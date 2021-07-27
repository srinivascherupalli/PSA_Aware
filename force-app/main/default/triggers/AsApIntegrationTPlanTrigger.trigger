trigger AsApIntegrationTPlanTrigger on As_AP_Integration__c (after insert) {
    if(!System.isBatch()){
        Id nullID;
        Set<Id> setnullID = new Set<Id>();
        AsApIntegrationTPlanBatch asApIntegration = new AsApIntegrationTPlanBatch(nullID,setnullID);
        asApIntegration.runAPIntegration_AfterInsert(Trigger.newMap.keySet());
    }
}