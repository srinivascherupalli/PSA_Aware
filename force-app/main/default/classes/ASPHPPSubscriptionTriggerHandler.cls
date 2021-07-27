/*Author : John Hope
*Description : This is a class that handles ASPHPP__Subscription__c File Object Trigger.
*Date Created : 
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data : ASPHPP__Subscription__c
*/
public class ASPHPPSubscriptionTriggerHandler {
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
	public ASPHPPSubscriptionTriggerHandler(boolean isExecuting){
		isExecutingBool = isExecuting;
	}
	
	/*Author : John Hope
	*Description : handler for before insert trigger for object ASPHPP__Subscription__c
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param : 
		0. List<Object> - the new Object from trigger
	*Return : 
 	*/
	public void OnBeforeInsert(Object[] newObjects){
    // EXECUTE BEFORE INSERT LOGIC
    for(ASPHPP__Subscription__c subs :(List<ASPHPP__Subscription__c>) newObjects) {
    	if(subs.Name.length() > 50) {
    		System.debug('checking subscription insert trigger');
    		subs.Name = subs.Name.subString(0,49) + '...';
    	}
    }
	}
	
	/*Author : John Hope
	*Description : handler for after insert trigger for object ASPHPP__Subscription__c
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param :
		0. List<Object> - the new Object from trigger
	*Return : 
 	*/
 	/*
	public void OnAfterInsert(Object[] newObjects,Map<Id,Object> newMapObjects) {
		
	}
	*/
	/*Author : John Hope
	*Description : handler for before update trigger for object ASPHPP__Subscription__c
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
		// BEFORE UPDATE LOGIC
	}
	*/
	/*Author : John Hope
	*Description : handler for after update trigger for object ASPHPP__Subscription__c
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
	public void OnAfterUpdate(Object[] updatedObjects,Map<Id,Object> oldMap,Map<Id,Object> newMap) {
	}
	*/
	/*Author : John Hope
	*Description : handler for before delete trigger for object ASPHPP__Subscription__c
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param : List<ASPHPP__Subscription__c>,List<ASPHPP__Subscription__c>
		0. List<ASPHPP__Subscription__c> - the old ASPHPP__Subscription__c data from trigger
		1. Map<Id,ASPHPP__Subscription__c> - the old Map data from trigger
	*Return : 
 	*/
 	/*
	public void OnBeforeDelete(Object[] oldObjects,Map<Id,Object>  MapObjectMap){
	
        
	}
	*/
	/*Author : John Hope
	*Description : handler for after delete trigger for object ASPHPP__Subscription__c
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
	*Description : handler for undelete trigger for object ASPHPP__Subscription__c
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
	
	
	
	
}