@isTest
global class AS_PSA_CustomLogoutHttpCalloutMock implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
      
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"email":"john@alphasys.com.au"}');
        res.setStatusCode(200);
        return res;
    }
    
}