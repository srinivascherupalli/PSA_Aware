trigger AsCPDPlannerTrigger on AsCPDPlanner__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    AsCPDPlannerTriggerHandler handler = new AsCPDPlannerTriggerHandler(true);
	
	/* Before Insert */
	if(Trigger.isInsert && Trigger.isBefore){
    handler.OnBeforeInsert(Trigger.new);
	}
	/* After Insert */
	else if(Trigger.isInsert && Trigger.isAfter){
    handler.OnAfterInsert(Trigger.new,Trigger.newMap);
	}
	/* Before Update */
	else if(Trigger.isUpdate && Trigger.isBefore){
    handler.OnBeforeUpdate(Trigger.new,Trigger.oldMap, Trigger.newMap);
	}
	/* After Update */
	else if(Trigger.isUpdate && Trigger.isAfter){
		if(AsCPDPlannerTriggerHandler.runOnce()){
			handler.OnAfterUpdate(Trigger.new, Trigger.oldMap, Trigger.newMap);
		}
	}
	// Before Delete 
	//else if(Trigger.isDelete && Trigger.isBefore){
 //   handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
	//}
	///* After Delete */
	//else if(Trigger.isDelete && Trigger.isAfter){
	//	handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
	//}
	
	///* After Undelete */
	//else if(Trigger.isUnDelete){
 //   handler.OnUndelete(Trigger.new);
	//}
}