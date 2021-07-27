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
private class AS_batchMembershipRenewalT2T3T4Test {

 	static testMethod void batchMembershipRenewalT2T3T4AutoRenew() {  
    	
    	Membership_End_Date_Renewal__c setting = new Membership_End_Date_Renewal__c();
		setting.Name = 'Test Setting';
		setting.T2__c = 15;
		setting.T3__c = 10;
		setting.T4__c = 5;
		insert setting;
		
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
        
        /*
       	Opportunity opp = new Opportunity();
       	opp.Name = 'john hope test opp';
       	opp.CloseDate = date.newInstance(2018, 3, 15);
       	opp.StageName = 'Qualification';
       	opp.AccountId = acc.Id;
       	opp.Amount = 100;
       	insert opp;
       	
       	OpportunityLineItem oppLineItem = new OpportunityLineItem();
	    oppLineItem.quantity = 2;
	    oppLineItem.UnitPrice = 10;
	    oppLineItem.PricebookEntryId = PricebookEntryList[1].Id;
	    oppLineItem.Product2Id = prod.Id;
	    oppLineItem.OpportunityId = opp.Id;
	    insert oppLineItem;
	    */
       	
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
        newSubscription.AS_End_Date__c 			=   Date.today().addDays(Integer.valueOf(setting.T4__c));
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
	   
       	Test.startTest(); 
		   	AsPsaSettings wew = new AsPsaSettings();
	   		wew.runThisBatch2();
       	Test.stopTest();
	            
    }
    
    static testMethod void batchMembershipRenewalT2T3T4NoAutoRenew() {  
    	
    	Membership_End_Date_Renewal__c setting = new Membership_End_Date_Renewal__c();
		setting.Name = 'Test Setting';
		setting.T2__c = 15;
		setting.T3__c = 10;
		setting.T4__c = 5;
		insert setting;
		
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
        
        /*
       	Opportunity opp = new Opportunity();
       	opp.Name = 'john hope test opp';
       	opp.CloseDate = date.newInstance(2018, 3, 15);
       	opp.StageName = 'Qualification';
       	opp.AccountId = acc.Id;
       	opp.Amount = 100;
       	insert opp;
       	
       	OpportunityLineItem oppLineItem = new OpportunityLineItem();
	    oppLineItem.quantity = 2;
	    oppLineItem.UnitPrice = 10;
	    oppLineItem.PricebookEntryId = PricebookEntryList[1].Id;
	    oppLineItem.Product2Id = prod.Id;
	    oppLineItem.OpportunityId = opp.Id;
	    insert oppLineItem;
	    */
       	
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
        newSubscription.AS_Auto_Renew__c        =   false;
        newSubscription.AS_Frequency__c         =   1;
        newSubscription.AS_Start_Date__c        =   Date.today();
        newSubscription.AS_End_Date__c 			=   Date.today().addDays(Integer.valueOf(setting.T4__c));
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
	    
       	Test.startTest(); 
		   	AsPsaSettings wew = new AsPsaSettings();
	   		wew.runThisBatch2();
       	Test.stopTest();
	            
    }
}