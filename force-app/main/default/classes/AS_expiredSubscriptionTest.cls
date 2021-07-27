@isTest
private class AS_expiredSubscriptionTest {
	
     static testMethod void AS_ExpiredSubscriptionTrigger() { // AS_ExpiredSubscription trigger
			System.runAs(new user(ID = UserInfo.getUserID())) {
				List<AS_Subscription__c> sub = [Select Id from AS_Subscription__c where AS_Membership_Status__c = 'Current' LIMIT 1];
				if(sub.size() > 0) {
					sub[0].AS_Membership_Status__c = 'Expired';
					update sub;
				}
			}
			/*
        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc;
        User u1;
        System.runAs(new user(ID = UserInfo.getUserID())) {
            Contact con = new Contact();
            con.FirstName = 'john';
            con.LastName = 'Hope';
            con.Email = 'test@test.com';
            insert con;

            Profile p = [SELECT Id FROM Profile WHERE Name='Member Login User'];
            List<userrole> listUserRole = [Select id from userrole where name = 'SVP Customer Experience'];
            List<UserLicense> listUserLicense = [Select Id from UserLicense where Masterlabel = 'Customer Community Login'];
            u1 = new User(Alias = 'standt1',Country='United Kingdom',Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='m@mtest.com',ContactId=con.Id);

            acc = new Account();
            acc.RecordTypeId = personAccountId;
            acc.FirstName = 'mFirst';
            acc.LastName = 'mLast';
            acc.PersonEmail = 'm@m.com';
            insert acc;
            
            AS_Subscription__c psaSub = new AS_Subscription__c();
            psaSub.AS_Membership_Status__c = 'Expired';
            psaSub.AS_User__c = u1.Id;
            psaSub.AS_Type__c = 'Member';
            psaSub.Account__c = acc.Id;
            insert psaSub;
        }
        */

    }
    
    @TestSetup  
		static void createData() {
	    Id ccRecordTypeId = Schema.SObjectType.ASPHPP__ASPayment_Source__c.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
	    Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
	    Id businessAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
	    
	   
	   	
	    // Create a unique UserName
			String uniqueUserName = 'adminuser' + DateTime.now().getTime() + '@testorg.com';
			// This code runs as the system user
			Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
			User use = new User(Alias = 'standt', Email='adminuser@testorg.com',
			EmailEncodingKey='UTF-8', LastName='administrator', LanguageLocaleKey='en_US',
			LocaleSidKey='en_US', ProfileId = p.Id,
			TimeZoneSidKey='America/Los_Angeles',
			 UserName=uniqueUserName);
			insert use;
			System.runAs(new user(ID = UserInfo.getUserID())) {
			
			Membership_End_Date_Renewal__c setting = new Membership_End_Date_Renewal__c();
			setting.Name = 'Test Setting';
			setting.T1__c = 10;
			setting.T2__c = 20;
			setting.T3__c = 30;
			setting.T4__c = 40;
			setting.T5__c = 50;
			setting.T6__c = 10;
			setting.T7__c = 10;
			setting.T8__c = 10;
			
			insert setting;
			
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
	    newSubscription.AS_End_Date__c 			=   Date.today();
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
			insert newSubscription;	
			
			}
    }
	
}