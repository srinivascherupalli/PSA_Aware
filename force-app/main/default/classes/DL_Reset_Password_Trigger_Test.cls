@isTest
public class DL_Reset_Password_Trigger_Test {
    
    static Boolean CheckPassword(String password){
        
        Boolean lowerCase = Pattern.compile('(.*[a-z].*)|([a-z].*)').matcher(password).matches();
        Boolean upperCase = Pattern.compile('(.*[A-Z].*)|([A-Z].*)').matcher(password).matches();
        Boolean alpha = Pattern.compile('(.*[a-zA-Z].*)|([a-zA-Z].*)').matcher(password).matches();
        Boolean nonAlpha = Pattern.compile('(.*[^A-Z].*)|([^A-Z].*)').matcher(password).matches();
        Boolean numeric = Pattern.compile('(.*[0-9].*)|([0-9].*)').matcher(password).matches();
        Boolean special = Pattern.compile('(.*[~!@#$%^&*()_,.?<>{}].*)|([~!@#$%^&*()_,.?<>{}].*)').matcher(password).matches();

        return (lowerCase && upperCase && special && numeric && password.length() >= 8 );
    }
	
    
    static testMethod void TestPassword(){
        ID profile_ID = [SELECT ID from Profile WHERE Name = 'Non Member Login User'].id;
        
        
        ////Account Setup
        
        Account testAccount = new Account();
        testAccount.FirstName = 'Test';
        testAccount.LastName = 'Account';
        testAccount.recordTypeId = [SELECT ID FROM RecordType WHERE Name = 'Person Account'].id;
        testAccount.PersonEmail = 'Test.Account@psa.org.au';
        
        insert testAccount;
		 
        
        Account account = [SELECT ID,Name,personContactID FROM Account WHERE PersonEmail = 'Test.Account@psa.org.au'];
        System.debug(account);
        
        
        Contact cntct = [SELECT ID,Name,AccountID FROM Contact WHERE ID = :account.PersonContactId];
        System.debug(cntct);
            
        
        User user = new User();
        user.Alias = 'AccountT';
        user.Email = testAccount.PersonEmail;
        user.Username = testAccount.PersonEmail;
        user.EmailEncodingKey = 'UTF-8';
        user.ContactId = cntct.Id;
        user.TimeZoneSidKey = 'Australia/Sydney';
        user.ProfileId = profile_ID;
        user.IsActive = true;
        user.LanguageLocaleKey = 'en_US';
        user.LastName = testAccount.LastName;
        user.LocaleSidKey = 'en_AU';
        
        insert user;
        

        User testUser = [SELECT ID,AccountID,ContactID FROM User WHERE ContactID = :cntct.ID];
        System.debug('testUSer.ACcountID:'+testUser.AccountID);
        
        
        System.runAs(testUser){
            
            Test.startTest();
            
            ////Testing all lowercase password
			Account acct = [SELECT ID,DL_Reset_Password__c,DL_Set_Password__c,PersonEmail From Account WHERE id = :testUser.AccountId];
            
            String password = 'testing';
            System.debug(password);
            
            acct.DL_Reset_Password__c = true;
            acct.DL_Set_Password__c = password;
            
            try{
                upsert acct;
            }
            
            catch(Exception e){
                System.debug(e.getMessage());
            }
            
    
            System.assertEquals(CheckPassword(password),false);  ///should fail  
            
            
            ////Testing all uppercase password
            
            acct = [SELECT ID,DL_Reset_Password__c,DL_Set_Password__c,PersonEmail From Account WHERE id = :testUser.AccountId];
            
            password = 'TESTING';
            System.debug(password);
            
            acct.DL_Reset_Password__c = true;
            acct.DL_Set_Password__c = password;
            
            try{
                upsert acct;
            }
            
            catch(Exception e){
                System.debug(e.getMessage());
            }
    
            System.assertEquals(CheckPassword(password),false);  ///should fail   
    
            
            
            ///Testing < 8 chars
            acct = [SELECT ID,DL_Reset_Password__c,DL_Set_Password__c,PersonEmail From Account WHERE id = :testUser.AccountId];
            
            password = 'Test!';
            System.debug(password);
            
            acct.DL_Reset_Password__c = true;
            acct.DL_Set_Password__c = password;
            
            try{
                upsert acct;
            }
            
            catch(Exception e){
                System.debug(e.getMessage());
            }
    
            System.assertEquals(CheckPassword(password),false);  ///should fail  
            
            
            
            ///Testing Mix of uppercase, lowercase and Special char
            acct = [SELECT ID,DL_Reset_Password__c,DL_Set_Password__c,PersonEmail From Account WHERE id = :testUser.AccountId];
            
            password = 'Testing!';
            System.debug(password);
            
            acct.DL_Reset_Password__c = true;
            acct.DL_Set_Password__c = password;
            
            try{
                upsert acct;
            }
            
            catch(Exception e){
                System.debug(e.getMessage());
            }
    
            System.assertEquals(CheckPassword(password),false);  ///should fail
            
            
            ///Testing Mix of uppercase, lowercase and number
            acct = [SELECT ID,DL_Reset_Password__c,DL_Set_Password__c,PersonEmail From Account WHERE id = :testUser.AccountId];
            
            password = 'Testing1';
            System.debug(password);
            
            acct.DL_Reset_Password__c = true;
            acct.DL_Set_Password__c = password;
            
            try{
                upsert acct;
            }
            
            catch(Exception e){
                System.debug(e.getMessage());
            }
    
            System.assertEquals(CheckPassword(password),false);  ///should fail
            
            
            ///Testing Mix of uppercase, lowercase, Number and Special char
            acct = [SELECT ID,DL_Reset_Password__c,DL_Set_Password__c,PersonEmail From Account WHERE id = :testUser.AccountId];
            
            password = 'Testing1!';
            System.debug(password);
            
            acct.DL_Reset_Password__c = true;
            acct.DL_Set_Password__c = password;
            
            try{
                upsert acct;
            }
            
            catch(Exception e){
                System.debug(e.getMessage());
            }
    
            System.assertEquals(CheckPassword(password),true);  ///should pass
            
            
            ///Testing with DL_Reset_Password set to false
            acct = [SELECT ID,DL_Reset_Password__c,DL_Set_Password__c,PersonEmail From Account WHERE id = :testUser.AccountId];
            
            password = 'Testing1!';
            System.debug(password);
            
            acct.DL_Reset_Password__c = false;
            acct.DL_Set_Password__c = password;
            
            try{
                upsert acct;
            }
            
            catch(Exception e){
                System.debug(e.getMessage());
            }
            
            acct = [SELECT ID,DL_Set_Password__c From Account WHERE id = :testUser.AccountId];
            String setPasswordValue = acct.DL_Set_Password__c;
            System.debug(setPasswordValue);
    
            System.assertEquals(setPasswordValue,null);  ///should pass
            
            
            Test.stopTest();
        }
        
    }    
    
}