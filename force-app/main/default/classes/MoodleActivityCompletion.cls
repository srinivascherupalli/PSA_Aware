@RestResource(urlMapping='/MoodleActivityCompletion/*')
global with sharing class MoodleActivityCompletion {
    @HttpPost
	global static void updateRecord( Id activityId, Id courseId, Id userId, LMS_Activity_Enrolment__c objtArr ) {
         
		List<LMS_Activity_Enrolment__c> theid = [Select Id from LMS_Activity_Enrolment__c where LMS_Activity__c =: activityId and LMS_Course__c =: courseId and LMS_User__c =: userId ];     
        
		//Set<Id> activityEnrolId = new Set<Id>();
		system.debug( 'objtArr' + objtArr );
     
        for( LMS_Activity_Enrolment__c enrolarr : theid ) {
            
			system.debug(' ID ' + enrolarr.id);

            LMS_Activity_Enrolment__c actenrol = new LMS_Activity_Enrolment__c();
            actenrol = objtArr;
            actenrol.Id = enrolarr.id;
            update actenrol;
        }
        
		

    }
}