/**
* @Class Name: TestContractAgreementTriggerHandler
* @Description: Used for ContractAgreementTrigger as a test Class.
* ================================================================================================================
* Version | Date | Author | Comments
* -----------------------------------------------------------------------------------------------------------------
* 1.0 | 20th Aug, 2021 | sujata.chaudhari@weare4c.com | 1. This class is used as test class for ContractAgreementTrigger.
* =================================================================================================================
*/
@isTest
public with sharing class TestContractAgreementTriggerHandler {
    @isTest
    public static void testSubmitApprovalProcess(){
            testRunnerInsertIF(1);
    }

    @isTest
    public static void testApprovalProcess(){
            testRunnerInsertElse(1);
    }

    @testSetup static void methodName() {

        Profile p = TestDataUtility.getProfile('Account Manager');
            
        User users = TestDataUtility.createUser('testff45@ghmail.com', 'tesdh', p.Id);
        users.Division = '452222';
        insert users;

        Entity__c ent = new Entity__c();
        ent.Country_Code__c = 'AE';
        ent.Entity__c = 'DXB';
        ent.Invoicing_Team_Email__c = 'chaudharisujata49@gmail.com';
        insert ent;

        Account companyAccount = TestDataUtility.createCompanyAccount('CompanyAccAuto12', 'AE', 'DXB');
        companyAccount.AccountNumber = '5959000000';
        companyAccount.Legal_Localized_Account_Name__c = 'Test';
        companyAccount.Legal_Name__c = 'Test';
        companyAccount.Legal_Name_Language__c = 'Test';
        companyAccount.Legal_Phone__c = '7485968574';
        companyAccount.Registration_Number__c = '8596';
        companyAccount.Segment__c = 'Accounting';
        companyAccount.Account_Entity__c = ent.Id;
        insert companyAccount;

        List<Account> billingAccounts = TestDataUtility.createAccountList(1);
        billingAccounts[0].Name = 'AutoNumGen';
        billingAccounts[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
        billingAccounts[0].ParentId = companyAccount.Id;
        billingAccounts[0].Credit_Limit__c = '0';
        billingAccounts[0].Credit_Terms__c = '0NET0';
        billingAccounts[0].Account_Set__c = '300AED';
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
        ContractAgreement.APXT_Redlining__Status__c = 'Contract Approved';
        ContractAgreement.OwnerId = users.Id;
        ContractAgreement.APXT_Redlining__Account__c = companyAccount.Id;
        ContractAgreement.Billing_Account__c = billingAccounts[0].Id;
        ContractAgreement.Opportunity__c = opp.Id;
        ContractAgreement.Contract_Signed_Date__c = System.today();
        ContractAgreement.APXT_Redlining__Effective_Date__c = System.today();
        ContractAgreement.APXT_Redlining__Expiration_Date__c = system.today() + 8;
        insert ContractAgreement;
    }

    public static void testRunnerInsertIF(Integer numberofRecords){
        APXT_Redlining__Contract_Agreement__c cA = [SELECT Id FROM APXT_Redlining__Contract_Agreement__c];

        // Create an approval request for the Opportunity
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval automatically using Trigger');
        req1.setObjectId(cA.Id);

        try{
            // Submit the approval request for the Opportunity
            Approval.ProcessResult result = Approval.process(req1);
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }

    public static void testRunnerInsertElse(Integer numberofRecords){

        Entity__c ent = [SELECT Country_Code__c, Entity__c FROM Entity__c LIMIT 1];
        ent.Country_Code__c = 'SA';
        ent.Entity__c = 'DHA';
        update ent;

        Account companyAccount1 = [SELECT RecordTypeId, Country_Code__c, Entity__c FROM Account LIMIT 1];
        companyAccount1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        companyAccount1.Country_Code__c = 'SA';
        companyAccount1.Entity__c = 'DHA';
        update companyAccount1;

        Account billingAccount = [SELECT RecordTypeId, ParentId, Account_Entity__c, Account_Set__c FROM Account LIMIT 1];
        //billingAccount.ParentId = companyAccount1.Id;
        billingAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
        billingAccount.Account_Set__c = '300SAR';
        billingAccount.Account_Entity__c = ent.Id;
        billingAccount.Business_Type__c = 'E-Commerce';
        billingAccount.Credit_Limit__c = '0';
        billingAccount.Credit_Terms__c = '0NET0';
        billingAccount.Legal_City__c = 'test';
        billingAccount.Account_Block_Type__c = '';
        billingAccount.Legal_Street__c = 'test';
        billingAccount.Tax_Rate__c = '0';
        update billingAccount;       

        Opportunity oppt = [SELECT AccountId, Billing_Account__c, Amount FROM Opportunity LIMIT 1];
        

        APXT_Redlining__Contract_Agreement__c cA = [SELECT Id FROM APXT_Redlining__Contract_Agreement__c LIMIT 1];
        cA.APXT_Redlining__Status__c = 'Contract Approved';
        cA.APXT_Redlining__Account__c = companyAccount1.Id;
        cA.Billing_Account__c = billingAccount.Id;
        cA.Opportunity__c = oppt.Id;
        update cA;

        // Create an approval request for the Opportunity
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval automatically using Trigger');
        req1.setObjectId(cA.Id);

        try{
            // Submit the approval request for the Opportunity
            Approval.ProcessResult result = Approval.process(req1);
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
}