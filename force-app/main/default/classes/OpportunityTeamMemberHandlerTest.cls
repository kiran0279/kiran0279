/**
    * @Class Name: OpportunityTeamMemberHandlerTest
    * @Description: Used for OpportunityTeamMemberHandler and OpportunityTeamMemberTrigger as a test Class.
    * ================================================================================================================
    * Version | Date | Author 
    * -----------------------------------------------------------------------------------------------------------------
    * 1.0 | 29st Dec, 2020 | sujata.chaudhari@weare4c.com 
    * =================================================================================================================
    */
    @isTest
    public class OpportunityTeamMemberHandlerTest{
        /*
        * Positive:
        *          testInsertOtmOwnerPositive
        *          testDeleteOtmOwnerPositive
        * Bulk:
        *      testInsertOtmOwnerBulk
        *      testDeleteOtmOwnerBulk
        */

        @isTest
        public static void testInsertOtmOwnerPositive(){
            testRunnerInsert(1);
        }

        @isTest
        public static void testInsertOtmOwnerBulk(){
            testRunnerInsert(200);
        }

        @isTest
        public static void testDeleteOtmOwnerPositive(){
            testRunnerDelete(1);
        }

        @isTest
        public static void testDeleteOtmOwnerBulk(){
            testRunnerDelete(200);
        }

        @testSetup static void testSetup(){
            Profile p = TestDataUtility.getProfile('Account Manager');
            
            List<User> users = TestDataUtility.createUsers(p.Id, 2);
            insert users;
            
            List<Account> accList = TestDataUtility.createAccountList(2);
            accList[0].OwnerId = users[0].Id;
            accList[1].OwnerId = users[1].Id;
            insert accList;
            
            List<AccountTeamMember> atm = TestDataUtility.createAccountTeamMember(users[0].Id, accList[0].Id, 1);
            insert atm;
            
            List<Opportunity> oppList = TestDataUtility.createOpportunityList(accList[0].Id,200);
            for(Opportunity opp : oppList){
                opp.OwnerId = users[0].Id;
                opp.AccountId = accList[0].Id;
            }
            insert oppList;
            
            List<OpportunityTeamMember> otm = TestDataUtility.createOpportunityTeamMember(users[1].Id, oppList[0].Id,1);  
            insert otm;
        }
        
        public static void testRunnerInsert(Integer numberofRecords){
            system.debug('numberofRecords>>>'+numberofRecords);
            List<User> users = [SELECT Id, Name, Segment__c, Vertical__c, Entity__c, No_of_Account_or_Opportunities_Owned__c 
                                FROM User where isActive=true AND CreatedDate >= TODAY AND Profile.Name = 'Account Manager' LIMIT 5];
            
            Set<Id> userIds = new Set<Id>();
            for(User usr : users){
                userIds.add(usr.Id);
            }
            
            Test.startTest();
            Integer beforeInsertOldUserCount = (Integer)users[0].No_of_Account_or_Opportunities_Owned__c;
            system.debug('beforeInsertOldUserCount>>>>'+beforeInsertOldUserCount);

            List<Opportunity> testOpportunity = [SELECT Id, OwnerId FROM Opportunity WHERE OwnerId =: users[0].Id LIMIT :numberofRecords];
            system.debug('testOpportunity>>>'+testOpportunity.size());
            List<OpportunityTeamMember> otmList = TestDataUtility.createOpportunityTeamMember(users[0].Id, testOpportunity[0].Id, numberofRecords);
            system.debug('otmList>>>>'+otmList.size());
            Integer i=0;
            for(OpportunityTeamMember otm : otmList){
                otm.TeamMemberRole = 'Account Manager';
                otm.OpportunityId = testOpportunity[i].Id; 
                i++;
            }

            insert otmList;

            Map<Id, Integer> userRecordCount1 = GenericHelperUtil.getTotalCount(userIds);
            system.debug('userRecordCount1>>>'+userRecordCount1);
            Integer afterInsertOldUserCount = userRecordCount1.get(users[0].Id);
            Test.stopTest();

            //Assertion For Insert
            System.assertEquals(afterInsertOldUserCount, beforeInsertOldUserCount +numberofRecords, 'There is some issue in updating count on Old Owner User record(In OpportunityTeamMember Update)');
            system.debug('afterInsertOldUserCount>>>'+afterInsertOldUserCount+'beforeInsertOldUserCount>>>'+beforeInsertOldUserCount+numberofRecords);

        }
        
        public static void testRunnerDelete(Integer numberofRecords){
            List<User> users = [SELECT Id, Name, Segment__c, Vertical__c, Entity__c, No_of_Account_or_Opportunities_Owned__c 
                                FROM User where isActive=true AND CreatedDate >= TODAY AND Profile.Name = 'Account Manager' LIMIT 5];
            
            Set<Id> userIds = new Set<Id>();
            for(User usr : users){
                userIds.add(usr.Id);
            }
            
            List<Opportunity> testOpportunity = [SELECT Id, OwnerId FROM Opportunity WHERE OwnerId =: users[0].Id LIMIT :numberofRecords];
            List<OpportunityTeamMember> otmList = TestDataUtility.createOpportunityTeamMember(users[0].Id, testOpportunity[0].Id, numberofRecords);
            Integer i=0;
            for(OpportunityTeamMember otm : otmList){
                otm.TeamMemberRole = 'Account Manager';
                otm.OpportunityId = testOpportunity[i].Id; 
                i++;
            }
            insert otmList;
            Test.startTest();
            List<OpportunityTeamMember> testOtm = [SELECT Id FROM OpportunityTeamMember WHERE UserId =: users[0].Id];
            
            Map<Id, Integer> userRecordCount1 = GenericHelperUtil.getTotalCount(userIds);
            Integer afterInsertOldUserCount = userRecordCount1.get(users[0].Id);

            delete testOtm;

            Map<Id, Integer> userRecordCount2 = GenericHelperUtil.getTotalCount(userIds);
            Integer afterDeleteOldUserCount = userRecordCount2.get(users[0].Id);
            Test.stopTest();

            //Assertion For Delete
            System.assertEquals(afterDeleteOldUserCount, afterInsertOldUserCount - numberofRecords, 'There is some issue in updating count on Old Owner User record(In OpportunityTeamMember Delete)');
        }
    }