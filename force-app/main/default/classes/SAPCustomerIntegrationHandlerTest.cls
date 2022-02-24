/**
* @Class Name: SAPCustomerIntegrationHandlerTest
* @Description: Used for SAPCustomerIntegrationHandler as a test class.
* ================================================================================================================
* Version | Date | Author | Comments
* -----------------------------------------------------------------------------------------------------------------
* 1.0 | 12th Feb, 2021 | sujata.chaudhari@weare4c.com | 1. This class is used by SAPCalloutHandler.
* =================================================================================================================
*/
@isTest
private class SAPCustomerIntegrationHandlerTest {

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
    *          SuccessMessageWithA200Response
    *          SuccessMessageWithNoIntegration 
    * Negative:
    *          SuccessMessageWithA404Response
    *          SuccessMessageWithA500Response
    *          SuccessMessageWithInvalidId
    *          SuccessMessageWithErrorResponse
    *          SuccessMessageWithInvalidResponse 
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
    public static void SuccessMessageWithA200Response() {
        Integer numberofRecords = 4;
        List<Account> accList = TestDataUtility.createAccountList(numberofRecords);     
        insert accList;

        accList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();

        accList[1].ParentId = accList[0].Id;
        accList[1].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();

        update accList;

        List<Id> accountIds = new List<Id>(new Map<Id, Account>(accList).keySet());

        Contact con = TestDataUtility.createContact('test', accList[0].Id);
        insert con;

        AccountContactRelation acr = TestDataUtility.createAccountContactRelation(accList[1].Id, con.Id);
        acr.Primary__c = true;
        insert acr;

        List<User> users = [SELECT Id, Name FROM User where isActive=true AND CreatedDate >= TODAY AND 
                            Profile.Name = 'Account Manager'];

        AccountTeamMember atm =  new AccountTeamMember(
            TeamMemberRole = 'Credit Manager',
            AccountId = accList[1].Id,
            UserId = users[0].Id
        );
        insert atm;                    
        
        /*
         * Setup mock
         */

        List<Map<String, String>> headers = new List<Map<String, String>>();
        headers.add(new Map<String, String> {'Content-Type' => 'application/json'});

        HTTPMockFactory serviceMock = new HTTPMockFactory('POST', '{    "MessageType": "S",    "Message": "Company code JO02 is not available in the customer",    "CustomerNo": "0000010101",    "BusinessArea": "AMM",    "Sort1": 10101 }  ', headers, 200);

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

        Contact con = TestDataUtility.createContact('test', accList[0].Id);
        insert con;

        AccountContactRelation acr = TestDataUtility.createAccountContactRelation(accList[1].Id, con.Id);
        acr.Primary__c = true;
        insert acr;

        List<User> users = [SELECT Id, Name FROM User where isActive=true AND CreatedDate >= TODAY AND 
                            Profile.Name = 'Account Manager'];

        AccountTeamMember atm =  new AccountTeamMember(
            TeamMemberRole = 'Credit Manager',
            AccountId = accList[1].Id,
            UserId = users[0].Id
        );
        insert atm;                    
        
        /*
         * Setup mock
         */

        List<Map<String, String>> headers = new List<Map<String, String>>();
        headers.add(new Map<String, String> {'Content-Type' => 'application/json'});

        HTTPMockFactory serviceMock = new HTTPMockFactory('POST', '{    "MessageType": "E",    "Message": "Company code JO02 is not available in the customer",    "CustomerNo": "0000010101",    "BusinessArea": "AMM",    "Sort1": 10101 }  ', headers, 200);

        Test.setMock(HttpCalloutMock.class, serviceMock); 
        
        /*
        * Setup user
        */
        testRunner(users[0], new List<Id>{accList[1].Id}, 0, 1, 0, 0, 1, 1, 'MessageCompany code JO02 is not available in the customer');
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

        Contact con = TestDataUtility.createContact('test', accList[0].Id);
        insert con;

        AccountContactRelation acr = TestDataUtility.createAccountContactRelation(accList[1].Id, con.Id);
        acr.Primary__c = true;
        insert acr;

        List<User> users = [SELECT Id, Name FROM User where isActive=true AND CreatedDate >= TODAY AND 
                            Profile.Name = 'Account Manager'];

        AccountTeamMember atm =  new AccountTeamMember(
            TeamMemberRole = 'Credit Manager',
            AccountId = accList[1].Id,
            UserId = users[0].Id
        );
        insert atm;                    
        
        /*
        * Setup user
        */
        testRunner(users[0], new List<Id>{accList[1].Id}, 0, 0, 1, 0, 1, 1, 'Methods defined as TestMethod do not support Web service callouts');
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

        System.debug('accList -- '+accList);

        Contact con = TestDataUtility.createContact('test', accList[0].Id);
        insert con;

        AccountContactRelation acr = TestDataUtility.createAccountContactRelation(accList[1].Id, con.Id);
        acr.Primary__c = true;
        insert acr;

        List<User> users = [SELECT Id, Name FROM User where isActive=true AND CreatedDate >= TODAY AND 
                            Profile.Name = 'Account Manager'];

        AccountTeamMember atm =  new AccountTeamMember(
            TeamMemberRole = 'Credit Manager',
            AccountId = accList[1].Id,
            UserId = users[0].Id
        );
        insert atm;
        
        /*
         * Setup mock
         */

        List<Map<String, String>> headers = new List<Map<String, String>>();
        headers.add(new Map<String, String> {'Content-Type' => 'application/json'});

        HTTPMockFactory serviceMock = new HTTPMockFactory('POST', '{    "MessageType": "S",    "Message": "Company code JO02 is not available in the customer",    "CustomerNo": "0000010101",    "BusinessArea": "AMM",    "Sort1": 10101 }  ', headers, 200);

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

    //     Contact con = TestDataUtility.createContact('test', accList[1].Id);
    //     insert con;

    //     AccountContactRelation acr = TestDataUtility.createAccountContactRelation(accList[0].Id, con.Id);
    //     acr.Primary__c = true;
    //     insert acr;

    //     List<User> users = [SELECT Id, Name FROM User where isActive=true AND CreatedDate >= TODAY AND 
    //                         Profile.Name = 'Account Manager'];
        
    //     /*
    //      * Setup mock
    //      */

    //     List<Map<String, String>> headers = new List<Map<String, String>>();
    //     headers.add(new Map<String, String> {'Content-Type' => 'application/json'});

    //     HTTPMockFactory serviceMock = new HTTPMockFactory('POST', '{    "MessageType": "S",    "Message": "Company code JO02 is not available in the customer",    "CustomerNo": "0000010101",    "BusinessArea": "AMM",    "Sort1": 10101 }  ', headers, 200);

    //     Test.setMock(HttpCalloutMock.class, serviceMock); 
        
    //     /*
    //     * Setup user
    //     */
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

        HTTPMockFactory serviceMock = new HTTPMockFactory('POST', '{    "MessageType": "S",    "Message": "Company code JO02 is not available in the customer",    "CustomerNo": "0000010101",    "BusinessArea": "AMM",    "Sort1": 10101 }', headers, 200);

        Test.setMock(HttpCalloutMock.class, serviceMock); 
        
        /*
        * Setup user
        */
        testRunner(users[0], accountIds, 0, 0, 1, 0, 1, 1, 'Unable to find account record');
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

        Contact con = TestDataUtility.createContact('test', accList[0].Id);
        insert con;

        AccountContactRelation acr = TestDataUtility.createAccountContactRelation(accList[1].Id, con.Id);
        acr.Primary__c = true;
        insert acr;

        List<User> users = [SELECT Id, Name FROM User where isActive=true AND CreatedDate >= TODAY AND 
                            Profile.Name = 'Account Manager'];

        AccountTeamMember atm =  new AccountTeamMember(
            TeamMemberRole = 'Credit Manager',
            AccountId = accList[1].Id,
            UserId = users[0].Id
        );
        insert atm;                    
        
        /*
         * Setup mock
         */

        List<Map<String, String>> headers = new List<Map<String, String>>();
        headers.add(new Map<String, String> {'Content-Type' => 'application/json'});

        HTTPMockFactory serviceMock = new HTTPMockFactory('POST', '{    "MessageType": "S",    "Message": "Company code JO02 is not available in the customer",    "CustomerNo": "0000010101",    "BusinessArea": "AMM",    "Sort1": 10101 }', headers, 404);

        Test.setMock(HttpCalloutMock.class, serviceMock); 
        
        /*
          * Setup user
          */
        testRunner(users[0], new List<Id>{accList[1].Id}, 0, 1, 0, 1, 1, 1, 'Unsuccessful Response Returned');
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

        Contact con = TestDataUtility.createContact('test', accList[0].Id);
        insert con;

        AccountContactRelation acr = TestDataUtility.createAccountContactRelation(accList[1].Id, con.Id);
        acr.Primary__c = true;
        insert acr;

        List<User> users = [SELECT Id, Name FROM User where isActive=true AND CreatedDate >= TODAY AND 
                            Profile.Name = 'Account Manager'];

        AccountTeamMember atm =  new AccountTeamMember(
            TeamMemberRole = 'Credit Manager',
            AccountId = accList[1].Id,
            UserId = users[0].Id
        );
        insert atm;                    
        
        /*
         * Setup mock
         */

        List<Map<String, String>> headers = new List<Map<String, String>>();
        headers.add(new Map<String, String> {'Content-Type' => 'application/json'});

        HTTPMockFactory serviceMock = new HTTPMockFactory('POST', '{    "MessageType": "S",    "Message": "Company code JO02 is not available in the customer",    "CustomerNo": "0000010101",    "BusinessArea": "AMM",    "Sort1": 10101 }', headers, 500);

        Test.setMock(HttpCalloutMock.class, serviceMock); 
        
        /*
          * Setup user
          */
        testRunner(users[0], new List<Id>{accList[1].Id}, 0, 1, 0, 1, 1, 1, 'Unsuccessful Response Returned');
    }

    @isTest
    public static void SuccessMessageWithInvalidId() {
        Integer numberofRecords = 1;
        List<Account> accList = TestDataUtility.createAccountList(numberofRecords);     
        insert accList;

        List<Id> accountIds = new List<Id>(new Map<Id, Account>(accList).keySet());
        accountIds.add('1133N00000TzgFoQAJ');

        List<User> users = [SELECT Id, Name FROM User where isActive=true AND CreatedDate >= TODAY AND 
                            Profile.Name = 'Account Manager'];                 
        
        /*
         * Setup mock
         */

        List<Map<String, String>> headers = new List<Map<String, String>>();
        headers.add(new Map<String, String> {'Content-Type' => 'application/json'});

        HTTPMockFactory serviceMock = new HTTPMockFactory('POST', '{    "MessageType": "S",    "Message": "Company code JO02 is not available in the customer",    "CustomerNo": "0000010101",    "BusinessArea": "AMM",    "Sort1": 10101 }', headers, 200);

        Test.setMock(HttpCalloutMock.class, serviceMock); 
        
        /*
          * Setup user
          */
        testRunner(users[0], accountIds, 0, 0, 1, 0, 1, 1, 'Unable to find account record');
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

        Contact con = TestDataUtility.createContact('test', accList[0].Id);
        insert con;

        AccountContactRelation acr = TestDataUtility.createAccountContactRelation(accList[1].Id, con.Id);
        acr.Primary__c = true;
        insert acr;

        List<User> users = [SELECT Id, Name FROM User where isActive=true AND CreatedDate >= TODAY AND 
                            Profile.Name = 'Account Manager'];

        AccountTeamMember atm =  new AccountTeamMember(
            TeamMemberRole = 'Credit Manager',
            AccountId = accList[1].Id,
            UserId = users[0].Id
        );
        insert atm;                    
        
        /*
         * Setup mock
         */

        List<Map<String, String>> headers = new List<Map<String, String>>();
        headers.add(new Map<String, String> {'Content-Type' => 'application/json'});

        HTTPMockFactory serviceMock = new HTTPMockFactory('POST', ' {    "MessageType": "E",    "Message": "Company code JO02 is not available in the customer",    "CustomerNo": "0000010101",    "BusinessArea": "AMM",    "Sort1": 10101 }', headers, 200);

        Test.setMock(HttpCalloutMock.class, serviceMock); 
        
        /*
          * Setup user
          */
        testRunner(users[0], new List<Id>{accList[1].Id}, 0, 1, 0, 0, 1, 0, '');
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

        Contact con = TestDataUtility.createContact('test', accList[0].Id);
        insert con;

        AccountContactRelation acr = TestDataUtility.createAccountContactRelation(accList[1].Id, con.Id);
        acr.Primary__c = true;
        insert acr;

        List<User> users = [SELECT Id, Name FROM User where isActive=true AND CreatedDate >= TODAY AND 
                            Profile.Name = 'Account Manager'];

        AccountTeamMember atm =  new AccountTeamMember(
            TeamMemberRole = 'Credit Manager',
            AccountId = accList[1].Id,
            UserId = users[0].Id
        );
        insert atm;                    
        
        /*
         * Setup mock
         */

        List<Map<String, String>> headers = new List<Map<String, String>>();
        headers.add(new Map<String, String> {'Content-Type' => 'application/json'});

        HTTPMockFactory serviceMock = new HTTPMockFactory('POST', '{    "MessageType": "E",    "Message": "Company code JO02 is not available in the customer",    "CustomerNo": "0000010101",    "BusinessArea": 12,    "Sort1": 10101 }', headers, 200);

        Test.setMock(HttpCalloutMock.class, serviceMock); 
        
        /*
          * Setup user
          */
        testRunner(users[0], new List<Id>{accList[1].Id}, 0, 1, 0, 1, 1, 1, 'Unsuccessful Response Returned');
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

        Contact con = TestDataUtility.createContact('test', accList[0].Id);
        insert con;

        AccountContactRelation acr = TestDataUtility.createAccountContactRelation(accList[1].Id, con.Id);
        acr.Primary__c = true;
        insert acr;

        List<User> users = [SELECT Id, Name FROM User where isActive=true AND CreatedDate >= TODAY AND 
                            Profile.Name = 'Account Manager'];

        AccountTeamMember atm =  new AccountTeamMember(
            TeamMemberRole = 'Credit Manager',
            AccountId = accList[1].Id,
            UserId = users[0].Id
        );
        insert atm;                    
        
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
        testRunner(users[0], new List<Id>{accList[1].Id}, 0, 0, 1, 0, 1, 1, 'Current token (null) not of boolean type at input location [1,4]');
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

        Contact con = TestDataUtility.createContact('test', accList[0].Id);
        insert con;

        AccountContactRelation acr = TestDataUtility.createAccountContactRelation(accList[1].Id, con.Id);
        acr.Primary__c = true;
        insert acr;

        List<User> users = [SELECT Id, Name FROM User where isActive=true AND CreatedDate >= TODAY AND 
                            Profile.Name = 'Account Manager'];

        AccountTeamMember atm =  new AccountTeamMember(
            TeamMemberRole = 'Credit Manager',
            AccountId = accList[1].Id,
            UserId = users[0].Id
        );
        insert atm;                    
        
        /*
         * Setup mock
         */

        List<Map<String, String>> headers = new List<Map<String, String>>();
        headers.add(new Map<String, String> {'Content-Type' => 'application/json'});

        HTTPMockFactory serviceMock = new HTTPMockFactory('POST', ' <?xml version="1.0" encoding="UTF-8" ?> <root> 	<MessageType>E</MessageType> 	<Message>Company code JO02 is not available in the customer</Message> 	<CustomerNo>0000010101</CustomerNo> 	<BusinessArea>AMM</BusinessArea> 	<Sort1>10101</Sort1> </root>', headers, 200);

        Test.setMock(HttpCalloutMock.class, serviceMock); 
        
        /*
          * Setup user
          */
        testRunner(users[0], new List<Id>{accList[1].Id}, 0, 0, 1, 0, 1, 1, 'Unexpected character ("<" (code 60)): expected a valid value (number, String, array, object, "true", "false" or "null") at input location [1,2]');
    }


    public static void testRunner(User userToRunAs, List<Id> accountIDs, Integer numberOfSuccess, Integer numberOfFailure, Integer numberOfException, Integer numberOfFailureWithMessage, Integer noOfFails, Integer numberOfExceptionFailureWithMessage, String message){
        System.runAs(userToRunAs) {
            Test.startTest();
            SAPCustomerIntegrationHandler.sAPOnboarding(accountIDs);
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
            System.assertEquals(numberOfException, [Select Id From Integration_Log__c Where Is_Success__c = false and Is_Integration_Related__c = false and Endpoint__c = 'callout:SAP_Credentials/RESTAdapter/SI_SF_CustMaster_Out'].size());
            System.assertEquals(noOfFails, [Select Id From Integration_Log__c Where Is_Success__c = false and Endpoint__c = 'callout:SAP_Credentials/RESTAdapter/SI_SF_CustMaster_Out'].size());
        }
        
    }
}