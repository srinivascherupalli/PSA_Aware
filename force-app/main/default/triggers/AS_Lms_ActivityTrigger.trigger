/*
*Author : Michael Vincent Largo
*Description :
*Date Created : 08/28/2019
*Last Modified By: Deadz
*Date Last Modified:
*Related Metadata :
*Action : insert
*/
trigger AS_Lms_ActivityTrigger on LMS_Activity__c (after insert) {
    
    Set<Id> ActIdSet = new Set<Id>();
	Set<Id> InstanceIdSet = new Set<Id>();
    for(LMS_Activity__c act : trigger.new) {
        if(act.LMS_Instance__c != null && act.LMS_Course__c != null && act.AS_Activity_Type__c !=null) {
            ActIdSet.add(act.Id);
			InstanceIdSet.add(act.LMS_Instance__c);
        }
    }
    
	Map<Id,LMS_Instance__c> allInstanceMap = new Map<Id,LMS_Instance__c>();
	allInstanceMap = new Map<Id,LMS_Instance__c>([SELECT Id,Token__c, URL__c FROM LMS_Instance__c WHERE Id = :InstanceIdSet]);
    system.debug('allInstanceMap==>' + allInstanceMap);
    try {
        List<AsMoodleWrapper> allAsMoodleWrapper = new List<AsMoodleWrapper>();
        for (LMS_Activity__c activity : [SELECT Id,Name,LMS_Course__c,AS_Activity_Type__c,LMS_Instance__c FROM LMS_Activity__c WHERE Status__c = 'Active' AND Id =:ActIdSet]){
            system.debug('GodSpeed==>' + activity);
            
            AsMoodleWrapper aswrap = new AsMoodleWrapper(activity.Id, activity.Name, activity.LMS_Course__c, activity.AS_Activity_Type__c, allInstanceMap.get(activity.LMS_Instance__c).Token__c, allInstanceMap.get(activity.LMS_Instance__c).URL__c, 'activities', 'local_psa_integration_create_activities', 'create');
            allAsMoodleWrapper.add(aswrap);
        }
        if(Limits.getLimitQueueableJobs() - Limits.getQueueableJobs() > 5  && !Test.isRunningTest() && allAsMoodleWrapper.size() > 0) {
            system.enqueueJob(new AsMoodleApiCalloutQueueable(allAsMoodleWrapper));  
        }
        
    } catch(Exception ex) {
        System.debug('ERROR LOGS HERE FOR ACTIVITY :' + ex);
    }
}