/*Author : Michael Vincent Largo
*Description :  This class is  training plan assignment test class.
*Date Created : September 25,2019
*Last Modified By : 
*Date Last Modified :
*/
@isTest
public class TrainingPlanAssignmentTriggerHandlerTest {
    
    @TestSetup  
    static void testData(){
        
        /*for Existing Lms_User record Purposes*/ 
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
     
        LMS_User__c lmsUser = new LMS_User__c();
        lmsUser.FirstName__c = 'Fname';
		lmsUser.LastName__c = 'Lname'; 
        lmsUser.AS_Banner_Group_Contact__c = indiUser.ContactId;
        lmsUser.LMS_Instance__c = LmsInstance.Id;
        lmsUser.As_Creation_Status__c = 'Success';
        lmsUser.Moodle_User_Id__c = '29';
        insert lmsUser;
        
       
        /*addded test for PRI - 103*/
        AS_Enrolled_Unit__c enrol = new AS_Enrolled_Unit__c();
        enrol.AS_Status__c = 'In Progress';
        enrol.AS_Result__c = 'Competent';
        insert enrol;       
        
        Training_Plan_Assignment__c tpa = new Training_Plan_Assignment__c();
        tpa.Training_Plan__c 			= tplan.Id;
        tpa.User__c 					= indiUser.Id;
        tpa.Status__c				    = 'Not Started';
        tpa.AS_Result__c				= 'Not competent/fail';
        tpa.AS_Enrolled_Unit__c 	    = enrol.Id;
        insert tpa;
        
        Training_Plan_Section__c tps 	= new Training_Plan_Section__c();
        tps.Name 						= 'test tps';
        tps.Training_Plan__c 			= tplan.Id;
        insert tps;
        
        Training_Plan_Section_Assignment__c tpsa 	= new Training_Plan_Section_Assignment__c();
        tpsa.Training_Plan_Assignment__c 			= tpa.Id;
        tpsa.User__c 								= indiUser.Id;
        tpsa.Training_Plan_Section__c				= tps.Id;
        insert tpsa;
        
        Id learnmoodlerecId = Schema.SObjectType.Learning__c.getRecordTypeInfosByName().get('Moodle').getRecordTypeId();
        Learning__c learn 		= new Learning__c();
        learn.RecordTypeId = learnmoodlerecId;
        learn.Name 				= 'test l';
        learn.AS_Group_1_CPD__c = 100;
        learn.AS_Group_2_CPD__c = 200;
        learn.AS_LMS_type__c   	= 'Activity';
        learn.AS_Activity_Type__c = 'Lesson';
        learn.LMS_Instance__c = lmsInstance.Id;
        learn.AS_Training_Plan__c = tplan.Id;
        learn.Description__c = 'test2132';
        learn.Published__c 		= true;
        insert learn;
        
        Learning_Assignment__c learnaAss = new Learning_Assignment__c();
        learnaAss.Learning__c = learn.Id; 
        learnaAss.AS_Passed__c = true;
        learnaAss.Progress__c = 'Completed';
        learnaAss.Training_Plan_Section_Assignment__c = tpsa.Id;
        learnaAss.User__c = indiUser.Id;
        learnaAss.Training_Plan_Section__c = tps.Id;
        learnaAss.Training_Plan__c = tplan.Id;
        insert learnaAss;
       
    }
    
    /*for Lms_User  not exist then create Lms_course_enrolment only*/
    static testmethod void ExistingLMSUser(){
        
        LMS_User__c lmsuser = [SELECT Id,FirstName__c,AS_Banner_Group_Contact__c,LMS_Instance__c FROM LMS_User__c WHERE FirstName__c = 'Fname'];
        System.assertEquals(lmsuser !=null, true);
        Training_Plan__c Tplan = [SELECT Id,AS_LMS__c FROM Training_Plan__c WHERE Name = 'Testing TPlan' AND AS_LMS__c = 'Moodle Course'];
        System.assertEquals(Tplan !=null, true);
        LMS_Instance__c LmsIntance = [SELECT Id,Status__c,Type__c FROM LMS_Instance__c WHERE Status__c = 'Active' AND Type__c = 'Moodle'];
        System.assertEquals(LmsIntance !=null, true);
        
        List<Training_Plan_Assignment__c>TplanAssign = [SELECT Id, 
                                                         Name, 
                                                         User__c, 
                                                         User__r.ContactId, 
                                                         Training_Plan__c, 
                                                         User__r.Contact.Email, 
                                                         User__r.Contact.FirstName, 
                                                         User__r.Contact.LastName, 
                                                         Training_Plan__r.AS_LMS_Course__c, 
                                                         Training_Plan__r.AS_LMS_Instance__c, 
                                                         CreatedDate,
                                                         Status__c  
                                                         FROM Training_Plan_Assignment__c 
                                                         WHERE Status__c = 'Not Started'];
        
        system.debug('TplanAssign==>:' +TplanAssign);
    
    }
 
    
    /*training plan assignment afterupdated*/
   
    static testmethod void trainingplanAssignmentUpdatetoCompleted(){
        
        List<Training_Plan_Assignment__c> TplanAsslist01 = [SELECT Id,Status__c,AS_Result__c,AS_Enrolled_Unit__c,Training_Plan__c FROM Training_Plan_Assignment__c WHERE Status__c = 'Not Started'];
		List<Training_Plan_Assignment__c> listtpa = new List<Training_Plan_Assignment__c>();
        for (Training_Plan_Assignment__c Tplanass : TplanAsslist01 ) {
            Training_Plan_Assignment__c tpa = new Training_Plan_Assignment__c();
            tpa.Id =  Tplanass.Id;
            tpa.Status__c = 'Completed';
            tpa.AS_Result__c = 'Competent';
            listtpa.add(tpa);
        }    
        update listtpa;
        System.assertEquals(listtpa !=null,true);
        
        AS_Enrolled_Unit__c enrollist = [SELECT Id,AS_Status__c,AS_Result__c,AS_Start_Date__c FROM AS_Enrolled_Unit__c];
        System.assertEquals(enrollist.AS_Status__c,listtpa[0].Status__c);
        System.assertEquals(enrollist.AS_Result__c,listtpa[0].AS_Result__c);
        System.assertEquals(enrollist.AS_Start_Date__c == Date.today(),true);
        System.assertEquals(enrollist !=null,true);
    }
}