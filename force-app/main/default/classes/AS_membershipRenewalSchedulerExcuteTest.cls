@isTest
private class AS_membershipRenewalSchedulerExcuteTest {
	
	@isTest static void AS_membershipRenewalSchedulerExcute1() {
		Membership_End_Date_Renewal__c setting = new Membership_End_Date_Renewal__c();
        setting.Name = 'Test Setting';
        setting.T1__c = 5;
        setting.T2__c = 5;
        setting.T3__c = 5;
        setting.T4__c = 5;
        setting.T5__c = 5;
        setting.T6__c = 5;
        setting.T7__c = 5;
        setting.T8__c = 5;
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
        
        
        Opportunity opp = new Opportunity();
        opp.Name = 'john hope test opp';
        opp.CloseDate = date.newInstance(2018, 3, 15);
        opp.StageName = 'Qualification';
        opp.AccountId = acc.Id;
        opp.Amount = 100;
        insert opp;
        
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
        
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.quantity = 2;
        oppLineItem.UnitPrice = 10;
        oppLineItem.PricebookEntryId = PricebookEntryList[1].Id;
        oppLineItem.Product2Id = prod.Id;
        oppLineItem.OpportunityId = opp.Id;
        insert oppLineItem;
        
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
        // TO DO: implement unit test
        AS_Subscription__c newSubscription      =   new AS_Subscription__c();
        newSubscription.AS_Auto_Renew__c        =   false;
        newSubscription.AS_Frequency__c         =   1;
        newSubscription.AS_Start_Date__c        =   Date.today().addDays(-365);
        newSubscription.AS_End_Date__c          =   Date.today().addDays(-1*(Integer.valueOf(setting.T8__c)));
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

		Test.startTest(); 
        String jobId = System.schedule('Test Renewal', '0 0 0 15 3 ? 2030', new AS_membershipRenewalSchedulerExcute());
        Test.stopTest();
	}
}