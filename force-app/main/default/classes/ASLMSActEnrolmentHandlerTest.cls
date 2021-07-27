/*Author : Ronald Santander
*Description : This test class is for ASTpLMSCourseHandler class
*Date Created : Aug 14,2019
*/

@isTest
public class ASLMSActEnrolmentHandlerTest {

    @testSetup 
    static void setup(){

        Profile p = [SELECT Id FROM Profile WHERE Name='Member Login User']; 

		Account a = new Account(Name='testAcc');
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

        LMS_Activity_Enrolment__c lmsActEnrol = new LMS_Activity_Enrolment__c();
        //lmsActEnrol.Name                    = 'actenrol test';
        lmsActEnrol.AS_Completed_Status__c  = false;
        lmsActEnrol.Completion_Status__c    = 'Pass';
        lmsActEnrol.End_Date__c             = Date.today();
        insert lmsActEnrol;
        
        LMS_Activity_Enrolment__c lmsActEnrol2 = new LMS_Activity_Enrolment__c();
        //lmsActEnrol.Name                    = 'actenrol test';
        lmsActEnrol.AS_Completed_Status__c  = false;
        lmsActEnrol.Completion_Status__c    = 'Pass';
        lmsActEnrol.End_Date__c             = Date.today();
        insert lmsActEnrol2;

        Learning__c l 		= new Learning__c();
        l.Name 				= 'test l';
        l.AS_Group_1_CPD__c = 100;
        l.AS_Group_2_CPD__c = 200;
        l.Published__c 		= true;
        insert l;
        
        Learning__c learn 		= new Learning__c();
        learn.Name 				= 'test l';
        learn.AS_Group_1_CPD__c = 100;
        learn.AS_Group_2_CPD__c = null;
        learn.Published__c 		= true;
        insert learn;

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

        Learning_Assignment__c Lassign = new Learning_Assignment__c();
        Lassign.Learning__c                     = learn.Id;
        Lassign.AS_LMS_activity_enrolment__c    = lmsActEnrol.Id;
        Lassign.User__c                         = u.Id;
        Lassign.Training_Plan__c                = tp.Id;
        Lassign.Training_Plan_Section__c        = tps.Id;
        Lassign.Training_Plan_Section_Item__c   = tpsi.Id;
        insert Lassign;

        Learning_Assignment__c learnAssign = new Learning_Assignment__c();
        learnAssign.Learning__c                     = l.Id;
        learnAssign.AS_LMS_activity_enrolment__c    = lmsActEnrol.Id;
        learnAssign.User__c                         = u.Id;
        learnAssign.Training_Plan__c                = tp.Id;
        learnAssign.Training_Plan_Section__c        = tps.Id;
        learnAssign.Training_Plan_Section_Item__c   = tpsi.Id;
        insert learnAssign;

        LMS_Activity_Enrolment__c lmsActEnrol1 = new LMS_Activity_Enrolment__c();
        lmsActEnrol1.Id                      = lmsActEnrol.Id;
        lmsActEnrol1.AS_Completed_Status__c  = true;
        update lmsActEnrol1;
        
        LMS_Activity_Enrolment__c lmsActEnrol3 = new LMS_Activity_Enrolment__c();
        lmsActEnrol3.Id                      = lmsActEnrol2.Id;
        lmsActEnrol3.AS_Completed_Status__c  = true;
        update lmsActEnrol3;
    }

    static testmethod void checkLearningAssignmentrecorde(){
        Learning_Assignment__c Lassign = [SELECT Id,Completed_On__c,AS_Passed__c,Progress__c,Progress_Percentage__c FROM Learning_Assignment__c LIMIT 1];
        System.assertEquals(Lassign.Completed_On__c, Date.today());
        System.assertEquals(Lassign.AS_Passed__c, true);
        System.assertEquals(Lassign.Progress__c, 'Completed');
        System.assertEquals(Lassign.Progress_Percentage__c, 100);

    }
}