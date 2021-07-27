/*Author : Mizpah
*Description : pass salesforce course to moodle
*Date Created : 
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data :
*Param :
*Return : Boolean
*/
trigger AS_LMS_Course on LMS_Course__c (after insert, after update) {
	System.debug(' Creation of new LMS Course starts here ');
	List<LMS_Course__c> lms_course = Trigger.new;
	List<LMS_Course__c> lms_course_old = Trigger.old;
	Set<Id> allInstanceIdSet = new Set<Id>();
	for(LMS_Course__c course : trigger.new) {
		if(course.LMS_Instance__c != null) {
			allInstanceIdSet.add(course.LMS_Instance__c);
		}
	}

	Map<Id,LMS_Instance__c> allInstanceMap = new Map<Id,LMS_Instance__c>();
	allInstanceMap = new Map<Id,LMS_Instance__c>([SELECT Id,Token__c, URL__c FROM LMS_Instance__c WHERE Id = :allInstanceIdSet]);
	
	try {
		List<AsMoodleWrapper> allAsMoodleWrapper = new List<AsMoodleWrapper>();
		for(LMS_Course__c course : trigger.new) {
				if(Trigger.isInsert) {
					AsMoodleWrapper wrap = new AsMoodleWrapper(allInstanceMap.get(course.LMS_Instance__c).Token__c, allInstanceMap.get(course.LMS_Instance__c).URL__c, 'courses', 'local_psa_integration_create_courses', 'insert', course.Id, course.Name, course.Name, null, null, null, null, null, null);
		    	allAsMoodleWrapper.add(wrap);
				} else if(Trigger.isUpdate && lms_course[0].Moodle_Course_Id__c == null) {
					AsMoodleWrapper wrap = new AsMoodleWrapper(allInstanceMap.get(course.LMS_Instance__c).Token__c, allInstanceMap.get(course.LMS_Instance__c).URL__c, 'courses', 'local_psa_integration_update_courses', 'update', course.Id, course.Name, course.Name, null, null, null, null, null, null);
		    	allAsMoodleWrapper.add(wrap);
				}
		}
		// if limit is not less than 5, create queueable
		if(Limits.getLimitQueueableJobs() - Limits.getQueueableJobs() > 5  && !Test.isRunningTest() && allAsMoodleWrapper.size() > 0) {
			system.enqueueJob(new AsMoodleApiCalloutQueueable(allAsMoodleWrapper));  
		}
		
	} catch(Exception ex) {
		System.debug('ERROR LOGS HERE :' + ex);
	}
	
}