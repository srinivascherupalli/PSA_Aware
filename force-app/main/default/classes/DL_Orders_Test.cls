@isTest
public with sharing class DL_Orders_Test {

    @TestSetup
    @future()
    static void makeData(){

        ID profile_ID = [SELECT ID from Profile WHERE Name = 'Non Member Login User'].id;

        Id stdPriceBookRecId = Test.getStandardPricebookId();
    
        Account testAccount = new Account();
        testAccount.FirstName = 'Adam';
        testAccount.LastName = 'Baker';
        testAccount.recordTypeId = [SELECT ID FROM RecordType WHERE Name = 'Person Account'].id;
        testAccount.PersonEmail = 'Adam.Baker@psa.org.au';
        testAccount.BillingPostalCode = '2600';
        testAccount.Fax = '(02)61711-111 111';
        testAccount.PersonHasOptedOutOfFax = false;
        insert testAccount;


        Order testOrder = new Order();
        testOrder.AccountId = testAccount.Id;
        testOrder.EffectiveDate = date.today();
        testOrder.Status = 'Draft';
        testOrder.Pricebook2Id  =  stdPriceBookRecId;
        insert testOrder;


        Product2 prod = new Product2();
        prod.Name  = 'Product1';
        prod.isActive = true;
        prod.AS_GST_Product__c = true;
        insert prod;


        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = prod.Id;
        pbe.Pricebook2Id = stdPriceBookRecId;
        pbe.UnitPrice = 100;
        pbe.isActive=true;
        insert pbe;


        OrderItem testOrderItem = new OrderItem();
        testOrderItem.PricebookEntryId = pbe.Id;
        testOrderItem.OrderId = testOrder.Id;
        testOrderItem.UnitPrice = 100;
        testOrderItem.Quantity = 1;
        insert testOrderItem;
    }



    @isTest
    static void testCompleteOrder(){

            Id orderId = [SELECT Id FROM Order LIMIT 1].Id;
            Test.startTest();
            DL_Orders.completeOrderItems(orderId);
            Test.stopTest();
    }

    @isTest
    static void testProcessingOrder(){

            Id orderId = [SELECT Id FROM Order LIMIT 1].Id;
            Test.startTest();
            DL_Orders.processingOrderItems(orderId);
            Test.stopTest();
    }
}