/**
    * @Class Name: OpportunityTriggerHandler
    * @Description: Used for OpportunityTrigger as handler Class.
    * ================================================================================================================
    * Version | Date | Author | Comments
    * -----------------------------------------------------------------------------------------------------------------
    * 1.0 | 21st Dec, 2020 | sujata.chaudhari@weare4c.com | 1. This class is used as handler for OpportunityTrigger.
    * =================================================================================================================
    */
    public without sharing class OpportunityTriggerHandler{
        public static set<Id> otmUserSet;
        /*
        * Get the List of Opportunity and newOpportunityMap to set the opportunity team member owner list in otmUserSet.
        * @param List, Map : Selected List of Opportunity and key value set of Id, Opportunity.
        * @return Void
        */ 
        public static void beforeUpdate(List<Opportunity> Opp, Map<Id,sObject> newOpportunityMap)
        {
            Set<Id> opptyIds = new Set<Id>();
            /* 
            * Loop through opportunity and identify if owner is getting changed.
            */
            for(Opportunity obj : Opp){
                Opportunity oppty = (Opportunity)newOpportunityMap.get(obj.Id);
                if(oppty.OwnerId != obj.OwnerId){ 
                    opptyIds.add(oppty.Id);
                }
            }
            /* 
            * If opportunity owner is not empty set the opportunity team member owner list in otmUserSet.
            */
            if(!opptyIds.isEmpty()){
                getOpportunityTeamMember(opptyIds);
            }
        }
        /*
        * Get the List of Opportunity and oldOpportunityMap to set the opportunity team member owner list in otmUserSet.
        * @param List, Map : Selected List of Opportunity and key value set of Id, Opportunity.
        * @return Void
        */ 
        public static void beforeDelete(List<Opportunity> Opp, Map<Id,sObject> oldOpportunityMap)
        {
            Set<Id> opptyIds = new Set<Id>();
            for(Opportunity obj : Opp){
                opptyIds.add(obj.Id);
            }
            /* 
            * If opportunity owner is not empty set the opportunity team member owner list in otmUserSet.
            */
            if(!opptyIds.isEmpty()){
                getOpportunityTeamMember(opptyIds);
            } 
        }
        /*
        * Get the List of Opportunity and oldOpportunityMap to updateUserCount.
        * @param List, Map : Selected List of Opportunity and key value set of Id, Opportunity.
        * @return Void
        */ 
        public static void afterUpdate(List<Opportunity> Opp, Map<Id,sObject> oldOpportunityMap)
        {
            Set<Id> userIds = new Set<Id>();
            otmUserSet = new Set<Id>();
            /* 
            * Loop through opportunity and identify if owner is getting changed and add their Ids in a set.
            */
            for(Opportunity obj : Opp){
                Opportunity oppty = (Opportunity)oldOpportunityMap.get(obj.Id);
                if(oppty.OwnerId != obj.OwnerId){ 
                    userIds.add(oppty.OwnerId);
                    userIds.add(obj.OwnerId);
                }
            }
            /* 
            * If opportunity owner is not empty call method to updateUserCount.
            */
            if(!userIds.isEmpty()){
                updateUserCount(userIds);
            } 
        }
        /*
        * Get the List of Opportunity and oldOpportunityMap to updateUserCount.
        * @param List, Map : Selected List of Opportunity and key value set of Id, Opportunity.
        * @return Void
        */ 
        public static void afterDelete(List<Opportunity> Opp, Map<Id,sObject> oldOpportunityMap)
        {
            Set<Id> userIds = new Set<Id>();
            for(Opportunity obj : Opp){
                userIds.add(obj.OwnerId);
            }
            /* 
            * If opportunity owner is not empty call method to updateUserCount.
            */
            if(!userIds.isEmpty()){
                updateUserCount(userIds);
            } 
        }
        /*
        * Get the Set of Opportunity Team Member userId to updateUserCount if owner is not empty.
        * @param Set<Id> : Selected Set User Id.
        * @return Void
        */ 
        public static void updateUserCount(Set<Id> userIds){
            otmUserSet = new Set<Id>();
            /* 
            * If Opportunity Team Member set is not empty add them in opportunity ownerId set.
            */
            if(!otmUserSet.isEmpty()){
                userIds.addAll(otmUserSet);  
            } 
            GenericHelperUtil.submitUserListForUpdate(userIds);
        }
        /*
        * Get the Set of OpportunityTeamMember userId.
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
    }