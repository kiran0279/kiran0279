/**
* @Class Name: AccountTriggerHandler
* @Description: Used for AccountTrigger as handler Class.
* ================================================================================================================
* Version | Date | Author | Comments
* -----------------------------------------------------------------------------------------------------------------
* 1.0 | 21st Dec, 2020 | sujata.chaudhari@weare4c.com | 1. This class is used as handler for AccountTrigger.
* =================================================================================================================
*/
public without sharing class AccountTriggerHandler{
    public static set<Id> otmUserSet;
    public static set<Id> atmUserSet;
    public static Map<Id, Id> opptyUserMap;
    
    public static void afterInsert(List<Account> Acc, Map<Id,sObject> newAccountMap)
    {
        // Method to ensure account numbers entered are valid
        validateAccountNumber(); 
    }
    
    /*
* Get the List of Account and newAccountMap to set the Account team member owner list in /atmUserSet/otmUserSet/opptyUserMap.
* @param List, Map : Selected List of Account and key value set of Id, Account.
* @return Void
*/ 
    public static void beforeUpdate(List<Account> Acc, Map<Id,sObject> newAccountMap)
    {
        Set<Id> AccIds = new Set<Id>();
        Set<Id> AccIds1 = new Set<Id>();
        Set<string> Accnumber = new Set<string>();
        Map<string,list<account>> accountnumberaccmap = new Map<string,list<account>>();
        Set<string> entity = new Set<string>();
        /* 
* Loop through Account and identify if owner is getting changed.
*/
        for(Account obj : Acc){
            Account Accnt = (Account)newAccountMap.get(obj.Id);
            if(Accnt.OwnerId != obj.OwnerId){ 
                AccIds.add(Accnt.Id);
            }
        }
        /* 
* If Account owner is not empty set the Account team member owner list in atmUserSet.
* If Account owner is not empty set the Opportunity team member owner list in otmUserSet.
*/
        if(!GenericTriggerHelper.isLeadTriggerRunning){
            if(!AccIds.isEmpty()){
                atmUserSet = new Set<Id>(); 
                atmUserSet = getAccountTeamMember(AccIds);
                opptyUserMap = new Map<Id, Id>();
                opptyUserMap = getOpportunityUser(AccIds);
                /*
* If opptyUserMap is not empty set the Opportunity team member user in opptyUserMap.
*/
                if(!opptyUserMap.isEmpty()){
                    otmUserSet = new Set<Id>();
                    otmUserSet = getOpportunityTeamMember(opptyUserMap.keySet());
                }
            }
        }
    }

    public static void beforeInsert(List<Account> accList, Map<Id,sObject> newAccountMap){
        AutoCreateRandomNumberHandler.setPinNumberOnAccount(accList);
    }

    /*
* Get the List of Account and newAccountMap to set the Account team member owner list in /atmUserSet/otmUserSet/opptyUserMap.
* @param List, Map : Selected List of Account and key value set of Id, Account.
* @return Void
*/ 
    public static void beforeDelete(List<Account> Acc, Map<Id,sObject> newAccountMap)
    {
        Set<Id> AccIds = new Set<Id>();
        for(Account obj : Acc){
            AccIds.add(obj.Id);
        }
        /* 
* If Account owner is not empty set the Account team member owner list in atmUserSet.
* If Account owner is not empty set the Opportunity team member owner list in otmUserSet.
*/
        
        if(!AccIds.isEmpty()){
            atmUserSet = new Set<Id>();
            atmUserSet = getAccountTeamMember(AccIds);
            opptyUserMap = new Map<Id, Id>();
            opptyUserMap = getOpportunityUser(AccIds);
            /*
* If opptyUserMap is not empty set the Opportunity team member user in opptyUserMap.
*/
            if(!opptyUserMap.isEmpty()){
                otmUserSet = new Set<Id>();
                otmUserSet = getOpportunityTeamMember(opptyUserMap.keySet());
            } 
        }
    }
    /*
* Get the List of Account and oldAccountMap to updateUserCount.
* @param List, Map : Selected List of Account and key value set of Id, Account.
* @return Void
*/ 
    public static void afterUpdate(List<Account> Acc, Map<Id,sObject> oldAccountMap)
    {
        // Method to ensure account numbers entered are valid
        validateAccountNumber();
        Set<Id> userIds = new Set<Id>();
        /* 
* Loop through Account and identify if owner is getting changed.
*/
        for(Account obj : Acc){
            Account Accnt = (Account)oldAccountMap.get(obj.Id);
            if(Accnt.OwnerId != obj.OwnerId){ 
                userIds.add(Accnt.OwnerId);
                userIds.add(obj.OwnerId);
            }
        }
        /* 
* If Account owner is not empty call method to updateUserCount.
*/
        if(!GenericTriggerHelper.isLeadTriggerRunning){
            if(!userIds.isEmpty()){
                updateUserCount(userIds);
            }
        }
    }
    /*
* Get the List of Account and oldAccountMap to updateUserCount.
* @param List, Map : Selected List of Account and key value set of Id, Account.
* @return Void
*/ 
    public static void afterDelete(List<Account> Acc, Map<Id,sObject> oldAccountMap)
    {
        Set<Id> userIds = new Set<Id>();
        for(Account obj : Acc){
            userIds.add(obj.OwnerId);
        }
        /* 
* If Account owner is not empty call method to updateUserCount.
*/
        if(!userIds.isEmpty()){
            updateUserCount(userIds);
        } 
    }
    /*
* Get the Set of Account Team Member userId to updateUserCount if owner is not empty.
* @param Set<Id> : Selected Set User Id.
* @return Void
*/ 
    public static void updateUserCount(Set<Id> userIds){
        /* 
* If Account Team Member set is not empty add them in Account ownerId set.
*/
        if(!atmUserSet.isEmpty()){
            userIds.addAll(atmUserSet);  
        }
        /* 
* If Opportunity set is not empty add them in Account ownerId set.
* If Opportunity Team Member set is not empty add them in Account ownerId set.
*/ 
        if(!opptyUserMap.isEmpty()){
            userIds.addAll(opptyUserMap.values());  
            if(!otmUserSet.isEmpty()){
                userIds.addAll(otmUserSet);  
            }
        }
        GenericHelperUtil.submitUserListForUpdate(userIds);	 
    }
    /*
* Get the Set of OpportunityTeamMember userId to update OpportunityTeamMember count.
* @param Set<Id> : Selected Set of OpportunityTeamMember Id.
* @return Void
*/
    public static Set<Id> getOpportunityTeamMember(Set<Id> OpportunityIds){
        Set<Id> otmSet = new Set<Id>();
        List<OpportunityTeamMember> otmList  = [SELECT Id, UserId FROM OpportunityTeamMember WHERE OpportunityID IN :OpportunityIds];
        if(!otmList.isEmpty()){
            for(OpportunityTeamMember otm : otmList){
                otmSet.add(otm.UserId);
            }
        }
        return otmSet;
    } 
    /*
* Get the Map of Opportunity userId to update Opportunity count.
* @param Map : Selected Set of Opportunity Id.
* @return Void
*/
    public static Map<Id, Id> getOpportunityUser(Set<Id> AccountIds){
        Map<Id, Id> opptyUserMap = new Map<Id, Id>();
        List<Opportunity> opptyList  = [SELECT Id, OwnerId FROM Opportunity WHERE AccountId IN :AccountIds];
        if(!opptyList.isEmpty()){
            for(Opportunity oppty : opptyList){
                opptyUserMap.put(oppty.Id, oppty.OwnerId);
            }
        }
        return opptyUserMap;
    } 
    /*
* Get the Map of AccountTeamMember userId to update AccountTeamMember count.
* @param Map : Selected Set of AccountTeamMember Id.
* @return Void
*/
    public static Set<Id> getAccountTeamMember(Set<Id> AccountIds){
        Set<Id> atmSet = new Set<Id>();
        List<AccountTeamMember> atmList  = [SELECT Id, UserId FROM AccountTeamMember WHERE AccountId IN :AccountIds];
        if(!atmList.isEmpty()){
            for(AccountTeamMember atm : atmList){
                atmSet.add(atm.UserId);
            }
        }
        return atmSet;
    }
    
    public static void validateAccountNumber(){
        Id billingRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Set<String> accountNumberSet = new Set<String>();
        for(Account account :(List<Account>)trigger.new){
            if(account.RecordTypeId == billingRecordTypeId 
               && trigger.isInsert
               ||(trigger.isUpdate
                  && account.AccountNumber != trigger.oldMap.get(account.Id).get('AccountNumber'))){
                      accountNumberSet.add(account.AccountNumber);
                  }
        }
        
        List<Account> accountList = [SELECT Id, AccountNumber, ParentId, Parent.Account_Entity__r.Legal_Entity__c, 
                                     Parent.Account_Entity__r.Entity__c, Parent.Account_Entity__r.Allow_Duplicate__c
                                     FROM Account
                                     WHERE AccountNumber IN :accountNumberSet
                                     AND RecordTypeId = :billingRecordTypeId];
        Map<String, List<Account>> accountMap = new Map<String, List<Account>>();
        Map<Id, Account> updatedAccountMap = new Map<Id, Account>();
        for(Account account :accountList){
            updatedAccountMap.put(account.Id, account);
            if(accountMap.containsKey(account.AccountNumber)){
                List<Account> accList = accountMap.get(account.AccountNumber);
                accList.add(account);
                accountMap.put(account.AccountNumber,accList);
            }else{
                accountMap.put(account.AccountNumber, new List<Account> {account});  
            }
        }
        for(Account account : (List<Account>)trigger.new){
            if(accountMap.containsKey(account.AccountNumber)){
                List<Account> existingAccList = accountMap.get(account.AccountNumber);
                if(updatedAccountMap.containsKey(account.Id)){
                    Account updatedAccount = updatedAccountMap.get(account.Id);
                    for(Account existingAccount :existingAccList){
                        if(account.Id != existingAccount.Id
                           && updatedAccount.Parent.Account_Entity__r.Legal_Entity__c != existingAccount.Parent.Account_Entity__r.Legal_Entity__c){
                               account.addError('Account Number already exists on another Legal Entity. Please populate another Account Number');
                           }else if(account.Id != existingAccount.Id
                                    && updatedAccount.Parent.Account_Entity__r.Entity__c != existingAccount.Parent.Account_Entity__r.Entity__c
                                    && (!updatedAccount.Parent.Account_Entity__r.Allow_Duplicate__c
                                    || !existingAccount.Parent.Account_Entity__r.Allow_Duplicate__c)){
                                        account.addError('Account Number already exists on another Entity within same Legal Entity. Please populate another Account Number');  
                                    }
                    }   
                }
                
            }
        }
    }
}