/**
* @Class Name: ErrorLogHandlerTest
* @Description: Used for ErrorLogHandler as a test class.
* ================================================================================================================
* Version | Date | Author | Comments
* -----------------------------------------------------------------------------------------------------------------
* 1.0 | 12th Feb, 2021 | sujata.chaudhari@weare4c.com | 1. This class is used by RestCalloutHandler.
* =================================================================================================================
*/
@isTest
private class ErrorLogHandlerTest {

    /*
    * Positive:
    *          testCreateLogsPositive
    * Negative:
    *          testCreateLogsNegative
    *          testNegativeCreateLog
    * Bulk:
    *          testCreateLogsBulk
    *          testCreateLogsMaxBulk 
    * Null:
    *          testCreateLogsNull
    *          testCreateLogsHtml  
    */
    
    @isTest
    public static void testCreateLogsPositive(){
        testRunner(1, 200, '{ "_StorerKey" : "DEMO2", "_Entity" : "JFK", "_CurrCode" : "USD", "_Country" : "United States of America", "_Company" : "Demo", "_CLoginToken" : { "_UserName" : "wssf", "_PassWord" : "jfhg8.33434o*", "_FacilityStr" : "WMWHSE1" }, "_City" : "Dubai", "_BusinessCategory" : "OTHER", "_BlockStatus" : false }', 
                '{"_HasError":false,"_Result":"OK: Block Status Updated"}', true, false);
    }

    @isTest
    public static void testCreateLogsNegative(){
        testRunner(1, 404, '{ "_StorerKey" : "DEMO2", "_Entity" : "JFK", "_CurrCode" : "USD", "_Country" : "United States of America", "_CLoginToken" : { "_UserName" : "wssf", "_PassWord" : "jfhg8.33434o*", "_FacilityStr" : "WMWHSE1" }, "_City" : "Dubai", "_BusinessCategory" : "OTHER", "_BlockStatus" : false }', 
                '{_Result":"OK: Block Status Updated"}', false, true);
    }

    @isTest
    public static void testNegativeCreateLog(){
        testRunner(1, 500, '{ "_StorerKey" : "DEMO2", "_Entity" : "JFK", "_CurrCode" : "SD", "_Country" : "United States of America", "_Company" : "Demo", "_CLoginToken" : { "_UserName" : "wssf", "_PassWord" : "jfhg8.33434o*", "_FacilityStr" : "WMWHSE1" }, "_City" : "Dubai", "_BusinessCategory" : "OTHER", "_BlockStatus" : false }',
                '{"_HasError":true,"_Result":"OK: Block Status Updated"}', false, true);
    }

    @isTest
    public static void testCreateLogsBulk(){
        testRunner(2, 200, '{ "_StorerKey" : "DEMO2", "_Entity" : "JFK", "_CurrCode" : "USD", "_Country" : "United States of America", "_Company" : "Demo", "_CLoginToken" : { "_UserName" : "wssf", "_PassWord" : "jfhg8.33434o*", "_FacilityStr" : "WMWHSE1" }, "_City" : "Dubai", "_BusinessCategory" : "OTHER", "_BlockStatus" : false }',
                '{"_HasError":false,"_Result":"OK: Block Status Updated"}',true, false);
    }

    @isTest
    public static void testCreateLogsMaxBulk(){
        testRunner(200, 200, '{ "_StorerKey" : "DEMO2", "_Entity" : "JFK", "_CurrCode" : "USD", "_Country" : "United States of America", "_Company" : "Demo", "_CLoginToken" : { "_UserName" : "wssf", "_PassWord" : "jfhg8.33434o*", "_FacilityStr" : "WMWHSE1" }, "_City" : "Dubai", "_BusinessCategory" : "OTHER", "_BlockStatus" : false }',
                '{"_HasError":false,"_Result":"OK: Block Status Updated"}',true, false);
    }

    @isTest
    public static void testCreateLogsNull(){
        testRunner(1, 200, '{ "_StorerKey" : "DEMO2", "_Entity" : "JFK", "_CurrCode" : "SD", "_Country" : "United States of America", "_Company" : "Demo", "_CLoginToken" : { "_UserName" : "wssf", "_PassWord" : "jfhg8.33434o*", "_FacilityStr" : "WMWHSE1" }, "_City" : "Dubai", "_BusinessCategory" : "OTHER", "_BlockStatus" : false }',
                ' ', false, true);
    }

    @isTest
    public static void testCreateLogsHtml(){
        testRunner(1, 200, '{ "_StorerKey" : "DEMO2", "_Entity" : "JFK", "_CurrCode" : "SD", "_Country" : "United States of America", "_Company" : "Demo", "_CLoginToken" : { "_UserName" : "wssf", "_PassWord" : "jfhg8.33434o*", "_FacilityStr" : "WMWHSE1" }, "_City" : "Dubai", "_BusinessCategory" : "OTHER", "_BlockStatus" : false }',
                '<?xml version="1.0" encoding="UTF-8" ?> <root> 	<_HasError>false</_HasError> 	<_Result>OK: Block Status Updated</_Result> </root>', 
                true, false);
    }

    @testSetup static void testSetup(){
        Profile p = TestDataUtility.getProfile('Account Manager');
            
        List<User> users = TestDataUtility.createUsers(p.Id, 2);
        insert users;

        Account acc = TestDataUtility.createAccount('test');
        acc.OwnerId = users[0].Id; 
        insert acc;  
    }

    public static void testRunner(Integer numberofRecords,Integer statsCode, String reqBody, String respBody,Boolean isSuccess, Boolean isIntegrationRelated){
        List<User> users = [SELECT Id, Name FROM User where isActive=true AND CreatedDate >= TODAY AND 
                            Profile.Name = 'Account Manager'];

        Account acc = [SELECT Id FROM Account WHERE OwnerId =: users[0].Id LIMIT :numberofRecords];
        List<Map<String, String>> headers = new List<Map<String, String>>();
        headers.add(new Map<String, String> {'Content-Type' => 'application/json'});
        /*
        * pass header
        */

        Test.startTest();
        Integration_Log__c createLogs = ErrorLogHandler.createLog(acc.Id, 'callout:Infor_Credentials/WS_EDI_TEST_V02/RestService_Users/Storer/UpdateStorer', 
                                            'test', isSuccess, isIntegrationRelated, reqBody, respBody, statsCode, 'Stacktrace', 'POST');                          

        Integration_Log__c updateLogs = ErrorLogHandler.updateLog(createLogs, 'test', 'callout:Infor_Credentials/WS_EDI_TEST_V02/RestService_Users/Storer/UpdateStorer',
                                            isSuccess, isIntegrationRelated, reqBody, headers, respBody, statsCode, 'POST'); 
        upsert updateLogs;                                         
        Test.stopTest(); 
        System.assertEquals(updateLogs.Id, [SELECT Id FROM Integration_Log__c WHERE Account__c =:acc.Id AND Is_Success__c =: isSuccess LIMIT 1].Id, 'Integration log record was not created');
        /*
        * Check for the success or failure in assert
        */
    }
}