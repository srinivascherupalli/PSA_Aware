@isTest
private class AS_ppaymentAutoOppTest {
    
    @isTest static void test_method_one() { //AS_PPaymentAutoOpp.Trigger
        Contact con = new Contact();
        con.FirstName = 'john';
        con.LastName = 'Hope';
        con.Email = 'test@test.com';
        insert con;

        Opportunity opp = new Opportunity();
        opp.Name = 'sample opportunity 2';
        opp.StageName = 'Closed Won';
        opp.CloseDate  = date.newinstance(2020, 12, 30);
        insert opp;
        
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

        ASPHPP__Subscription__c psub = new ASPHPP__Subscription__c();
        psub.Name = 'mTest';
        psub.ASPHPP__Amount__c = 100;
        psub.ASPHPP__Frequency__c = 'Quarterly';
        psub.ASPHPP__Payment_Source__c = source.Id;
        psub.ASPHPP__Gateway__c = gateway.Id;
        psub.AS_opportunity__c = opp.Id;
        psub.ASPHPP__Contact__c = con.Id;
        insert psub;

        Id idCash = Schema.SObjectType.ASPHPP__Payment__c.getRecordTypeInfosByName().get('Cash').getRecordTypeId();

        ASPHPP__Payment__c pPayment = new ASPHPP__Payment__c();
        pPayment.RecordTypeId = idCash;
        pPayment.Name = 'mPayment';
        pPayment.ASPHPP__PSubscription__c = psub.Id;
        insert pPayment;

        ASPHPP__Payment__c pPayment2 = new ASPHPP__Payment__c();
        pPayment2.Id = pPayment.Id;
        pPayment.Name = 'mPayment2';
        update pPayment2;
    }

}