/**
* @Class Name: InforCalloutHandlerTest
* @Description: Used for InforCalloutHandler as a test class.
* ================================================================================================================
* Version | Date | Author
* -----------------------------------------------------------------------------------------------------------------
* 1.0 | 12th Feb, 2021 | sujata.chaudhari@weare4c.com 
* =================================================================================================================
*/
@isTest
public inherited sharing class InforCalloutHandlerTest {

    /*
    * Positive:
    *          testInforCallout
    *          testInforCalloutPositive
    * Negative:
    *          testNegativeInforCallout
    *          testInforCalloutNegative
    *          testInforCalloutInvalid
    * Bulk:
    *          testBulkInforCallout
    *          testMaxBulkInforCallout 
    * Null:
    *          testInforCalloutNull
    *          testInforCalloutHtml  
    */

    @isTest
    public static void testInforCallout(){
        testRunner(1, 200, '{ "_StorerKey" : "DEMO2", "_Entity" : "JFK", "_CurrCode" : "USD", "_Country" : "United States of America", "_Company" : "Demo", "_CLoginToken" : { "_UserName" : "wssf", "_PassWord" : "jfhg8.33434o*", "_FacilityStr" : "WMWHSE1" }, "_City" : "Dubai", "_BusinessCategory" : "OTHER", "_BlockStatus" : false }', 
                '{"_HasError":true,"_Result":"OK: Block Status Updated"}', true, false);
    }

    @isTest
    public static void testInforCalloutPositive(){
        testRunner(1, 200, '{ "_StorerKey" : "DEMO2", "_Entity" : "JFK", "_CurrCode" : "USD", "_Country" : "United States of America", "_Company" : "Demo", "_CLoginToken" : { "_UserName" : "wssf", "_PassWord" : "jfhg8.33434o*", "_FacilityStr" : "WMWHSE1" }, "_City" : "Dubai", "_BusinessCategory" : "OTHER", "_BlockStatus" : false }', 
                '{"_HasError":false,"_Result":"OK: Block Status Updated"}', true, false);
    }

    @isTest
    public static void testBulkInforCallout(){
        testRunner(2, 200, '{ "_StorerKey" : "DEMO2", "_Entity" : "JFK", "_CurrCode" : "USD", "_Country" : "United States of America", "_Company" : "Demo", "_CLoginToken" : { "_UserName" : "wssf", "_PassWord" : "jfhg8.33434o*", "_FacilityStr" : "WMWHSE1" }, "_City" : "Dubai", "_BusinessCategory" : "OTHER", "_BlockStatus" : false }',
                '{"_HasError":true,"_Result":"OK: Block Status Updated"}', true, false);
    }

    @isTest
    public static void testMaxBulkInforCallout(){
        testRunner(200, 200,'{ "_StorerKey" : "DEMO2", "_Entity" : "JFK", "_CurrCode" : "USD", "_Country" : "United States of America", "_Company" : "Demo", "_CLoginToken" : { "_UserName" : "wssf", "_PassWord" : "jfhg8.33434o*", "_FacilityStr" : "WMWHSE1" }, "_City" : "Dubai", "_BusinessCategory" : "OTHER", "_BlockStatus" : false }',
                '{"_HasError":true,"_Result":"OK: Block Status Updated"}', true, false);
    }

    @isTest
    public static void testNegativeInforCallout(){
        testRunner(1, 404, '{ "_StorerKey" : "DEMO2", "_Entity" : "JFK", "_CurrCode" : "USD", "_Country" : "United States of America", "_CLoginToken" : { "_UserName" : "wssf", "_PassWord" : "jfhg8.33434o*", "_FacilityStr" : "WMWHSE1" }, "_City" : "Dubai", "_BusinessCategory" : "OTHER", "_BlockStatus" : false }', 
                '{"_Result":"OK: Block Status Updated"}', true, false);
    }

    @isTest
    public static void testInforCalloutInvalid(){
        testRunner(1, 200, '{ "_StorerKey" : "DEMO2", "_Entity" : "JFK", "_CurrCode" : "USD", "_Country" : "United States of America", "_CLoginToken" : { "_UserName" : "wssf", "_PassWord" : "jfhg8.33434o*", "_FacilityStr" : "WMWHSE1" }, "_City" : "Dubai", "_BusinessCategory" : "OTHER", "_BlockStatus" : false }', 
                '{"_HasError":123,"_Result":"OK: Block Status Updated"}', true, false);
    }

    @isTest
    public static void testInforCalloutNegative(){
        testRunner(1, 500, '{ "_StorerKey" : "DEMO2", "_Entity" : "JFK", "_CurrCode" : "SD", "_Country" : "United States of America", "_Company" : "Demo", "_CLoginToken" : { "_UserName" : "wssf", "_PassWord" : "jfhg8.33434o*", "_FacilityStr" : "WMWHSE1" }, "_City" : "Dubai", "_BusinessCategory" : "OTHER", "_BlockStatus" : false }',
                '{"_HasError":false,"_Result":"OK: Block Status Updated"}', false, true);
    }

    @isTest
    public static void testInforCalloutNull(){
        testRunner(1, 200, '{ "_StorerKey" : "DEMO2", "_Entity" : "JFK", "_CurrCode" : "SD", "_Country" : "United States of America", "_Company" : "Demo", "_CLoginToken" : { "_UserName" : "wssf", "_PassWord" : "jfhg8.33434o*", "_FacilityStr" : "WMWHSE1" }, "_City" : "Dubai", "_BusinessCategory" : "OTHER", "_BlockStatus" : false }',
                ' ', false, true);
    }

    @isTest
    public static void testInforCalloutHtml(){
        testRunner(1, 200, '{ "_StorerKey" : "DEMO2", "_Entity" : "JFK", "_CurrCode" : "SD", "_Country" : "United States of America", "_Company" : "Demo", "_CLoginToken" : { "_UserName" : "wssf", "_PassWord" : "jfhg8.33434o*", "_FacilityStr" : "WMWHSE1" }, "_City" : "Dubai", "_BusinessCategory" : "OTHER", "_BlockStatus" : false }',
                '<?xml version="1.0" encoding="UTF-8" ?> <root> 	<_HasError>true</_HasError> 	<_Result>OK: Block Status Updated</_Result> </root>', 
                false, true);
    }

    @testSetup static void testSetupData(){
        Profile p = TestDataUtility.getProfile('Account Manager');
            
        List<User> users = TestDataUtility.createUsers(p.Id, 2);
        insert users;

        Account acc = TestDataUtility.createAccount('test'); 
        acc.OwnerId = users[0].Id; 
        insert acc;

        Asset ast = TestDataUtility.createAsset('test', acc.Id);
        insert ast;

        Integration_Settings__c ins = new Integration_Settings__c();
        ins.Enable_Debug_Logging__c = true;
        insert ins;
    }

    public static void testRunner(Integer numberofRecords, Integer statsCode, String reqBody, String responseBdy,Boolean isSuccess, Boolean isIntegrationRelated){
        List<User> users = [SELECT Id, Name FROM User where isActive=true AND CreatedDate >= TODAY AND 
                            Profile.Name = 'Account Manager'];

        Account acc = [SELECT Id, AccountNumber, CurrencyIsoCode, Entity__c, Legal_City__c, Country_Code__c
                        FROM Account WHERE OwnerId =: users[0].Id LIMIT :numberofRecords];
        //InforCalloutHandler callOutHandler = new InforCalloutHandler(acc.Id);

        Integration_Settings__c ins = [SELECT Enable_Debug_Logging__c FROM Integration_Settings__c];

        Integration_Log__c createLogs = ErrorLogHandler.createLog(acc.Id, 'callout:Infor_Credentials/WS_EDI_TEST_V02/RestService_Users/Storer/UpdateStorer', 
                                            'test', isSuccess, isIntegrationRelated, reqBody, 
                                            responseBdy, statsCode, 'Stacktrace', 'POST'); 
        insert createLogs;                                     

        List<Map<String, String>> headers = new List<Map<String, String>>();
        headers.add(new Map<String, String> {'Content-Type' => 'application/json'});

        HTTPMockFactory serviceMock = new HTTPMockFactory('POST', responseBdy, headers, statsCode);

        Test.setMock(HttpCalloutMock.class, serviceMock);

        Test.startTest();
        
        HttpResponse res = new RestCalloutHandler().restCallout('POST', 'callout:Infor_Credentials/WS_EDI_TEST_V02/RestService_Users/Storer/UpdateStorer',
                                                        headers, responseBdy, createLogs, ins.Enable_Debug_Logging__c);
                                                        
        // System.enqueueJob(callOutHandler);
                                                    
        Test.stopTest();
        
        Integration_Log__c inst = [SELECT Id, Response_Code__c, Response_Body__c FROM Integration_Log__c WHERE Account__c =:acc.Id LIMIT 1];
        System.assertEquals(res.getStatusCode(), inst.Response_Code__c, 'Get Status Code on Successful Callout');
    }
}