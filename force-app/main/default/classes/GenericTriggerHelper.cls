/**
    * @Class Name: GenericTriggerHelper
    * @Description: Used as generic helper Class.
    * ================================================================================================================
    * Version | Date | Author 
    * -----------------------------------------------------------------------------------------------------------------
    * 1.0 | 7th Jan, 2021 | sujata.chaudhari@weare4c.com  
    * =================================================================================================================
    */
    public class GenericTriggerHelper{
        public static boolean isLeadTriggerRunning =false;
        public static Map<Id, User> accountManagerUserMap = new Map<Id, User>();
        public static Map<Id, User> getAccountManagerUserMap(){
            if(accountManagerUserMap.isEmpty()){   
                accountManagerUserMap = new Map<Id,User>([SELECT Id,Name,Segment__c,Vertical__c,Entity__c 
                                                        FROM User WHERE isActive=true AND Profile.Name = 'Account Manager']);
                return accountManagerUserMap;
                
            }else{
                return accountManagerUserMap;
            }
        }
    }