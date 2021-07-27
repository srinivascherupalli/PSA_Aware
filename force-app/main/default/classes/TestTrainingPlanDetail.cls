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
public class TestTrainingPlanDetail {
    
    static testmethod void testTrainingPlanDetailMobile(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(5,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplan = [select id from Training_Plan__c];
        System.assertEquals(1,tplan.size());

        List<Achievement_Category__c> lAchieveCat = TestAchievementData.createAchievementCategories(1);
        List<Achievement__c> lAchievement = TestAchievementData.createAchievements(1, lAchieveCat.get(0).Id, 'Achievements');
        List<Training_Plan_Achievement__c> lTPlanAchievement = TestTrainingPlanData.createTrainingPlanAchievements(tplan, lAchievement);

        Id tplanId = tplan.get(0).Id;
        Set<Id> selectedUserIds = new Set<Id>();

        for(User u : lmsUsers){
            selectedUserIds.add(u.Id);
        }

        //Test Insert
        Test.startTest();
            System.runAs(adminUsers.get(0)){
                LMSService.upsertAssignments(selectedUserIds,tplanId,null);
            }
        Test.stopTest();
				
        System.runAs(lmsUsers.get(0)){
            PageReference pageRef = Page.TrainingPlanDetail;
            Test.setCurrentPage(pageRef);
            pageRef.getHeaders().put('User-Agent', 'iPhone');
            ApexPages.Standardcontroller stdcontroller = New ApexPages.StandardController(tplan.get(0));
            TrainingPlanDetailController extension = new TrainingPlanDetailController(stdcontroller);

            List<Training_Plan_Section__c> ltpsec = [select id from Training_Plan_Section__c where Training_Plan__c =: tplan.get(0).Id order by Order__c asc];
            System.assert(ltpsec.size() == 3);

            List<Training_Plan_Section_Item__c> ltpsitem = [select id from Training_Plan_Section_Item__c where Training_Plan_Section__c =: ltpsec.get(0).Id order by Order__c asc];
            System.assert(ltpsitem.size() == 1, 'Training Plan Section Item issues, size = ' + ltpsitem.size());

            extension.selectedSectionId = ltpsec.get(0).Id;
            extension.selectedItemId = ltpsitem.get(0).Id;
            extension.retrieveItemDetails();
            extension.launchLearning();
            System.assert(extension.selectedItemStatusLabel == 'default', 'Error on selectedItemStatusLabel, label = ' + extension.selectedItemStatusLabel);

            List<Learning_Assignment__c> lassignment = [select Id,
                                                            Progress__c from Learning_Assignment__c
                                                            where Training_Plan__c =: tplanId
                                                            and Training_Plan_Section__c =:ltpsec.get(0).Id
                                                            and User__c =: lmsUsers.get(0).Id];
            for(Learning_Assignment__c oa : lassignment){
                oa.Progress__c = 'In Progress';
            }

            upsert lassignment;
						
            extension.init();
            extension.selectedSectionId = ltpsec.get(0).Id;
            extension.selectedItemId = ltpsitem.get(0).Id;
            extension.retrieveItemDetails();
            extension.launchLearning();
            System.assert(extension.selectedItemStatusLabel == 'warning', 'Error on selectedItemStatusLabel, label = ' + extension.selectedItemStatusLabel);

            for(Learning_Assignment__c oa : lassignment){
                oa.Progress__c = 'Completed';
            }

            upsert lassignment;
            // this is temporarily commented but will be uncommented later
						/*
            extension.init();
            extension.selectedSectionId = ltpsec.get(0).Id;
            extension.selectedItemId = ltpsitem.get(0).Id;
            extension.retrieveItemDetails();
            extension.launchLearning();
            System.assert(extension.selectedItemStatusLabel == 'success', 'Error on selectedItemStatusLabel, label = ' + extension.selectedItemStatusLabel);

            List<Training_Plan_Section_Item__c> ltpsitem2 = [select id from Training_Plan_Section_Item__c where Training_Plan_Section__c =: ltpsec.get(1).Id order by Order__c asc];
            System.assert(ltpsitem2.size() == 3, 'Training Plan Section Item issues, size = ' + ltpsitem2.size());

            extension.selectedSectionId = ltpsec.get(1).Id;
            extension.selectedItemId = ltpsitem2.get(0).Id;
            extension.retrieveItemDetails();
            extension.launchLearning();

            List<Learning_Assignment__c> lassignment2 = [select Id,
                                                            Progress__c from Learning_Assignment__c
                                                            where Training_Plan__c =: tplanId
                                                            and Training_Plan_Section__c =:ltpsec.get(1).Id
                                                            and User__c =: lmsUsers.get(0).Id];
            for(Learning_Assignment__c oa2 : lassignment2){
                oa2.Progress__c = 'Completed';
            }

            upsert lassignment2;

            List<Training_Plan_Section_Item__c> ltpsitem3 = [select id from Training_Plan_Section_Item__c where Training_Plan_Section__c =: ltpsec.get(2).Id order by Order__c asc];
            System.assert(ltpsitem3.size() == 3, 'Training Plan Section Item issues, size = ' + ltpsitem3.size());

            extension.selectedSectionId = ltpsec.get(2).Id;
            extension.selectedItemId = ltpsitem3.get(0).Id;
            extension.retrieveItemDetails();
            extension.launchLearning();

            List<Learning_Assignment__c> lassignment3 = [select Id,
                                                            Progress__c from Learning_Assignment__c
                                                            where Training_Plan__c =: tplanId
                                                            and Training_Plan_Section__c =:ltpsec.get(2).Id
                                                            and User__c =: lmsUsers.get(0).Id];
            for(Learning_Assignment__c oa3 : lassignment3){
                oa3.Progress__c = 'Completed';
            }
            upsert lassignment3;
						*/
        } 
        
    }

    static testmethod void testTrainingPlanDetailWeb(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(5,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplan = [select id from Training_Plan__c];
        System.assertEquals(1,tplan.size());

        List<Achievement_Category__c> lAchieveCat = TestAchievementData.createAchievementCategories(1);
        List<Achievement__c> lAchievement = TestAchievementData.createAchievements(1, lAchieveCat.get(0).Id, 'Achievements');
        List<Training_Plan_Achievement__c> lTPlanAchievement = TestTrainingPlanData.createTrainingPlanAchievements(tplan, lAchievement);

        Id tplanId = tplan.get(0).Id;
        Set<Id> selectedUserIds = new Set<Id>();

        for(User u : lmsUsers){
            selectedUserIds.add(u.Id);
        }

        //Test Insert
        Test.startTest();
            System.runAs(adminUsers.get(0)){
                LMSService.upsertAssignments(selectedUserIds,tplanId,null);
            }
        Test.stopTest();

        System.runAs(lmsUsers.get(0)){
            PageReference pageRef = Page.TrainingPlanDetail;
            Test.setCurrentPage(pageRef);
            pageRef.getHeaders().put('User-Agent', 'Mozilla');
            ApexPages.Standardcontroller stdcontroller = New ApexPages.StandardController(tplan.get(0));
            TrainingPlanDetailController extension = new TrainingPlanDetailController(stdcontroller);

            List<Training_Plan_Section__c> ltpsec = [select id from Training_Plan_Section__c where Training_Plan__c =: tplan.get(0).Id order by Order__c asc];
            System.assert(ltpsec.size() == 3);

            List<Training_Plan_Section_Item__c> ltpsitem = [select id from Training_Plan_Section_Item__c where Training_Plan_Section__c =: ltpsec.get(0).Id order by Order__c asc];
            System.assert(ltpsitem.size() == 1, 'Training Plan Section Item issues, size = ' + ltpsitem.size());

            extension.selectedSectionId = ltpsec.get(0).Id;
            extension.selectedItemId = ltpsitem.get(0).Id;
            extension.retrieveItemDetails();
            extension.launchLearning();
            System.assert(extension.selectedItemStatusLabel == 'default', 'Error on selectedItemStatusLabel, label = ' + extension.selectedItemStatusLabel);

            List<Learning_Assignment__c> lassignment = [select Id,
                                                            Progress__c from Learning_Assignment__c
                                                            where Training_Plan__c =: tplanId
                                                            and Training_Plan_Section__c =:ltpsec.get(0).Id
                                                            and User__c =: lmsUsers.get(0).Id];
            for(Learning_Assignment__c oa : lassignment){
                oa.Progress__c = 'In Progress';
            }

            upsert lassignment;

            extension.init();
            extension.selectedSectionId = ltpsec.get(0).Id;
            extension.selectedItemId = ltpsitem.get(0).Id;
            extension.retrieveItemDetails();
            extension.launchLearning();
            System.assert(extension.selectedItemStatusLabel == 'warning', 'Error on selectedItemStatusLabel, label = ' + extension.selectedItemStatusLabel);

            for(Learning_Assignment__c oa : lassignment){
                oa.Progress__c = 'Completed';
            }

            upsert lassignment;
            // this is temporarily commented but will be uncommented later
						/*
            extension.init();
            extension.selectedSectionId = ltpsec.get(0).Id;
            extension.selectedItemId = ltpsitem.get(0).Id;
            extension.retrieveItemDetails();
            extension.launchLearning();
            System.assert(extension.selectedItemStatusLabel == 'success', 'Error on selectedItemStatusLabel, label = ' + extension.selectedItemStatusLabel);

            List<Training_Plan_Section_Item__c> ltpsitem2 = [select id from Training_Plan_Section_Item__c where Training_Plan_Section__c =: ltpsec.get(1).Id order by Order__c asc];
            System.assert(ltpsitem2.size() == 3, 'Training Plan Section Item issues, size = ' + ltpsitem2.size());

            extension.selectedSectionId = ltpsec.get(1).Id;
            extension.selectedItemId = ltpsitem2.get(0).Id;
            extension.retrieveItemDetails();
            extension.launchLearning();

            List<Learning_Assignment__c> lassignment2 = [select Id,
                                                            Progress__c from Learning_Assignment__c
                                                            where Training_Plan__c =: tplanId
                                                            and Training_Plan_Section__c =:ltpsec.get(1).Id
                                                            and User__c =: lmsUsers.get(0).Id];
            for(Learning_Assignment__c oa2 : lassignment2){
                oa2.Progress__c = 'Completed';
            }

            upsert lassignment2;

            List<Training_Plan_Section_Item__c> ltpsitem3 = [select id from Training_Plan_Section_Item__c where Training_Plan_Section__c =: ltpsec.get(2).Id order by Order__c asc];
            System.assert(ltpsitem3.size() == 3, 'Training Plan Section Item issues, size = ' + ltpsitem3.size());

            extension.selectedSectionId = ltpsec.get(2).Id;
            extension.selectedItemId = ltpsitem3.get(0).Id;
            extension.retrieveItemDetails();
            extension.launchLearning();

            List<Learning_Assignment__c> lassignment3 = [select Id,
                                                            Progress__c from Learning_Assignment__c
                                                            where Training_Plan__c =: tplanId
                                                            and Training_Plan_Section__c =:ltpsec.get(2).Id
                                                            and User__c =: lmsUsers.get(0).Id];
            for(Learning_Assignment__c oa3 : lassignment3){
                oa3.Progress__c = 'Completed';
            }
            upsert lassignment3;
						*/
        }
    }

    static testmethod void testTrainingPlanDetailChangesOnLearning_KeepNewVersion(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(5,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplan = [select id from Training_Plan__c];
        System.assertEquals(1,tplan.size());

        List<Achievement_Category__c> lAchieveCat = TestAchievementData.createAchievementCategories(1);
        List<Achievement__c> lAchievement = TestAchievementData.createAchievements(1, lAchieveCat.get(0).Id, 'Achievements');
        List<Training_Plan_Achievement__c> lTPlanAchievement = TestTrainingPlanData.createTrainingPlanAchievements(tplan, lAchievement);

        Id tplanId = tplan.get(0).Id;
        Set<Id> selectedUserIds = new Set<Id>();

        for(User u : lmsUsers){
            selectedUserIds.add(u.Id);
        }

        //Test Insert
        Test.startTest();
            System.runAs(adminUsers.get(0)){
                LMSService.upsertAssignments(selectedUserIds,tplanId,null);
            }
        Test.stopTest();

        System.runAs(lmsUsers.get(0)){
            PageReference pageRef = Page.TrainingPlanDetail;
            Test.setCurrentPage(pageRef);
            pageRef.getHeaders().put('User-Agent', 'iPhone');
            ApexPages.Standardcontroller stdcontroller = New ApexPages.StandardController(tplan.get(0));
            TrainingPlanDetailController extension = new TrainingPlanDetailController(stdcontroller);

            List<Training_Plan_Section__c> ltpsec = [select id from Training_Plan_Section__c where Training_Plan__c =: tplan.get(0).Id order by Order__c asc];
            System.assert(ltpsec.size() == 3);

            List<Training_Plan_Section_Item__c> ltpsitem = [select id from Training_Plan_Section_Item__c where Training_Plan_Section__c =: ltpsec.get(0).Id order by Order__c asc];
            System.assert(ltpsitem.size() == 1, 'Training Plan Section Item issues, size = ' + ltpsitem.size());

            extension.selectedSectionId = ltpsec.get(0).Id;
            extension.selectedItemId = ltpsitem.get(0).Id;
            extension.retrieveItemDetails();
            extension.launchLearning();
            System.assert(extension.selectedItemStatusLabel == 'default', 'Error on selectedItemStatusLabel, label = ' + extension.selectedItemStatusLabel);

            List<Learning_Assignment__c> lassignment = [select Id,
                                                            Progress__c from Learning_Assignment__c
                                                            where Training_Plan__c =: tplanId
                                                            and Training_Plan_Section__c =:ltpsec.get(0).Id
                                                            and User__c =: lmsUsers.get(0).Id];

            for(Learning_Assignment__c oa : lassignment){
                oa.Progress__c = 'Completed';
            }

            upsert lassignment;
        }
        List<Training_Plan_Section__c> ltpsection = [select id from Training_Plan_Section__c where Training_Plan__c =: tplan.get(0).Id order by Order__c asc];

        List<Learning_Assignment__c> lassignment3 = [select Id, Learning__c from Learning_Assignment__c
                                                            where Training_Plan__c =: tplanId
                                                            and Training_Plan_Section__c =:ltpsection.get(2).Id
                                                            and User__c =: lmsUsers.get(0).Id];

        List<Learning__c> learning = [select Id from Learning__c where Id =: lassignment3.get(0).Learning__c];
        //create task
        List<Task__c> ttasks = TestLearningData.createTestTask(learning);
        //publish task learning
        TestLearningData.publishLearning(learning.get(0).Id,'task',ttasks.get(0).Id,false);

        System.runAs(lmsUsers.get(0)){
            PageReference pageRef = Page.TrainingPlanDetail;
            Test.setCurrentPage(pageRef);
            pageRef.getHeaders().put('User-Agent', 'iPhone');
            ApexPages.Standardcontroller stdcontroller = New ApexPages.StandardController(tplan.get(0));
            TrainingPlanDetailController extension = new TrainingPlanDetailController(stdcontroller);

            List<Training_Plan_Section__c> ltpsec = [select id from Training_Plan_Section__c where Training_Plan__c =: tplan.get(0).Id order by Order__c asc];
            System.assert(ltpsec.size() == 3);

            List<Training_Plan_Section_Item__c> ltpsitem = [select id from Training_Plan_Section_Item__c where Training_Plan_Section__c =: ltpsec.get(0).Id order by Order__c asc];
            System.assert(ltpsitem.size() == 1, 'Training Plan Section Item issues, size = ' + ltpsitem.size());

            extension.selectedSectionId = ltpsec.get(0).Id;
            extension.selectedItemId = ltpsitem.get(0).Id;
            extension.retrieveItemDetails();
            extension.launchLearning();
            extension.updateToNewVersionAndLaunch();

            List<Training_Plan_Section_Item__c> ltpsitem2 = [select id from Training_Plan_Section_Item__c where Training_Plan_Section__c =: ltpsec.get(1).Id order by Order__c asc];
            System.assert(ltpsitem2.size() == 3, 'Training Plan Section Item issues, size = ' + ltpsitem2.size());

            extension.init();
            extension.selectedSectionId = ltpsec.get(1).Id;
            extension.selectedItemId = ltpsitem2.get(1).Id;
            extension.retrieveItemDetails();
            extension.launchLearning();

        }
    }


    static testmethod void testTrainingPlanDetailChangesOnLearning_KeepOldVersion(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(5,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplan = [select id from Training_Plan__c];
        System.assertEquals(1,tplan.size());

        List<Achievement_Category__c> lAchieveCat = TestAchievementData.createAchievementCategories(1);
        List<Achievement__c> lAchievement = TestAchievementData.createAchievements(1, lAchieveCat.get(0).Id, 'Achievements');
        List<Training_Plan_Achievement__c> lTPlanAchievement = TestTrainingPlanData.createTrainingPlanAchievements(tplan, lAchievement);

        Id tplanId = tplan.get(0).Id;
        Set<Id> selectedUserIds = new Set<Id>();

        for(User u : lmsUsers){
            selectedUserIds.add(u.Id);
        }

        //Test Insert
        Test.startTest();
            System.runAs(adminUsers.get(0)){
                LMSService.upsertAssignments(selectedUserIds,tplanId,null);
            }
        Test.stopTest();

        System.runAs(lmsUsers.get(0)){
            PageReference pageRef = Page.TrainingPlanDetail;
            Test.setCurrentPage(pageRef);
            pageRef.getHeaders().put('User-Agent', 'iPhone');
            ApexPages.Standardcontroller stdcontroller = New ApexPages.StandardController(tplan.get(0));
            TrainingPlanDetailController extension = new TrainingPlanDetailController(stdcontroller);

            List<Training_Plan_Section__c> ltpsec = [select id from Training_Plan_Section__c where Training_Plan__c =: tplan.get(0).Id order by Order__c asc];
            System.assert(ltpsec.size() == 3);

            List<Training_Plan_Section_Item__c> ltpsitem = [select id from Training_Plan_Section_Item__c where Training_Plan_Section__c =: ltpsec.get(0).Id order by Order__c asc];
            System.assert(ltpsitem.size() == 1, 'Training Plan Section Item issues, size = ' + ltpsitem.size());

            extension.selectedSectionId = ltpsec.get(0).Id;
            extension.selectedItemId = ltpsitem.get(0).Id;
            extension.retrieveItemDetails();
            extension.launchLearning();
            System.assert(extension.selectedItemStatusLabel == 'default', 'Error on selectedItemStatusLabel, label = ' + extension.selectedItemStatusLabel);

            List<Learning_Assignment__c> lassignment = [select Id,
                                                            Progress__c from Learning_Assignment__c
                                                            where Training_Plan__c =: tplanId
                                                            and Training_Plan_Section__c =:ltpsec.get(0).Id
                                                            and User__c =: lmsUsers.get(0).Id];

            for(Learning_Assignment__c oa : lassignment){
                oa.Progress__c = 'Completed';
            }

            upsert lassignment;
        }

        //Update learning version on Plan
        List<Training_Plan_Section__c> ltpsection = [select id from Training_Plan_Section__c where Training_Plan__c =: tplan.get(0).Id order by Order__c asc];

        List<Learning_Assignment__c> lassignment3 = [select Id, Learning__c from Learning_Assignment__c
                                                            where Training_Plan__c =: tplanId
                                                            and Training_Plan_Section__c =:ltpsection.get(2).Id
                                                            and User__c =: lmsUsers.get(0).Id];

        List<Learning__c> learning = [select Id from Learning__c where Id =: lassignment3.get(0).Learning__c];
        //create task
        List<Task__c> ttasks = TestLearningData.createTestTask(learning);
        //publish task learning
        TestLearningData.publishLearning(learning.get(0).Id,'task',ttasks.get(0).Id,false);

        System.runAs(lmsUsers.get(0)){
            PageReference pageRef = Page.TrainingPlanDetail;
            Test.setCurrentPage(pageRef);
            pageRef.getHeaders().put('User-Agent', 'iPhone');
            ApexPages.Standardcontroller stdcontroller = New ApexPages.StandardController(tplan.get(0));
            TrainingPlanDetailController extension = new TrainingPlanDetailController(stdcontroller);

            List<Training_Plan_Section__c> ltpsec = [select id from Training_Plan_Section__c where Training_Plan__c =: tplan.get(0).Id order by Order__c asc];
            System.assert(ltpsec.size() == 3);

            List<Training_Plan_Section_Item__c> ltpsitem = [select id from Training_Plan_Section_Item__c where Training_Plan_Section__c =: ltpsec.get(0).Id order by Order__c asc];
            System.assert(ltpsitem.size() == 1, 'Training Plan Section Item issues, size = ' + ltpsitem.size());

            extension.selectedSectionId = ltpsec.get(0).Id;
            extension.selectedItemId = ltpsitem.get(0).Id;
            extension.retrieveItemDetails();
            extension.launchLearning();
            extension.keepOldVersionAndLaunch();

            List<Training_Plan_Section_Item__c> ltpsitem2 = [select id from Training_Plan_Section_Item__c where Training_Plan_Section__c =: ltpsec.get(1).Id order by Order__c asc];
            System.assert(ltpsitem2.size() == 3, 'Training Plan Section Item issues, size = ' + ltpsitem2.size());

            extension.init();
            extension.selectedSectionId = ltpsec.get(1).Id;
            extension.selectedItemId = ltpsitem2.get(1).Id;
            extension.retrieveItemDetails();
            extension.launchLearning();

        }
    }

    static testmethod void testTrainingPlanDetailWebnNoMainAchievement(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(5,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplan = [select id from Training_Plan__c];
        System.assertEquals(1,tplan.size());
        List<Training_Plan_Section__c> tplanSections = [select id,Training_Plan__c from Training_Plan_Section__c where Training_Plan__c = :tplan.get(0).id];


        List<Achievement_Category__c> lAchieveCat = TestAchievementData.createAchievementCategories(1);
        List<Achievement__c> lAchievement = TestAchievementData.createAchievements(1, lAchieveCat.get(0).Id, 'Achievements');
        List<Training_Plan_Achievement__c> lTPlanSectionAchievements = TestTrainingPlanData.createTrainingPlanSectionAchievements(new List<Training_Plan_Section__c>{tplanSections.get(0)},lAchievement);

        Id tplanId = tplan.get(0).Id;
        Set<Id> selectedUserIds = new Set<Id>();

        for(User u : lmsUsers){
            selectedUserIds.add(u.Id);
        }

        //Test Insert
        Test.startTest();
            System.runAs(adminUsers.get(0)){
                LMSService.upsertAssignments(selectedUserIds,tplanId,null);
            }
        Test.stopTest();

        System.runAs(lmsUsers.get(0)){
            PageReference pageRef = Page.TrainingPlanDetail;
            Test.setCurrentPage(pageRef);
            pageRef.getHeaders().put('User-Agent', 'Mozilla');
            ApexPages.Standardcontroller stdcontroller = New ApexPages.StandardController(tplan.get(0));
            TrainingPlanDetailController extension = new TrainingPlanDetailController(stdcontroller);

        }
    }

    static testmethod void testTrainingPlanDetailWithMultipleAchievements(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(5,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplan = [select id from Training_Plan__c];
        System.assertEquals(1,tplan.size());
        List<Training_Plan_Section__c> tplanSections = [select id,Training_Plan__c from Training_Plan_Section__c where Training_Plan__c = :tplan.get(0).id];


        List<Achievement_Category__c> lAchieveCat = TestAchievementData.createAchievementCategories(1);
        //Create multiple achievments tied to the plan
        List<Achievement__c> lAchievement = TestAchievementData.createAchievements(2, lAchieveCat.get(0).Id, 'Achievements');
        List<Achievement__c> lSectionAchievements = TestAchievementData.createAchievements(2, lAchieveCat.get(0).Id, 'Achievements');
        List<Training_Plan_Achievement__c> lTPlanAchievement1 = TestTrainingPlanData.createTrainingPlanAchievements(tplan, new List<Achievement__c>{lAchievement.get(0)});
        List<Training_Plan_Achievement__c> lTPlanAchievement2 = TestTrainingPlanData.createTrainingPlanAchievements(tplan, new List<Achievement__c>{lAchievement.get(1)});
        List<Training_Plan_Achievement__c> lTPlanSectionAchievements1 = TestTrainingPlanData.createTrainingPlanSectionAchievements(new List<Training_Plan_Section__c>{tplanSections.get(0)},new List<Achievement__c>{lSectionAchievements.get(0)});
        List<Training_Plan_Achievement__c> lTPlanSectionAchievements2 = TestTrainingPlanData.createTrainingPlanSectionAchievements(new List<Training_Plan_Section__c>{tplanSections.get(0)},new List<Achievement__c>{lSectionAchievements.get(1)});

        Id tplanId = tplan.get(0).Id;
        Set<Id> selectedUserIds = new Set<Id>();

        for(User u : lmsUsers){
            selectedUserIds.add(u.Id);
        }

        //Test Insert
        Test.startTest();
            System.runAs(adminUsers.get(0)){
                LMSService.upsertAssignments(selectedUserIds,tplanId,null);
            }
        Test.stopTest();

        System.runAs(lmsUsers.get(0)){
            PageReference pageRef = Page.TrainingPlanDetail;
            Test.setCurrentPage(pageRef);
            pageRef.getHeaders().put('User-Agent', 'Mozilla');
            ApexPages.Standardcontroller stdcontroller = New ApexPages.StandardController(tplan.get(0));
            TrainingPlanDetailController extension = new TrainingPlanDetailController(stdcontroller);
            
            extension.campaignStatusButton();
            extension.createTrainingPlanBookmark();

        }
    }
    
    static testMethod void testMoodle() { 

		Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        List<Account> AsAccList = new List<Account>();
        
        Account acc = new Account();
        acc.FirstName = 'Sample Person';
        acc.LastName = 'Account';
        acc.PersonEmail = 'person@test.com';
        acc.RecordTypeId = personAccountId;
        AsAccList.add( acc );
        
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
       
        
        LMS_Instance__c lmsInstance = new LMS_Instance__c();
        lmsInstance.AS_Instance_Long_Name__c = 'sample instance';
        lmsInstance.Status__c = 'Active';
        lmsInstance.Token__c = '1234567890';
        lmsInstance.Type__c = 'Moodle';
        lmsInstance.Domain_URL__c = 'https://google.com/';
        insert lmsInstance;
        
        LMS_Course__c lc    = new LMS_Course__c();
        lc.Name             = 'test';
        lc.Date__c          = date.today();
        lc.Status__c        = 'Active';
        lc.LMS_Instance__c = lmsInstance.Id;
        lc.AsMoodleResponse__c = 'Course successfully created';
        lc.Moodle_Course_Id__c = '104';
        insert lc; 
        
        Training_Plan__c tplan             = new Training_Plan__c();
        tplan.Name                         = 'test tp';
        tplan.Status__c                     = 'Active';
        tplan.Type__c                         = 'Member Benefit';
        tplan.Enable_Self_Registration__c     = true;
        tplan.AS_LMS_Course__c                = lc.Id;
        tplan.AS_LMS_Instance__c             = lmsInstance.Id;
        tplan.AS_LMS__c                        = 'Moodle Course';
        tplan.Self_Registration_Access__c     = 'External';
        insert tplan;
        
        Training_Plan_Section__c tps 	= new Training_Plan_Section__c();
        tps.Name 						= 'test tps';
        tps.Training_Plan__c 			= tplan.Id;
        insert tps;

        Id learnmoodlerecId = Schema.SObjectType.Learning__c.getRecordTypeInfosByName().get('Moodle').getRecordTypeId();
        
        Learning__c learn  = new Learning__c();
        learn.RecordTypeId = learnmoodlerecId;
        learn.Name         = 'test l';
        learn.AS_Group_1_CPD__c = 100;
        learn.AS_Group_2_CPD__c = 200;
        learn.AS_LMS_type__c       = 'Activity';
        learn.AS_Activity_Type__c = 'Lesson';
        learn.LMS_Instance__c = lmsInstance.Id;
        learn.AS_Training_Plan__c = tplan.Id;
        learn.Description__c = 'test2132';
        learn.Published__c   = true;
        insert learn;
        
        Training_Plan_Section_Item__c tpsectItem = new Training_Plan_Section_Item__c();
        tpsectItem.Learning__c = learn.Id;
        tpsectItem.Training_Plan_Section__c = tps.Id;
        insert tpsectItem;
        
        
        
          	list<Learning__c> getLearn = [select Id, Name, AsMoodle_Course_URL__c from Learning__c where Id =: learn.Id];
            //list<Learning__c> getLearn = [select Id, Name, AsMoodle_Course_URL__c from Learning__c where Id =: learn.Id];
            System.debug('learn  =====>'+ getLearn);
            string url = getLearn[0].AsMoodle_Course_URL__c;
        
        
        	List<User> theUser = [Select Id, AccountId,Account.PersonEmail,Contact.AccountId from User where Email = 'person@test.com' ];
        
        	System.runAs(theUser.get(0)){

                PageReference pageRef = Page.TrainingPlanDetail;
                pageRef.getParameters().put( 'id', tplan.Id );
                Test.setCurrentPage(pageRef);
                
                TrainingPlanDetailController extension = new TrainingPlanDetailController();
                extension.selectedSectionId = tps.Id;
                extension.selectedItemId = tpsectItem.Id;
                extension.retrieveItemDetails();
                extension.launchLearning();
            
        	}
    }

}