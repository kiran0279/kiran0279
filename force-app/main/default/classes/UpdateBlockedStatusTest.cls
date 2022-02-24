/**
* @Class Name: UpdateBlockedStatusTest
* @Description: Used for UpdateBlockedStatus as a test class.
* ================================================================================================================
* Version | Date | Author | Comments
* -----------------------------------------------------------------------------------------------------------------
* 1.0 | 5th March, 2021 | sujata.chaudhari@weare4c.com | 1. This class is used by UpdateBlockedStatus.
* =================================================================================================================
*/
@isTest
public with sharing class UpdateBlockedStatusTest {

    /*
    * Positive:
    *            testPositive
    * Bulk:
    *            testBulk     
    */
    
    @isTest
    public static void testPositiveGlobalBlockingEnabled(){
        List<User> users = [SELECT Id, Name FROM User where isActive=true AND CreatedDate >= TODAY AND 
                                Profile.Name = 'Account Manager'];
        testRunner(users[0], 1, true);
    }

    @isTest
    public static void testPositiveGlobalBlockingDissabled(){
        List<User> users = [SELECT Id, Name FROM User where isActive=true AND CreatedDate >= TODAY AND 
                                Profile.Name = 'Account Manager'];
        testRunner(users[0], 1, false);
    }

    @isTest
    public static void testBulk(){
        List<User> users = [SELECT Id, Name FROM User where isActive=true AND CreatedDate >= TODAY AND 
                                Profile.Name = 'Account Manager'];
        testRunner(users[0], 20, true);                        
    }

    @testSetup static void testSetupData(){
        Profile p = TestDataUtility.getProfile('Account Manager');
            
        List<User> users = TestDataUtility.createUsers(p.Id, 2);
        insert users;
    }
    public static void testRunner(User userToRunAs, Integer numberofRecords, Boolean entityAutoBlockEnabled) {
        System.runAs(userToRunAs) {
            Entity__c entityRecord = new Entity__c(
                Auto_Blocking_Enabled__c = entityAutoBlockEnabled,
                Country_Code__c = 'AE',
                Entity__c = 'DXB'
            );
            insert entityRecord;

            Account companyAccount = TestDataUtility.createCompanyAccount('Company Account', 'AE', 'DXB');
            insert companyAccount;

            List<Account> billingAccountRecords = new List<Account>();
            for(Integer i =0; i < numberofRecords; i++) {
                String name = 'Billing Account ' + string.valueOf(i);
                billingAccountRecords.add(TestDataUtility.createBillingAccount(name, 
                                                                               companyAccount.Id, 
                                                                               TestDataUtility.AUTOBLOCK, 
                                                                               date.Today().addDays(-1),
                                                                               '30')
                                                                               
                );
            }
            insert billingAccountRecords;

            String sch = '0 0 13 * * ?'; 

            Test.StartTest();
            UpdateBlockedStatus ubs = new UpdateBlockedStatus();
            String jobId = system.schedule('Update the Block Status Test', sch, ubs);
            ubs.execute(null);
            Test.stopTest();

            Integer afterUpdateCount = [SELECT COUNT() FROM Account WHERE Account_Block_Status__c = 'Blocked'];

            // Get the information from the CronTrigger API object
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                        FROM CronTrigger WHERE id = :jobId];

            // Verify the expressions are the same
            System.assertEquals(sch, ct.CronExpression);
            System.assertEquals(entityRecord.Id, [Select Id, Account_Entity__c From Account Where Id = :companyAccount.Id].Account_Entity__c);

            // Verify the Count
            if(entityAutoBlockEnabled) {
                System.assertEquals(numberofRecords, afterUpdateCount);
            } else {
                System.assertEquals(0, afterUpdateCount);
            }
        }
    }
}