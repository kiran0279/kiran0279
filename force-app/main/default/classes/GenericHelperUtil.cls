/**
    * @Class Name: GenericHelperUtil
    * @Description: Used as generic helper Class.
    * ================================================================================================================
    * Version | Date | Author 
    * -----------------------------------------------------------------------------------------------------------------
    * 1.0 | 24th Dec, 2020 | sujata.chaudhari@weare4c.com  
    * =================================================================================================================
    */
    public without sharing class GenericHelperUtil{
        /**
        * This method gets the count of Opportunities, Account, Opportunity Team Member, Account Team Member for a given set of users.
        * @param Set<Id> : Selected Set of UserIds.
        * @return Map<Id,Integer> : Key value pair of Count for each user.
        */
        public static Map<Id,Integer> getTotalCount(Set<Id> UserIds){
            Map<Id,Integer> totalAccOppCount=new Map<Id,Integer>();
                if(!UserIds.isEmpty()){
                /*
                * Get count of Account records with provided set of userIds. 
                */ 
                    for(AggregateResult ar :[Select OwnerId,COUNT(id) totalAcc from Account WHERE OwnerId IN:UserIds GROUP BY OwnerId ]){
                        totalAccOppCount.put((Id)ar.get('OwnerId'),(Integer)ar.get('totalAcc'));
                    }
                    /*
                    * Get count of AccountTeamMember records with provided set of userIds. 
                    */
                    for(AggregateResult ar :[Select UserId,COUNT(Id) totalUserOnAccTMember from AccountTeamMember WHERE UserId IN:UserIds GROUP BY UserId ]){
                        if(totalAccOppCount.containsKey((Id)ar.get('UserId'))){
                            totalAccOppCount.put((Id)ar.get('UserId'), (Integer)totalAccOppCount.get((Id)ar.get('UserId')) + (Integer)ar.get('totalUserOnAccTMember'));
                        }else{
                            totalAccOppCount.put((Id)ar.get('UserId'),(Integer)ar.get('totalUserOnAccTMember'));
                        } 
                    }
                    /*
                    * Get count of OpportunityTeamMember records with provided set of userIds. 
                    */
                    for(AggregateResult ar :[Select UserId,COUNT(Id) totalUserOnOppTMember from OpportunityTeamMember WHERE UserId IN:UserIds GROUP BY UserId ]){
                        if(totalAccOppCount.containsKey((Id)ar.get('UserId'))){
                            totalAccOppCount.put((Id)ar.get('UserId'), (Integer)totalAccOppCount.get((Id)ar.get('UserId')) + (Integer)ar.get('totalUserOnOppTMember'));
                                                                                                          system.debug('totalAccOppCount-1>>>'+totalAccOppCount);
                        }else{
                            totalAccOppCount.put((Id)ar.get('UserId'),(Integer)ar.get('totalUserOnOppTMember'));
                                                                                    system.debug('totalAccOppCount0>>>'+totalAccOppCount);
                        } 
                    }
                    /*
                    * Get count of Opportunity records with provided set of userIds. 
                    */
                    for(AggregateResult ar :[Select OwnerId, COUNT(id) totalOpp from Opportunity WHERE OwnerId IN:UserIds GROUP BY OwnerId ]){
                        if(totalAccOppCount.containsKey((Id)ar.get('OwnerId'))){
                            totalAccOppCount.put((Id)ar.get('OwnerId'), (Integer)totalAccOppCount.get((Id)ar.get('OwnerId')) + (Integer)ar.get('totalOpp'));
                                                        system.debug('totalAccOppCount1>>>'+totalAccOppCount);
                        }else{
                            totalAccOppCount.put((Id)ar.get('OwnerId'),(Integer)ar.get('totalOpp'));
                            system.debug('totalAccOppCount>>>'+totalAccOppCount);
                        }  
                    }      
                    /*
                    * If there are no records for the provided userIds then set totalAccOppCount as 0.
                    */
                    List<Id> listUserIds = new List<Id>(UserIds);
                    for(Id Ids: listUserIds){
                        if(totalAccOppCount.get(Ids) == null){
                            totalAccOppCount.put(Ids, 0);
                        }        
                    }
                }
            return totalAccOppCount; 
        }
        /*
        * Update Opportunity count on User record on update or delete action.
        * @param Set : Selected User Set of UserIds.
        * @return Void 
        */
        public static void submitUserListForUpdate(Set<Id> userSet){
            if(!userSet.isEmpty()){
                System.enqueueJob(new UpdateUser(userSet));
            }
        }
    }