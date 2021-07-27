@istest
public class CustomSerachController_Test {
	
    @testSetup static void setup() {
        // Create common test accounts
        List<Account> testAccts = new List<Account>();
        for(Integer i=0;i<2;i++) {
            testAccts.add(new Account(Name = 'Test '+i));
        }
        insert testAccts;
		
        Campaign ca = new campaign();
        ca.Name = 'Test';
        ca.IsActive = true;
        insert ca;
        
        Lead ll = new Lead();
        ll.LastName = 'Test';
        ll.Company = 'Deloitte';
        insert ll;
        
        Contact con = new Contact();
        con.LastName = 'Test';
        Insert Con;        	        
    }
    
    @isTest static void testMethod1() {
               
        Id [] fixedSearchResults= new Id[4];
        fixedSearchResults[0] = [Select Id,Name from Contact Limit 1].Id;
        fixedSearchResults[1] = [Select Id,Name from Account Limit 1].Id;
        fixedSearchResults[2] = [Select Id,Name from Lead Limit 1].Id;
        fixedSearchResults[3] = [Select Id,Name from Campaign Limit 1].Id;
        
       Test.setFixedSearchResults(fixedSearchResults);
        List<SObject> lla = CustomSearchController.searchForIds('Test');
        
        system.assertEquals(false, lla.isEmpty());
    }
}