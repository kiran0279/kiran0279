/**
* @Class Name: HTTPMockFactory
* @Description: For creating response.
* ================================================================================================================
* Version | Date | Author 
* -----------------------------------------------------------------------------------------------------------------
* 1.0 | 12th Feb, 2021 | sujata.chaudhari@weare4c.com 
* =================================================================================================================
*/
@isTest
public class HTTPMockFactory implements HttpCalloutMock {
    protected String method;
    protected List<Map<String, String>> headers; 
    protected String body;
    protected Integer code; 

    public HTTPMockFactory(String method, String body, List<Map<String, String>> headers, Integer code) {
        this.method = method;
        this.headers = headers;
        this.body = body;
        this.code = code;
    }
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        for(Map<String, String> header : headers) {
            for (String key : header.keySet()) {
                res.setHeader(key, header.get(key));
            }
        }
        res.setStatusCode(this.code);
        res.setBody(this.body);
        return res;
    }
}