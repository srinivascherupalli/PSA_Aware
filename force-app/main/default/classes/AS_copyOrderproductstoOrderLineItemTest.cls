@isTest
private class AS_copyOrderproductstoOrderLineItemTest {
	
	@isTest static void test_method_one() {
        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        Id stdPriceBookRecId = Test.getStandardPricebookId();

        Account acc = new Account();
        acc.RecordTypeId = personAccountId;
        acc.FirstName = 'mFirst';
        acc.LastName = 'mLast';
        acc.PersonEmail = 'm@m.com';
        acc.AS_Graduation_Year__pc = '2005';
        insert acc;

        Pricebook2 prBook = new Pricebook2();
        prBook.Name = 'standard pricebook';
        prBook.AS_Frequency__c = 12;
        insert prBook;

        ORder newOrder = new Order();
        newOrder.AccountId = acc.id;
        newOrder.Status = 'Draft';
        newOrder.EffectiveDate = Date.today();
        newOrder.Pricebook2Id  =  prBook.Id;
        insert newOrder;

        Product2 prod = new Product2();
        prod.Name  = 'Product1';
        prod.isActive = true;
        prod.AS_GST_Product__c = true;
        //prod.AS_Membership_Type__c = mmbrshipType.Id; 
        insert prod;

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

        OrderItem ordrItem = new OrderItem();
        ordrItem.PricebookEntryId = pbe.Id;
        ordrItem.OrderId = newOrder.Id;
        ordrItem.UnitPrice = 100;
        ordrItem.Quantity = 5;
        insert ordrItem;

        Order ordr2update = new Order();
        ordr2update.Id = newOrder.Id;
        ordr2update.Status = 'Activated';
        ordr2update.AS_Generate_Invoice__c = true;
        update ordr2update;
	}
	
}