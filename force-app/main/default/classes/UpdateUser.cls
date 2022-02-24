/**
    * @Class Name: UpdateUser
    * @Description: Used as Queueable Class.
    * ================================================================================================================
    * Version | Date | Author 
    * -----------------------------------------------------------------------------------------------------------------
    * 1.0 | 21st Dec, 2020 | sujata.chaudhari@weare4c.com  
    * 1.1 | 6th Jan, 2021 | sujata.chaudhari@weare4c.com 
    * =================================================================================================================
    */
    public class UpdateUser implements Queueable{
        public class OtherException extends Exception{}
        Private Set<Id> userSet;
        Public UpdateUser(Set<Id> userSet){
            this.userSet = userSet;
        }  
        public void execute(QueueableContext context){
            try{
                Map<Id,Integer> totalAccAccCount=new Map<Id,Integer>();
                Set<User> userIds = new Set<User>();
                if(!userSet.isEmpty()){
                totalAccAccCount = GenericHelperUtil.getTotalCount(userSet);  
                    if(!totalAccAccCount.isEmpty()){
                        for(Id ids : userSet){
                            userIds.add(new User(Id=ids, No_of_Account_or_Opportunities_Owned__c = (Integer)totalAccAccCount.get(ids)));
                        }
                    }
                }else{
                    Throw new OtherException('User Set is Empty');
                }
                if(!userIds.isEmpty()){
                    Update new List<User>(userIds);
                }
            }catch(Exception e){
                System.debug(e.getMessage());
            }
        }
    }