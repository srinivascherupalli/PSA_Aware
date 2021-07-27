/**
* Helper class for ASBatchPendingExpiredNotification #PRI-163
* @author danrl@alphasys.com.au
*/
public class ASPendingExpireNotificationHandler {

    /**
    * List of enrolment records to be processed
    */
    private List<Enrolment_Form__c> enrolList {get; set;}

    /**
    * handler init method, passing batch data to container
    * @param enrol List<Enrolment_Form__c>, list of enrolment form from query locator
    */
    public ASPendingExpireNotificationHandler( List<Enrolment_Form__c> enrol ) {

        // pass enrolment batch data items to container
        enrolList = enrol;
    }

    /**
    * handler method that triggers the process
    */
    public void runBatch() {

        // task container
        List<Task> taskList = new List<Task>();

        // Enrol containers
        List<Enrolment_Form__c> listEnrol = new List<Enrolment_Form__c>();

        // itration of data
        for( Enrolment_Form__c e : enrolList ) {

            // grab last sync date of enrolment
            Date lastmodified = ( e.AS_Enrollment_Last_Modify_Date__c != null ? Date.valueOf( e.AS_Enrollment_Last_Modify_Date__c ) : null );

            // get custom settings
            AS_pending_and_expired_notifications__c notifSettings = AS_pending_and_expired_notifications__c.getOrgDefaults();

            // make user custom settings is set up
            if ( notifSettings.Expired_Notification__c != null && notifSettings.Pending_Notification__c != null && lastmodified != null ) {

                // pending date
                Date pendingDate = ( Date.today() - Integer.valueOf( notifSettings.Pending_Notification__c ) );

                // expired date
                Date expiredDate = Date.today() - Integer.valueOf( notifSettings.Expired_Notification__c );

                // system.debug( 'lastmodified' + getStringDate( lastmodified ) );
                // system.debug( 'pendingDate' + getDateFormat( pendingDate ) );
                // system.debug( 'expiredDate' + getDateFormat( expiredDate ) );

                // pending process
                if ( getStringDate( lastmodified ) == getDateFormat( pendingDate ) ) {

                    System.debug( 'go here' );
                    
                    // send pending notifcation
                    sendNotification( e, false );

                    // creation of task
                    Task t = taskBuild( e, false );
                    taskList.add( t );
 
                    // enrolment update
                    e.AS_Pending_notification_sent__c = true;
                    listEnrol.add( e );
                }

                // expired process
                if ( getStringDate( lastmodified ) == getDateFormat( expiredDate ) ) {

                    System.debug( 'go here expired' );

                    // send expired notifcation
                    sendNotification( e, true );
                    
                    // creation of task
                    Task t = taskBuild( e, true );
                    taskList.add( t );

                    // enrolment update
                    e.AS_Expired_notification_sent__c = true;
                    e.Enrolment_Status__c = 'Expired';
                    listEnrol.add( e );
                }

            } else {
                System.debug( 'Custom Settings is not setup or last modified date is not defined!' );
            }

        }

        try {

            // insert tasks
            if ( taskList.size() > 0 ) {
                insert taskList;
                System.debug('taskList' + taskList);
            }

            // enrol update
            if ( listEnrol.size() > 0 ) {
                update listEnrol;
                //System.debug('listEnrol' + listEnrol);
            }
             
        } catch( Exception et ) {
            system.debug( 'dml exception'+et );
        }
 
    }

    /**
    * build task data to be created
    * @param e Enrolment_Form__c, enrolment data from query
    * @param isExpired Boolean, indicator if it is a pending or expired
    * @return Task object, task object data being constructed
    */
    private Task taskBuild( Enrolment_Form__c e, Boolean isExpired ) {
        Task t = new Task();
        t.Subject = ( isExpired ? 'Expired enrolment email sent' : 'Pending enrolment email sent' );
        t.WhoId = e.AS_Account__r.AS_PersonAccount_ContactID__c;
        t.WhatId = e.Id;
        t.Status = 'Completed';
        t.Priority = 'Normal';
        t.ActivityDate = Date.today();
        return t;
    }

    /**
    * send notifcation 
    * @param e Enrolment_Form__c, enrolment data from query
    * @param isExpired Boolean, indicator if it is a pending or expired
    * @return
    */
    private static void sendNotification( Enrolment_Form__c e, Boolean isExpired ) {

        try {

            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

            message.setTargetObjectId(e.AS_Account__r.AS_PersonAccount_ContactID__c); 
            message.setSenderDisplayName('PSA'); 
            message.setReplyTo('noreply@psa.org.au');
            message.setUseSignature(false); 
            message.setBccSender(false); 
            message.setSaveAsActivity(false); 

            EmailTemplate emailTemplate = new EmailTemplate();
            
            if ( isExpired ) {
                emailTemplate = [SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE name = 'Expired enrolment email'];
            } else {
                emailTemplate = [SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE name = 'Pending enrolment email'];
            }
            
            message.setTemplateID( emailTemplate.Id ); 
            message.setWhatId( e.Id ); //This is important for the merge fields in template to work
            message.toAddresses = new String[] { e.AS_Account__r.PersonEmail };

            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    
            if (results[0].success)  {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: ' +  results[0].errors[0].message);
            }

        } catch( Exception ssse ) {
            System.debug( 'email exception'+ssse );
        }

    }

    /*
    * string format for date ( 'yyyy-MM-dd' )
    * @param dateDate String, date value to be converted to string format
    * @return String format of date
    */
    private String getStringDate( Datetime dateDate ) {
        return DateTime.newInstance(
            dateDate.year(), dateDate.month(), dateDate.day()
        ).format( 'yyyy-MM-dd' );
    }

    /*
    * string format for date ( 'yyyy-MM-dd' )
    * @param d Date, date value to be converted to string format
    * @return String format of date
    */
    private String getDateFormat( Date day ) {
        Integer m = day.month();
        String mStr = String.valueOf( m );
        if ( m < 10 ) {
            mStr = '0' + mStr;
        }
        
        Integer d = day.day();
		String dStr = String.valueOf( d );
        if ( d < 10 ) {
            dStr = '0' + dStr;
        }
	
        return day.year() + '-' + mStr + '-' + dStr;
    }

}