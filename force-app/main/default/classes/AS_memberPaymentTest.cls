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
private class AS_memberPaymentTest {
		
		static testMethod void constructTest() {
      AS_memberPayment mem = new AS_memberPayment();
    }
    
    static testMethod void paymentAllDataTest() {
       	Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
       	
       	Account acc = new Account();
       	acc.FirstName = 'John Hope';
       	Acc.LastName = 'Ondona';
       	acc.recordTypeId = personAccRecId;
       	acc.PersonEmail = 'test@test.com';
       	insert acc;

		// Updated Juniel
		Pricebook2 book = new Pricebook2();
		book.Name = 'Test PriceBook';
		book.Description = 'Test Description';
		book.IsActive = true;
		insert book;
       
       	Opportunity opp = new Opportunity();
       	opp.Name = 'john hope test opp';
       	opp.CloseDate = date.newInstance(2018, 3, 15);
       	opp.StageName = 'Qualification';
       	opp.AccountId = acc.Id;
		opp.Pricebook2Id = book.Id;
       	insert opp;
       	
       	List<String> oppdata = new List<String>();
       	oppdata.add(opp.Id);
       	AS_memberPayment.paymentAllData(oppdata);
    }
    
    static testMethod void adVoucherTest() {

		Id pricebookId = Test.getStandardPricebookId();

		Product2 prod = new Product2(
            Name = 'Laptop X200', 
            Family = 'Hardware',
            isActive=true
        );
        insert prod;

		PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, 
            Product2Id = prod.Id,
            UnitPrice = 10000, 
            IsActive = true
        );
        insert standardPrice;  

		Training_Plan__c trainPlan = new Training_Plan__c(
			AS_Product__c = prod.Id,
			Name = 'New training Plan',
			Description__c = 'New training Plan Description',
			Status__c = 'Active'
		);
		insert trainPlan;

    	Opportunity opp = [Select Id,Pricebook2Id,AccountId from Opportunity where Name = 'john hope test opp'];
		Id RecordTypeIdCoupon = Schema.SObjectType.AS_Coupon__c.getRecordTypeInfosByName().get('Amount').getRecordTypeId();
		String AsVoucher = 'Test';

		AS_Coupon__c AsCoupon = new AS_Coupon__c(
             RecordTypeId= RecordTypeIdCoupon,
             AS_Product__c = prod.Id,
             AS_Discount_Amount__c = 10,
             AS_Code__c = AsVoucher,
             AS_Status__c = 'Active',
			 AS_Generic_Coupon__c = true

        );
        insert AsCoupon;

		AS_memberPayment.convertToCloseWon(new List<String>{String.valueOf(opp.Id)});
		AS_memberPayment.updateAllPpaymentsByOppId( opp.Id );

		Test.StartTest();

			AS_memberPayment.addVoucher(new List<String>{String.valueOf(opp.Id), String.valueOf(opp.Pricebook2Id), AsVoucher, String.valueOf(trainPlan.Id)});

		Test.StopTest();
    	
    }
    
     static testMethod void successOnceOffTest() {
    	Opportunity opp = [Select Id,Pricebook2Id,AccountId from Opportunity where Name = 'john hope test opp'];
    	
    	ASPHPP__Subscription__c PPSubs = [Select Id from ASPHPP__Subscription__c LIMIT 1];
    	
    	ASPHPP__ASPayment_Source__c PPSource = [Select Id from ASPHPP__ASPayment_Source__c LIMIT 1];
    	
    	ASPHPP__ASGateway__c gateway = new ASPHPP__ASGateway__c();
	    gateway.Name = 'Sample Gateway';
	    gateway.ASPHPP__Digital_Token_Key__c = 'ABCDEGHIJKLMNOPQRSTUVXYZ123456E4B1';
	    insert gateway;
	    
    	ASPHPP__Payment__c PPayment = new ASPHPP__Payment__c();
    	PPayment.ASPHPP__Account__c = opp.AccountId;
    	PPayment.ASPHPP__Amount__c = 10;
    	PPayment.ASPHPP__Gateway__c = gateway.Id;
    	PPayment.ASPHPP__Opportunity__c = opp.Id;
    	PPayment.ASPHPP__Payment_Source__c = PPSource.Id;
    	PPayment.ASPHPP__Payment_Date__c = date.today();
    	insert PPayment;
    	
    	Test.StartTest();

    		List<ASPHPP__Payment__c> theOppPaymentList = [Select Id,Name,ASPHPP__PSubscription__r.ASPHPP__Payment_Source__c,ASPHPP__Payment_Status__c,ASPHPP__PSubscription__c,ASPHPP__PSubscription__r.AS_opportunity__c FROM ASPHPP__Payment__c ORDER BY CreatedDate];
    		System.debug('theOppPaymentList : ' + theOppPaymentList);
    		
    		List<ASPHPP__Payment__c> theOpp = [Select Id,Name,ASPHPP__PSubscription__r.ASPHPP__Payment_Source__c,ASPHPP__Payment_Status__c,ASPHPP__PSubscription__c,ASPHPP__PSubscription__r.AS_opportunity__c FROM ASPHPP__Payment__c where ASPHPP__PSubscription__r.AS_opportunity__c=:opp.Id ORDER BY CreatedDate DESC LIMIT 1];
    		if(theOpp.size() > 0) {
	    		List<String> allParamOnceOff = new List<String>{String.valueOf(theOpp[0].ASPHPP__PSubscription__r.AS_opportunity__c), String.valueOf(theOpp[0].ASPHPP__PSubscription__r.ASPHPP__Payment_Source__c), String.valueOf(theOpp[0].ASPHPP__PSubscription__c),String.valueOf(theOpp[0].Id)};
	    		
	    		AS_memberPayment.successOnceOff(allParamOnceOff);
	    		
	    		AS_memberPayment.convertSubsEndDate(new List<String>{String.valueOf(theOpp[0].ASPHPP__PSubscription__c)});
    		}

	    	List<String> allParamOnceOff = new List<String>{String.valueOf(opp.Id), String.valueOf(PPSource.Id), String.valueOf(PPSubs.Id),String.valueOf(PPayment.Id)};
	    	
	    	AS_memberPayment.successOnceOff(allParamOnceOff);
		    		
				AS_memberPayment.convertSubsEndDate(new List<String>{String.valueOf(PPSubs.Id)});
				
    	Test.StopTest();
    	
    }
	
    static testMethod void checkPaymentStatusTest() {
    	Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
    	
    	Account acc = new Account();
       	acc.FirstName = 'John Hope';
       	Acc.LastName = 'Ondona';
       	acc.recordTypeId = personAccRecId;
       	acc.PersonEmail = 'test@test.com';
       	insert acc;
       
       	Opportunity opp = new Opportunity();
       	opp.Name = 'john hope test opp';
       	opp.CloseDate = date.newInstance(2018, 3, 15);
       	opp.StageName = 'Qualification';
       	opp.AccountId = acc.Id;
       	insert opp;
       	
    	
    	List<String> oppdata = new List<String>();
       	oppdata.add(opp.Id);
    	AS_memberPayment.checkPaymentStatus(oppdata);
    	
    
    	
    }
    
     static testMethod void convertToCloseWonTest() {
    	Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
    	
    	Account acc = new Account();
       	acc.FirstName = 'John Hope';
       	Acc.LastName = 'Ondona';
       	acc.recordTypeId = personAccRecId;
       	acc.PersonEmail = 'test@test.com';
       	insert acc;
       
       	Opportunity opp = new Opportunity();
       	opp.Name = 'john hope test opp';
       	opp.CloseDate = date.newInstance(2018, 3, 15);
       	opp.StageName = 'Qualification';
       	opp.AccountId = acc.Id;
       	insert opp;
       	
         Id ccRecordTypeId = Schema.SObjectType.ASPHPP__ASPayment_Source__c.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
            
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
    	
/*    	List<String> oppdata = new List<String>();
       	oppdata.add(opp.Id);
        oppData.add(paySource.Id);
    	AS_memberPayment.convertToCloseWon(oppdata);*/
    	
    	
    }
    
	@TestSetup  
 	static void testAndProcessDataData() {
 		Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
    		
       	Test.getStandardPricebookId();
       	
       	Account acc = new Account();
       	acc.FirstName = 'John Hope';
       	Acc.LastName = 'Ondona';
       	acc.recordTypeId = personAccRecId;
       	acc.PersonEmail = 'test@test.com';
       	insert acc;
       
       	Opportunity opp = new Opportunity();
       	opp.Name = 'john hope test opp';
       	opp.CloseDate = date.newInstance(2018, 3, 15);
       	opp.StageName = 'Qualification';
       	opp.AccountId = acc.Id;
       	insert opp;

       	
       	List<Product2> allProd = new List<Product2>();
       	
       	Product2 prod = new Product2();
        prod.Name  = 'Product Name';
        prod.isActive = true;
        allProd.add(prod);
        
        Product2 prod2 = new Product2();
        prod2.Name  = 'coupon';
        prod2.isActive = true;
        allProd.add(prod2);
        
       	insert allProd;
       	
       	Pricebook2 prBook = new Pricebook2();
        prBook.Name = 'standard pricebook';
        prBook.isActive = true;
    //    prBook.isStandard = true;
        insert prBook;
       	
       	List<PricebookEntry> PricebookEntryList = new List<PricebookEntry>();
       	
       	PricebookEntry priEntry = new PricebookEntry();
	    	priEntry.Product2Id = allProd[0].Id;
		    priEntry.Pricebook2Id = Test.getStandardPricebookId();
		    priEntry.UnitPrice = 100;
		    priEntry.isActive=true;
		    PricebookEntryList.add(priEntry);
		    
		    PricebookEntry priEntry2 = new PricebookEntry();
	    	priEntry2.Product2Id = allProd[0].Id;
		    priEntry2.Pricebook2Id = prBook.Id;
		    priEntry2.UnitPrice = 100;
		    priEntry2.isActive=true;
		    PricebookEntryList.add(priEntry2);
	    
	    insert PricebookEntryList;
	    
	    Id stdPriceBookRecId = Test.getStandardPricebookId();
	    
	    OpportunityLineItem oppLineItem = new OpportunityLineItem();
	    oppLineItem.quantity = 2;
	    oppLineItem.UnitPrice = 10;
	    oppLineItem.PricebookEntryId = PricebookEntryList[1].Id;
	    oppLineItem.Product2Id = allProd[0].Id;
	    oppLineItem.OpportunityId = opp.Id;
	    insert oppLineItem;

      Id ccRecordTypeId = Schema.SObjectType.ASPHPP__ASPayment_Source__c.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
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
      newSubscription.AS_Auto_Renew__c        =   false;
      newSubscription.AS_Frequency__c         =   1;
      newSubscription.AS_Start_Date__c        =   Date.today();
      newSubscription.AS_End_Date__c          =   Date.today().addDays(365);
      newSubscription.AS_Type__c              =   'Member';
      newSubscription.AS_Payment_Source__c    =   paySource.Id;
      newSubscription.AS_Membership_Span__c   =   1;
      newSubscription.AS_Price_Book__c        =   prBook.Id;
      newSubscription.Account__c              =   acc.Id;
      newSubscription.AS_Membership_Status__c =   'Pending';//Jan 9
      newSubscription.AS_Product__c           =   allProd[0].Id;
      newSubscription.AS_Membership_Renewal_Date__c = Date.today();
      newSubscription.AS_Type__c              = 'Member';
      newSubscription.AS_Membership_Status__c = 'Current'; 
      insert newSubscription;
 
      Opportunity opp1 = new Opportunity();
      opp1.Id = opp.Id;
      opp1.AS_PSA_Subscription__c = newSubscription.Id;
      update opp1;

	    ASPSASettings__c setting = new ASPSASettings__c();
			setting.AsCouponProductId__c = String.valueOf(allProd[1].Id);
			insert setting;
			
				
			// adding of coupon code starts here
			Id amountRecordTypeId = Schema.SObjectType.AS_Coupon__c.getRecordTypeInfosByName().get('Amount').getRecordTypeId();
    	Id percentRecordTypeId = Schema.SObjectType.AS_Coupon__c.getRecordTypeInfosByName().get('Percentage').getRecordTypeId();
    	
    	List<AS_Coupon__c> allCouponCodeList = new List<AS_Coupon__c>();
			
			AS_Coupon__c cou = new AS_Coupon__c();
			cou.AS_Status__c = 'Active';
			cou.AS_Code__c = 'amt1';
			cou.recordTypeId = amountRecordTypeId;
			cou.AS_Discount_Amount__c = 10;
			allCouponCodeList.add(cou);
					
			AS_Coupon__c cou2 = new AS_Coupon__c();
			cou2.AS_Status__c = 'Active';
			cou2.AS_Code__c = 'amt2';
			cou2.recordTypeId = amountRecordTypeId;
			cou2.AS_Discount_Amount__c = 10000;
			allCouponCodeList.add(cou2);
			
			AS_Coupon__c cou3 = new AS_Coupon__c();
			cou3.AS_Status__c = 'Active';
			cou3.AS_Code__c = 'per1';
			cou3.recordTypeId = percentRecordTypeId;
			cou3.AS_Percentage_Discount__c = 1;
			allCouponCodeList.add(cou3);
			
			AS_Coupon__c cou4 = new AS_Coupon__c();
			cou4.AS_Status__c = 'Active';
			cou4.AS_Code__c = 'per2';
			cou4.recordTypeId = percentRecordTypeId;
			cou4.AS_Percentage_Discount__c = 200;
			allCouponCodeList.add(cou4);
			
			insert allCouponCodeList;
			// adding of coupon code ends here
			AS_memberPayment.processData('{"PRICEBOOKID":"'+prBook.Id+'","OPPORTUNITYID":"'+opp.Id+'","ACCOUNTID":"'+acc.Id+'","SUBTOTAL":0,"PAYBY":"CreditCard","DISCOUNT":{"type":"","value":0,"coupon":""},"CARDDETAILS":{"Name_On_Card":"john visa","Card_Number":"4987654321098769","Card_Type":"Visa Card","Card_Expiry_Month":"05","Card_Expiry_Year":"2021","CCV":"123"},"HASDISCOUNT":false,"TOTAL":0,"ACKNOWLEDGEDBRQSTSRVC":true,"CONSENTTOGIVESGNTR":true}');
 	}
}