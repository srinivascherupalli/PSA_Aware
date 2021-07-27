/*Author : John Hope
*Description : This is a class that handles LMS User File Object Trigger.
*Date Created : 
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data : LMS User
*/
public class AsLMSUserTriggerHandler {
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
	public AsLMSUserTriggerHandler(boolean isExecuting){
		isExecutingBool = isExecuting;
	}
	
	/*Author : John Hope
	*Description : handler for before insert trigger for object LMS User
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param : 
		0. List<Object> - the new Object from trigger
	*Return : 
 	*/
	public void OnBeforeInsert(LMS_User__c[] newObjects){
	    // EXECUTE BEFORE INSERT LOGIC
	}
	
	/*Author : John Hope
	*Description : handler for after insert trigger for object LMS User
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param :
		0. List<Object> - the new Object from trigger
	*Return : 
 	*/
	public void OnAfterInsert(LMS_User__c[] newObjects,Map<Id,LMS_User__c> newMapObjects) {
		
	}
	
	/*Author : John Hope
	*Description : handler for before update trigger for object LMS User
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param :
		0. List<Object> - the new Object from trigger
		1. Map<Id,Object> - the new Object from trigger
		2. Map<Id,Object> - the new Map Object from trigger
	*Return : 
 	*/
	public void OnBeforeUpdate(LMS_User__c[] updatedObjects, Map<Id,LMS_User__c> oldMap, Map<Id,LMS_User__c> newMap){
		// BEFORE UPDATE LOGIC
	}
	
	/*Author : John Hope
	*Description : handler for after update trigger for object LMS User
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param :
		0. List<Object> - the new Object from trigger
		1. Map<Id,Object> - the new Object from trigger
		2. Map<Id,Object> - the new Map Object from trigger
	*Return : 
 	*/
	public void OnAfterUpdate(LMS_User__c[] updatedObjects,Map<Id,LMS_User__c> oldMap,Map<Id,LMS_User__c> newMap) {
	}
	
	/*Author : John Hope
	*Description : handler for before delete trigger for object LMS User
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param : List<LMS User>,List<LMS User>
		0. List<LMS User> - the old LMS User data from trigger
		1. Map<Id,LMS User> - the old Map data from trigger
	*Return : 
 	*/
	public void OnBeforeDelete(LMS_User__c[] oldObjects,Map<Id,LMS_User__c>  MapObjectMap){
	
        
	}
	
	/*Author : John Hope
	*Description : handler for after delete trigger for object LMS User
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param : 
		0. List<Object> - the old object data list from trigger
		1. Map<Id,Object> - the old object data map from trigger
	*Return : 
 	*/
	public void OnAfterDelete(LMS_User__c[] deletedObjects,Map<Id,LMS_User__c>  MapObjectMap){
	    // AFTER DELETE LOGIC
	}
	
	/*Author : John Hope
	*Description : handler for undelete trigger for object LMS User
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param :
		0. List<Object> - the new object data list from trigger
	*Return : 
 	*/
	public void OnUndelete(LMS_User__c[] restoredObjects){
	    // AFTER UNDELETE LOGIC
	}
	
	
	/*Author : John Hope
	*Description : handler for after update trigger in object LMS User
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param :
		0. List<Object> - the new object data list from trigger
	*Return : 
 	*/
	public static void processDataForUpdate(List<LMS_User__c> updatedObjects){
		if(runOnceCallMoodle() && updatedObjects.size() == 1) {
	    System.debug('lms user is running');
	    Set<Id> allUserInstance = new Set<Id>();
	    List<AsMoodleWrapper> allMoodleWrapper = new List<AsMoodleWrapper>();
	    for(LMS_User__c lmsUser : updatedObjects) {
				allUserInstance.add(lmsUser.LMS_Instance__c);
			}
			
			Map<Id,LMS_Instance__c> allInstance = new Map<Id,LMS_Instance__c>();
			for(LMS_Instance__c ins : [SELECT Token__c, URL__c FROM LMS_Instance__c WHERE Id IN :allUserInstance]) {
				allInstance.put(ins.Id,ins);
			}
			
			if(allInstance.size() > 0) {
				
				try {
					for(LMS_User__c lmsUser : updatedObjects) {
						AsMoodleWrapper wrap = new AsMoodleWrapper(allInstance.get(lmsUser.LMS_Instance__c).Token__c, allInstance.get(lmsUser.LMS_Instance__c).URL__c, 'updateUsers', 'local_psa_integration_update_users', 'update', lmsUser.Id, '5', '', '', lmsUser.Firstname__c, lmsUser.Lastname__c, lmsUser.Email__c, '', lmsUser.AS_Authentication_Method__c);
						allMoodleWrapper.add(wrap);
					}
					
					if(Limits.getLimitQueueableJobs() - Limits.getQueueableJobs() > 5 && allMoodleWrapper.size() > 0 && !Test.isRunningTest()) { // if limit is not less than 5, create queueable
			    	system.enqueueJob(new AsMoodleApiCalloutQueueable(allMoodleWrapper));    
		    	}
				} catch(Exception ex) {
					System.debug('ERROR OCCUR ON UPDATE OF MOODLE USER' + ex);
		    }
					
			}
			
			if(allMoodleWrapper.size()>0) {
		    AsLMSUserTriggerHandler.runCallMoodle = false;
			} else {
				 AsLMSUserTriggerHandler.runCallMoodle = true;
			}
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
	
	
	
	
}