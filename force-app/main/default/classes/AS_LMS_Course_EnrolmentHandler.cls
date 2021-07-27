/*Author : John Hope
*Description : This is a class that handles LMS_Course_Enrolment__c File Object Trigger.
*Date Created : 
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data : LMS_Course_Enrolment__c
*/
public class AS_LMS_Course_EnrolmentHandler {
	private boolean isExecutingBool = false;
	
	/*Author : John Hope
	*Description : this is a constructor
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param : 
		0. boolean - set value for isExecutingBool 
	*Return : 
 	*/
	public AS_LMS_Course_EnrolmentHandler(boolean isExecuting){
		isExecutingBool = isExecuting;
	}
	
	/*Author : John Hope
	*Description : handler for before insert trigger for object LMS_Course_Enrolment__c
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param : 
		0. List<Object> - the new Object from trigger
	*Return : 
 	*/
 	/*
	public void OnBeforeInsert(Object[] newObjects){
	    // EXECUTE BEFORE INSERT LOGIC
	}
	*/
	
	/*Author : John Hope
	*Description : handler for after insert trigger for object LMS_Course_Enrolment__c
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param :
		0. List<Object> - the new Object from trigger
	*Return : 
 	*/
	public void OnAfterInsert(Object[] newObjects,Map<Id,Object> newMapObjects) {
		moodleCallOut(newObjects);
		
		// added by wew for (##PSA-92)
    updateLearAssOrBgCoEnrViaLMSEnrollChecker(newObjects, new Map<Id,Object>(), new Map<Id,Object>(), 'INSERT');
    
	}
	
	/*Author : John Hope
	*Description : handler for before update trigger for object LMS_Course_Enrolment__c
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param :
		0. List<Object> - the old Object from trigger
		1. List<Object> - the new Object from trigger
		2. List<Object> - the new Map Object from trigger
	*Return : 
 	*/
 	/*
	public void OnBeforeUpdate(Object[] updatedObjects, Map<Id,Object> oldMap, Map<Id,Object> newMap){
		
	}
	*/
	
	/*Author : John Hope
	*Description : handler for after update trigger for object LMS_Course_Enrolment__c
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param :
		0. List<Object> - the old Object from trigger
		1. List<Object> - the new Object from trigger
		2. List<Object> - the new Map Object from trigger
	*Return : 
 	*/
	public void OnAfterUpdate(Object[] updatedObjects,Map<Id,Object> oldMap,Map<Id,Object> newMap) {
		moodleCallOut(updatedObjects);
		
		// added by wew for (##PSA-92)
    updateLearAssOrBgCoEnrViaLMSEnrollChecker(updatedObjects, oldMap, newMap,'UPDATE');
	}
	
	/*Author : John Hope
	*Description : handler for before delete trigger for object LMS_Course_Enrolment__c
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param : List<LMS_Course_Enrolment__c>,List<LMS_Course_Enrolment__c>
		0. List<LMS_Course_Enrolment__c> - the old LMS_Course_Enrolment__c data from trigger
		1. Map<Id,LMS_Course_Enrolment__c> - the old Map data from trigger
	*Return : 
 	*/
 	/*
	public void OnBeforeDelete(Object[] oldObjects,Map<Id,Object>  MapObjectMap){
	   
	}
	*/
	
	/*Author : John Hope
	*Description : handler for after delete trigger for object LMS_Course_Enrolment__c
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param : 
		0. List<Object> - the old object data list from trigger
		1. Map<Id,Object> - the old object data map from trigger
	*Return : 
 	*/
 	/*
	public void OnAfterDelete(Object[] deletedObjects,Map<Id,Object>  MapObjectMap){
	    // AFTER DELETE LOGIC
	}
	*/
	/*Author : John Hope
	*Description : handler for undelete trigger for object LMS_Course_Enrolment__c
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param :
		0. List<Object> - the new object data list from trigger
	*Return : 
 	*/
 	/*
	public void OnUndelete(Object[] restoredObjects){
	    // AFTER UNDELETE LOGIC
	}
	*/
	/*Author : John Hope
	*Description : checker if trigger is running
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param : 
	*Return : boolean
 	*/
	public boolean IsTriggerContext{
	    get{ return isExecutingBool;}
	}
	
	/*
	* Author : mizpah
	* Description: method to call moodle
	* Parameter : None
	* Updated by : john
	* Return : None
	*/
	public void moodleCallOut(Object[] newData) {
		System.debug('AS_LMS_Course_EnrolmentHandler.runCallMoodle : ' + AS_LMS_Course_EnrolmentHandler.runCallMoodle);
		if(runOnceCallMoodle() && newData.size() == 1) { //if course enrollment is equal to one, automatically call moodle
			List<LMS_Course_Enrolment__c> lce = (List<LMS_Course_Enrolment__c>) newData;
			List<AsMoodleWrapper> allMoodleWrapper = new List<AsMoodleWrapper>();
			Boolean hasDataProcess = false;
			if(lce.size() > 0) {
				Set<Id> allInstanceIdSet = new Set<Id>();
				Set<Id> allLmsUserIdSet = new Set<Id>();
				
				for(LMS_Course_Enrolment__c lmsEnroll : lce) {
					if(lmsEnroll.LMS_Instance__c != null) {
						allInstanceIdSet.add(lmsEnroll.LMS_Instance__c);
					}
					if(lmsEnroll.LMS_User__c != null) {
						allLmsUserIdSet.add(lmsEnroll.LMS_User__c);
					}
				}
			
				Map<Id,LMS_Instance__c> allInstanceMap = new Map<Id,LMS_Instance__c>();
				Map<Id,LMS_User__c> allLmsUserMap = new Map<Id,LMS_User__c>();
				Map<Id,User> allUserMap = new Map<Id,User>();
				
				allInstanceMap = new Map<Id,LMS_Instance__c>([SELECT Id,Token__c, URL__c FROM LMS_Instance__c WHERE Id = :allInstanceIdSet]);
				allLmsUserMap = new Map<Id,LMS_User__c>([SELECT Firstname__c, Lastname__c, Email__c,AS_Authentication_Method__c FROM LMS_User__c WHERE Id = :allLmsUserIdSet]);
				
				System.debug('allInstanceMap :' + allInstanceMap);
				System.debug('allLmsUserMap :' + allLmsUserMap);
			
				for(User theUser : [SELECT 
																Id, 
																Firstname, 
																Lastname, 
																CommunityNickname, 
																Email, 
																Username,
																LMS_Instance__c,
																LMS_User__c
															FROM 
																User 
															WHERE 
																LMS_User__c  IN :allLmsUserIdSet
															]) {
					allUserMap.put(theUser.LMS_User__c,theUser);								
				}
				try {
					Integer counter50 = 1;
					for(LMS_Course_Enrolment__c lmsEnroll : lce) {
						if(lmsEnroll.As_Moodle_Id__c == null) {
							String theEmail;
							if(allUserMap.containsKey(lmsEnroll.LMS_User__c)) {
								theEmail = allUserMap.get(lmsEnroll.LMS_User__c).Username;
							} else {
								theEmail = allLmsUserMap.get(lmsEnroll.LMS_User__c).Email__c;
							}
		        	AsMoodleWrapper wrap = new AsMoodleWrapper(allInstanceMap.get(lmsEnroll.LMS_Instance__c).Token__c, allInstanceMap.get(lmsEnroll.LMS_Instance__c).URL__c, 'enrolUsers', 'local_psa_integration_enrol_users', 'insert', lmsEnroll.Id, '5', lmsEnroll.LMS_Course__c, theEmail, allLmsUserMap.get(lmsEnroll.LMS_User__c).Firstname__c, allLmsUserMap.get(lmsEnroll.LMS_User__c).Lastname__c, allLmsUserMap.get(lmsEnroll.LMS_User__c).Email__c, lmsEnroll.LMS_User__c, allLmsUserMap.get(lmsEnroll.LMS_User__c).AS_Authentication_Method__c);
				    	allMoodleWrapper.add(wrap);
				    	
				    	if(counter50 == 50) {
				    		Integer remainJobs = Limits.getLimitQueueableJobs()-Limits.getQueueableJobs();
								System.debug('CONDITIONS FOR MOODLE 1: ' + Limits.getLimitQueueableJobs() + '-' + Limits.getQueueableJobs() + '='+ remainJobs + ' - ' + allMoodleWrapper.size() +' - ' + Test.isRunningTest());
								if(remainJobs>0  && allMoodleWrapper.size() > 0 && !Test.isRunningTest()) { // if limit is not less than 2, create queueable
						 			system.enqueueJob(new AsMoodleApiCalloutQueueable(allMoodleWrapper));   
						 			hasDataProcess = true;
						 			
						 			system.debug('moodle api is called : - counter ' +counter50 + ' - allMoodleWrapper.size() :' + allMoodleWrapper.size());
						 			
						 			allMoodleWrapper = new List<AsMoodleWrapper>();
						 			counter50 = 0;
					    	}
				    	}
				    	counter50++;
						}
					}
					Integer remainJobs = Limits.getLimitQueueableJobs()-Limits.getQueueableJobs();
					System.debug('CONDITIONS FOR MOODLE 2: ' + Limits.getLimitQueueableJobs() + '-' + Limits.getQueueableJobs() + '='+ remainJobs + ' - ' + allMoodleWrapper.size() +' - ' + Test.isRunningTest());
					if(remainJobs>0  && allMoodleWrapper.size() > 0 && !Test.isRunningTest()) { // if limit is not less than 2, create queueable
			 			system.enqueueJob(new AsMoodleApiCalloutQueueable(allMoodleWrapper));  
			 			system.debug('moodle api is called : - counter ' +counter50 + ' - allMoodleWrapper.size() :' + allMoodleWrapper.size());
		    	}
				} catch(Exception ex) {
					System.debug(' AN ERROR OCCUR : ' + ex);
		    }
		
			}
			
			if(allMoodleWrapper.size()>0 || hasDataProcess == true) {
		    AS_LMS_Course_EnrolmentHandler.runCallMoodle = false;
		    System.debug('hasDataProcess set to false');
			} else {
				 AS_LMS_Course_EnrolmentHandler.runCallMoodle = true;
				 System.debug('hasDataProcess set to true');
			}
			
			/* // this commented since this will only run when size is 1
			if(newData.size() == 200) {
		    AS_LMS_Course_EnrolmentHandler.runCallMoodle = true;
			}
			*/
			
		}
	}
	
	
	public static boolean runCallMoodle = true;
	
	/*Author : John Hope
	*Description : check the run variable and use for recursion
	*Date Created :
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param :
		0. List<Object> - the new object data list from trigger
	*Return : 
 	*/
	public static boolean runOnceCallMoodle(){
	    if(runCallMoodle){
	     runCallMoodle=false;
	     return true;
	    }else{
	        return runCallMoodle;
	    }
	}
	
	/*
	* Author : john hope
	* Description: method to check data before updateLearAssOrBgCoEnrViaLMSEnroll (#PSA-92)
	* Parameter : None
	* Return : None
	*/
  public void updateLearAssOrBgCoEnrViaLMSEnrollChecker(Object[] enrollData, Map<Id,Object> oldMap, Map<Id,Object> newMap,String action) {
  	Set<Id> tobeProcessedIdSet = new Set<Id>();
  	List<LMS_Course_Enrolment__c> finalEnrollData = (List<LMS_Course_Enrolment__c>) enrollData;
  	Map<Id,LMS_Course_Enrolment__c> finalOldMap = new Map<Id,LMS_Course_Enrolment__c>();
  	Map<Id,LMS_Course_Enrolment__c> finalNewMap = new Map<Id,LMS_Course_Enrolment__c>();
  	if(action == 'UPDATE') {
	  	finalOldMap = (Map<Id,LMS_Course_Enrolment__c>) oldMap;
			finalNewMap = (Map<Id,LMS_Course_Enrolment__c>) newMap;
  	}
  	
  	for(LMS_Course_Enrolment__c enroll : finalEnrollData) {
  		if(enroll.AS_Completed_Status__c == true && enroll.Completion_Status__c != null) {
	  		System.debug('checker : ' + 1 + action);
	  		if(action == 'INSERT' || (action == 'UPDATE' && (finalOldMap.get(enroll.Id).AS_Completed_Status__c != finalNewMap.get(enroll.Id).AS_Completed_Status__c || finalOldMap.get(enroll.Id).Completion_Status__c != finalNewMap.get(enroll.Id).Completion_Status__c)) ) {
	  			System.debug('checker : ' + 2);
	  			tobeProcessedIdSet.add(enroll.Id);
	  		}
  		}
  	}
  	if(tobeProcessedIdSet.size() > 0) {
  		updateLearAssOrBgCoEnrViaLMSEnroll(tobeProcessedIdSet);
  	}
  }
	
	/*
	* Author : john hope
	* Description: method to update learning assignment base on learning data (#PSA-92)
	* Parameter : None
	* Return : None
	*/
	public void updateLearAssOrBgCoEnrViaLMSEnroll(Set<Id> allTobeProcessedIdSet) {
		Map<Id,LMS_Course_Enrolment__c> existLMSCourseEnroll = new Map<Id,LMS_Course_Enrolment__c>();
		Map<Id,LMS_Course_Enrolment__c> existBGCourseEnroll = new Map<Id,LMS_Course_Enrolment__c>();
		Set<Id> allLearAssId = new Set<Id>();
		Set<Id> allBgCourseEnrollId = new Set<Id>();
		for(LMS_Course_Enrolment__c enroll : [Select 
																						Completion_Status__c,
																						Id,
																						AS_CPD_Group_1_Group_2__c,
																						Name,
																						(Select 
																								Id,
																								LMS_Course_Enrolment__c,
																								Name
																							from 
																								Learning_Assignments__r
																						),
																						(Select 
																								Id,
																								AS_LMS_Course_Enrolment__c,
																								Name
																							from 
																								Banner_Group_Course_Enrolments__r
																						)
																					from 
																						LMS_Course_Enrolment__c 
																					where 
																						ID IN :allTobeProcessedIdSet
																					]) {																		
			// for learning assignment
			if(enroll.Learning_Assignments__r.size() > 0) {
				existLMSCourseEnroll.put(enroll.Id,enroll);
				for(Learning_Assignment__c leaAss : enroll.Learning_Assignments__r) {
					allLearAssId.add(leaAss.Id);
				}
			}
			// for bg course enrollment
			if(enroll.Banner_Group_Course_Enrolments__r.size() > 0) {
				existBGCourseEnroll.put(enroll.Id,enroll);
				for(AS_BG_Course_Enrolment__c bgCourEn : enroll.Banner_Group_Course_Enrolments__r) {
					allBgCourseEnrollId.add(bgCourEn.Id);
				}
			}
			
		}
		
		System.debug('existLMSCourseEnroll : ' + existLMSCourseEnroll);
		
		// for update for learning assignments starts here
		list<Learning_Assignment__c> allLeaAss = new list<Learning_Assignment__c>();
		for(Learning_Assignment__c leaAss : [Select 
																						Id,
																						LMS_Course_Enrolment__c,
																						Learning__r.AsCPD_Group_1_Group_2_Available__c,
																						Learning__r.AS_Group_1_CPD__c,
																						Learning__r.AS_Group_2_CPD__c, 
																						Training_Plan__r.AS_Group_1_and_Group_2_CPD_Available__c
																					from 
																						Learning_Assignment__c
																					where 
																						Id IN :allLearAssId
																				]) {
			System.debug('leaAss : ' + leaAss);
			LMS_Course_Enrolment__c finalLMSCouEnr1 = existLMSCourseEnroll.get(leaAss.LMS_Course_Enrolment__c);
			System.debug('finalLMSCouEnr1 : ' + finalLMSCouEnr1);
			
			// commented because of update for #PSA-96
			/*
			if(finalLMSCouEnr1.Completion_Status__c == 'Fail') {
				leaAss.Progress__c = 'Completed';
				leaAss.Progress_Percentage__c = 100;
				leaAss.AS_Group_1_CPD__c = leaAss.Learning__r.AS_Group_1_CPD__c;
				leaAss.AS_Group_2_CPD__c = 0;
				allLeaAss.add(leaAss); 
			} else if(finalLMSCouEnr1.Completion_Status__c == 'Pass' && leaAss.Learning__r.AsCPD_Group_1_Group_2_Available__c == true) {
				leaAss.Progress__c = 'Completed';
				leaAss.Progress_Percentage__c = 100;
				leaAss.AS_Group_1_CPD__c = leaAss.Learning__r.AS_Group_1_CPD__c;
				leaAss.AS_Group_2_CPD__c = leaAss.Learning__r.AS_Group_2_CPD__c;
				leaAss.AS_Passed__c = True;
				allLeaAss.add(leaAss);
			} else if(finalLMSCouEnr1.Completion_Status__c == 'Pass' && leaAss.Learning__r.AsCPD_Group_1_Group_2_Available__c != true) {
				leaAss.Progress__c = 'Completed';
				leaAss.Progress_Percentage__c = 100;
				leaAss.AS_Group_1_CPD__c = 0;
				leaAss.AS_Group_2_CPD__c = leaAss.Learning__r.AS_Group_2_CPD__c;
				leaAss.AS_Passed__c = True;
				allLeaAss.add(leaAss);
			}
			*/
			
			if(finalLMSCouEnr1.Completion_Status__c == 'Pass' && (leaAss.Learning__r.AS_Group_2_CPD__c != NULL && leaAss.Learning__r.AS_Group_2_CPD__c != 0)) {
				leaAss.Progress__c = 'Completed';
				leaAss.Progress_Percentage__c = 100;
				leaAss.AS_Group_1_CPD__c = 0;
				leaAss.AS_Group_2_CPD__c = leaAss.Learning__r.AS_Group_2_CPD__c;
				leaAss.AS_Passed__c = True;
				allLeaAss.add(leaAss);
			} else {
				leaAss.Progress__c = 'Completed';
				leaAss.Progress_Percentage__c = 100;
				leaAss.AS_Group_1_CPD__c = leaAss.Learning__r.AS_Group_1_CPD__c;
				leaAss.AS_Group_2_CPD__c = 0;
				leaAss.AS_Passed__c = (finalLMSCouEnr1.Completion_Status__c == 'Pass')?true:false;
				allLeaAss.add(leaAss);
			}
		}
		// for update for learning assignments ends here
		
		// for update for banner course enrollment starts here
		list<AS_BG_Course_Enrolment__c> allbgCoEn = new list<AS_BG_Course_Enrolment__c>();
		for(AS_BG_Course_Enrolment__c bgCoEn : [Select 
																						Id,
																						AS_LMS_Course_Enrolment__c,
																						AS_Banner_Group_Course__r.AS_Group_1_CPD__c,
																						AS_Banner_Group_Course__r.AS_Group_2_CPD__c, 
																						AS_Banner_Group_Course__r.AS_Group_1_and_Group_2_CPD_Available__c
																					from 
																						AS_BG_Course_Enrolment__c
																					where 
																						Id IN :allBgCourseEnrollId
																				]) {
			System.debug('bgCoEn : ' + bgCoEn);
			LMS_Course_Enrolment__c finalLMSCouEnr2 = existBGCourseEnroll.get(bgCoEn.AS_LMS_Course_Enrolment__c);
			System.debug('finalLMSCouEnr2 : ' + finalLMSCouEnr2);
			
			// commented because of update for #PSA-96
			/*
			if(finalLMSCouEnr2.Completion_Status__c == 'Fail') {
				bgCoEn.AS_Status__c = 'Completed';
				bgCoEn.AS_Completed_On__c = Date.Today();
				bgCoEn.AS_Group_1_CPD_Achieved__c = bgCoEn.AS_Banner_Group_Course__r.AS_Group_1_CPD__c;
				bgCoEn.AS_Group_2_CPD_Achieved__c = 0;
				allbgCoEn.add(bgCoEn); 
			} else if(finalLMSCouEnr2.Completion_Status__c == 'Pass' && bgCoEn.AS_Banner_Group_Course__r.AS_Group_1_and_Group_2_CPD_Available__c == true) {
				bgCoEn.AS_Status__c = 'Completed';
				bgCoEn.AS_Completed_On__c = Date.Today();
				bgCoEn.AS_Group_1_CPD_Achieved__c = bgCoEn.AS_Banner_Group_Course__r.AS_Group_1_CPD__c;
				bgCoEn.AS_Group_2_CPD_Achieved__c = bgCoEn.AS_Banner_Group_Course__r.AS_Group_2_CPD__c;
				bgCoEn.AS_Passed__c = True;
				allbgCoEn.add(bgCoEn);
			} else if(finalLMSCouEnr2.Completion_Status__c == 'Pass' && bgCoEn.AS_Banner_Group_Course__r.AS_Group_1_and_Group_2_CPD_Available__c != true) {
				bgCoEn.AS_Status__c = 'Completed';
				bgCoEn.AS_Completed_On__c = Date.Today();
				bgCoEn.AS_Group_1_CPD_Achieved__c = 0;
				bgCoEn.AS_Group_2_CPD_Achieved__c = bgCoEn.AS_Banner_Group_Course__r.AS_Group_2_CPD__c;
				bgCoEn.AS_Passed__c = True;
				allbgCoEn.add(bgCoEn);
			}
			*/
			if(finalLMSCouEnr2.Completion_Status__c == 'Pass' && (bgCoEn.AS_Banner_Group_Course__r.AS_Group_2_CPD__c != null && bgCoEn.AS_Banner_Group_Course__r.AS_Group_2_CPD__c != 0)) {
				bgCoEn.AS_Status__c = 'Completed';
				bgCoEn.AS_Completed_On__c = Date.Today();
				bgCoEn.AS_Group_1_CPD_Achieved__c = 0;
				bgCoEn.AS_Group_2_CPD_Achieved__c = bgCoEn.AS_Banner_Group_Course__r.AS_Group_2_CPD__c;
				bgCoEn.AS_Passed__c = True;
				allbgCoEn.add(bgCoEn);
			} else {
				bgCoEn.AS_Status__c = 'Completed';
				bgCoEn.AS_Completed_On__c = Date.Today();
				bgCoEn.AS_Group_1_CPD_Achieved__c = bgCoEn.AS_Banner_Group_Course__r.AS_Group_1_CPD__c;
				bgCoEn.AS_Group_2_CPD_Achieved__c = 0;
				bgCoEn.AS_Passed__c = (finalLMSCouEnr2.Completion_Status__c == 'Pass')?true:false;
				allbgCoEn.add(bgCoEn);
			}
		}
		// for update for banner course enrollment ends here
		
		System.debug('allLeaAss : ' + allLeaAss.size() + allLeaAss);
		System.debug('allbgCoEn : ' + allbgCoEn.size() + allbgCoEn);
		if(allLeaAss.size() > 0) {
			update allLeaAss;
		}
		if(allbgCoEn.size() > 0) {
			update allbgCoEn;
		}
		
	}
	
	
	
	
}