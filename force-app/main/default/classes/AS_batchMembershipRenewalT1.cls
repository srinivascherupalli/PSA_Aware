/*
* Author : WEW
* Description: batch process to check for T1 membership renewal
* Parameter : 
* Return : 
*/
public class AS_batchMembershipRenewalT1 implements Database.batchable<SObject>,Database.Stateful{
    
    private String errorMessage = '';
    
    public AS_batchMembershipRenewalT1() {
        isEnabled=true;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        Membership_End_Date_Renewal__c renew = Membership_End_Date_Renewal__c.getOrgDefaults();
        Date entranceDate = (renew.T1__c!=null)?Date.today().addDays(Integer.valueOf(renew.T1__c)):null;
        Date lastDate = (renew.T1__c!=null)?Date.today().addDays(Integer.valueOf(renew.T1__c+1)):null;
        
        if(entranceDate !=null && renew.T1__c>=0){
            String memberStatus = 'Current'; 
            return Database.getQueryLocator('Select Id,Name,Account__c,Account__r.Name,Account__r.PersonContactId,AS_Payment_Source__c,AS_End_Date__c,AS_Auto_Renew__c,AS_Price_Book__c,AS_Product__c,AS_Product__r.AS_Renewal_Product__c from AS_Subscription__c where AS_End_Date__c >=:entranceDate AND AS_End_Date__c < :lastDate AND AS_Membership_Status__c =:memberStatus AND AS_Type__c =\'Member\'');
        } else {
            return null; 
        }
    }
 
    public void execute(Database.BatchableContext BC, List<AS_Subscription__c> scope) {
        Savepoint sp = Database.setSavepoint();
        try {
            Set<Id> allProdSet = new Set<Id>();
            Set<Id> allPrBookSet = new Set<Id>();
            List<Id> allProdList = new List<Id>();
            List<Id> allPrBookList = new List<Id>();
            for(AS_Subscription__c subs : scope) {
                if(subs.AS_Product__r.AS_Renewal_Product__c!=null) {
                    allProdSet.add(subs.AS_Product__r.AS_Renewal_Product__c);
                } else if(subs.AS_Product__c != null){
                    allProdSet.add(subs.AS_Product__c);
                }
                
                if(subs.AS_Price_Book__c != null) {
                    allPrBookSet.add(subs.AS_Price_Book__c);
                }
            }
            
            System.debug('allProdSet :' + allProdSet);
            System.debug('allPrBookSet :' + allPrBookSet);
            
            List<OrgWideEmailAddress> owea = [select Id,Address from OrgWideEmailAddress where Address = 'noreply@psa.org.au'];
        
            Map<String,double> prodPreEntry = new Map<String,double>();
            for(PricebookEntry prBookEntry : [Select Id,Name,Product2Id,Pricebook2Id,UnitPrice from PricebookEntry where Product2Id IN :allProdSet AND Pricebook2Id IN :allPrBookSet]) {
                if(prBookEntry.Product2Id != null && prBookEntry.Pricebook2Id != null) {
                    prodPreEntry.put(String.valueOf(prBookEntry.Product2Id).toLowerCase()+String.valueOf(prBookEntry.Pricebook2Id).toLowerCase(),(prBookEntry.UnitPrice!=null?prBookEntry.UnitPrice:0));
                }
            }
            
            Id memberRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();
            
            EmailTemplate emailTempNotice = [SELECT Id FROM EmailTemplate WHERE DeveloperName ='AS_Send_Renewal_Notice_Email1'];
            EmailTemplate emailTempAutoRenew = [SELECT Id FROM EmailTemplate WHERE DeveloperName ='PSA_Send_Email_of_Automatic_Renewal_1'];
            
            List<AS_Subscription__c> allSubsToUpdate = new List<AS_Subscription__c>();
            List<Opportunity> allOppToInsert = new List<Opportunity>();
            List<OpportunityLineItem> allOppLineList = new List<OpportunityLineItem>();
            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
            
            for(AS_Subscription__c sub : scope) {
                if( sub.AS_End_Date__c != null && ((sub.AS_Product__r.AS_Renewal_Product__c!=null && sub.AS_Product__r.AS_Renewal_Product__c != null) || (sub.AS_Product__c!=null && sub.AS_Product__c != null)) && sub.AS_Price_Book__c != null ) {
                    try {
                        String THERANDOMSTRING = AS_commonFunction.generateRandomString(40);
                        AS_Subscription__c indiSubs = new AS_Subscription__c();
                        
                        Opportunity opp = new Opportunity();
                        opp.Name = sub.Account__r.Name + ' Membership'; 
                        opp.Pricebook2Id = sub.AS_Price_Book__c;
                        opp.CloseDate = sub.AS_End_Date__c.addDays(1); // for PSA-276
                        opp.AS_PSA_Subscription__c = sub.Id;
                        opp.StageName = 'Pending';
                        opp.Generate_Order__c = true; // for PSA-325
                        opp.AS_Create_Subscription__c = false;
                        opp.RecordTypeId = memberRecordTypeId;
                        opp.AccountId = sub.Account__c;
                        opp.ASPHPP__Payment_Source__c = sub.AS_Payment_Source__c;
                        
                        Opportunity referenceOpp  =   new Opportunity();
                        referenceOpp.AS_extID__c          =   THERANDOMSTRING;
                        
                        opp.AS_extID__c = THERANDOMSTRING; 
                        
                        // to update subscription starts here
                        indiSubs.Id = sub.Id;
                        indiSubs.AS_Opportunity__r = referenceOpp;
                        allSubsToUpdate.add(indiSubs);
                        // to update subscription starts here
                        
                        
                        OpportunityLineItem indiOppLine = new OpportunityLineItem();
                        indiOppLine.Opportunity = referenceOpp;
                        indiOppLine.quantity =1;
                        if(sub.AS_Product__r.AS_Renewal_Product__c!=null) {
                            indiOppLine.Product2Id  = sub.AS_Product__r.AS_Renewal_Product__c;
                            indiOppLine.UnitPrice  = prodPreEntry.get(String.valueOf(sub.AS_Product__r.AS_Renewal_Product__c).toLowerCase()+String.valueOf(sub.AS_Price_Book__c).toLowerCase());
                            
                            opp.AS_Product__c = sub.AS_Product__r.AS_Renewal_Product__c;
                            opp.AS_Product_Price__c = prodPreEntry.get(String.valueOf(sub.AS_Product__r.AS_Renewal_Product__c).toLowerCase()+String.valueOf(sub.AS_Price_Book__c).toLowerCase());
                        } else if(sub.AS_Product__c != null){
                            indiOppLine.Product2Id  = sub.AS_Product__c;
                            indiOppLine.UnitPrice  = prodPreEntry.get(String.valueOf(sub.AS_Product__c).toLowerCase()+String.valueOf(sub.AS_Price_Book__c).toLowerCase());
                            
                            opp.AS_Product__c = sub.AS_Product__c;
                            opp.AS_Product_Price__c = prodPreEntry.get(String.valueOf(sub.AS_Product__c).toLowerCase()+String.valueOf(sub.AS_Price_Book__c).toLowerCase());
                        }
                        
                        allOppLineList.add(indiOppLine);
                        
                        // email part starts here
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        
                        if(sub.AS_Auto_Renew__c == true) {
                            mail.setTemplateId(emailTempAutoRenew.Id);
                        } else {
                            mail.setTemplateId(emailTempNotice.Id);
                        }
                        
                        if(owea.size()>0) {
                            mail.setorgWideEmailAddressId(owea[0].Id);
                        }
                        
                        mail.setTargetObjectId(sub.Account__r.PersonContactId);
                        mail.setWhatId(sub.Id);
                        mail.setSaveAsActivity(false);
                        allmsg.add(mail);
                        
                        // email part end here
                        
                        
                        allOppToInsert.add(opp);
                    } catch(Exception ex) {
                        errorMessage += '\n\r'+ sub.Id + ' record : ' + ex.getMessage() + ' - Line :' + ex.getLineNumber();
                    }
                } else {
                    errorMessage += '\n\r'+ sub.Id + ' record, must have end date, pricebook and product to create a new renewal opportunity.';
                }
            }
            System.debug('allSubsToUpdate : ' + allSubsToUpdate);
            System.debug('allOppLineList : ' + allOppLineList);
            System.debug('allOppToInsert : ' + allOppToInsert);
            System.debug('allmsg : ' + allmsg);
            
            insert allOppToInsert;
            insert allOppLineList;
            update allSubsToUpdate;
            
            //Messaging.SendEmailResult[] wew= Messaging.sendEmail(allmsg,false);
            
            //System.debug('email result : '+ wew);
        } catch (Exception e) {
            System.debug('Batch RES : '+ e);
            Database.rollback(sp);
            errorMessage +=  '\n\r' + e.getMessage() + ' - Line :' + e.getLineNumber();
        }
        
    }
    
    public void finish(Database.BatchableContext BC) {
         try {
           if(String.isNotBlank(errorMessage)) { 
            AsyncApexJob batchResult = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];    
           // Email the Batch Job's submitter that the Job is finished.  
           Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
           String[] toAddresses = new String[] {batchResult.CreatedBy.Email};
           mail.setToAddresses(toAddresses);  
           mail.setSubject('batch Membership Renewal T1');  
           String theEmailBody = ''; 
              theEmailBody += 'This email is to notify you that your recent batch of membership renewal encounter a problem.\n\r'; 
              theEmailBody += 'ERROR : \n';
              theEmailBody += errorMessage + '\n\r';
              
              mail.setPlainTextBody(theEmailBody);  
              
               Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
           }
        } catch(Exception e) {
            
        }
    } 
 

    public String processMessage {get;set;}
    public boolean isEnabled {get;set;}

    @remoteAction
    public static  AS_Subscription__c checkingOppId( Id memSubscriptionId ) { 

        AS_Subscription__c sub = [Select Id,AS_Opportunity__c from AS_Subscription__c where Id =:memSubscriptionId];
        
        return sub;   

    } 
     
    /*Author : John Hope
    *Description : this method is use to create renewal opportunity when clicking a button in membership subscription layout
    *Date Created : 
    *Last Modified By : John Hope
    *Date Last Modified :
     *Param : 
     *Return : 
     */ 
    @remoteAction
    @AuraEnabled 
    public static singleRenewalResWrapper createRenewalOppViaButton(Id memSubscriptionId) {
        AS_Subscription__c sub = [Select Id,Name,AS_Membership_Status__c,Account__c,Account__r.Name,Account__r.PersonContactId,AS_Payment_Source__c,AS_End_Date__c,AS_Auto_Renew__c,AS_Price_Book__c,AS_Product__c,AS_Product__r.AS_Renewal_Product__c from AS_Subscription__c where Id =:memSubscriptionId];
        
        if( sub.AS_End_Date__c != null && ((sub.AS_Product__r.AS_Renewal_Product__c!=null && sub.AS_Product__r.AS_Renewal_Product__c != null) || (sub.AS_Product__c!=null && sub.AS_Product__c != null)) && sub.AS_Price_Book__c != null && sub.AS_Membership_Status__c == 'Current') {
            Date oppEndDate = sub.AS_End_Date__c.addDays(1); // for PSA-276
            List<Opportunity> existingOpp = [Select Id from Opportunity where CloseDate = :oppEndDate and AS_PSA_Subscription__c = :memSubscriptionId];
            // if size is 0 data will be created
            if(existingOpp.size() == 0) {
            try {
                        Set<Id> allProdSet = new Set<Id>();
                    Set<Id> allPrBookSet = new Set<Id>();
                    
                    if(sub.AS_Product__r.AS_Renewal_Product__c!=null) {
                        allProdSet.add(sub.AS_Product__r.AS_Renewal_Product__c);
                    } else if(sub.AS_Product__c != null){
                        allProdSet.add(sub.AS_Product__c);
                    }
                    
                    allPrBookSet.add(sub.AS_Price_Book__c);
                    
                    System.debug('allProdSet :' + allProdSet);
                    System.debug('allPrBookSet :' + allPrBookSet);
                        
                    Map<String,double> prodPreEntry = new Map<String,double>();
                    for(PricebookEntry prBookEntry : [Select Id,Name,Product2Id,Pricebook2Id,UnitPrice from PricebookEntry where Product2Id IN :allProdSet AND Pricebook2Id IN :allPrBookSet]) {
                        if(prBookEntry.Product2Id != null && prBookEntry.Pricebook2Id != null) {
                            prodPreEntry.put(String.valueOf(prBookEntry.Product2Id).toLowerCase()+String.valueOf(prBookEntry.Pricebook2Id).toLowerCase(),(prBookEntry.UnitPrice!=null?prBookEntry.UnitPrice:0));
                        }
                    }
                        
                    Id memberRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();
                    
                    
                    List<AS_Subscription__c> allSubsToUpdate = new List<AS_Subscription__c>();
                    List<Opportunity> allOppToInsert = new List<Opportunity>();
                    List<OpportunityLineItem> allOppLineList = new List<OpportunityLineItem>();
                    List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                    String THERANDOMSTRING = AS_commonFunction.generateRandomString(40);
                    AS_Subscription__c indiSubs = new AS_Subscription__c();
                    
                    Opportunity opp = new Opportunity();
                    opp.Name = sub.Account__r.Name + ' Membership'; 
                    opp.Pricebook2Id = sub.AS_Price_Book__c;
                    opp.CloseDate = sub.AS_End_Date__c.addDays(1); // for PSA-276
                    opp.AS_PSA_Subscription__c = sub.Id;
                    opp.StageName = 'Pending';
                    opp.Generate_Order__c = true; // for PSA-325
                    opp.AS_Create_Subscription__c = false;
                    opp.RecordTypeId = memberRecordTypeId;
                    opp.AccountId = sub.Account__c;
                    opp.ASPHPP__Payment_Source__c = sub.AS_Payment_Source__c;
                    
                    Opportunity referenceOpp  =   new Opportunity();
                    referenceOpp.AS_extID__c          =   THERANDOMSTRING;
                    
                    opp.AS_extID__c = THERANDOMSTRING; 
                    
                    // to update subscription starts here
                    indiSubs.Id = sub.Id;
                    indiSubs.AS_Opportunity__r = referenceOpp;
                    allSubsToUpdate.add(indiSubs);
                    // to update subscription starts here
                    
                    
                    OpportunityLineItem indiOppLine = new OpportunityLineItem();
                    indiOppLine.Opportunity = referenceOpp;
                    indiOppLine.quantity =1;
                    if(sub.AS_Product__r.AS_Renewal_Product__c!=null) {
                        indiOppLine.Product2Id  = sub.AS_Product__r.AS_Renewal_Product__c;
                        indiOppLine.UnitPrice  = prodPreEntry.get(String.valueOf(sub.AS_Product__r.AS_Renewal_Product__c).toLowerCase()+String.valueOf(sub.AS_Price_Book__c).toLowerCase());
                        
                        opp.AS_Product__c = sub.AS_Product__r.AS_Renewal_Product__c;
                        opp.AS_Product_Price__c = prodPreEntry.get(String.valueOf(sub.AS_Product__r.AS_Renewal_Product__c).toLowerCase()+String.valueOf(sub.AS_Price_Book__c).toLowerCase());
                    } else if(sub.AS_Product__c != null){
                        indiOppLine.Product2Id  = sub.AS_Product__c;
                        indiOppLine.UnitPrice  = prodPreEntry.get(String.valueOf(sub.AS_Product__c).toLowerCase()+String.valueOf(sub.AS_Price_Book__c).toLowerCase());
                        
                        opp.AS_Product__c = sub.AS_Product__c;
                        opp.AS_Product_Price__c = prodPreEntry.get(String.valueOf(sub.AS_Product__c).toLowerCase()+String.valueOf(sub.AS_Price_Book__c).toLowerCase());
                    }
                
                    allOppLineList.add(indiOppLine);
                    allOppToInsert.add(opp);
                    
                    System.debug('allOppToInsert : ' + allOppToInsert);
                    System.debug('allOppLineList : ' + allOppLineList);
                    System.debug('allSubsToUpdate : ' + allSubsToUpdate);
                    
                    insert allOppToInsert;
                    insert allOppLineList; 
                    update allSubsToUpdate;

                    System.debug('allSubsToUpdate : ' + allSubsToUpdate); 
                
                    return new singleRenewalResWrapper(memSubscriptionId,true,'Successfully created a new renewal opportunity.');
                } catch(Exception ex) {
                    return new singleRenewalResWrapper(null,false,'An error occurred during the process please contact the administrator.' +ex.getMessage());
                }
            } else {
                return new singleRenewalResWrapper(null,false,'An existing opportunity renewal was found during the process.');
            }
        } else {
            return new singleRenewalResWrapper(null,false,'This record must have end date, pricebook, product and status must be current to create a new renewal opportunity.');
        }
    }
    
    /*
    * Author : john hope
    * Description: wrapper class for certificate creation response
    * Parameter : None
    * Return : None
    */
    public class singleRenewalResWrapper {  
        @AuraEnabled public Boolean isSuccess {get; set;}
        @AuraEnabled public String ErrorMessage {get;set;}
        @AuraEnabled public Id OppId {get;set;}
        public singleRenewalResWrapper(Id oppId,Boolean suc,String err) {
            isSuccess = suc;
            OppId = oppId;
            ErrorMessage = err;
        }
    }
}