/*
*Author : Michael Vincent Largo
*Description : Test class
*Date Created : 06/12/2019
*Last Modified By: Deadz 
*Date Last Modified: 
*Related Metadata :  
*Action : 
*Param : 
*Return : 
*/
@isTest
public with sharing class AsPsaSettingsTest {

    static testMethod void CallMemberRenewalRunBatchByProcedure(){

        AsPsaSettings asp = new AsPsaSettings();
        asp.MemberRenewalRunBatchByProcedure();

    }

    static testMethod void CallrunThisBatch1(){
    
        Membership_End_Date_Renewal__c setting = new Membership_End_Date_Renewal__c();
        setting.Name = 'Test Setting';
        setting.T1__c = 10;
        insert setting;
    
        Test.startTest(); 
            AsPsaSettings wew = new AsPsaSettings();
            wew.runThisBatch1();
        Test.stopTest();
                
    }
    
    static testMethod void CallrunThisBatch2(){

        Membership_End_Date_Renewal__c setting = new Membership_End_Date_Renewal__c();
        setting.Name = 'Test Setting';
        setting.T2__c = 15;
        setting.T3__c = 10;
        setting.T4__c = 5;
        insert setting;

        Test.startTest(); 
        AsPsaSettings asp2 = new AsPsaSettings();
        asp2.runThisBatch2();
        Test.stopTest();
    }

    static testMethod void CallrunThisBatch3(){

        Membership_End_Date_Renewal__c setting = new Membership_End_Date_Renewal__c();
        setting.Name = 'Test Setting';
        setting.T5__c = 15;
        setting.T6__c = 10;
        setting.T7__c = 5;
        insert setting;
        
        Test.startTest(); 
        AsPsaSettings asp2 = new AsPsaSettings();
        asp2.runThisBatch3();
        Test.stopTest();
    }

    static testMethod void CallrunThisBatch4(){

        Membership_End_Date_Renewal__c setting = new Membership_End_Date_Renewal__c();
        setting.Name = 'Test Setting';
        setting.T8__c = 30;
        insert setting;
        
        Test.startTest(); 
        AsPsaSettings asp2 = new AsPsaSettings();
        asp2.runThisBatch4();
        Test.stopTest();
    }

    static testMethod void CallrunThisBatch5(){

        Membership_End_Date_Renewal__c setting = new Membership_End_Date_Renewal__c();
        setting.Name = 'Test Setting';
        setting.T1__c = 10;
        setting.T8__c = 10;
        insert setting;
        
        Test.startTest(); 
        AsPsaSettings asp2 = new AsPsaSettings();
        asp2.runThisBatch5();
        Test.stopTest();
    }

    static testMethod void CallMemberRenewalRunScheduler(){
        AsPsaSettings asp1 = new AsPsaSettings();
        asp1.MemberRenewalRunScheduler();
    }

    static testMethod void CalltrainTrackAndMoodleRunScheduler(){

        AsPsaSettings asp2 = new AsPsaSettings();
        asp2.trainTrackBtnNameStr ='Run Training Track Registration and Moodle Syncing Batch';
        asp2.trainTrackAndMoodleRunScheduler();
    }

    static testMethod void CallapIntegrationRunScheduler(){
        
        AsPsaSettings asp3 = new AsPsaSettings();
        asp3.apIntegrationBtnNameStr = 'Run Ap Integration Batch';
        asp3.apIntegrationRunScheduler();
    

    }

    /*static testMethod void CallBatchCreateCpdRun(){

        Test.StartTest();
        User sub = [Select Id, Name from User where email = 'memberuser@testorg.com' LIMIT 1];

        Id plannerRecordTypeId = Schema.SObjectType.AsCPDPlanner__c.getRecordTypeInfosByName().get('Active CPD Planner').getRecordTypeId();

        // creation of CPD Planner starts here
        List<AsCPDPlanner__c> allCPDList = new List<AsCPDPlanner__c>();
        AsCPDPlanner__c planner = new AsCPDPlanner__c();
        planner.recordTypeId = plannerRecordTypeId;
        planner.AsUser__c = sub.Id;
        planner.Name = 'hope planner review';
        planner.AS_Current_CPD_Plan__c = true;
        planner.AS_Plan_Year__c = String.valueOf(Date.Today().addYears(-2).year());
        allCPDList.add(planner);
        
        AsCPDPlanner__c planner2 = new AsCPDPlanner__c();
        planner2.recordTypeId = plannerRecordTypeId;
        planner2.AsUser__c = sub.Id;
        planner2.Name = 'hope planner review';
        planner2.AS_Current_CPD_Plan__c = false;
        planner2.AsGenerateCPDsummary__c   = true;
        planner2.AS_Plan_Year__c = String.valueOf(Date.Today().addYears(-1).year());
        allCPDList.add(planner2);
        
        insert allCPDList;


    ASCPDPlannerManualInactiveBatch ascpdpplanner = new ASCPDPlannerManualInactiveBatch(String.valueOf(Date.today().addDays(400).year()),true);
    //database.executeBatch(ascpdpplanner);
    //ascpdpplanner.cpdYear = '2019';
    //ascpdpplanner.cpdCurrent = true;

    //AsPsaSettings asp3 = new AsPsaSettings();
    //asp3.BatchCreateCpdRun();

    Test.StopTest();
    }

    @TestSetup  
    static void createData() {
        // TO DO: implement unit test
        Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
    Account acc = new Account();
    acc.FirstName = 'AlphaSys';
    acc.LastName = 'UserAccount12345';
    acc.recordTypeId = personAccRecId;
    acc.PersonEmail = 'memberuser@testorg.com';
    insert acc;
    
    // Create a unique UserName
    String uniqueUserName = 'memberuser2' + DateTime.now().getTime() + '@testorg.com';
    // This code runs as the system user
    Profile p = [SELECT Id FROM Profile WHERE Name='Member Login User'];
    Account acc1 = [SELECT Id,PersonContactId FROM Account WHERE Id =:acc.Id];
    
    User use = new User(Alias = 'standt', Email='memberuser@testorg.com',
    EmailEncodingKey='UTF-8', LastName='johnmongrel', LanguageLocaleKey='en_US',
    LocaleSidKey='en_US', ProfileId = p.Id,
    ContactId = acc1.PersonContactId,
    TimeZoneSidKey='America/Los_Angeles',
    isActive = true,
    UserName=uniqueUserName);
    insert use;
    }*/
    
    static testMethod void CallOtherSettingSave(){
        AsPsaSettings asp5 = new AsPsaSettings();
        asp5.OtherSettingSave();
    }

}