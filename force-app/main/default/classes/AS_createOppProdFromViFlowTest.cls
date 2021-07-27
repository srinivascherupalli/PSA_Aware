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
private class AS_createOppProdFromViFlowTest {

    static testMethod void AS_createOppProdFromViFlowTriggerTest() {
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
       
       	Opportunity opp = new Opportunity();
       	opp.Name = 'john hope test opp';
       	opp.CloseDate = date.newInstance(2018, 3, 15);
       	opp.StageName = 'Qualification';
       	opp.AccountId = acc.Id;
       	opp.AS_Create_Subscription__c = true;
       	opp.AS_Add_Products__c = true;
       	opp.AS_Product_Price__c = 100;
       	opp.AS_Product__c = prod.Id;
       	opp.Pricebook2Id = prBook.Id;
       	opp.AS_Account_Number__c = String.valueOf(acc.Id);
       	insert opp;
        
    }
}