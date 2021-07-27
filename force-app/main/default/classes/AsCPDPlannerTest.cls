/*Author : John Hope
*Description : This is a test class for AsCPDPlanner class.
*Date Created : May 4, 2018
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data : AsCPDPlanner.cls
 */
@isTest
private class AsCPDPlannerTest {
	/*Author : John Hope
	*Description : This is a test class for allCPDPlannerCompetencies method
	*Date Created : May 4, 2018
	*Last Modified By : 
	*Date Last Modified : May 4, 2018
	*Related Meta Data : 
	*Param : NA
	*Return : NA
 	*/
 
	static testMethod void allCPDPlannerCompetencies() {
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
			// creation of AsCPDPlannerReview__c starts here
    	AsCPDPlannerReview__c planRev = new AsCPDPlannerReview__c();
    	planRev.AsUser__c = use.Id;
    	planRev.Name = 'hope planner review';
    	insert planRev;
    	// creation of AsCPDPlannerReview__c ends here
    	
	    // creation of competencies starts here
			List<AsCPDPlannerCompetencies__c> allCom = new List<AsCPDPlannerCompetencies__c>();
			
			AsCPDPlannerCompetencies__c indi1Com = new AsCPDPlannerCompetencies__c();
			indi1Com.AsStatus__c = 'Active';
			indi1Com.AsDomain__c = 'Domain 3';
			indi1Com.Name = 'domain 3';
			allCom.add(indi1Com);
			
			AsCPDPlannerCompetencies__c indi2Com = new AsCPDPlannerCompetencies__c();
			indi2Com.AsStatus__c = 'Active';
			indi2Com.AsDomain__c = 'Domain 3';
			indi2Com.Name = 'domain 4';
			allCom.add(indi2Com);
			
			insert allCom;
			// creation of competencies ends here
	    
	    // creation of competency plan links starts here
    	List<AsCPDPlannerCompetencieslink__c> allPlanComLink = new List<AsCPDPlannerCompetencieslink__c>();
    	
    	AsCPDPlannerCompetencieslink__c planCom1Link = new AsCPDPlannerCompetencieslink__c();
    	planCom1Link.AsCPDPlannerCompetencies__c = allCom[1].Id;
			planCom1Link.AsCPDPlannerReview__c = planRev.Id;
			allPlanComLink.add(planCom1Link);
			
			insert allPlanComLink;
			// creation of competency plan links ends here
	    
	    AsCPDPlanner.allCPDPlannerCompetencies('');
	    
	    // assertion
	    System.AssertEquals(database.countquery('SELECT '
	           																		+ 'COUNT()'
	              															+' FROM'
	              																+' AsCPDPlannerCompetencieslink__c '
	              															),1
	              					); 
		}
	   
	}
	
	/*Author : John Hope
	*Description : This is a test class for allCPDTopics method
	*Date Created : May 4, 2018
	*Last Modified By : 
	*Date Last Modified : May 4, 2018
	*Related Meta Data : 
	*Param : NA
	*Return : NA
 	*/
 	
	static testMethod void allCPDTopics() {
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
			// creation of AsCPDPlannerReview__c starts here
    	AsCPDPlannerReview__c planRev = new AsCPDPlannerReview__c();
    	planRev.AsUser__c = use.Id;
    	planRev.Name = 'hope planner review';
    	insert planRev;
    	// creation of AsCPDPlannerReview__c ends here
    	
    	// creation of topics starts here
			List<AsCPDPlannerTopic__c> allTop = new List<AsCPDPlannerTopic__c>();
			
			AsCPDPlannerTopic__c indi1Top = new AsCPDPlannerTopic__c();
			indi1Top.AsStatus__c = 'Active';
			indi1Top.Name = 'Topic 1';
			allTop.add(indi1Top);
			
			insert allTop;
			// creation of topics ends here
    	
    	// creation of topic plan links starts here
    	List<AsCPDPlannerTopicLink__c> allPlanTopLink = new List<AsCPDPlannerTopicLink__c>();
    	
    	AsCPDPlannerTopicLink__c planTop1Link = new AsCPDPlannerTopicLink__c();
    	planTop1Link.AsCPDPlannerTopic__c = allTop[0].Id;
			planTop1Link.AsCPDPlannerReview__c = planRev.Id;
			allPlanTopLink.add(planTop1Link);
			
			insert allPlanTopLink;
			// creation of topic plan links ends here
	    	
	    AsCPDPlanner.allCPDTopics('');
	    
	    // assertion
	    System.AssertEquals(database.countquery('SELECT '
	           																		+ 'COUNT()'
	              															+' FROM'
	              																+' AsCPDPlannerTopicLink__c '
	              															),1
	              					); 
		}
	}
	
	/*Author : John Hope
	*Description : This is a test class for allCPDTopics method
	*Date Created : May 4, 2018
	*Last Modified By : 
	*Date Last Modified : May 4, 2018
	*Related Meta Data : 
	*Param : NA
	*Return : NA
 	*/
 	
	static testMethod void processCPD() {
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
	    	// creation of AsCPDPlannerReview__c starts here
	    	AsCPDPlannerReview__c planRev = new AsCPDPlannerReview__c();
	    	planRev.AsUser__c = use.Id;
	    	planRev.Name = 'hope planner review';
	    	insert planRev;
	    	// creation of AsCPDPlannerReview__c ends here
	    	
	    	// creation of competencies starts here
	    	List<AsCPDPlannerCompetencies__c> allCom = new List<AsCPDPlannerCompetencies__c>();
	    	
	    	AsCPDPlannerCompetencies__c indi1Com = new AsCPDPlannerCompetencies__c();
	    	indi1Com.AsStatus__c = 'Active';
	    	indi1Com.AsDomain__c = 'Domain 3';
	    	indi1Com.Name = 'domain 3';
	    	allCom.add(indi1Com);
	    	
	    	AsCPDPlannerCompetencies__c indi2Com = new AsCPDPlannerCompetencies__c();
	    	indi2Com.AsStatus__c = 'Active';
	    	indi2Com.AsDomain__c = 'Domain 3';
	    	indi2Com.Name = 'domain 4';
	    	allCom.add(indi2Com);
	    	
	    	AsCPDPlannerCompetencies__c indi3Com = new AsCPDPlannerCompetencies__c();
	    	indi3Com.AsStatus__c = 'Active';
	    	indi3Com.AsDomain__c = 'Domain 5';
	    	indi3Com.Name = 'domain 5';
	    	allCom.add(indi3Com);
	    	
	    	AsCPDPlannerCompetencies__c indi4Com = new AsCPDPlannerCompetencies__c();
	    	indi4Com.AsStatus__c = 'Active';
	    	indi4Com.AsDomain__c = 'Domain 1';
	    	indi4Com.Name = 'domain 1';
	    	allCom.add(indi4Com);
	    	
	    	insert allCom;
	    	// creation of competencies ends here
	    	
	    	// creation of topics starts here
	    	List<AsCPDPlannerTopic__c> allTop = new List<AsCPDPlannerTopic__c>();
	    	
	    	AsCPDPlannerTopic__c indi1Top = new AsCPDPlannerTopic__c();
	    	indi1Top.AsStatus__c = 'Active';
	    	indi1Top.Name = 'Topic 1';
	    	allTop.add(indi1Top);
	    	
	    	AsCPDPlannerTopic__c indi2Top = new AsCPDPlannerTopic__c();
	    	indi2Top.AsStatus__c = 'Active';
	    	indi2Top.Name = 'Topic 2';
	    	allTop.add(indi2Top);
	    	
	    	AsCPDPlannerTopic__c indi3Top = new AsCPDPlannerTopic__c();
	    	indi3Top.AsStatus__c = 'Active';
	    	indi3Top.Name = 'Topic 3';
	    	allTop.add(indi3Top);
	    	
	    	insert allTop;
	    	// creation of topics ends here
	    	
	    	// creation of competency plan links starts here
	    	List<AsCPDPlannerCompetencieslink__c> allPlanComLink = new List<AsCPDPlannerCompetencieslink__c>();
	    	
	    	AsCPDPlannerCompetencieslink__c planCom1Link = new AsCPDPlannerCompetencieslink__c();
	    	planCom1Link.AsCPDPlannerCompetencies__c = allCom[1].Id;
				planCom1Link.AsCPDPlannerReview__c = planRev.Id;
				allPlanComLink.add(planCom1Link);
				
				insert allPlanComLink;
				// creation of competency plan links ends here
				
				// creation of topic plan links starts here
	    	List<AsCPDPlannerTopicLink__c> allPlanTopLink = new List<AsCPDPlannerTopicLink__c>();
	    	
	    	AsCPDPlannerTopicLink__c planTop1Link = new AsCPDPlannerTopicLink__c();
	    	planTop1Link.AsCPDPlannerTopic__c = allTop[1].Id;
				planTop1Link.AsCPDPlannerReview__c = planRev.Id;
				allPlanTopLink.add(planTop1Link);
				
				insert allPlanTopLink;
				// creation of topic plan links ends here
				
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
				
				insert allTrainPlan;
				// creation of training plan link ends here
				
				// creation of competencies training plan link starts here
				List<AsCPDPlannerCompetenciesTrainingPlanLink__c> allComTrainPlanLink = new List<AsCPDPlannerCompetenciesTrainingPlanLink__c>();
				
				AsCPDPlannerCompetenciesTrainingPlanLink__c comTrain1PlanLink = new AsCPDPlannerCompetenciesTrainingPlanLink__c();
				comTrain1PlanLink.AsCPDPlannerCompetencies__c =  allCom[0].Id;
				comTrain1PlanLink.AsTrainingPlan__c	= 	allTrainPlan[0].Id;
				allComTrainPlanLink.add(comTrain1PlanLink);
				
				insert allcomTrainPlanLink;
				// creation of competencies training plan link ends here
				
				// creation of topic training plan link starts here
				List<AsCPDPlannerReviewTrainingPlanLink__c> allTopTrainPlanLink = new List<AsCPDPlannerReviewTrainingPlanLink__c>();
				AsCPDPlannerReviewTrainingPlanLink__c topTrain1PlanLink = new AsCPDPlannerReviewTrainingPlanLink__c();
				topTrain1PlanLink.AsCPDPlannerTopic__c =  allTop[0].Id;
				topTrain1PlanLink.AsTrainingPlan__c	= 	allTrainPlan[0].Id;
				allTopTrainPlanLink.add(topTrain1PlanLink);
				
				insert allTopTrainPlanLink;
				// creation of topic training plan link starts here
							
	    	AsCPDPlanner.processCPD('{"Competency":{"'+allCom[0].Id+'":true,"'+allCom[1].Id+'":true,"'+allCom[2].Id+'":true},"Topic":{"'+allTop[0].Id+'":true,"'+allTop[1].Id+'":true,"'+allTop[2].Id+'":true},"CpdId":""}');
	    	
	    	// assertion
		    System.AssertEquals(database.countquery('SELECT '
		           																		+ 'COUNT()'
		              															+' FROM'
		              																+' AsCPDPlannerReviewTrainingPlanLink__c '
		              															),1
		              					);
	    }
	}
	
	/*Author : John Hope
	*Description : This is a test class for allCPDTopics method
	*Date Created : May 4, 2018
	*Last Modified By : 
	*Date Last Modified : May 4, 2018
	*Related Meta Data : 
	*Param : NA
	*Return : NA
 	*/
 	
	static testMethod void processTrainingBook() {
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
	    	planner.Name = 'hope planner review';
	    	planner.AS_Current_CPD_Plan__c = true;
	    	planner.AS_Plan_Year__c = '2019';
	    	insert planner;
	    	// creation of CPD Planner ends here
	    	
	    	// creation of competencies starts here
	    	List<AsCPDPlannerCompetencies__c> allCom = new List<AsCPDPlannerCompetencies__c>();
	    	
	    	AsCPDPlannerCompetencies__c indi1Com = new AsCPDPlannerCompetencies__c();
	    	indi1Com.AsStatus__c = 'Active';
	    	indi1Com.AsDomain__c = 'Domain 3';
	    	indi1Com.Name = 'domain 3';
	    	allCom.add(indi1Com);
	    	
	    	AsCPDPlannerCompetencies__c indi2Com = new AsCPDPlannerCompetencies__c();
	    	indi2Com.AsStatus__c = 'Active';
	    	indi2Com.AsDomain__c = 'Domain 3';
	    	indi2Com.Name = 'domain 4';
	    	allCom.add(indi2Com);
	    	
	    	AsCPDPlannerCompetencies__c indi3Com = new AsCPDPlannerCompetencies__c();
	    	indi3Com.AsStatus__c = 'Active';
	    	indi3Com.AsDomain__c = 'Domain 5';
	    	indi3Com.Name = 'domain 5';
	    	allCom.add(indi3Com);
	    	
	    	AsCPDPlannerCompetencies__c indi4Com = new AsCPDPlannerCompetencies__c();
	    	indi4Com.AsStatus__c = 'Active';
	    	indi4Com.AsDomain__c = 'Domain 1';
	    	indi4Com.Name = 'domain 1';
	    	allCom.add(indi4Com);
	    	
	    	insert allCom;
	    	// creation of competencies ends here
	    	
	    	// creation of topics starts here
	    	List<AsCPDPlannerTopic__c> allTop = new List<AsCPDPlannerTopic__c>();
	    	
	    	AsCPDPlannerTopic__c indi1Top = new AsCPDPlannerTopic__c();
	    	indi1Top.AsStatus__c = 'Active';
	    	indi1Top.Name = 'Topic 1';
	    	allTop.add(indi1Top);
	    	
	    	AsCPDPlannerTopic__c indi2Top = new AsCPDPlannerTopic__c();
	    	indi2Top.AsStatus__c = 'Active';
	    	indi2Top.Name = 'Topic 2';
	    	allTop.add(indi2Top);
	    	
	    	AsCPDPlannerTopic__c indi3Top = new AsCPDPlannerTopic__c();
	    	indi3Top.AsStatus__c = 'Active';
	    	indi3Top.Name = 'Topic 3';
	    	allTop.add(indi3Top);
	    	
	    	insert allTop;
	    	// creation of topics ends here
	    	
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
				// creation of training plan link ends here
				
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
				// creation of AsTrainingPlanBookmark__c ends here
						
	    	AsCPDPlanner.processTrainingBook('{"Training":{"'+alltrainPlanBook[0].Id+'":true,"'+alltrainPlanBook[2].Id+'":true},"CpdId":""}');
	    	
	    	// call move bookmark functionality
	    	AsCPDPlanner.transferBookmark(String.valueOf(planner.Id));
	    	
	    	// assertion
		    System.AssertEquals(database.countquery('SELECT '
		           																		+ 'COUNT()'
		              															+' FROM'
		              																+' AsTrainingPlanBookmark__c '
		              															),3
		              					);
 			}
	}
	
	static testMethod void constructorTest() {
		AsCPDPlanner cpd = new AsCPDPlanner();
	}
	
}