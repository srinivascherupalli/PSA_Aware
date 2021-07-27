/*Author : Ronald Santander
*Description : test class for fake response
*Date Created : 1/23/2019
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data : 
*/
@isTest
global class ASCourseEnrolToMoodleHttpMock implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response

        //System.assertEquals('https://moodle.alphasys.com.au/webservice/rest/server.php?wstoken={{ token }} &wsfunction={{ function }}&moodlewsrestformat={{ format }}', req.getEndpoint());
        //System.assertEquals('POST', req.getMethod());


        HttpResponse res = new HttpResponse();

        res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        res.setBody('[{"status": true,"is_created": false,"enrolsfid": "a2cN0000001HyvhIAC","enrolid": 298,"userid": 70,"courseid": 201,"courseurl": "https://moodle.alphasys.com.au/course/view.php?id=201","message": "User successfully enroled"}]');
        res.setStatusCode(200);
        return res;
    }
}