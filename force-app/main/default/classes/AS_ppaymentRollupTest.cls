/*
* Author: John Hope 
* Created: Last 2017
* Last Updated Date: March 2020
* Last Update by: Danryl T. Carpio
* Description: Test class for payment roll up trigger
*/

@isTest
private class AS_ppaymentRollupTest {
    
    @isTest static void test_payment() {

        System.runAs( testCreateAdminUser() ) {

        Test.startTest();

        
        Id idOppMembership = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();
        Id idSubscription = Schema.SObjectType.AS_Subscription__c.getRecordTypeInfosByName().get('Membership').getRecordTypeId();

        Id stdPriceBookRecId = Test.getStandardPricebookId();

        //AS_commonFunction commonFunction = new AS_commonFunction();

        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        Account acc = new Account();
        acc.RecordTypeId = personAccountId;
        acc.FirstName = 'mFirst';
        acc.LastName = 'mLast';
        acc.PersonEmail = 'm@m.com';
        acc.AS_Graduation_Year__pc = '2010';
        insert acc;
        System.debug('Account Id  =====>>>  '+acc.Id);

        Contact con = new Contact();
        con.FirstName = 'john';
        con.LastName = 'Hope';
        con.Email = 'test@test.com';
        insert con;
        System.debug('Contact Id  =====>>>  '+con.Id);

        Pricebook2 prBook = new Pricebook2();
        prBook.Name = 'standard pricebook';
        prBook.AS_Frequency__c = 12;
        insert prBook;
        System.debug('pricebook Id  =====>>>  '+prBook.Id);

        Membership_Type__c mmbrshipType = new Membership_Type__c();
        mmbrshipType.Name = 'Student Members';
        insert mmbrshipType;
        System.debug('Membership Id  =====>>>  '+acc.Id);

        Product2 prod = new Product2();
        prod.Name  = 'Product1';
        prod.isActive = true;
        prod.AS_Membership_Type__c = mmbrshipType.Id; 
        insert prod;
        System.debug('Product Id  =====>>>  '+prod.Id);

        Product2 prodx = new Product2();
        prodx.Name  = 'Student Members';
        prodx.isActive = true;
        prodx.AS_Parent_Product__c = prod.Id; 
        insert prodx;
        System.debug('Product2 Id  =====>>>  '+prodx.Id);

        system.debug('ASDF : '+prodx);

        Opportunity opp = new Opportunity();
        opp.Name = 'sample opportunity 2';
        opp.StageName = 'Prospecting';
        opp.CloseDate  = date.newinstance(2020, 12, 30);
        opp.RecordTypeId = idOppMembership;
        opp.Pricebook2Id = prBook.Id;
        opp.AS_Create_Subscription__c = false;
        opp.AccountId = acc.Id;
        opp.AS_Product__c = prod.Id;
        opp.AS_extId__c  = AS_commonFunction.generateRandomString(40);
        insert opp;
        system.debug('QWER1 : '+opp.Id);
        System.debug('Opportunity Id  =====>>>  '+opp.Id);

        PricebookEntry pbe2 = new PricebookEntry();
        pbe2.Product2Id = prod.Id;
        pbe2.Pricebook2Id = stdPriceBookRecId;
        pbe2.UnitPrice = 100;
        pbe2.isActive=true;
        insert pbe2;
        System.debug('PricebookEntry Id  =====>>>  '+pbe2.Id);

        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = prod.Id;
        pbe.Pricebook2Id = prBook.Id;
        pbe.UnitPrice = 100;
        pbe.isActive=true;
        insert pbe;
        System.debug('PricebookEntry Id  =====>>>  '+pbe.Id);

        OpportunityLineItem oppline = new OpportunityLineItem();
        oppline.OpportunityId = opp.Id;
        oppline.Product2Id = prod.Id; 
        oppline.Quantity = 5;
        oppline.UnitPrice = 100.00;
        oppline.PricebookEntryId = pbe.Id;
        insert oppline;
        System.debug('OpportunityLineItem Id  =====>>>  '+oppline.Id);

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
        System.debug('ASPHPP__ASPayment_Source__c Id  =====>>>  '+source.Id);

        ASPHPP__ASGateway__c gateway = new ASPHPP__ASGateway__c();
        gateway.Name = 'Sample Gateway';
        gateway.ASPHPP__Digital_Token_Key__c = 'ABCDEGHIJKLMNOPQRSTUVXYZ123456E4B1';
        insert gateway;

        ASPHPP__PPSettings__c ppSettings = new ASPHPP__PPSettings__c ();
        ppSettings.ASPHPP__Gateway_ID__c = gateway.Id;

        ASPHPP__Subscription__c psub = new ASPHPP__Subscription__c();
        psub.Name = 'mTest';
        psub.ASPHPP__Amount__c = 100;
        psub.ASPHPP__Frequency__c = 'Quarterly';
        psub.ASPHPP__Payment_Source__c = source.Id;
        psub.ASPHPP__Gateway__c = gateway.Id;
        psub.AS_opportunity__c = opp.Id;
        psub.ASPHPP__Contact__c = con.Id;
        insert psub;
  
        Order ordr = new Order();
        ordr.OpportunityId = opp.Id;
        ordr.AccountId = acc.Id;
        ordr.Pricebook2Id = prBook.Id;
        ordr.EffectiveDate = opp.CloseDate;
        //ordr.AS_extId__c = AS_commonFunction.generateRandomString(40);
        ordr.Status = 'DRAFT';
        insert ordr;

        OrderItem ordrItem = new OrderItem();
        ordrItem.PricebookEntryId = oppline.PricebookEntryId;
        ordrItem.OrderId = ordr.Id;
        ordrItem.UnitPrice = 100;
        ordrItem.Quantity = 5;
        insert ordrItem;
        
        Id idBankAcc = Schema.SObjectType.ASPHPP__Payment__c.getRecordTypeInfosByName().get('Bank Account').getRecordTypeId();

        ASPHPP__Payment__c pPayment = new ASPHPP__Payment__c();
        pPayment.RecordTypeId = idBankAcc;
        pPayment.Name = 'mPayment';
        pPayment.ASPHPP__Amount__c = 200;
        pPayment.ASPHPP__Account__c = ordr.AccountId;
        pPayment.AS_Order__c = ordr.Id;
        pPayment.ASPHPP__PSubscription__c = psub.Id;
        pPayment.ASPHPP__Opportunity__c = opp.Id;
        pPayment.ASPHPP__Process_Payment__c = 'Manual Payment';
        pPayment.ASPHPP__Payment_Source__c = source.Id;
        pPayment.ASPHPP__Payment_Status__c = 'Success';
        insert pPayment;

        // Opportunity updateOpp = new Opportunity(
        //     Id = opp.Id,
        //     StageName = 'Closed Won'
        // );
        // update updateOpp;
       
        Test.stopTest();

        }
    }

    private static User testCreateAdminUser() {
        
        String orgId = UserInfo.getOrganizationId();
    	String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
    	Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
    	String uniqueName = orgId + dateString + randomInt;
     
        UserRole adminrole = new UserRole( DeveloperName = 'TestClassRole123333', Name = 'TestClassRole123333');
		insert adminrole;
        
        Profile adminprofile = [SELECT Id,name from Profile WHERE Name = 'System Administrator' LIMIT 1];
        User adminuser = new User(Alias = 'standt', 
                                  Email='admin213@testorg.com', 
                                  UserRoleId = adminrole.Id, 
                                  EmailEncodingKey='UTF-8',
                                  LastName='Testing', 
                                  LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US',
                                  ProfileId = adminprofile.Id, 
                                  TimeZoneSidKey='America/Los_Angeles', 
                                  UserName= uniqueName + '@test' + orgId + '.org');
        
        insert adminuser; 
        return adminuser;
    }
}