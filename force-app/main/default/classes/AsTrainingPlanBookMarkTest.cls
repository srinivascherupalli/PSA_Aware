@isTest
private class AsTrainingPlanBookMarkTest {
	
	/*Author : Jet R. Compayan
	*Description : This is a test class for isCreateTrainingPlanBookmarkTest method
	*Date Created : May 25, 2018
	*Last Modified By : 
	*Date Last Modified : May 25, 2018
	*Related Meta Data : 
	*Param : NA
	*Return : NA
 	*/
	@isTest static void isCreateTrainingPlanBookmarkTest() {

	 	// Create a unique UserName
		String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
		// This code runs as the system user
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
		User use = new User(Alias = 'standt', Email='standarduser@testorg.com',
		EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
		LocaleSidKey='en_US', ProfileId = p.Id,
		TimeZoneSidKey='America/Los_Angeles',
		 UserName=uniqueUserName);
		insert use;
		System.runAs(use) {

		   	// creation of CPD Planner starts here
		   	AsCPDPlanner__c planner = new AsCPDPlanner__c();
		   	planner.AsUser__c = use.Id;
		   	planner.Name = 'Jet planner review';
		   	planner.AS_Current_CPD_Plan__c = true;
		   	planner.AS_Plan_Year__c = '2019';
		   	insert planner;

			// creation of training plan link starts here
			List<Training_Plan__c> allTrainPlan = new List<Training_Plan__c>();

			Training_Plan__c trainPlanLink1 = new Training_Plan__c();
			trainPlanLink1.Name = 'New training Plan';
			trainPlanLink1.Description__c = 'New training Plan Description';
			allTrainPlan.add(trainPlanLink1);

			Training_Plan__c trainPlanLink2 = new Training_Plan__c();
			trainPlanLink2.Name = 'New training Plan 2';
			trainPlanLink2.Description__c = 'New training Plan Description 2';
			allTrainPlan.add(trainPlanLink2);

			Training_Plan__c trainPlanLink3 = new Training_Plan__c();
			trainPlanLink3.Name = 'New training Plan 3';
			trainPlanLink3.Description__c = 'New training Plan Description 3';
			allTrainPlan.add(trainPlanLink3);

			insert allTrainPlan;

			// creation of AsTrainingPlanBookmark__c starts here
			List<AsTrainingPlanBookmark__c> alltrainPlanBook = new List<AsTrainingPlanBookmark__c>();

			AsTrainingPlanBookmark__c trainPlanBook1 = new AsTrainingPlanBookmark__c();
			trainPlanBook1.AsTrainingPlan__c = allTrainPlan[0].Id;
			trainPlanBook1.AsCPDPlanner__c = planner.Id;
			alltrainPlanBook.add(trainPlanBook1);

			AsTrainingPlanBookmark__c trainPlanBook2 = new AsTrainingPlanBookmark__c();
			trainPlanBook2.AsTrainingPlan__c = allTrainPlan[1].Id;
			trainPlanBook2.AsCPDPlanner__c = planner.Id;
			alltrainPlanBook.add(trainPlanBook2);

			AsTrainingPlanBookmark__c trainPlanBook3 = new AsTrainingPlanBookmark__c();
			trainPlanBook3.AsTrainingPlan__c = allTrainPlan[2].Id;
			trainPlanBook3.AsCPDPlanner__c = planner.Id;
			alltrainPlanBook.add(trainPlanBook3);

			insert alltrainPlanBook;

			TestTrainingPlanData.createSampleData();
			List<Training_Plan__c> tplan = [select id from Training_Plan__c];

			Id tplanId = tplan.get(0).Id;

			Boolean isRes = AsTrainingPlanBookMark.isCreateTrainingPlanBookmark( use.Id , tplanId );
			System.assertEquals(true,isRes);

		}


	}
	
	/*Author : Jet R. Compayan
	*Description : This is a test class for isCheckTrainingPlanInBookMark method
	*Date Created : May 25, 2018
	*Last Modified By : 
	*Date Last Modified : May 25, 2018
	*Related Meta Data : 
	*Param : NA
	*Return : NA
 	*/
	@isTest static void isCheckTrainingPlanInBookMarkTest() {
			// Create a unique UserName
		String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
		// This code runs as the system user
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
		User use = new User(Alias = 'standt', Email='standarduser@testorg.com',
		EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
		LocaleSidKey='en_US', ProfileId = p.Id,
		TimeZoneSidKey='America/Los_Angeles',
		 UserName=uniqueUserName);
		insert use;
		System.runAs(use) {

		   	// creation of CPD Planner starts here
		   	AsCPDPlanner__c planner = new AsCPDPlanner__c();
		   	planner.AsUser__c = use.Id;
		   	planner.Name = 'Jet planner review';
		   	planner.AS_Current_CPD_Plan__c = true;
		   	planner.AS_Plan_Year__c = '2019';
		   	insert planner;

			// creation of training plan link starts here
			List<Training_Plan__c> allTrainPlan = new List<Training_Plan__c>();

			Training_Plan__c trainPlanLink1 = new Training_Plan__c();
			trainPlanLink1.Name = 'New training Plan';
			trainPlanLink1.Description__c = 'New training Plan Description';
			allTrainPlan.add(trainPlanLink1);

			Training_Plan__c trainPlanLink2 = new Training_Plan__c();
			trainPlanLink2.Name = 'New training Plan 2';
			trainPlanLink2.Description__c = 'New training Plan Description 2';
			allTrainPlan.add(trainPlanLink2);

			Training_Plan__c trainPlanLink3 = new Training_Plan__c();
			trainPlanLink3.Name = 'New training Plan 3';
			trainPlanLink3.Description__c = 'New training Plan Description 3';
			allTrainPlan.add(trainPlanLink3);

			insert allTrainPlan;

			// creation of AsTrainingPlanBookmark__c starts here
			List<AsTrainingPlanBookmark__c> alltrainPlanBook = new List<AsTrainingPlanBookmark__c>();

			AsTrainingPlanBookmark__c trainPlanBook1 = new AsTrainingPlanBookmark__c();
			trainPlanBook1.AsTrainingPlan__c = allTrainPlan[0].Id;
			trainPlanBook1.AsCPDPlanner__c = planner.Id;
			alltrainPlanBook.add(trainPlanBook1);

			AsTrainingPlanBookmark__c trainPlanBook2 = new AsTrainingPlanBookmark__c();
			trainPlanBook2.AsTrainingPlan__c = allTrainPlan[1].Id;
			trainPlanBook2.AsCPDPlanner__c = planner.Id;
			alltrainPlanBook.add(trainPlanBook2);

			AsTrainingPlanBookmark__c trainPlanBook3 = new AsTrainingPlanBookmark__c();
			trainPlanBook3.AsTrainingPlan__c = allTrainPlan[2].Id;
			trainPlanBook3.AsCPDPlanner__c = planner.Id;
			alltrainPlanBook.add(trainPlanBook3);

			insert alltrainPlanBook;

			TestTrainingPlanData.createSampleData();
			List<Training_Plan__c> tplan = [select id from Training_Plan__c];

			Id tplanId = tplan.get(0).Id;

			Boolean isRes = AsTrainingPlanBookMark.isCheckTrainingPlanInBookMark( use.Id , tplanId );
			System.assertEquals(false,isRes);

		}
	}

}