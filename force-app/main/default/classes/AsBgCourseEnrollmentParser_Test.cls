@isTest
private  class AsBgCourseEnrollmentParser_Test {
	
	 @isTest static  void testParse() {
		String json = '{ \"strParam\": { \"sfId\" : \"a2jN0000000k9tN\", \"Status\" : \"Fail\" }'+
		''+
		'}';
		AsBgCourseEnrollmentParser obj = AsBgCourseEnrollmentParser.parse(json);
		system.debug(' obj ==> '+ obj); 


		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        System.assert(p != null, 'no Standard User profile found');
        
		LMS_Instance__c li 	= new LMS_Instance__c();
        li.Token__c         = '6d6e009a7317681cad15d8780f1d27cf';
        li.URL__c 			= 'https://moodle.alphasys.com.au/webservice/rest/server.php';
        li.Status__c 		= 'Active';
        li.Type__c 			= 'Moodle';
        li.Domain_URL__c    = 'https://moodle.alphasys.com.au/';
        insert li;
        System.assert(li != null, 'LMS instance is empty');
        
        LMS_User__c lu 		= new LMS_User__c();
        lu.FirstName__c 	= 'test';
        lu.LastName__c 		= 'test';
        lu.Email__c 		= 'test@test.com';
        lu.LMS_Instance__c 	= li.Id;
        insert lu;
        System.assert(lu != null, 'LMS user is empty');

        User u = new User(Alias = 'standt', 
                            Email = 'standarduser@testorg.com', 
                            EmailEncodingKey = 'UTF-8', 
                            FirstName = 'FNtesting',
                            LastName = 'LNtesting', 
                            LanguageLocaleKey = 'en_US', 
                            LocaleSidKey = 'en_US', 
                            ProfileId = p.Id, 
                            TimeZoneSidKey = 'America/Los_Angeles', 
                            UserName = 'standarduser@testusername.com',
                            LMS_User__c = lu.Id);
        insert u;
        System.assert(u != null, 'Standard user is empty');

        AS_BG_Course__c bgCourse = new AS_BG_Course__c();
        bgCourse.Name = 'Test Course';
        bgCourse.AS_Course_Start_Date__c = date.today();
        bgCourse.AS_Course_End_Date__c  = date.today()  + 4 ;
        bgCourse.AS_Status__c  = 'Active';
        bgCourse.LMS_Instance_lookup__c = li.id;
        insert bgCourse;
        System.assert(bgCourse != null, 'LMS instance is empty');

				//AsBgCouresApi test class
			//	AsBgCourseEnrollmentParser.StrParam par = new AsBgCourseEnrollmentParser.StrParam(String.valueOf(bgCourse.Id),'Fail');
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
    
    Profile memPro = [SELECT Id FROM Profile WHERE Name='Member Login User'];
    String uniqueUserName1 = 'memberuser' + DateTime.now().getTime() + '@testorg.com';
    
    User use = new User(Alias = 'standt', Email='bannegroupuser@testorg.com',
		EmailEncodingKey='UTF-8', LastName='Sys', LanguageLocaleKey='en_US',
		LocaleSidKey='en_US', ProfileId = memPro.Id,
		ContactId = forMemMatchCon.PersonContactId,
		TimeZoneSidKey='America/Los_Angeles',
		isActive = true,
		UserName=uniqueUserName1);
		insert use;
		
		// creation of CPD Planner starts here
		AsCPDPlanner__c planner = new AsCPDPlanner__c();
		planner.AsUser__c = use.Id;
		planner.Name = 'ALphasys Planner 2019';
		planner.AS_Current_CPD_Plan__c = true;
		planner.AS_Plan_Year__c = '2019';
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
		
 		AS_BG_Course__c bgCourse2 = new AS_BG_Course__c();
		bgCourse2.Name = 'BG Course Name';
		bgCourse2.AS_Status__c = 'Active';
		bgCourse2.LMS_Instance_lookup__c = lmsInstance.Id;
		bgCourse2.AS_Course_Type__c = 'CW';
		bgCourse2.recordTypeId = bgCourseRecId;
		insert bgCourse2;
 		
 		AS_BG_Course_Enrolment__c enroll = new AS_BG_Course_Enrolment__c();
 		enroll.AS_Contact__c = forMemMatchCon.PersonContactId;
		enroll.AS_Status__c = 'Completed';
		enroll.AS_Banner_Group_Course__c = bgCourse2.Id;
		enroll.AS_Passed__c = true;
		enroll.AS_Enrolment_Confirmation_Status__c = 'Confirmed';
		insert enroll;
		
		AS_BG_Course_Enrolment__c lmsEnr = [Select AS_LMS_Course_Enrolment__c,id from AS_BG_Course_Enrolment__c where Id = :enroll.Id];
		
		String AsBgCouresApiStrParam = '{ \"strParam\": { \"sfId\" : \"'+lmsEnr.AS_LMS_Course_Enrolment__c+'\", \"Status\" : \"Pass\" }'+
		''+
		'}';



        Test.startTest();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/claimApi'; 
            req.params.put('phoneNumber', '9876543210');
            req.params.put('claimNumber', '111111');
            req.httpMethod = 'GET';
            req.addHeader('Content-Type', 'application/json'); 
            RestContext.request = req;
            RestContext.response = res;
 
        Test.stopTest();  

		AsBgCourseEnrollmentParser finalParam = AsBgCourseEnrollmentParser.parse(AsBgCouresApiStrParam);
		AsBgCouresApi.updateObject(finalParam.StrParam);
        //AsBgCouresApi.ResponseWrapper ress = new  AsBgCouresApi.ResponseWrapper();
        //ress.status  = 'Success';
        //ress.message = 'Process is successful'; 
        //ress.resBody = '';


		

	}
}