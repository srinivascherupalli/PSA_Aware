@isTest
private class AS_oppClosedWonTest {

   static testMethod void remakeTestClass(){

        system.debug(' test 0 ');

        Id idOppMembership = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();
        Id idSubscription = Schema.SObjectType.AS_Subscription__c.getRecordTypeInfosByName().get('Membership').getRecordTypeId();
        
        AsOpportunityTriggerHandler opphandler = new AsOpportunityTriggerHandler(false);
        System.debug(opphandler.IsTriggerContext);
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
    
    static testMethod void AS_oppClosedWonNewTriggerTest() {

        system.debug(' test 3 ');
    	
    	User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
       
    	System.runAs (thisUser) {
    		
		    AS_commonFunction.runOppCloseWon = true;
		    
		    Id idCash = Schema.SObjectType.ASPHPP__Payment__c.getRecordTypeInfosByName().get('Cash').getRecordTypeId();
		    
		    String opportunityStr = 'test opportunity';
	    	List<Opportunity> oppQueryResList = [Select Id, Name, StageName , AS_PSA_Subscription__c from Opportunity where name LIKE  :('%' + opportunityStr + '%')];

            system.debug('oppQueryResList==>'+ oppQueryResList ); 

	    	ASPHPP__ASPayment_Source__c source = [Select Id from ASPHPP__ASPayment_Source__c where Name = 'John Bank'];
	    	
	    	String subscriptionStr = 'testSubscription';
	    	List<ASPHPP__Subscription__c> subs = [Select Id from ASPHPP__Subscription__c where Name LIKE :('%' + subscriptionStr + '%')];
	    	
	    	System.debug('oppQueryResList :' + oppQueryResList);
	    	System.debug('subs :' + subs); 
	    	
	    	Test.startTest(); 
 		    ASPHPP__Payment__c pPayment = new ASPHPP__Payment__c();
			    pPayment.RecordTypeId               = idCash;
			    pPayment.ASPHPP__Opportunity__c     = oppQueryResList[0].Id; 
		     	pPayment.ASPHPP__PSubscription__c   = subs[0].Id;
			    pPayment.ASPHPP__Payment_Source__c  = source.Id;
			    pPayment.Name                       = 'testPayment';
			    pPayment.ASPHPP__Payment_Status__c  = 'Success';
			    insert pPayment;
			    
                system.debug('pPayment ==> '+ pPayment);  
  
			    List<Opportunity> oppQueryResList2 = [Select Id, Name, StageName , AS_PSA_Subscription__c from Opportunity where name LIKE  :('%' + opportunityStr + '%')];
			    System.debug('oppQueryResList2 :' + oppQueryResList2);
			    
			    Opportunity updateOpp = new Opportunity();
			    updateOpp.Id = oppQueryResList2[1].Id;
			    updateOpp.AS_PSA_Subscription__c = oppQueryResList2[0].AS_PSA_Subscription__c;
			    updateOpp.AS_Create_Subscription__c = false; 
			    update updateOpp;
			    System.debug('updateOpp :' + updateOpp);
			    
			    AS_commonFunction.runOppCloseWon = true;
			    
			    ASPHPP__Payment__c pPayment2 = new ASPHPP__Payment__c();
			    pPayment2.RecordTypeId = idCash;
			    pPayment2.ASPHPP__Opportunity__c = updateOpp.Id; 
		     	pPayment2.ASPHPP__PSubscription__c = subs[1].Id;
			    pPayment2.ASPHPP__Payment_Source__c = source.Id;
			    pPayment2.Name = 'testPayment';
			    pPayment2.ASPHPP__Payment_Status__c = 'Success';
			    insert pPayment2;
		    Test.stopTest();
    	}
    	
    }
    
    /*
    static testMethod void AS_oppClosedWonRenewTriggerTest() {
    	
    	User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
       
    	System.runAs (thisUser) {
    		
		    AS_commonFunction.runOppCloseWon = true;
		    
		    Id idCash = Schema.SObjectType.ASPHPP__Payment__c.getRecordTypeInfosByName().get('Cash').getRecordTypeId();
	    	Opportunity opp = [Select Id,Name,StageName from Opportunity where name = 'test opportunity 1'];
	    	ASPHPP__ASPayment_Source__c source = [Select Id from ASPHPP__ASPayment_Source__c where Name = 'John Bank'];
	    	ASPHPP__Subscription__c subs = [Select Id from ASPHPP__Subscription__c where Name = 'testSubscription'];
	    	
	    	opp.AS_Create_Subscription__c = false; 
	    	update opp;
	    	
	    	Test.startTest();
		    ASPHPP__Payment__c pPayment = new ASPHPP__Payment__c();
		    pPayment.RecordTypeId = idCash;
		    pPayment.ASPHPP__Opportunity__c = opp.Id; 
	     	pPayment.ASPHPP__PSubscription__c = subs.Id;
		    pPayment.ASPHPP__Payment_Source__c = source.Id;
		    pPayment.Name = 'testPayment';
		    pPayment.ASPHPP__Payment_Status__c = 'Success';
		    insert pPayment;
		    
		    Opportunity opp2 = [Select Id,Name,StageName,AS_PSA_Subscription__c from Opportunity where name = 'test opportunity 1'];
		    opp2.AS_Create_Subscription__c = false; 
	    	update opp2;
	    	
	    	// for renewal
	    	ASPHPP__Payment__c pPayment2 = new ASPHPP__Payment__c();
		    pPayment2.RecordTypeId = idCash;
		    pPayment2.ASPHPP__Opportunity__c = opp.Id; 
	     	pPayment2.ASPHPP__PSubscription__c = subs.Id;
		    pPayment2.ASPHPP__Payment_Source__c = source.Id;
		    pPayment2.Name = 'testPayment2';
		    pPayment2.ASPHPP__Payment_Status__c = 'Success';
		    insert pPayment2;
		    
		    
		    Test.stopTest();
    	}
    	
    }
    */
    
    @TestSetup  
		static void createData() {
			AS_commonFunction.runOppCloseWon = false;
				
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
				
				List<Opportunity> allOppList = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.Name = 'test opportunity 1';
        opp.StageName = 'Prospecting';
        opp.CloseDate  = date.newinstance(2020, 12, 30);
        opp.RecordTypeId = idOppMembership;
        opp.Pricebook2Id = prBook.Id;
        opp.AS_Create_Subscription__c = true; 
        opp.AccountId = acc.Id;
        opp.AS_Product__c = prod.Id; 
        allOppList.add(opp);
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'test opportunity 2';
        opp2.StageName = 'Prospecting';
        opp2.CloseDate  = date.newinstance(2020, 12, 30);
        opp2.RecordTypeId = idOppMembership;
        opp2.Pricebook2Id = prBook.Id;
        opp2.AS_Create_Subscription__c = false; 
        opp2.AccountId = acc.Id;
        opp2.AS_Product__c = prod.Id; 
        allOppList.add(opp2);
        
        insert allOppList;
        
        system.debug('QWER1 : '+allOppList);

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
				
				List<OpportunityLineItem> allOpportunityLineItem = new List<OpportunityLineItem>();
				
        OpportunityLineItem oppline = new OpportunityLineItem();
        oppline.OpportunityId = allOppList[0].Id;
        oppline.Product2Id = prod.Id; 
        oppline.Quantity = 5;
        oppline.UnitPrice = 100.00;
        oppline.PricebookEntryId = pbe.Id;
        allOpportunityLineItem.add(oppline);
        
        OpportunityLineItem oppline1 = new OpportunityLineItem();
        oppline1.OpportunityId = allOppList[0].Id;
        oppline1.Product2Id = prod.Id; 
        oppline1.Quantity = 5;
        oppline1.UnitPrice = 100.00;
        oppline1.PricebookEntryId = pbe.Id;
        allOpportunityLineItem.add(oppline1); 
        
        OpportunityLineItem oppline2 = new OpportunityLineItem();
        oppline2.OpportunityId = allOppList[0].Id;
        oppline2.Product2Id = prod.Id; 
        oppline2.Quantity = 5;
        oppline2.UnitPrice = 100.00;
        oppline2.PricebookEntryId = pbe.Id;
        allOpportunityLineItem.add(oppline2);

        OpportunityLineItem oppline3 = new OpportunityLineItem();
        oppline3.OpportunityId = allOppList[0].Id;
        oppline3.Product2Id = prod.Id; 
        oppline3.Quantity = 5;
        oppline3.UnitPrice = 100.00;
        oppline3.PricebookEntryId = pbe.Id;
        allOpportunityLineItem.add(oppline3);

				insert allOpportunityLineItem;
				
        system.debug('QWER2 : '+oppline);

        Id bankId = Schema.SObjectType.ASPHPP__ASPayment_Source__c.getRecordTypeInfosByName().get('Bank Account').getRecordTypeId();
        
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
				
				List<ASPHPP__Subscription__c> allPPSubscription = new List<ASPHPP__Subscription__c>();
        ASPHPP__Subscription__c psub = new ASPHPP__Subscription__c();
        psub.Name = 'testSubscription 1';
        psub.ASPHPP__Amount__c = 100;
        psub.ASPHPP__Frequency__c = 'Quarterly';
        psub.ASPHPP__Payment_Source__c = source.Id;
        psub.ASPHPP__Gateway__c = gateway.Id;
        psub.AS_opportunity__c = allOppList[0].Id;
        psub.ASPHPP__Contact__c = con.Id;
        allPPSubscription.add(psub);
        
        
        ASPHPP__Subscription__c psub2 = new ASPHPP__Subscription__c();
        psub2.Name = 'testSubscription 2';
        psub2.ASPHPP__Amount__c = 100;
        psub2.ASPHPP__Frequency__c = 'Quarterly';
        psub2.ASPHPP__Payment_Source__c = source.Id;
        psub2.ASPHPP__Gateway__c = gateway.Id;
        psub2.AS_opportunity__c = allOppList[1].Id;
        psub2.ASPHPP__Contact__c = con.Id;
        allPPSubscription.add(psub2);
        
        insert allPPSubscription;
        /*
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
       
    		System.runAs (thisUser) {
	        AS_Subscription__c newSubscription      =   new AS_Subscription__c();
	        newSubscription.AS_Auto_Renew__c        =   true;
	        newSubscription.AS_Frequency__c         =   1;
	        newSubscription.AS_Start_Date__c        =   Date.today();
	        newSubscription.AS_End_Date__c          =   Date.today().addDays(365);
	        newSubscription.AS_Type__c              =   'Member';
	        newSubscription.AS_Payment_Source__c    =   source.Id;
	        newSubscription.AS_Membership_Span__c   =   1;
	        newSubscription.AS_Price_Book__c        =   prBook.Id;
	        newSubscription.Account__c              =   acc.Id;
	        newSubscription.AS_Membership_Status__c =   'Pending';//Jan 9
	        newSubscription.AS_Product__c           =  prod.Id;
	        newSubscription.AS_Membership_Renewal_Date__c = Date.today();
	        newSubscription.AS_Type__c = 'Member';
	        newSubscription.AS_Membership_Status__c = 'Current';
	    //    newSubscription.AS_Opportunity__c = opp.Id;
	        insert newSubscription;
    		}
        */
		}
    
    
}