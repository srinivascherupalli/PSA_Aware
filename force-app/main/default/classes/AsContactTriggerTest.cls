/*Author : John Hope
*Description : This is a test class for Contact class.
*Date Created : 
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data : Contact.cls
 */
 @isTest
private class AsContactTriggerTest {
	
	static testMethod void isInsert() {
		Account acc = new Account(Name='AlphaSys');
		insert acc;
		Contact con = new Contact(LastName='Alphasys Contact',AccountId = acc.Id);
		insert con;
		
		// assertion
    System.AssertEquals(database.countquery('SELECT '
           																		+ 'COUNT()'
              															+' FROM'
              																+' Contact '
              															),2
              					); 
	}
    
	static testMethod void isUpdate() {
		Contact con = new Contact(LastName='Alphasys Contact');
		insert con;
		
		Contact conUpdate = new Contact(Id = con.Id, LastName='Alphasys Contact Final');
		update conUpdate;
		
		// assertion
    System.AssertEquals(database.countquery('SELECT '
           																		+ 'COUNT()'
              															+' FROM'
              																+' Contact '
              															),2
              					); 
	}

	static testMethod void isDelete() {
		Contact con = new Contact(LastName='Alphasys Contact');
		insert con;
		
		delete con;
		
		// assertion
    System.AssertEquals(database.countquery('SELECT '
           																		+ 'COUNT()'
              															+' FROM'
              																+' Contact '
              															),1
              					); 
	}
    
	static testMethod void isUndelete() {
		Contact con = new Contact(LastName='Alphasys Contact');
		insert con;
		
		delete con;
		
		Contact[] savedCon= [SELECT Id, Name FROM Contact WHERE Name = 'Alphasys Contact' ALL ROWS]; 
		try {
		    undelete savedCon;
		} catch (DmlException e) {
		    // Process exception here
		}
		
		// assertion
    System.AssertEquals(database.countquery('SELECT '
           																		+ 'COUNT()'
              															+' FROM'
              																+' Contact '
              															),2
              					); 
	}
	
	static testMethod void updateAccountPrimaryContactTest() {
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
   
   
	@TestSetup  
 	static void testData() {
 		Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
		Account acc = new Account();
    acc.FirstName = 'Alpha';
    acc.LastName = 'Sys';
    acc.recordTypeId = personAccRecId;
    acc.PersonEmail = 'bannegroupuser@testorg.com';
    acc.AS_Membership_Status__pc = 'Current';
    acc.AS_AHPRA_Number__pc = '123456789';
    insert acc;
 	}
 	
 	
 	static testMethod void createMemberMatch() {
		Contact newCon = new Contact();
		newCon.LastName = 'member Match';
		newCon.ASAHPRA_ID__c = '123456789';
		insert newCon;
		
		// assertion
    System.AssertEquals(database.countquery('SELECT '
           																		+ 'COUNT()'
              															+' FROM'
              																+' Contact '
              															),2
              					); 
	}
    
    
}