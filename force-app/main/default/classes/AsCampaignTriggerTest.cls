/*Author : John Hope
*Description : This is a test class for Campaign class.
*Date Created : May 4, 2018
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data : Campaign.cls
 */
 @isTest
private class AsCampaignTriggerTest {

	static testMethod void isInsert() {
		Campaign a = new Campaign(Name='Alphasys Campaign');
		insert a;
	}
	
 	static testMethod void isUpdate() {
        Id eventRT = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Event').getRecordTypeId();
 		Campaign cam = new Campaign(Name='Alphasys Campaign', RecordTypeId=eventRT, AS_Session__c=true);
		insert cam;
		
        AS_Event__c evt = new AS_Event__c(Name = 'Campaign Event');
        insert evt;
        
		Campaign camUpdate = new Campaign(Id = cam.Id, Name='Alphasys Campaign Final', AS_Event__c=evt.Id);
		update camUpdate;
	}

	static testMethod void isDelete() { 
		Campaign cam = new Campaign(Name='Alphasys Campaign');
		insert cam;
		
		delete cam;
	}
	
	static testMethod void isUndelete() {
		Campaign cam = new Campaign(Name='Alphasys Campaign');
		insert cam;
		
		delete cam;
		
		Campaign[] savedCam = [SELECT Id, Name FROM Campaign WHERE Name = 'Alphasys Campaign' ALL ROWS]; 
		try {
		    undelete savedCam;
		} catch (DmlException e) {
		    // Process exception here
		}
	}
	
	
}