/**
    * @Class Name: AccountTeamMemberHandlerTest
    * @Description: Used for AccountTeamMemberHandler and AccountTeamMemberTrigger as a test Class.
    * ================================================================================================================
    * Version | Date | Author 
    * -----------------------------------------------------------------------------------------------------------------
    * 1.0 | 29th Dec, 2020 | sujata.chaudhari@weare4c.com 
    * =================================================================================================================
    */
    @isTest
    public class AccountTeamMemberHandlerTest{
        /*
        * Positive:
        *          testInsertAtmOwnerPositive
        *          testDeleteAtmOwnerPositive
        * Bulk:
        *      testInsertAtmOwnerBulk
        *      testDeleteAtmOwnerBulk
        */
        @isTest
        public static void testInsertAtmOwnerPositive(){
            testRunnerInsert(1); 
        }
        
        @isTest
        public static void testCreditManagerScenario(){
            testForCreditManager(1); 
        }
        
        @isTest
        public static void testInsertAtmOwnerBulk(){
            testRunnerInsert(10); 
        }
        
        @isTest
        public static void testDeleteAtmOwnerPositive(){
            testRunnerDelete(1);
        }
        
        @isTest
        public static void testDeleteForCreditManager(){
            testCreditManagerDelete(1);
        }
        
        @isTest
        public static void testDeleteAtmOwnerBulk(){
            testRunnerDelete(10);
        }
        
        @testSetup static void testData(){
            Profile p = TestDataUtility.getProfile('Account Manager');
            
            List<User> users = TestDataUtility.createUsers(p.Id, 2);
            insert users;
            
            Profile creditManagerProfile = TestDataUtility.getProfile('Credit Manager');
            
            List<User> creditManagerUser = TestDataUtility.createUsers(creditManagerProfile.Id, 1);
            insert creditManagerUser;
            
            List<Account> accList = TestDataUtility.createAccountList(10);
            for(Account acc : accList){
                acc.OwnerId = users[0].Id;
                acc.Name = 'testBulkacc';
            }
            insert accList;
            
            Opportunity opp = TestDataUtility.createOpportunity('testOpp1', accList[0].Id);
            opp.OwnerId = users[0].Id;
            insert opp;
            
            List<OpportunityTeamMember> otm = TestDataUtility.createOpportunityTeamMember(users[0].Id, opp.Id, 1);  
            insert otm;
        }
        
        public static void testRunnerInsert(Integer numberofRecords){
            List<User> users = [SELECT Id, Name, Segment__c, Vertical__c, Entity__c, No_of_Account_or_Opportunities_Owned__c 
                                FROM User where isActive=true AND CreatedDate >= TODAY AND Profile.Name = 'Account Manager' LIMIT 5];
            
            Set<Id> userIds = new Set<Id>();
            for(User usr : users){
                userIds.add(usr.Id);
            }
            
            Test.startTest();
            Integer beforeInsertOldUserCount = (Integer)users[0].No_of_Account_or_Opportunities_Owned__c;
            
            List<Account> testAccount = [SELECT Id FROM Account WHERE OwnerId =: users[0].Id LIMIT :numberofRecords];
            List<AccountTeamMember> atmList = TestDataUtility.createAccountTeamMember(users[0].Id, testAccount[0].Id, numberofRecords);
            Integer i=0;
            for(AccountTeamMember atm : atmList){
                atm.TeamMemberRole = 'Account Manager';
                atm.AccountId =  testAccount[i].Id; 
                i++;
            }
            
            insert atmList;
            
            Map<Id, Integer> userRecordCount1 = GenericHelperUtil.getTotalCount(userIds);
            Integer afterInsertOldUserCount = userRecordCount1.get(users[0].Id);
            Test.stopTest();
            
            //Assertion For Insert
            System.assertEquals(afterInsertOldUserCount, beforeInsertOldUserCount +numberofRecords, 'There is some issue in updating count on Old Owner User record(In AccountTeamMember Update)');
        }
        
        //==========New Logic START ==================
        
        public static void testForCreditManager(Integer numberofRecords){
            Profile creditManagerProfile = TestDataUtility.getProfile('Credit Manager');
            
            List<User> creditManagerUser = TestDataUtility.createUsers(creditManagerProfile.Id, 1);
            insert creditManagerUser;
            
            System.runAs(creditManagerUser[0]) {
                
                List<User> users = [SELECT Id, Name, Segment__c, Vertical__c, Entity__c, No_of_Account_or_Opportunities_Owned__c 
                                FROM User where isActive=true AND CreatedDate >= TODAY AND Profile.Name = 'Account Manager' LIMIT 5];
            
                Set<Id> userIds = new Set<Id>();
                for(User usr : users){
                    userIds.add(usr.Id);
                }
                
                Test.startTest();
               
                List<Account> testAccount = [SELECT Id FROM Account WHERE OwnerId =: users[0].Id LIMIT :numberofRecords];
                List<AccountTeamMember> atmList = TestDataUtility.createAccountTeamMember(users[0].Id, testAccount[0].Id, numberofRecords);
                Integer i=0;
                for(AccountTeamMember atm : atmList){
                    atm.TeamMemberRole = 'Account Manager';
                    atm.AccountId =  testAccount[i].Id; 
                    i++;
                }
                
                try{
                    insert atmList;
                }
                catch(Exception e) {
                    System.assert(e.getMessage().contains('Please Select "Credit Manager" User.'));
                }
                
                
                //Database.SaveResult result = Database.insert(atmList, false);
                //System.assertEquals('Please Select "Credit Manager" User.',result.getErrors()[0].getMessage());
    
                
                Test.stopTest();
                  
            }
        }
        
        
        //========== New Logic END ==================
        
        
        public static void testRunnerDelete(Integer numberofRecords){
            List<User> users = [SELECT Id, Name, Segment__c, Vertical__c, Entity__c, No_of_Account_or_Opportunities_Owned__c 
                                FROM User where isActive=true AND CreatedDate >= TODAY AND Profile.Name = 'Account Manager' LIMIT 5];
            
            Set<Id> userIds = new Set<Id>();
            for(User usr : users){
                userIds.add(usr.Id);
            }
            
            List<Account> testAccount = [SELECT Id FROM Account WHERE OwnerId =: users[0].Id LIMIT :numberofRecords];
            system.assertNotEquals(0, testAccount.size(), 'Incorrect number of accounts found assigned to the user');
            List<AccountTeamMember> atmList = TestDataUtility.createAccountTeamMember(users[0].Id, testAccount[0].Id, numberofRecords);
            Integer i=0;
            for(AccountTeamMember atm : atmList){
                atm.TeamMemberRole = 'Account Manager';
                atm.AccountId =  testAccount[i].Id; 
                i++;
            }
            
            insert atmList;
            
            Test.startTest();
            List<AccountTeamMember> testAtm = [SELECT Id FROM AccountTeamMember WHERE UserId =: users[0].Id];
            Map<Id, Integer> userRecordCount1 = GenericHelperUtil.getTotalCount(userIds);
            Integer afterInsertOldUserCount = userRecordCount1.get(users[0].Id);
            
            Delete testAtm;
            
            Map<Id, Integer> userRecordCount2 = GenericHelperUtil.getTotalCount(userIds);
            Integer afterDeleteOldUserCount = userRecordCount2.get(users[0].Id);
            Test.stopTest();
            
            //Assertion For Delete
            System.assertEquals(afterDeleteOldUserCount, afterInsertOldUserCount - numberofRecords, 'There is some issue in updating count on Old Owner User record(In AccountTeamMember Delete)');
        }
        
        //========== New Logic START ==================
        
        public static void testCreditManagerDelete(Integer numberofRecords){
            
            Profile creditManagerProfile = TestDataUtility.getProfile('Credit Manager');
            
            List<User> creditManagerUser = TestDataUtility.createUsers(creditManagerProfile.Id, 1);
            insert creditManagerUser;
            
            List<AccountTeamMember> aTMDelete = [select Id, TeamMemberRole from accountteammember where TeamMemberRole = 'Account Manager'];
                
            System.runAs(creditManagerUser[0]) {
            
                List<AccountTeamMember> testAtm = [select Id, TeamMemberRole from accountteammember where TeamMemberRole = 'Account Manager'];
                //Delete testAtm;
                
                //Delete aTMDelete;
                
                AccountTeamMemberTriggerHandler.showErrorOnRemoveMember(aTMDelete);
                AccountTeamMemberTriggerHandler.showErrorOnRemoveMember(testAtm);
                             
               }
        }
}