/**
 * @File Name          : ASUpdateOppEnrolmentStatusTrigger.trigger
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 11/5/2019, 10:15:58 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/5/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
trigger ASUpdateOppEnrolmentStatusTrigger on Opportunity (after insert,after update) {
    if(!System.isBatch()) {
        if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)) ASUpdateOppEnrolmentStatusHandler.checkOpportunity(Trigger.newMap.keySet());
    }
}