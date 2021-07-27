@isTest
private class AS_LMS_Course_triggerTest {
	
	@isTest static void courseInsertUpdate() {
		LMS_Instance__c li 	= new LMS_Instance__c();
        li.Token__c         = '6d6e009a7317681cad15d8780f1d27cf';
        li.URL__c 			= 'https://moodle.alphasys.com.au/webservice/rest/server.php';
        li.Domain_URL__c = 'https://moodle.alphasys.com.au/webservice/rest/server.php';
        li.Status__c 		= 'Active';
        li.Type__c 			= 'Moodle';
        insert li;
        System.assert(li != null, 'LMS instance is empty');
        
        LMS_Course__c lc 	= new LMS_Course__c();
        lc.Name 			= 'test lc';
        lc.Status__c 		= 'Active';
        lc.LMS_Instance__c 	= li.Id;
        lc.AS_Update_LMS_Course__c = false;
        insert lc;
        System.assert(lc != null, 'LMS course is empty');        
				
				lc.AS_Update_LMS_Course__c = true;
        update lc;
        
        System.AssertEquals(database.countquery('SELECT '
                                                        + 'COUNT()'
                                                +' FROM'
                                                    +' LMS_Course__c '
                                            ),1
                                ); 
	}
}