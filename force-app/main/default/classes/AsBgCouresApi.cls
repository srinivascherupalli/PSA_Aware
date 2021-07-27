@RestResource(urlMapping='/MoodleCourseCompletion')
global with sharing class AsBgCouresApi  {

	/*
  * Author : Jet R. Compayan
  * Description: This is the Api to update the Bg Course Enrollment and Lms Course Enrollement to Pass to Faill of the Status (ticket # PSA-100)
  * Parameter :
  * Return : None
  */
	@HttpPost
	global static ResponseWrapper updateObject( AsBgCourseEnrollmentParser.StrParam strParam  ) {

		RestRequest req  = RestContext.request; 
		RestResponse res = RestContext.response;

		Id lmsCourseEnId = strParam.sfId; //the Id of BG Course Enrollment 
		String bgCourseEnStatus = strParam.Status;  //the Status Fail or Pass

		LMS_Course_Enrolment__c lmsCourseEn = new LMS_Course_Enrolment__c();
		lmsCourseEn.Id = lmsCourseEnId;
		lmsCourseEn.Completion_Status__c = bgCourseEnStatus;
		lmsCourseEn.AS_Completed_Status__c  = true;

		update lmsCourseEn;

		ResponseWrapper response = new ResponseWrapper();

		res.StatusCode   = 200;
		response.status  = 'Success';
		response.message = 'Process is successful'; 
		response.resBody = '';
		return response;

	}


	global class ResponseWrapper {
		
	    public String status;
	    public String message;
	    public String resBody; 

	    public ResponseWrapper() {}

    }

   }