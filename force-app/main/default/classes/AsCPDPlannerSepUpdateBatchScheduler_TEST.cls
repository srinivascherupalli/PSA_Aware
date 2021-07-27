/*
*Author : Crishel-Ann
*Description : This is a class that acts as a test class for the AsCPDPlannerSepUpdateBatchScheduler batch.
*JIRA TASK: https://jira.alphasys.com.au/browse/PSAMOPT-120
*Date Created : December 18, 2019
*/
@isTest
public class AsCPDPlannerSepUpdateBatchScheduler_TEST {
    public static String CRON_EXP = '0 0 0 1 10 ? *';
    
    static testMethod void Test_AsCPDPlannerSepUpdateBatchScheduler(){
        Id activeCPDRecId = Schema.SObjectType.AsCPDPlanner__c.getRecordTypeInfosByName().get('Active CPD Planner').getRecordTypeId();
        String cpdYear = '2020';
        Boolean cpdCurrent = true;
        String cpd;
        
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
        User theUser = new User(Alias = 'standt', Email='memberuser@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='testeronly', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,
                            ContactId = acc1.PersonContactId,
                            TimeZoneSidKey='America/Los_Angeles',
                            isActive = true,
                            UserName=uniqueUserName);
        insert theUser;
        
        AsCPDPlanner__c indiAddedUpdatedCPD = new AsCPDPlanner__c();
        indiAddedUpdatedCPD.recordTypeId = activeCPDRecId;
        indiAddedUpdatedCPD.Name = theUser.Name + ' - CPD Plan - ' + cpdYear;
        indiAddedUpdatedCPD.AsUser__c = theUser.Id;
        indiAddedUpdatedCPD.AS_Plan_Year__c = cpdYear;
        indiAddedUpdatedCPD.AsStartDate__c = Date.newInstance(Integer.valueOf(cpdYear)-1,10,1);
        indiAddedUpdatedCPD.AsEndDate__c = Date.newInstance(Integer.valueOf(cpdYear),9,30);
        indiAddedUpdatedCPD.AS_Current_CPD_Plan__c = TRUE;
        indiAddedUpdatedCPD.AsGenerateCPDsummary__c = false;
        
        Test.startTest();
        //Schedule the Job
        String jobId = System.schedule('CPD Planner', CRON_EXP, new AsCPDPlannerSepUpdateBatchScheduler());
        Test.stopTest();
    }
}