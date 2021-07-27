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
private class TestTrainingTrackDetailCtrl{
    
         @TestSetup  
    static void testData(){
        
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

    static testMethod void testSharedTrackDetail(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(5,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingTrackData.createSampleData();
        
        List<Training_Track__c> tracks = [select id,name from Training_Track__c];
        List<Training_Track_Level_Item__c> trackItems = [select id,name from Training_Track_Level_Item__c];
        System.assertEquals(1,tracks.size());
        System.assert(trackItems.size()>0);

        List<Training_Track__Share> shares = new List<Training_Track__Share>();

        for(Training_Track__c t : tracks){
            Training_Track__Share tShr  = new Training_Track__Share();
            tShr.ParentId = t.Id;
            tShr.UserOrGroupId = lmsUsers.get(0).Id;
            tShr.AccessLevel = 'Read';
            shares.add(tShr);
        }

        insert shares;


        Test.startTest();
	
            PageReference pageRef = Page.TrainingTrackDetail;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('id', tracks.get(0).Id);

            System.runAs(lmsUsers.get(0)){
                TrainingTrackDetailCtrl cont = new TrainingTrackDetailCtrl();
                
                System.assert(cont.track != null);
            }

        Test.stopTest();
        
    }
   
    
    static testMethod void paid() {
        
   
        List<User> theUser = [Select Id, AccountId,Account.PersonEmail,Contact.AccountId from User where Email = 'person@test.com' ];
        
        System.runAs(theUser.get(0)){
            //Assign corresponding perm sets
            //TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
           // TestUtilClass.addPermissionSet(theUser,'LMS_User');
        
        
        
        System.debug( 'testtttt' + theUser );
        
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
            
        Id psaenrolment = Schema.SObjectType.Enrolment_Form__c.getRecordTypeInfosByName().get('PSA Enrolment').getRecordTypeId();

        TestTrainingTrackData.createSampleData();
        
        Learning_Package__c lp = new Learning_Package__c( Name ='LP Test' );
        insert lp;
        
        List<Training_Track__c> wttt = new List<Training_Track__c>();
		wttt.add( new Training_Track__c( Name = 'TT1', AS_Track_Type__c = 'Diploma', AS_Learning_Package__c = lp.Id ) );
        insert wttt;
        
        PageReference pageRef = Page.TrainingTrackDetail;
        pageRef.getParameters().put( 'id', wttt[0].Id );
        
        Test.setCurrentPage(pageRef);

        TrainingTrackDetailCtrl contww = new TrainingTrackDetailCtrl();
        contww.canViewTrainPlan = true;
        contww.purchase();
        }
    }
    
    static testMethod void paid0() {
        
   
        List<User> theUser = [Select Id, AccountId,Account.PersonEmail,Contact.AccountId from User where Email = 'person@test.com' ];
        
        System.runAs(theUser.get(0)){
            //Assign corresponding perm sets
            //TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
           // TestUtilClass.addPermissionSet(theUser,'LMS_User');
        
        
        
        System.debug( 'testtttt' + theUser );
        
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
            
        Id psaenrolment = Schema.SObjectType.Enrolment_Form__c.getRecordTypeInfosByName().get('PSA Enrolment').getRecordTypeId();

        TestTrainingTrackData.createSampleData();
        
        Learning_Package__c lp = new Learning_Package__c( Name ='LP Test' );
        insert lp;
            
        List<Account> AccListNew = [SELECT Id, Name FROM Account];
            
        Enrolment_Form__c Asenrolform = new Enrolment_Form__c(
            RecordTypeId = psaenrolment,
            AS_Account__c = AccListNew[0].Id,
            Enrolment_Status__c = 'Approved',
            AS_Learning_Package__c = lp.Id,
            AS_Processed__c = false
        );
        insert Asenrolform;
        
        List<Training_Track__c> wttt = new List<Training_Track__c>();
		wttt.add( new Training_Track__c( Name = 'TT1', AS_Track_Type__c = 'Diploma', AS_Learning_Package__c = lp.Id ) );
        insert wttt;
        
        PageReference pageRef = Page.TrainingTrackDetail;
        pageRef.getParameters().put( 'id', wttt[0].Id );
        
        Test.setCurrentPage(pageRef);

        TrainingTrackDetailCtrl contww = new TrainingTrackDetailCtrl();
        contww.canViewTrainPlan = true;
        contww.purchase();
        }
    }
    
    static testMethod void paid1() {
        
        List<User> theUser = [Select Id, AccountId,Account.PersonEmail,Contact.AccountId from User where Email = 'person@test.com' ];
        
        System.runAs(theUser.get(0)){
        
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
        
        Learning_Package__c lp = new Learning_Package__c( Name ='LP Test' );
        insert lp;
        
         List<Training_Track__c> wttt = new List<Training_Track__c>();
		wttt.add( new Training_Track__c( Name = 'TT1', AS_Track_Type__c = 'Member Only (Free)', AS_Learning_Package__c = lp.Id ) );
        insert wttt;
        
        PageReference pageRef = Page.TrainingTrackDetail;
        pageRef.getParameters().put( 'id', wttt[0].Id );
        
        Test.setCurrentPage(pageRef);

        TrainingTrackDetailCtrl contww = new TrainingTrackDetailCtrl();
        contww.canViewTrainPlan = true;
        contww.purchase();
        }
    }
    
    static testMethod void paid2() {
        
        List<User> theUser = [Select Id, AccountId,Account.PersonEmail,Contact.AccountId from User where Email = 'person@test.com' ];
        
        System.runAs(theUser.get(0)){
        
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
        
        Learning_Package__c lp = new Learning_Package__c( Name ='LP Test' );
        insert lp;
        
         List<Training_Track__c> wttt = new List<Training_Track__c>();
		wttt.add( new Training_Track__c( Name = 'TT1', AS_Track_Type__c = 'Member Benefit', AS_Learning_Package__c = lp.Id ) );
        insert wttt;
        
         PageReference pageRef = Page.TrainingTrackDetail;
        pageRef.getParameters().put( 'id', wttt[0].Id );
        
        Test.setCurrentPage(pageRef);

        TrainingTrackDetailCtrl contww = new TrainingTrackDetailCtrl();
        contww.canViewTrainPlan = true;
        contww.purchase();
        }
    }
    
    static testMethod void paid3() {
        
        List<User> theUser = [Select Id, AccountId,Account.PersonEmail,Contact.AccountId from User where Email = 'person@test.com' ];
        
        System.runAs(theUser.get(0)){
        
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
        
        Learning_Package__c lp = new Learning_Package__c( Name ='LP Test' );
        insert lp;
        
         List<Training_Track__c> wttt = new List<Training_Track__c>();
		wttt.add( new Training_Track__c( Name = 'TT1', AS_Track_Type__c = 'Member Only (Paid)', AS_Learning_Package__c = lp.Id ) );
        insert wttt;
        
         PageReference pageRef = Page.TrainingTrackDetail;
        pageRef.getParameters().put( 'id', wttt[0].Id );
        
        Test.setCurrentPage(pageRef);

        TrainingTrackDetailCtrl contww = new TrainingTrackDetailCtrl();
        contww.canViewTrainPlan = true;
        contww.purchase();
        }
    }
    
    static testMethod void paid4() {
        
        List<User> theUser = [Select Id, AccountId,Account.PersonEmail,Contact.AccountId from User where Email = 'person@test.com' ];
        
        System.runAs(theUser.get(0)){
        
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
        
        Learning_Package__c lp = new Learning_Package__c( Name ='LP Test' );
        insert lp;
        
         List<Training_Track__c> wttt = new List<Training_Track__c>();
		wttt.add( new Training_Track__c( Name = 'TT1', AS_Track_Type__c = 'Paid', AS_Learning_Package__c = lp.Id ) );
        insert wttt;
        
         PageReference pageRef = Page.TrainingTrackDetail;
        pageRef.getParameters().put( 'id', wttt[0].Id );
        
        Test.setCurrentPage(pageRef);

        TrainingTrackDetailCtrl contww = new TrainingTrackDetailCtrl();
        contww.canViewTrainPlan = true;
        contww.purchase();
        }
    }
    
    static testMethod void paid5() {
        
        List<User> theUser = [Select Id, AccountId,Account.PersonEmail,Contact.AccountId from User where Email = 'person@test.com' ];
        
        System.runAs(theUser.get(0)){
        
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
        
        Learning_Package__c lp = new Learning_Package__c( Name ='LP Test' );
        insert lp;
        
         List<Training_Track__c> wttt = new List<Training_Track__c>();
		wttt.add( new Training_Track__c( Name = 'TT1', AS_Track_Type__c = 'Public', AS_Learning_Package__c = lp.Id ) );
        insert wttt;
        
         PageReference pageRef = Page.TrainingTrackDetail;
        pageRef.getParameters().put( 'id', wttt[0].Id );
        
        Test.setCurrentPage(pageRef);

        TrainingTrackDetailCtrl contww = new TrainingTrackDetailCtrl();
        contww.canViewTrainPlan = true;
        contww.purchase();
        }
    }

     
    static testMethod void paid6() {
        
   
        List<User> theUser = [Select Id, AccountId,Account.PersonEmail,Contact.AccountId from User where Email = 'person1@test.com' ];
        
        System.runAs(theUser.get(0)){
            //Assign corresponding perm sets
            //TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
           // TestUtilClass.addPermissionSet(theUser,'LMS_User');
        
        
        
        System.debug( 'testtttt' + theUser );
        
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
        
        Learning_Package__c lp = new Learning_Package__c( Name ='LP Test',AS_Event_selection__c = true );
        insert lp;
        
        List<Training_Track__c> wttt = new List<Training_Track__c>();
		wttt.add( new Training_Track__c( Name = 'TT1', AS_Track_Type__c = 'Diploma', AS_Learning_Package__c = lp.Id ) );
        insert wttt;
        
        PageReference pageRef = Page.TrainingTrackDetail;
        pageRef.getParameters().put( 'id', wttt[0].Id );
        
        Test.setCurrentPage(pageRef);

        TrainingTrackDetailCtrl contww = new TrainingTrackDetailCtrl();
        contww.canViewTrainPlan = false;
        contww.purchase();
        }
    }
    
    static testMethod void paid7() {
        
        List<User> theUser = [Select Id, AccountId,Account.PersonEmail,Contact.AccountId from User where Email = 'person1@test.com' ];
        
        System.runAs(theUser.get(0)){
        
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
        
        Learning_Package__c lp = new Learning_Package__c( Name ='LP Test' );
        insert lp;
        
         List<Training_Track__c> wttt = new List<Training_Track__c>();
		wttt.add( new Training_Track__c( Name = 'TT1', AS_Track_Type__c = 'Member Only (Free)', AS_Learning_Package__c = lp.Id ) );
        insert wttt;
        
        PageReference pageRef = Page.TrainingTrackDetail;
        pageRef.getParameters().put( 'id', wttt[0].Id );
        
        Test.setCurrentPage(pageRef);

        TrainingTrackDetailCtrl contww = new TrainingTrackDetailCtrl();
        contww.canViewTrainPlan = false;
        contww.purchase();
        }
    }
    
    static testMethod void paid8() {
        
        List<User> theUser = [Select Id, AccountId,Account.PersonEmail,Contact.AccountId from User where Email = 'person1@test.com' ];
        
        System.runAs(theUser.get(0)){
        
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
        
        Learning_Package__c lp = new Learning_Package__c( Name ='LP Test' );
        insert lp;
        
         List<Training_Track__c> wttt = new List<Training_Track__c>();
		wttt.add( new Training_Track__c( Name = 'TT1', AS_Track_Type__c = 'Member Benefit', AS_Learning_Package__c = lp.Id ) );
        insert wttt;
        
         PageReference pageRef = Page.TrainingTrackDetail;
        pageRef.getParameters().put( 'id', wttt[0].Id );
        
        Test.setCurrentPage(pageRef);

        TrainingTrackDetailCtrl contww = new TrainingTrackDetailCtrl();
        contww.canViewTrainPlan = false;
        contww.purchase();
        }
    }
    
    static testMethod void paid9() {
        
        List<User> theUser = [Select Id, AccountId,Account.PersonEmail,Contact.AccountId from User where Email = 'person1@test.com' ];
        
        System.runAs(theUser.get(0)){
        
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
        
        Learning_Package__c lp = new Learning_Package__c( Name ='LP Test' );
        insert lp;
        
         List<Training_Track__c> wttt = new List<Training_Track__c>();
		wttt.add( new Training_Track__c( Name = 'TT1', AS_Track_Type__c = 'Member Only (Paid)', AS_Learning_Package__c = lp.Id ) );
        insert wttt;
        
         PageReference pageRef = Page.TrainingTrackDetail;
        pageRef.getParameters().put( 'id', wttt[0].Id );
        
        Test.setCurrentPage(pageRef);

        TrainingTrackDetailCtrl contww = new TrainingTrackDetailCtrl();
        contww.canViewTrainPlan = false;
        contww.purchase();
        }
    }
    
    static testMethod void paid10() {
        
        List<User> theUser = [Select Id, AccountId,Account.PersonEmail,Contact.AccountId from User where Email = 'person1@test.com' ];
        
        System.runAs(theUser.get(0)){
        
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
        
        Learning_Package__c lp = new Learning_Package__c( Name ='LP Test' );
        insert lp;
        
         List<Training_Track__c> wttt = new List<Training_Track__c>();
		wttt.add( new Training_Track__c( Name = 'TT1', AS_Track_Type__c = 'Paid', AS_Learning_Package__c = lp.Id ) );
        insert wttt;
        
         PageReference pageRef = Page.TrainingTrackDetail;
        pageRef.getParameters().put( 'id', wttt[0].Id );
        
        Test.setCurrentPage(pageRef);

        TrainingTrackDetailCtrl contww = new TrainingTrackDetailCtrl();
        contww.canViewTrainPlan = false;
        contww.purchase();
        }
    }
    
    static testMethod void paid11() {
        
        List<User> theUser = [Select Id, AccountId,Account.PersonEmail,Contact.AccountId from User where Email = 'person1@test.com' ];
        
        System.runAs(theUser.get(0)){
        
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
        
        Learning_Package__c lp = new Learning_Package__c( Name ='LP Test' );
        insert lp;
        
         List<Training_Track__c> wttt = new List<Training_Track__c>();
		wttt.add( new Training_Track__c( Name = 'TT1', AS_Track_Type__c = 'Public', AS_Learning_Package__c = lp.Id ) );
        insert wttt;
        
         PageReference pageRef = Page.TrainingTrackDetail;
        pageRef.getParameters().put( 'id', wttt[0].Id );
        
        Test.setCurrentPage(pageRef);

        TrainingTrackDetailCtrl contww = new TrainingTrackDetailCtrl();
        contww.canViewTrainPlan = false;
        contww.purchase();
        }
    }

}