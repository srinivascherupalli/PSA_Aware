@isTest
public class AsOpportunityTriggerHandlerTest {
    
    static testMethod void AsOpportunityTestMethod1() {
        
        Id ccRecordTypeId = Schema.SObjectType.ASPHPP__ASPayment_Source__c.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Id idOppMembership = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();
        
        TestTrainingTrackData.createSampleData();
        
        List<Training_Track__c> tracks = [select id,Achievement__c,name from Training_Track__c];
        
        System.debug('AsTrainingList ' + tracks );
	    	
	    Account acc = new Account();
       	acc.FirstName = 'John Hope';
       	Acc.LastName = 'Ondona';
       	acc.recordTypeId = personAccRecId;
       	acc.PersonEmail = 'test@test.com';
       	insert acc;
        
        LMS_Instance__c	 LmsInstance = new LMS_Instance__c();
        LmsInstance.Type__c = 'Moodle';
        LmsInstance.Date__c = Date.today();
        LmsInstance.Status__c = 'Active';
        LmsInstance.Token__c = '1234567890';
        LmsInstance.Domain_URL__c = 'https://samplewebsite.com';
        LmsInstance.URL__c = 'https://lms.alphasys.com.au/moodle/';
        insert LmsInstance;
        
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
        
        Product2 Asprod = new Product2();
        Asprod.Name  = 'Product Name';
        Asprod.isActive = true;
       	insert Asprod;
       	
       	Product2 prod = new Product2();
        prod.Name  = 'student members';
        prod.isActive = true;
        prod.AS_Parent_Product__c = Asprod.Id;
       	insert prod;
       	
       	Pricebook2 prBook = new Pricebook2();
        prBook.Name = 'standard pricebook';
        prBook.isActive = true;
    //    prBook.isStandard = true;
        insert prBook;
        
        Training_Plan__c tplan = new Training_Plan__c();
        tplan.AS_Training_Plan_Type__c = 'Australian Pharmacist';
        tplan.Name = 'Testing TPlan';
        tplan.Type__c = 'Public';
        tplan.Status__c = 'Active';
        tplan.AS_Product__c = prod.Id;
        tplan.AS_LMS__c = 'Moodle Course';
        tplan.AS_LMS_Instance__c = LmsInstance.Id;
        insert tplan;

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
        
        system.debug('subscriptions==> '+ newSubscription);
        
        Training_Track__c AsTrainingTrack = new Training_Track__c(
            Name = 'Test Training Track',
            Status__c = 'Active',
            Product__c = prod.Id,
            AS_Track_Type__c = 'Public'
        );
        insert AsTrainingTrack;
        
        Training_Track_Account__c tAcc = new Training_Track_Account__c();
        tAcc.AS_Approval_Status__c = 'Confirmed';
        tAcc.Training_Track__c = AsTrainingTrack.Id;
        tAcc.Account__c = acc.Id;
        insert tAcc;
        
        List<Opportunity> allOppList = new List<Opportunity>();
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'test opportunity 2';
        opp2.StageName = 'Prospecting';
        opp2.CloseDate  = date.newinstance(2020, 12, 30);
        opp2.RecordTypeId = idOppMembership;
        opp2.Pricebook2Id = prBook.Id;
        opp2.AS_Create_Subscription__c = false; 
        opp2.AccountId = acc.Id;
        opp2.AS_Product__c = prod.Id;
        opp2.AS_PSA_Subscription__c = newSubscription.Id;
        allOppList.add(opp2);

        Opportunity opp = new Opportunity();
        opp.Name = 'test opportunity 1';
        opp.StageName = 'Prospecting';
        opp.CloseDate  = date.newinstance(2020, 12, 30);
        opp.RecordTypeId = idOppMembership;
        opp.Pricebook2Id = prBook.Id;
        opp.AS_Create_Subscription__c = true; 
        opp.AccountId = acc.Id;
        opp.AS_Product__c = prod.Id;
        opp.AS_PSA_Subscription__c = newSubscription.Id;
        allOppList.add(opp);
        
        Opportunity opp1 = new Opportunity();
       	opp1.Name = 'john hope test opp';
       	opp1.CloseDate = date.newInstance(2018, 3, 15);
       	opp1.StageName = 'Prospecting';
       	opp1.AccountId = acc.Id;
       	opp1.AS_Create_Subscription__c = false;
       	opp1.AS_Add_Products__c = true;
       	opp1.AS_Product_Price__c = 100;
       	opp1.AS_Product__c = prod.Id;
       	opp1.Pricebook2Id = prBook.Id;
       	opp1.AS_Account_Number__c = String.valueOf(acc.Id);
        opp1.RecordTypeId = idOppMembership;
        opp1.AS_PSA_Subscription__c = newSubscription.Id;
        allOppList.add(opp1);
        
        insert allOppList;
        
        List<OpportunityLineItem> AsOppLineItemList = new List<OpportunityLineItem>();
        
        OpportunityLineItem oppline1 = new OpportunityLineItem();
        oppline1.OpportunityId = allOppList[0].Id;
        oppline1.Product2Id = prod.Id; 
        oppline1.Quantity = 5;
        oppline1.UnitPrice = 100.00;
        oppline1.PricebookEntryId = PricebookEntryList[1].Id;
        AsOppLineItemList.add( oppline1 );
        
        OpportunityLineItem oppline2 = new OpportunityLineItem();
        oppline2.OpportunityId = allOppList[1].Id;
        oppline2.Product2Id = prod.Id; 
        oppline2.Quantity = 5;
        oppline2.UnitPrice = 100.00;
        oppline2.PricebookEntryId = PricebookEntryList[1].Id;
        AsOppLineItemList.add( oppline2 );
        
        OpportunityLineItem oppline3 = new OpportunityLineItem();
        oppline3.OpportunityId = allOppList[2].Id;
        oppline3.Product2Id = prod.Id; 
        oppline3.Quantity = 5;
        oppline3.UnitPrice = 100.00;
        oppline3.PricebookEntryId = PricebookEntryList[1].Id;
        AsOppLineItemList.add( oppline3 );
        
        insert AsOppLineItemList;
        
        Opportunity upOpp1 = new Opportunity();
        upOpp1.Id = allOppList[0].Id;
        upOpp1.StageName = 'Closed Won';
        update upOpp1;
        
        Opportunity upOpp2 = new Opportunity();
        upOpp2.Id = allOppList[1].Id;
        upOpp2.StageName = 'Closed Won';
        update upOpp2;
        
        Opportunity upOpp3 = new Opportunity();
        upOpp3.Id = allOppList[2].Id;
        upOpp3.StageName = 'Closed Won';
        update upOpp3;
       
        
    }
    
    static testMethod void AsOpportunityTestMethod2() {
        
        Id ccRecordTypeId = Schema.SObjectType.ASPHPP__ASPayment_Source__c.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Id idOppMembership = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();
        
        TestTrainingTrackData.createSampleData();
        
        List<Training_Track__c> tracks = [select id,Achievement__c,name from Training_Track__c];
        
        System.debug('AsTrainingList ' + tracks );
	    	
	    Account acc = new Account();
       	acc.FirstName = 'John Hope';
       	Acc.LastName = 'Ondona';
       	acc.recordTypeId = personAccRecId;
       	acc.PersonEmail = 'test@test.com';
       	insert acc;
        
        LMS_Instance__c	 LmsInstance = new LMS_Instance__c();
        LmsInstance.Type__c = 'Moodle';
        LmsInstance.Date__c = Date.today();
        LmsInstance.Status__c = 'Active';
        LmsInstance.Token__c = '1234567890';
        LmsInstance.Domain_URL__c = 'https://samplewebsite.com';
        LmsInstance.URL__c = 'https://lms.alphasys.com.au/moodle/';
        insert LmsInstance;
        
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
        
        Product2 Asprod = new Product2();
        Asprod.Name  = 'Product Name';
        Asprod.isActive = true;
       	insert Asprod;
        
        Membership_Type__c mt = new Membership_Type__c( Name = 'MT Name' );
        insert mt;
       	
       	Product2 prod = new Product2();
        prod.Name  = 'student members';
        prod.isActive = true;
        prod.AS_Parent_Product__c = Asprod.Id;
        prod.AS_Membership_Type__c = mt.Id;
       	insert prod;
       	
       	Pricebook2 prBook = new Pricebook2();
        prBook.Name = 'standard pricebook';
        prBook.isActive = true;
    //    prBook.isStandard = true;
        insert prBook;
        
        Training_Plan__c tplan = new Training_Plan__c();
        tplan.AS_Training_Plan_Type__c = 'Australian Pharmacist';
        tplan.Name = 'Testing TPlan';
        tplan.Type__c = 'Public';
        tplan.Status__c = 'Active';
        tplan.AS_Product__c = prod.Id;
        tplan.AS_LMS__c = 'Moodle Course';
        tplan.AS_LMS_Instance__c = LmsInstance.Id;
        insert tplan;

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
        
        //AS_Subscription__c newSubscription      =   new AS_Subscription__c();
	    //newSubscription.AS_Auto_Renew__c        =   true;
	    //newSubscription.AS_Frequency__c         =   1;
	    //newSubscription.AS_Start_Date__c        =   Date.today();
	    //newSubscription.AS_End_Date__c 			=   Date.today();
	 	//newSubscription.AS_Type__c              =   'Member';
	    //newSubscription.AS_Payment_Source__c    =   paySource.Id;
	    //newSubscription.AS_Membership_Span__c   =   1;
	    //newSubscription.AS_Price_Book__c        =   prBook.Id;
	    //newSubscription.Account__c              =   acc.Id;
	    //newSubscription.AS_Membership_Status__c =   'Pending';//Jan 9
	    //newSubscription.AS_Product__c           =  prod.Id;
	    //newSubscription.AS_Membership_Renewal_Date__c = Date.today();
	    //newSubscription.AS_Type__c = 'Member';
	    //newSubscription.AS_Membership_Status__c = 'Current';
		//insert newSubscription;
        
        //system.debug('subscriptions==> '+ newSubscription);
        
        Training_Track__c AsTrainingTrack = new Training_Track__c(
            Name = 'Test Training Track',
            Status__c = 'Active',
            Product__c = prod.Id,
            AS_Track_Type__c = 'Public'
        );
        insert AsTrainingTrack;
        
        Training_Track_Account__c tAcc = new Training_Track_Account__c();
        tAcc.AS_Approval_Status__c = 'Confirmed';
        tAcc.Training_Track__c = AsTrainingTrack.Id;
        tAcc.Account__c = acc.Id;
        insert tAcc;
        
        List<Opportunity> allOppList = new List<Opportunity>();
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'test opportunity 2';
        opp2.StageName = 'Closed Won';
        opp2.CloseDate  = date.newinstance(2020, 12, 30);
        opp2.RecordTypeId = idOppMembership;
        opp2.Pricebook2Id = prBook.Id;
        opp2.AS_Create_Subscription__c = true; 
        opp2.AccountId = acc.Id;
        opp2.AS_Product__c = prod.Id;
        //opp2.AS_PSA_Subscription__c = newSubscription.Id;
        allOppList.add(opp2);

        Opportunity opp = new Opportunity();
        opp.Name = 'test opportunity 1';
        opp.StageName = 'Closed Won';
        opp.CloseDate  = date.newinstance(2020, 12, 30);
        opp.RecordTypeId = idOppMembership;
        opp.Pricebook2Id = prBook.Id;
        opp.AS_Create_Subscription__c = false; 
        opp.AccountId = acc.Id;
        opp.AS_Product__c = prod.Id;
        //opp.AS_PSA_Subscription__c = newSubscription.Id;
        allOppList.add(opp);
        
        Opportunity opp1 = new Opportunity();
       	opp1.Name = 'john hope test opp';
       	opp1.CloseDate = date.newInstance(2018, 3, 15);
       	opp1.StageName = 'Closed Won';
       	opp1.AccountId = acc.Id;
       	opp1.AS_Create_Subscription__c = false;
       	opp1.AS_Add_Products__c = true;
       	opp1.AS_Product_Price__c = 100;
       	opp1.AS_Product__c = prod.Id;
       	opp1.Pricebook2Id = prBook.Id;
       	opp1.AS_Account_Number__c = String.valueOf(acc.Id);
        opp1.RecordTypeId = idOppMembership;
        //opp1.AS_PSA_Subscription__c = newSubscription.Id;
        allOppList.add(opp1);
        
        insert allOppList;
        
        OpportunityLineItem oppline = new OpportunityLineItem();
        oppline.OpportunityId = allOppList[2].Id;
        oppline.Product2Id = prod.Id; 
        oppline.Quantity = 5;
        oppline.UnitPrice = 100.00;
        oppline.PricebookEntryId = PricebookEntryList[1].Id;
        insert oppline;
        
        Opportunity upOpp1 = new Opportunity();
        upOpp1.Id = allOppList[0].Id;
        upOpp1.AS_Create_Subscription__c = true;
        //upOpp1.AS_PSA_Subscription__c = newSubscription.Id;
        update upOpp1;
        
        //Opportunity upOpp2 = new Opportunity();
        //upOpp2.Id = allOppList[1].Id;
        //upOpp2.AS_Create_Subscription__c = true;
        //upOpp2.AS_PSA_Subscription__c = newSubscription.Id;
        //update upOpp2;
        
        //Opportunity upOpp3 = new Opportunity();
        //upOpp3.Id = allOppList[2].Id;
        //upOpp3.AS_Create_Subscription__c = true;
        //upOpp3.AS_PSA_Subscription__c = newSubscription.Id;
        //update upOpp3;
        
    }

    static testMethod void AS_createOppProdFromViFlowTriggerTest() {

        system.debug(' test 1 ');

    	Test.startTest();
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
       Test.stopTest();
    }

    static testMethod void AsOppStageMethod() {

        Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Id onlineShopRecordId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Online_Shop').getRecordTypeId();

        Account acc = new Account();
        acc.FirstName = 'John Hope';
        Acc.LastName = 'Ondona';
        acc.recordTypeId = personAccRecId;
        acc.PersonEmail = 'test@test.com';
        insert acc;

        Opportunity oppStage = new Opportunity(

            Name = 'test opp 3',
            CloseDate = date.newInstance(2018, 3, 15),
            StageName = 'Closed Won',
            AccountId = acc.Id,
            //AS_Product__c = prod.Id,
            RecordTypeId = onlineShopRecordId,
            // Generate_Order__c = true,
            AS_Generate_Order_Without_Invoice__c = true

        );
        insert oppStage;

        // Opportunity upOpp = new Opportunity(

        //     Id = oppStage.Id,
        //     StageName = 'Closed Won'

        // );
        // update upOpp;



    }

}