/**
 * @description Class for generating generic Mock HTTP response
 * 
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                      |
      |---------------------------|-----------------------|--------------|-----------------------------------------------------|
      | mark.j.mahilum            | May 29, 2024          | DEPP-8954    | Created file                                        |
 */
@isTest
public class GenericHttpCalloutMock implements HttpCalloutMock{
    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;
    
    public GenericHttpCalloutMock (Integer code, String status, String body) {       
        this.code = code;
        this.status = status;
        this.body = body ;
        this.responseHeaders = responseHeaders;
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(this.code);
        response.setStatus(this.status);
        response.setBody(this.body);
        return response;
    }
}