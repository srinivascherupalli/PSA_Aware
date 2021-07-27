@isTest
global with sharing class DL_WebServiceMock implements HttpCalloutMock {
    private Boolean throwCalloutException;
    private Integer responseSwitch;
    public DL_WebServiceMock(Boolean throwCalloutException, Integer responseSwitch) {  
      this.throwCalloutException = throwCalloutException;
      this.responseSwitch = responseSwitch;
    } 

    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();

        if (this.throwCalloutException) {
            CalloutException e = new CalloutException();
            e.setMessage('DL_WebServiceMock CalloutException Raised');
            throw e;
        }

        else if(this.responseSwitch == 1){
            Integer randInt = Math.round(Math.random() * 100000);
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"status":true, "message":"success", "Message":"Token valid", "Success":"true", "InProgress":"false", "Response":"'+randInt+'"}');
            response.setStatusCode(200);
        }

        else if(this.responseSwitch == 2){
            Integer randInt = Math.round(Math.random() * 100000);
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"status":true, "message":"success", "Message":"Token valid", "Success":"true", "InProgress":"false", "Response":[20147385,20147386,20147387]}');
            response.setStatusCode(200);
        }

        else if(this.responseSwitch == 3){
            Integer randInt = Math.round(Math.random() * 100000);
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"status":true, "message":"success", "Message":"Token valid", "Success":"true", "InProgress":"false", "Response":[{"SendFaxTransmissionID":0, "Status":"Test Status", "FileName":"Test.pdf", "ToNumber":"777777777", "TransmissionDate":"2019-01-17T04:40:31.539Z", "ClientID":0}]}');
            response.setStatusCode(200);
        }

        return response;
    }

}