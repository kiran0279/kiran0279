/**
* @Class Name: ArchiveRecordsBatchTest
* @Description: Used for ArchiveRecordsBatch as a test class.
* ================================================================================================================
* Version | Date | Author | Comments
* -----------------------------------------------------------------------------------------------------------------
* 1.0 | 5th March, 2021 | sujata.chaudhari@weare4c.com | 1. This class is used by ArchiveRecordsBatch.
* =================================================================================================================
*/
@isTest
public with sharing class ArchiveRecordsBatchTest {

    /*
    * Positive:
    *            testPositive
    * Bulk:
    *            testBulk     
    */

    @isTest
    public static void testPositive(){
        List<User> users = [SELECT Id, Name FROM User where isActive=true AND CreatedDate >= TODAY AND 
                                Profile.Name = 'Account Manager'];
        testRunner(users[0], 1);
    }

    @isTest
    public static void testBulk(){
        List<User> users = [SELECT Id, Name FROM User where isActive=true AND CreatedDate >= TODAY AND 
                                Profile.Name = 'Account Manager'];
        testRunner(users[0], 200);                        
    }

    @testSetup static void testSetupData(){
        Profile p = TestDataUtility.getProfile('Account Manager');
            
        List<User> users = TestDataUtility.createUsers(p.Id, 2);
        insert users;
    }

    public static void testRunner(User userToRunAs, Integer numberofRecords) {
        System.runAs(userToRunAs) {
            Job_Archive_Setting__c jas = TestDataUtility.createJobArchiveSetting('test');
            insert jas;

            Account acc = TestDataUtility.createAccount('test');
            insert acc;

            List<Integration_Log__c> logList = TestDataUtility.createIntegrationLogList(acc.Id, numberofRecords);
            insert logList;

            Date oldDate = Date.Today().addDays(-200);
            for(Integration_Log__c logListRecord : logList) {
                Test.setCreatedDate(logListRecord.Id, oldDate);
            }

            Integer beforeArchiveLogsCount = [SELECT COUNT() FROM Integration_Log__c WHERE Archiving_Required__c = true];

            String sch = '0 0 13 * * ?'; 
            ArchiveRecordsBatch arb = new ArchiveRecordsBatch('Integration_Log__c', 'Archiving_Required__c');

            Test.StartTest();
            String jobId = system.schedule('Archive Records', sch, arb); 
            arb.execute(null);
            Test.stopTest();

            Integer afterArchiveLogsCount = [SELECT COUNT() FROM Integration_Log__c WHERE Archiving_Required__c = true];

            // Get the information from the CronTrigger API object
                CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                            FROM CronTrigger WHERE id = :jobId];

            // Verify the expressions are the same
            System.assertEquals(sch, ct.CronExpression);

            // Verify the Count
            System.assertnotEquals(beforeArchiveLogsCount, afterArchiveLogsCount);
        }
    }
}