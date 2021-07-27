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
private class AS_updateAccountPrimaryContactTest {
		// commented out since AS_updateAccountPrimaryContact trigger is set to inactive
		/*
    static testMethod void updateAccountPrimaryContactTrigger() {
        // TO DO: implement unit test
        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        
        Account acc = new Account();
        acc.RecordTypeId = personAccountId;
        acc.Name= 'test update primary';
        insert acc;
		
		List<Contact> allContact = new List<Contact>();
		
        Contact con1 = new Contact();
        con1.FirstName = 'john';
        con1.LastName = 'Hope';
        con1.Email = 'test@test.com';
        con1.AccountID = acc.Id;
        allContact.add(con1);
        
        Contact con2 = new Contact();
        con2.FirstName = 'john';
        con2.LastName = 'Hope';
        con2.Email = 'test@test.com';
        con2.Primary_Contact__c = true;
        con2.AccountID = acc.Id;
        allContact.add(con2);
        
        insert allContact;
        
        AS_commonFunction.runupdateAccount = false;
        
        Contact con3 = new Contact();
        con3.Id = allContact[0].Id;
        con2.Primary_Contact__c = true;
        allContact.add(con1);
        
    }
    */
}