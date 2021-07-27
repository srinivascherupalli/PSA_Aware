@isTest
public class DL_Events_Test {

    @TestSetup
    static void makeData(){
        ID profile_ID = [SELECT ID from Profile WHERE Name = 'Non Member Login User'].id;
        
        Account testAccount1 = new Account();
        testAccount1.FirstName = 'Adam';
        testAccount1.LastName = 'Baker';
        testAccount1.recordTypeId = [SELECT ID FROM RecordType WHERE Name = 'Person Account'].id;
        testAccount1.PersonEmail = 'Adam.Baker@psa.org.au.Test';
        testAccount1.Conference_ID__c = '01-01234';
        insert testAccount1;

        Account account1 = [SELECT ID,Name,personContactID,Conference_ID__c FROM Account WHERE PersonEmail = :testAccount1.PersonEmail];

        Contact cntct1 = [SELECT ID,Name,AccountID,Account.PSA_PSA_ID__c FROM Contact WHERE ID = :account1.PersonContactId];

        User user1 = new User();
        user1.Alias = 'BakerA';
        user1.Email = testAccount1.PersonEmail;
        user1.Username = testAccount1.PersonEmail;
        user1.EmailEncodingKey = 'UTF-8';
        user1.ContactId = cntct1.Id;
        user1.TimeZoneSidKey = 'Australia/Sydney';
        user1.ProfileId = profile_ID;
        user1.IsActive = true;
        user1.LanguageLocaleKey = 'en_US';
        user1.LastName = testAccount1.LastName;
        user1.LocaleSidKey = 'en_AU';
    
        insert user1;



        Account testAccount2 = new Account();
        testAccount2.FirstName = 'John';
        testAccount2.LastName = 'Citizen';
        testAccount2.recordTypeId = [SELECT ID FROM RecordType WHERE Name = 'Person Account'].id;
        testAccount2.PersonEmail = 'John.Citizen@psa.org.au.Test';
        testAccount2.Conference_ID__c = '02-01234';
        insert testAccount2;

        Account account2 = [SELECT ID,Name,personContactID,Conference_ID__c FROM Account WHERE PersonEmail = :testAccount2.PersonEmail];

        Contact cntct2 = [SELECT ID,Name,AccountID,Account.PSA_PSA_ID__c FROM Contact WHERE ID = :account2.PersonContactId];

        User user2 = new User();
        user2.Alias = 'CitizenJ';
        user2.Email = testAccount2.PersonEmail;
        user2.Username = testAccount2.PersonEmail;
        user2.EmailEncodingKey = 'UTF-8';
        user2.ContactId = cntct2.Id;
        user2.TimeZoneSidKey = 'Australia/Sydney';
        user2.ProfileId = profile_ID;
        user2.IsActive = true;
        user2.LanguageLocaleKey = 'en_US';
        user2.LastName = testAccount2.LastName;
        user2.LocaleSidKey = 'en_AU';
        insert user2;


        List<Contact> contactList = [SELECT Id,FirstName,LastName FROM Contact];

        Campaign parentCampaign = new Campaign();
        parentCampaign.Name = 'Test Parent Campaign';
        parentCampaign.Status = 'In Progress';
        parentCampaign.Type = 'Seminar / Conference';
        parentCampaign.StartDate = Date.today().addDays(-3);
        parentCampaign.EndDate = Date.today().addDays(3);
        parentCampaign.Flow_Members_Down_Heirarchy__c = true;
        parentCampaign.Auto_Close__c = true;
        parentCampaign.IsActive = true;
        parentCampaign.AS_Region__c = 'ACT';
        insert parentCampaign;


        Campaign childCampaign1 = parentCampaign.clone(false,true); //passed/completed event
        childCampaign1.Flow_Members_Down_Heirarchy__c = false;
        childCampaign1.Name = 'Test Child Campaign 1';
        childCampaign1.AS_Start_Time__c = Datetime.now().addMinutes(-90);
        childCampaign1.AS_End_Time__c = Datetime.now().addMinutes(-30);
        childCampaign1.StartDate = null;
        childCampaign1.EndDate = null;
        childCampaign1.Auto_Close__c = true;
        childCampaign1.ParentId = parentCampaign.id;
        insert childCampaign1;


        Campaign childCampaign2 = childCampaign1.clone(false,true); //future event
        childCampaign2.Name = 'Test Child Campaign 2';
        childCampaign2.AS_Start_Time__c = Datetime.now().addMinutes(30);
        childCampaign2.AS_End_Time__c = Datetime.now().addMinutes(90);
        insert childCampaign2;


        Campaign childCampaign3 = childCampaign1.clone(false,true); //future event
        childCampaign3.Name = 'Test Child Campaign 3';
        insert childCampaign3;


        Campaign childCampaign4 = childCampaign1.clone(false,true); //future event
        childCampaign4.Name = 'Test Child Campaign 4';
        insert childCampaign4;


        Campaign childCampaign5 = childCampaign1.clone(false,true); //future event
        childCampaign5.Name = 'Test Child Campaign 5';
        insert childCampaign5;


        Campaign childCampaign6 = childCampaign1.clone(false,true); //future event
        childCampaign6.Name = 'Test Child Campaign 6';
        insert childCampaign6;


        childCampaign1.Back_to_Back_Session__c = childCampaign2.id;
        update childCampaign1;

        childCampaign2.Back_to_Back_Session__c = childCampaign3.id;
        update childCampaign2;

        childCampaign3.Back_to_Back_Session__c = childCampaign4.id;
        update childCampaign3;

        childCampaign4.Back_to_Back_Session__c = childCampaign5.id;
        update childCampaign4;

        childCampaign5.Back_to_Back_Session__c = childCampaign6.id;
        update childCampaign5;


        


        System.debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        System.debug(contactList);

        for(Contact cntct : contactList){
            CampaignMember member = new CampaignMember();
            member.ContactId = cntct.Id;
            member.CampaignId = parentCampaign.Id;
            member.Status = 'Registered';

            insert member;
        }

        List<CampaignMember> parentMembers = [SELECT ID,Name,CampaignId,Status FROM CampaignMember WHERE CampaignId = :parentCampaign.Id];
        System.debug('ParentMembers:'+ parentMembers);


    }


    @isTest
    public static void TestGetCampaigns_True(){
        System.debug('////TestGetCampaigns_True////');
        

        test.startTest();
            List<Campaign> campaigns = DL_Events.GetCampaigns(true);
        test.stopTest();

        System.assert(campaigns.size() > 0);
        System.debug('campaigns:'+campaigns);
    }


    @isTest
    public static void TestGetCampaigns_False(){
        System.debug('////TestGetCampaigns_False////');
        

        test.startTest();
            List<Campaign> campaigns = DL_Events.GetCampaigns(false);
        test.stopTest();

        System.assert(campaigns.size() > 0);
        System.debug('campaigns:'+campaigns);
    }


    @isTest
    public static void TestGetCampaignSessions_True(){
        System.debug('////TestGetCampaignSessions_True////');
        Id campaignId = [SELECT Id, Name, Flow_Members_Down_Heirarchy__c FROM Campaign WHERE Flow_Members_Down_Heirarchy__c = true].id;

        test.startTest();
            List<Campaign> campaigns = DL_Events.GetCampaignSessions(String.valueOf(campaignId), 'true');
        test.stopTest();

        System.assert(campaigns.size() > 0);
        System.debug('campaigns:'+campaigns);
    }


    @isTest
    public static void TestGetCampaignSessions_False(){
        System.debug('////TestGetCampaignSessions_False////');
        Id campaignId = [SELECT Id, Name, Flow_Members_Down_Heirarchy__c FROM Campaign WHERE Flow_Members_Down_Heirarchy__c = true].id;

        test.startTest();
            List<Campaign> campaigns = DL_Events.GetCampaignSessions(String.valueOf(campaignId), 'false');
        test.stopTest();

        System.assert(campaigns.size() > 0);
        System.debug('campaigns:'+campaigns);
    }


    @isTest
    public static void TestGetCampaignSessions_null(){
        System.debug('////TestGetCampaignSessions_null////');
        Id campaignId = [SELECT Id, Name, Flow_Members_Down_Heirarchy__c FROM Campaign WHERE Flow_Members_Down_Heirarchy__c = true].id;

        test.startTest();
            List<Campaign> campaigns = DL_Events.GetCampaignSessions(String.valueOf(campaignId), '');
        test.stopTest();

        System.assert(campaigns.size() > 0);
        System.debug('campaigns:'+campaigns);
    }


    @isTest
    public static void TestGetImageURL(){
        System.debug('////TestGetImageURL////');
        try{
            Id campaignId = [SELECT Id, Name, Flow_Members_Down_Heirarchy__c FROM Campaign WHERE Flow_Members_Down_Heirarchy__c = true].id;

            test.startTest();
                String url = DL_Events.GetImageURL(String.valueOf(campaignId));
            test.stopTest();
        }
        
        catch(Exception e){
            System.debug(e.getMessage());
        }
    }


    @isTest
    public static void TestGetMember(){
        System.debug('////TestGetMember////');
        Contact testContact = [SELECT Id,LastName,Account.PSA_PSA_ID__c,Account.Conference_ID__c From Contact WHERE LastName = 'Citizen'];
        String psaId = testContact.Account.PSA_PSA_ID__c;
        String conferenceId = testContact.Account.Conference_ID__c;
        Test.startTest();
            DL_Events.GetMember(psaId);
            DL_Events.GetMember(conferenceId);
        Test.stopTest();
    }


    @isTest
    public static void TestSaveRFID(){
        System.debug('////TestSaveRFID////');
        Contact testContact1 = [SELECT Id,LastName,Account.PSA_PSA_ID__c From Contact WHERE LastName = 'Citizen'];
        Contact testContact2 = [SELECT Id,LastName,Account.PSA_PSA_ID__c,Account.Conference_ID__c From Contact WHERE LastName = 'Baker'];
        Campaign testParentCampaign = [SELECT Id,Name FROM Campaign WHERE Name = 'Test Parent Campaign'];

        String rfidNumber = '000559431';

        String psaID = testContact1.Account.PSA_PSA_ID__c;
        String conferenceId = testContact2.Account.Conference_ID__c;

        Test.startTest();
            DL_Events.SaveRFIDNumber(psaID, rfidNumber);
            DL_Events.SaveRFIDNumber(conferenceId, rfidNumber);
        Test.stopTest();
    }


    @isTest
    public static void TestProcessScan_RFID_In(){
        System.debug('////TestProcessScan_RFID_In////');
        Test.startTest();
            Contact testContact1 = [SELECT Id,LastName,Account.PSA_PSA_ID__c From Contact WHERE LastName = 'Citizen'];
            Campaign testParentCampaign = [SELECT Id,Name FROM Campaign WHERE Name = 'Test Parent Campaign'];
            String psaID = testContact1.Account.PSA_PSA_ID__c;
            String rfidNumber = '000559431';
            Id parentId = testParentCampaign.Id;

            DL_Events.SaveRFIDNumber(psaID, rfidNumber);

            DL_Events.ProcessScan_ID(true, rfidNumber, parentId);
        Test.stopTest();
    }


    @isTest
    public static void TestProcessScan_RFID_Out(){
        System.debug('////TestProcessScan_RFID_Out////');
        Test.startTest();
            Contact testContact1 = [SELECT Id,LastName,Account.PSA_PSA_ID__c From Contact WHERE LastName = 'Citizen'];
            Campaign testParentCampaign = [SELECT Id,Name FROM Campaign WHERE Name = 'Test Parent Campaign'];

            String psaID = testContact1.Account.PSA_PSA_ID__c;
            String rfidNumber = '000559431';
            Id parentId = testParentCampaign.Id;

            DL_Events.SaveRFIDNumber(psaID, rfidNumber);

            DL_Events.ProcessScan_ID(false, rfidNumber, parentId);
        Test.stopTest();
    }


    @isTest
    public static void TestProcessScan_RFID_Fail_In(){
        System.debug('////TestProcessScan_RFID_Fail_In////');
        Test.startTest();
            Contact testContact1 = [SELECT Id,LastName,Account.PSA_PSA_ID__c From Contact WHERE LastName = 'Citizen'];
            Campaign testParentCampaign = [SELECT Id,Name FROM Campaign WHERE Name = 'Test Parent Campaign'];
            Id parentId = testParentCampaign.Id;
            String rfidNumber = '000000000';
        
            DL_Events.ProcessScan_ID(true, rfidNumber, parentId);
        Test.stopTest();
    }


    @isTest
    public static void TestProcessScan_RFID_Fail_Out(){
        System.debug('////TestProcessScan_RFID_Fail_Out////');
        Test.startTest();
            Contact testContact1 = [SELECT Id,LastName,Account.PSA_PSA_ID__c From Contact WHERE LastName = 'Citizen'];
            Campaign testParentCampaign = [SELECT Id,Name FROM Campaign WHERE Name = 'Test Parent Campaign'];
            Id parentId = testParentCampaign.Id;
            String rfidNumber = '000000000';
        
           DL_Events.ProcessScan_ID(false, rfidNumber, parentId);
        Test.stopTest();
    }


    @isTest
    public static void TestProcessScan_psaId_campaign1(){
        System.debug('////TestProcessScan_psaId_campaign1////');
        Test.startTest();
            Contact testContact1 = [SELECT Id,LastName,Account.PSA_PSA_ID__c From Contact WHERE LastName = 'Citizen'];
            Campaign cmpaign = [SELECT Id, Name, ParentId FROM Campaign WHERE Name = 'Test Child Campaign 1'];
            Id cmpaignId = cmpaign.Id;

            CampaignMember newMember = new CampaignMember();
            newMember.ContactId = testContact1.Id;
            newMember.CampaignId = cmpaignId;
            newMember.Status = 'Registered';

            insert newMember;
            
            System.debug(cmpaign);

            DL_CampaignMember_TriggerHandler.FlowMembersHandler(cmpaign.ParentId);

            List<CampaignMember> members = [SELECT Id,Name,Status,CampaignId FROM CampaignMember WHERE CampaignId = :cmpaign.id];
            System.debug('///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////');
            System.debug(members);

            for(CampaignMember member : members){
                member.Status = 'Attending';
            }

            update members;

            CampaignMember cmpaignMember = [SELECT ID,Name,ContactId,CampaignId FROM CampaignMember WHERE CampaignId = :cmpaign.Id LIMIT 1];
            System.debug(cmpaignMember);

            Contact cntact = [SELECT ID,Name,Account.PSA_PSA_ID__c,Account.Conference_ID__c FROM Contact WHERE Id = :cmpaignMember.ContactId];
            System.debug(cntact);

            String psaId = cntact.Account.PSA_PSA_ID__c;
            String conferenceId = cntact.Account.Conference_ID__c;

            String scanIn_Response = DL_Events.ProcessScan_Id(true, conferenceId, cmpaignId);
            scanIn_Response = DL_Events.ProcessScan_Id(true, conferenceId, cmpaignId);
            String scanOut_Response = DL_Events.ProcessScan_Id(false, conferenceId, cmpaignId);
            scanOut_Response = DL_Events.ProcessScan_Id(false, conferenceId, cmpaignId);
            scanIn_Response = DL_Events.ProcessScan_psaId(true, psaId, cmpaignId);
            scanIn_Response = DL_Events.ProcessScan_psaId(true, psaId, cmpaignId);
            scanOut_Response = DL_Events.ProcessScan_psaId(false, psaId, cmpaignId);
            scanOut_Response = DL_Events.ProcessScan_psaId(false, psaId, cmpaignId);
        Test.stopTest();

        System.assert(scanIn_Response != null);
        System.assert(scanOut_Response != null);
    }


    @isTest
    public static void TestProcessScan_psaId_campaign2(){
        System.debug('////TestProcessScan_Id_campaign2////');
        Test.startTest();
            Contact testContact1 = [SELECT Id,LastName,Account.PSA_PSA_ID__c From Contact WHERE LastName = 'Citizen'];
            Campaign cmpaign = [SELECT Id, Name, ParentId FROM Campaign WHERE Name = 'Test Child Campaign 2'];
            Id cmpaignId = cmpaign.Id;

            CampaignMember newMember = new CampaignMember();
            newMember.ContactId = testContact1.Id;
            newMember.CampaignId = cmpaignId;
            newMember.Status = 'Registered';

            insert newMember;
            
            System.debug(cmpaign);

            List<CampaignMember> members = [SELECT Id,Name,Status,CampaignId FROM CampaignMember WHERE CampaignId = :cmpaign.id];
            System.debug(members);

            for(CampaignMember member : members){
                member.Status = 'Registered';
            }

            update members;

            CampaignMember cmpaignMember = [SELECT ID,Name,ContactId,CampaignId FROM CampaignMember WHERE CampaignId = :cmpaign.Id LIMIT 1];
            System.debug(cmpaignMember);

            Contact cntact = [SELECT ID,Name,Account.PSA_PSA_ID__c FROM Contact WHERE Id = :cmpaignMember.ContactId];
            System.debug(cntact);

            String psaId = cntact.Account.PSA_PSA_ID__c;
        
            String scanIn_Response = DL_Events.ProcessScan_psaId(true, psaId, cmpaignId);
            scanIn_Response = DL_Events.ProcessScan_psaId(true, psaId, cmpaignId);
            String scanOut_Response = DL_Events.ProcessScan_psaId(false, psaId, cmpaignId);
            scanOut_Response = DL_Events.ProcessScan_psaId(false, psaId, cmpaignId);
            scanIn_Response = DL_Events.ProcessScan_psaId(true, psaId, cmpaignId);
            scanIn_Response = DL_Events.ProcessScan_psaId(true, '', cmpaignId);
            String cron = '0 0 * * * ?';
            System.schedule('Schedule Events Close Test1', cron, new DL_Events_Schedulable()); ///ADDED THIS LINE
        Test.stopTest();

        System.assert(scanIn_Response != null);
        System.assert(scanOut_Response != null);
    }


    @isTest
    public static void TestProcessScan_psaId_campaign3(){
        System.debug('////TestProcessScan_psaId_campaign3////');
        Test.startTest();
            Contact testContact1 = [SELECT Id,LastName,Account.PSA_PSA_ID__c From Contact WHERE LastName = 'Citizen'];
            Campaign cmpaign = [SELECT Id, Name, ParentId FROM Campaign WHERE Name = 'Test Child Campaign 3'];
            Id cmpaignId = cmpaign.Id;

            CampaignMember newMember = new CampaignMember();
            newMember.ContactId = testContact1.Id;
            newMember.CampaignId = cmpaignId;
            newMember.Status = 'Registered';

            insert newMember;
            
            System.debug(cmpaign);

            //DL_CampaignMember_TriggerHandler.FlowMembersHandler(cmpaign.ParentId);

            List<CampaignMember> members = [SELECT Id,Name,Status,CampaignId FROM CampaignMember WHERE CampaignId = :cmpaign.id];

            for(CampaignMember member : members){
                member.Status = 'Checked In';
            }

            update members;

            CampaignMember cmpaignMember = [SELECT ID,Name,ContactId,CampaignId FROM CampaignMember WHERE CampaignId = :cmpaign.Id LIMIT 1];
            System.debug(cmpaignMember);

            Contact cntact = [SELECT ID,Name,Account.PSA_PSA_ID__c FROM Contact WHERE Id = :cmpaignMember.ContactId];
            System.debug(cntact);

            String psaId = cntact.Account.PSA_PSA_ID__c;
        
            String cron = '0 0 * * * ?';
            System.schedule('Schedule Events Close Test2', cron, new DL_Events_Schedulable());
            String scanIn_Response = DL_Events.ProcessScan_psaId(true, psaId, cmpaignId);
            scanIn_Response = DL_Events.ProcessScan_psaId(true, psaId, cmpaignId);
            String scanOut_Response = DL_Events.ProcessScan_psaId(false, psaId, cmpaignId);
            scanOut_Response = DL_Events.ProcessScan_psaId(false, psaId, cmpaignId);
        Test.stopTest();

        System.assert(scanIn_Response != null);
        System.assert(scanOut_Response != null);
    }


    @isTest
    public static void TestFlowDeleteMembers(){
        System.debug('////TestFlowDeleteMembers////');
        Test.startTest();
            Id campaignId = [SELECT Id, Name, Flow_Members_Down_Heirarchy__c FROM Campaign WHERE Flow_Members_Down_Heirarchy__c = true].id;

            CampaignMember member = [SELECT Id,Name,CampaignId FROM CampaignMember WHERE CampaignId = :campaignId LIMIT 1];
        
            delete member;
        Test.stopTest();


        Campaign cmpaign = [SELECT Id,Name,ParentId From Campaign WHERE ParentId = :campaignId LIMIT 1];

        List<CampaignMember> campaignMembers = [SELECT ID,Name,ContactId,CampaignId FROM CampaignMember WHERE CampaignId = :cmpaign.Id ];

        DL_CampaignMember_TriggerHandler.DeleteFlowCampaignMembers(campaignMembers);


        System.assert(!campaignMembers.contains(member));
        System.debug(campaignMembers);
    }


    @isTest
    public static void TestFlowSaveMembers(){
        System.debug('////TestFlowSaveMembers////');

        ID profile_ID = [SELECT ID from Profile WHERE Name = 'Non Member Login User'].id;
        
        Account testAccount1 = new Account();
        testAccount1.FirstName = 'Tony';
        testAccount1.LastName = 'Jizz';
        testAccount1.recordTypeId = [SELECT ID FROM RecordType WHERE Name = 'Person Account'].id;
        testAccount1.PersonEmail = 'Tony.Jizz@psa.org.au.Test';
        testAccount1.Conference_ID__c = '01-012345';
        insert testAccount1;

        Account account1 = [SELECT ID,Name,personContactID,Conference_ID__c FROM Account WHERE PersonEmail = :testAccount1.PersonEmail];

        Contact cntct1 = [SELECT ID,Name,AccountID,Account.PSA_PSA_ID__c FROM Contact WHERE ID = :account1.PersonContactId];

        User user1 = new User();
        user1.Alias = 'JizzT';
        user1.Email = testAccount1.PersonEmail;
        user1.Username = testAccount1.PersonEmail;
        user1.EmailEncodingKey = 'UTF-8';
        user1.ContactId = cntct1.Id;
        user1.TimeZoneSidKey = 'Australia/Sydney';
        user1.ProfileId = profile_ID;
        user1.IsActive = true;
        user1.LanguageLocaleKey = 'en_US';
        user1.LastName = testAccount1.LastName;
        user1.LocaleSidKey = 'en_AU';
        insert user1;

        Campaign cmpaign = [SELECT Id, Name, Flow_Members_Down_Heirarchy__c FROM Campaign WHERE Flow_Members_Down_Heirarchy__c = true LIMIT 1];

        CampaignMember member = new CampaignMember();
        member.ContactId = cntct1.Id;
        member.CampaignId = cmpaign.Id;
        member.Status = 'Registered';
        insert member;

        Test.startTest();
            List<Campaign> cmpaigns = [SELECT Id,Name,ParentId From Campaign WHERE ParentId = :cmpaign.Id]; //childCampaign

            DL_CampaignMember_TriggerHandler.FlowMembersHandler(cmpaign.Id);
            DL_CampaignMember_TriggerHandler.FlowMembers(cmpaigns[0].Id);
            DL_CampaignMember_TriggerHandler.CheckInMembersHandler(cmpaigns[0].Id);
        Test.stopTest();
    }


    @isTest
    public static void TestBackToBack(){
        System.debug('////////TestBackToBack/////////');

        Test.startTest();
            Campaign child2Cmpaign = [Select Id,Name,AS_End_Time__c from Campaign WHERE Name = 'Test Child Campaign 2'];
            Campaign child3Cmpaign = [Select Id,Name,AS_End_Time__c from Campaign WHERE Name = 'Test Child Campaign 3'];
            Campaign child4Cmpaign = [Select Id,Name from Campaign WHERE Name = 'Test Child Campaign 4'];
            List<Account> newAccounts = new List<Account>();
            List<CampaignMember> newMembers = new List<CampaignMember>();
            ID profile_ID = [SELECT ID from Profile WHERE Name = 'Non Member Login User'].id;

            for(Integer i = 0; i < 51; i++){
                Account testAccount1 = new Account();
                testAccount1.FirstName = 'Jeff';
                testAccount1.LastName = 'Fizz' + i;
                testAccount1.recordTypeId = [SELECT ID FROM RecordType WHERE Name = 'Person Account'].id;
                testAccount1.PersonEmail = 'Jeff.Fizz'+i+'@psa.org.au.Test';
                testAccount1.Conference_ID__c = '0'+i+'-0123456';
                newAccounts.add(testAccount1);
            }

            insert newAccounts;

            List<Account> savedAccounts = [SELECT ID,Name,personContactID,Conference_ID__c FROM Account];

            for(Account accnt : savedAccounts){
                CampaignMember member = new CampaignMember();
                member.ContactId = accnt.PersonContactId;
                member.CampaignId = child3Cmpaign.Id;
                member.Status = 'Attending';
                newMembers.add(member);

                CampaignMember member2 = new CampaignMember();
                member2.ContactId = accnt.PersonContactId;
                member2.CampaignId = child4Cmpaign.Id;
                member2.Status = 'Registered';
                newMembers.add(member2);

                CampaignMember member3 = new CampaignMember();
                member3.ContactId = accnt.PersonContactId;
                member3.CampaignId = child2Cmpaign.Id;
                member3.Status = 'Checked In';
                newMembers.add(member3);
            }

            insert newMembers;

            child3Cmpaign.AS_End_Time__c = Datetime.now().addMinutes(-30);
            update child3Cmpaign;

            child2Cmpaign.AS_End_Time__c = Datetime.now().addMinutes(-30);
            update child3Cmpaign;

            String cron = '0 0 * * * ?';
            System.schedule('Schedule Events Back To Back Test', cron, new DL_Events_Schedulable());

        Test.stopTest();
    }


    @isTest
    public static void TestEventsSchedulable(){
        System.debug('////TestEventsSchedulable////');
        Test.startTest();
            String cron = '0 0 * * * ?';
            System.schedule('Schedule Events Close Test', cron, new DL_Events_Schedulable());
        Test.stopTest();
    }


    @isTest
    public static void TestDeleteRFIDNumber(){
        System.debug('////TestDeleteRFIDNumber////');
        Campaign testParentCampaign = [SELECT Id,Name FROM Campaign WHERE Name = 'Test Parent Campaign'];
        Id testParentId = testParentCampaign.Id;

        Test.startTest();
           DL_Events.DeleteRFIDNumbers(testParentId);
        Test.stopTest();
    }


    private static String GetCRONExpression(Datetime dt) {
        return ('' + dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year());
    }

}