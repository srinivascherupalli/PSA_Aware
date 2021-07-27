trigger AsUserTrigger on User (after insert, after update, before insert, before update) {
	AsUserTriggerHandler handler = new AsUserTriggerHandler(true);
	
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
	    handler.OnBeforeUpdate(Trigger.new, Trigger.oldMap, Trigger.newMap);
	}
	/* After Update */
	else if(Trigger.isUpdate && Trigger.isAfter){
	    handler.OnAfterUpdate(Trigger.new, Trigger.oldMap, Trigger.newMap);
	}
}