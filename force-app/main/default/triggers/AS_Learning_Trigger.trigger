trigger AS_Learning_Trigger on Learning__c (before insert, before update, after insert, after update) {
	
	//AS_Learning_Trigger_Handler handler = new AS_Learning_Trigger_Handler(true);
	
	AS_Learning_Trigger_Handler handler = new AS_Learning_Trigger_Handler();
	
    Map<Id, Learning__c> lrn = Trigger.newMap;
    List<Learning__c> lrnList = Trigger.new;
    if(Trigger.isBefore){
        lrnList[0].LMS_Course__c = AS_HelperClass.LMS_Integration_Learning(lrnList, 'before');
    }else{
        // Jrc Comment this part if(lrnList[0].Unlock_Training_Plan__c == true) AS_HelperClass.UpdateRequestApproveHelper(lrn, new Set<Id>(), null, null);
    }
    
    /* After Insert */
    if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new,Trigger.newMap);
    }
    /* After Update */
    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.new, Trigger.oldMap, Trigger.newMap);
    }

}