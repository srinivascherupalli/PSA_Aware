/*Author : John Hope
*Description : This is a class that handles Order File Object Trigger.
*Date Created : 
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data : Order
*/
public class AsOrderHandler {
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
	public AsOrderHandler(boolean isExecuting){
		isExecutingBool = isExecuting;
	}
	
	/*Author : John Hope
	*Description : handler for before insert trigger for object Order
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
	}
	*/
	
	/*Author : John Hope
	*Description : handler for after insert trigger for object Order
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param :
		0. List<Object> - the new Object from trigger
	*Return : 
 	*/
 	
	public void OnAfterInsert(Object[] newObjects,Map<Id,Object> newMapObjects) {
		// EXECUTE BEFORE INSERT LOGIC
		Set<Id> allOppId = new Set<Id>();
		for(Order ord :(List<Order>) newObjects) {
			if(ord.OpportunityId != null) {
				allOppId.add(ord.OpportunityId);
			}
		}
		
		Map<Id,Id> allSubsMap = new Map<Id,Id>();
		for(ASPHPP__Subscription__c subs : [Select 
																					AS_opportunity__c,
																					Id 
																				from 
																					ASPHPP__Subscription__c 
																				where 
																					AS_opportunity__c IN :allOppId
																				]) {
			allSubsMap.put(subs.AS_opportunity__c,subs.Id);																					
		}
		
		List<ASPHPP__Subscription__c> alltobeUpdatedSub = new List<ASPHPP__Subscription__c>();
		for(Order ord :(List<Order>) newObjects) {
			if(allSubsMap.containsKey(ord.OpportunityId)) {
				ASPHPP__Subscription__c inditobeUpdatedSub = new ASPHPP__Subscription__c();
				inditobeUpdatedSub.Id = allSubsMap.get(ord.OpportunityId);
				inditobeUpdatedSub.AS_Order__c = ord.Id;
				alltobeUpdatedSub.add(inditobeUpdatedSub);
			}
		}
		
		update alltobeUpdatedSub;
	}
	
	
	/*Author : John Hope
	*Description : handler for before update trigger for object Order
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
	*Description : handler for after update trigger for object Order
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
	*Description : handler for before delete trigger for object Order
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param : List<Order>,List<Order>
		0. List<Order> - the old Order data from trigger
		1. Map<Id,Order> - the old Map data from trigger
	*Return : 
 	*/
 	/*
	public void OnBeforeDelete(Object[] oldObjects,Map<Id,Object>  MapObjectMap){
	
        
	}
	*/
	
	/*Author : John Hope
	*Description : handler for after delete trigger for object Order
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
	*Description : handler for undelete trigger for object Order
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