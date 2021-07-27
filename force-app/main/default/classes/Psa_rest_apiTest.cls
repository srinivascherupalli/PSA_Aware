@isTest
private class Psa_rest_apiTest {

	@isTest static void one() {

		Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

		Account acc = new Account();
    acc.RecordTypeId = personAccountId;
    acc.FirstName = 'mFirst';
    acc.LastName = 'mLast';
    acc.PersonEmail = 'm@m.com';
    acc.BillingStreet = 'Baker Street';
    acc.BillingCity = 'Ozamiz';
    acc.BillingCountry = 'PH';
    acc.BillingPostalCode = '7200';
    acc.BillingState = 'Empire State';
    acc.ShippingStreet = 'Baker Street';
    acc.ShippingCity = 'Ozamiz';
    acc.ShippingCountry = 'PH';
    acc.ShippingPostalCode = '7200';
    acc.ShippingState = 'Empire State';
    insert acc;

		Pricebook2 prBook = new Pricebook2();
    prBook.Name = 'standard pricebook';
    prBook.AS_Frequency__c = 12;
    insert prBook;
        
    Product2 prod = new Product2();
    prod.Name  = 'Product A';
    prod.isActive = true;
   	insert prod;
       	
   	Product2 prod2 = new Product2();
    prod2.Name  = 'Product B';
    prod2.isActive = true;
   	insert prod2;

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
		    
    ORder newOrder = new Order();
		newOrder.AccountId = acc.id;
		newOrder.Status = 'Draft';
		newOrder.EffectiveDate = Date.today();
		newOrder.Pricebook2Id  =  prBook.Id;
		insert newOrder;
        
    OrderItem ordrItem = new OrderItem();
    ordrItem.PricebookEntryId = PricebookEntryList[1].Id;
    ordrItem.OrderId = newOrder.Id;
    ordrItem.UnitPrice = 100;
    ordrItem.Quantity = 5;
    insert ordrItem;

   	Order newOrder2 = new Order();
   	newOrder2.Id = newOrder.Id;
   	newOrder2.Status = 'Activated';
   	update newOrder2;

    RestRequest req = new RestRequest();
  	RestResponse res = new RestResponse();
  	req.requestURI = '/PSA_process_order/';  //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
 
	
    RecordType recordTypeid4 = [SELECT Id,Name,SobjectType FROM RecordType WHERE Name = 'EziDebit' AND SobjectType = 'ASPHPP__ASGateway__c'];
        
	ASPHPP__ASGateway__c asGate = new ASPHPP__ASGateway__c();
	asGate.Name = 'Ezidebit Gateway';
    asGate.ASPHPP__Digital_Token_Key__c = '51172E35-1B77-41DF-2007-0EE14CB27262';
    asGate.RecordType = recordTypeid4;
   	insert asGate;

		String msg = '{"PSA_Order_Details":{"Order_id":"'+ newOrder.Id +'","FirstName":"Doge","StoreCredit":"0","LastName":"Wow","PersonEmail":"michelle@alphasys.com.au","BillingStreet":"9 Gag Street ","BillingCity":"Reddit","BillinCountry":"AU","BillingPostalCode":"9000","BillingState":"NSW","ShippingStreet":" ","ShippingCity":"","ShippingCountry":"","ShippingPostalCode":"","ShippingState":"","AccountRecordType":"Business Account","CompanyName":"Doge","Order_note":"","FileName":"Sample File","FileContent":"'+EncodingUtil.base64Encode(Blob.valueOf('test'))+'","Transaction_id":"11210831","Order_Status":"processing","Stripe_source_id":"src_1CzHtxLllRQCw1aoJ1rhOatV","Order_total":"129.00","Gateway_id":"'+asGate.Id+'","Orders":[{"product_id":"' + prod.Id + '","quantity":1,"price":30,"totalprice":30,"percentage_discount":10,"tax_rate":10,"PriceBookEntry":"'+PricebookEntryList[1].Id+'"}]}}';
		
		req.requestBody = Blob.valueof(msg);
		RestContext.request = req;
		RestContext.response= res;

		Psa_rest_api.doPost();
	}
	
	@isTest static void two() {

		Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

				Account acc = new Account();
        acc.RecordTypeId = personAccountId;
        acc.FirstName = 'mFirst';
        acc.LastName = 'mLast';
        acc.PersonEmail = 'm@m.com';
        acc.BillingStreet = 'Baker Street';
        acc.BillingCity = 'Ozamiz';
        acc.BillingCountry = 'PH';
        acc.BillingPostalCode = '7200';
        acc.BillingState = 'Empire State';
        acc.ShippingStreet = 'Baker Street';
        acc.ShippingCity = 'Ozamiz';
        acc.ShippingCountry = 'PH';
        acc.ShippingPostalCode = '7200';
        acc.ShippingState = 'Empire State';
        insert acc;

				Pricebook2 prBook = new Pricebook2();
        prBook.Name = 'standard pricebook';
        prBook.AS_Frequency__c = 12;
        insert prBook;
        
        Product2 prod = new Product2();
        prod.Name  = 'Product A';
        prod.isActive = true;
       	insert prod;
       	
       	Product2 prod2 = new Product2();
        prod2.Name  = 'Product B';
        prod2.isActive = true;
       	insert prod2;

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
		    
		    ORder newOrder = new Order();
        newOrder.AccountId = acc.id;
        newOrder.Status = 'Draft';
        newOrder.EffectiveDate = Date.today();
        newOrder.Pricebook2Id  =  prBook.Id;
        insert newOrder;
        
        OrderItem ordrItem = new OrderItem();
        ordrItem.PricebookEntryId = PricebookEntryList[1].Id;
        ordrItem.OrderId = newOrder.Id;
        ordrItem.UnitPrice = 100;
        ordrItem.Quantity = 5;
        insert ordrItem;

       	Order newOrder2 = new Order();
       	newOrder2.Id = newOrder.Id;
       	newOrder2.Status = 'Activated';
       	update newOrder2;

        RestRequest req = new RestRequest();
  		RestResponse res = new RestResponse();
  		req.requestURI = '/PSA_process_order/';  //Request URL
		req.httpMethod = 'POST';//HTTP Request Type

		
        RecordType recordTypeid4 = [SELECT Id,Name,SobjectType FROM RecordType WHERE Name = 'EziDebit' AND SobjectType = 'ASPHPP__ASGateway__c'];
        
        ASPHPP__ASGateway__c asGate = new ASPHPP__ASGateway__c();
        asGate.Name = 'Ezidebit Gateway';
        asGate.ASPHPP__Digital_Token_Key__c = '51172E35-1B77-41DF-2007-0EE14CB27262';
        asGate.RecordType = recordTypeid4;
        insert asGate;
		
		String msg = '{"PSA_Order_Details":{"Order_id":"'+ newOrder.Id +'","FirstName":"Doge","LastName":"Wow","StoreCredit":"0","PersonEmail":"michelle@alphasys.com.au","BillingStreet":"9 Gag Street ","BillingCity":"Reddit","BillinCountry":"AU","BillingPostalCode":"9000","BillingState":"NSW","ShippingStreet":" ","ShippingCity":"","ShippingCountry":"","ShippingPostalCode":"","ShippingState":"","AccountRecordType":"Person Account","CompanyName":"Doge","Order_note":"","FileName":"Sample File","FileContent":"'+EncodingUtil.base64Encode(Blob.valueOf('test'))+'","Transaction_id":"11210831","Order_Status":"processing","Stripe_source_id":"src_1CzHtxLllRQCw1aoJ1rhOatV","Order_total":"129.00","Gateway_id":"'+asGate.Id+'","Orders":[{"product_id":"' + prod.Id + '","quantity":1,"price":30,"totalprice":30,"percentage_discount":10,"tax_rate":10,"PriceBookEntry":"'+PricebookEntryList[1].Id+'"}]}}';
		req.requestBody = Blob.valueof(msg);
		RestContext.request = req;
		RestContext.response= res;

		Psa_rest_api.doPost();
	}
}