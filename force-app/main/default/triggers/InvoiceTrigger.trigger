trigger InvoiceTrigger on blng__Invoice__c (after insert) {
    system.debug('Invoice trigger called: ' + String.valueOf(trigger.operationType));
    system.debug(trigger.newMap.keySet());
    
    InvoiceTriggerHandler.afterInsert(trigger.newMap.keySet());  
}