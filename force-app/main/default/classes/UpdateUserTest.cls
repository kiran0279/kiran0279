/**
    * @Class Name: UpdateUserTest
    * @Description: Used for UpdateUser class as a test class.
    * ================================================================================================================
    * Version | Date | Author 
    * -----------------------------------------------------------------------------------------------------------------
    * 1.0 | 29st Dec, 2020 | sujata.chaudhari@weare4c.com 
    * 1.1 | 6th  Jan, 2021 | sujata.chaudhari@weare4c.com
    * =================================================================================================================
    */
    @isTest
    public class UpdateUserTest{
        @testSetup static void testSetupData(){
            Profile p = TestDataUtility.getProfile('Account Manager');
            
            List<User> users = TestDataUtility.createUsers(p.Id, 5);
            insert users;
        }
        @isTest 
        public static void testList(){
            List<User> users = [SELECT Id, Name, Segment__c, Vertical__c, Entity__c, No_of_Account_or_Opportunities_Owned__c 
                                FROM User where isActive=true AND CreatedDate >= TODAY AND Profile.Name = 'Account Manager' LIMIT 5];
            
            users[0].Id = users[1].Id;
            Set<Id> userIds = new Set<Id>();
            for(User usr : users){
                userIds.add(usr.Id);
            } 
            UpdateUser userupdate = new UpdateUser(userIds);
            Test.startTest();
            System.enqueueJob(userupdate);
            
            Test.stopTest();
            List<User> usr = [SELECT Id, Name, Segment__c, Vertical__c, Entity__c, No_of_Account_or_Opportunities_Owned__c 
                            FROM User where isActive=true AND CreatedDate >= TODAY AND Profile.Name = 'Account Manager' LIMIT 5];
            System.assertEquals(5, usr.Size(), 'Update user count');
        }
        @isTest 
        public static void testListNegative(){
            List<User> users = [SELECT Id, Name, Segment__c, Vertical__c, Entity__c, No_of_Account_or_Opportunities_Owned__c 
                                FROM User where isActive=true AND CreatedDate >= TODAY AND Profile.Name = 'Account Manager' LIMIT 5];
            
            users[0].Id = users[1].Id;
            Set<Id> userIds = new Set<Id>();
            UpdateUser userupdate = new UpdateUser(userIds);
            Test.startTest();
            try{
                System.enqueueJob(userupdate);
            }catch(DmlException e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('User Set is Empty') ? true : false;
                System.assertEquals(expectedExceptionThrown, true, 'Exception Thrown');
            } 
            Test.stopTest();
        }
    }