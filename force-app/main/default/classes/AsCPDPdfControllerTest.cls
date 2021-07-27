/*Author : John Hope
*Description : This is a test class for creation of pdf that is connected to cpd objects class.
*Date Created : 
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data : AsCPDPdfController.cls
 */
 @isTest
private class AsCPDPdfControllerTest {

	static testMethod void createCPDPdf() {
		List<Id> allCPDId =new List<Id>();
		for(AsCPDPlanner__c cpd :[Select Id from AsCPDPlanner__c where name = 'Alphasys CPD 2018']) {
			allCPDId.add(cpd.Id);
		}
		AsCPDPdfController.createCPDPdf(allCPDId);
		
		System.AssertEquals(allCPDId.size(),1); 
	}
	
	static testMethod void createCPDPdfByButton() {
		List<AsCPDPlanner__c> allCPD = [Select Id,Name from AsCPDPlanner__c where name = 'Alphasys CPD 2018'];
		AsCPDPdfController.createCPDPdfByButton(allCPD[0].Id);
		
		System.AssertEquals(allCPD.size(),1); 
	}
	
	static testMethod void createTrainPlanAssignPdf() {
		List<AsCPD_Learning_Summary__c> allSumm = [Select Id,Name from AsCPD_Learning_Summary__c where Name = 'AlphaSys Learning Summary' LIMIT 1];
		AsCPDPdfController.createTrainPlanAssignPdf(allSumm[0].Id);
		
		System.AssertEquals(allSumm.size(),1); 
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
		
		insert allTrainPlanAss;
		
		// creation of new user
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
    User finalUser = new User(Alias = 'lrnStan', Email='learnstandarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='learnstandarduser@testorg.com');
    insert finalUser;
    
    // create new cpd
    AsCPDPlanner__c cpdPlan = new AsCPDPlanner__c();
    cpdPlan.Name = 'Alphasys CPD 2018';
    cpdPlan.AS_Current_CPD_Plan__c = true;
    cpdPlan.AsUser__c = finalUser.Id;
    cpdPlan.AS_Plan_Year__c = '2018';
    insert cpdPlan;
		
		List<AsCPD_Learning_Summary__c> allLearnSum = new List<AsCPD_Learning_Summary__c>();
		
		AsCPD_Learning_Summary__c learnSum1 = new AsCPD_Learning_Summary__c();
		learnSum1.Name = 'AlphaSys Learning Summary';
		learnSum1.ASTraining_Plan_Assignment__c = allTrainPlanAss[0].Id;
		learnSum1.CPD_Planner__c = cpdPlan.Id;
		allLearnSum.add(learnSum1);
		
		insert allLearnSum;
		
		
		
	}
	
	
}