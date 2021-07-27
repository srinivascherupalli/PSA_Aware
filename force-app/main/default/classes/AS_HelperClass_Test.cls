@IsTest(SeeAllData=false)
public class AS_HelperClass_Test {

	private static Id createUser(){
		Profile p = [SELECT Id FROM Profile WHERE Name='Member Login User']; 

		Account a = new Account(Name='testAcc', AS_Unique_Student_Identifier__c = '1212');
		insert a;

        Contact c = new Contact(LastName='test',AccountId=a.Id);
        insert c;

        User u = new User(Alias = 'standt', 
                            Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', 
                            FirstName='FNtesting',
                            LastName='LNtesting', 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', 
                            UserName='standarduser@testorg.com',
                            ContactId=c.Id);
        insert u;
        
        // for isUserMember test
        AS_HelperClass.isUserMember(u.Id);
        
        return u.Id;
    }
    
    static testMethod void test_TrainingPlanRegisterHelper() {
        PriceBook2 pb = new PriceBook2(Name='PSA Member',IsActive=true);
        insert pb;
        
        Product2 prod = new Product2(Name = 'Test', ProductCode = 'test123', IsActive = true);
        insert prod;
        System.assert(prod != null, 'Product is empty');
        
        Id pricebookId = Test.getStandardPricebookId();        
        System.assert(pricebookId != null, 'StandardPricebookId is empty');
        
        List<PricebookEntry> allPbe = new List<PricebookEntry>();
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, 
                                                Product2Id = prod.Id,
                                                UnitPrice = 200, 
                                                IsActive = true);
        allPbe.add(pbe);
        
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = pb.Id, 
                                                 Product2Id = prod.Id,
                                                 UnitPrice = 200, 
                                                 IsActive = true);
        allPbe.add(pbe2);
        insert allPbe;
        
        Training_Plan__c tp 			= new Training_Plan__c();
        tp.Name 						= 'test tp';
        tp.Status__c 					= 'Active';
        tp.Type__c 						= 'Member Benefit'; 
        tp.Enable_Self_Registration__c 	= true;
        tp.Self_Registration_Access__c 	= 'External';
        tp.AS_Product__c 				= prod.Id;
        insert tp;
        
        AS_HelperClass.TrainingPlanRegisterHelper(createUser(), prod.Id, '' );
        
    }
      
    static testMethod void test_TrainingPlanPreviewValidation(){
        AS_HelperClass.TrainingPlanPreviewValidation(createUser());
    }
    
    static testMethod void test_UpdateRequestApproveHelper(){
        Learning__c l 		= new Learning__c();
        l.Name 				= 'test l';
        l.AS_Group_1_CPD__c = 100;
        l.AS_Group_2_CPD__c = 200;
        l.Published__c 		= true;
        insert l;
        
        Map<Id, Learning__c> newMapLearning = new Map<Id, Learning__c>();
        newMapLearning.put(l.Id, l);
        
        Training_Plan__c tp 			= new Training_Plan__c();
        tp.Name 						= 'test tp';
        tp.Status__c 					= 'Active';
        tp.Type__c 						= 'Member Benefit';
        tp.Enable_Self_Registration__c 	= true;
        tp.Self_Registration_Access__c 	= 'External';
        insert tp;
        
        Training_Plan_Section__c tps 	= new Training_Plan_Section__c();
        tps.Name 						= 'test tps';
        tps.Training_Plan__c			= tp.Id;
        insert tps;
        
        Training_Plan_Section_Item__c tpsi 	= new Training_Plan_Section_Item__c();
        tpsi.Learning__c 					= l.Id;
        tpsi.Training_Plan_Section__c 		= tps.Id;
        insert tpsi;

        Training_Plan_Access_Request__c AsTplanAccess = new Training_Plan_Access_Request__c(
            Training_Plan__c = tp.Id,
            Status__c = 'Pending'
        );
        insert AsTplanAccess;
        
        
        AS_HelperClass.UpdateRequestApproveHelper(newMapLearning, new Set<Id>(), null, null);
    }
    
    static testMethod void test_LearningAssignmentTriggerHelper_AND_LMS_Integration_LearningAssignment(){
        Id uId = createUser();
        
        Learning__c l 		= new Learning__c();
        l.Name 				= 'test l';
        l.AS_Group_1_CPD__c = 100;
        l.AS_Group_2_CPD__c = 200;
        l.Published__c 		= true;
        insert l;
        
        Training_Plan__c tp 			= new Training_Plan__c();
        tp.Name 						= 'test tp';
        tp.Status__c 					= 'Active';
        tp.Type__c 						= 'Member Benefit';
        tp.Enable_Self_Registration__c 	= true;
        tp.Self_Registration_Access__c 	= 'External';
        insert tp;
        
        Training_Plan_Section__c tps 	= new Training_Plan_Section__c();
        tps.Name 						= 'test tps';
        tps.Training_Plan__c 			= tp.Id;
        insert tps;
        
        Training_Plan_Section_Item__c tpsi 	= new Training_Plan_Section_Item__c();
        tpsi.Learning__c 					= l.Id;
        tpsi.Training_Plan_Section__c 		= tps.Id;
        insert tpsi;
        
        Training_Plan_Assignment__c tpa = new Training_Plan_Assignment__c();
        tpa.Training_Plan__c 			= tp.Id;
        tpa.User__c 					= uId;
        insert tpa;
        
        Training_Plan_Section_Assignment__c tpsa 	= new Training_Plan_Section_Assignment__c();
        tpsa.Training_Plan_Assignment__c 			= tpa.Id;
        tpsa.Training_Plan_Section__c 				= tps.Id;
        tpsa.User__c 								= uId;
        insert tpsa;
        
        Learning_Assignment__c la 				= new Learning_Assignment__c();
        la.Learning__c 							= l.Id;
        la.Training_Plan__c 					= tp.Id;
        la.Training_Plan_Section__c 			= tps.Id;
        la.Training_Plan_Section_Item__c 		= tpsi.Id;
        la.Training_Plan_Section_Assignment__c 	= tpsa.Id;
        la.User__c 								= uId;
        insert la;
        
        AS_HelperClass.LearningAssignmentTriggerHelper(new List<Learning_Assignment__c>{ la });
        AS_HelperClass.LMS_Integration_LearningAssignment(new List<Learning_Assignment__c>{ la }, 'after insert');
    }
    
    static testMethod void test_LearningEventRecType(){
        AS_HelperClass.LearningEventRecType('Event', 'https://www.google.com/');
    }
    
    static testMethod void test_LMS_Integration_Learning(){
        LMS_Instance__c li 	= new LMS_Instance__c();
        li.Token__c 		= '6d6e009a7317681cad15d8780f1d27cf';
        li.URL__c 			= 'https://moodle.alphasys.com.au/webservice/rest/server.php';
        li.Status__c 		= 'Active';
        li.Type__c 			= 'Moodle';
        li.Domain_URL__c 			= 'https://moodle.alphasys.com.au/webservice/rest/server.php';
        insert li;
        
        Learning__c l 		= new Learning__c();
        l.Name 				= 'test l';
        l.AS_Group_1_CPD__c = 100;
        l.AS_Group_2_CPD__c = 200;
        l.Published__c 		= true;
        l.LMS_Instance__c 	= li.Id;
        insert l;
        
        AS_HelperClass.LMS_Integration_Learning(new List<Learning__c>{ l }, 'before');
    }
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            
            //System.assertEquals('http://api.salesforce.com/foo/bar', req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"foo":"bar"}');
            res.setStatusCode(200);
            return res;
        }
    } 
    
    @isTest static void testCallout() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        LMS_Course__c lc    = new LMS_Course__c();
        lc.Name             = 'test';
        lc.Date__c          = date.today();
        lc.Status__c        = 'Active';
        insert lc; 
    }   

    static testMethod void test_CampaignMemberTriggerHelper(){
        Training_Plan__c tp 			= new Training_Plan__c();
        tp.Name 						= 'test tp';
        tp.Status__c 					= 'Active';
        tp.Type__c 						= 'Member Benefit';
        tp.Enable_Self_Registration__c 	= true;
        tp.Self_Registration_Access__c 	= 'External';
        insert tp;
        
        AS_Event__c evt = new AS_Event__c();
        evt.Name = 'test';
        insert evt;


        Campaign cam = new Campaign();
    	cam.Name = 'Alphasys Campaign';
    	cam.Training_Plan__c = tp.Id;
        cam.AS_Event__c = evt.Id;
		insert cam;
			
		Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
		Account acc = new Account();
	    acc.FirstName = 'Alpha';
	    acc.LastName = 'Sys';
        acc.recordTypeId = personAccRecId;
        acc.AS_Unique_Student_Identifier__c = '1212';
        acc.PersonEmail = 'bannegroupuser@testorg.com';
	    acc.AS_Membership_Status__pc = 'Current';
	    acc.AS_AHPRA_Number__pc = '123456789';
	    insert acc;
     	
   	    Account forMemMatchCon = [Select Id,PersonContactId,AS_Unique_Student_Identifier__c from Account where PersonEmail = 'bannegroupuser@testorg.com' LIMIT 1];
     	
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
                    
        List<CampaignMember> allCamMem = new List<CampaignMember>();
        
        CampaignMember camMem = new CampaignMember();
        camMem.ContactId = forMemMatchCon.PersonContactId;
        camMem.CampaignId = cam.Id;
        camMem.Status ='Attending';
        allCamMem.add(camMem);
        
        insert allCamMem;
        
        AS_HelperClass.CampaignMemberTriggerHelper(allCamMem);
        
        CampaignMember updateCam = new CampaignMember();
        updateCam.Id = allCamMem[0].Id;
        updateCam.Status ='Checked In';
        update updateCam;

    }

    static testMethod void test_createLmsCourseEnrollment(){
    	Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
		Account acc = new Account();
        acc.AS_Unique_Student_Identifier__c = '1212';
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
			planner.Name = 'ALphasys Planner' + Date.today().Year()+1;
			planner.AS_Current_CPD_Plan__c = true;
			planner.AS_Plan_Year__c = String.valueOf(Date.today().Year()+1);
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
        
        LMS_Course__c lMSC    = new LMS_Course__c();
        lMSC.Name             = 'test';
        lMSC.AsMoodleResponse__c = 'Course successfully created';
        lMSC.Moodle_Course_Id__c = '87';
        lMSC.LMS_Instance__c  = lmsInstance.Id;
        lMSC.Date__c          = date.today();
        lMSC.Status__c        = 'Active';
        insert lMSC; 
        
        Id learnmoodlerecId = Schema.SObjectType.Learning__c.getRecordTypeInfosByName().get('Moodle').getRecordTypeId();
        Learning__c learnCourse = new Learning__c();
        learnCourse.Name = 'Learning Name';
        learnCourse.AS_LMS_type__c = 'Course';
        learnCourse.RecordTypeId = learnmoodlerecId;
        learnCourse.LMS_Instance__c = lmsInstance.Id;
        learnCourse.LMS_Course__c = lMSC.Id;
        learnCourse.Published__c = true;
        insert learnCourse;
        
        Id learnmoodlerecIdactivity = Schema.SObjectType.Learning__c.getRecordTypeInfosByName().get('Moodle').getRecordTypeId();
        Learning__c learnActivity = new Learning__c();
        learnActivity.RecordTypeId = learnmoodlerecIdactivity;
        learnActivity.Name = 'Learning Activity';
        learnActivity.AS_LMS_type__c = 'Course';
        //learnActivity.AS_Activity_Type__c = 'Quiz'; 
        learnActivity.LMS_Instance__c = lmsInstance.Id;
        learnActivity.LMS_Course__c = lMSC.Id;
        learnActivity.Published__c = true;
        insert learnActivity;
			
			// create Training_Plan__c
			List<Training_Plan__c> allTp = new List<Training_Plan__c>();
			
			Training_Plan__c tp 			= new Training_Plan__c();
	    tp.Name 						= 'test tp';
	    tp.Status__c 					= 'Active';
	    tp.Type__c 						= 'Member Benefit';
	    tp.Enable_Self_Registration__c 	= true;
	    tp.Self_Registration_Access__c 	= 'External';
	    allTp.add(tp);
	    
	    Training_Plan__c tp2 			= new Training_Plan__c();
	    tp2.Name 						= 'test tp';
	    tp2.Status__c 					= 'Active';
	    tp2.Type__c 						= 'Member Benefit';
	    tp2.Enable_Self_Registration__c 	= true;
	    tp2.Self_Registration_Access__c 	= 'External';
	    allTp.add(tp2);
	    
	    insert allTp;
	    // create Training_Plan__c
	    
	    
	    // create Training_Plan_Section__c
	    List<Training_Plan_Section__c> allTPSec = new List<Training_Plan_Section__c>();
	    
	    Training_Plan_Section__c tps 	= new Training_Plan_Section__c();
	    tps.Name 						= 'test tps';
	    tps.Training_Plan__c			= allTp[0].Id;
	    allTPSec.add(tps);
	    
	    Training_Plan_Section__c tps2 	= new Training_Plan_Section__c();
	    tps2.Name 						= 'test tps';
	    tps2.Training_Plan__c			= allTp[1].Id;
	    allTPSec.add(tps2);
	    
	    insert allTPSec;
	    // create Training_Plan_Section__c
	    
	    // create Training_Plan_Assignment__c
	    List<Training_Plan_Assignment__c> allTPAssign = new List<Training_Plan_Assignment__c>();
	    
	    Training_Plan_Assignment__c tpa = new Training_Plan_Assignment__c();
	    tpa.Training_Plan__c 			= allTp[0].Id;
	    tpa.User__c 					= use.Id;
	    tpa.Status__c = 'Complete';
	    allTPAssign.add(tpa);
	    
	    Training_Plan_Assignment__c tpa2 = new Training_Plan_Assignment__c();
	    tpa2.Training_Plan__c 			= allTp[1].Id;
	    tpa2.User__c 					= use.Id;
	    tpa2.Status__c = 'Complete';
	    allTPAssign.add(tpa2);
	    
	    insert allTPAssign;
	    // create Training_Plan_Assignment__c
	    
	    // create Training_Plan_Section_Assignment__c
	    List<Training_Plan_Section_Assignment__c> allTPSecAssign = new List<Training_Plan_Section_Assignment__c>();
	    
	    Training_Plan_Section_Assignment__c tpsa 	= new Training_Plan_Section_Assignment__c();
	    tpsa.Training_Plan_Assignment__c 			= allTPAssign[0].Id;
	    tpsa.Training_Plan_Section__c 				= allTPSec[0].Id;
	    tpsa.User__c 								= use.Id;
	    allTPSecAssign.add(tpsa);
	    
	    Training_Plan_Section_Assignment__c tpsa2 	= new Training_Plan_Section_Assignment__c();
	    tpsa2.Training_Plan_Assignment__c 			= allTPAssign[0].Id;
	    tpsa2.Training_Plan_Section__c 				= allTPSec[0].Id;
	    tpsa2.User__c 								= use.Id;
	    allTPSecAssign.add(tpsa2);
	    
	    insert allTPSecAssign;
	    // create Training_Plan_Section_Assignment__c
			
			// create Learning_Assignment__c
			List<Learning_Assignment__c> allLearnAssign = new List<Learning_Assignment__c>();
			
	 		Learning_Assignment__c enroll = new Learning_Assignment__c();
	 		enroll.Contact__c = forMemMatchCon.PersonContactId;
			enroll.Learning__c = learnCourse.Id;
			enroll.AS_Passed__c = true;
			enroll.User__c = use.Id;
			enroll.Training_Plan__c = allTp[0].Id;
			enroll.Training_Plan_Section__c = allTPSec[0].Id;
			enroll.Training_Plan_Section_Assignment__c = allTPSecAssign[0].Id;
			allLearnAssign.add(enroll);
			
			Learning_Assignment__c enroll2 = new Learning_Assignment__c();
	 		enroll2.Contact__c = forMemMatchCon.PersonContactId;
			enroll2.Learning__c = learnCourse.Id;
			enroll2.AS_Passed__c = true;
			enroll2.User__c = use.Id;
			enroll2.Training_Plan__c = allTp[1].Id;
			enroll2.Training_Plan_Section__c = allTPSec[0].Id;
			enroll2.Training_Plan_Section_Assignment__c = allTPSecAssign[1].Id;
			allLearnAssign.add(enroll2);
			insert allLearnAssign;
			// create Learning_Assignment__c
		
        LMS_Instance__c lmsInstancenew = new LMS_Instance__c();
        lmsInstancenew.AS_Instance_Long_Name__c = 'sample instance';
        lmsInstancenew.Status__c = 'Active';
        lmsInstancenew.Token__c = '1234567890';
        lmsInstancenew.Type__c = 'Moodle';
        lmsInstancenew.Domain_URL__c = 'https://samplewebsite.com';
        insert lmsInstancenew;
		
        LMS_User__c lmsUser = new LMS_User__c();
        lmsUser.AS_Banner_Group_Contact__c = use.ContactId;
        lmsUser.LMS_Instance__c = lmsInstancenew.Id; 
        lmsUser.As_Creation_Status__c = 'Success';
        lmsUser.Moodle_User_Id__c = '29';
        insert lmsUser;
      
        LMS_Course_Enrolment__c lmscourseenrol = new LMS_Course_Enrolment__c();
        lmscourseenrol.Completion_Status__c = 'Pass';
        lmscourseenrol.Start_Date__c = Date.Today();
        lmscourseenrol.LMS_Course__c = lMSC.Id;
        lmscourseenrol.LMS_Instance__c = lmsInstancenew.Id;
        lmscourseenrol.LMS_User__c = lmsUser.Id;
        insert lmscourseenrol;
        
        // assertion
         System.AssertEquals(database.countquery('SELECT '
                                                + 'COUNT()'
                                                +' FROM'
                                                +' LMS_User__c '
                                                +'WHERE As_Creation_Status__c = \'Success\''),1);

		  System.AssertEquals(database.countquery('SELECT '
                                                + 'COUNT()'
                                                +' FROM'
                                                +' LMS_Course_Enrolment__c '
                                                +'WHERE Completion_Status__c = \'Pass\''),1);


	  	
    }

    
    /*test class added by vincent for PRI 41/PRI69 TICKET in
AS_Learning_Trigger_Handler.CreateLmsActBaseOnLearning();*/
    static testMethod void CreateLmsActBaseOnLearning() {
        
        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        Account acc = new Account();
        acc.FirstName = 'Sample Person';
        acc.LastName = 'Account';
        acc.PersonEmail = 'person@test.com';
        acc.RecordTypeId = personAccountId;
        acc.AS_Unique_Student_Identifier__c = '12312';
        insert acc;

        // Contact conn = new Contact(
        //     FirstName = 'Test Contact',
        //     LastName = 
        // );
        
        List<Profile> pro = [Select Id,Name from Profile where Name='Member Login User' LIMIT 1];
        Account accToUsed = [Select Id,PersonContactId from Account where Id = :acc.Id limit 1];
        
        User indiUser = new User();
  		indiUser.ContactId = accToUsed.PersonContactId;
        indiUser.profileid = (pro.size() > 0)?pro[0].Id:null;
        indiUser.FirstName = acc.FirstName;
        indiUser.LastName = acc.LastName;
        indiUser.Alias =string.valueof(acc.FirstName.substring(0,1) + acc.LastName.substring(0,2));
        indiUser.Email = 'person@test.com';
        indiUser.Username = 'person@test.com';
        indiUser.CommunityNickname = acc.FirstName + acc.LastName + AS_commonFunction.generateRandomIntString(2);
        indiUser.emailencodingkey='UTF-8';
        indiUser.languagelocalekey='en_US'; 
        indiUser.localesidkey='en_AU'; 
        indiUser.timezonesidkey='GMT';
        insert indiUser;
        
        LMS_Instance__c	 LmsInstance = new LMS_Instance__c();
        LmsInstance.Type__c = 'Moodle';
        LmsInstance.Date__c = Date.today();
        LmsInstance.Status__c = 'Active';
        LmsInstance.Token__c = '1234567890';
        LmsInstance.Domain_URL__c = 'https://samplewebsite.com';
        LmsInstance.URL__c = 'https://lms.alphasys.com.au/moodle/';
        insert LmsInstance;
        
        LMS_User__c lmsUser = new LMS_User__c();
        lmsUser.AS_Banner_Group_Contact__c = indiUser.ContactId;
        lmsUser.LMS_Instance__c = LmsInstance.Id; 
        lmsUser.As_Creation_Status__c = 'Success';
        lmsUser.Moodle_User_Id__c = '29';
        insert lmsUser;
        
        
        LMS_Course__c lc    = new LMS_Course__c();
        lc.Name             = 'test';
        lc.Date__c          = date.today();
        lc.Status__c        = 'Active';
        lc.LMS_Instance__c = LmsInstance.Id;
        lc.AsMoodleResponse__c = 'Course successfully created';
        lc.Moodle_Course_Id__c = '104';
        insert lc; 
        
        Training_Plan__c tplan = new Training_Plan__c();
        tplan.AS_Training_Plan_Type__c = 'Australian Pharmacist';
        tplan.Name = 'Testing TPlan';
        tplan.Type__c = 'Public';
        tplan.Status__c = 'Active';
        tplan.AS_LMS__c = 'Moodle Course';
        tplan.AS_LMS_Instance__c = LmsInstance.Id;
        insert tplan;
        
        Training_Plan_Assignment__c tplanAss = new Training_Plan_Assignment__c();
        tplanAss.User__c = indiUser.Id;
        tplanAss.Status__c = 'Not Started';
        tplanAss.Training_Plan__c = tplan.Id;
        insert tplanAss;
            
       Id learnmoodlerecIdactivity = Schema.SObjectType.Learning__c.getRecordTypeInfosByName().get('Moodle').getRecordTypeId();
        
        Learning__c learn 		= new Learning__c();
        learn.RecordTypeId = learnmoodlerecIdactivity;
        learn.Name = 'Learning Activity';
        learn.AS_Group_1_CPD__c = 100;
        learn.AS_Group_2_CPD__c = 200;
        learn.AS_LMS_type__c   	= 'Activity';
        learn.AS_Activity_Type__c = 'Lesson';
        learn.LMS_Instance__c = LmsInstance.Id;
        learn.AS_Training_Plan__c = tplan.Id;
        learn.Description__c = 'test2132';
        learn.Published__c 		= true;
        insert learn;
        
        Training_Plan_Section__c tps 	= new Training_Plan_Section__c();
        tps.Name 						= 'test tps';
        tps.Training_Plan__c 			= tplan.Id;
        insert tps;
        
        Training_Plan_Section_Assignment__c tpsa 	= new Training_Plan_Section_Assignment__c();
        tpsa.Training_Plan_Assignment__c 			= tplanAss.Id;
        tpsa.User__c 								= indiUser.Id;
        tpsa.Training_Plan_Section__c				= tps.Id;
        insert tpsa;
        
        Learning_Assignment__c learnaAss = new Learning_Assignment__c();
        learnaAss.Learning__c = learn.Id; 
        learnaAss.AS_Passed__c = true;
        learnaAss.Progress__c = 'Completed';
        learnaAss.Training_Plan_Section_Assignment__c = tpsa.Id;
        learnaAss.User__c = indiUser.Id;
        learnaAss.Training_Plan_Section__c = tps.Id;
        learnaAss.Training_Plan__c = tplan.Id;
        learnaAss.Contact__c = accToUsed.PersonContactId;
        insert learnaAss;
        
        LMS_Activity__c lmsAc = new LMS_Activity__c();
        lmsAc.Name = learn.Name;
        lmsAc.LMS_Instance__c = LmsInstance.Id;
        lmsAc.Status__c = 'Active'; 
        lmsAc.AS_Activity_Type__c = learn.AS_Activity_Type__c;
        lmsAc.LMS_Course__c = lc.Id;
        lmsAc.Description__c = learn.Description__c;
        lmsAc.Date__c = Date.today();
        insert lmsAc;
        
        learn.AS_LMS_Activity__c = lmsAc.Id;
        update learn;
        
    }

    static testMethod void test_createAttendee(){
        AS_Event__c evt = new AS_Event__c(Name = 'Test Event');
        insert evt;
        
        Campaign cam = new Campaign(Name = 'Test Campaign', AS_Event__c = evt.Id);
        insert cam;
        
        Contact con = new Contact(LastName = 'Test', FirstName = 'Test');
        insert con;
        
        CampaignMember camMem = new CampaignMember(CampaignId = cam.Id, ContactId = con.Id);
        insert camMem;
        
        AS_HelperClass helper = new AS_HelperClass();
        helper.createAttendee(new List<CampaignMember>{ camMem });
    }

    static testMethod void test_createAttendeeFromSession() {

        Profile p = [SELECT Id FROM Profile WHERE Name='Member Login User']; 

		Account a = new Account(Name='testAcc', AS_Unique_Student_Identifier__c = '1212');
		insert a;

        Contact c = new Contact(LastName='test',AccountId=a.Id);
        insert c;

        User use = new User(Alias = 'standt', 
                            Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', 
                            FirstName='FNtesting',
                            LastName='LNtesting', 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', 
                            UserName='standarduser@testorg.com',
                            ContactId=c.Id);
        insert use;

        System.runAs( use ) {

            // Training_Plan__c tplan = new Training_Plan__c();
            // tplan.AS_Training_Plan_Type__c = 'Australian Pharmacist';
            // tplan.Name = 'Testing TPlan';
            // tplan.Type__c = 'Public';
            // tplan.Status__c = 'Active';
            // tplan.AS_LMS__c = 'Moodle Course';
            // tplan.AS_LMS_Instance__c = LmsInstance.Id;
            // insert tplan;



            // AS_HelperClass Ashelper = new AS_HelperClass();
            // Ashelper.createAttendeeFromSession();

        }
    }

    static testMethod void TestDeleteDuplicateLearnin() {

        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        Account acc = new Account();
        acc.FirstName = 'Sample Person';
        acc.LastName = 'Account';
        acc.PersonEmail = 'person@test.com';
        acc.RecordTypeId = personAccountId;
        acc.AS_Unique_Student_Identifier__c = '12312';
        insert acc;
        
        List<Profile> pro = [Select Id,Name from Profile where Name='Member Login User' LIMIT 1];
        Account accToUsed = [Select Id,PersonContactId from Account where Id = :acc.Id limit 1];
        
        User indiUser = new User();
  		indiUser.ContactId = accToUsed.PersonContactId;
        indiUser.profileid = (pro.size() > 0)?pro[0].Id:null;
        indiUser.FirstName = acc.FirstName;
        indiUser.LastName = acc.LastName;
        indiUser.Alias =string.valueof(acc.FirstName.substring(0,1) + acc.LastName.substring(0,2));
        indiUser.Email = 'person@test.com';
        indiUser.Username = 'person@test.com';
        indiUser.CommunityNickname = acc.FirstName + acc.LastName + AS_commonFunction.generateRandomIntString(2);
        indiUser.emailencodingkey='UTF-8';
        indiUser.languagelocalekey='en_US'; 
        indiUser.localesidkey='en_AU'; 
        indiUser.timezonesidkey='GMT';
        insert indiUser;
        
        LMS_Instance__c	 LmsInstance = new LMS_Instance__c();
        LmsInstance.Type__c = 'Moodle';
        LmsInstance.Date__c = Date.today();
        LmsInstance.Status__c = 'Active';
        LmsInstance.Token__c = '1234567890';
        LmsInstance.Domain_URL__c = 'https://samplewebsite.com';
        LmsInstance.URL__c = 'https://lms.alphasys.com.au/moodle/';
        insert LmsInstance;
        
        LMS_User__c lmsUser = new LMS_User__c();
        lmsUser.AS_Banner_Group_Contact__c = indiUser.ContactId;
        lmsUser.LMS_Instance__c = LmsInstance.Id; 
        lmsUser.As_Creation_Status__c = 'Success';
        lmsUser.Moodle_User_Id__c = '29';
        insert lmsUser;
        
        
        LMS_Course__c lc    = new LMS_Course__c();
        lc.Name             = 'test';
        lc.Date__c          = date.today();
        lc.Status__c        = 'Active';
        lc.LMS_Instance__c = LmsInstance.Id;
        lc.AsMoodleResponse__c = 'Course successfully created';
        lc.Moodle_Course_Id__c = '104';
        insert lc; 
        
        Training_Plan__c tplan = new Training_Plan__c();
        tplan.AS_Training_Plan_Type__c = 'Australian Pharmacist';
        tplan.Name = 'Testing TPlan';
        tplan.Type__c = 'Public';
        tplan.Status__c = 'Active';
        tplan.AS_LMS__c = 'Moodle Course';
        tplan.AS_LMS_Instance__c = LmsInstance.Id;
        insert tplan;
        
        Training_Plan_Assignment__c tplanAss = new Training_Plan_Assignment__c();
        tplanAss.User__c = indiUser.Id;
        tplanAss.Status__c = 'Not Started';
        tplanAss.Training_Plan__c = tplan.Id;
        insert tplanAss;
            
       Id learnmoodlerecIdactivity = Schema.SObjectType.Learning__c.getRecordTypeInfosByName().get('Moodle').getRecordTypeId();
        
        Learning__c learn 		= new Learning__c();
        learn.RecordTypeId = learnmoodlerecIdactivity;
        learn.Name = 'Learning Activity';
        learn.AS_Group_1_CPD__c = 100;
        learn.AS_Group_2_CPD__c = 200;
        learn.AS_LMS_type__c   	= 'Activity';
        learn.AS_Activity_Type__c = 'Lesson';
        learn.LMS_Instance__c = LmsInstance.Id;
        learn.AS_Training_Plan__c = tplan.Id;
        learn.Description__c = 'test2132';
        learn.Published__c 		= true;
        insert learn;
        
        Training_Plan_Section__c tps 	= new Training_Plan_Section__c();
        tps.Name 						= 'test tps';
        tps.Training_Plan__c 			= tplan.Id;
        insert tps;
        
        Training_Plan_Section_Assignment__c tpsa 	= new Training_Plan_Section_Assignment__c();
        tpsa.Training_Plan_Assignment__c 			= tplanAss.Id;
        tpsa.User__c 								= indiUser.Id;
        tpsa.Training_Plan_Section__c				= tps.Id;
        insert tpsa;

        List<Learning_Assignment__c> learnaAssList = new List<Learning_Assignment__c>();
        
        Learning_Assignment__c learnaAss = new Learning_Assignment__c();
        learnaAss.Learning__c = learn.Id; 
        learnaAss.AS_Passed__c = true;
        learnaAss.Progress__c = 'Completed';
        learnaAss.Training_Plan_Section_Assignment__c = tpsa.Id;
        learnaAss.User__c = indiUser.Id;
        learnaAss.Training_Plan_Section__c = tps.Id;
        learnaAss.Training_Plan__c = tplan.Id;
        learnaAss.Contact__c = accToUsed.PersonContactId;
        learnaAssList.add( learnaAss );

        insert learnaAssList;

        Test.startTest();

            AS_HelperClass Ashelper = new AS_HelperClass();
            Ashelper.deleteDuplicateLearningAss( learnaAssList );

        Test.stopTest();

    }

}