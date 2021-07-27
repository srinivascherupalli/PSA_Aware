/**
* Batch class ASBatchPendingExpiredNotification #PRI-163
* @author danrl@alphasys.com.au
*/
global class ASBatchPendingExpiredNotification implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

    global Database.QueryLocator start( Database.BatchableContext BC ) {
        String q = 'SELECT ';
        q += 'Id';
        q += ', Name';
        q += ', AS_Enrollment_Last_Modify_Date__c';
        q += ', AS_Expired_notification_sent__c';
        q += ', AS_Account__r.AS_PersonAccount_ContactID__c';
        q += ', AS_Account__r.PersonEmail';

        Id rId = Schema.Sobjecttype.Enrolment_Form__c.getRecordTypeInfosByName().get('PSA Enrolment').getRecordTypeId();
        q += ', Enrolment_Status__c FROM Enrolment_Form__c WHERE Enrolment_Status__c = \'Draft\' AND RecordTypeId =: rId AND AS_Pending_notification_sent__c = false';
 
       	return Database.getQueryLocator( q );
    }

    global void execute( Database.BatchableContext BC, List<Enrolment_Form__c> scope ) {
 
        // trigger batch process
        ASPendingExpireNotificationHandler notification = new ASPendingExpireNotificationHandler( scope );
        notification.runBatch();

    }

    global void finish(Database.BatchableContext BC) {}

}