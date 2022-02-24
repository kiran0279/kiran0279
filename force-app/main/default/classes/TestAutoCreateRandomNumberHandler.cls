/**
    * @Class Name: TestAutoCreateRandomNumberHandler
    * @Description: Used for AccountTriggerHandler, AutoCreateRandomNumberHandler and AccountTrigger as a test Class.
    * ================================================================================================================
    * Version | Date | Author 
    * -----------------------------------------------------------------------------------------------------------------
    * 1.0 | 28th July, 2021 | sujata.chaudhari@weare4c.com
    * =================================================================================================================
    */
        
    @isTest
    public with sharing class TestAutoCreateRandomNumberHandler {
        @isTest
        public static void testAutoCreateRandomNumber(){
                testRunnerInsert(1);
        }
        public static void testRunnerInsert(Integer numberofRecords){
            
            
            Account companyAccount = TestDataUtility.createCompanyAccount('CompanyAccAuto12', 'SA', 'DHA');
            companyAccount.AccountNumber = '5959000000';
            insert companyAccount;

            List<Account> billingAccounts = TestDataUtility.createAccountList(numberofRecords);
            billingAccounts[0].Name = 'AutoNumGen';
            billingAccounts[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
            billingAccounts[0].ParentId = companyAccount.Id;
            billingAccounts[0].Credit_Limit__c = '0';
            insert billingAccounts;

            Account ac = [SELECT Id, Pin_Number__c FROM Account WHERE Name = 'AutoNumGen'];
            System.assertNotEquals(ac, Null);
        }
    }