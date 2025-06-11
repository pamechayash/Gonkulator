@isTest
public class MockHttpResponseGenerator implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        // Create a new HTTPResponse object
        HttpResponse res = new HttpResponse();
        
        // Set the status code to 200 to simulate a successful response
        res.setStatusCode(200);
        
        // Set a properly formatted JSON response body that the real method expects
        res.setBody('{"status": "success", "message": "Mock callout successful!", "response": "Generated code from GPT"}');
        
        // Set the status to 'OK'
        res.setStatus('OK');
        
        return res;
    }
}