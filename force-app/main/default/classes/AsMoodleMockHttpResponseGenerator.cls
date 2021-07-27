@isTest
global class AsMoodleMockHttpResponseGenerator implements HttpCalloutMock {
    
    protected Integer code;
    protected String status;
    protected List<String> bodyAsString;
    
    /**
    * @param code      holds the statusCode
    * @param status    holds the status response
    * @param bodyAsString  holds the response body
    */
    global AsMoodleMockHttpResponseGenerator(Integer code, String status, List<String> bodyAsString) {
        this.code = code;
        this.status = status;
        this.bodyAsString = bodyAsString;
    }
    
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        String body = this.bodyAsString[0];

        //System.assertEquals('https://moodle.alphasys.com.au/webservice/rest/server.php?wstoken={{ token }} &wsfunction={{ function }}&moodlewsrestformat={{ format }}', req.getEndpoint());
        //System.assertEquals('POST', req.getMethod());

        HttpResponse resp = new HttpResponse();

        resp.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        //res.setBody('[{"status": true,"is_created": false,"enrolsfid": "a2cN0000001HyvhIAC","enrolid": 298,"userid": 70,"courseid": 201,"courseurl": "https://moodle.alphasys.com.au/course/view.php?id=201","message": "User successfully enroled"}]');
		
        resp.setStatusCode(code);
        resp.setStatus(status);
        resp.setBody(body);
        return resp;
    }
     

}