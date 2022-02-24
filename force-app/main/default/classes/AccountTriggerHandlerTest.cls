/**
    * @Class Name: AccountTriggerHandlerTest
    * @Description: Used for AccountTriggerHandler and AccountTrigger as a test Class.
    * ================================================================================================================
    * Version | Date | Author 
    * -----------------------------------------------------------------------------------------------------------------
    * 1.0 | 29st Dec, 2020 | sujata.chaudhari@weare4c.com
    * 2.0 | 6th Jan, 2021 | sujata.chaudhari@weare4c.com
    * =================================================================================================================
    */
    @isTest
    public class AccountTriggerHandlerTest{
        /*
        * Positive:
        *          testcreateAccountOwnerUpdatePositive
        *          testcreateAccountOwnerDeletePositive
        * Bulk:
        *      testcreateAccountOwnerUpdateBulk
        *      testcreateAccountOwnerDeleteBulk
        */
        
        @isTest
        public static void testcreateAccountOwnerUpdatePositive(){
            testRunnerUpdate(1);
        }
        
        @isTest
        public static void testcreateAccountOwnerUpdateBulk(){
            testRunnerUpdate(10); 
        }
        
        @isTest
        public static void testcreateAccountOwnerDeletePositive(){
            testRunnerDelete(1);
        }
        
        @isTest
        public static void testcreateAccountOwnerDeleteBulk(){
            testRunnerDelete(10);
        }
        
        @testSetup static void testSetup(){
            Profile p = TestDataUtility.getProfile('Account Manager');
            
            List<User> users = TestDataUtility.createUsers(p.Id, 2);
            insert users;

            List<Account> accList = TestDataUtility.createAccountList(2);
            accList[0].OwnerId = users[0].Id;
            accList[1].OwnerId = users[1].Id;
            insert accList;

            List<Account> bulkAcc = TestDataUtility.createAccountList(10);
            for(Account ac : bulkAcc){
                ac.OwnerId = users[0].Id;
                ac.Name = 'testBulkacc';
            }
            insert bulkAcc;
            
            List<AccountTeamMember> atm1 = TestDataUtility.createAccountTeamMember(users[0].Id, accList[1].Id, 1);
            insert atm1;
            
            List<Opportunity> opp = TestDataUtility.createOpportunityList(accList[1].Id, 2);
            opp[1].OwnerId = users[0].Id;
            opp[0].OwnerId = users[1].Id;
            opp[0].AccountId = accList[0].Id;
            insert opp;
            
            List<OpportunityTeamMember> otm = TestDataUtility.createOpportunityTeamMember(users[1].Id, opp[1].Id, 2); 
            otm[1].UserId = users[0].Id;
            otm[1].OpportunityId = opp[0].Id;
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
            List<Account> testAccounts = [SELECT Id FROM Account WHERE OwnerId =: users[0].Id LIMIT :numberofRecords];
            for(Account ac : testAccounts){
                ac.OwnerId = users[1].Id; 
            }
            
            Integer beforeUpdateOldUserCount = (Integer)users[0].No_of_Account_or_Opportunities_Owned__c;
            Integer beforeUpdateNewUserCount = (Integer)users[1].No_of_Account_or_Opportunities_Owned__c;
            
            update testAccounts;
            
            Map<Id, Integer> userRecordCount1 = GenericHelperUtil.getTotalCount(userIds);
            Integer afterUpdateOldUserCount = userRecordCount1.get(users[0].Id);
            Integer afterUpdateNewUserCount = userRecordCount1.get(users[1].Id);
            Test.stopTest();

            //Assertion for Update
            System.assertEquals(afterUpdateOldUserCount, beforeUpdateOldUserCount -numberofRecords, 'There is some issue in updating count on Old Owner User record(In Account Update)');
            System.assertEquals(afterUpdateNewUserCount, beforeUpdateNewUserCount +numberofRecords, 'There is some issue in updating count on new Owner User record(In Account Update)');
        }

        public static void testRunnerDelete(Integer numberofRecords){
            List<User> users = [SELECT Id, Name, Segment__c, Vertical__c, Entity__c, No_of_Account_or_Opportunities_Owned__c 
                                FROM User where isActive=true AND CreatedDate >= TODAY AND Profile.Name = 'Account Manager'  LIMIT 2];
            
            Set<Id> userIds = new Set<Id>();
            for(User usr : users){
                userIds.add(usr.Id);
            }

            Test.startTest();
            List<Account> testAccount = [SELECT Id FROM Account WHERE OwnerId =: users[0].Id AND Name = 'testBulkacc' LIMIT :numberofRecords];
        
            Integer beforeDeleteOldUserCount = (Integer)users[0].No_of_Account_or_Opportunities_Owned__c;
            Integer beforeDeleteNewUserCount = (Integer)users[1].No_of_Account_or_Opportunities_Owned__c;
            
            delete testAccount;
            
            Map<Id, Integer> userRecordCount2 = GenericHelperUtil.getTotalCount(userIds);
            Integer afterDeleteOldUserCount = userRecordCount2.get(users[0].Id);
            Integer afterDeleteNewUserCount = userRecordCount2.get(users[1].Id);
            Test.stopTest();

            //Assertion For Delete
            System.assertEquals(afterDeleteOldUserCount, beforeDeleteOldUserCount -numberofRecords, 'There is some issue in updating count on Old Owner User record(In Account Delete)');
            System.assertEquals(afterDeleteNewUserCount, beforeDeleteNewUserCount, 'There is some issue in updating count on new Owner User record(In Account Delete)'); 
        }
    }