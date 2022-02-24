/**
* @Class Name: InforCIHandlerTest
* @Description: Used for InforCustomerIntegrationHandler as a test class.
* ================================================================================================================
* Version | Date | Author | Comments
* -----------------------------------------------------------------------------------------------------------------
* 1.0 | 12th Feb, 2021 | sujata.chaudhari@weare4c.com | 1. This class is used by InforCalloutHandler.
* =================================================================================================================
*/
@isTest
private class InforCIHandlerTest {

/*
* TODO
*  - Test runner -done
*  - Running under specific users -done
*  - Meaningful asserts on the tests  -done
* 
* Positive
*  - 200 response with success message - no integration log  -done
*  - 200 response will integration log  -done
* Negative
*  - 404 reponse    -done
*  - 500 response   -done
*  - Invalid id passed in  -done
*  - Invalid data in the response  -done
*      Suggestion is that you make a boolean or integer an invalid value
*  - Error response from the callout  -done
*      Message type of e or has error = true
* Null
*  - null accounts   -done
*  - blank response  -done
*  - html response   -done
* Bulk
*  - 2 records -done
*  - 200 records -done
*/


    /*
    * Positive:
    *          successMessageWithA200Response
    *          SuccessMessageWithIntegrationLog 
    * Negative:
    *          SuccessMessageWithA404Response
    *          SuccessMessageWithA500Response
    *          SuccessMessageWithInvalidId
    *          SuccessMessageWithErrorResponse
    *          SuccessMessageWithInvalidResponse
    *          SuccessMessageWithExceptionCoverage  
    * Null:
    *          SuccessMessageWithNullAccounts
    *          SuccessMessageWithBlankResponse
    *          SuccessMessageWithHtmlResponse
    * Bulk:
    *          SuccessMessageWith2BulkRecords 
    *          SuccessMessageWith200BulkRecords 
    */


    @testSetup static void testSetupData(){
        Profile p = TestDataUtility.getProfile('Account Manager');
            
        List<User> users = TestDataUtility.createUsers(p.Id, 2);
        insert users;

        Integration_Settings__c ins = new Integration_Settings__c();
        ins.Enable_Debug_Logging__c = true;
        //ins.Hide_Credentials__c = false;
        insert ins;
    }

    @isTest
    public static void successMessageWithA200Response() {
        Integer numberofRecords = 3;
        List<Account> accList = TestDataUtility.createAccountList(numberofRecords);
        insert accList;

        accList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();

        accList[1].ParentId = accList[0].Id;
        accList[1].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();

        update accList;

        List<Id> accountIds = new List<Id>(new Map<Id, Account>(accList).keySet());

        Product2 prod = TestDataUtility.createProduct('test');
        insert prod;

        Asset ast = TestDataUtility.createAsset('test', accList[0].Id);
        ast.Product2Id = prod.Id;
        insert ast;

        List<User> users = [SELECT Id, Name FROM User where isActive=true AND CreatedDate >= TODAY AND 
                            Profile.Name = 'Account Manager'];
        
        /*
         * Setup mock
         */

        List<Map<String, String>> headers = new List<Map<String, String>>();
        headers.add(new Map<String, String> {'Content-Type' => 'application/json'});
        headers.add(new Map<String, String> {'Accept' => 'application/json'});

        HTTPMockFactory serviceMock = new HTTPMockFactory('POST', '{"_HasError":false,"_Result":"OK: Block Status Updated"}', headers, 200);

        Test.setMock(HttpCalloutMock.class, serviceMock); 
        
        /*
        * Setup user
        */
        testRunner(users[0], new List<Id>{accList[1].Id}, 1, 0, 0, 0, 0, 0, '');
    }

    @isTest
    public static void SuccessMessageWithIntegrationLog() {
        Integer numberofRecords = 3;
        List<Account> accList = TestDataUtility.createAccountList(numberofRecords);     
        insert accList;

        accList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();

        accList[1].ParentId = accList[0].Id;
        accList[1].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();

        update accList;

        List<Id> accountIds = new List<Id>(new Map<Id, Account>(accList).keySet());

        Product2 prod = TestDataUtility.createProduct('test');
        insert prod;

        Asset ast = TestDataUtility.createAsset('test', accList[0].Id);
        ast.Product2Id = prod.Id;
        insert ast;

        List<User> users = [SELECT Id, Name FROM User where isActive=true AND CreatedDate >= TODAY AND 
                            Profile.Name = 'Account Manager'];
        
        /*
        * Setup mock
        */

        List<Map<String, String>> headers = new List<Map<String, String>>();
        headers.add(new Map<String, String> {'Content-Type' => 'application/json'});
        headers.add(new Map<String, String> {'Accept' => 'application/json'});

        HTTPMockFactory serviceMock = new HTTPMockFactory('POST', '{"_HasError":true,"_Result":"OK: Block Status Updated"}', headers, 200);

        Test.setMock(HttpCalloutMock.class, serviceMock); 
        
        /*
        * Setup user
        */
        testRunner(users[0], new List<Id>{accList[1].Id}, 0, 1, 0, 1, 0, 1, 'OK: Block Status Updated');
    }

    @isTest
    public static void SuccessMessageWithExceptionCoverage() {
        Integer numberofRecords = 3;
        List<Account> accList = TestDataUtility.createAccountList(numberofRecords);     
        insert accList;

        accList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();

        accList[1].ParentId = accList[0].Id;
        accList[1].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();

        update accList;

        List<Id> accountIds = new List<Id>(new Map<Id, Account>(accList).keySet());

        Product2 prod = TestDataUtility.createProduct('test');
		    prod.Family = 'Freight';
        insert prod;

        Asset ast = TestDataUtility.createAsset('test', accList[0].Id);
        ast.Product2Id = prod.Id;
        insert ast;

        List<User> users = [SELECT Id, Name FROM User where isActive=true AND CreatedDate >= TODAY AND 
                            Profile.Name = 'Account Manager'];
        
        /*
        * Setup user
        */
        testRunner(users[0], new List<Id>{accList[1].Id}, 0, 0, 0, 0, 0, 1, 'Unable to find a logistics asset record with a facility code assigned');
    }

    @isTest
    public static void SuccessMessageWith2BulkRecords() {
        Integer numberofRecords = 2;
        List<Account> accList = TestDataUtility.createAccountList(numberofRecords);     
        insert accList;

        accList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();

        accList[1].ParentId = accList[0].Id;
        accList[1].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();

        update accList;

        List<Id> accountIds = new List<Id>(new Map<Id, Account>(accList).keySet());

        Product2 prod = TestDataUtility.createProduct('test');
        insert prod;

        Asset ast = TestDataUtility.createAsset('test', accList[0].Id);
        ast.Product2Id = prod.Id;
        insert ast;

        List<User> users = [SELECT Id, Name FROM User where isActive=true AND CreatedDate >= TODAY AND 
                            Profile.Name = 'Account Manager'];
        
        /*
         * Setup mock
         */

        List<Map<String, String>> headers = new List<Map<String, String>>();
        headers.add(new Map<String, String> {'Content-Type' => 'application/json'});

        HTTPMockFactory serviceMock = new HTTPMockFactory('POST', '{"_HasError":false,"_Result":"OK: Block Status Updated"}', headers, 200);

        Test.setMock(HttpCalloutMock.class, serviceMock); 
        
        /*
          * Setup user
          */
        testRunner(users[0], new List<Id>{accList[1].Id}, 1, 0, 0, 0, 0, 0, '');
    }

    // @isTest
    // public static void SuccessMessageWith200BulkRecords() {
    //     Integer numberofRecords = 200;
    //     List<Account> accList = TestDataUtility.createAccountList(numberofRecords);     
    //     insert accList;

    //     accList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();

    //     accList[1].ParentId = accList[0].Id;
    //     accList[1].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();

    //     update accList;

    //     List<Id> accountIds = new List<Id>(new Map<Id, Account>(accList).keySet());

    //     Product2 prod = TestDataUtility.createProduct('test');
    //     insert prod;

    //     Asset ast = TestDataUtility.createAsset('test', accList[0].Id);
    //     ast.Product2Id = prod.Id;
    //     insert ast;


    //     List<User> users = [SELECT Id, Name FROM User where isActive=true AND CreatedDate >= TODAY AND 
    //                         Profile.Name = 'Account Manager'];
        
    //     /*
    //      * Setup mock
    //      */

    //     List<Map<String, String>> headers = new List<Map<String, String>>();
    //     headers.add(new Map<String, String> {'Content-Type' => 'application/json'});

    //     HTTPMockFactory serviceMock = new HTTPMockFactory('POST', '{"_HasError":false,"_Result":"OK: Block Status Updated"}', headers, 200);

    //     Test.setMock(HttpCalloutMock.class, serviceMock); 
        
    //     /*
    //       * Setup user
    //       */
    //     testRunner(users[0], new List<Id>{accList[1].Id}, 1, 0, 0, 0, 0, 0, '');
    // }

    @isTest
    public static void SuccessMessageWithNullAccounts() {
        Integer numberofRecords = 0;
        List<Account> accList = TestDataUtility.createAccountList(numberofRecords);     
        insert accList;

        List<Id> accountIds = new List<Id>(new Map<Id, Account>(accList).keySet());

        List<User> users = [SELECT Id, Name FROM User where isActive=true AND CreatedDate >= TODAY AND 
                            Profile.Name = 'Account Manager'];
        
        /*
         * Setup mock
         */

        List<Map<String, String>> headers = new List<Map<String, String>>();
        headers.add(new Map<String, String> {'Content-Type' => 'application/json'});

        HTTPMockFactory serviceMock = new HTTPMockFactory('POST', '{"_HasError":false,"_Result":"OK: Block Status Updated"}', headers, 200);

        Test.setMock(HttpCalloutMock.class, serviceMock); 
        
        /*
          * Setup user
          */
        testRunner(users[0], accountIds, 0, 0, 0, 0, 0, 0, '');
    }

    @isTest
    public static void SuccessMessageWithA404Response() {
        Integer numberofRecords = 3;
        List<Account> accList = TestDataUtility.createAccountList(numberofRecords);     
        insert accList;

        accList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();

        accList[1].ParentId = accList[0].Id;
        accList[1].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();

        update accList;

        List<Id> accountIds = new List<Id>(new Map<Id, Account>(accList).keySet());

        Product2 prod = TestDataUtility.createProduct('test');
        insert prod;

        Asset ast = TestDataUtility.createAsset('test', accList[0].Id);
        ast.Product2Id = prod.Id;
        insert ast;

        List<User> users = [SELECT Id, Name FROM User where isActive=true AND CreatedDate >= TODAY AND 
                            Profile.Name = 'Account Manager'];
        
        /*
        * Setup mock
        */

        List<Map<String, String>> headers = new List<Map<String, String>>();
        headers.add(new Map<String, String> {'Content-Type' => 'application/json'});

        HTTPMockFactory serviceMock = new HTTPMockFactory('POST', '{"_HasError":false,"_Result":"OK: Block Status Updated"}', headers, 404);

        Test.setMock(HttpCalloutMock.class, serviceMock); 
        
        /*
        * Setup user
        */
        testRunner(users[0], new List<Id>{accList[1].Id}, 0, 1, 0, 1, 0, 1, 'Unsuccessful Response Returned');
    }

    @isTest
    public static void SuccessMessageWithA500Response() {
        Integer numberofRecords = 3;
        List<Account> accList = TestDataUtility.createAccountList(numberofRecords);     
        insert accList;

        accList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();

        accList[1].ParentId = accList[0].Id;
        accList[1].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();

        update accList;

        List<Id> accountIds = new List<Id>(new Map<Id, Account>(accList).keySet());

        Product2 prod = TestDataUtility.createProduct('test');
        insert prod;

        Asset ast = TestDataUtility.createAsset('test', accList[0].Id);
        ast.Product2Id = prod.Id;
        insert ast;

        List<User> users = [SELECT Id, Name FROM User where isActive=true AND CreatedDate >= TODAY AND 
                            Profile.Name = 'Account Manager'];
        
        /*
        * Setup mock
        */

        List<Map<String, String>> headers = new List<Map<String, String>>();
        headers.add(new Map<String, String> {'Content-Type' => 'application/json'});

        HTTPMockFactory serviceMock = new HTTPMockFactory('POST', '{"_HasError":false,"_Result":"OK: Block Status Updated"}', headers, 500);

        Test.setMock(HttpCalloutMock.class, serviceMock); 
        
        /*
        * Setup user
        */
        testRunner(users[0],  new List<Id>{accList[1].Id}, 0, 1, 0, 1, 0, 1, 'Unsuccessful Response Returned');
    }

    @isTest
    public static void SuccessMessageWithInvalidId() {
        Integer numberofRecords = 2;
        List<Account> accList = TestDataUtility.createAccountList(numberofRecords);     
        insert accList;

        accList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();

        accList[1].ParentId = accList[0].Id;
        accList[1].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();

        update accList;

        List<Id> accountIds = new List<Id>(new Map<Id, Account>(accList).keySet());
        accountIds.add('0033N00000TzgFoQAJ');

        Product2 prod = TestDataUtility.createProduct('test');
        insert prod;

        Asset ast = TestDataUtility.createAsset('test', accList[0].Id);
        ast.Product2Id = prod.Id;
        insert ast;

        List<User> users = [SELECT Id, Name FROM User where isActive=true AND CreatedDate >= TODAY AND 
                            Profile.Name = 'Account Manager'];
        
        /*
         * Setup mock
         */

        List<Map<String, String>> headers = new List<Map<String, String>>();
        headers.add(new Map<String, String> {'Content-Type' => 'application/json'});

        HTTPMockFactory serviceMock = new HTTPMockFactory('POST', '{"_HasError":false,"_Result":"OK: Block Status Updated"}', headers, 200);

        Test.setMock(HttpCalloutMock.class, serviceMock); 
        
        /*
          * Setup user
          */
        testRunner(users[0], accountIds, 0, 0, 0, 1, 0, 0, '');
    }

    @isTest
    public static void SuccessMessageWithErrorResponse() {
        Integer numberofRecords = 2;
        List<Account> accList = TestDataUtility.createAccountList(numberofRecords);     
        insert accList;

        accList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();

        accList[1].ParentId = accList[0].Id;
        accList[1].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();

        update accList;

        List<Id> accountIds = new List<Id>(new Map<Id, Account>(accList).keySet());

        Product2 prod = TestDataUtility.createProduct('test');
        insert prod;

        Asset ast = TestDataUtility.createAsset('test', accList[0].Id);
        ast.Product2Id = prod.Id;
        insert ast;

        List<User> users = [SELECT Id, Name FROM User where isActive=true AND CreatedDate >= TODAY AND 
                            Profile.Name = 'Account Manager'];
        
        /*
        * Setup mock
        */

        List<Map<String, String>> headers = new List<Map<String, String>>();
        headers.add(new Map<String, String> {'Content-Type' => 'application/json'});

        HTTPMockFactory serviceMock = new HTTPMockFactory('POST', ' {"_HasError":true,"_Result":"OK: Block Status Updated"}', headers, 200);

        Test.setMock(HttpCalloutMock.class, serviceMock); 
        
        /*
        * Setup user
        */
        testRunner(users[0], new List<Id>{accList[1].Id}, 0, 1, 0, 1, 0, 1, 'OK: Block Status Updated');
    }

    @isTest
    public static void SuccessMessageWithInvalidResponse() {
        Integer numberofRecords = 2;
        List<Account> accList = TestDataUtility.createAccountList(numberofRecords);     
        insert accList;

        accList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();

        accList[1].ParentId = accList[0].Id;
        accList[1].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();

        update accList;

        List<Id> accountIds = new List<Id>(new Map<Id, Account>(accList).keySet());

        Product2 prod = TestDataUtility.createProduct('test');
        insert prod;

        Asset ast = TestDataUtility.createAsset('test', accList[0].Id);
        ast.Product2Id = prod.Id;
        insert ast;

        List<User> users = [SELECT Id, Name FROM User where isActive=true AND CreatedDate >= TODAY AND 
                            Profile.Name = 'Account Manager'];
        
        /*
         * Setup mock
         */

        List<Map<String, String>> headers = new List<Map<String, String>>();
        headers.add(new Map<String, String> {'Content-Type' => 'application/json'});

        HTTPMockFactory serviceMock = new HTTPMockFactory('POST', '{"_HasError":12,"_Result":"OK: Block Status Updated"}', headers, 200);

        Test.setMock(HttpCalloutMock.class, serviceMock); 
        
        /*
          * Setup user
          */
        testRunner(users[0], new List<Id>{accList[1].Id}, 0, 0, 0, 0, 0, 1, '');
    }

    @isTest
    public static void SuccessMessageWithBlankResponse() {
        Integer numberofRecords = 2;
        List<Account> accList = TestDataUtility.createAccountList(numberofRecords);     
        insert accList;

        accList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();

        accList[1].ParentId = accList[0].Id;
        accList[1].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();

        update accList;

        List<Id> accountIds = new List<Id>(new Map<Id, Account>(accList).keySet());

        Product2 prod = TestDataUtility.createProduct('test');
        insert prod;

        Asset ast = TestDataUtility.createAsset('test', accList[0].Id);
        ast.Product2Id = prod.Id;
        insert ast;

        List<User> users = [SELECT Id, Name FROM User where isActive=true AND CreatedDate >= TODAY AND 
                            Profile.Name = 'Account Manager'];
        
        /*
        * Setup mock
        */

        List<Map<String, String>> headers = new List<Map<String, String>>();
        headers.add(new Map<String, String> {'Content-Type' => 'application/json'});

        HTTPMockFactory serviceMock = new HTTPMockFactory('POST', ' ', headers, 200);

        Test.setMock(HttpCalloutMock.class, serviceMock); 
        
        /*
        * Setup user
        */
        testRunner(users[0], new List<Id>{accList[1].Id}, 0, 0, 0, 0, 0, 1, '');
    }

    @isTest
    public static void SuccessMessageWithHtmlResponse() {
        Integer numberofRecords = 2;
        List<Account> accList = TestDataUtility.createAccountList(numberofRecords);     
        insert accList;

        accList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();

        accList[1].ParentId = accList[0].Id;
        accList[1].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();

        update accList;

        List<Id> accountIds = new List<Id>(new Map<Id, Account>(accList).keySet());

        Product2 prod = TestDataUtility.createProduct('test');
        insert prod;

        Asset ast = TestDataUtility.createAsset('test', accList[0].Id);
        ast.Product2Id = prod.Id;
        insert ast;

        List<User> users = [SELECT Id, Name FROM User where isActive=true AND CreatedDate >= TODAY AND 
                            Profile.Name = 'Account Manager'];
        
        /*
         * Setup mock
         */

        List<Map<String, String>> headers = new List<Map<String, String>>();
        headers.add(new Map<String, String> {'Content-Type' => 'application/json'});

        HTTPMockFactory serviceMock = new HTTPMockFactory('POST', '<?xml version="1.0" encoding="UTF-8"?><root><_HasError>false</_HasError><_Result>OK: Block Status Updated</_Result></root>', headers, 200);

        Test.setMock(HttpCalloutMock.class, serviceMock); 
        
        /*
        * Setup user
        */
        testRunner(users[0], new List<Id>{accList[1].Id}, 0, 0, 0, 0, 0, 1, '');
    }


    public static void testRunner(User userToRunAs, List<Id> accountIDs, Integer numberOfSuccess, Integer numberOfFailure, Integer numberOfException, Integer numberOfFailureWithMessage, Integer noOfFails, Integer numberOfExceptionFailureWithMessage, String message){
        System.runAs(userToRunAs) {
            Test.startTest();
            InforCustomerIntegrationHandler.inforOnboarding(accountIDs);
            Test.stopTest();


            List<Integration_Log__c> inl = new List<Integration_Log__c>();
            for (Integration_Log__c log : [Select Id, Error_Message__c From Integration_Log__c Where Is_Success__c = false and Is_Integration_Related__c = true]) {
              if(log.Error_Message__c == message){
                inl.add(log);
                System.assertEquals(numberOfFailureWithMessage, inl.Size());
              }
            }

            List<Integration_Log__c> inlog = new List<Integration_Log__c>();
            for (Integration_Log__c logs : [Select Id, Error_Message__c From Integration_Log__c Where Is_Success__c = false and Is_Integration_Related__c = false]) {
              if(logs.Error_Message__c == message){
                inlog.add(logs);
                System.assertEquals(numberOfExceptionFailureWithMessage, inlog.Size());
              }
            }

            System.assertEquals(numberOfSuccess, [Select Id From Integration_Log__c Where Is_Success__c = true].size());
            System.assertEquals(numberOfFailure, [Select Id From Integration_Log__c Where Is_Success__c = false and Is_Integration_Related__c = true].size());
            System.assertEquals(numberOfException, [Select Id From Integration_Log__c Where Is_Success__c = false and Is_Integration_Related__c = false and Endpoint__c = 'callout:Infor_Credentials/WS_EDI_TEST_V02/RestService_Users/Storer/UpdateStorer'].size());
            System.assertEquals(noOfFails, [Select Id From Integration_Log__c Where Is_Success__c = false and Endpoint__c = 'callout:Infor_Credentials/WS_EDI_TEST_V02/RestService_Users/Storer/UpdateStorer'].size());
        }
        
    }
}