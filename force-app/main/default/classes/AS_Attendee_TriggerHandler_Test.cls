@isTest
public class AS_Attendee_TriggerHandler_Test {
    static testmethod void MethodTest() {

        Id AsCampRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Event').getRecordTypeId();
        Id AsPersonAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Id AsBusinessAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        Id AsLearningRecordTypeId = Schema.SObjectType.Learning__c.getRecordTypeInfosByName().get('Event').getRecordTypeId();
        
        List<Account> AsAccountList = new List<Account>();
        Account acc1 = new Account(
            RecordTypeId=AsPersonAccountRecordTypeId,
            FirstName = 'Account First Name',
            LastName='Test Account',
            AS_Unique_Student_Identifier__c = '1212',
            PersonEmail = 'bannegroupuser@testorg.com',
	        AS_Membership_Status__pc = 'Current',
	        AS_AHPRA_Number__pc = '123456789'
        );
        AsAccountList.add( acc1 );

        Account acc2 = new Account(
            RecordTypeId=AsBusinessAccountRecordTypeId,
            Name='Test Account'
        );
        AsAccountList.add( acc2 );
        insert AsAccountList;
        
        Contact con = new Contact(
            LastName = 'TestContact',
            AccountId = AsAccountList[1].Id
        );
        insert con;

        List<Profile> pro = [Select Id,Name from Profile where Name='Member Login User' LIMIT 1];
        Account accToUsed = [Select Id,PersonContactId from Account where Id = :AsAccountList[0].Id limit 1];
        User indiUser = new User();
        indiUser.ContactId = accToUsed.PersonContactId;
        indiUser.profileid = (pro.size() > 0)?pro[0].Id:null;
        indiUser.FirstName = AsAccountList[0].FirstName;
        indiUser.LastName = AsAccountList[0].LastName;
        indiUser.Alias =string.valueof(AsAccountList[0].FirstName.substring(0,1) + AsAccountList[0].LastName.substring(0,2));
        indiUser.Email = 'person@test.com';
        indiUser.Username = 'person@test.com';
        indiUser.CommunityNickname = AsAccountList[0].FirstName + AsAccountList[0].LastName + AS_commonFunction.generateRandomIntString(2);
        indiUser.emailencodingkey='UTF-8';
        indiUser.languagelocalekey='en_US'; 
        indiUser.localesidkey='en_AU'; 
        indiUser.timezonesidkey='GMT';
        insert indiUser;

        Training_Plan__c AsTplan = new Training_Plan__c(
            Name = 'Test Training Plan',
            Type__c = 'Public',
            Status__c = 'Active'
        );
        insert AsTplan;
        Learning__c AsLearning = new Learning__c(
            RecordTypeId = AsLearningRecordTypeId,
            AS_Training_Plan__c = AsTplan.Id,
            Name = 'Test Learning',
            AS_Group_1_CPD__c = 2,
            AS_Group_2_CPD__c = 3

        );
        insert AsLearning;
        
        AS_Event__c evnt = new AS_Event__c(
            Name = 'Campaign Event'
        );
        insert evnt;

        Campaign camp = new Campaign(
            Learning__c = AsLearning.Id,
            Name = 'Alphasys Campaign',
            AS_Event__c = evnt.Id,
            Training_Plan__c = AsTplan.Id
        );
		insert camp;

        AS_Enrolled_Unit__c enrol = new AS_Enrolled_Unit__c();
        enrol.AS_Status__c = 'In Progress';
        enrol.AS_Result__c = 'Competent';
        insert enrol;    
   
        Training_Plan_Assignment__c tpa = new Training_Plan_Assignment__c();
        tpa.Training_Plan__c 			= AsTplan.Id;
        tpa.User__c 					= indiUser.Id;
        tpa.Status__c					= 'In Progress';
        tpa.Status__c					= 'Completed';
        //tpa.AS_Result__c				= 'Continuing';
        tpa.AS_Enrolled_Unit__c 	    = enrol.Id;
        insert tpa;
        
        Training_Plan_Section__c tps 	= new Training_Plan_Section__c();
        tps.Name 						= 'test tps';
        tps.Training_Plan__c 			= AsTplan.Id;
        insert tps;
        
        Training_Plan_Section_Assignment__c tpsa 	= new Training_Plan_Section_Assignment__c();
        tpsa.Status__c								= 'Completed';
        tpsa.Training_Plan_Assignment__c 			= tpa.Id;
        tpsa.User__c 								= indiUser.Id;
        tpsa.Training_Plan_Section__c				= tps.Id;
        insert tpsa;

        Learning_Assignment__c AsLearningAss = new Learning_Assignment__c(
            Learning__c = AsLearning.Id,
            Contact__c = con.Id,
            Training_Plan__c = AsTplan.Id,
            User__c = indiUser.Id,
            Training_Plan_Section__c = tps.Id,
            Training_Plan_Section_Assignment__c = tpsa.Id
        );
        insert AsLearningAss;

        Account forMemMatchCon = [Select Id,PersonContactId,AS_Unique_Student_Identifier__c from Account where PersonEmail = 'bannegroupuser@testorg.com' LIMIT 1];

        CampaignMember AsCampaignMember = new CampaignMember(
            Learning__c = AsLearning.Id,
            ContactId = forMemMatchCon.PersonContactId,
            CampaignId = camp.Id,
            Status = 'Attending'
        );
        insert AsCampaignMember;
        
        Map<Id,AS_Attendee__c> AsMapId = new Map<Id,AS_Attendee__c>();

        List<AS_Attendee__c> AsAttList = new List<AS_Attendee__c>();

        AS_Attendee__c att1 = new AS_Attendee__c(
            AS_Event__c = evnt.Id,
            AS_Attendee_First_Name__c = 'Test',
            AS_Attendee_Last_Name__c = 'Attend',
            AS_Status__c = AsCampaignMember.Status,
            AS_Agrees_to_terms_and_conditions__c = true,
            AS_User__c = con.Id
        );
        AsAttList.add( att1 );

        insert AsAttList;

       AsMapId.put( att1.Id, att1 );

        AS_Attendee_TriggerHandler.createCampaignMember( AsAttList );
        AS_Attendee_TriggerHandler.updateCampaignMember( AsAttList[0].Id );
       AS_Attendee_TriggerHandler.deleteCampaignMember( AsMapId );
       AS_Attendee_TriggerHandler.updateAttendee( AsAttList );
    }

}