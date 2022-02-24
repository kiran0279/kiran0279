/***
* Class for lead conversion assignments
* 18/12/2020 neha.kumari@weare4c.com [REQ-ARMX-0259 and ARMX-0260] v1.0
*/
public with sharing class ConvertedLeadAssignmentRules{
    
    // public static void handleLeadConversion(Lead[] convertedLeadsList){   
    //     if(convertedLeadsList == null || convertedLeadsList.isEmpty()) return;//return if lead list is empty
        
    //     //Retrieve the segment, vertical and entity values of the Lead
    //     List<String> segList=new List<String>();
    //     List<String> vertList=new List<String>();
    //     List<String> entList=new List<String>();
    //     for(Lead ld : convertedLeadsList){            
    //         segList.add(ld.Segment__c);
    //         vertList.add(ld.Vertical__c);
    //         entList.add(ld.Entity__c);
    //     }
        
    //     Map<Id,User> usersWithMatchingLeadValues= new Map<Id,User>();
    //     Map<Id,Lead> convertedLeadMap = new Map<Id,Lead>(convertedLeadsList);
    //     //Map<Id,Lead> convertedLeadMap = new Map<Id,Lead>([Select Id,ConvertedOpportunityId,ConvertedAccountId,Segment__c,Vertical__c,Entity__c from Lead where Id IN:convertedLeadsList]);
        
    //     //Find the profile id of "Account Manager"
    //     Id accManagerProfileId = ConvertedLeadAssignmentRules.retrieveProfileId('Account Manager');
        
    //     //filter of users if they are active, have non blank segment, vertical and entity, and profile as Account Manager
    //     for(User users: [SELECT Id,Name,Segment__c,Vertical__c,Entity__c 
    //                      FROM User 
    //                      WHERE isActive=true AND profileId = :accManagerProfileId AND (Segment__c In :segList AND Vertical__c In :vertList AND Entity__c In :entList)]){
    //                          usersWithMatchingLeadValues.put(users.id,users); 
    //                      }
    //     if(usersWithMatchingLeadValues == null && usersWithMatchingLeadValues.isEmpty()) return;//return if no matching users found
        
    //     //Find the number of accounts and opportunities assigned to the users
    //     Map<Id,Integer> totalAccOppCount=new Map<Id,Integer>() ; 
    //     totalAccOppCount = countOfTotalAccountOnUser(usersWithMatchingLeadValues,totalAccOppCount);
    //     totalAccOppCount = countOfTotalOpportunityOnUser(usersWithMatchingLeadValues,totalAccOppCount);
    //     totalAccOppCount = countOfTotalAccountMemberOfUser(usersWithMatchingLeadValues,totalAccOppCount);
    //     totalAccOppCount = countOfTotalOpportunityMemberOfUser(usersWithMatchingLeadValues,totalAccOppCount);
    //     System.debug('totalAccOppCount-->'+totalAccOppCount);           
    //     //Perform match of users against each Lead
    //     Map<Id,Id> userByLead= new Map<id,Id>();
    //     List<Account> accsToBeUpdated=new List<Account>();
    //     List<Opportunity> oppsToBeUpdated=new List<Opportunity>();
        
    //     for(Id keyOfLeadId: convertedLeadMap.keySet()){
    //         Lead l = (Lead)convertedLeadMap.get(keyOfLeadId);
    //         String leadSegment = l.Segment__c;
    //         String leadVertical = l.Vertical__c;
    //         String leadEntity = l.Entity__c;
            
    //         for(User usr: usersWithMatchingLeadValues.values()){
    //             if(usr.Segment__c.contains(leadSegment) && usr.Vertical__c.contains(leadVertical) && usr.Entity__c.contains(leadEntity)){
    //                 if(userByLead.containsKey(l.id)){
    //                     id userId = userByLead.get(l.id);
    //                     if(totalAccOppCount.get(userId) > totalAccOppCount.get(usr.id)){
    //                         userByLead.put(l.id,usr.id);
    //                     }
    //                 }else{
    //                     userByLead.put(l.id,usr.id);
    //                 }
    //             }  
    //         }//end of User loop
    //         if(userByLead.containsKey(l.id)){
    //             accsToBeUpdated.add(new Account(Id=l.ConvertedAccountId,ownerId=userByLead.get(l.id)));
    //             oppsToBeUpdated.add(new Opportunity(Id=l.ConvertedOpportunityId,ownerId=userByLead.get(l.id)));
    //         }   
    //     }//end of Lead map loop
    //     update accsToBeUpdated;
    //     update oppsToBeUpdated;
        
    // }
    
    // public static Id retrieveProfileId(String profileName){
    //     Id profileId = [Select Id from Profile where Name =:profileName LIMIT 1].Id;
    //     return profileId;
    // }
    
    // public static Map<Id,Integer> countOfTotalAccountOnUser(Map<Id,User>  usersMap,Map<Id,Integer> totalAccOppCount){
    //     for(AggregateResult ar :[Select OwnerId,COUNT(id) totalAcc from Account WHERE OwnerId IN:usersMap.keySet() GROUP BY OwnerId ]){
    //         if(totalAccOppCount.containsKey((Id)ar.get('OwnerId'))){
    //             totalAccOppCount.put((Id)ar.get('OwnerId'), (Integer)totalAccOppCount.get((Id)ar.get('OwnerId')) + (Integer)ar.get('totalAcc'));
    //         }else{           
    //             totalAccOppCount.put((Id)ar.get('OwnerId'),(Integer)ar.get('totalAcc'));
    //         }
    //     }
    //     return totalAccOppCount;
    // }
    
    // public static Map<Id,Integer> countOfTotalOpportunityOnUser(Map<Id,User>  usersMap,Map<Id,Integer> totalAccOppCount){
    //     for(AggregateResult ar :[Select OwnerId, COUNT(id) totalOpp from Opportunity WHERE OwnerId IN:usersMap.keySet() GROUP BY OwnerId ]){
    //         if(totalAccOppCount.containsKey((Id)ar.get('OwnerId'))){
    //             totalAccOppCount.put((Id)ar.get('OwnerId'), (Integer)totalAccOppCount.get((Id)ar.get('OwnerId')) + (Integer)ar.get('totalOpp'));
    //         }else{
    //             totalAccOppCount.put((Id)ar.get('OwnerId'),(Integer)ar.get('totalOpp'));
    //         }  
    //     } 
    //     return totalAccOppCount;
    // }    
    
    // public static Map<Id,Integer> countOfTotalAccountMemberOfUser(Map<Id,User>  usersMap,Map<Id,Integer> totalAccOppCount){
    //     for(AggregateResult ar :[Select UserId,COUNT(Id) totalUserOnAccTMember from AccountTeamMember WHERE UserId IN:usersMap.keySet() GROUP BY UserId ]){
    //         if(totalAccOppCount.containsKey((Id)ar.get('UserId'))){
    //             totalAccOppCount.put((Id)ar.get('UserId'), (Integer)totalAccOppCount.get((Id)ar.get('UserId')) + (Integer)ar.get('totalUserOnAccTMember'));
    //         }else{
    //             totalAccOppCount.put((Id)ar.get('OwnerId'),(Integer)ar.get('totalUserOnAccTMember'));
    //         } 
    //     }
    //     return totalAccOppCount;
    // }
    
    // public static Map<Id,Integer> countOfTotalOpportunityMemberOfUser(Map<Id,User>  usersMap,Map<Id,Integer> totalAccOppCount){
    //     for(AggregateResult ar :[Select UserId,COUNT(Id) totalUserOnOppTMember from OpportunityTeamMember WHERE UserId IN:usersMap.keySet() GROUP BY UserId ]){
    //         if(totalAccOppCount.containsKey((Id)ar.get('UserId'))){
    //             totalAccOppCount.put((Id)ar.get('UserId'), (Integer)totalAccOppCount.get((Id)ar.get('UserId')) + (Integer)ar.get('totalUserOnOppTMember'));
    //         }else{
    //             totalAccOppCount.put((Id)ar.get('OwnerId'),(Integer)ar.get('totalUserOnOppTMember'));
    //         } 
    //     }
    //     return totalAccOppCount;
    // }
}