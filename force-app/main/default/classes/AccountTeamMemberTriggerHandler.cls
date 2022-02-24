/**
    * @Class Name: AccountTeamMemberTriggerHandler
    * @Description: Used for AccountTeamMemberTrigger as handler Class.
    * ================================================================================================================
    * Version | Date | Author | Comments
    * -----------------------------------------------------------------------------------------------------------------
    * 1.0 | 22nd Dec, 2020 | sujata.chaudhari@weare4c.com | 1. This class is used as handler for AccountTeamMemberTrigger.
    * Modified By: Bhupesh Kumar to add the validation logic of add/remove member for credit manager profile.
    * =================================================================================================================
    */
public without sharing class AccountTeamMemberTriggerHandler{
    /*
    * Get the List of AccountTeamMember to update user count if owner is not empty.
    * @param List : Selected List of AccountTeamMember.
    * @return Void
    */ 
    
    static Id currentUserProfileId = UserInfo.getProfileId();
 
    static Id creditManager = [SELECT Id, Name FROM Profile WHERE Name = 'Credit Manager' limit 1].Id;
    static Set<Id> userATMId = new Set<Id>();
    static Set<Id> selectedUserId = new Set<Id>();
    static String customLabelFirst = System.Label.CreditManagerTeamUser;
    static String customLabelSecond = System.Label.CreditManagerTeamRole;
    static String customLabelThird = System.Label.CreditManagerTeamRemove;
        
    public static void afterInsert(List<AccountTeamMember> atm) {
     
        Set<Id> userIds = new Set<Id>();
        // Loop through Account and identify if owner is getting changed and add their Ids in a set.
        for (AccountTeamMember obj : atm){ 
            userIds.add(obj.UserId);
        }
        // If Account owner is not empty call method to update user count.
        if(!GenericTriggerHelper.isLeadTriggerRunning){
            if(!userIds.isEmpty()){
                GenericHelperUtil.submitUserListForUpdate(userIds);
            }
        }
    }
    /*
    * Get the List of AccountTeamMember to update user count if owner is not empty.
    * @param List : Selected List of AccountTeamMember.
    * @return Void
    */
    public static void afterDelete(List<AccountTeamMember> atm) {
    
        Set<Id> userIds = new Set<Id>();
        for (AccountTeamMember obj : atm){
            userIds.add(obj.UserId);
        }
        // If AccountTeamMember owner is not empty call method to update user count.
        if(!userIds.isEmpty()){
            GenericHelperUtil.submitUserListForUpdate(userIds);
        } 
    }
    
    public static void OnBeforeInsert(List<AccountTeamMember> atm) {
        // BEFORE INSERT LOGIC
        showErrorOnAddMember(atm);
    }   
           
    public static void OnBeforeUpdate(List<AccountTeamMember> atm) {
        // BEFORE UPDATE LOGIC
        showErrorOnAddMember(atm);
    }
       
    public static void OnBeforeDelete(List<AccountTeamMember> atm) {
        // BEFORE DELETE LOGIC
        showErrorOnRemoveMember(atm);
    }  
    
    public static void showErrorOnAddMember(List<AccountTeamMember> lstATM) {
    
        if(currentUserProfileId == creditManager) {
            for(AccountTeamMember atm : lstATM) {
                userATMId.add(atm.UserId);
            }
            
            List<User> lstATMUser = [Select Id, ProfileId, Profile.Name From User Where Id IN : userATMId AND Profile.Name != 'Credit Manager'];
            for(User Usr : lstATMUser) {
                selectedUserId.add(Usr.Id);
            }
            
            for(AccountTeamMember atm : lstATM) {
                if(selectedUserId.contains(atm.UserId)) {
                    atm.addError(customLabelFirst);
                }
                else if(atm.TeamMemberRole != 'Credit Manager') {
                    atm.addError(customLabelSecond);
                }
            }
        }   
    }
    
    public static void showErrorOnRemoveMember(List<AccountTeamMember> lstATM) {
        
        if(currentUserProfileId == creditManager) {
            for(AccountTeamMember atm : lstATM) {
                userATMId.add(atm.UserId);
            }
            
            List<User> lstATMUser = [Select Id, ProfileId, Profile.Name From User Where Id IN : userATMId AND Profile.Name != 'Credit Manager'];
            for(User Usr : lstATMUser) {
                selectedUserId.add(Usr.Id);
            }
            
            for(AccountTeamMember atm : lstATM) {
                if(selectedUserId.contains(atm.UserId)) {
                    atm.addError(customLabelThird);
                }
            }
        }   
    }
}