public class AS_batchMembershipRenewalT5T6T7 implements Database.Batchable < sObject > , Database.Stateful {


    public AS_batchMembershipRenewalT5T6T7() {

    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        Membership_End_Date_Renewal__c medr = Membership_End_Date_Renewal__c.getInstance();
        set < Date > dateCarteriaSet = new set < Date > ();

        if (medr.T5__c != null && medr.T5__c >= 0) {
            dateCarteriaSet.add(system.today().addDays((Integer.valueOf(medr.T5__c) != null ? -1 * (Integer.valueOf(medr.T5__c)) : 0)));
        }

        if (medr.T6__c != null && medr.T6__c >= 0) {
            dateCarteriaSet.add(system.today().addDays((Integer.valueOf(medr.T6__c) != null ? -1 * (Integer.valueOf(medr.T6__c)) : 0)));
        }

        if (medr.T7__c != null && medr.T7__c >= 0) {
            dateCarteriaSet.add(system.today().addDays((Integer.valueOf(medr.T7__c) != null ? -1 * (Integer.valueOf(medr.T7__c)) : 0)));
        }
        String type = 'Member';
        Set < String > allowedStatusSet = new Set < String > {
            'Current',
            'Grace Period' 
        }; 
        System.debug('THE QUERY : SELECT Id,AS_Auto_Renew__c,Account__r.PersonContactId,AS_Start_Date__c,AS_Type__c,Name FROM AS_Subscription__c WHERE  AS_Type__c =' + type + ' and AS_End_Date__c IN ' + dateCarteriaSet);
        String QuerySTring = 'SELECT ' +
            'Id,AS_Auto_Renew__c,Account__r.PersonContactId ,AS_End_Date__c,AS_Frequency__c,' +
            'AS_Membership_Span__c,AS_Membership_Status__c,' +
            'AS_Opportunity__c,AS_Payment_Source__c,' + 
            'AS_Product__c,AS_Quantity__c,' +
            'AS_Start_Date__c,AS_Type__c,Name ' +
            'FROM AS_Subscription__c WHERE  AS_Membership_Status__c IN :allowedStatusSet AND AS_Type__c =:type and AS_End_Date__c IN :dateCarteriaSet';  
         
        if (dateCarteriaSet.size() > 0) {
            return Database.getQueryLocator(QuerySTring); 
        } else { 
            return null;
        } 
    }

    public void execute(Database.BatchableContext BC, List < AS_Subscription__c > scope) {

        System.debug(' scope : ' + scope);
        Membership_End_Date_Renewal__c medr = Membership_End_Date_Renewal__c.getInstance();
        list < AS_Subscription__c > subOppSendRenew = new list < AS_Subscription__c > ();

        List < OrgWideEmailAddress > owea = [select Id, Address from OrgWideEmailAddress where Address = 'noreply@psa.org.au'];

        for (AS_Subscription__c subscription: scope) {
            subOppSendRenew.add(subscription);
        }

        System.debug(' subOppSendRenew ' + subOppSendRenew);

        List < Messaging.SingleEmailMessage > allmsg = new List < Messaging.SingleEmailMessage > ();
        EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'AS_Send_Email_of_Automatic_Renewal_T5_1']; // for PSA-276
        EmailTemplate et_1 = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'AS_Send_Renewal_Notice_Email1']; // for PSA-276

        for (AS_Subscription__c sub: subOppSendRenew) {

            //Email Template : AS_Send_Email_of_Automatic_Renewal_T5_1
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(et.Id);
            mail.setTargetObjectId(sub.Account__r.PersonContactId);
            mail.setWhatId(sub.Id);

            if (owea.size() > 0) {
              mail.setorgWideEmailAddressId(owea[0].Id); 
            }

            //Email Template :  AS_Send_Renewal_Notice_Email1
            Messaging.SingleEmailMessage mail_1 = new Messaging.SingleEmailMessage();
            mail_1.setTemplateId(et_1.Id);
            mail_1.setTargetObjectId(sub.Account__r.PersonContactId);
            mail_1.setWhatId(sub.Id);

            if (owea.size() > 0) {
              mail_1.setorgWideEmailAddressId(owea[0].Id);
            }

            mail.setSaveAsActivity(false);
            mail_1.setSaveAsActivity(false);
            allmsg.add(mail);
            allmsg.add(mail_1);

        }

        Messaging.SendEmailResult[] sendEmail = Messaging.sendEmail(allmsg,false);   
        System.debug('email Result : ' + sendEmail.size());
    }

    public void finish(Database.BatchableContext BC) { 


    }
}