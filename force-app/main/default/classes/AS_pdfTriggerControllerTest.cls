@isTest
private class AS_pdfTriggerControllerTest {
	
        @isTest static void test_method_one() {
                Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

                Id stdPriceBookRecId = Test.getStandardPricebookId();
                String uniqueUserName1 = 'memberuserjrc' + DateTime.now().getTime() + '@testorg.com';
                Account acc = new Account();
                acc.RecordTypeId = personAccountId;
                acc.FirstName = 'mFirst';
                acc.LastName = 'mLast';
                acc.AS_Sign_Up_Email__pc = uniqueUserName1; 
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


                AS_Subscription__c subs      =   new AS_Subscription__c();
                //subs.AS_Payment_Source__c = source.Id;
                subs.AS_Auto_Renew__c = true;
                subs.AS_Frequency__c = 1;
                subs.AS_Start_Date__c = Date.newInstance(2018, 1, 13);
                subs.AS_End_Date__c = Date.newInstance(2018, 11, 13);
                subs.AS_Type__c = 'Member';
                subs.AS_Membership_Span__c = 2;
                subs.AS_Price_Book__c = prBook.Id;
                subs.Account__c = acc.Id;
                subs.AS_Membership_Status__c = 'Pending';
                subs.AS_Product__c = prod.Id;
                insert subs;
        
                Map<Id,Id> mapSubIdandAccId = new Map<Id,Id>();
                mapSubIdandAccId.put(subs.Id,acc.Id);
         
                AS_pdfTriggerController.addPDFAttach(mapSubIdandAccId);
                AS_pdfTriggerController.createInvoiceByButton(newOrder.Id);
	}
	
}