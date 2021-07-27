/*
*Author : Michael Vincent Largo
*Description : Text here!!
*Date Created : 10/10/2019
*Last Modified By: Vincent
*/
@isTest
public class AsPaymentOptionControllerTest {
    
    @isTest 
    public static void AsTestMethod1() { 
        
        Id RecordTypeIdPerAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Id RecordTypeIdEnrollment = Schema.SObjectType.Enrolment_Form__c.getRecordTypeInfosByName().get('PSA Enrolment').getRecordTypeId();
        Id RecordTypeIdCoupon = Schema.SObjectType.AS_Coupon__c.getRecordTypeInfosByName().get('Amount').getRecordTypeId();
        Id pricebookId = Test.getStandardPricebookId();
        
        Account Accnt = new Account(
            RecordTypeID=RecordTypeIdPerAccount,
            FirstName='Test FName',
            LastName='Test LName',
            PersonMailingStreet='test@alphasys.com.au',
            PersonMailingPostalCode='12345',
            PersonMailingCity='SFO',
            PersonEmail='test@alphasys.com.au',
            PersonHomePhone='1234567',
            PersonMobilePhone='12345678',
            AS_Unique_Student_Identifier__c='01234'
        );
        
        insert Accnt;

        List<Profile> pro = [Select Id,Name from Profile where Name='Member Login User' LIMIT 1];
        
        System.debug('pro.Name  '+pro[0].Name);
        Account accToUsed = [Select Id,PersonContactId from Account where Id = :Accnt.Id limit 1];
        User indiUser = new User();
        indiUser.ContactId = accToUsed.PersonContactId;
        indiUser.ProfileId = (pro.size() > 0)?pro[0].Id:null;
        indiUser.FirstName = Accnt.FirstName;
        indiUser.LastName = Accnt.LastName;
        indiUser.Alias =string.valueof(Accnt.FirstName.substring(0,1) + Accnt.LastName.substring(0,2));
        indiUser.Email = 'person@test.com';
        indiUser.Username = 'person@test.com';
        indiUser.CommunityNickname = Accnt.FirstName + Accnt.LastName + AS_commonFunction.generateRandomIntString(2);
        indiUser.emailencodingkey='UTF-8';
        indiUser.languagelocalekey='en_US';
        indiUser.localesidkey='en_AU'; 
        indiUser.timezonesidkey='GMT';
        insert indiUser;

        System.runAs( indiUser ) {
            // The following code runs as user 'u' 
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
        }
        
        Pricebook2 AsPricebookEnt = new Pricebook2(
            Name = 'PSA Non-member',
            IsActive = true
        );
        insert AsPricebookEnt;
        
        Product2 prod = new Product2(
            Name = 'Laptop X200', 
            Family = 'Hardware',
            isActive=true
        );
        insert prod;
        
        List<PricebookEntry> AsPriBookEnt = new List<PricebookEntry>();
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, 
            Product2Id = prod.Id,
            UnitPrice = 10000, 
            IsActive = true
        );
        AsPriBookEnt.add( standardPrice ); 

        PricebookEntry elderPBE = new PricebookEntry(
            Pricebook2Id = AsPricebookEnt.Id,
            Product2Id = prod.Id,
            UnitPrice = 22,
            IsActive = true
        );
        
        AsPriBookEnt.add( elderPBE );
        insert AsPriBookEnt;
        
        Learning_Package__c AsLearning = new Learning_Package__c(
            Name = 'Test Learning Package',
            AS_product__c = prod.Id,
            AS_Funding_eligible__c = true
        );
        insert AsLearning;
        
        // Create Opportunity
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.CloseDate= System.Today();
        opp.StageName='Prospecting';
        opp.Amount = 1000;
        opp.AS_Product__c = prod.id; 
        insert opp;
        
        // Add product and Pricebook to the particular opportunity using OpportunityLineItem 
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.OpportunityId = opp.Id;
        oppLineItem.PricebookEntryId = AsPriBookEnt[1].Id;
        oppLineItem.UnitPrice = 7000;
        oppLineItem.Quantity = 5;
        insert oppLineItem;
        
        List<Enrolment_Form__c> AsEnrolList = new List<Enrolment_Form__c>();
        
        Enrolment_Form__c enrol = new Enrolment_Form__c(
            RecordTypeId= RecordTypeIdEnrollment,
            AS_Account__c = Accnt.Id,
            AS_Learning_Package__c = AsLearning.Id,
            AS_Preferred_Name__c='Test Enrolment',
            Enrolment_Status__c='In Progress',
            AS_Employment_Pharmacy_Name__c = 'alphasys pharmacy',
            AS_Email__c = 'Vincent@alphasys.com',
            AS_Employment_State__c = 'NSW',
            AS_Employment_Status__c = 'Full-time',
            Recent_Occupation__c = 'Labourers',
            Industry__c = 'Retail Trade',
            Funded_position__c = true,
            AS_Send_enrollment__c = true,
            AS_Send_enrollment_link__c = true,
            AS_Pending_notification_sent__c = false,
            AS_Enrollment_Last_Modify_Date__c = date.today(),
            AS_Expired_notification_sent__c = false,
            AS_Enrolment_Received_Sent__c = false,
            Opportunity__c = opp.Id
            
        );
        AsEnrolList.add( enrol );

        Enrolment_Form__c AsEnrol = new Enrolment_Form__c(
            RecordTypeId= RecordTypeIdEnrollment,
            AS_Account__c = Accnt.Id,
            AS_Learning_Package__c = AsLearning.Id,
            AS_Preferred_Name__c='Test Enrolment',
            Enrolment_Status__c='Draft',
            AS_Employment_Pharmacy_Name__c = 'alphasys pharmacy',
            AS_Email__c = 'Vincent@alphasys.com',
            AS_Employment_State__c = 'NSW',
            AS_Employment_Status__c = 'Full-time',
            Recent_Occupation__c = 'Labourers',
            Industry__c = 'Retail Trade',
            Funded_position__c = true,
            AS_Send_enrollment__c = true,
            AS_Send_enrollment_link__c = true,
            AS_Pending_notification_sent__c = false,
            AS_Enrollment_Last_Modify_Date__c = date.today(),
            AS_Expired_notification_sent__c = false,
            AS_Enrolment_Received_Sent__c = false,
            Opportunity__c = opp.Id
            
        );
        AsEnrolList.add( AsEnrol );

        insert AsEnrolList;

        String Vcode = 'Test';

        List<AS_Coupon__c> AsCouponList = new List<AS_Coupon__c>();

        AS_Coupon__c AsCoupon1 = new AS_Coupon__c(
             RecordTypeId= RecordTypeIdCoupon,
             AS_Product__c = prod.Id,
             AS_Discount_Amount__c = 10,
             AS_Code__c = Vcode,
             AS_Status__c = 'Active'

        );
        AsCouponList.add( AsCoupon1 );

        insert AsCouponList;


        AsPaymentOptionController.InitPaymentPage(Accnt.Id, AsEnrolList[0].Id);
        AsPaymentOptionController.deleteEnrolment(AsEnrolList[1].Id);
        AsPaymentOptionController.deleteEnrolment(AsEnrolList[0].Id);
        AsPaymentOptionController.createOppOnEnrolment(AsEnrolList[0].Id, Accnt.Id, pricebookId, 22);
        AsPaymentOptionController.updateEnrollment(AsEnrolList[0].Id, Accnt.Id);
        AsPaymentOptionController.updateEnrollmentToPending(AsEnrolList[0].Id, Accnt.Id);
        AsPaymentOptionController.updateEnrollmentToPendingPayment(AsEnrolList[0].Id, Accnt.Id);
        AsPaymentOptionController.updateEnrollmentToPendingAndCreateOpp(AsEnrolList[0].Id, Accnt.Id);
        AsPaymentOptionController.validateVoucherCode(Vcode, prod.Id);
        AsPaymentOptionController.createOppLineItems(AsEnrolList[0].Id, Accnt.Id, pricebookId, 22, Vcode);

        AsPaymentOptionController.PriceBookWrapper AsPbWrap = new AsPaymentOptionController.PriceBookWrapper();
        AsPbWrap.priceBookId = AsPricebookEnt.Id;
        AsPbWrap.priceBookName = AsPricebookEnt.Name;
        AsPbWrap.membership = AsPricebookEnt.Name;
        AsPbWrap.unitPrice = 20;
        AsPbWrap.isOnceOff = true;
        
    }

    public static void AsTestMethod2() { 
        
        Id RecordTypeIdPerAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Id RecordTypeIdEnrollment = Schema.SObjectType.Enrolment_Form__c.getRecordTypeInfosByName().get('PSA Enrolment').getRecordTypeId();
        Id RecordTypeIdCoupon = Schema.SObjectType.AS_Coupon__c.getRecordTypeInfosByName().get('Amount').getRecordTypeId();
        Id pricebookId = Test.getStandardPricebookId();
        
        Account Accnt = new Account(
            RecordTypeID=RecordTypeIdPerAccount,
            FirstName='Test FName',
            LastName='Test LName',
            PersonMailingStreet='test@alphasys.com.au',
            PersonMailingPostalCode='12345',
            PersonMailingCity='SFO',
            PersonEmail='test@alphasys.com.au',
            PersonHomePhone='1234567',
            PersonMobilePhone='12345678',
            AS_Unique_Student_Identifier__c='01234'
        );
        
        insert Accnt;

        List<Profile> pro = [Select Id,Name from Profile where Name='Member Login User' LIMIT 1];
        
        System.debug('pro.Name  '+pro[0].Name);
        Account accToUsed = [Select Id,PersonContactId from Account where Id = :Accnt.Id limit 1];
        User indiUser = new User();
        indiUser.ContactId = accToUsed.PersonContactId;
        indiUser.ProfileId = (pro.size() > 0)?pro[0].Id:null;
        indiUser.FirstName = Accnt.FirstName;
        indiUser.LastName = Accnt.LastName;
        indiUser.Alias =string.valueof(Accnt.FirstName.substring(0,1) + Accnt.LastName.substring(0,2));
        indiUser.Email = 'person@test.com';
        indiUser.Username = 'person@test.com';
        indiUser.CommunityNickname = Accnt.FirstName + Accnt.LastName + AS_commonFunction.generateRandomIntString(2);
        indiUser.emailencodingkey='UTF-8';
        indiUser.languagelocalekey='en_US';
        indiUser.localesidkey='en_AU'; 
        indiUser.timezonesidkey='GMT';
        insert indiUser;

        System.runAs( indiUser ) {
            // The following code runs as user 'u' 
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
        }
        
        Pricebook2 AsPricebookEnt = new Pricebook2(
            Name = '6 Month Pricebook',
            IsActive = true
        );
        insert AsPricebookEnt;
        
        Product2 prod = new Product2(
            Name = 'Laptop X200', 
            Family = 'Hardware',
            isActive=true
        );
        insert prod;
        
        List<PricebookEntry> AsPriBookEnt = new List<PricebookEntry>();
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, 
            Product2Id = prod.Id,
            UnitPrice = 10000, 
            IsActive = true
        );
        AsPriBookEnt.add( standardPrice ); 

        PricebookEntry elderPBE = new PricebookEntry(
            Pricebook2Id = AsPricebookEnt.Id,
            Product2Id = prod.Id,
            UnitPrice = 22,
            IsActive = true
        );
        
        AsPriBookEnt.add( elderPBE );
        insert AsPriBookEnt;
        
        Learning_Package__c AsLearning = new Learning_Package__c(
            Name = 'Test Learning Package',
            AS_product__c = prod.Id,
            AS_Funding_eligible__c = true
        );
        insert AsLearning;
        
        // Create Opportunity
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.CloseDate= System.Today();
        opp.StageName='Prospecting';
        opp.Amount = 1000;
        opp.AS_Product__c = prod.id; 
        insert opp;
        
        // Add product and Pricebook to the particular opportunity using OpportunityLineItem 
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.OpportunityId = opp.Id;
        oppLineItem.PricebookEntryId = AsPriBookEnt[1].Id;
        oppLineItem.UnitPrice = 7000;
        oppLineItem.Quantity = 5;
        insert oppLineItem;
        
        List<Enrolment_Form__c> AsEnrolList = new List<Enrolment_Form__c>();
        
        Enrolment_Form__c enrol = new Enrolment_Form__c(
            RecordTypeId= RecordTypeIdEnrollment,
            AS_Account__c = Accnt.Id,
            AS_Learning_Package__c = AsLearning.Id,
            AS_Preferred_Name__c='Test Enrolment',
            Enrolment_Status__c='In Progress',
            AS_Employment_Pharmacy_Name__c = 'alphasys pharmacy',
            AS_Email__c = 'Vincent@alphasys.com',
            AS_Employment_State__c = 'NSW',
            AS_Employment_Status__c = 'Full-time',
            Recent_Occupation__c = 'Labourers',
            Industry__c = 'Retail Trade',
            Funded_position__c = true,
            AS_Send_enrollment__c = true,
            AS_Send_enrollment_link__c = true,
            AS_Pending_notification_sent__c = false,
            AS_Enrollment_Last_Modify_Date__c = date.today(),
            AS_Expired_notification_sent__c = false,
            AS_Enrolment_Received_Sent__c = false,
            Opportunity__c = opp.Id
            
        );
        AsEnrolList.add( enrol );

        Enrolment_Form__c AsEnrol = new Enrolment_Form__c(
            RecordTypeId= RecordTypeIdEnrollment,
            AS_Account__c = Accnt.Id,
            AS_Learning_Package__c = AsLearning.Id,
            AS_Preferred_Name__c='Test Enrolment',
            Enrolment_Status__c='Draft',
            AS_Employment_Pharmacy_Name__c = 'alphasys pharmacy',
            AS_Email__c = 'Vincent@alphasys.com',
            AS_Employment_State__c = 'NSW',
            AS_Employment_Status__c = 'Full-time',
            Recent_Occupation__c = 'Labourers',
            Industry__c = 'Retail Trade',
            Funded_position__c = true,
            AS_Send_enrollment__c = true,
            AS_Send_enrollment_link__c = true,
            AS_Pending_notification_sent__c = false,
            AS_Enrollment_Last_Modify_Date__c = date.today(),
            AS_Expired_notification_sent__c = false,
            AS_Enrolment_Received_Sent__c = false,
            Opportunity__c = opp.Id
            
        );
        AsEnrolList.add( AsEnrol );

        insert AsEnrolList;

        String Vcode = 'Test';

        List<AS_Coupon__c> AsCouponList = new List<AS_Coupon__c>();

        AS_Coupon__c AsCoupon1 = new AS_Coupon__c(
             RecordTypeId= RecordTypeIdCoupon,
             AS_Product__c = prod.Id,
             AS_Discount_Amount__c = 10,
             AS_Code__c = Vcode,
             AS_Status__c = 'Active'

        );
        AsCouponList.add( AsCoupon1 );

        insert AsCouponList;


        AsPaymentOptionController.InitPaymentPage(Accnt.Id, AsEnrolList[0].Id);
        AsPaymentOptionController.deleteEnrolment(AsEnrolList[1].Id);
        AsPaymentOptionController.deleteEnrolment(AsEnrolList[0].Id);
        AsPaymentOptionController.createOppOnEnrolment(AsEnrolList[0].Id, Accnt.Id, pricebookId, 22);
        AsPaymentOptionController.updateEnrollment(AsEnrolList[0].Id, Accnt.Id);
        AsPaymentOptionController.updateEnrollmentToPending(AsEnrolList[0].Id, Accnt.Id);
        AsPaymentOptionController.updateEnrollmentToPendingPayment(AsEnrolList[0].Id, Accnt.Id);
        AsPaymentOptionController.updateEnrollmentToPendingAndCreateOpp(AsEnrolList[0].Id, Accnt.Id);
        AsPaymentOptionController.validateVoucherCode(Vcode, prod.Id);
        AsPaymentOptionController.createOppLineItems(AsEnrolList[0].Id, Accnt.Id, pricebookId, 22, Vcode);

        AsPaymentOptionController.PriceBookWrapper AsPbWrap = new AsPaymentOptionController.PriceBookWrapper();
        AsPbWrap.priceBookId = AsPricebookEnt.Id;
        AsPbWrap.priceBookName = AsPricebookEnt.Name;
        AsPbWrap.membership = AsPricebookEnt.Name;
        AsPbWrap.unitPrice = 20;
        AsPbWrap.isOnceOff = true;
        
    }

    
}