/*Author : Ronald Santander
*Description : This test class is for ASTpLMSCourseHandler class
*Date Created : Aug 14,2019
*/
@isTest
public class ASTpLMSCourseHandlerTest {
    
    @testSetup 
    static void setup(){

        LMS_Instance__c lmsInst = new LMS_Instance__c();
        lmsInst.Type__c     = 'Moodle';
        lmsInst.Date__c     = Date.today();
        lmsInst.Status__c   = 'Active';
        lmsInst.Domain_URL__c = 'https://lms.alphasys.com.au/moodle/';
        insert lmsInst;

        Training_Plan__c tp = new Training_Plan__c();
        tp.Name             = 'tp test';
        tp.Start_Date__c    = Date.today();
        tp.End_Date__c      = Date.today().addDays(30);
        tp.Date_Published__c = Date.today();
        tp.Status__c        = 'Draft';
        tp.AS_LMS__c        = 'Moodle Course';
        tp.Type__c          = 'Public';
        tp.AS_Include_In_Catalog__c = true;
        tp.AS_LMS_Instance__c = lmsInst.Id;
        insert tp;
    }

    //check if the created lms course linked to training plan 
    static testmethod void checkTPrecord(){
        Training_Plan__c tp = [SELECT Id,AS_LMS_Course__c FROM Training_Plan__c WHERE Name =: 'tp test'];
        system.assertNotEquals(null, tp.AS_LMS_Course__c);
    }
}