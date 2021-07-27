@isTest
public with sharing class DL_Fax_Test {


    @TestSetup
    @future()
    static void makeData(){

        List<Account> accts = new List<Account>();

        for(Integer i=0; i < 20; i++){
            ID profile_ID = [SELECT ID from Profile WHERE Name = 'Non Member Login User'].id;
        
            Account testAccount = new Account();
            testAccount.FirstName = 'Adam';
            testAccount.LastName = 'Baker';
            testAccount.recordTypeId = [SELECT ID FROM RecordType WHERE Name = 'Person Account'].id;
            testAccount.PersonEmail = 'Adam.Baker'+i+'@psa.org.au';
            testAccount.BillingPostalCode = String.valueof(2600+i);
            testAccount.Fax = '(02)61711-111 111';
            testAccount.PersonHasOptedOutOfFax = false;
            
            accts.add(testAccount);
        }
        
        insert accts;
    }


    @isTest
    static void testPostCodeFax(){

        try{
            Test.setMock(HttpCalloutMock.class, new DL_WebServiceMock(false,1));

            List<String> onePostCode = DL_Fax.getFaxNumbers('2600');
            List<String> postCodeRange = DL_Fax.getFaxNumbers('2600-2900');
            List<String> postCodeGroup = DL_Fax.getFaxNumbers('2600,2602,2605');
            List<String> postCodeError1 = DL_Fax.getFaxNumbers('2600,2602-2605');
            List<String> postCodeError2 = DL_Fax.getFaxNumbers('2600-260');

            String fileName = 'Test.pdf';
            String base64Data = 'TESTDATA';
            String costCode = '6323-23-2334';

            test.startTest();

                DL_Fax.sendFaxProxy(onePostCode, fileName, base64Data, costCode);
                DL_Fax.sendFaxProxy(postCodeRange, fileName, base64Data, costCode);
                DL_Fax.sendFaxProxy(postCodeGroup, fileName, base64Data, costCode);
                DL_Fax.sendFaxProxy(postCodeError1, fileName, base64Data, costCode);
                DL_Fax.sendFaxProxy(postCodeError2, fileName, base64Data, costCode);

            test.stopTest();

            List<Fax__c> faxes = [SELECT ID,Name,Document_Name__c FROM Fax__c WHERE Status__c = null OR Status__c = ''];
            System.debug('faxes: '+ faxes);

            System.assert(faxes.size() > 0);
        }

        catch(Exception e){
            System.debug(e.getMessage());
        }
    }


    @isTest
    static void testStateFax(){

        try{
            Test.setMock(HttpCalloutMock.class, new DL_WebServiceMock(false,1));

            List<String> statesFaxList = DL_Fax.getFaxNumbers('ACT_NSW_VIC');

            String fileName = 'Test1.pdf';
            String base64Data = 'TESTDATA';
            String costCode = '6323-23-2334';

            test.startTest();

                DL_Fax.sendFaxProxy(statesFaxList, fileName, base64Data, costCode);

            test.stopTest();

            List<Fax__c> faxes = [SELECT ID,Name,Document_Name__c FROM Fax__c WHERE Document_Name__c = :fileName];
            System.debug('faxes: '+ faxes);

        }

        catch(Exception e){
            System.debug(e.getMessage());
        }
    }


    
    @isTest
    static void TestBulkFax1(){
        try{
            String fileName = 'Test.pdf';
            String base64Data = 'TESTDATA';
            String costCode = '6323-23-2334';

            Datetime executeTime = System.now().addMinutes(1); 
            String cronExpression = GetCRONExpression(executeTime);
            DL_Fax_Update updateFaxJob = new DL_Fax_Update();

            Test.setMock(HttpCalloutMock.class, new DL_WebServiceMock(false,1));
            
            List<String> numbers = new List<String>();
            List<string> ids = new List<String>();
            
            for(Integer i=0; i < 1005; i++ ){
                numbers.add(String.valueOf(i));
            }

            test.startTest();
                DL_Fax.sendFaxProxy(numbers, fileName, base64Data, costCode);
            test.stopTest();

            DL_Fax.faxStatusProxy(numbers);
            
            List<Fax__c> faxes = [SELECT ID,Name,Document_Name__c FROM Fax__c WHERE Status__c = null OR Status__c = ''];
            System.debug('faxes: '+ faxes);

            System.assert(faxes.size() > 0);
        }

        catch(Exception e){
            System.debug(e.getMessage());
        }
    }


    @isTest
    static void TestBulkFax2(){
        try{
            String fileName = 'Test.pdf';
            String base64Data = 'TESTDATA';
            String costCode = '6323-23-2334';

            Datetime executeTime = System.now().addMinutes(1); 
            String cronExpression = GetCRONExpression(executeTime);
            DL_Fax_Update updateFaxJob = new DL_Fax_Update();

            Test.setMock(HttpCalloutMock.class, new DL_WebServiceMock(false,2));
            
            List<String> numbers = new List<String>();
            
            for(Integer i=0; i < 2005; i++ ){
                numbers.add(String.valueOf(i));
            }

            DL_Fax.sendFaxProxy(numbers, fileName, base64Data, costCode);

            Test.startTest();
                DL_Fax.faxStatusProxy(numbers);
            Test.stopTest();
            
            List<Fax__c> faxes = [SELECT ID,Name,Document_Name__c FROM Fax__c WHERE Status__c = null OR Status__c = ''];
            System.debug('faxes: '+ faxes);

            System.assert(faxes.size() > 0);
        }

        catch(Exception e){
            System.debug(e.getMessage());
        }
    }


    @isTest
    static void TestBulkFax3(){
        try{
            String fileName = 'Test.pdf';
            String base64Data = 'TESTDATA';
            String costCode = '6323-23-2334';

            Datetime executeTime = System.now().addMinutes(1); 
            String cronExpression = GetCRONExpression(executeTime);
            DL_Fax_Update updateFaxJob = new DL_Fax_Update();

            Test.setMock(HttpCalloutMock.class, new DL_WebServiceMock(false,1));
            
            List<String> numbers = new List<String>();
            
            for(Integer i=0; i < 100; i++ ){
                numbers.add(String.valueOf(i));
            }

            DL_Fax.sendFaxProxy(numbers, fileName, base64Data, costCode);

            Test.startTest();
                DL_Fax.faxStatusProxy(numbers);
            Test.stopTest();
            
            List<Fax__c> faxes = [SELECT ID,Name,Document_Name__c FROM Fax__c WHERE Status__c = null OR Status__c = ''];
            System.debug('faxes: '+ faxes);

            System.assert(faxes.size() > 0);
        }

        catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    


    @isTest
    Static void testUpdate(){

        try{
            Test.setMock(HttpCalloutMock.class, new DL_WebServiceMock(false,1));

            Test.startTest();
                String cron = '0 0 23 * * ?';
                DL_Fax_Update dl_fax_upate = new DL_Fax_Update();
                System.schedule('Update Fax Status Test', cron, dl_fax_upate);
            Test.stopTest();
        }

        catch(Exception e){
            System.debug(e.getMessage());
        }
    }



    @isTest
    Static void testCalloutException(){

        String fileName = 'Test.pdf';
        String base64Data = 'TESTDATA';
        String costCode = '6323-23-2334';

        Datetime executeTime = System.now().addMinutes(1); 
        String cronExpression = GetCRONExpression(executeTime);
        DL_Fax_Update updateFaxJob = new DL_Fax_Update();

        Test.setMock(HttpCalloutMock.class, new DL_WebServiceMock(true, 2)); //throw exception
        
        List<String> numbers = new List<String>();
        
        for(Integer i=0; i < 2005; i++ ){
            numbers.add(String.valueOf(i));
        }

        try{
            DL_Fax.sendFaxProxy(numbers, fileName, base64Data, costCode);

            Test.startTest();
                DL_Fax.faxStatusProxy(numbers);
            Test.stopTest();  
        }

        catch(Exception e){

        }

        List<Fax__c> faxes = [SELECT ID,Name,Document_Name__c FROM Fax__c WHERE Status__c = null OR Status__c = ''];
        System.debug('faxes: '+ faxes);

        System.assert(faxes.size() == 0);
    }



    @isTest
    Static void testUnsavedFaxProxy(){
        try{
            String fileName = 'Test.pdf';
            String base64Data = 'TESTDATA';
            String costCode = '6323-23-2334';

            Datetime executeTime = System.now().addMinutes(1); 
            String cronExpression = GetCRONExpression(executeTime);
            DL_Fax_Update updateFaxJob = new DL_Fax_Update();
            
            List<String> numbers = new List<String>();
            
            for(Integer i=0; i < 2005; i++ ){
                numbers.add(String.valueOf(i));
            }

            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new DL_WebServiceMock(false,1));
                DL_Fax.sendFaxProxy(numbers, fileName, base64Data, costCode);
                Test.setMock(HttpCalloutMock.class, new DL_WebServiceMock(false,3));
                DL_Fax.getUnsavedFaxDetails();
            Test.stopTest();
        }

        catch(Exception e){
            System.debug(e.getMessage());
        }

    }



    private static String GetCRONExpression(Datetime dt) {
        return ('' + dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year());
    }

}