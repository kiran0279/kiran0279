/**
* @Class Name: AccountOpportunityTriggerTest
* @Description: Used for Account, Opportunity, Account Team Member and Opportunity Team Member as a test Class.
* ================================================================================================================
* Version | Date | Author 
* -----------------------------------------------------------------------------------------------------------------
* 1.0 | 10th March, 2021 | sujata.chaudhari@weare4c.com .
* 2.0 | 1st Jan, 2022|
* =================================================================================================================
*/
@isTest
public without sharing class AccountOpportunityTriggerTest {
    public static Id accountManagerProfileId = [Select Id From Profile Where Name = 'Account Manager' Limit 1].Id;
    public static Id BDMProfileId = [Select Id From Profile Where Name = 'Business Development Manager' Limit 1].Id;
    public static Id systemAdministratorProfileId = [Select Id From Profile Where Name = 'System Administrator' Limit 1].Id;
    public static User bdmUserRecord;
    public static List<User> accountManagerUserRecords;
    public static list<Database.LeadConvert> leadConverts;
    public static List<Account> accList;
    public static List<Opportunity> oppList;
    public static List<String> errorMessages;

    @isTest
    public static void happyPathCreateBulk() {
        User userRecord = TestDataUtility.createUser('user.name@aramex.com', '123432', systemAdministratorProfileId);
        test.startTest();
        Integer bulkFactor = 1;
        happyPathRunnerCreate(userRecord, bulkFactor);
        test.stopTest();
        
        Set<Id> aMUserIdSet = new Set<Id>();
        for (User u : accountManagerUserRecords) {
            aMUserIdSet.add(u.Id);
        }

        List<User> usersWithCount = [Select Id,No_of_Account_or_Opportunities_Owned__c from User Where Id IN :aMUserIdSet AND isActive = true];

        Integer total = 0;

        for (User u : usersWithCount) {
            total += (Integer)u.No_of_Account_or_Opportunities_Owned__c;
        }

        system.assertEquals(bulkFactor*4, total);
    }

    @isTest
    public static void happyPathUpdate() {
        User userRecord = TestDataUtility.createUser('user.name@aramex.com', '123432', systemAdministratorProfileId);
        test.startTest();
        Integer bulkFactor = 1;
        happyPathRunnerUpdate(userRecord, bulkFactor);
        test.stopTest();

        /*
        * Asserts for update
        */
        List<User> testUser = [Select Id, No_of_Account_or_Opportunities_Owned__c From User Where Id IN :accountManagerUserRecords];
        //system.assertEquals(0, testUser[0].No_of_Account_or_Opportunities_Owned__c, 'Incorrect first account manager count [' + testUser[0].No_of_Account_or_Opportunities_Owned__c + ']');
        system.assertEquals(bulkFactor+1, testUser[1].No_of_Account_or_Opportunities_Owned__c, 'Incorrect Second account manager count [' + testUser[0].No_of_Account_or_Opportunities_Owned__c + ']');
        List<User> userRecordsWithCountee = [Select Id, No_of_Account_or_Opportunities_Owned__c From User where isActive = true and Profile.Name = 'Account Manager' and No_of_Account_or_Opportunities_Owned__c != 0];
        system.assertEquals(bulkFactor+1, userRecordsWithCountee[0].No_of_Account_or_Opportunities_Owned__c, 'Incorrect count on the account manager records. Actual count [' + userRecordsWithCountee[0].No_of_Account_or_Opportunities_Owned__c + ']');
    }

    @isTest
    public static void happyPathDelete() {
        User userRecord = TestDataUtility.createUser('user.name@aramex.com', '123432', systemAdministratorProfileId);
        test.startTest();
        Integer bulkFactor = 1;
        happyPathRunnerDelete(userRecord, bulkFactor);
        test.stopTest();

        /*
        * Asserts for delete
        */
        List<User> testUser = [Select Id, No_of_Account_or_Opportunities_Owned__c From User Where Id IN :accountManagerUserRecords];
        system.assertEquals(0, testUser[0].No_of_Account_or_Opportunities_Owned__c, 'Incorrect first account manager count [' + testUser[0].No_of_Account_or_Opportunities_Owned__c + ']');
        List<User> userRecordsWithCount = [Select Id, No_of_Account_or_Opportunities_Owned__c From User where isActive = true and Profile.Name = 'Account Manager' and No_of_Account_or_Opportunities_Owned__c = 0];
    }

    /*
     * Runner methods
     */
    public static void happyPathRunnerCreate(User userToRunAs, Integer bulkFactor) {
        setupUsers(bulkFactor);
        createAndConvertLeadRecords(userToRunAs, bulkFactor);
    }

    public static void happyPathRunnerUpdate(User userToRunAs, Integer bulkFactor) {
        setupUsers(bulkFactor);
        createAndConvertLeadRecords(userToRunAs, bulkFactor);

        /*
        * Updating the account managers on the account
        */
            
        updateAccountManagerRecords(userToRunAs, bulkFactor);

            
        /*
        * Account manager update checks
        */
        system.assertEquals(bulkFactor, [Select Id From Account Where OwnerId = :accountManagerUserRecords[1].Id].size(), 'Account OwnerId size is not increased');
        system.assertEquals(bulkFactor - 1, [Select Id From Account Where OwnerId = :accountManagerUserRecords[0].Id].size(), 'Account OwnerId size is not decreased');

        system.assertEquals(bulkFactor, [Select Id From Opportunity Where OwnerId = :accountManagerUserRecords[1].Id].size(), 'Opportunity OwnerId size is not increased');
        system.assertEquals(bulkFactor - 1, [Select Id From Opportunity Where OwnerId = :accountManagerUserRecords[0].Id].size(), 'Opportunity OwnerId size is not decreased');
    }

    public static void happyPathRunnerDelete(User userToRunAs, Integer bulkFactor) {
        setupUsers(bulkFactor);
        createAndConvertLeadRecords(userToRunAs, bulkFactor);

        deleteAccountRecords(userToRunAs, bulkFactor);

        /*
        * Asserts for delete
        */    

        //Delete Account Member
        system.assertEquals(0, [Select Id From AccountTeamMember Where UserId = :accountManagerUserRecords[0].Id].size(), 'Failed to delete AccountTeamMember record');

        //Delete Opportunity Member
        system.assertEquals(0, [Select Id From OpportunityTeamMember Where OpportunityId =:oppList[0].Id AND UserId = :accountManagerUserRecords[0].Id].size(), 'Failed to delete OpportunityTeamMember record');

        //Delete Opportunity
        system.assertEquals(0, [Select Id From Opportunity Where OwnerId = :accountManagerUserRecords[1].Id].size(), 'Failed to delete Opportunity record');

        //Deleting the accounts
        system.assertEquals(0, [Select Id From Account Where OwnerId = :accountManagerUserRecords[1].Id].size(), 'Failed to delete Account record');
    }


    @TestSetup static void testData(){
        Pricebook2 pricebook = TestDataUtility.createPricebook2('test'); 
        insert pricebook;
    }
    /*
     * Helper methods
     */
    public static void setupUsers(Integer bulkFactor) {
        
        /*
        * create BDM User
        */
        bdmUserRecord = TestDataUtility.createUser('bd.one@aramex.com', 'BD123432', BDMProfileId);
        insert bdmUserRecord;

        /*
         * create Account Managers
         */
        List<User> existingAccountManagersToDeactivate = new List<User>();
        for(User userRecord : [Select Id From User Where Profile.Name = 'Account Manager']) {
            userRecord.isActive = false;
            existingAccountManagersToDeactivate.add(userRecord);
        }
        update existingAccountManagersToDeactivate;

        accountManagerUserRecords = TestDataUtility.createUsers(accountManagerProfileId, bulkFactor *2);
        insert accountManagerUserRecords;
        system.assertEquals(accountManagerUserRecords.size(), [Select Id From User Where Profile.Name = 'Account Manager' and isActive = true].size());
    }

    public static void createAndConvertLeadRecords(User userToRunAs, Integer bulkFactor) {
        /*
        * Create the lead records
        */
        
        System.runAs(userToRunAs) {

            //Pricebook2 pricebook = [SELECT Id FROM Pricebook2];
            List<Lead> leadRecords = TestDataUtility.createLeads(bulkFactor);
            insert leadRecords;

            /*
             * Take the lead off the queue before conversion
             */
            for(Lead leadRecord : leadRecords) {
                leadRecord.OwnerId = bdmUserRecord.Id;
            }
            update leadRecords;

            /*
             * Convert the lead records
             */
            leadConverts = new list<Database.LeadConvert>();
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            for(Integer i = 0; i < leadRecords.size(); i++) {
                Lead leadRecord = leadRecords[i];
                Database.LeadConvert lc = new database.LeadConvert();
                lc.setLeadId(leadRecord.id);
                lc.setDoNotCreateOpportunity(false);
                lc.setConvertedStatus(convertStatus.MasterLabel);
                leadConverts.add(lc);
            }
            //test.startTest();
            errorMessages = new List<String>();
            if(!leadConverts.isEmpty()){
                for(Integer i = 0; i <= leadConverts.size()/100 ; i++){
                    list<Database.LeadConvert> tempList = new list<Database.LeadConvert>();
                    Integer startIndex = i*100;
                    Integer endIndex = ((startIndex+100) < leadConverts.size()) ? startIndex+100: leadConverts.size();
                    for(Integer j=startIndex;j<endIndex;j++){
                        tempList.add(leadConverts[j]);
                    }
                    Database.LeadConvertResult[] lcrList = Database.convertLead(tempList, false);

                    for(Database.LeadConvertResult lcr : lcrList) {
                        if(!lcr.isSuccess()) {
                            errorMessages.add(lcr.getErrors()[0].getMessage());
                        }
                    }
                }
            }

            String firstError = errorMessages.size() > 0 ? errorMessages[0] : '';
            system.assertEquals(0, errorMessages.size(), 'Errors converting leads [' + firstError + ']');
            accList = [SELECT Id FROM Account LIMIT : bulkFactor];
            system.assertEquals(leadConverts.size(), accList.size(), 'Incorrect number of account records created');
            oppList = [SELECT Id FROM Opportunity LIMIT : bulkFactor];
            system.assertEquals(leadConverts.size(), oppList.size(), 'Incorrect number of opportunity records created');

            //Insert Account Member
            List<AccountTeamMember> atm1 = new List<AccountTeamMember>();
            for(Integer i = 0; i < accList.size(); i++) {
                atm1.addAll(TestDataUtility.createAccountTeamMember(accountManagerUserRecords[i].Id, accList[i].Id, 1));
            }
            insert atm1;

            //Insert Opportunity Member
            List<OpportunityTeamMember> otm = new List<OpportunityTeamMember>();
            for(Integer i = 0; i < oppList.size(); i++) {
                otm.addAll(TestDataUtility.createOpportunityTeamMember(accountManagerUserRecords[i].Id,oppList[i].Id, 1)); 
            }
            insert otm;
            //test.stopTest();
        }
    }

    public static void updateAccountManagerRecords(User userToRunAs, Integer bulkFactor) {
        System.runAs(userToRunAs) {
            accList = new List<Account>();
            for(Account acc : [SELECT Id, Name, OwnerId FROM Account LIMIT :bulkFactor]){
                acc.OwnerId = accountManagerUserRecords[1].Id;
                accList.add(acc);
            }  

            update accList;

            //Update Opportunity
            oppList = new List<Opportunity>();
            for(Opportunity opp : [SELECT Id, Name, OwnerId FROM Opportunity WHERE AccountId =:accList[0].Id AND OwnerId =:accountManagerUserRecords[0].Id LIMIT :bulkFactor]){
                opp.OwnerId = accountManagerUserRecords[1].Id;
                oppList.add(opp);
            }  

            update oppList;
        }
    }

    public static void deleteAccountRecords(User userToRunAs, Integer bulkFactor) {
        System.runAs(userToRunAs) {

            accList = [SELECT Id FROM Account LIMIT : bulkFactor];
            oppList = [SELECT Id FROM Opportunity LIMIT : bulkFactor];

            //Delete Opportunity
            delete oppList;

            // Deleting the accounts
            delete accList;
        }
    }
}