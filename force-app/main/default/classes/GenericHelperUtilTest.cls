/**
    * @Class Name: GenericHelperUtilTest
    * @Description: Used for GenericHelperUtil class as a test class.
    * ================================================================================================================
    * Version | Date | Author 
    * -----------------------------------------------------------------------------------------------------------------
    * 1.0 | 29st Dec, 2020 | sujata.chaudhari@weare4c.com 
    * 2.0 | 6th Jan, 2021 | sujata.chaudhari@weare4c.com 
    * =================================================================================================================
    */
    @isTest
    public class GenericHelperUtilTest{
        /*
        * Positive:
        *          testGenericPositive
        * Bulk:
        *      testGenericBulk
        */
        
        @isTest
        public static void testGenericPositive(){
            testRunnerInsert(1);
        }
        
        @isTest
        public static void testGenericBulk(){
            testRunnerInsert(10);
        }
        
        @testSetup static void testSetup(){
            Profile p = TestDataUtility.getProfile('Account Manager');
            List<User> userToUpdate = [SELECT Id, isActive FROM User where isActive=true AND Profile.Name = 'Account Manager'];
            for (User userObj : userToUpdate) {
                userObj.isActive = false;
            }
            update userToUpdate;

            List<User> userst = TestDataUtility.createUsers(p.Id, 1);
            insert userst;
        }

        public static void testRunnerInsert(Integer numberofRecords){
            
            List<User> users = [SELECT Id, Name, Segment__c, Vertical__c, Entity__c, No_of_Account_or_Opportunities_Owned__c 
                                FROM User where isActive=true AND Profile.Name = 'Account Manager'];
            
            Set<Id> userIds = new Set<Id>();
            for(User usr : users){
                userIds.add(usr.Id);
            }
            
            Test.startTest();
            Map<Id, Integer> userRecordCount0 = GenericHelperUtil.getTotalCount(userIds);
            Integer beforeInsertOldUserCount = (Integer)users[0].No_of_Account_or_Opportunities_Owned__c;
            System.debug('beforeInsertOldUserCount' +beforeInsertOldUserCount);
            
            List<Account> acc = TestDataUtility.createAccountList(numberofRecords);
            for(Account ac : acc){
                ac.OwnerId = users[0].Id;
            }
            insert acc;
            
            List<Opportunity> opt = TestDataUtility.createOpportunityList(acc[0].Id, numberofRecords);
            for(Opportunity opp : opt){
                opp.OwnerId = users[0].Id;
            }
            insert opt;
            
            List<AccountTeamMember> atml = TestDataUtility.createAccountTeamMember(users[0].Id, acc[0].Id, numberofRecords);
            for (Integer i = 0; i < atml.size(); i++) {
                atml[i].UserId = users[0].Id;
                atml[i].AccountId = acc[i].Id;
            }
            insert atml;
            
            List<OpportunityTeamMember> otml = TestDataUtility.createOpportunityTeamMember(users[0].Id, opt[0].Id, numberofRecords);
            for (Integer i = 0; i < otml.size(); i++) {
                otml[i].UserId = users[0].Id;
                otml[i].OpportunityId = opt[i].Id;
            }
            insert otml;
            
                        
            Map<Id, Integer> userRecordCount1 = GenericHelperUtil.getTotalCount(userIds);
            Integer afterInsertOldUserCount = userRecordCount1.get(users[0].Id);
            System.debug('afterInsertOldUserCount' +afterInsertOldUserCount);
            Test.stopTest();

            //Assertion For Insert
            System.assertEquals(afterInsertOldUserCount, beforeInsertOldUserCount +(numberofRecords * 4), 'There is some issue in updating count on Old Owner User record');
        }
    }