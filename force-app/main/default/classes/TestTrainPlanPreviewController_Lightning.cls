/**
 * Test class for the TrainingPlanPreviewController_Lightning class
 * 
 * @author	Davanti:
 * @author	LToohey (Davanti),
 * @since	29/07/2020 
 * @date	29/07/2020 - LToohey (Davanti): created initial class structure
 * @see		TrainingPlanPreviewController_Lightning 
 */
@isTest
private class TestTrainPlanPreviewController_Lightning {
    
    /**
     * @author	Davanti:
     * @author	LToohey (Davanti),
     * @since	29/07/2020 
     * @see		TrainingPlanPreviewController_Lightning#GetTrainingPlanState
     */
    static testMethod void testGetTrainingPlanState_AdminUser() {
        //Run all class methods as admin user
        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(2,'Standard User');

        //Get URL
        String baseURL = TrainingPlanPreviewController_Lightning.getUrl();

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplans = [select id
                                            ,Enable_Self_Registration__c
                                            ,Self_Registration_Access__c
                                            from Training_Plan__c];

        System.assertEquals(1,tplans.size()); 
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;
        tplan.Self_Registration_Access__c = 'Public';
        tplan.type__c = 'Member Only (Free)';
        update tplan;

        //Insert a Training Track Level and items?
        TestTrainingTrackData.createSampleData();
        List<Training_Track_Level_Item__c> tTrackLvlItems = [Select Id, Name, Training_Track_Level__c, Training_Plan__c FROM Training_Track_Level_Item__c];
        for(Training_Track_Level_Item__c tlvl : tTrackLvlItems){
            tlvl.Training_Plan__c = tplan.Id;
        }
        update tTrackLvlItems;
        
        Test.startTest();   
            System.runAs(adminUsers.get(0)){
                //Get state from page init
                TrainingPlanPreviewController_Lightning.pageStateWrapper state = TrainingPlanPreviewController_Lightning.getTrainingPlanState(tplan.Id);
                //Register for training plan
                System.debug('Register for training plan: ' + JSON.serializePretty(state));
                TrainingPlanPreviewController_Lightning.pageStateWrapper state2 = TrainingPlanPreviewController_Lightning.registerForTrainingPlan(state);
                TrainingPlanPreviewController_Lightning.pageStateWrapper state3 = TrainingPlanPreviewController_Lightning.createTrainingPlanBookmark(state);
                Boolean futureCheck = TrainingPlanPreviewController_Lightning.check_futureJobComplete(tplan.Id);
            }
        Test.stopTest();
    }

    /**
     * @author	Davanti:
     * @author	LToohey (Davanti),
     * @since	29/07/2020 
     * @see		TrainingPlanPreviewController_Lightning#GetTrainingPlanState
     */
    static testMethod void testGetTrainingPlanState_MemberUser() {

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');

        Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = DateTime.now().getTime()+'Alpha';
        acc.LastName = DateTime.now().getTime()+'Sys';
        acc.recordTypeId = personAccRecId;
        acc.PersonEmail = 'bannegroupuser'+DateTime.now().getTime()+'@testorg.com';
        acc.AS_Membership_Status__pc = 'Current';
        acc.AS_AHPRA_Number__pc = '123456789';
        insert acc;
        
        Account forMemMatchCon = [Select Id,PersonContactId from Account where PersonEmail =:acc.PersonEmail LIMIT 1];
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Member Login User'];
        String uniqueUserName1 = 'memberuser' + DateTime.now().getTime() + '@testorg.com';
        
        User use = new User(Alias = generateRandomString(6), Email=acc.PersonEmail,
                            EmailEncodingKey='UTF-8', LastName=acc.LastName, LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,
                            ContactId = forMemMatchCon.PersonContactId,
                            TimeZoneSidKey='America/Los_Angeles',
                            isActive = true, 
                            UserName=uniqueUserName1);
        
        list<User> lmsUsers  = new List<User>();
        lmsUsers.add(use);
        insert lmsUsers;
        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
        //       TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplans = [select id
                                            ,Enable_Self_Registration__c
                                            ,Self_Registration_Access__c
                                            from Training_Plan__c];

        System.assertEquals(1,tplans.size());
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;  
        tplan.Self_Registration_Access__c = 'External';
        tplan.Type__c = 'Member Only (Free)';
        update tplan;         

        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                //Get state from page init
                TrainingPlanPreviewController_Lightning.pageStateWrapper stateMemFree = TrainingPlanPreviewController_Lightning.getTrainingPlanState(tplan.Id);
                //Register for training plan
                System.debug('Register for training plan: ' + JSON.serializePretty(stateMemFree));
                TrainingPlanPreviewController_Lightning.pageStateWrapper state2 = TrainingPlanPreviewController_Lightning.registerForTrainingPlan(stateMemFree);
                System.debug('STATE @***:' + JSON.serializePretty(state2));
                
                //Update to RTO type
                stateMemFree.tPlan.trainingPlan.Type__c = 'RTO';
                TrainingPlanPreviewController_Lightning.pageStateWrapper state3 = TrainingPlanPreviewController_Lightning.registerForTrainingPlan(stateMemFree);
                
                //Update to Event type
                stateMemFree.tPlan.trainingPlan.Type__c = 'Event';
                TrainingPlanPreviewController_Lightning.pageStateWrapper state4 = TrainingPlanPreviewController_Lightning.registerForTrainingPlan(stateMemFree);
                
                //Update to Event type
                stateMemFree.tPlan.trainingPlan.Type__c = 'Public';
                TrainingPlanPreviewController_Lightning.pageStateWrapper state5 = TrainingPlanPreviewController_Lightning.registerForTrainingPlan(stateMemFree);

            }
        Test.stopTest();
    }

    /**
     * @author	Davanti:
     * @author	LToohey (Davanti),
     * @since	29/07/2020 
     * @see		TrainingPlanPreviewController_Lightning#GetTrainingPlanState
     */
    static testMethod void testGetTrainingPlanState_MemberUser_Paid() {

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');

        Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = DateTime.now().getTime()+'Alpha';
        acc.LastName = DateTime.now().getTime()+'Sys';
        acc.recordTypeId = personAccRecId;
        acc.PersonEmail = 'bannegroupuser'+DateTime.now().getTime()+'@testorg.com';
        acc.AS_Membership_Status__pc = 'Current';
        acc.AS_AHPRA_Number__pc = '123456789';
        insert acc;
        
        Account forMemMatchCon = [Select Id,PersonContactId from Account where PersonEmail =:acc.PersonEmail LIMIT 1];
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Member Login User'];
        String uniqueUserName1 = 'memberuser' + DateTime.now().getTime() + '@testorg.com';
        
        User use = new User(Alias = generateRandomString(6), Email=acc.PersonEmail,
                            EmailEncodingKey='UTF-8', LastName=acc.LastName, LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,
                            ContactId = forMemMatchCon.PersonContactId,
                            TimeZoneSidKey='America/Los_Angeles',
                            isActive = true, 
                            UserName=uniqueUserName1);
        
        list<User> lmsUsers  = new List<User>();
        lmsUsers.add(use);
        insert lmsUsers;
        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
     //       TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        PriceBook2 pb = new PriceBook2(Name='PSA Member',IsActive=true);
        insert pb;
        
        Product2 prod = new Product2(Name = 'Test', ProductCode = 'test123', IsActive = true);
        insert prod;
        System.assert(prod != null, 'Product is empty');
        
        Id pricebookId = Test.getStandardPricebookId();        
        System.assert(pricebookId != null, 'StandardPricebookId is empty');
        
        List<PricebookEntry> allPbe = new List<PricebookEntry>();
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, 
                                                Product2Id = prod.Id,
                                                UnitPrice = 200, 
                                                IsActive = true);
        allPbe.add(pbe);
        
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = pb.Id, 
                                                 Product2Id = prod.Id,
                                                 UnitPrice = 200, 
                                                 IsActive = true);
        allPbe.add(pbe2);
        insert allPbe;


        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplans = [select id
                                            ,Enable_Self_Registration__c
                                            ,Self_Registration_Access__c,Type__c,AS_Product__c
                                            from Training_Plan__c];

        System.assertEquals(1,tplans.size());
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;  
        tplan.Self_Registration_Access__c = 'External';
        tplan.Type__c = 'Paid'; 
        tplan.AS_Product__c = prod.Id;
        update tplan;
 
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                //Get state from page init
                TrainingPlanPreviewController_Lightning.pageStateWrapper stateMemFree = TrainingPlanPreviewController_Lightning.getTrainingPlanState(tplan.Id);
                //Register for training plan
                System.debug('Register for training plan: ' + JSON.serializePretty(stateMemFree));
                try{
                TrainingPlanPreviewController_Lightning.pageStateWrapper state2 = TrainingPlanPreviewController_Lightning.registerForTrainingPlan(stateMemFree);
                System.debug('STATE @***:' + JSON.SerializePretty(stateMemFree));

                //Update to RTO type
                stateMemFree.tPlan.trainingPlan.Type__c = 'Member Benefit';
                TrainingPlanPreviewController_Lightning.pageStateWrapper state5 = TrainingPlanPreviewController_Lightning.registerForTrainingPlan(stateMemFree);
                
                //Update to Member Only (Paid) type
                stateMemFree.tPlan.trainingPlan.Type__c = 'Member Only (Paid)';
                TrainingPlanPreviewController_Lightning.pageStateWrapper state6 = TrainingPlanPreviewController_Lightning.registerForTrainingPlan(stateMemFree);
                }
                catch(exception e)
        				 {
						}     
            }
        Test.stopTest();
    }

    /**
     * @author	Davanti:
     * @author	LToohey (Davanti),
     * @since	29/07/2020 
     * @see		TrainingPlanPreviewController_Lightning#GetTrainingPlanState
     */
    static testMethod void testGetTrainingPlanState_NonMemberUser() {
        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');

        Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = DateTime.now().getTime()+'Alpha';
        acc.LastName = DateTime.now().getTime()+'Sys';
        acc.recordTypeId = personAccRecId;
        acc.PersonEmail = 'bannegroupuser'+DateTime.now().getTime()+'@testorg.com';
        acc.AS_Membership_Status__pc = 'Current';
        acc.AS_AHPRA_Number__pc = '123456789';
        insert acc;
        
        Account forMemMatchCon = [Select Id,PersonContactId from Account where PersonEmail =:acc.PersonEmail LIMIT 1];
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Non Member Login User'];
        String uniqueUserName1 = 'memberuser' + DateTime.now().getTime() + '@testorg.com';
        
        User use = new User(Alias = generateRandomString(6), Email=acc.PersonEmail,
                            EmailEncodingKey='UTF-8', LastName=acc.LastName, LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,
                            ContactId = forMemMatchCon.PersonContactId,
                            TimeZoneSidKey='America/Los_Angeles',
                            isActive = true, 
                            UserName=uniqueUserName1);

        list<User> lmsUsers  = new List<User>();
        lmsUsers.add(use);
        insert lmsUsers;
        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
        //       TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplans = [select id
                                            ,Enable_Self_Registration__c
                                            ,Self_Registration_Access__c
                                            from Training_Plan__c];

        System.assertEquals(1,tplans.size());
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;  
        tplan.Self_Registration_Access__c = 'External';
        tplan.Type__c = 'Member Only (Free)';
        update tplan;         

        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                //Get state from page init
                TrainingPlanPreviewController_Lightning.pageStateWrapper stateMemFree = TrainingPlanPreviewController_Lightning.getTrainingPlanState(tplan.Id);
                //Register for training plan
                System.debug('Register for training plan: ' + JSON.serializePretty(stateMemFree));
                TrainingPlanPreviewController_Lightning.pageStateWrapper state2 = TrainingPlanPreviewController_Lightning.registerForTrainingPlan(stateMemFree);
                System.debug('STATE @***:' + JSON.SerializePretty(state2));

                //Update to RTO type
                stateMemFree.tPlan.trainingPlan.Type__c = 'RTO';
                TrainingPlanPreviewController_Lightning.pageStateWrapper state3 = TrainingPlanPreviewController_Lightning.registerForTrainingPlan(stateMemFree);
                
                //Update to Event type
                stateMemFree.tPlan.trainingPlan.Type__c = 'Event';
                TrainingPlanPreviewController_Lightning.pageStateWrapper state4 = TrainingPlanPreviewController_Lightning.registerForTrainingPlan(stateMemFree);
                
                //Update to Event type
                stateMemFree.tPlan.trainingPlan.Type__c = 'Public';
                TrainingPlanPreviewController_Lightning.pageStateWrapper state5 = TrainingPlanPreviewController_Lightning.registerForTrainingPlan(stateMemFree);

            }
        Test.stopTest();
    }

    /**
     * @author	Davanti:
     * @author	LToohey (Davanti),
     * @since	29/07/2020 
     * @see		TrainingPlanPreviewController_Lightning#GetTrainingPlanState
     */
    static testMethod void testGetTrainingPlanState_NonMemberUser_withOpp() {
        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');

        Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = DateTime.now().getTime()+'Alpha';
        acc.LastName = DateTime.now().getTime()+'Sys';
        acc.recordTypeId = personAccRecId;
        acc.PersonEmail = 'bannegroupuser'+DateTime.now().getTime()+'@testorg.com';
        acc.AS_Membership_Status__pc = 'Current';
        acc.AS_AHPRA_Number__pc = '123456789';
        insert acc;
        
        Account forMemMatchCon = [Select Id,PersonContactId from Account where PersonEmail =:acc.PersonEmail LIMIT 1];
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Non Member Login User'];
        String uniqueUserName1 = 'memberuser' + DateTime.now().getTime() + '@testorg.com';
        
        User use = new User(Alias = generateRandomString(6), Email=acc.PersonEmail,
                            EmailEncodingKey='UTF-8', LastName=acc.LastName, LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,
                            ContactId = forMemMatchCon.PersonContactId,
                            TimeZoneSidKey='America/Los_Angeles',
                            isActive = true, 
                            UserName=uniqueUserName1);
        
        list<User> lmsUsers  = new List<User>();
        lmsUsers.add(use);
        insert lmsUsers;
        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
     //       TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        PriceBook2 pb = new PriceBook2(Name='PSA Non-Member',IsActive=true);
        insert pb;
        
        Product2 prod = new Product2(Name = 'Test', ProductCode = 'test123', IsActive = true);
        insert prod;
        System.assert(prod != null, 'Product is empty');
        
        Id pricebookId = Test.getStandardPricebookId();        
        System.assert(pricebookId != null, 'StandardPricebookId is empty');
        
        List<PricebookEntry> allPbe = new List<PricebookEntry>();
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, 
                                                Product2Id = prod.Id,
                                                UnitPrice = 200, 
                                                IsActive = true);
        allPbe.add(pbe);
        
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = pb.Id, 
                                                 Product2Id = prod.Id,
                                                 UnitPrice = 200, 
                                                 IsActive = true);
        allPbe.add(pbe2);
        insert allPbe;


        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplans = [select id
                                            ,Enable_Self_Registration__c
                                            ,Self_Registration_Access__c,Type__c,AS_Product__c
                                            from Training_Plan__c];

        System.assertEquals(1,tplans.size());
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;  
        tplan.Self_Registration_Access__c = 'External';
        tplan.Type__c = 'Member Benefit'; 
        tplan.AS_Product__c                = prod.Id;
        update tplan;

        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                //Get state from page init
                TrainingPlanPreviewController_Lightning.pageStateWrapper stateMemFree = TrainingPlanPreviewController_Lightning.getTrainingPlanState(tplan.Id);
                //Register for training plan
                System.debug('Register for training plan: ' + JSON.serializePretty(stateMemFree));
                try{
                TrainingPlanPreviewController_Lightning.pageStateWrapper state2 = TrainingPlanPreviewController_Lightning.registerForTrainingPlan(stateMemFree);
                System.debug('STATE @***:' + JSON.SerializePretty(state2));

                //Update to RTO type
                stateMemFree.tPlan.trainingPlan.Type__c = 'Member Only (Paid)';
                TrainingPlanPreviewController_Lightning.pageStateWrapper state3 = TrainingPlanPreviewController_Lightning.registerForTrainingPlan(stateMemFree);

                //Update to RTO type
                stateMemFree.tPlan.trainingPlan.Type__c = 'RTO';
                TrainingPlanPreviewController_Lightning.pageStateWrapper state4 = TrainingPlanPreviewController_Lightning.registerForTrainingPlan(stateMemFree);
                
                //Update to Event type
                stateMemFree.tPlan.trainingPlan.Type__c = 'Event';
                TrainingPlanPreviewController_Lightning.pageStateWrapper state5 = TrainingPlanPreviewController_Lightning.registerForTrainingPlan(stateMemFree);
                
                //Update to Event type
                stateMemFree.tPlan.trainingPlan.Type__c = 'Public';
                TrainingPlanPreviewController_Lightning.pageStateWrapper state6 = TrainingPlanPreviewController_Lightning.registerForTrainingPlan(stateMemFree);
                
                //Update to Event type
                stateMemFree.tPlan.trainingPlan.Type__c = '';
                TrainingPlanPreviewController_Lightning.pageStateWrapper state7 = TrainingPlanPreviewController_Lightning.registerForTrainingPlan(stateMemFree);
                }
                catch(exception e){}
        				 
                
            }
        Test.stopTest();
    }

    /**
     * @author	Davanti:
     * @author	LToohey (Davanti),
     * @since	29/07/2020 
     * @see		TrainingPlanPreviewController_Lightning#GetTrainingPlanState
     */
    static testMethod void testGetTrainingPlanState_Error1() {
        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(2,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplans = [select id
                                            ,Enable_Self_Registration__c
                                            ,Self_Registration_Access__c
                                            from Training_Plan__c];

        System.assertEquals(1,tplans.size()); 
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;
        tplan.Self_Registration_Access__c = 'Public';
        tplan.type__c = 'Member Only (Free)';
        update tplan;

        Test.startTest();   
            //Run as LMS user to force CRUD error
            System.runAs(lmsUsers.get(0)){
                //Get state from page init
                try{
                    TrainingPlanPreviewController_Lightning.pageStateWrapper state = TrainingPlanPreviewController_Lightning.getTrainingPlanState(tplan.Id);
                }catch(Exception e){
                    system.debug('Test error: ' + e.getMessage() + e.getStackTraceString() + e.getCause() + e.getLineNumber());
                }
            }
        Test.stopTest();
    }

    /**
     * @author	Davanti:
     * @author	LToohey (Davanti),
     * @since	29/07/2020 
     * @see		TrainingPlanPreviewController_Lightning#eventEnrol
     */
    static testMethod void testEventEnrol_AdminUser() {
        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(2,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplans = [select id
                                            ,Enable_Self_Registration__c
                                            ,Self_Registration_Access__c
                                            from Training_Plan__c];
        Test.startTest();   
            //Run as LMS user to force CRUD error
            System.runAs(adminUsers.get(0)){
                //Get state from page init
                String  redirectURL = TrainingPlanPreviewController_Lightning.eventEnrol(tplans.get(0).Id);
                System.debug('enrol URL: ' + redirectURL);
                system.assertNotEquals(null, redirectURL);
            }
        Test.stopTest();
    }
    
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }

    static testMethod void testGetUserAccountDetails() {
        Id userId = UserInfo.getUserId();
        TrainingPlanPreviewController_Lightning.getUserAccountDetails(userId);
    }
}