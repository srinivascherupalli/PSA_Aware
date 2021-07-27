// ============================================================================================= 
//  Object:   Contract
//  Company: The Aware Group
//  Author: Kay Jin 
//  Purpose:  autorenew
//  Methods:  
//              
//  Created:  
// ============================================================================================= 
//  Use Cases or Requirements: 
//  @UseCase number - @requirement Description      
// ============================================================================================= 
//  Changes: @Date Author
//           @Description
// ============================================================================================= 

global class CPQ_RenewContractsBatch implements Database.Batchable<SObject>, Database.Stateful {
    global Integer recordsProcessed = 0;

    global Database.QueryLocator start(Database.BatchableContext bc){

        return Database.getQueryLocator(
            //This is where you input the conditions for the records which you wish to set renewal for 
            //'SELECT ITP_Enddate__c, SBQQ__RenewalForecast__c, SBQQ__RenewalQuoted__c, Id FROM Contract WHERE SBQQ__RenewalForecast__c = FALSE AND SBQQ__RenewalQuoted__c = FALSE AND (CreateRenewalDate__c = TODAY  )'
            //Updated by Fortino 3 June 2021 to check for Auto Renew in the Contract = True and if migrated contract then pick those with early date than today too
            //Updated by Bram 4 June 2021 to identify that the Contract has been auto-renewed
            //'SELECT ITP_Enddate__c, SBQQ__RenewalForecast__c, SBQQ__RenewalQuoted__c, Id FROM Contract WHERE SBQQ__RenewalForecast__c = FALSE AND SBQQ__RenewalQuoted__c = FALSE AND Auto_Renew__c = TRUE AND ((CreateRenewalDate__c = TODAY) OR (CPQMigrate__c = TRUE AND CreateRenewalDate__c <= TODAY))'
            //SOQL Updated by Fortino 4 June 2021 to also retrieve contracts for Life Members
            //'SELECT ITP_Enddate__c, SBQQ__RenewalForecast__c, SBQQ__RenewalQuoted__c, Id FROM Contract WHERE SBQQ__RenewalForecast__c = FALSE AND SBQQ__RenewalQuoted__c = FALSE AND ( (Auto_Renew__c = TRUE AND ((CreateRenewalDate__c = TODAY) OR (CPQMigrate__c = TRUE AND CreateRenewalDate__c <= TODAY)    )) OR (Account.PersonContact.CPQ_Membership_Product__c IN (\'PSA Membership – Life Members\', \'PSA Membership – Life Fellows\', \'PSA Membership – Honorary Member\', \'PSA Membership – Honorary Fellow\', \'PSA Membership – Complimentary\')    AND Account.PersonContact.CPQ_Membership_Status__c != \'Former\' AND CreateRenewalDate__c = TODAY   ))'            
            //SOQL Updated by Fortino 10 June 2021 to only run once for Migrated records
            //'SELECT ITP_Enddate__c, SBQQ__RenewalForecast__c, SBQQ__RenewalQuoted__c, Id FROM Contract WHERE SBQQ__RenewalForecast__c = FALSE AND SBQQ__RenewalQuoted__c = FALSE AND ( (Auto_Renew__c = TRUE AND ((CreateRenewalDate__c = TODAY) OR (CPQMigrate__c = TRUE AND CreateRenewalDate__c <= TODAY AND Auto_Renewed_Contract__c = FALSE)    )) OR (Account.PersonContact.CPQ_Membership_Product__c IN (\'PSA Membership – Life Members\', \'PSA Membership – Life Fellows\', \'PSA Membership – Honorary Member\', \'PSA Membership – Honorary Fellow\', \'PSA Membership – Complimentary\')    AND Account.PersonContact.CPQ_Membership_Status__c != \'Former\' AND CreateRenewalDate__c = TODAY   ))'            
            //'SELECT ITP_Enddate__c, SBQQ__RenewalForecast__c, SBQQ__RenewalQuoted__c, Id FROM Contract WHERE SBQQ__RenewalForecast__c = FALSE AND SBQQ__RenewalQuoted__c = FALSE AND CreateRenewalDate__c = TODAY AND ( Auto_Renew__c = TRUE OR (Account.PersonContact.CPQ_Membership_Product__c IN (\'PSA Membership – Life Members\', \'PSA Membership – Life Fellows\', \'PSA Membership – Honorary Member\', \'PSA Membership – Honorary Fellow\', \'PSA Membership – Complimentary\') AND Account.PersonContact.CPQ_Membership_Status__c != \'Former\' ) )'
            //SOQL Updated by Fortino 24th June 2021 to add conditions
            //'SELECT ITP_Enddate__c, SBQQ__RenewalForecast__c, SBQQ__RenewalQuoted__c, Id FROM Contract WHERE SBQQ__RenewalForecast__c = FALSE AND SBQQ__RenewalQuoted__c = FALSE AND CreateRenewalDate__c = TODAY AND Account.PSA_Subscription__r.Status__c = \'Current\' AND Account.PSA_Effective_Date__c = TRUE AND (Auto_Renew__c = TRUE OR (Account.PSA_Subscription__r.Product__r.Name IN (\'PSA Membership – Life Members\', \'PSA Membership – Life Fellows\', \'PSA Membership – Honorary Member\', \'PSA Membership – Honorary Fellow\', \'PSA Membership – Complimentary\') ) )'

            //SOQL Updated by Fortino 5th July 2021 to remove Auto renewal and product conditions: all memberships are autorenewed
            'SELECT ITP_Enddate__c, SBQQ__RenewalForecast__c, SBQQ__RenewalQuoted__c, Id FROM Contract WHERE SBQQ__RenewalForecast__c = FALSE AND SBQQ__RenewalQuoted__c = FALSE AND CreateRenewalDate__c = TODAY AND Account.PSA_Subscription__r.Status__c = \'Current\' AND Account.PSA_Effective_Date__c = TRUE'

        );
    }
    global void execute(Database.BatchableContext bc, List<Contract> scope){

        for(Contract contract:scope){
            contract.SBQQ__RenewalQuoted__c= TRUE;
            contract.Auto_Renewed_Contract__c= TRUE;
            recordsProcessed = recordsProcessed + 1;
        }
        update scope;

    }
    global void finish(Database.BatchableContext bc){
       // Get the ID of the AsyncApexJob representing this batch job
       // from Database.BatchableContext.
       // Query the AsyncApexJob object to retrieve the current job's information.
       /*
       AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
          TotalJobItems, CreatedBy.Email
          FROM AsyncApexJob WHERE Id =
          :BC.getJobId()];
       // OPTIONAL: Send an email to the Apex job's submitter notifying of job completion.
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {a.CreatedBy.Email};
       mail.setToAddresses(toAddresses);
       mail.setSubject('Contract Renewal Batch ' + a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
       */
    }
}