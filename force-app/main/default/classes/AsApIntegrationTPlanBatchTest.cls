/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class AsApIntegrationTPlanBatchTest {
	
	static testMethod void runTheBatchTest() {
		
		Test.StartTest();
	   	As_AP_Integration__c indiIntegration = [Select Id from As_AP_Integration__c where As_Status__c = 'Processed' limit 1];
        
        Set<Id> setNullIDs = new Set<Id>();
		AsApIntegrationTPlanBatch runBatch = new AsApIntegrationTPlanBatch(indiIntegration.Id,setNullIDs); // this part call's the next batch process for AP Integration
   		database.executeBatch(runBatch); 	
		Test.StopTest();
		
		List<As_AP_Integration__c> assertIntegration = [Select Id from As_AP_Integration__c where As_Status__c = 'Processed'];
		System.Assert(assertIntegration.size() > 0);
	}
	
	static testMethod void AS_batchApIntegrationSchedulerTest() {
		Test.StartTest();
	   	String jobId = System.schedule('testBasicScheduledApex','0 0 0 3 9 ? 2022',new AS_batchApIntegrationScheduler());
		Test.StopTest();
	}
	
	@TestSetup  
 	static void testData() {
 		 //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
      //  List<User> lmsUsers = TestUtilClass.createUsers(5,'Standard User');
        List<User> lmsUsers = new List<User>();
        
        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
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
				
        lmsUsers.add(indiUser);
        
        System.runAs(adminUsers.get(0)){
	   	 		
	        //Assign corresponding perm sets
	        TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
	       // TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplan = [select id from Training_Plan__c];
        System.assertEquals(1,tplan.size());	
        
        
        LMS_Instance__c lmsInstance = new LMS_Instance__c();
				lmsInstance.AS_Instance_Long_Name__c = 'sample instance';
				lmsInstance.Status__c = 'Active';
				lmsInstance.Token__c = '1234567890123';
				lmsInstance.Type__c = 'Moodle';
				lmsInstance.Domain_URL__c = 'https://samplewebsite.com';
				lmsInstance.URL__c = 'https://samplewebsite.com';
				insert lmsInstance;
        
        List<Learning__c> allTobeUpdateLearnList = new List<Learning__c>();
        for(Learning__c learn : [Select Id from Learning__c]) {
        	Learning__c indiLearn = new Learning__c();
        	indiLearn.Id = learn.Id;
        	indiLearn.LMS_Instance__c = lmsInstance.Id;
        	allTobeUpdateLearnList.add(indiLearn);
        }
        update allTobeUpdateLearnList;
        
				List<As_AP_Integration__c> allApIntegration = new List<As_AP_Integration__c>();
				
				As_AP_Integration__c apInt1 = new As_AP_Integration__c();
				apInt1.As_User_ID__c = lmsUsers[0].Id;
				apInt1.As_Training_Plan_ID__c = tplan[0].Id;
				apInt1.As_Learning_ID__c = allTobeUpdateLearnList[0].Id;
				apInt1.As_Status__c = 'Not Processed';
				allApIntegration.add(apInt1);
				
				As_AP_Integration__c apInt2 = new As_AP_Integration__c();
				apInt2.As_User_ID__c = null;
				apInt2.As_Training_Plan_ID__c = null;
				apInt2.As_Learning_ID__c = null;
				apInt2.As_Status__c = 'Not Processed';
				allApIntegration.add(apInt2);
				
				As_AP_Integration__c apInt3 = new As_AP_Integration__c();
				apInt3.As_User_ID__c = '123';
				apInt3.As_Training_Plan_ID__c = '123';
				apInt3.As_Learning_ID__c = '123';
				apInt3.As_Status__c = 'Not Processed';
				allApIntegration.add(apInt3);
				
				insert allApIntegration;
				
				List<Contact> allCon = [Select Id,Name from Contact];
				System.debug('allCon : ' + allCon);
				
				Test.StartTest();
	        	Id nullId;
        		Set<Id> setNullIDs = new Set<Id>();
				AsApIntegrationTPlanBatch runBatch = new AsApIntegrationTPlanBatch(nullId,setNullIDs); // this part call's the next batch process for AP Integration
		   		database.executeBatch(runBatch); 
					
				Test.StopTest();
				
				//List<As_AP_Integration__c> assertIntegration = [Select Id from As_AP_Integration__c where As_Status__c = 'Not Processed'];
				//System.Assert(assertIntegration.size() == 0);
 	}
}