/*Author : Ronald Santander
*Description : test class for ASCourseEnrollmentToMoodleBatch
*Date Created : 1/17/2019
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data : ASCourseEnrollmentToMoodleBatch class
*/

@isTest
public class ASCourseEnrollmentToMoodleBatchTest {


	static testMethod void passLMSCourseEnrolment(){
		List<LMS_Instance__c> instancelist = new List<LMS_Instance__c>();
		List<LMS_Course_Enrolment__c> courseEnlist = new List<LMS_Course_Enrolment__c>();

		LMS_Instance__c lmsInstance = new LMS_Instance__c();
		lmsInstance.AS_Instance_Long_Name__c = 'sample instance';
		lmsInstance.Status__c = 'Active';
		lmsInstance.Token__c = '1234567890';
		lmsInstance.Type__c = 'Moodle';
		lmsInstance.Domain_URL__c = 'https://samplewebsite.com';
		lmsInstance.URL__c = 'https://samplewebsite.com';
		instancelist.add(lmsInstance); //insert lmsInstance;

		LMS_Instance__c lmsInstance2 = new LMS_Instance__c();
		lmsInstance2.AS_Instance_Long_Name__c = 'sample instance';
		lmsInstance2.Status__c = 'Active';
		lmsInstance2.Token__c = '1234567890123';
		lmsInstance2.Type__c = 'Moodle';
		lmsInstance2.Domain_URL__c = 'https://samplewebsite.com';
		lmsInstance2.URL__c = 'https://samplewebsite.com';
		instancelist.add(lmsInstance2); //insert lmsInstance2;
		insert instancelist;

		LMS_Course__c lc = new LMS_Course__c();
	    lc.Name = 'test lc';
	    lc.Status__c = 'Active';
	    lc.LMS_Instance__c = lmsInstance.Id;
	    insert lc;//courselist.add(lc); 

	    LMS_User__c lmsuser = new LMS_User__c();
	    lmsuser.FirstName__c = 'test lms user';
	    lmsuser.LastName__c = 'testing';
	    lmsuser.Email__c = 'bannegroupuser@testorg.com';
	    lmsuser.As_Creation_Status__c = 'In Progress';
	    insert lmsuser; //lmsuserlist.add(lmsuser); 
	    //insert lc;

		LMS_Course_Enrolment__c lmscourseEnrol = new LMS_Course_Enrolment__c();
		lmscourseEnrol.LMS_Course__c = lc.Id;
		lmscourseEnrol.LMS_User__c = lmsuser.Id;
		lmscourseEnrol.LMS_Instance__c = lmsInstance.Id;
		lmscourseEnrol.As_Creation_Status__c = 'In Progress';
		courseEnlist.add(lmscourseEnrol); //insert lmscourseEnrol;

		LMS_Course_Enrolment__c lmscourseEnrol2 = new LMS_Course_Enrolment__c();
		lmscourseEnrol2.LMS_Course__c = lc.Id;
		lmscourseEnrol2.LMS_User__c = lmsuser.Id;
		lmscourseEnrol2.LMS_Instance__c = lmsInstance.Id;
		lmscourseEnrol2.As_Creation_Status__c = 'In Progress';
		courseEnlist.add(lmscourseEnrol2);//insert lmscourseEnrol2;

		insert courseEnlist;

		List<LMS_Instance__c> lmsInstanceList = [Select
                                              Id,
                                              Domain_URL__c,
                                              Status__c,
                                              Token__c,
                                              Type__c,
                                              URL__c
                                            from
                                              LMS_Instance__c
                                            where
                                              URL__c != null
                                            and
                                              Token__c != null
                                            ];

    	System.assertEquals(2,lmsInstanceList.size());

		
		
	    

	    test.StartTest();
            Test.setMock(HttpCalloutMock.class, new ASCourseEnrolToMoodleHttpMock());
            
            ASCourseEnrollmentToMoodleBatch courseEnrollmentToMoodle = new ASCourseEnrollmentToMoodleBatch(lmsInstanceList,null);
            Database.executeBatch(courseEnrollmentToMoodle);
	    test.StopTest();
	}

	static testMethod void errorLMSCourseEnrolment(){
		List<LMS_Instance__c> instancelist = new List<LMS_Instance__c>();
		List<LMS_Course_Enrolment__c> courseEnlist = new List<LMS_Course_Enrolment__c>();

		LMS_Instance__c lmsInstance = new LMS_Instance__c();
		lmsInstance.AS_Instance_Long_Name__c = 'sample instance';
		lmsInstance.Status__c = 'Active';
		lmsInstance.Token__c = '1234567890';
		lmsInstance.Type__c = 'Moodle';
		lmsInstance.Domain_URL__c = 'https://samplewebsite.com';
		lmsInstance.URL__c = 'https://samplewebsite.com';
		instancelist.add(lmsInstance); //insert lmsInstance;

		LMS_Instance__c lmsInstance2 = new LMS_Instance__c();
		lmsInstance2.AS_Instance_Long_Name__c = 'sample instance';
		lmsInstance2.Status__c = 'Active';
		lmsInstance2.Token__c = '1234567890123';
		lmsInstance2.Type__c = 'Moodle';
		lmsInstance2.Domain_URL__c = 'https://samplewebsite.com';
		lmsInstance2.URL__c = 'https://samplewebsite.com';
		instancelist.add(lmsInstance2); //insert lmsInstance2;
		insert instancelist;

		LMS_Course__c lc = new LMS_Course__c();
	    lc.Name = 'test lc';
	    lc.Status__c = 'Active';
	    lc.LMS_Instance__c = lmsInstance.Id;
	    insert lc;//courselist.add(lc); 

	    LMS_User__c lmsuser = new LMS_User__c();
	    lmsuser.FirstName__c = 'test lms user';
	    lmsuser.LastName__c = 'testing';
	    lmsuser.Email__c = 'bannegroupuser@testorg.com';
	    lmsuser.As_Creation_Status__c = 'In Progress';
	    insert lmsuser; //lmsuserlist.add(lmsuser); 
	    //insert lc;

		LMS_Course_Enrolment__c lmscourseEnrol = new LMS_Course_Enrolment__c();
		lmscourseEnrol.LMS_Course__c = lc.Id;
		lmscourseEnrol.LMS_User__c = lmsuser.Id;
		lmscourseEnrol.LMS_Instance__c = lmsInstance.Id;
		lmscourseEnrol.As_Creation_Status__c = 'In Progress';
		courseEnlist.add(lmscourseEnrol); //insert lmscourseEnrol;

		LMS_Course_Enrolment__c lmscourseEnrol2 = new LMS_Course_Enrolment__c();
		lmscourseEnrol2.LMS_Course__c = lc.Id;
		lmscourseEnrol2.LMS_User__c = lmsuser.Id;
		lmscourseEnrol2.LMS_Instance__c = lmsInstance.Id;
		lmscourseEnrol2.As_Creation_Status__c = 'In Progress';
		courseEnlist.add(lmscourseEnrol2);//insert lmscourseEnrol2;

		insert courseEnlist;

		List<LMS_Instance__c> lmsInstanceList = [Select
                                              Id,
                                              Domain_URL__c,
                                              Status__c,
                                              Token__c,
                                              Type__c,
                                              URL__c
                                            from
                                              LMS_Instance__c
                                            where
                                              URL__c != null
                                            and
                                              Token__c != null
                                            ];

    	System.assertEquals(2,lmsInstanceList.size());

		
		
	    

	    test.StartTest();
            //Test.setMock(HttpCalloutMock.class, new ASCourseEnrolToMoodleHttpMock());
            
            ASCourseEnrollmentToMoodleBatch courseEnrollmentToMoodle = new ASCourseEnrollmentToMoodleBatch(lmsInstanceList,null);
            Database.executeBatch(courseEnrollmentToMoodle);
	    

			LMS_Course_Enrolment__c lmsCourseEnrolq = [Select
                                              Id 
                                            from
                                              LMS_Course_Enrolment__c LIMIT 1
                                            ];

    
		    PageReference pageRef = Page.ASCourseEnrollmentToMoodlePage;
		    Test.setCurrentPage(pageRef);
		    pageRef.getParameters().put('Id', String.valueOf(lmsCourseEnrolq.Id));
		    ApexPages.StandardController sc = new ApexPages.StandardController(lmsCourseEnrolq);
		    ASCourseEnrollmentToMoodleBatch ext = new ASCourseEnrollmentToMoodleBatch(sc);

		    ext.sendToMoodle();
		test.StopTest();
    
	}
}