/**
    * @Class Name: OpportunityTeamMemberTriggerHandler
    * @Description: Used for OpportunityTeamMemberTrigger as handler Class.
    * ================================================================================================================
    * Version | Date | Author | Comments
    * -----------------------------------------------------------------------------------------------------------------
    * 1.0 | 22nd Dec, 2020 | sujata.chaudhari@weare4c.com | 1. This class is used as handler for OpportunityTeamMemberTrigger.
    * =================================================================================================================
    */
    public without sharing class OpportunityTeamMemberTriggerHandler{
        /*
        * Get the List of OpportunityTeamMember to update user count if owner is not empty.
        * @param List : Selected List of OpportunityTeamMember.
        * @return Void
        */ 
        public static void afterInsert(List<OpportunityTeamMember> Otm)
        {
            Set<Id> userIds = new Set<Id>();
            /*
            * Loop through opportunity and identify if owner is getting changed and add their Ids in a set.
            */
            for (OpportunityTeamMember obj : Otm){ 
                userIds.add(obj.UserId);
            }
            /* 
            * If opportunity owner is not empty call method to update user count.
            */
            if(!GenericTriggerHelper.isLeadTriggerRunning){
                if(!userIds.isEmpty()){
                    GenericHelperUtil.submitUserListForUpdate(userIds);
                }
            }
        }
        /*
        * Get the List of OpportunityTeamMember to update user count if owner is not empty.
        * @param List : Selected List of OpportunityTeamMember.
        * @return Void
        */  
        public static void afterDelete(List<OpportunityTeamMember> Otm)
        {
            Set<Id> userIds = new Set<Id>();
            for (OpportunityTeamMember obj : Otm){
                userIds.add(obj.UserId);
            }
            /* 
            * If OpportunityTeamMember owner is not empty call method to update user count.
            */
            if(!userIds.isEmpty()){
                GenericHelperUtil.submitUserListForUpdate(userIds);
            } 
        }
    }