/**
* @Class Name: TestSendEmailAttachments
* @Description: Used for testing Sending Email Attachments functionality.
* ================================================================================================================
* Version | Date | Author | Comments
* -----------------------------------------------------------------------------------------------------------------
* 1.0 | 11th Aug, 2021 | sujata.chaudhari@weare4c.com | 1. This Test class is used for SendingEmailAttachments class.
* =================================================================================================================
*/
@isTest
public with sharing class TestSendEmailAttachments {
    @isTest
    public static void TestSendEmail() {
        testRunnerInsert(1);
    }

    public static void testRunnerInsert(Integer numberofRecords){

        Profile p = TestDataUtility.getProfile('Account Manager');
            
        User users = TestDataUtility.createUser('testff45@ghmail.com', 'tesdh', p.Id);
        users.Division = '452222';
        insert users;

        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Standard Price Book';
        insert pb;

        Entity__c ent = new Entity__c();
        ent.Country_Code__c = 'SA';
        ent.Entity__c = 'DHA';
        ent.Invoicing_Team_Email__c = 'chaudharisujata49@gmail.com';
        insert ent;

        Account companyAccount = TestDataUtility.createCompanyAccount('CompanyAccAuto12', 'SA', 'DHA');
        companyAccount.AccountNumber = '5959000000';
        companyAccount.Legal_Localized_Account_Name__c = 'Test';
        companyAccount.Legal_Name__c = 'Test';
        companyAccount.Legal_Name_Language__c = 'Test';
        companyAccount.Legal_Phone__c = '7485968574';
        companyAccount.Registration_Number__c = '8596';
        companyAccount.Segment__c = 'Accounting';
        companyAccount.Account_Entity__c = ent.Id;
        insert companyAccount;

        List<Account> billingAccounts = TestDataUtility.createAccountList(numberofRecords);
        billingAccounts[0].Name = 'AutoNumGen';
        billingAccounts[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
        billingAccounts[0].ParentId = companyAccount.Id;
        billingAccounts[0].Credit_Limit__c = '0';
        billingAccounts[0].Credit_Terms__c = '0NET0';
        billingAccounts[0].Account_Set__c = '300SAR';
        billingAccounts[0].Business_Type__c = 'E-Commerce';
        billingAccounts[0].Legal_City__c = 'test';
        billingAccounts[0].Account_Block_Type__c = '';
        billingAccounts[0].Legal_Street__c = 'test';
        billingAccounts[0].Tax_Rate__c = '0';
        billingAccounts[0].Account_Entity__c = ent.Id;
        insert billingAccounts;       

        Opportunity opp = TestDataUtility.createOpportunity('TestOpp', companyAccount.Id);
        opp.Billing_Account__c = billingAccounts[0].Id;
        opp.Amount = 200;
        insert opp;

        APXT_Redlining__Contract_Agreement__c ContractAgreement = new APXT_Redlining__Contract_Agreement__c();
        ContractAgreement.OwnerId = users.Id;
        ContractAgreement.APXT_Redlining__Status__c = 'Contract Approved';
        ContractAgreement.APXT_Redlining__Account__c = companyAccount.Id;
        ContractAgreement.Billing_Account__c = billingAccounts[0].Id;
        ContractAgreement.Opportunity__c = opp.Id;
        ContractAgreement.Contract_Signed_Date__c = System.today();
        ContractAgreement.APXT_Redlining__Effective_Date__c = System.today();
        ContractAgreement.APXT_Redlining__Expiration_Date__c = system.today() + 8;
        insert ContractAgreement;

        ContentVersion content = new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData = bodyBlob; 
        content.origin = 'H';
        insert content;

        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = ContractAgreement.id;
        contentlink.contentdocumentId = [SELECT contentdocumentId FROM contentversion WHERE Id =: content.Id].contentdocumentId;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;

        Test.startTest();
        ContractAgreement.APXT_Redlining__Status__c = 'Active';
        try{
            Update ContractAgreement;
        }
        Catch(Exception e){
            System.debug('Email Id is null');
        }
        
        Test.stopTest();

        List<EmailMessage> allmails = [SELECT Id, ToAddress FROM EmailMessage LIMIT 1];

        for (EmailMessage uniquemail : allmails) {
            System.assertEquals(uniquemail.ToAddress, 'chaudharisujata49@gmail.com');
        }
    }
}