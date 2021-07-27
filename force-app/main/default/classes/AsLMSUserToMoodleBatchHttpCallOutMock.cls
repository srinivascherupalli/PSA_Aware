/*
*Author : Michael Vincent Largo
*Description : Fake response HttpCallOutMock for json format
*Date Created : 01/15/2019
*Last Modified By: Deadz 
*Date Last Modified: 01/15/2019
*Related Metadata : None 
*Action : Fake response
*Param : HTTPRequest req
*Return : res
*/

@isTest
global class AsLMSUserToMoodleBatchHttpCallOutMock implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response

        HttpResponse res = new HttpResponse();

        res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        res.setBody('[{"status": true,"is_created": false,"sf_id": "a2fN0000000yUen","userid": 75}]');
        res.setStatusCode(200);
        return res;
    }
}