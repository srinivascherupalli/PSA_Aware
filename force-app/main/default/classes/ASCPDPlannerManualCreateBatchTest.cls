/*Author : John Hope
*Description : This is a test class for AsCPDPlannerSepUpdateBatch and AsCPDPlannerSepUpdateBatchScheduler class.
*Date Created : June 20, 2018
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data : AsCPDPlannerSepUpdateBatch.cls,AsCPDPlannerSepUpdateBatchScheduler.cls
 */
@isTest(SeeAllData=false)
private class ASCPDPlannerManualCreateBatchTest {
	
    
	static testMethod void ASCPDPlannerManualCreateBatch_test() {
		Test.StartTest();
		User sub = [Select Id, Name from User where email = 'memberuser@testorg.com' LIMIT 1];
		
		// creation of CPD Planner starts here
		List<AsCPDPlanner__c> allCPDList = new List<AsCPDPlanner__c>();
		AsCPDPlanner__c planner = new AsCPDPlanner__c();
		planner.AsUser__c = sub.Id;
		planner.Name = 'hope planner review';
		planner.AS_Current_CPD_Plan__c = true;
		planner.AS_Plan_Year__c = String.valueOf(Date.Today().addYears(-2).year());
		allCPDList.add(planner);
		
		AsCPDPlanner__c planner2 = new AsCPDPlanner__c();
		planner2.AsUser__c = sub.Id;
		planner2.Name = 'hope planner review';
		planner2.AS_Current_CPD_Plan__c = false;
		planner2.AsGenerateCPDsummary__c   = true;
		planner2.AS_Plan_Year__c = String.valueOf(Date.Today().addYears(-1).year());
		allCPDList.add(planner2);
		
		insert allCPDList;




		// creation of CPD Planner ends here
		
		Id ccRecordTypeId = Schema.SObjectType.ASPHPP__ASPayment_Source__c.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        
	    Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
	    
	    Account acc = new Account();
	   	acc.FirstName = 'John Hope';
	   	Acc.LastName = 'Ondona';
	   	acc.recordTypeId = personAccRecId;
	   	acc.PersonEmail = 'test@test.com';
	   	insert acc; 
        
     	ASPHPP__ASPayment_Source__c paySource = new ASPHPP__ASPayment_Source__c();
     	paySource.recordTypeId = ccRecordTypeId;
     	paySource.ASPHPP__Account__c = acc.Id;   // account
     	paySource.ASPHPP__Card_Name__c = 'test';    // card name
     	paySource.ASPHPP__Credit_Card_Type__c =  'VISA';    // card type
     	paySource.ASPHPP__Card_CCV__c = '123';  // ccv
     	paySource.ASPHPP__Card_Number__c =  '111111111111111';   // card number
     	paySource.ASPHPP__Card_Expiry_Month__c =  '01';   // card number
     	paySource.ASPHPP__Card_Expiry_Year__c = '2020';  // expiry month 
     	insert paySource;
       	
	   	Product2 prod = new Product2();
	    prod.Name  = 'Product Name';
	    prod.isActive = true;
	   	insert prod;
	   	
	   	Pricebook2 prBook = new Pricebook2();
	    prBook.Name = 'standard pricebook';
	    prBook.isActive = true;
	//    prBook.isStandard = true;
	    insert prBook;
	   	
	   	List<PricebookEntry> PricebookEntryList = new List<PricebookEntry>();
       	
   		PricebookEntry priEntry = new PricebookEntry();
    	priEntry.Product2Id = prod.Id;
	    priEntry.Pricebook2Id = Test.getStandardPricebookId();
	    priEntry.UnitPrice = 100;
	    priEntry.isActive=true;
	    PricebookEntryList.add(priEntry);
	    
	    PricebookEntry priEntry2 = new PricebookEntry();
    	priEntry2.Product2Id = prod.Id;
	    priEntry2.Pricebook2Id = prBook.Id;
	    priEntry2.UnitPrice = 100;
	    priEntry2.isActive=true;
	    PricebookEntryList.add(priEntry2);
	    
	    insert PricebookEntryList;
	    
	    Id stdPriceBookRecId = Test.getStandardPricebookId();
		
	    // TO DO: implement unit test
	    AS_Subscription__c newSubscription      =   new AS_Subscription__c();
	    newSubscription.AS_Auto_Renew__c        =   true;
	    newSubscription.AS_Frequency__c         =   1;
	    newSubscription.AS_Start_Date__c        =   Date.today();
	    newSubscription.AS_End_Date__c 			=   Date.today().addDays(365);
     	newSubscription.AS_Type__c              =   'Member';
			newSubscription.AS_Payment_Source__c    =   paySource.Id;
	    newSubscription.AS_Membership_Span__c   =   1;
	    newSubscription.AS_Price_Book__c        =   prBook.Id;
	    newSubscription.Account__c              =   acc.Id;
	    newSubscription.AS_Membership_Status__c =   'Pending';//Jan 9
	    newSubscription.AS_Product__c           =  prod.Id;
	    newSubscription.AS_Membership_Renewal_Date__c = Date.today();
	    newSubscription.AS_Type__c = 'Member';
	    newSubscription.AS_Membership_Status__c = 'Current';
	//    newSubscription.AS_Opportunity__c = opp.Id;
	    insert newSubscription;
		
		ASCPDPlannerManualCreateBatch manualBatch = new ASCPDPlannerManualCreateBatch(String.valueOf(Date.today().addDays(400).year()),true);
		database.executeBatch(manualBatch);
		
		/*
	 	// assertion
		System.AssertEquals(database.countquery('SELECT '
	           																		+ 'COUNT()'
	              															+' FROM'
	              																+' AsCPDPlanner__c '
	              															),2
	              					); 
	       */      					
	    
	    
   	Test.StopTest();

   	AsCPDPlanner__c Updateplanner = new AsCPDPlanner__c();	
   	Updateplanner.Id = allCPDList[0].Id;
   	Updateplanner.AsGenerateCPDsummary__c   = true;
   	update Updateplanner;
   	
	}
	
	@TestSetup  
	static void createData() {
	 	// TO DO: implement unit test
		Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
    Account acc = new Account();
    acc.FirstName = 'AlphaSys';
    acc.LastName = 'UserAccount12345';
    acc.recordTypeId = personAccRecId;
    acc.PersonEmail = 'memberuser@testorg.com';
    insert acc;
    
    // Create a unique UserName
    String uniqueUserName = 'memberuser2' + DateTime.now().getTime() + '@testorg.com';
    // This code runs as the system user
    Profile p = [SELECT Id FROM Profile WHERE Name='Member Login User'];
    Account acc1 = [SELECT Id,PersonContactId FROM Account WHERE Id =:acc.Id];
    
    User use = new User(Alias = 'standt', Email='memberuser@testorg.com',
    EmailEncodingKey='UTF-8', LastName='johnmongrel', LanguageLocaleKey='en_US',
    LocaleSidKey='en_US', ProfileId = p.Id,
    ContactId = acc1.PersonContactId,
    TimeZoneSidKey='America/Los_Angeles',
    isActive = true,
    UserName=uniqueUserName);
    insert use;
	}
}