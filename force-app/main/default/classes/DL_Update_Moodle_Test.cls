@isTest
public with sharing class DL_Update_Moodle_Test {


    @isTest(SeeAllData=true)
    static void UpdateEmailPass(){
      LMS_User__c lmsUser = [SELECT ID,Email__c,PSA_Imis_Id__c from LMS_User__c WHERE PSA_Imis_Id__c = '923198'];
      User usr = [SELECT Id,Name,AS_Imis_ID__c FROM User WHERE AS_Imis_ID__c = '923198'];

      Test.setMock(HttpCalloutMock.class, new DL_WebServiceMock(false,1));  


      lmsUser.Email__c = 'johan.citizen@psa.org.au';

      Test.startTest();

      update lmsUser;

      lmsUser = [SELECT ID,Email__c,PSA_Imis_Id__c from LMS_User__c WHERE PSA_Imis_Id__c = '923198'];

      System.assertEquals('johan.citizen@psa.org.au', lmsUser.Email__c); // ==

      Test.stopTest();

    }


    @isTest(SeeAllData=true)
    static void UpdateEmailFail(){
      Boolean exceptionThrown = false;
      LMS_User__c lmsUser = [SELECT ID,Email__c,PSA_Imis_Id__c from LMS_User__c WHERE PSA_Imis_Id__c = '923198'];

      Test.setMock(HttpCalloutMock.class, new DL_WebServiceMock(false,1));  


      lmsUser.Email__c = 'adam.baker200@psa.org.au';


      Test.startTest();

      try{ //Update will fail and an exception will raise because LMS User email != User.Username
        update lmsUser;
      }
      
      catch(Exception e){
        System.debug(e.getMessage());
        exceptionThrown = true;
      }

      Test.stopTest();


      lmsUser = [SELECT ID,Email__c,PSA_Imis_Id__c from LMS_User__c WHERE PSA_Imis_Id__c = '923198'];

      System.assertNotEquals('adam.baker200@psa.org.au', lmsUser.Email__c); // !=
      System.assert(exceptionThrown == true);
    }


    @isTest(SeeAllData=true)
    static void UpdateEmailNoUser(){
      Boolean exceptionThrown = false;
      LMS_User__c lmsUser = [SELECT ID,Email__c,PSA_Imis_Id__c from LMS_User__c WHERE PSA_Imis_Id__c = '926407'];

      Test.setMock(HttpCalloutMock.class, new DL_WebServiceMock(false,1));  


      lmsUser.Email__c = 'john.citizen200@psa.org.au';


      Test.startTest();

      try{ //Update will pass when no user is found 
        update lmsUser;
      }
      
      catch(Exception e){
        System.debug(e.getMessage());
      }

      lmsUser = [SELECT ID,Email__c,PSA_Imis_Id__c from LMS_User__c WHERE PSA_Imis_Id__c = '926407'];

      System.assertEquals('john.citizen200@psa.org.au', lmsUser.Email__c); 

      Test.stopTest();
    }

    @isTest(SeeAllData=true)
     static void UnenrolUser(){
      Boolean exceptionThrown = false;

      Test.setMock(HttpCalloutMock.class, new DL_WebServiceMock(false,1));  
      Training_Plan__c trainingPlan = [SELECT Id,Name,ASCourse_Code__c  FROM Training_Plan__c WHERE AsCourse_Code__c = 'TEST1'];
      Id trainingPlanAssignmentId = [SELECT Id,Name,Training_Plan__c FROM Training_Plan_Assignment__c WHERE Training_Plan__c = :trainingPlan.Id LIMIT 1].Id;


      Test.startTest();

      try{ //Update will pass when no user is found 
        DL_Update_Moodle.UnenrolUser(trainingPlanAssignmentId);
      }
      
      catch(Exception e){
        System.debug(e.getMessage());
      }

      Test.stopTest();

    }

}