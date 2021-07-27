@isTest
public class AS_membershipSignUp_test {
    
     static testMethod void Test1() { 
        
        Account acc = new Account();
        acc.lastName = 'Test Name';
        acc.Firstname = 'Name';
        insert acc;
        
         
        //get standard pricebook
        Id  standardPb = Test.getStandardPricebookId(); 
        
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1',productCode = 'ABC', isActive = true);
        insert prd1;
        
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb,UnitPrice=50, isActive=true);
        insert pbe1;
        
        
        Opportunity opp1 = new Opportunity (Name='Opp1',StageName='Stage 0 - Lead Handed Off',CloseDate=Date.today(),Pricebook2Id = pbe1.Pricebook2Id, AccountId = acc.id);
        insert opp1;
        
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp1.id,PriceBookEntryID=pbe1.id, quantity=4, totalprice=200);
        insert lineItem1; 
        
        
       //MembershipSignUp
       
        PageReference pageRef = Page.MembershipSignUp;
        Test.setCurrentPage(pageRef);
        AS_MembershipSignUp testCtrl = new AS_MembershipSignUp();
        testCtrl.getOID();
        testCtrl.theFileHander = Blob.valueOf('Test Data');
        testCtrl.theFileName = 'Sample';
        //testCtrl.theOppId = opp1.Id;
      //  testCtrl.upload();
        
    
        /*Blob b = Blob.valueOf('Test Data');
        
        Attachment attachment = new Attachment();
        attachment.ParentId = opp1.Id;
        attachment.Name = 'Test Attachment for Parent';
        attachment.Body = b;
        
        insert attachment;*/
        
        //AS_MembershipSignUp ms = new AS_MembershipSignUp();

     }
     
     static testMethod void memberSignUpStudent() {
     	User finalUser = [Select Id,Name from User where lastName = 'johnmongrel' LIMIT 1];
	   	System.runAs(finalUser) {
	    	Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
	    	
	    	Account acc = new Account();
		   	acc.FirstName = 'John Hope';
		   	Acc.LastName = 'Ondona';
		   	acc.recordTypeId = personAccRecId;
		   	acc.PersonEmail = 'test@test.com';
		   	insert acc;
		   	
		   	Product2 prod = new Product2();
		    prod.Name  = 'student';
		    prod.isActive = true;
		   	insert prod;
		   
		   	Opportunity opp = new Opportunity();
		   	opp.Name = 'john hope test opp';
		   	opp.CloseDate = date.newInstance(2018, 3, 15);
		   	opp.StageName = 'Qualification';
		   	opp.AccountId = acc.Id;
		   	opp.AS_Product__c = prod.Id;
		   	insert opp;
		   	
		   	AS_membershipSignUp.checkIfStudent(String.valueOf(opp.Id));
     	}
     	
    	
    }
    
    static testMethod void getSalesforceBaseUrl() {
    	AS_membershipSignUp.getSalesforceBaseUrl();
    }
    
    static testMethod void myTestMethodForFlow() {
      User finalUser = [Select Id,Name from User where lastName = 'johnmongrel' LIMIT 1];
	   	System.runAs(finalUser) {
	    	Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
	    	
	    	Account acc = new Account();
		   	acc.FirstName = 'John Hope';
		   	Acc.LastName = 'Ondona';
		   	acc.recordTypeId = personAccRecId;
		   	acc.PersonEmail = 'test@test.com';
		   	insert acc;
		   	
		   	Product2 prod = new Product2();
		    prod.Name  = 'student';
		    prod.isActive = true;
		   	insert prod;
		   
		   	Opportunity opp = new Opportunity();
		   	opp.Name = 'john hope test opp';
		   	opp.CloseDate = date.newInstance(2018, 3, 15);
		   	opp.StageName = 'Qualification';
		   	opp.AccountId = acc.Id;
		   	opp.AS_Product__c = prod.Id;
		   	insert opp;
		   	/*
		   	Map<String, Object> inputs = new Map<String, Object>();
			  inputs.put('AccountID', acc.Id);
			  inputs.put('opportunityid', opp.Id);
			  */
			  AS_membershipSignUp sign = new AS_membershipSignUp();
			 // sign.myFlow = new Flow.Interview.PSA_Membership_Sign_Up(inputs);
			  
			  PageReference pageRef = Page.MembershipSignUp;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('acctestid', String.valueOf(acc.Id));
        pageRef.getParameters().put('opptestid', String.valueOf(opp.Id));
        
        sign.theFileHander = Blob.valueOf('testing');
        sign.upload();
        
        sign.getOID();
     	}
        
    }
    
    @TestSetup  
    static void createUser() {
    	
    
	    // Create a unique UserName
	    String uniqueUserName = 'memberuser2' + DateTime.now().getTime() + '@testorg.com';
	    // This code runs as the system user
	    Profile p = [SELECT Id FROM Profile WHERE Name='Membership Sign Up Profile'];
	    
	    User use = new User(Alias = 'standt', Email='memberuser@testorg.com',
	    EmailEncodingKey='UTF-8', LastName='johnmongrel', LanguageLocaleKey='en_US',
	    LocaleSidKey='en_US', ProfileId = p.Id,
	    TimeZoneSidKey='America/Los_Angeles',
	    isActive = true,
	    UserName=uniqueUserName);
	    insert use;
	    
	    System.runAs(use) {
	    	Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
	    	Account acc = new Account();
		    acc.LastName = 'membership sign up site guest user';
		    acc.recordTypeId = personAccRecId;
		    acc.PersonEmail = 'memberuser@testorg.com';
		    insert acc;
	    }	   
    	 
	    System.AssertEquals(database.countquery('SELECT '
	                                                    + 'COUNT()'
	                                            +' FROM'
	                                                +' Account '
	                                        ),1
	                            ); 
    }
}