/**
* @Class Name: ErrorLogHandler
* @Description: To Create Integration Logs.
* ================================================================================================================
* Version | Date | Author | Comments
* -----------------------------------------------------------------------------------------------------------------
* 1.0 | 2st Feb, 2021 | sujata.chaudhari@weare4c.com | 1. This class is used by RestCalloutHandler.
* =================================================================================================================
*/
public with sharing class ErrorLogHandler {
    public static Integration_Log__c createLog(Id Account, String endpoint, String errorMessage,
                                    Boolean isSuccess, Boolean isIntegrationRelated, String requestBody,
                                    String responseBody, Integer responseCode, String stacktrace, String method) {
        Integration_Log__c errorlog = new Integration_Log__c();
                            errorlog.Account__c = Account;
                            errorlog.Endpoint__c = endpoint;
                            errorlog.Error_Message__c = errorMessage;
                            errorlog.Is_Success__c = isSuccess; 
                            errorlog.Is_Integration_Related__c = isIntegrationRelated;
                            errorlog.Request_Body__c = requestBody;
                            errorlog.Response_Body__c = responseBody;
                            errorlog.Response_Code__c = responseCode;
                            errorlog.Stacktrace__c = stacktrace;
                            errorlog.Method__c = method;                                       
                            return errorlog;
    }

    public static Integration_Log__c updateLog(Integration_Log__c errorlog, String errorMessage,
                                                String endpoint, Boolean isSuccess, Boolean isIntegrationRelated, String requestBody,
                                                List<Map<String, String>> requestHeaders, String responseBody, Integer responseCode,
                                                String method) {
                                    
        errorlog.Error_Message__c = errorMessage;
        errorlog.Endpoint__c = endpoint;
        errorlog.Is_Success__c = isSuccess;
        errorlog.Is_Integration_Related__c = isIntegrationRelated;
        errorlog.Request_Body__c = requestBody;
        errorlog.Request_Headers__c = JSON.serializePretty(requestHeaders);
        errorlog.Response_Body__c = responseBody;
        errorlog.Response_Code__c = responseCode;
        errorlog.Method__c = method;
        return errorlog;
    }   
}