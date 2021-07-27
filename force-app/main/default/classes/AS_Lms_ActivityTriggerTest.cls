@isTest
public class AS_Lms_ActivityTriggerTest {
    
    @isTest static void lmsAcTest() { 
        
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
    
        //Test.startTest();
        
        //Test.setMock(HttpCalloutMock.class, new AsMoodleMockHttpResponseGenerator());
        
        LMS_Activity__c lmsAc = new LMS_Activity__c();
        lmsAc.Name = learn.Name;
        lmsAc.LMS_Instance__c = LmsInstance.Id;
        lmsAc.Status__c = 'Active';
        lmsAc.AS_Activity_Type__c = learn.AS_Activity_Type__c;
        lmsAc.LMS_Course__c = lc.Id;
        lmsAc.Description__c = learn.Description__c;
        lmsAc.Date__c = Date.today();
        insert lmsAc;
        
        //Test.stopTest();
        /*learn.AS_LMS_Activity__c = lmsAc.Id;
        update learn;*/
    }

}