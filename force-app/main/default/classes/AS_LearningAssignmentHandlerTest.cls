/*Author : Michael Vincent Largo
*Description :  This class is  Learning Assignment test class.
*Date Created : September 25,2019
*Last Modified By : 
*Date Last Modified :
*/
@isTest
public class AS_LearningAssignmentHandlerTest {
    
    @TestSetup  
    static void testData(){
        
        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        Account acc = new Account();
        acc.FirstName = 'Sample Person';
        acc.LastName = 'Account';
        acc.PersonEmail = 'person@test.com';
        acc.RecordTypeId = personAccountId;
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
        
        
        LMS_Instance__c lmsInstance = new LMS_Instance__c();
        lmsInstance.AS_Instance_Long_Name__c = 'sample instance';
        lmsInstance.Status__c = 'Active';
        lmsInstance.Token__c = '1234567890';
        lmsInstance.Type__c = 'Moodle';
        lmsInstance.Domain_URL__c = 'https://samplewebsite.com';
        insert lmsInstance;
        
        LMS_Course__c lc    = new LMS_Course__c();
        lc.Name             = 'test';
        lc.Date__c          = date.today();
        lc.Status__c        = 'Active';
        lc.LMS_Instance__c = lmsInstance.Id;
        lc.AsMoodleResponse__c = 'Course successfully created';
        lc.Moodle_Course_Id__c = '104';
        insert lc; 
        
        Training_Plan__c tplan 			= new Training_Plan__c();
        tplan.Name 						= 'test tp';
        tplan.Status__c 					= 'Active';
        tplan.Type__c 						= 'Member Benefit';
        tplan.Enable_Self_Registration__c 	= true;
        tplan.AS_LMS_Course__c				= lc.Id;
        tplan.AS_LMS_Instance__c 			= lmsInstance.Id;
        tplan.AS_LMS__c						= 'Moodle Course';
        tplan.Self_Registration_Access__c 	= 'External';
        insert tplan;
        
        
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
        
        
        AS_Enrolled_Unit__c enrol = new AS_Enrolled_Unit__c();
        enrol.AS_Status__c = 'In Progress';
        enrol.AS_Result__c = 'Competent';
        insert enrol;    
   
        Training_Plan_Assignment__c tpa = new Training_Plan_Assignment__c();
        tpa.Training_Plan__c 			= tplan.Id;
        tpa.User__c 					= indiUser.Id;
        tpa.Status__c					= 'In Progress';
        //tpa.Status__c					= 'Completed';
        tpa.AS_Result__c				= 'Continuing';
        tpa.AS_Enrolled_Unit__c 	    = enrol.Id;
        insert tpa;
        
        Training_Plan_Section__c tps 	= new Training_Plan_Section__c();
        tps.Name 						= 'test tps';
        tps.Training_Plan__c 			= tplan.Id;
        insert tps;
        
        Training_Plan_Section_Assignment__c tpsa 	= new Training_Plan_Section_Assignment__c();
        tpsa.Status__c								= 'Completed';
        tpsa.Training_Plan_Assignment__c 			= tpa.Id;
        tpsa.User__c 								= indiUser.Id;
        tpsa.Training_Plan_Section__c				= tps.Id;
        insert tpsa;
        
        Learning_Assignment__c learnaAss = new Learning_Assignment__c();
        learnaAss.Learning__c = learn.Id;
        learnaAss.Progress__c = 'In Progress';
        learnaAss.Training_Plan_Section_Assignment__c = tpsa.Id;
        learnaAss.User__c = indiUser.Id;
        learnaAss.Training_Plan_Section__c = tps.Id;
        learnaAss.Training_Plan__c = tplan.Id;
        insert learnaAss;
        
    }
    
    static testmethod void updateTrainingPlaAssBasOnLearningAss(){
        
        List<Learning__c> learn = [SELECT Id FROM Learning__c WHERE Name = 'test l' LIMIT 1];
        System.assertEquals(learn != null, true);       
        
        List<Training_Plan_Section_Assignment__c> tplansecass = [SELECT Id FROM Training_Plan_Section_Assignment__c WHERE Status__c	= 'Completed' LIMIT 1];
        System.assertEquals(tplansecass != null, true);
        
        List<Training_Plan_Assignment__c> tplan = [SELECT Id FROM Training_Plan_Assignment__c WHERE Status__c	= 'In Progress' LIMIT 1];
        System.assertEquals(tplan != null, true);
        
        
        Learning_Assignment__c learningAssList = [SELECT Id,Progress__c,Learning__c,User__c,Training_Plan__c,Training_Plan_Section__c,Training_Plan_Section_Assignment__r.Training_Plan_Assignment__c,Training_Plan_Section_Assignment__r.Training_Plan_Assignment__r.Status__c FROM Learning_Assignment__c WHERE Progress__c='In Progress' LIMIT 1];
        learningAssList.Progress__c='Completed';
        update learningAssList;
        
        List<Training_Plan_Assignment__c> TPAList = new List<Training_Plan_Assignment__c>();
    
        if (learningAssList.Training_Plan_Section_Assignment__r.Training_Plan_Assignment__r.Status__c == 'In Progress') {
            Training_Plan_Assignment__c TPAnew = new Training_Plan_Assignment__c();
            TPAnew.Id = learningAssList.Training_Plan_Section_Assignment__r.Training_Plan_Assignment__c;
            //TPAnew.Id = tplan[0].Id;
            //TPAnew.Status__c = 'In Progress';
            TPAnew.AS_Result__c='Continuing';
            TPAList.add(TPAnew);
            update TPAList; 
        }
        System.assertEquals(TPAList !=null, true);
    }
}