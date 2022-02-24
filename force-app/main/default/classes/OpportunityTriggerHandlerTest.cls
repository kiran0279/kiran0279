/**
    * @Class Name: OpportunityTriggerHandlerTest
    * @Description: Used for OpportunityTriggerHandler and OpportunityTrigger as a test Class.
    * ================================================================================================================
    * Version | Date | Author 
    * -----------------------------------------------------------------------------------------------------------------
    * 1.0 | 29st Dec, 2020 | sujata.chaudhari@weare4c.com 
    * =================================================================================================================
    */
    @isTest
    public class OpportunityTriggerHandlerTest{
        /*
        * Positive:
        *          testcreateOpportunityOwnerUpdatePositive
        *          testcreateOpportunityOwnerDeletePositive
        * Bulk:
        *      testcreateOpportunityOwnerUpdateBulk
        *      testcreateOpportunityOwnerDeleteBulk
        */
        
        @isTest
        public static void testcreateOpportunityOwnerUpdatePositive(){
            testRunnerUpdate(1);
        }

        @isTest
        public static void testcreateOpportunityOwnerUpdateBulk(){
            testRunnerUpdate(200);
        }
        
        @isTest
        public static void testcreateOpportunityOwnerDeletePositive(){
            testRunnerDelete(1);
        }
        
        @isTest
        public static void testcreateOpportunityOwnerDeleteBulk(){
            testRunnerDelete(200);
        }
        
        @testSetup static void testSetup(){
            Profile p = TestDataUtility.getProfile('Account Manager');
            
            List<User> users = TestDataUtility.createUsers(p.Id, 2);
            insert users;
            
            Account acc = TestDataUtility.createAccount('test');
            insert acc;
            
            List<AccountTeamMember> atm1 = TestDataUtility.createAccountTeamMember(users[0].Id, acc.Id, 1);
            insert atm1;
            
            Opportunity opp = TestDataUtility.createOpportunity('test', acc.Id);
            insert opp;
            
            List<Opportunity> bulkOpp = TestDataUtility.createOpportunityList(acc.Id,200);
            for(Opportunity getOpp : bulkOpp){
                getOpp.OwnerId = users[0].Id; 
            }
            insert bulkOpp;
            
            List<OpportunityTeamMember> otm = TestDataUtility.createOpportunityTeamMember(users[0].Id, opp.Id, 1); 
            insert otm;
        }

        public static void testRunnerUpdate(Integer numberofRecords){
            List<User> users = [SELECT Id, Name, Segment__c, Vertical__c, Entity__c, No_of_Account_or_Opportunities_Owned__c 
                                FROM User where isActive=true AND CreatedDate >= TODAY AND Profile.Name = 'Account Manager' LIMIT 2];
            
            Set<Id> userIds = new Set<Id>();
            for(User usr : users){
                userIds.add(usr.Id);
            }
            
            Test.startTest();
            List<Opportunity> testOpportunity = [SELECT Id FROM Opportunity WHERE OwnerId =: users[0].Id LIMIT :numberofRecords];
            for(Opportunity opp : testOpportunity){
                opp.OwnerId = users[1].Id; 
            }

            Integer beforeUpdateOldUserCount = (Integer)users[0].No_of_Account_or_Opportunities_Owned__c;
            Integer beforeUpdateNewUserCount = (Integer)users[1].No_of_Account_or_Opportunities_Owned__c;
            
            update testOpportunity;
            
            Map<Id, Integer> userRecordCount1 = GenericHelperUtil.getTotalCount(userIds);
            Integer afterUpdateOldUserCount = userRecordCount1.get(users[0].Id);
            Integer afterUpdateNewUserCount = userRecordCount1.get(users[1].Id);     
            Test.stopTest();

            //Assertion for Update
            System.assertEquals(afterUpdateOldUserCount, beforeUpdateOldUserCount - numberofRecords, 'There is some issue in updating count on Old Owner User record(In Opportunity Update)');
            System.assertEquals(afterUpdateNewUserCount, beforeUpdateNewUserCount + numberofRecords, 'There is some issue in updating count on new Owner User record(In Opportunity Update)');  
        }
        
        public static void testRunnerDelete(Integer numberofRecords){
            List<User> users = [SELECT Id, Name, Segment__c, Vertical__c, Entity__c, No_of_Account_or_Opportunities_Owned__c 
                                FROM User where isActive=true AND CreatedDate >= TODAY AND Profile.Name = 'Account Manager' LIMIT 2];
            Set<Id> userIds = new Set<Id>();
            for(User usr : users){
                userIds.add(usr.Id);
            }   
            
            Test.startTest();
            List<Opportunity> testOpportunity = [SELECT Id FROM Opportunity WHERE OwnerId =: users[0].Id LIMIT :numberofRecords];

            Integer afterUpdateOldUserCount = (Integer)users[0].No_of_Account_or_Opportunities_Owned__c;
            Integer afterUpdateNewUserCount = (Integer)users[1].No_of_Account_or_Opportunities_Owned__c;
            
            delete testOpportunity;
            
            Map<Id, Integer> userRecordCount2 = GenericHelperUtil.getTotalCount(userIds);
            Integer afterDeleteOldUserCount = userRecordCount2.get(users[0].Id);
            Integer afterDeleteNewUserCount = userRecordCount2.get(users[1].Id);   
            Test.stopTest();

            //Assertion For Delete
            System.assertEquals(afterDeleteOldUserCount, afterUpdateOldUserCount - numberofRecords, 'There is some issue in updating count on Old Owner User record(In Opportunity Delete)');
            System.assertEquals(afterDeleteNewUserCount, afterUpdateNewUserCount , 'There is some issue in updating count on new Owner User record(In Opportunity Delete)');   
        }
    }