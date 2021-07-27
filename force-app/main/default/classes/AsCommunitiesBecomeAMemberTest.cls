@isTest
private class AsCommunitiesBecomeAMemberTest {
	
	@isTest static void theUserIdTest() {

		Account acc =  new Account();
		acc.Name = 'Test Account';
		insert acc;

		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 

		User u = new User(Alias = 'standt', 
                        Email = 'standarduser@testorg.com', 
                        EmailEncodingKey = 'UTF-8', 
                        FirstName = 'FNtesting',
                        LastName = 'LNtesting', 
                        LanguageLocaleKey = 'en_US', 
                        LocaleSidKey = 'en_US', 
                        ProfileId = p.Id, 
                        TimeZoneSidKey = 'America/Los_Angeles', 
                        UserName = 'standarduser@testusername.com');
        insert u;

		AsCommunitiesBecomeAMember asCom = new AsCommunitiesBecomeAMember();
		asCom.AccountId = acc.id;
		asCom.theUserId();

	}

	
}