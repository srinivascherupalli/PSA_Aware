@isTest
private class AsMoodleApiCalloutQueueableTest {
    
    /*@testSetup static void methodName() {
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
        
        LMS_Course_Enrolment__c lce = new LMS_Course_Enrolment__c();
        lce.LMS_Instance__c = LmsInstance.Id;
        lce.LMS_Course__c = lc.Id;
        lce.LMS_User__c = lmsUser.Id;
        insert lce;
        
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
    
        
        LMS_Activity__c lmsAc = new LMS_Activity__c();
        lmsAc.Name = learn.Name;
        lmsAc.LMS_Instance__c = LmsInstance.Id;
        lmsAc.Status__c = 'Active';
        lmsAc.AS_Activity_Type__c = learn.AS_Activity_Type__c;
        lmsAc.LMS_Course__c = lc.Id;
        lmsAc.Description__c = learn.Description__c;
        lmsAc.Date__c = Date.today();
        insert lmsAc;
	}*/
    
    /*
    static testMethod void TestMethodCallouts() {
        
        Map<Id,LMS_Instance__c> allInstanceMap = new Map<Id,LMS_Instance__c>();
		allInstanceMap = new Map<Id,LMS_Instance__c>([SELECT Id,Token__c, URL__c FROM LMS_Instance__c ]);
    
        try {
            List<AsMoodleWrapper> allAsMoodleWrapper = new List<AsMoodleWrapper>();
            for (LMS_Activity__c activity : [SELECT Id,Name,LMS_Course__c,AS_Activity_Type__c,LMS_Instance__c FROM LMS_Activity__c WHERE Status__c = 'Active' ]){
                system.debug('GodSpeed==>' + activity);
                
                AsMoodleWrapper aswrap = new AsMoodleWrapper(activity.Id, activity.Name, activity.LMS_Course__c, activity.AS_Activity_Type__c, allInstanceMap.get(activity.LMS_Instance__c).Token__c, allInstanceMap.get(activity.LMS_Instance__c).URL__c, 'activities', 'local_psa_integration_create_activities', 'create');
                allAsMoodleWrapper.add(aswrap);
            }
          
            system.enqueueJob(new AsMoodleApiCalloutQueueable(allAsMoodleWrapper));  
    
            
        } catch(Exception ex) {
            System.debug('ERROR LOGS HERE FOR ACTIVITY :' + ex);
        }
      
        
    }*/
    
    // @isTest
    // static void TestMethodCalloutsCourse() {
        
	   //  Test.setMock(HttpCalloutMock.class, new AsMoodleMockHttpResponseGenerator());
    //    	Test.startTest();
    //     Map<Id,LMS_Instance__c> allInstanceMap = new Map<Id,LMS_Instance__c>();
    //     allInstanceMap = new Map<Id,LMS_Instance__c>([SELECT Id,Token__c, URL__c FROM LMS_Instance__c ]);
        
    //     LMS_Course_Enrolment__c lmsEnroll = [ Select Id, LMS_Course__c, LMS_User__c From LMS_Course_Enrolment__c limit 1 ];
  
    //     List<AsMoodleWrapper> allAsMoodleWrapper = new List<AsMoodleWrapper>();
        
    //     AsMoodleWrapper aswrap = new AsMoodleWrapper('sdfafsdasffsdfsda', 'https://lms.alphasys.com.au/moodle/', 'enrolUsers', 'local_psa_integration_enrol_users', 'insert', lmsEnroll.Id, '5', lmsEnroll.LMS_Course__c, 'theEmail@alphasys.com.au','lmsfirstname' ,'lmsLastname', 'test@alphasys.com.au', lmsEnroll.LMS_User__c, 'saml');
        
    //     allAsMoodleWrapper.add(aswrap);
       
    //     system.enqueueJob(new AsMoodleApiCalloutQueueable(allAsMoodleWrapper));  
    //     Test.stopTest();
    // }
    
    @isTest
    static void callQueueCourseEnrolment() {
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
        
        LMS_Course_Enrolment__c lce = new LMS_Course_Enrolment__c();
        lce.LMS_Instance__c = LmsInstance.Id;
        lce.LMS_Course__c = lc.Id;
        lce.LMS_User__c = lmsUser.Id;
        insert lce;
        
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
    
        
        LMS_Activity__c lmsAc = new LMS_Activity__c();
        lmsAc.Name = learn.Name;
        lmsAc.LMS_Instance__c = LmsInstance.Id;
        lmsAc.Status__c = 'Active';
        lmsAc.AS_Activity_Type__c = learn.AS_Activity_Type__c;
        lmsAc.LMS_Course__c = lc.Id;
        lmsAc.Description__c = learn.Description__c;
        lmsAc.Date__c = Date.today();
        insert lmsAc;
        Test.startTest();
            AsMoodleApiCalloutQueueable.makeCallout = false;
            // enqueue job
        Test.stopTest();
    }

    @isTest
    static void callHTTP() {
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
        
        LMS_Course_Enrolment__c lce = new LMS_Course_Enrolment__c();
        lce.LMS_Instance__c = LmsInstance.Id;
        lce.LMS_Course__c = lc.Id;
        lce.LMS_User__c = lmsUser.Id;
        insert lce;
        
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
    
        
        LMS_Activity__c lmsAc = new LMS_Activity__c();
        lmsAc.Name = learn.Name;
        lmsAc.LMS_Instance__c = LmsInstance.Id;
        lmsAc.Status__c = 'Active';
        lmsAc.AS_Activity_Type__c = learn.AS_Activity_Type__c;
        lmsAc.LMS_Course__c = lc.Id;
        lmsAc.Description__c = learn.Description__c;
        lmsAc.Date__c = Date.today();
        insert lmsAc;
        
        
        List<String> respMock = new List<String>();
		respMock.add( '[{"status":true,"is_created":true,"enrolsfid":"'+lce.Id+'","usersfid":"'+lmsUser.Id+'","enrolid":33,"userid":49,"courseid":121,"courseurl":"https://lms.alphasys.com.au/demo1/course/view.php?id=121","message":"User successfully enroled"}]' );

        AsMoodleMockHttpResponseGenerator fake = new AsMoodleMockHttpResponseGenerator(200,'OK',respMock);
        Test.setMock(HttpCalloutMock.class, fake);
        
        Test.startTest();
            LMS_Course_Enrolment__c lmsEnroll = [ Select Id, LMS_Course__c, LMS_User__c From LMS_Course_Enrolment__c limit 1 ];
  
        	List<AsMoodleWrapper> allAsMoodleWrapper = new List<AsMoodleWrapper>();
        	AsMoodleWrapper aswrap = new AsMoodleWrapper('sdfafsdasffsdfsda', 'https://lms.alphasys.com.au/moodle/', 'enrolUsers', 'local_psa_integration_enrol_users', 'insert', lmsEnroll.Id, '5', lmsEnroll.LMS_Course__c, 'theEmail@alphasys.com.au','lmsfirstname' ,'lmsLastname', 'test@alphasys.com.au', lmsEnroll.LMS_User__c, 'saml');
			allAsMoodleWrapper.add(aswrap);
        	AsMoodleApiCalloutQueueable que = new AsMoodleApiCalloutQueueable(allAsMoodleWrapper);
            que.performCallout();
            // enqueue job
        Test.stopTest();
    }
    
    @isTest
    static void callQueueActivity() {
        
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
        
        LMS_Course_Enrolment__c lce = new LMS_Course_Enrolment__c();
        lce.LMS_Instance__c = LmsInstance.Id;
        lce.LMS_Course__c = lc.Id;
        lce.LMS_User__c = lmsUser.Id;
        insert lce;
        
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
    
        
        LMS_Activity__c lmsAc = new LMS_Activity__c();
        lmsAc.Name = learn.Name;
        lmsAc.LMS_Instance__c = LmsInstance.Id;
        lmsAc.Status__c = 'Active';
        lmsAc.AS_Activity_Type__c = learn.AS_Activity_Type__c;
        lmsAc.LMS_Course__c = lc.Id;
        lmsAc.Description__c = learn.Description__c;
        lmsAc.Date__c = Date.today();
        insert lmsAc;
        
		Map<Id,LMS_Instance__c> allInstanceMap = new Map<Id,LMS_Instance__c>();
		allInstanceMap = new Map<Id,LMS_Instance__c>([SELECT Id,Token__c, URL__c FROM LMS_Instance__c  Limit 1]);
        List<AsMoodleWrapper> allAsMoodleWrapper = new List<AsMoodleWrapper>();
        for (LMS_Activity__c activity : [SELECT Id,Name,LMS_Course__c,AS_Activity_Type__c,LMS_Instance__c FROM LMS_Activity__c WHERE Status__c = 'Active']){
            system.debug('GodSpeed==>' + activity);
            
            AsMoodleWrapper aswrap = new AsMoodleWrapper(activity.Id, activity.Name, activity.LMS_Course__c, activity.AS_Activity_Type__c, allInstanceMap.get(activity.LMS_Instance__c).Token__c, allInstanceMap.get(activity.LMS_Instance__c).URL__c, 'activities', 'local_psa_integration_create_activities', 'create');
            allAsMoodleWrapper.add(aswrap);
        }
        
        List<String> respMock = new List<String>();
		respMock.add( '[{"activitysfid":"'+lmsAc.Id+'","activityid":"841","message":"Activity Successfully Created"}]' );

        AsMoodleMockHttpResponseGenerator fake = new AsMoodleMockHttpResponseGenerator(200,'OK',respMock);
        Test.setMock(HttpCalloutMock.class, fake);
        
        Test.startTest();
            LMS_Course_Enrolment__c lmsEnroll = [ Select Id, LMS_Course__c, LMS_User__c From LMS_Course_Enrolment__c limit 1 ];
  
        	AsMoodleApiCalloutQueueable que = new AsMoodleApiCalloutQueueable(allAsMoodleWrapper);
            que.performCallout();
            // enqueue job
        Test.stopTest();
        
        
    }
    
    @isTest
    static void callQueueCourse() {
        
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
        
        LMS_Course_Enrolment__c lce = new LMS_Course_Enrolment__c();
        lce.LMS_Instance__c = LmsInstance.Id;
        lce.LMS_Course__c = lc.Id;
        lce.LMS_User__c = lmsUser.Id;
        insert lce;
        
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
    
        
        LMS_Activity__c lmsAc = new LMS_Activity__c();
        lmsAc.Name = learn.Name;
        lmsAc.LMS_Instance__c = LmsInstance.Id;
        lmsAc.Status__c = 'Active';
        lmsAc.AS_Activity_Type__c = learn.AS_Activity_Type__c;
        lmsAc.LMS_Course__c = lc.Id;
        lmsAc.Description__c = learn.Description__c;
        lmsAc.Date__c = Date.today();
        insert lmsAc;
        
        Map<Id,LMS_Instance__c> allInstanceMap = new Map<Id,LMS_Instance__c>();
		allInstanceMap = new Map<Id,LMS_Instance__c>([SELECT Id,Token__c, URL__c FROM LMS_Instance__c  Limit 1]);
        
        List<AsMoodleWrapper> allAsMoodleWrapper = new List<AsMoodleWrapper>();
        AsMoodleWrapper wrap = new AsMoodleWrapper(allInstanceMap.get(lc.LMS_Instance__c).Token__c, allInstanceMap.get(lc.LMS_Instance__c).URL__c, 'courses', 'local_psa_integration_update_courses', 'update', lc.Id, lc.Name, lc.Name, null, null, null, null, null, null);
		allAsMoodleWrapper.add(wrap);

		List<String> respMock = new List<String>();
		respMock.add( '[{"status":true,"sf_id":"'+lc.Id+'","courseid":2,"categoryid":1,"message":"Course successfully created"}]' );

        AsMoodleMockHttpResponseGenerator fake = new AsMoodleMockHttpResponseGenerator(200,'OK',respMock);
        Test.setMock(HttpCalloutMock.class, fake);
        
        Test.startTest();
            LMS_Course_Enrolment__c lmsEnroll = [ Select Id, LMS_Course__c, LMS_User__c From LMS_Course_Enrolment__c limit 1 ];
  
        	AsMoodleApiCalloutQueueable que = new AsMoodleApiCalloutQueueable(allAsMoodleWrapper);
            que.performCallout();
            // enqueue job
        Test.stopTest();
        
    }

}