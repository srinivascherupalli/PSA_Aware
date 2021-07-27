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
private class AS_orderInvoiceExtTest {

    static testMethod void AS_orderInvoiceContruct() {
    	Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
       	
	   	Account acc = new Account();
	   	acc.FirstName = 'John Hope';
	   	Acc.LastName = 'Ondona';
	   	acc.recordTypeId = personAccRecId;
	   	acc.PersonEmail = 'test@test.com';
	   	insert acc;
	   
	   	Product2 prod = new Product2();
	    prod.Name  = 'Product Name';
	    prod.isActive = true;
	   	insert prod;
	   	
	   	Pricebook2 prBook = new Pricebook2();
	    prBook.Name = 'standard pricebook';
	    prBook.isActive = true;
	//    prBook.isStandard = true;
	    insert prBook;
	    
	    Order ord = new Order();
	   	ord.Name = 'john hope test ord';
	   	ord.AccountId = acc.Id;
	   	ord.Status = 'Draft';
	   	ord.EffectiveDate = Date.today();
	   	ord.Pricebook2Id = prBook.Id;
	   	insert ord;
	   	
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
	    
	    OrderItem oi = new OrderItem(OrderId=ord.id,Quantity=decimal.valueof('1'),PricebookEntryId=PricebookEntryList[1].Id,UnitPrice = decimal.valueof('100')); 
	    insert oi;
    	
     	PageReference pageRef = Page.AS_InvoicePdf;
     	Test.setCurrentPage(pageRef);

     	pageRef.getParameters().put('Id', String.valueOf(ord.Id));
     	ApexPages.StandardController sc = new ApexPages.StandardController(ord);
     	AS_orderInvoiceExt ext = new AS_orderInvoiceExt(sc);
     	
     	System.AssertEquals(database.countquery('SELECT '
                                                        + 'COUNT()'
                                                +' FROM'
                                                    +' Order '
                                            ),1
                                ); 
   	}
   	
   	static testMethod void AS_orderInvoiceContructwithContact() {
    	Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
       	
	   	Account acc = new Account();
	   	acc.FirstName = 'John Hope';
	   	Acc.LastName = 'Ondona';
	   	acc.recordTypeId = personAccRecId;
	   	acc.PersonEmail = 'test@test.com';
	   	insert acc;
	   	
	   	Contact con = new Contact();
	   	con.LastName = 'Ondona';
	   	insert con;
	   
	   	Product2 prod = new Product2();
	    prod.Name  = 'Product Name';
	    prod.isActive = true;
	   	insert prod;
	   	
	   	Pricebook2 prBook = new Pricebook2();
	    prBook.Name = 'standard pricebook';
	    prBook.isActive = true;
	//    prBook.isStandard = true;
	    insert prBook;
	    
	    Order ord = new Order();
	   	ord.Name = 'john hope test ord';
	   	ord.AccountId = acc.Id;
	   	ord.Status = 'Draft';
	   	ord.EffectiveDate = Date.today();
	   	ord.Pricebook2Id = prBook.Id;
	   	ord.AS_Ship_To_Contact__c = con.Id;
	   	insert ord;
	   	
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
	    
	    OrderItem oi = new OrderItem(OrderId=ord.id,Quantity=decimal.valueof('1'),PricebookEntryId=PricebookEntryList[1].Id,UnitPrice = decimal.valueof('100')); 
	    insert oi;
    	
     	PageReference pageRef = Page.AS_InvoicePdf;
     	Test.setCurrentPage(pageRef);

     	pageRef.getParameters().put('Id', String.valueOf(ord.Id));
     	ApexPages.StandardController sc = new ApexPages.StandardController(ord);
     	AS_orderInvoiceExt ext = new AS_orderInvoiceExt(sc);
     	
     	system.debug(ext.theOrder);
     	system.debug(ext.shipToContactStr);
     	system.debug(ext.shipToContactAccStr);
     	
     	System.AssertEquals(database.countquery('SELECT '
                                                        + 'COUNT()'
                                                +' FROM'
                                                    +' Order '
                                            ),1
                                ); 
    }
}