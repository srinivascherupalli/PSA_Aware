@isTest
public with sharing class DL_PaymentSource_Test {
    public @IsTest
    static void TestDeactivate(){

        System.runAs( testCreateAdminUser() ) {
            Membership_End_Date_Renewal__c setting = new Membership_End_Date_Renewal__c();
            setting.Name = 'Test Setting';
            setting.T8__c = 30;
            insert setting;
        
            Id ccRecordTypeId = Schema.SObjectType.ASPHPP__ASPayment_Source__c.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        
            Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            
            Account acc = new Account();
            acc.FirstName = 'Dan';
            Acc.LastName = 'Test';
            acc.recordTypeId = personAccRecId;
            acc.PersonEmail = 'test@test.com';
            insert acc; 

            Contact con = new Contact();
            con.FirstName = 'Dan';
            con.LastName = 'Test';
            con.Email = 'test@test.com';
            insert con;
            
            ASPHPP__ASPayment_Source__c paySource = new ASPHPP__ASPayment_Source__c();
            paySource.recordTypeId = ccRecordTypeId;
            paySource.ASPHPP__Account__c = acc.Id;   // account
            paySource.ASPHPP__Card_Name__c = 'test';    // card name
            paySource.ASPHPP__Credit_Card_Type__c =  'VISA';    // card type
            paySource.ASPHPP__Card_CCV__c = '123';  // ccv
            paySource.ASPHPP__Card_Number__c =  '111111111111111';   // card number
            paySource.ASPHPP__Card_Expiry_Month__c =  '01';   // card number
            paySource.ASPHPP__Card_Expiry_Year__c = '2020';  // expiry month 
            upsert paySource;
            
            
            Opportunity opp = new Opportunity();
            opp.Name = 'Dan test opp';
            opp.CloseDate = date.newInstance(2018, 3, 15);
            opp.StageName = 'Closed won';
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
            newSubscription.AS_Auto_Renew__c        =   true;
            newSubscription.AS_Frequency__c         =   1;
            newSubscription.AS_Start_Date__c        =   Date.today().addDays(-365);
            newSubscription.AS_End_Date__c 			=   Date.today().addDays(-1*(Integer.valueOf(setting.T8__c)));
            newSubscription.AS_Type__c              =   'Member';
            newSubscription.AS_Payment_Source__c    =   paySource.Id;
            newSubscription.AS_Membership_Span__c   =   1;
            newSubscription.AS_Price_Book__c        =   prBook.Id;
            newSubscription.Account__c              =   acc.Id;
            newSubscription.AS_Membership_Status__c =   'Pending';//Jan 9
            newSubscription.AS_Product__c           =  prod.Id;
            newSubscription.AS_Membership_Renewal_Date__c = Date.today();
            newSubscription.AS_Type__c = 'Member';
            newSubscription.AS_Membership_Status__c = 'Grace Period';
            newSubscription.AS_Opportunity__c = opp.Id;
            insert newSubscription;

            Order ordr = new Order();
            ordr.OpportunityId = opp.Id;
            ordr.AccountId = acc.Id;
            ordr.Pricebook2Id = prBook.Id;
            ordr.EffectiveDate = opp.CloseDate;
            //ordr.AS_extId__c = AS_commonFunction.generateRandomString(40);
            ordr.Status = 'DRAFT';
            insert ordr;

            OrderItem ordrItem = new OrderItem();
            ordrItem.PricebookEntryId = oppLineItem.PricebookEntryId;
            ordrItem.OrderId = ordr.Id;
            ordrItem.UnitPrice = 100;
            ordrItem.Quantity = 5;
            insert ordrItem;

            ASPHPP__ASGateway__c gateway = new ASPHPP__ASGateway__c();
            gateway.Name = 'Sample Gateway';
            gateway.ASPHPP__Digital_Token_Key__c = 'ABCDEGHIJKLMNOPQRSTUVXYZ123456E4B1';
            insert gateway;

            ASPHPP__PPSettings__c ppSettings = new ASPHPP__PPSettings__c ();
            ppSettings.ASPHPP__Gateway_ID__c = gateway.Id;

            Id idBankAcc = Schema.SObjectType.ASPHPP__Payment__c.getRecordTypeInfosByName().get('Bank Account').getRecordTypeId();

            ASPHPP__Payment__c pPayment = new ASPHPP__Payment__c();
            pPayment.RecordTypeId = idBankAcc;
            pPayment.Name = 'mPayment';
            pPayment.ASPHPP__Amount__c = 200;
            pPayment.ASPHPP__Account__c = ordr.AccountId;
            pPayment.AS_Order__c = ordr.Id;
            pPayment.ASPHPP__Opportunity__c = opp.Id;
            pPayment.ASPHPP__Process_Payment__c = 'Manual Payment';
            pPayment.ASPHPP__Payment_Source__c = paySource.Id;
            pPayment.ASPHPP__Payment_Status__c = 'Failed';
            insert pPayment;
            
            Test.startTest(); 
                DL_PaymentSource.deactivatePaymentSource(String.valueOf(paySource.Id));
                DL_PaymentSource.recoverFailedPayments(String.valueOf(paySource.Id));
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