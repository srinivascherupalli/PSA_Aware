@isTest
public class TrainingPlanAssignmentHelperTest {
    @TestSetup  
    static void testData(){
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Id planActRecId = Schema.SObjectType.AsCPD_Learning_Summary__c.getRecordTypeInfosByName().get('Planned Activity').getRecordTypeId();
        
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
        
        Training_Plan__c tplan = new Training_Plan__c();
        tplan.AS_Training_Plan_Type__c = 'Australian Pharmacist';
        tplan.Name = 'Testing TPlan';
        tplan.Type__c = 'Public';
        tplan.Status__c = 'Active';
        insert tplan;
        
        Achievement__c achieve = new Achievement__c();
        achieve.Name = 'test achievement';
        achieve.Type__c = 'Achievements';
        insert achieve;
        
        Training_Plan_Achievement__c TPlanAchieve = new Training_Plan_Achievement__c();
        TPlanAchieve.Achievement__c = achieve.Id;
        TPlanAchieve.Training_Plan__c = tplan.Id;
        insert TPlanAchieve;
        
        List<Training_Plan_Assignment__c> tplanAssign = new List<Training_Plan_Assignment__c>();
        Training_Plan_Assignment__c tplanAss = new Training_Plan_Assignment__c();
        tplanAss.User__c = indiUser.Id;
        tplanAss.Status__c = 'Not Started';
        tplanAss.Training_Plan__c = tplan.Id;
        insert tplanAss;
        
        Training_Plan_Assignment__c tplanAss2 = new Training_Plan_Assignment__c();
        tplanAss2.User__c = indiUser.Id;
        tplanAss2.Status__c = 'Completed';
        tplanAss2.Training_Plan__c = tplan.Id;
        insert tplanAss2;
        
        Training_Plan_Assignment__c tplanAss3 = new Training_Plan_Assignment__c();
        tplanAss3.User__c = indiUser.Id;
        tplanAss3.Status__c = 'Not Started';
        tplanAss3.Training_Plan__c = tplan.Id;
        insert tplanAss3;
        
        Id activeCPDRecId = Schema.SObjectType.AsCPDPlanner__c.getRecordTypeInfosByName().get('Active CPD Planner').getRecordTypeId();
        AsCPDPlanner__c newCPD = new AsCPDPlanner__c();
        newCPD.AsUser__c = indiUser.Id;
        newCPD.Name = 'testing CPD';
        newCPD.AS_Current_CPD_Plan__c = true;
        newCPD.AS_Plan_Year__c = '2019';
        newCPD.AsStartDate__c = Date.today();
        newCPD.AsEndDate__c = Date.today().addDays(30);
        newCPD.recordTypeId = activeCPDRecId;
        insert newCPD;
        
        AsCPDPlanner__c newCPD2 = new AsCPDPlanner__c();
        newCPD2.AsUser__c = adminUsers[0].Id;
        newCPD2.Name = 'testing CPD';
        newCPD2.AS_Current_CPD_Plan__c = true;
        newCPD2.AS_Plan_Year__c = '2019';
        newCPD2.AsStartDate__c = Date.today();
        newCPD2.AsEndDate__c = Date.today().addDays(30);
        newCPD2.recordTypeId = activeCPDRecId;
        insert newCPD2;
        
        As_TPlan_Assignment_Task__c TPlanAssignTask = new As_TPlan_Assignment_Task__c();
        TPlanAssignTask.As_Training_Plan__c = tplan.Id;
        TPlanAssignTask.As_Status__c = 'In Progress';
        TPlanAssignTask.As_User__c = indiUser.Id;
        insert TPlanAssignTask;
        
        AsCPD_Learning_Summary__c CPDlearning = new AsCPD_Learning_Summary__c();
        CPDlearning.Name = 'testing cpd learning';
        CPDlearning.CPD_Planner__c = newCPD.Id;
        CPDlearning.ASTraining_Plan_Assignment__c = tplanAss.Id;
        insert CPDlearning;
        
        AsCPD_Learning_Summary__c CPDlearning2 = new AsCPD_Learning_Summary__c();
        CPDlearning2.Name = 'testing cpd learning';
        CPDlearning2.CPD_Planner__c = newCPD.Id;
        CPDlearning2.recordTypeId = planActRecId;
        CPDlearning2.AS_Training_Plan_Record_ID__c = String.valueOf(tplan.Id);
        insert CPDlearning2;
        
        Training_Plan_Assignment__c updatetplanAss = new Training_Plan_Assignment__c();
        updatetplanAss.Id = tplanAss.Id;
        updatetplanAss.Status__c = 'Completed';
        update updatetplanAss;
        
        Training_Track__c TTrack = new Training_Track__c();
        TTrack.Name = 'Testing training track';
        TTrack.Enable_all_external_accounts__c = true;
        TTrack.Status__c = 'Active';
        TTrack.Achievement__c = achieve.Id;
        insert TTrack;
            
        Training_Track_Level__c TTrackLevel = new Training_Track_Level__c();
        TTrackLevel.Name = 'test training track level';
        TTrackLevel.Training_Track__c = TTrack.Id;
        insert TTrackLevel;
        
        Training_Track_Level_Item__c TTrackItem = new Training_Track_Level_Item__c();
        TTrackItem.Training_Plan__c = tplan.Id;
        TTrackItem.Training_Track_Level__c = TTrackLevel.Id;
        insert TTrackItem;
    }
    
    static testMethod void updateTrainingPlanAssign(){
        Training_Plan_Assignment__c TPlanAssign = [SELECT Id FROM Training_Plan_Assignment__c WHERE Status__c = 'Not Started'];
        Training_Plan_Assignment__c updateTPlanAssign = new Training_Plan_Assignment__c();
        updateTPlanAssign.Id = TPlanAssign.Id; 
        updateTPlanAssign.Status__c = 'In Progress';
        update updateTPlanAssign;
    }
    
    static testMethod void insertOtherData(){
        
        List<User> adminUsers = TestUtilClass.createUsers(1,'System Administrator');
        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Id planActRecId = Schema.SObjectType.AsCPD_Learning_Summary__c.getRecordTypeInfosByName().get('Planned Activity').getRecordTypeId();
        
        Account acc = new Account();
        acc.FirstName = 'Sample Person2';
        acc.LastName = 'Account2';
        acc.PersonEmail = 'person2@test.com';
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
        indiUser.Email = 'person2@test.com';
        indiUser.Username = 'person2@test.com';
        indiUser.CommunityNickname = acc.FirstName + acc.LastName + AS_commonFunction.generateRandomIntString(2);
        indiUser.emailencodingkey='UTF-8';
        indiUser.languagelocalekey='en_US'; 
        indiUser.localesidkey='en_AU'; 
        indiUser.timezonesidkey='GMT';
		insert indiUser;
        
        Training_Plan__c tplan = new Training_Plan__c();
        tplan.AS_Training_Plan_Type__c = 'Australian Pharmacist';
        tplan.Name = 'Testing TPlan';
        tplan.Type__c = 'Public';
        tplan.Status__c = 'Active';
        insert tplan;
        
        List<Training_Plan_Assignment__c> tplanAssign = new List<Training_Plan_Assignment__c>();
        Training_Plan_Assignment__c tplanAss = new Training_Plan_Assignment__c();
        tplanAss.User__c = adminUsers[0].Id;
        tplanAss.Status__c = 'Not Started';
        tplanAss.Training_Plan__c = tplan.Id;
        insert tplanAss;
        
        Training_Plan_Assignment__c tplanAss2 = new Training_Plan_Assignment__c();
        tplanAss2.User__c = adminUsers[0].Id;
        tplanAss2.Status__c = 'Completed';
        tplanAss2.Training_Plan__c = tplan.Id;
        insert tplanAss2;
        
        Training_Plan_Assignment__c tplanAss3 = new Training_Plan_Assignment__c();
        tplanAss3.User__c = indiUser.Id;
        tplanAss3.Status__c = 'Not Started';
        tplanAss3.Training_Plan__c = tplan.Id;
        insert tplanAss3;
        
        Id activeCPDRecId = Schema.SObjectType.AsCPDPlanner__c.getRecordTypeInfosByName().get('Active CPD Planner').getRecordTypeId();
        AsCPDPlanner__c newCPD = new AsCPDPlanner__c();
        newCPD.AsUser__c = indiUser.Id;
        newCPD.Name = 'testing CPD';
        newCPD.AS_Current_CPD_Plan__c = true;
        newCPD.AS_Plan_Year__c = '2019';
        newCPD.AsStartDate__c = Date.today();
        newCPD.AsEndDate__c = Date.today().addDays(30);
        newCPD.recordTypeId = activeCPDRecId;
        insert newCPD;
        
        AsCPD_Learning_Summary__c CPDlearning = new AsCPD_Learning_Summary__c();
        CPDlearning.Name = 'testing cpd learning';
        CPDlearning.CPD_Planner__c = newCPD.Id;
        CPDlearning.recordTypeId = planActRecId;
        CPDlearning.AS_Training_Plan_Record_ID__c = String.valueOf(tplan.Id);
        insert CPDlearning;
        
    }
    
    static testMethod void deleteData(){
        List<Training_Plan_Assignment__c> delTPlanAssign = [SELECT Id FROM Training_Plan_Assignment__c WHERE Status__c = 'Not Started'];
        
        List<Training_Plan_Assignment__c> updateTpa = new List<Training_Plan_Assignment__c>();
        for(Training_Plan_Assignment__c tpa : delTPlanAssign){
            tpa.Status__c = 'Completed';
            updateTpa.add(tpa);
        }
        update updateTpa;
        delete delTPlanAssign[0];
    }
    
    static testMethod void callpostChatter(){
        List<Training_Plan_Assignment__c> TPlanAssign = [SELECT Id,Training_Plan__c,User__c,Community_Id__c FROM Training_Plan_Assignment__c WHERE Status__c = 'Completed'];
        TrainingPlanAssignmentHelper.postChatterNotifications(TPlanAssign);        
    }
}