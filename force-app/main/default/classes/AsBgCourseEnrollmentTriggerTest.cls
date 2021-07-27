/*Author : John Hope
*Description : This is a test class for AsBgCouAS_BG_Course_Enrolment__c and AsBgCourseEnrollmentTrigger class.
*Date Created : 
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data : AsBgCourseTriggerHandler.cls, AsBgCourseTrigger.trigger
 */
@isTest
private class AsBgCourseEnrollmentTriggerTest {

	static testMethod void isUpdate() {
		AS_BG_Course_Enrolment__c bgEnroll = [Select Id from AS_BG_Course_Enrolment__c where AS_Passed__c = true LIMIT 1];
		bgEnroll.AS_Generate_Certificate__c = true;
		update bgEnroll;
		
	}
	
	
	@TestSetup  
 	static void testData() {
 		Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
		Account acc = new Account();
    acc.FirstName = 'Alpha';
    acc.LastName = 'Sys';
    acc.recordTypeId = personAccRecId;
    acc.PersonEmail = 'bannegroupuser@testorg.com';
    acc.AS_Membership_Status__pc = 'Current';
    acc.AS_AHPRA_Number__pc = '123456789';
    insert acc;
    
    Account forMemMatchCon = [Select Id,PersonContactId from Account where PersonEmail = 'bannegroupuser@testorg.com' LIMIT 1];
    
    Profile p = [SELECT Id FROM Profile WHERE Name='Member Login User'];
    String uniqueUserName1 = 'memberuser' + DateTime.now().getTime() + '@testorg.com';
    
    User use = new User(Alias = 'standt', Email='bannegroupuser@testorg.com',
		EmailEncodingKey='UTF-8', LastName='Sys', LanguageLocaleKey='en_US',
		LocaleSidKey='en_US', ProfileId = p.Id,
		ContactId = forMemMatchCon.PersonContactId,
		TimeZoneSidKey='America/Los_Angeles',
		isActive = true,
		UserName=uniqueUserName1);
		insert use;
		
		// creation of CPD Planner starts here
		AsCPDPlanner__c planner = new AsCPDPlanner__c();
		planner.AsUser__c = use.Id;
		planner.Name = 'ALphasys Planner '+ Date.today().addYears(1).year();
		planner.AS_Current_CPD_Plan__c = true;
		planner.AS_Plan_Year__c = String.valueOf(Date.today().addYears(1).year());
		insert planner;
		// creation of CPD Planner ends here
    
 		Contact con = new Contact();
 		con.FirstName = 'john';
 		con.LastName = 'haskbusk';
 		con.Email = 'haskbusk@gmail.com';
 		con.ASAHPRA_ID__c = '123456789';
 		insert con;
 		
 		LMS_Instance__c lmsInstance = new LMS_Instance__c();
		lmsInstance.AS_Instance_Long_Name__c = 'sample instance';
		lmsInstance.Status__c = 'Active';
		lmsInstance.Token__c = '1234567890';
		lmsInstance.Type__c = 'Moodle';
		lmsInstance.Domain_URL__c = 'https://samplewebsite.com';
		insert lmsInstance;
		
		Id bgCourseRecId = Schema.SObjectType.AS_BG_Course__c.getRecordTypeInfosByName().get('Chemist Warehouse').getRecordTypeId();
		
		List<AS_BG_Course__c> allBgCourse = new List<AS_BG_Course__c>();
		
 		AS_BG_Course__c bgCourse = new AS_BG_Course__c();
		bgCourse.Name = 'BG Course Name';
		bgCourse.AS_Status__c = 'Active';
		bgCourse.LMS_Instance_lookup__c = lmsInstance.Id;
		bgCourse.AS_Course_Type__c = 'CW';
		bgCourse.recordTypeId = bgCourseRecId;
		allBgCourse.add(bgCourse);
		
		AS_BG_Course__c bgCourse2 = new AS_BG_Course__c();
		bgCourse2.Name = 'BG Course Name';
		bgCourse2.AS_Status__c = 'Active';
		bgCourse2.LMS_Instance_lookup__c = lmsInstance.Id;
		bgCourse2.AS_Course_Type__c = 'CW';
		bgCourse2.recordTypeId = bgCourseRecId;
		allBgCourse.add(bgCourse2);
		
		insert allBgCourse;
 		
 		List<AS_BG_Course_Enrolment__c> allBgCourseEnrollment = new List<AS_BG_Course_Enrolment__c>();
 		
 		AS_BG_Course_Enrolment__c enroll = new AS_BG_Course_Enrolment__c();
 		enroll.AS_Contact__c = forMemMatchCon.PersonContactId;
		enroll.AS_Status__c = 'Completed';
		enroll.AS_Banner_Group_Course__c = allBgCourse[0].Id;
		enroll.AS_Passed__c = true;
		enroll.AS_Enrolment_Confirmation_Status__c = 'Confirmed';
		allBgCourseEnrollment.add(enroll);
		
		AS_BG_Course_Enrolment__c enroll2 = new AS_BG_Course_Enrolment__c();
 		enroll2.AS_Contact__c = forMemMatchCon.PersonContactId;
		enroll2.AS_Status__c = 'Completed';
		enroll2.AS_Banner_Group_Course__c = allBgCourse[1].Id;
		enroll2.AS_Passed__c = true;
		enroll2.AS_Enrolment_Confirmation_Status__c = 'Confirmed';
		allBgCourseEnrollment.add(enroll2);
		
		insert allBgCourseEnrollment;
		
		// assertion
	    System.AssertEquals(database.countquery('SELECT '
	           																		+ 'COUNT()'
	              															+' FROM'
	              																+' LMS_User__c '
	              															),1
	              					); 
	  	
	  	System.AssertEquals(database.countquery('SELECT '
	           																		+ 'COUNT()'
	              															+' FROM'
	              																+' LMS_Course_Enrolment__c '
	              															),2
	              					); 
		
 	}
}