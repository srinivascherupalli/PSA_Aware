/**
 * Test class for the TrainingTrackDetailCtrl_Lightning class
 * 
 * @author	Davanti:
 * @author	LToohey (Davanti),
 * @since	29/07/2020 
 * @date	29/07/2020 - LToohey (Davanti): created initial class structure
 * @see		TrainingTrackDetailCtrl_Lightning 
 */
@isTest
private class TestTrainTrackDetailCtrl_Lightning {
    /**
     * @author	Davanti:
     * @author	LToohey (Davanti),
     * @since	03/08/2020 
     * @see		TrainingTrackDetailCtrl_Lightning#GetTrainingTrackState
     */
    static testMethod void testGetTrainingTrackState_Member() {

        //Member user
        List<User> theUser = [Select Id, AccountId,Account.PersonEmail,Contact.AccountId from User where Email = 'person@test.com' ];
        System.debug('THE USER (@*#$: ' + theUser);
                   
        List<Training_Track__c> tracks = [select id,name from Training_Track__c];
        List<Training_Track_Level_Item__c> trackItems = [select id,name from Training_Track_Level_Item__c];
        
        List<Training_Track__Share> shares = new List<Training_Track__Share>();

        for(Training_Track__c t : tracks){
            Training_Track__Share tShr  = new Training_Track__Share();
            tShr.ParentId = t.Id;
            tShr.UserOrGroupId = theUser.get(0).Id;
            tShr.AccessLevel = 'Read';
            shares.add(tShr);
        }
        insert shares;

        TestTrainingTrackData.createSampleData();

        //Create products and pricebook entry
        PriceBook2 pb = new PriceBook2(Name='PSA Member',IsActive=true);
        insert pb;
        
        Product2 prod = new Product2(IsActive = true, Name = 'Test product 1', ProductCode = 'PSACVworkshop', Family = 'Courses');
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, 
                                                Product2Id = prod.Id,
                                                UnitPrice = 200, 
                                                IsActive = true);
        insert pbe;

        //Create learning package
        Learning_Package__c lp = new Learning_Package__c( Name ='LP Test');
        insert lp;
        Learning_Package__c lp2 = new Learning_Package__c( Name ='LP Test', AS_Event_selection__c=true);
        insert lp2;
        
        Training_Track__c newTT = [Select Name, Id, Product__c,  AS_Track_Type__c, AS_Learning_Package__c FROM Training_Track__c LIMIT 1];
        newTT.Name='TT1';
        newTT.Product__c=prod.Id;
        newTT.AS_Track_Type__c='Diploma';
        newTT.AS_Learning_Package__c=lp.Id;
        //Training_Track__c newTT = new Training_Track__c( Name = 'TT1', Product__c=prod.Id, AS_Track_Type__c = 'Diploma', AS_Learning_Package__c = lp.Id );
        update newTT;
        Training_Track__c newTT2 = new Training_Track__c( Name = 'TT1', Product__c=prod.Id, AS_Track_Type__c = 'Diploma', AS_Learning_Package__c = lp2.Id );
        insert newTT2;

        Test.startTest();
            System.runAs(theUser.get(0)){
                //Get state from page init
                TrainingTrackDetailCtrl_Lightning.pageStateWrapper state = TrainingTrackDetailCtrl_Lightning.getTrainingTrackState(newTT.Id);
                TrainingTrackDetailCtrl_Lightning.pageStateWrapper state2 = TrainingTrackDetailCtrl_Lightning.getTrainingTrackState(newTT2.Id);
                //Purchase Training Track
                state.canViewTrainPlan = true;
                state2.canViewTrainPlan = true;
                System.debug('Training Track STATE!@()#: ' + JSON.serializePretty(state));
                TrainingTrackDetailCtrl_Lightning.pageStateWrapper state3 = TrainingTrackDetailCtrl_Lightning.purchase(state);
                TrainingTrackDetailCtrl_Lightning.pageStateWrapper state4 = TrainingTrackDetailCtrl_Lightning.purchase(state2);
                
                //Update training track to Member Only (Free)
                state3.trackTy.AS_Track_Type__c = 'Member Only (Free)';
                TrainingTrackDetailCtrl_Lightning.pageStateWrapper state5 = TrainingTrackDetailCtrl_Lightning.purchase(state3);
                
                //Update training track to Paid
                state3.trackTy.AS_Track_Type__c = 'Paid';
                TrainingTrackDetailCtrl_Lightning.pageStateWrapper state6 = TrainingTrackDetailCtrl_Lightning.purchase(state3);
                
                //Update training track to Member Benefit
                state3.trackTy.AS_Track_Type__c = 'Member Benefit';
                TrainingTrackDetailCtrl_Lightning.pageStateWrapper state7 = TrainingTrackDetailCtrl_Lightning.purchase(state3);
                
                //Update training track to Member Only (Paid)
                state3.trackTy.AS_Track_Type__c = 'Member Only (Paid)';
                TrainingTrackDetailCtrl_Lightning.pageStateWrapper state8 = TrainingTrackDetailCtrl_Lightning.purchase(state3);
                
                //Update training track to Public
                state3.trackTy.AS_Track_Type__c = 'Public';
                TrainingTrackDetailCtrl_Lightning.pageStateWrapper state9 = TrainingTrackDetailCtrl_Lightning.purchase(state3);
            }
        Test.stopTest();
    }

    /**
     * @author	Davanti:
     * @author	LToohey (Davanti),
     * @since	03/08/2020 
     * @see		TrainingTrackDetailCtrl_Lightning#GetTrainingTrackState
     */
    static testMethod void testGetTrainingTrackState_nonMember() {

        //Non Member user
        List<User> theUser = [Select Id, AccountId,Account.PersonEmail,Contact.AccountId from User where Email = 'person1@test.com' ];
        System.debug('THE USER (@*#$: ' + theUser);
                   
        List<Training_Track__c> tracks = [select id,name from Training_Track__c];
        List<Training_Track_Level_Item__c> trackItems = [select id,name from Training_Track_Level_Item__c];
        
        List<Training_Track__Share> shares = new List<Training_Track__Share>();

        for(Training_Track__c t : tracks){
            Training_Track__Share tShr  = new Training_Track__Share();
            tShr.ParentId = t.Id;
            tShr.UserOrGroupId = theUser.get(0).Id;
            tShr.AccessLevel = 'Read';
            shares.add(tShr);
        }
        insert shares;

        TestTrainingTrackData.createSampleData();
        
        Learning_Package__c lp = new Learning_Package__c( Name ='LP Test');
        insert lp;
        Learning_Package__c lp2 = new Learning_Package__c( Name ='LP Test', AS_Event_selection__c=true);
        insert lp2;
        
        Training_Track__c newTT = new Training_Track__c( Name = 'TT1', AS_Track_Type__c = 'Diploma', AS_Learning_Package__c = lp.Id, PSA_Accreditation_Expiry_Date__c = Date.newInstance(2999, 12, 31) );
        insert newTT;
        Training_Track__c newTT2 = new Training_Track__c( Name = 'TT1', AS_Track_Type__c = 'Diploma', AS_Learning_Package__c = lp2.Id, PSA_Accreditation_Expiry_Date__c = Date.newInstance(2999, 12, 31) );
        insert newTT2;

        Test.startTest();
            System.runAs(theUser.get(0)){
                //Get state from page init
                TrainingTrackDetailCtrl_Lightning.pageStateWrapper state = TrainingTrackDetailCtrl_Lightning.getTrainingTrackState(newTT.Id);
                TrainingTrackDetailCtrl_Lightning.pageStateWrapper state2 = TrainingTrackDetailCtrl_Lightning.getTrainingTrackState(newTT2.Id);
                //Purchase Training Track
                System.debug('Training Track STATE!@()#: ' + JSON.serializePretty(state));
                TrainingTrackDetailCtrl_Lightning.pageStateWrapper state3 = TrainingTrackDetailCtrl_Lightning.purchase(state);
                TrainingTrackDetailCtrl_Lightning.pageStateWrapper state4 = TrainingTrackDetailCtrl_Lightning.purchase(state2);
                
                //Update training track to Member Only (Free)
                state3.trackTy.AS_Track_Type__c = 'Member Only (Free)';
                TrainingTrackDetailCtrl_Lightning.pageStateWrapper state5 = TrainingTrackDetailCtrl_Lightning.purchase(state3);
                
                //Update training track to Paid
                state3.trackTy.AS_Track_Type__c = 'Paid';
                TrainingTrackDetailCtrl_Lightning.pageStateWrapper state6 = TrainingTrackDetailCtrl_Lightning.purchase(state3);
                
                //Update training track to Member Benefit
                state3.trackTy.AS_Track_Type__c = 'Member Benefit';
                TrainingTrackDetailCtrl_Lightning.pageStateWrapper state7 = TrainingTrackDetailCtrl_Lightning.purchase(state3);
                
                //Update training track to Member Only (Paid)
                state3.trackTy.AS_Track_Type__c = 'Member Only (Paid)';
                TrainingTrackDetailCtrl_Lightning.pageStateWrapper state8 = TrainingTrackDetailCtrl_Lightning.purchase(state3);
                
                //Update training track to Public
                state3.trackTy.AS_Track_Type__c = 'Public';
                TrainingTrackDetailCtrl_Lightning.pageStateWrapper state9 = TrainingTrackDetailCtrl_Lightning.purchase(state3);
            }
        Test.stopTest();
    }
    /**
     * @author	Davanti:
     * @author	LToohey (Davanti),
     * @since	03/08/2020 
     * @see		TrainingTrackDetailCtrl_Lightning#GetTrainingTrackState
     */
    static testMethod void testGetTrainingTrackState_Admin() {

        //Non Member user
        List<User> theUser = [Select Id, AccountId,Account.PersonEmail,Contact.AccountId from User where Email = 'person1@test.com' ];
        System.debug('THE USER (@*#$: ' + theUser);
                   
        List<Training_Track__c> tracks = [select id,name from Training_Track__c];
        List<Training_Track_Level_Item__c> trackItems = [select id,name from Training_Track_Level_Item__c];
        
        List<Training_Track__Share> shares = new List<Training_Track__Share>();

        for(Training_Track__c t : tracks){
            Training_Track__Share tShr  = new Training_Track__Share();
            tShr.ParentId = t.Id;
            tShr.UserOrGroupId = theUser.get(0).Id;
            tShr.AccessLevel = 'Read';
            shares.add(tShr);
        }
        insert shares;

        TestTrainingTrackData.createSampleData();
        
        Learning_Package__c lp = new Learning_Package__c( Name ='LP Test');
        insert lp;
        
        Training_Track__c newTT = new Training_Track__c( Name = 'TT1', AS_Track_Type__c = 'Diploma', AS_Learning_Package__c = lp.Id, PSA_Accreditation_Expiry_Date__c = Date.newInstance(2999, 12, 31) );
        insert newTT;

        Test.startTest();
            System.runAs(theUser.get(0)){
                //Get state from page init
                TrainingTrackDetailCtrl_Lightning.pageStateWrapper state = TrainingTrackDetailCtrl_Lightning.getTrainingTrackState(newTT.Id);
                //call setter for coverage state wrapper
                state.mainAchievement = null;
                state.tpFAQs=null;
                state.listFAQs = null;
                state.mainAchievement = null;
                state.tpFAQs = null;
                state.mainFAQ = null;
                state.prerequsite1Plan = null;
                state.prerequsite2Plan = null;
                state.prerequsite3Plan = null;
                state.related1Plan = null;
                state.related2Plan = null;
                state.related3Plan = null;
                state.related4Plan = null;
            }
        Test.stopTest();
    }


    /**
     * create all the required data for use in these test methods
     */
    @testSetup
    static void setup(){
        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        List<Account> AsAccList = new List<Account>();
        
        Account acc = new Account();
        acc.FirstName = 'Sample Person';
        acc.LastName = 'Account';
        acc.PersonEmail = 'person@test.com';
        acc.RecordTypeId = personAccountId;
        AsAccList.add( acc );
        
        Account acc1 = new Account();
        acc1.FirstName = 'Sample Person1';
        acc1.LastName = 'Account1';
        acc1.PersonEmail = 'person1@test.com';
        acc1.RecordTypeId = personAccountId;
        AsAccList.add( acc1 );
        
        insert AsAccList;
        
        List<Profile> pro = [Select Id,Name from Profile where Name='Member Login User' LIMIT 1];
        Account accToUsed = [Select Id,PersonContactId from Account where Id = :AsAccList[0].Id limit 1];
        User indiUser = new User();
        indiUser.ContactId = accToUsed.PersonContactId;
        indiUser.profileid = (pro.size() > 0)?pro[0].Id:null;
        indiUser.FirstName = AsAccList[0].FirstName;
        indiUser.LastName = AsAccList[0].LastName;
        indiUser.Alias =string.valueof(AsAccList[0].FirstName.substring(0,1) + AsAccList[0].LastName.substring(0,2));
        indiUser.Email = 'person@test.com';
        indiUser.Username = 'person@test.com';
        indiUser.CommunityNickname = AsAccList[0].FirstName + AsAccList[0].LastName + AS_commonFunction.generateRandomIntString(2);
        indiUser.emailencodingkey='UTF-8';
        indiUser.languagelocalekey='en_US'; 
        indiUser.localesidkey='en_AU'; 
        indiUser.timezonesidkey='GMT';
        insert indiUser;
        
        List<Profile> pro1 = [Select Id,Name from Profile where Name='Non Member Login User' LIMIT 1];
        Account accToUsed1 = [Select Id,PersonContactId from Account where Id = :AsAccList[1].Id limit 1];
        User indiUser1 = new User();
        indiUser1.ContactId = accToUsed1.PersonContactId;
        indiUser1.profileid = (pro1.size() > 0)?pro1[0].Id:null;
        indiUser1.FirstName = AsAccList[1].FirstName;
        indiUser1.LastName = AsAccList[1].LastName;
        indiUser1.Alias =string.valueof(AsAccList[1].FirstName.substring(0,1) + AsAccList[1].LastName.substring(0,2));
        indiUser1.Email = 'person1@test.com';
        indiUser1.Username = 'person1@test.com';
        indiUser1.CommunityNickname = AsAccList[1].FirstName + AsAccList[1].LastName + AS_commonFunction.generateRandomIntString(2);
        indiUser1.emailencodingkey='UTF-8';
        indiUser1.languagelocalekey='en_US'; 
        indiUser1.localesidkey='en_AU'; 
        indiUser1.timezonesidkey='GMT';
        insert indiUser1;
        
    }

    static testMethod void testGetUserAccountDetails() {
        Id userId = UserInfo.getUserId();
        TrainingTrackDetailCtrl_Lightning.getUserAccountDetails(userId);
    }
}