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
public class AsTrainTrackAccTriggerHandlerTest {
    static testMethod void TrackAssgnmttest(){
    	List<As_TPlan_Assignment_Task__c> tplanTaskList = [select id,As_Status__c from As_TPlan_Assignment_Task__c];
	    System.assertEquals(1,tplanTaskList.size());

	    As_TPlan_Assignment_Task__c tplanTask = tplanTaskList.get(0);
	    tplanTask.As_Status__c = 'In Progress';
	    update tplanTask;
	    
	    Test.startTest();
	    	String jobId = System.schedule('Training Track and Moodle batch 2', '0 0 0 15 3 ? 2030', new AS_batchTrainTrackAndMoodleScheduler());
     	Test.stopTest();
     	
    }
    
    static testMethod void TrackAssgnmtERRORtest(){
    	List<As_TPlan_Assignment_Task__c> tplanTaskList = [select id,As_Status__c from As_TPlan_Assignment_Task__c];
	    System.assertEquals(1,tplanTaskList.size());

	    As_TPlan_Assignment_Task__c tplanTask = tplanTaskList.get(0);
	    tplanTask.As_Status__c = 'In Progress';
	    tplanTask.As_User__c = null;
	    update tplanTask;
	    
	    Test.startTest();
	    	String jobId = System.schedule('Training Track and Moodle batch 3', '0 0 0 15 3 ? 2030', new AS_batchTrainTrackAndMoodleScheduler());
     	Test.stopTest();
    }
    
    @TestSetup  
 		static void testData() {
    	Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
			Account acc = new Account();
	    acc.FirstName = 'AlphaSys';
	    acc.LastName = 'Account12345';
	    acc.recordTypeId = personAccRecId;
	    acc.PersonEmail = 'memberuser@testorg.com';
	    insert acc;
	    
	    // Create a unique UserName
	    String uniqueUserName1 = 'memberuser' + DateTime.now().getTime() + '@testorg.com';
			// This code runs as the system user
			Profile p = [SELECT Id FROM Profile WHERE Name='Member Login User'];
			Account acc1 = [SELECT Id,PersonContactId FROM Account WHERE Id =:acc.Id];
			
			System.debug('acc1 : ' + acc1);
			
			User use = new User(Alias = 'standt', Email='memberuser@testorg.com',
			EmailEncodingKey='UTF-8', LastName='mongrel', LanguageLocaleKey='en_US',
			LocaleSidKey='en_US', ProfileId = p.Id,
			ContactId = acc1.PersonContactId,
			TimeZoneSidKey='America/Los_Angeles',
			isActive = true,
			UserName=uniqueUserName1);
			insert use;
			
	    //Create admin users
	    List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
	    List<User> lmsUsers = TestUtilClass.createUsers(5,'Standard User');

	    System.runAs(adminUsers.get(0)){
	        //Assign corresponding perm sets
	        TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
	        TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
	    }

    	TestTrainingTrackData.createSampleData();

	    List<Training_Plan__c> tplan = [select id from Training_Plan__c];
	    System.assertEquals(3,tplan.size());

	    Id tplanId1 = tplan.get(0).Id;
	    Id tplanId2 = tplan.get(1).Id;
	    Id tplanId3 = tplan.get(2).Id;

    	Set<Id> selectedUserIds = new Set<Id>{lmsUsers.get(0).Id};

	    System.runAs(adminUsers.get(0)){
        //Upsert assignemtns for tplan 1
   			LMSService.upsertAssignments(selectedUserIds,tplanId1,null);
	    	//   LMSService.upsertAssignments(selectedUserIds,tplanId2,null);
	    	//    LMSService.upsertAssignments(selectedUserIds,tplanId3,null);
	    }

    	//Add achievement to the training track
				
	    List<Achievement_Category__c> lAchieveCat = TestAchievementData.createAchievementCategories(1);
	    List<Achievement__c> lAchievement = TestAchievementData.createAchievements(1, lAchieveCat.get(0).Id, 'Achievements');
	    List<Training_Track__c> tracks = [select id,Achievement__c,name from Training_Track__c];
	    tracks.get(0).Achievement__c = lAchievement.get(0).id;
	    update tracks.get(0);

    	List<Training_Track_Level_Item__c> trackItems = [select id,name from Training_Track_Level_Item__c];

	    System.assertEquals(1,tracks.size());
	    System.assert(trackItems.size()>0);
				
			Training_Track_Account__c tAcc = new Training_Track_Account__c();
			tAcc.AS_Approval_Status__c = 'Confirmed';
			tAcc.Training_Track__c = tracks[0].Id;
			tAcc.Account__c = acc.Id;
			insert tAcc;
			
			List<As_TPlan_Assignment_Task__c> allTobeDeletedTask = new List<As_TPlan_Assignment_Task__c>();
    	Integer deleteCntrInt = 1;
    	for(As_TPlan_Assignment_Task__c task: [Select Id from As_TPlan_Assignment_Task__c]){
    		if(deleteCntrInt > 1) {
	    		As_TPlan_Assignment_Task__c tobeDeletedTask = new As_TPlan_Assignment_Task__c();
	    		tobeDeletedTask.Id = task.Id;
	    		allTobeDeletedTask.add(tobeDeletedTask);
    		}
    		deleteCntrInt = deleteCntrInt + 1;
    	}
    	
    	delete allTobeDeletedTask;
    	
    	Test.startTest();
	    	String jobId = System.schedule('Training Track and Moodle batch', '0 0 0 15 3 ? 2030', new AS_batchTrainTrackAndMoodleScheduler());
	    	
	    	System.enqueueJob(new AsTrainTrackAssignment(null,null,null));
     	Test.stopTest();
    }
}