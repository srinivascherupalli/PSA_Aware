trigger AsBgCourseTrigger on AS_BG_Course__c (after delete, after insert, after undelete,
after update, before delete, before insert, before update) {
  // This should be used in conjunction with the TriggerHandlerComprehensive.cls template
  // The origin of this pattern is http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx

  AsBgCourseTriggerHandler handler = new AsBgCourseTriggerHandler(Trigger.isExecuting, Trigger.size);

  /* Before Insert */
	if(Trigger.isInsert && Trigger.isBefore){
		handler.OnBeforeInsert(Trigger.new);
	}
	/* After Insert */
	else if(Trigger.isInsert && Trigger.isAfter){
    	handler.OnAfterInsert(Trigger.new);
 	} 
  /* Before Update */
	else if(Trigger.isUpdate && Trigger.isBefore){
    	handler.OnBeforeUpdate(Trigger.new, Trigger.oldMap, Trigger.newMap);
	}
	/* After Update */
	else if(Trigger.isUpdate && Trigger.isAfter){
    	handler.OnAfterUpdate(Trigger.new, Trigger.oldMap, Trigger.newMap);
	}
	/* Before Delete */
	else if(Trigger.isDelete && Trigger.isBefore){
    	handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
	}
	/* After Delete */
	else if(Trigger.isDelete && Trigger.isAfter){
		handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
	}
    /* After Undelete */
	else if(Trigger.isUnDelete){
   		handler.OnUndelete(Trigger.new);
	}

}