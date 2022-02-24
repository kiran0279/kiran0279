/**
    * @Class Name: LeadTriggerHandler
    * @Description: Used for LeadTrigger as handler Class.
    * ================================================================================================================
    * Version | Date | Author | Comments
    * -----------------------------------------------------------------------------------------------------------------
    * 1.0 | 10th Dec, 2020 | neha.kumari@weare4c.com | 1. This class is used as handler for LeadTrigger.
    * 1.1 | 18th Dec, 2020 | sujata.chaudhari@weare4c.com | 1. This class is used as handler for LeadTrigger.
    * =================================================================================================================
    */
    public without sharing class LeadTriggerHandler{

        /**
        * This method converts Lead to Account, Opportunity, Contact and assign those Account and Opportunities to 
        * the user with given criteria and update the Account and opportunities count field value on user record.
        * @param List<Lead>, Map<Id,sObject> : Selected List of Leads and old Lead Map.
        * @return Void 
        */
        public static void afterUpdate(List<Lead> listOfLead,Map<Id,sObject> oldLeadMap){
            //check if lead is converted
            List<Lead> convertedListOfLeads=new List<Lead>();
            /*
            * Remove this from a query to use either the schema or if the scheme isn't available use the singleton method
            */
            Map<Id,User> extractedUsers = GenericTriggerHelper.getAccountManagerUserMap();
            
            Set<Id> accountIds = new Set<Id>();
            Set<Id> opportunityIds = new Set<Id>();

            for(Lead ld:listOfLead){
                Boolean isOldLeadConverted = oldLeadMap.get(ld.id).get('isConverted') == false;
                Boolean isConvertedOpportunityIdNull = oldLeadMap.get(ld.id).get('convertedOpportunityId') == null;
                Boolean isConvertedAccountIdNull = oldLeadMap.get(ld.id).get('convertedAccountId') == null;
                
                if(ld.isConverted && isOldLeadConverted && isConvertedOpportunityIdNull && isConvertedAccountIdNull)
                {
                    convertedListOfLeads.add(ld);
                    accountIds.add(ld.convertedAccountId);
                    opportunityIds.add(ld.convertedOpportunityId);
                }
            }

            if(!convertedListOfLeads.isEmpty() && !extractedUsers.isEmpty()){
                GenericTriggerHelper.isLeadTriggerRunning = true;
                updateOwnerIdOnAccOppty(convertedListOfLeads, extractedUsers, accountIds, opportunityIds);
                GenericTriggerHelper.isLeadTriggerRunning = false;
            }//convertedListOfLeads
        }
        public static void updateOwnerIdOnAccOppty(List<Lead> convertedListOfLeads, Map<Id, User> extractedUsers, Set<Id> accountIds, Set<Id> opportunityIds){
            Map<Id,Lead> mapLead = new Map<Id,Lead>([Select Id,ConvertedOpportunityId,ConvertedAccountId,Segment__c,Vertical__c,Entity__c from Lead where Id IN:convertedListOfLeads]);
            Map<Id,Integer> totalAccOppCount=new Map<Id,Integer>(); 
            totalAccOppCount = GenericHelperUtil.getTotalCount(extractedUsers.keyset());
            //Perform match of users against each Lead
            List<Lead> ldList= new List<Lead>();
            Map<Id,Id> userByLead= new Map<id,Id>();
            List<Account> accsToBeUpdated=new List<Account>();
            List<Opportunity> oppsToBeUpdated=new List<Opportunity>();
            Set<Id> userIds = new Set<Id>(); 

            
            Map<Id, Account> accountRecordsMap = new Map<Id, Account>([Select Id, OwnerId From Account Where Id IN : accountIds]);
            Map<Id, Opportunity> opportunityRecordsMap = new Map<Id, Opportunity>([Select Id, OwnerId From Opportunity Where Id IN : opportunityIds]);

            for(Id keyOfLeadId: mapLead.keySet()){  
                Lead l = (Lead)mapLead.get(keyOfLeadId);
                Boolean mapContainsLeadId = false;
                Id getUserId = null;
                Boolean userFound = false;
                Integer minRecordCount = 100000000;
                
                for(User usr: extractedUsers.values()){

                    Boolean isSegmentVerticalEntityExists = (usr.Segment__c != null && usr.Vertical__c != null  && usr.Entity__c != null)?True:False;
                    Boolean containsSegment = isSegmentVerticalEntityExists && usr.Segment__c.contains(l.Segment__c);
                    Boolean containsVertical = isSegmentVerticalEntityExists && usr.Vertical__c.contains(l.Vertical__c);
                    Boolean containsEntity = isSegmentVerticalEntityExists && usr.Entity__c.contains(l.Entity__c);
                    Boolean containsAll = containsSegment && containsVertical && containsEntity ;
                   // Boolean containsAll = containsSegment && containsVertical ;
                    getUserId = mapContainsLeadId ? userByLead.get(l.id) : null;
                    Integer mapUserCount = mapContainsLeadId ? totalAccOppCount.get(getUserId) : 0;
                    Integer userCount =  totalAccOppCount.get(usr.id);
                    
                    // if(containsAll && mapContainsLeadId && (mapUserCount > userCount)){
                    if(containsAll && mapContainsLeadId){
                        userByLead.put(l.id, usr.id);
                        if (minRecordCount > userCount) {
                            minRecordCount = userCount;
                            userFound = true;
                            getUserId = userByLead.get(l.id);
                        }
                    } else if(!mapContainsLeadId){
                        userByLead.put(l.id,usr.id);
                    }
                        
                    getUserId = userByLead.get(l.id);
                    mapContainsLeadId = userByLead.containsKey(l.id);
                }

          /* 
           * Lines of code for changing the userid to CRM TEAM Sonam
           *      String customLabelValue = System.Label.UserNameforAMAssignment;
                User uId = [SELECT Id FROM User WHERE FirstName = :customLabelValue Limit 1];
                if (!userFound && uId != Null) {
                    getUserId = uId.Id;
                }*/
                //New code to fetch the current user of the lead
                Lead lId = [select OwnerId from Lead where Id IN:convertedListOfLeads];                
                if (!userFound && lId != Null) {
                    getUserId= lId.ownerId;
                    //getUserId = uId.Id;
                }
                //Code changes are done
                //Changes done on 22/12/2021
                
                Boolean accountOwnerIdHasChanged = accountRecordsMap.containsKey(l.ConvertedAccountId) && accountRecordsMap.get(l.ConvertedAccountId).ownerId != getUserId;
                if(mapContainsLeadId && accountOwnerIdHasChanged) {
                   accsToBeUpdated.add(new Account(Id=l.ConvertedAccountId,ownerId=getUserId));
                    //  accsToBeUpdated.add(new Account(Id=l.ConvertedAccountId,ownerId='0053N000006anDJQAY'));
                    system.debug(getUserId);
                }

                Boolean opportunityOwnerIdHasChanged = opportunityRecordsMap.containsKey(l.ConvertedOpportunityId) && opportunityRecordsMap.get(l.ConvertedOpportunityId).ownerId != getUserId;
                if(mapContainsLeadId && opportunityOwnerIdHasChanged) {
                    oppsToBeUpdated.add(new Opportunity(Id=l.ConvertedOpportunityId,ownerId=getUserId));
                }

                if(mapContainsLeadId) {
                    userIds.add(getUserId);
                    /*
                    * In case of bulk lead conversion adding +2 to reflect latest count of the owner.
                    */
                    if (userFound) {
                        totalAccOppCount.put((Id)getUserId, (Integer)totalAccOppCount.get(getUserId)+2);
                    }
                }
            }//end of Lead map loop
            //Perform DML updates on opportunity, account and count for user
            if(!accsToBeUpdated.isEmpty()){
                update accsToBeUpdated;
            }
            if(!oppsToBeUpdated.isEmpty()){
                update oppsToBeUpdated;
            }                    
            if(!userIds.isEmpty()){
                GenericHelperUtil.submitUserListForUpdate(userIds);
            }
        }
      
    }