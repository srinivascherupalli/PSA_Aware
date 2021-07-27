/*
Copyright (c) 2014, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors
    may be used to endorse or promote products derived from this software
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
OF THE POSSIBILITY OF SUCH DAMAGE.

*/
@isTest 
private class TestTrainingPlanPreviewCtrl extends LMSBaseController{

    static testMethod void testPreviewRedirection(){

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
        update tplan;

        System.assertEquals(0,getTrainingPlanAssignmentsCount(tplan.Id));

        PageReference ref = Page.TrainingPlanPreview;
        ref.getParameters().put('id',tplan.Id);
        ref.getHeaders().put('User-Agent', 'Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53');

        Test.setCurrentPageReference(ref);
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                TrainingPlanPreviewController cont = new TrainingPlanPreviewController();
                System.debug('Tplan '+cont.tPlan);
                //LT(Davanti) - 05/08/2020 Add future job check for coverage
                String futureCheck = TrainingPlanPreviewController.check_futureJobComplete(lmsUsers.get(0).Id, tplan.Id, System.now().format());//DateTime string for 3rd param
                //System.assert(cont.tPlan != null);
            }
        Test.stopTest();

    }

    static testMethod void testPreviewRegistration(){

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
        tplan.type__c = 'Public';
        update tplan;

        System.assertEquals(0,getTrainingPlanAssignmentsCount(tplan.Id));

        PageReference ref = Page.TrainingPlanPreview;
        ref.getParameters().put('id',tplan.Id);

        Test.setCurrentPageReference(ref);
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                TrainingPlanPreviewController cont = new TrainingPlanPreviewController();
                //System.assert(cont.tPlan != null);
                //Register for public trainign plan
                cont.registerForTrainingPlan();
                //System.assertEquals(1,getTrainingPlanAssignmentsCount(tplan.Id));
            }

        Test.stopTest();

    }

    static testMethod void testPreviewRegistrationWithApprovalEntries(){

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
        tplan.Self_Registration_Access__c = 'Requires Approval';
        update tplan;

        System.assertEquals(0,getTrainingPlanAssignmentsCount(tplan.Id));

        PageReference ref = Page.TrainingPlanPreview;
        ref.getParameters().put('id',tplan.Id); 

        Test.setCurrentPageReference(ref);
        Test.startTest();
            System.runAs(adminUsers.get(0)){
                TrainingPlanPreviewController cont = new TrainingPlanPreviewController();
                //System.assert(cont.tPlan != null);
                PageReference contRef = cont.fetchTrainingPlanInfo();
                //Confirm we don't have any access requests in the system
                //System.assertEquals(0,getTrainingPlanAccessRequestCount(tplan.Id));
                //Submit request
                contRef = cont.requestAccessForTrainingPlan();
                //Confirm request creation
                //System.assertEquals(1,getTrainingPlanAccessRequestCount(tplan.Id));

            }

        Test.stopTest();

    }
    
    // test added by John Hope
    static testMethod void testPreviewOtherCode(){

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

        System.debug( 'weeeeeee tplan' + tplan );

        System.assertEquals(0,getTrainingPlanAssignmentsCount(tplan.Id));

        PageReference ref = Page.TrainingPlanPreview;
        ref.getParameters().put('id',tplan.Id);

        Test.setCurrentPageReference(ref);
        Test.startTest();   
            System.runAs(lmsUsers.get(0)){
                TrainingPlanPreviewController cont = new TrainingPlanPreviewController();
                System.debug('tpLan debug '+cont.tPlan);
                //System.assert(cont.tPlan != null);
                //Register for public trainign plan
                cont.registerForTrainingPlan();
                
                cont.redirectToPlanDetailPage();
                
                cont.hasTrainingPlanAssignment();
                
                cont.createTrainingPlanBookmark();
            }

        Test.stopTest();

    } 

 
    static testMethod void testPreviewRedirectionWithUser(){

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
 
        System.assertEquals(0,getTrainingPlanAssignmentsCount(tplan.Id));
 
        PageReference ref = Page.TrainingPlanPreview;
        ref.getParameters().put('id',tplan.Id);

        Test.setCurrentPageReference(ref);
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                TrainingPlanPreviewController cont = new TrainingPlanPreviewController();
                cont.eventEnrol(); 
                //System.assert(cont.tPlan != null);
            }
        Test.stopTest();

    }


    static testMethod void testPreviewRedirectionWithUserNonMember(){

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
 
        System.assertEquals(0,getTrainingPlanAssignmentsCount(tplan.Id));
 
        PageReference ref = Page.TrainingPlanPreview;
        ref.getParameters().put('id',tplan.Id);

        Test.setCurrentPageReference(ref);
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                TrainingPlanPreviewController cont = new TrainingPlanPreviewController();
                cont.eventEnrol(); 
                //System.assert(cont.tPlan != null);
            }
        Test.stopTest();

    }


    static testMethod void testPreviewRedirectionWithUser_PaidError(){

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

        //System.assertEquals(1,tplans.size());
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;  
        tplan.Self_Registration_Access__c = 'External';
        tplan.Type__c = 'Paid';
        update tplan;
 
        System.assertEquals(0,getTrainingPlanAssignmentsCount(tplan.Id));
 
        PageReference ref = Page.TrainingPlanPreview;
        ref.getParameters().put('id',tplan.Id);

        Test.setCurrentPageReference(ref);
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                TrainingPlanPreviewController cont = new TrainingPlanPreviewController();
                cont.eventEnrol(); 
                //System.assert(cont.tPlan != null);
            }
        Test.stopTest();

    }

    static testMethod void testPreviewRedirectionWithUser_Paid(){

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
                                            ,Self_Registration_Access__c
                                            from Training_Plan__c];

        System.assertEquals(1,tplans.size());
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;  
        tplan.Self_Registration_Access__c = 'External';
        tplan.Type__c = 'Paid'; 
        tplan.AS_Product__c                = prod.Id;
        update tplan;
 
        System.assertEquals(0,getTrainingPlanAssignmentsCount(tplan.Id));
 
        PageReference ref = Page.TrainingPlanPreview;
        ref.getParameters().put('id',tplan.Id);

        Test.setCurrentPageReference(ref);
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                TrainingPlanPreviewController cont = new TrainingPlanPreviewController();
                cont.eventEnrol(); 
                //System.assert(cont.tPlan != null);
            }
        Test.stopTest();

    }


    static testMethod void testPreviewRedirectionWithUser_RTO(){

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
        tplan.Type__c = 'RTO';
        update tplan;
 
        System.assertEquals(0,getTrainingPlanAssignmentsCount(tplan.Id));
 
        PageReference ref = Page.TrainingPlanPreview;
        ref.getParameters().put('id',tplan.Id);

        Test.setCurrentPageReference(ref);
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                TrainingPlanPreviewController cont = new TrainingPlanPreviewController();
                cont.eventEnrol(); 
                //System.assert(cont.tPlan != null);
            }
        Test.stopTest();

    }


    static testMethod void testPreviewRedirectionWithNonMemUser_MemberBenefit(){

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
        tplan.Type__c = 'Member Benefit';
        update tplan;
 
        System.assertEquals(0,getTrainingPlanAssignmentsCount(tplan.Id));
 
        PageReference ref = Page.TrainingPlanPreview;
        ref.getParameters().put('id',tplan.Id);

        Test.setCurrentPageReference(ref);
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                TrainingPlanPreviewController cont = new TrainingPlanPreviewController();
                cont.eventEnrol(); 
                //System.assert(cont.tPlan != null);
            }
        Test.stopTest();

    }
  
 


    static testMethod void testPreviewRedirectionWithUser_MemberBenefit_withOpp(){

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
                                            ,Self_Registration_Access__c
                                            from Training_Plan__c];

        System.assertEquals(1,tplans.size());
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;  
        tplan.Self_Registration_Access__c = 'External';
        tplan.Type__c = 'Member Benefit'; 
        tplan.AS_Product__c                = prod.Id;
        update tplan;
 
        System.assertEquals(0,getTrainingPlanAssignmentsCount(tplan.Id));
 
        PageReference ref = Page.TrainingPlanPreview;
        ref.getParameters().put('id',tplan.Id);

        Test.setCurrentPageReference(ref);
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                TrainingPlanPreviewController cont = new TrainingPlanPreviewController();
                cont.eventEnrol(); 
                //System.assert(cont.tPlan != null);
            }
        Test.stopTest();

    }



    static testMethod void testPreviewRedirectionWithUser_MemberBenefit_withOpp_Error(){

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
                                            ,Self_Registration_Access__c
                                            from Training_Plan__c];

        System.assertEquals(1,tplans.size());
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;  
        tplan.Self_Registration_Access__c = 'External';
        tplan.Type__c = 'Member Benefit'; 
        tplan.AS_Product__c                = prod.Id;
        update tplan;
 
        System.assertEquals(0,getTrainingPlanAssignmentsCount(tplan.Id));
 
        PageReference ref = Page.TrainingPlanPreview;
        ref.getParameters().put('id',tplan.Id);

        Test.setCurrentPageReference(ref);
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                TrainingPlanPreviewController cont = new TrainingPlanPreviewController();
                cont.eventEnrol(); 
                //System.assert(cont.tPlan != null);
            }
        Test.stopTest();

    }
 

    static testMethod void testPreviewRedirectionWithUser_MemberOnlyPaidWithOpp(){

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
                                            ,Self_Registration_Access__c
                                            from Training_Plan__c];

        System.assertEquals(1,tplans.size());
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;  
        tplan.Self_Registration_Access__c = 'External';
        tplan.Type__c = 'Member Only (Paid)'; 
        tplan.AS_Product__c                = prod.Id;
        update tplan;
 
        System.assertEquals(0,getTrainingPlanAssignmentsCount(tplan.Id));
 
        PageReference ref = Page.TrainingPlanPreview;
        ref.getParameters().put('id',tplan.Id);

        Test.setCurrentPageReference(ref);
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                TrainingPlanPreviewController cont = new TrainingPlanPreviewController();
                cont.eventEnrol(); 
                //System.assert(cont.tPlan != null);
            }
        Test.stopTest();

    }
 

    static testMethod void testPreviewRedirectionWithUser_MemberOnlyPaidWithWithOutOpp(){

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
                                            ,Self_Registration_Access__c
                                            from Training_Plan__c];

        System.assertEquals(1,tplans.size());
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;  
        tplan.Self_Registration_Access__c = 'External';
        tplan.Type__c = 'Member Only (Paid)'; 
        tplan.AS_Product__c                = prod.Id;
        update tplan;
 
        System.assertEquals(0,getTrainingPlanAssignmentsCount(tplan.Id));
 
        PageReference ref = Page.TrainingPlanPreview;
        ref.getParameters().put('id',tplan.Id);

        Test.setCurrentPageReference(ref);
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                TrainingPlanPreviewController cont = new TrainingPlanPreviewController();
                cont.eventEnrol(); 
                //System.assert(cont.tPlan != null);
            }
        Test.stopTest();

    }


    static testMethod void testPreviewRedirectionWithNonMemberUser_MemberOnlyPaidWithWithOpp(){

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
                                            ,Self_Registration_Access__c
                                            from Training_Plan__c];

        System.assertEquals(1,tplans.size());
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;  
        tplan.Self_Registration_Access__c = 'External';
        tplan.Type__c = 'Member Only (Paid)'; 
        tplan.AS_Product__c                = prod.Id;
        update tplan;
 
        System.assertEquals(0,getTrainingPlanAssignmentsCount(tplan.Id));
 
        PageReference ref = Page.TrainingPlanPreview;
        ref.getParameters().put('id',tplan.Id);

        Test.setCurrentPageReference(ref);
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                TrainingPlanPreviewController cont = new TrainingPlanPreviewController();
                cont.eventEnrol(); 
                cont.checkAssignment();
                //System.assert(cont.tPlan != null);
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

    private static Integer getTrainingPlanAssignmentsCount(Id tplanId){
        return [select count() from Training_Plan_Assignment__c where Training_Plan__c = :tplanId];
    }

    private static Integer getTrainingPlanAccessRequestCount(Id tplanId){
        return [select count() from Training_Plan_Access_Request__c where Training_Plan__c = :tplanId];
    }

}