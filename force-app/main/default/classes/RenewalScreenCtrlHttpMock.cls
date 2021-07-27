@isTest
global class RenewalScreenCtrlHttpMock implements HttpCalloutMock
{
	global HTTPResponse respond(HTTPRequest req)
    {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        
        if (req.getEndpoint().contains('query/?q=SELECT+id+FROM+blng__Invoice__c'))
            res.setBody('{"totalSize":1}');
        
        return res;
    }
}