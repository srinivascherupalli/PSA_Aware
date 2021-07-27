/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class AsUserTriggerHandlerTest {
		
    static testMethod void isInsert() {
    	
    	// create a non member user
    	Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
	    Account acc = new Account();
	    acc.FirstName = 'AlphaSys';
	    acc.LastName = 'Stark';
	    acc.recordTypeId = personAccRecId;
	    acc.PersonEmail = 'nonmemberuser@testorg.com';
	    insert acc;
	
	    // Create a unique UserName
	    String uniqueUserName = 'nonmemberuser2' + DateTime.now().getTime() + '@testorg.com';
	    // This code runs as the system user
	    Profile p = [SELECT Id FROM Profile WHERE Name='Non Member Login User'];
	    Account acc1 = [SELECT Id,PersonContactId FROM Account WHERE Id =:acc.Id];
	    
	    User use = new User(Alias = 'standt', Email='memberuser@testorg.com',
	    EmailEncodingKey='UTF-8', LastName='stark', LanguageLocaleKey='en_US',
	    LocaleSidKey='en_US', ProfileId = p.Id,
	    ContactId = acc1.PersonContactId,
	    TimeZoneSidKey='America/Los_Angeles',
	    isActive = true,
	    UserName=uniqueUserName);
	    insert use;
	    
	     
	    System.AssertEquals(database.countquery('SELECT '
	                                                    + 'COUNT()'
	                                            +' FROM'
	                                                +' Account '
	                                        ),2
	                            ); 
	                            
    }
    
    static testMethod void isUpdate() {
    Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
    User u = new User(Alias = 'standt', Email='useTriStandardUser@testorg.com', 
    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
    LocaleSidKey='en_US', ProfileId = p.Id, 
    TimeZoneSidKey='America/Los_Angeles', UserName='useTriStandardUser@testorg.com');

    System.runAs(u) {
        User finalUser = [Select Id,Name from User where lastName = 'johnmongrel' LIMIT 1];
        User useUpdate = new User(Id = finalUser.Id, firstName='standU');
        update useUpdate;
    }
    
    System.AssertEquals(database.countquery('SELECT '
                                                        + 'COUNT()'
                                                +' FROM'
                                                    +' User '
                                                + 'WHERE '
                                                    + 'firstName = \'standU\''
                                            ),1
                                ); 
        
    }
    
     @TestSetup  
    static void createUser() {
    	
        Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account();
		    acc.FirstName = 'AlphaSys';
		    acc.LastName = 'UserAccount12345';
		    acc.recordTypeId = personAccRecId;
		    acc.PersonEmail = 'memberuser@testorg.com';
		    insert acc;
    
		    // Create a unique UserName
		String uniqueUserName = 'memberuser2' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Member Login User'];
        Account acc1 = [SELECT Id,PersonContactId FROM Account WHERE Id =:acc.Id];
        
        User use = new User(Alias = 'standt', Email='memberuser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='johnmongrel', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        ContactId = acc1.PersonContactId,
        TimeZoneSidKey='America/Los_Angeles',
        isActive = true,
        UserName=uniqueUserName);
        insert use;
        
        
        System.AssertEquals(database.countquery('SELECT '
                                                        + 'COUNT()'
                                                +' FROM'
                                                    +' Account '
                                            ),1
                                ); 
                                
    }
    
}