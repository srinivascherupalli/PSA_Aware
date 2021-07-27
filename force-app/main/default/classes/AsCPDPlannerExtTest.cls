/*Author : John Hope
*Description : This is a test class for AsCPDPlannerExt class.
*Date Created : June 8, 2018
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data : AsCPDPlannerExt.cls
 */
 @isTest
private class AsCPDPlannerExtTest {
	static testMethod void cpdExt() { 
		AsCPDPlanner__c cpdPlan = [Select Id,AsUser__r.Alias from AsCPDPlanner__c where AsUser__r.Email = 'cpdPlanstandarduser@testorg.com'];
    
    ApexPages.StandardController sc = new ApexPages.StandardController(cpdPlan);
    AsCPDPlannerExt cpd = new AsCPDPlannerExt(sc);
    
    System.AssertEquals(cpdPlan.AsUser__r.Alias,'lrnStan'); 
	}
	
	@TestSetup  
	static void createData() {
		List<Training_Plan__c> allTrainPlan = new List<Training_Plan__c>();
		
		TestTrainingPlanData.createSampleData();
		
	 	List<Training_Plan__c> tplans = [select id
                                            ,Enable_Self_Registration__c
                                            ,Self_Registration_Access__c
                                            from Training_Plan__c];

		Training_Plan__c TrainPlan = tplans.get(0);
		
		List<Training_Plan_Assignment__c> allTrainPlanAss = new List<Training_Plan_Assignment__c>();
		
		Training_Plan_Assignment__c trainPlanAss1 = new Training_Plan_Assignment__c();
		trainPlanAss1.Training_Plan__c = TrainPlan.Id;
		trainPlanAss1.Status__c = 'Completed'; // 
		allTrainPlanAss.add(trainPlanAss1);


		Training_Plan_Assignment__c trainPlanAss2 = new Training_Plan_Assignment__c();
		trainPlanAss2.Training_Plan__c = TrainPlan.Id;
		trainPlanAss2.Status__c = 'In Progress'; // 
		allTrainPlanAss.add(trainPlanAss2);
		

		Training_Plan_Assignment__c trainPlanAss3 = new Training_Plan_Assignment__c();
		trainPlanAss3.Training_Plan__c = TrainPlan.Id;
		trainPlanAss3.Status__c = 'Planned'; // 
		allTrainPlanAss.add(trainPlanAss3);

		insert allTrainPlanAss;
		
		// creation of new user
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
    User finalUser = new User(Alias = 'lrnStan', Email='cpdPlanstandarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='cpdPlanstandarduser@testorg.com');
    insert finalUser;
    
    // create new cpd
    AsCPDPlanner__c cpdPlan = new AsCPDPlanner__c();
    cpdPlan.AS_Current_CPD_Plan__c = true;
    cpdPlan.AsUser__c = finalUser.Id;
    cpdPlan.AS_Plan_Year__c = '2018';
    insert cpdPlan;
		
		List<AsCPD_Learning_Summary__c> allLearnSum = new List<AsCPD_Learning_Summary__c>();
		
		AsCPD_Learning_Summary__c learnSum1 = new AsCPD_Learning_Summary__c();
		learnSum1.Name = 'AlphaSys Learning Summary';
		learnSum1.ASTraining_Plan_Assignment__c = allTrainPlanAss[0].Id;
		learnSum1.CPD_Planner__c = cpdPlan.Id;
		learnSum1.AsSummary_Plan__c  = true;
		learnSum1.Status__c = 'Complete';
		allLearnSum.add(learnSum1); 		

		AsCPD_Learning_Summary__c learnSum2= new AsCPD_Learning_Summary__c();
		learnSum2.Name = 'AlphaSys Learning Summary';
		learnSum2.ASTraining_Plan_Assignment__c = allTrainPlanAss[1].Id;
		learnSum2.CPD_Planner__c = cpdPlan.Id;
		learnSum2.AsSummary_Plan__c  = true;
		learnSum2.Status__c = 'In Progress';
		allLearnSum.add(learnSum2); 		

		AsCPD_Learning_Summary__c learnSum3= new AsCPD_Learning_Summary__c();
		learnSum3.Name = 'AlphaSys Learning Summary';
		learnSum3.ASTraining_Plan_Assignment__c = allTrainPlanAss[2].Id;
		learnSum3.CPD_Planner__c = cpdPlan.Id;
		learnSum3.AsSummary_Plan__c  = true;
		learnSum3.Status__c = 'Planned';
		allLearnSum.add(learnSum3); 	

		insert allLearnSum;
	}

		
	/*@TestSetup  
	static void createData1() {
		List<Training_Plan__c> allTrainPlan = new List<Training_Plan__c>();
		
		TestTrainingPlanData.createSampleData();
		
	 	List<Training_Plan__c> tplans = [select id
                                            ,Enable_Self_Registration__c
                                            ,Self_Registration_Access__c
                                            from Training_Plan__c];

		Training_Plan__c TrainPlan = tplans.get(0);
		
		List<Training_Plan_Assignment__c> allTrainPlanAss = new List<Training_Plan_Assignment__c>();
		
		Training_Plan_Assignment__c trainPlanAss1 = new Training_Plan_Assignment__c();
		trainPlanAss1.Training_Plan__c = TrainPlan.Id;
		trainPlanAss1.Status__c = 'Complete'; // 
		allTrainPlanAss.add(trainPlanAss1);
		
		insert allTrainPlanAss;
		
		// creation of new user
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
    User finalUser = new User(Alias = 'lrnStan1', Email='cpdPlanstandarduser1@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='cpdPlanstandarduser1@testorg.com');
    insert finalUser;
    
    // create new cpd
    AsCPDPlanner__c cpdPlan = new AsCPDPlanner__c();
    cpdPlan.AS_Current_CPD_Plan__c = true;
    cpdPlan.AsUser__c = finalUser.Id;
    cpdPlan.AS_Plan_Year__c = '2018';
    insert cpdPlan;
		
		List<AsCPD_Learning_Summary__c> allLearnSum = new List<AsCPD_Learning_Summary__c>();
		
		AsCPD_Learning_Summary__c learnSum1 = new AsCPD_Learning_Summary__c();
		learnSum1.Name = 'AlphaSys Learning Summary';
		learnSum1.ASTraining_Plan_Assignment__c = allTrainPlanAss[0].Id;
		learnSum1.CPD_Planner__c = cpdPlan.Id;
		learnSum1.AsSummary_Plan__c  = true;
		learnSum1.Status__c = 'In Progress';
		allLearnSum.add(learnSum1); 		
		insert allLearnSum;
	}*/
}