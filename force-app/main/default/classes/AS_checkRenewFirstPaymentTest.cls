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
private class AS_checkRenewFirstPaymentTest {
	
    static testMethod void AS_checkRenewFirstPaymentTriggerTest() {
	    System.runAs(new user(ID = UserInfo.getUserID())) {
	    	Id idOppMembership = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();
        Id idSubscription = Schema.SObjectType.AS_Subscription__c.getRecordTypeInfosByName().get('Membership').getRecordTypeId();

        Id stdPriceBookRecId = Test.getStandardPricebookId();

        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        Account acc = new Account();
        acc.RecordTypeId = personAccountId;
        acc.FirstName = 'mFirst';
        acc.LastName = 'mLast';
        acc.PersonEmail = 'm@m.com';
        acc.AS_Graduation_Year__pc = '2010';
        insert acc;

        Contact con = new Contact();
        con.FirstName = 'john';
        con.LastName = 'Hope';
        con.Email = 'test@test.com';
        insert con;

        Pricebook2 prBook = new Pricebook2();
        prBook.Name = 'standard pricebook';
        prBook.AS_Frequency__c = 12;
        insert prBook;

        Membership_Type__c mmbrshipType = new Membership_Type__c();
        mmbrshipType.Name = 'Student Members';
        insert mmbrshipType;

        Product2 prod = new Product2();
        prod.Name  = 'Product1';
        prod.isActive = true;
        prod.AS_Membership_Type__c = mmbrshipType.Id; 
       	insert prod;

				Product2 prodx = new Product2();
        prodx.Name  = 'Student Members';
        prodx.isActive = true;
        prodx.AS_Parent_Product__c = prod.Id; 
       	insert prodx;

       	system.debug('ASDF : '+prodx);

        Opportunity opp = new Opportunity();
        opp.Name = 'sample opportunity 2';
        opp.StageName = 'Closed Won';
        opp.CloseDate  = date.newinstance(2020, 12, 30);
        opp.RecordTypeId = idOppMembership;
        opp.Pricebook2Id = prBook.Id;
        opp.AS_Create_Subscription__c = true;
        opp.AccountId = acc.Id;
        opp.AS_Product__c = prod.Id;
        insert opp;

        system.debug('QWER1 : '+opp);

       	PricebookEntry pbe2 = new PricebookEntry();
       	pbe2.Product2Id = prod.Id;
       	pbe2.Pricebook2Id = stdPriceBookRecId;
       	pbe2.UnitPrice = 100;
       	pbe2.isActive=true;
       	insert pbe2;

       	PricebookEntry pbe = new PricebookEntry();
       	pbe.Product2Id = prod.Id;
       	pbe.Pricebook2Id = prBook.Id;
       	pbe.UnitPrice = 100;
       	pbe.isActive=true;
       	insert pbe;

        OpportunityLineItem oppline = new OpportunityLineItem();
        oppline.OpportunityId = opp.Id;
        oppline.Product2Id = prod.Id; 
        oppline.Quantity = 5;
        oppline.UnitPrice = 100.00;
        oppline.PricebookEntryId = pbe.Id;
        insert oppline;

        system.debug('QWER2 : '+oppline);

        Id bankId = Schema.SObjectType.ASPHPP__ASPayment_Source__c.getRecordTypeInfosByName().get('Bank Account').getRecordTypeId();
        Id ccRecordTypeId = Schema.SObjectType.ASPHPP__ASPayment_Source__c.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        
        ASPHPP__ASPayment_Source__c source =  new ASPHPP__ASPayment_Source__c();
        source.Name = 'John Bank';
        source.ASPHPP__PPContact__c = con.Id;
        source.ASPHPP__Account_Name__c = 'Bank';
        source.ASPHPP__Account_Number__c = '001234';
        source.ASPHPP__Account_BSB__c = '000234';
        source.RecordTypeId = bankId;
        insert source;

        ASPHPP__ASGateway__c gateway = new ASPHPP__ASGateway__c();
        gateway.Name = 'Sample Gateway';
        gateway.ASPHPP__Digital_Token_Key__c = 'ABCDEGHIJKLMNOPQRSTUVXYZ123456E4B1';
        insert gateway;

        ASPHPP__PPSettings__c ppSettings = new ASPHPP__PPSettings__c ();
        ppSettings.ASPHPP__Gateway_ID__c = gateway.Id;

        ASPHPP__Subscription__c psub = new ASPHPP__Subscription__c();
        psub.Name = 'mTest subscription';
        psub.ASPHPP__Amount__c = 100;
        psub.ASPHPP__Frequency__c = 'Quarterly';
        psub.ASPHPP__Payment_Source__c = source.Id;
        psub.ASPHPP__Gateway__c = gateway.Id;
        psub.AS_opportunity__c = opp.Id;
        psub.ASPHPP__Contact__c = con.Id;
        psub.AS_forRenewalFirstPayment__c = false;
        insert psub;

        Id idCash = Schema.SObjectType.ASPHPP__Payment__c.getRecordTypeInfosByName().get('Cash').getRecordTypeId();

        ASPHPP__Payment__c pPayment = new ASPHPP__Payment__c();
        pPayment.RecordTypeId = idCash;
        pPayment.Name = 'mPayment';
        pPayment.ASPHPP__PSubscription__c = psub.Id;
        pPayment.ASPHPP__Opportunity__c = opp.Id; 
        pPayment.ASPHPP__Payment_Source__c = source.Id;
        pPayment.ASPHPP__Payment_Status__c = 'Success';
        insert pPayment;
        
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
		    newSubscription.AS_Opportunity__c = opp.Id;
		    insert newSubscription;
		    
		    // test here start
		    Test.startTest();
		    
		    ASPHPP__Subscription__c psubRenew = new ASPHPP__Subscription__c();
        psubRenew.Name = 'hope pp subscription';
        psubRenew.ASPHPP__Amount__c = 100;
        psubRenew.ASPHPP__Frequency__c = 'Quarterly';
        psubRenew.ASPHPP__Payment_Source__c = source.Id;
        psubRenew.ASPHPP__Gateway__c = gateway.Id;
        
        psubRenew.ASPHPP__Contact__c = con.Id;
        psubRenew.AS_forRenewalFirstPayment__c = false;
    		psubRenew.AS_opportunity__c = opp.Id;
    		psubRenew.AS_Subscription__c = newSubscription.Id;
        insert psubRenew;
        
        Id idCashRenew = Schema.SObjectType.ASPHPP__Payment__c.getRecordTypeInfosByName().get('Cash').getRecordTypeId();

        ASPHPP__Payment__c pPaymentRenew = new ASPHPP__Payment__c();
        pPaymentRenew.RecordTypeId = idCashRenew;
        pPaymentRenew.Name = 'mPayment';
        pPaymentRenew.ASPHPP__PSubscription__c = psubRenew.Id;
        pPaymentRenew.ASPHPP__Opportunity__c = opp.Id;
        pPaymentRenew.ASPHPP__Payment_Source__c = source.Id;
        pPaymentRenew.ASPHPP__Payment_Status__c = 'Success';
        insert pPaymentRenew;
        
        Test.stopTest();
        // test here stop
	    }
    }
    
    static testMethod void AS_checkRenewFirstPaymentTriggerTest2() {
	    Opportunity opp2Update = [Select Id from Opportunity where Name = 'sample opportunity 2'];
	    opp2Update.StageName = 'Prospecting';
	    update opp2Update;
	    
	    Test.startTest();
	    
	    AS_commonFunction.runOppCloseWon = true;
	    
	    Opportunity opp3Update = new Opportunity();
	    opp3Update.Id = opp2Update.Id;
	    opp3Update.StageName = 'Closed Won';
	    update opp3Update;
	    
	    Test.stopTest();
        
    }
    
    @TestSetup  
		static void createData() {
			System.runAs(new user(ID = UserInfo.getUserID())) {
	    	Id idOppMembership = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();
        Id idSubscription = Schema.SObjectType.AS_Subscription__c.getRecordTypeInfosByName().get('Membership').getRecordTypeId();

        Id stdPriceBookRecId = Test.getStandardPricebookId();

        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        Account acc = new Account();
        acc.RecordTypeId = personAccountId;
        acc.FirstName = 'mFirst';
        acc.LastName = 'mLast';
        acc.PersonEmail = 'm@m.com';
        acc.AS_Graduation_Year__pc = '2010';
        insert acc;

        Contact con = new Contact();
        con.FirstName = 'john';
        con.LastName = 'Hope';
        con.Email = 'test@test.com';
        insert con;

        Pricebook2 prBook = new Pricebook2();
        prBook.Name = 'standard pricebook';
        prBook.AS_Frequency__c = 12;
        insert prBook;

        Membership_Type__c mmbrshipType = new Membership_Type__c();
        mmbrshipType.Name = 'Student Members';
        insert mmbrshipType;

        Product2 prod = new Product2();
        prod.Name  = 'Product1';
        prod.isActive = true;
        prod.AS_Membership_Type__c = mmbrshipType.Id; 
       	insert prod;

				Product2 prodx = new Product2();
        prodx.Name  = 'Student Members';
        prodx.isActive = true;
        prodx.AS_Parent_Product__c = prod.Id; 
       	insert prodx;

       	system.debug('ASDF : '+prodx);

        Opportunity opp = new Opportunity();
        opp.Name = 'sample opportunity 2';
        opp.StageName = 'Prospecting';
        opp.CloseDate  = date.newinstance(2020, 12, 30);
        opp.RecordTypeId = idOppMembership;
        opp.Pricebook2Id = prBook.Id;
        opp.AS_Create_Subscription__c = true;
        opp.AccountId = acc.Id;
        opp.AS_Product__c = prod.Id;
        insert opp;

        system.debug('QWER1 : '+opp);

       	PricebookEntry pbe2 = new PricebookEntry();
       	pbe2.Product2Id = prod.Id;
       	pbe2.Pricebook2Id = stdPriceBookRecId;
       	pbe2.UnitPrice = 100;
       	pbe2.isActive=true;
       	insert pbe2;

       	PricebookEntry pbe = new PricebookEntry();
       	pbe.Product2Id = prod.Id;
       	pbe.Pricebook2Id = prBook.Id;
       	pbe.UnitPrice = 100;
       	pbe.isActive=true;
       	insert pbe;

        OpportunityLineItem oppline = new OpportunityLineItem();
        oppline.OpportunityId = opp.Id;
        oppline.Product2Id = prod.Id; 
        oppline.Quantity = 5;
        oppline.UnitPrice = 100.00;
        oppline.PricebookEntryId = pbe.Id;
        insert oppline;

        system.debug('QWER2 : '+oppline);
        
        Test.startTest();

	        Id bankId = Schema.SObjectType.ASPHPP__ASPayment_Source__c.getRecordTypeInfosByName().get('Bank Account').getRecordTypeId();
	        Id ccRecordTypeId = Schema.SObjectType.ASPHPP__ASPayment_Source__c.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
	        
	        ASPHPP__ASPayment_Source__c source =  new ASPHPP__ASPayment_Source__c();
	        source.Name = 'John Bank';
	        source.ASPHPP__PPContact__c = con.Id;
	        source.ASPHPP__Account_Name__c = 'Bank';
	        source.ASPHPP__Account_Number__c = '001234';
	        source.ASPHPP__Account_BSB__c = '000234';
	        source.RecordTypeId = bankId;
	        insert source;
	
	        ASPHPP__ASGateway__c gateway = new ASPHPP__ASGateway__c();
	        gateway.Name = 'Sample Gateway';
	        gateway.ASPHPP__Digital_Token_Key__c = 'ABCDEGHIJKLMNOPQRSTUVXYZ123456E4B1';
	        insert gateway;
	
	        ASPHPP__PPSettings__c ppSettings = new ASPHPP__PPSettings__c ();
	        ppSettings.ASPHPP__Gateway_ID__c = gateway.Id;
				
				
				
	        ASPHPP__Subscription__c psub = new ASPHPP__Subscription__c();
	        psub.Name = 'mTest subscription';
	        psub.ASPHPP__Amount__c = 100;
	        psub.ASPHPP__Frequency__c = 'Quarterly';
	        psub.ASPHPP__Payment_Source__c = source.Id;
	        psub.ASPHPP__Gateway__c = gateway.Id;
	        psub.AS_opportunity__c = opp.Id;
	        psub.ASPHPP__Contact__c = con.Id;
	        psub.AS_forRenewalFirstPayment__c = false;
	        insert psub;
	
	        Id idCash = Schema.SObjectType.ASPHPP__Payment__c.getRecordTypeInfosByName().get('Cash').getRecordTypeId();
	
	        ASPHPP__Payment__c pPayment = new ASPHPP__Payment__c();
	        pPayment.RecordTypeId = idCash;
	        pPayment.Name = 'mPayment';
	        pPayment.ASPHPP__PSubscription__c = psub.Id;
	        pPayment.ASPHPP__Opportunity__c = opp.Id; 
	        pPayment.ASPHPP__Payment_Source__c = source.Id;
	        pPayment.ASPHPP__Payment_Status__c = 'Success';
	        insert pPayment;
        
        Test.stopTest();
        
			}
		}
}