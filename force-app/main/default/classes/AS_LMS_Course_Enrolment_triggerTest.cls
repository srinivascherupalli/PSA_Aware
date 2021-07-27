@isTest
private class AS_LMS_Course_Enrolment_triggerTest {
	
	@TestSetup  
 	static void TestData() {
		Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
		Account acc = new Account();
    acc.FirstName = 'Alpha';
    acc.LastName = 'Sys';
    acc.recordTypeId = personAccRecId;
    acc.PersonEmail = 'bannegroupuser@testorg.com';
    acc.AS_Membership_Status__pc = 'Current';
    acc.AS_AHPRA_Number__pc = '123456789';
    insert acc;
        
    Contact con = new Contact();
    con.FirstName 	= 'test';
    con.LastName 		= 'test';
    con.Email 		= 'test@test.com';
    con.ASAHPRA_ID__c = '123456789';
    insert con;
		
		// for banner group starts here
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
    
    LMS_Instance__c lmsInstance = new LMS_Instance__c();
		lmsInstance.AS_Instance_Long_Name__c = 'sample instance';
		lmsInstance.Status__c = 'Active';
		lmsInstance.Token__c = '1234567890';
		lmsInstance.Type__c = 'Moodle';
		lmsInstance.Domain_URL__c = 'https://samplewebsite.com';
		insert lmsInstance;
    
 		AS_BG_Course__c bgCourse = new AS_BG_Course__c();
		bgCourse.Name = 'BG Course Name';
		bgCourse.AS_Status__c = 'Active';
		bgCourse.LMS_Instance_lookup__c = lmsInstance.Id;
		bgCourse.AS_Course_Type__c = 'CW';
		insert bgCourse;
 		
 		AS_BG_Course_Enrolment__c enroll = new AS_BG_Course_Enrolment__c();
 		enroll.AS_Contact__c = forMemMatchCon.PersonContactId;
		enroll.AS_Status__c = 'Completed';
		enroll.AS_Banner_Group_Course__c = bgCourse.Id;
		enroll.AS_Passed__c = true;
		enroll.AS_Enrolment_Confirmation_Status__c = 'Confirmed';
		insert enroll;
    // for banner group ends here
   
		// assertion
    System.AssertEquals(database.countquery('SELECT '
           																		+ 'COUNT()'
              															+' FROM'
              																+' LMS_Course_Enrolment__c '
              															),1
              					); 
	}	
	
	static testMethod void updateLearAss() {
	test.StartTest();
		List<LMS_Course_Enrolment__c> lmsCourseEnroll = [Select 
																	Id
																from 
																	LMS_Course_Enrolment__c 
																];
		System.debug('lmsCourseEnroll : ' + lmsCourseEnroll.size() + lmsCourseEnroll);
		
		//Create admin users
    List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
    List<User> lmsUsers = TestUtilClass.createUsers(5,'Standard User');

    System.runAs(adminUsers.get(0)){
    //Assign corresponding perm sets
    TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
    TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
    }

    TestTrainingPlanData.createSampleData();
    List<Training_Plan__c> tplan = [select id from Training_Plan__c];
    List<Training_Plan_Section__c> ltpsec = [select id from Training_Plan_Section__c where Training_Plan__c =: tplan.get(0).Id order by Order__c asc];
    LMS_Instance__c li 	= [Select Id from LMS_Instance__c LIMIT 1];
    Contact con 	= [Select Id from Contact LIMIT 1];
    
    LMS_Course__c lc = new LMS_Course__c();
    lc.Name = 'test lc';
    lc.Status__c = 'Active';
    lc.LMS_Instance__c = li.Id;
    insert lc;
        
    Learning__c learn = new Learning__c();
    learn.name ='test learning';
    learn.AS_Group_1_CPD__c = 20;
    learn.AS_Group_2_CPD__c = 10;
    insert learn;
    
    Learning_Assignment__c leaAss = new Learning_Assignment__c();
    leaAss.LMS_Course_Enrolment__c = lmsCourseEnroll[0].Id;
    leaAss.Learning__c = learn.Id;
    leaAss.User__c = lmsUsers[0].Id;
    leaAss.Contact__c = con.Id;
    leaAss.Training_Plan__c=tplan[0].Id;
    leaAss.Training_Plan_Section__c =ltpsec[0].Id;
    insert leaAss; 
    
     
    
	    List<LMS_Course_Enrolment__c> allLCE = new List<LMS_Course_Enrolment__c>();
	    
	    LMS_Course_Enrolment__c lce = new LMS_Course_Enrolment__c();
	    lce.Id = lmsCourseEnroll[0].Id;
	    lce.Completion_Status__c = 'Pass';
	    lce.AS_Completed_Status__c = true;
	    allLCE.add(lce);
	    /*
	    LMS_Course_Enrolment__c lce2 = new LMS_Course_Enrolment__c();
	    lce2.Id = lmsCourseEnroll[0].Id;
	    lce2.Completion_Status__c = 'Fail';
	    lce2.AS_Completed_Status__c = true;
	    allLCE.add(lce2);
	    */
	    update allLCE;
    test.StopTest();
    
    // assertion
    System.AssertEquals(database.countquery('SELECT '
           																		+ 'COUNT()'
              															+' FROM'
              																+' LMS_Course_Enrolment__c '
              															),1
              					); 
		
	}
	
	static testMethod void isDelete() {
		LMS_Course_Enrolment__c lmsCourseEnroll = [Select 
																	Id
																from 
																	LMS_Course_Enrolment__c 
																LIMIT 1
																];
		delete lmsCourseEnroll;
		
		// assertion
    System.AssertEquals(database.countquery('SELECT '
           																		+ 'COUNT()'
              															+' FROM'
              																+' LMS_Course_Enrolment__c '
              															),0
              					); 
	}
	
	static testMethod void isUndelete() {
		LMS_Course_Enrolment__c lmsCourseEnroll = [Select 
																	Id
																from 
																	LMS_Course_Enrolment__c 
																LIMIT 1
																];
		delete lmsCourseEnroll;
		
		undelete lmsCourseEnroll;
		
		// assertion
    System.AssertEquals(database.countquery('SELECT '
           																		+ 'COUNT()'
              															+' FROM'
              																+' LMS_Course_Enrolment__c '
              															),1
              					); 
	}
}