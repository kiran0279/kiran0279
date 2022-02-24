/**
* @Class Name: RestCalloutHandler
* @Description: API Callout.
* ================================================================================================================
* Version | Date | Author | Comments
* -----------------------------------------------------------------------------------------------------------------
* 1.0 | 2st Feb, 2021 | sujata.chaudhari@weare4c.com | 1. This class is used by RestCalloutHandler.
* =================================================================================================================
*/

public with sharing class RestCalloutHandler {
    public static String GET = 'GET';
    public static String POST = 'POST';
    public HttpResponse restCallout(String method, String url, List<Map<String, String>> headers, String body, Integration_Log__c errorLog, Boolean enableDebugLog){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod(method);
        request.setBody(body);
        request.setTimeout(60000);
        
        for(Map<String, String> header : headers) {
            for(String key : header.keySet()) {
                request.setHeader(key, header.get(key));
            }
        }

        HttpResponse response = http.send(request);
        return response;
    }   
}