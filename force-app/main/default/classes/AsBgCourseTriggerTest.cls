/*Author : John Hope
*Description : This is a test class for AsBgCourseTrigger and AsBgCourseTriggerHandler class.
*Date Created : 
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data : AsBgCourseTriggerHandler.cls, AsBgCourseTrigger.trigger
 */
@isTest
private class AsBgCourseTriggerTest {
	static testMethod void isUpdate() {
		AS_BG_Course__c bgCourse = [Select 
																	Id 
																from 
																	AS_BG_Course__c 
																where 
																	name = 'BG Course Name 2' 
																LIMIT 1
																];
		bgCourse.AS_Description__c = 'Update description here';
		bgCourse.AS_Status__c = 'Active';
		update bgCourse;
		
		AsBgCourseTriggerHandler.OnAfterInsertAsync(new Set<Id>{bgCourse.Id});
		AsBgCourseTriggerHandler.OnAfterUpdateAsync(new Set<Id>{bgCourse.Id});
		
		// assertion
    System.AssertEquals(database.countquery('SELECT '
           																		+ 'COUNT()'
              															+' FROM'
              																+' AS_BG_Course__c '
              															),3
              					); 
	}
	
	static testMethod void isDelete() {
		AS_BG_Course__c bgCourse = [Select 
																	Id 
																from 
																	AS_BG_Course__c 
																where 
																	name = 'BG Course Name' 
																LIMIT 1
																];
		delete bgCourse;
		
		//AsBgCourseTriggerHandler common = new AsBgCourseTriggerHandler(true,1);
		AsBgCourseTriggerHandler.OnAfterDeleteAsync(new Set<Id>{bgCourse.Id});
		
		// assertion
    System.AssertEquals(database.countquery('SELECT '
           																		+ 'COUNT()'
              															+' FROM'
              																+' AS_BG_Course__c '
              															),2
              					); 
	}
	
	static testMethod void isUndelete() {
		AS_BG_Course__c bgCourse = [Select 
																	Id 
																from 
																	AS_BG_Course__c 
																where 
																	name = 'BG Course Name' 
																LIMIT 1
																];
		delete bgCourse;
		
		undelete bgCourse;
		
		// assertion
    System.AssertEquals(database.countquery('SELECT '
           																		+ 'COUNT()'
              															+' FROM'
              																+' AS_BG_Course__c '
              															),3
              					); 
	}
	
	@TestSetup  
 	static void testData() {
 		Id cheWareRecId = Schema.SObjectType.AS_BG_Course__c.getRecordTypeInfosByName().get('Chemist Warehouse').getRecordTypeId();
 		
 		LMS_Instance__c lmsInstance = new LMS_Instance__c();
		lmsInstance.AS_Instance_Long_Name__c = 'sample instance';
		lmsInstance.Status__c = 'Active';
		lmsInstance.Token__c = '1234567890';
		lmsInstance.Type__c = 'Moodle';
		lmsInstance.Domain_URL__c    = 'https://moodle.alphasys.com.au/';
		insert lmsInstance;
		
		List<AS_BG_Course__c> allbgCourse = new List<AS_BG_Course__c>();
 		AS_BG_Course__c bgCourse = new AS_BG_Course__c();
		bgCourse.Name = 'BG Course Name';
		bgCourse.AS_Status__c = 'Active';
		bgCourse.LMS_Instance_lookup__c = lmsInstance.Id;
		bgCourse.recordTypeId = cheWareRecId;
		allbgCourse.add(bgCourse);
		
		AS_BG_Course__c bgCourse2 = new AS_BG_Course__c();
		bgCourse2.Name = 'BG Course Name 2';
		bgCourse2.AS_Status__c = 'Inactive';
		bgCourse2.LMS_Instance_lookup__c = lmsInstance.Id;
		bgCourse.recordTypeId = cheWareRecId;
		allbgCourse.add(bgCourse2);
		
		AS_BG_Course__c bgCourse3 = new AS_BG_Course__c();
		bgCourse3.Name = 'BG Course Name 3';
		bgCourse3.AS_Status__c = 'Active';
		bgCourse3.LMS_Instance_lookup__c = lmsInstance.Id;
		bgCourse3.recordTypeId = cheWareRecId;
		allbgCourse.add(bgCourse3);
		
		
		
		insert allbgCourse;
		
		LMS_Course__c lmsCourse = new LMS_Course__c();
		lmsCourse.Name = 'LMS Course Name';
		lmsCourse.Description__c = 'Test here';
		lmsCourse.LMS_Instance__c = lmsInstance.Id;
		insert lmsCourse;
 	}
 	
	
	static testMethod void common() {
		AsBgCourseTriggerHandler common = new AsBgCourseTriggerHandler(true,1);
		
		common.IsExecuteAnonymousContext = true;
		common.IsWebServiceContext = true;
		common.IsVisualforcePageContext = true;
		common.IsTriggerContext = true;
		
	}
	
}