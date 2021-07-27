/*
* Author : WEW
* Description: trigger to check if first payment for renewal is successful or not
* Parameter : None
* Return : None
*/
trigger AS_checkRenewFirstPayment on ASPHPP__Payment__c (after insert,after update) {
    
    Set<Id> setSubsId = new Set<Id>();
    List<Id> listSubsId = new List<Id>();
    
    Set<Id> setMemSubsId = new Set<Id>();
    List<Id> listMemSubsId = new List<Id>();
    for(ASPHPP__Payment__c pay : trigger.new){
        setSubsId.add(pay.ASPHPP__PSubscription__c);
        setMemSubsId.add(pay.AS_Subscription__c);
    }
    listSubsId.addAll(setSubsId);
    listMemSubsId.addAll(setMemSubsId);
    
    Map<String,ASPHPP__Subscription__c> allMapSubs = new  Map<String,ASPHPP__Subscription__c>();
    
    Id bankRecordTypeId = Schema.SObjectType.ASPHPP__ASPayment_Source__c.getRecordTypeInfosByName().get('Bank Account').getRecordTypeId();
    
    for(ASPHPP__Subscription__c sub : [Select Id,AS_opportunity__r.Pricebook2.AS_X6_Month_Subscription__c,Name,AS_forRenewalFirstPayment__c,AS_opportunity__c,AS_opportunity__r.StageName,AS_Subscription__c,AS_Subscription__r.AS_Opportunity__c,AS_Subscription__r.Account__r.PersonContactId,ASPHPP__Payment_Source__r.recordTypeId from ASPHPP__Subscription__c where Id IN :listSubsId]){
        /*
        Id one  = (sub.AS_opportunity__c!=null)? sub.AS_opportunity__c:null;
        Id two  = (sub.AS_Subscription__r.AS_Opportunity__c!=null)? sub.AS_Subscription__r.AS_Opportunity__c:null;
        Id four = (sub.AS_Subscription__r.Account__r.PersonContactId!=null)? sub.AS_Subscription__r.Account__r.PersonContactId:null;
        allMapSubs.put(sub.Id,new List<Object>{one,two,sub.AS_forRenewalFirstPayment__c,four});
        */
        allMapSubs.put(String.valueOf(sub.Id).toLowerCase(),sub);
    }
    
    System.debug('allMapSubs :' + allMapSubs);
    
    EmailTemplate emailTempErrorPay = [SELECT Id FROM EmailTemplate WHERE DeveloperName ='AS_Failed_Payment_Email'];
    
    List<OrgWideEmailAddress> owea = [select Id,Address from OrgWideEmailAddress where Address = 'noreply@psa.org.au'];
    
    Map<Id,boolean> subsHasPayment = new Map<Id,Boolean>();
    Map<Id,boolean> oppHasPayment = new Map<Id,Boolean>();
    List<ASPHPP__Subscription__c> allUpdatePSubs = new List<ASPHPP__Subscription__c>(); 
    List<Opportunity> allUpdateOpp = new List<Opportunity>();
    List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
    for(ASPHPP__Payment__c pay : trigger.new){
        if(pay.ASPHPP__PSubscription__c!= null && allMapSubs.containsKey(String.valueOf(pay.ASPHPP__PSubscription__c).toLowerCase())){
            ASPHPP__Subscription__c tempSub = allMapSubs.get(String.valueOf(pay.ASPHPP__PSubscription__c).toLowerCase());
            System.debug('tempSub :' + tempSub);
            System.debug('subsHasPayment :' + subsHasPayment);
            System.debug('oppHasPayment :' + oppHasPayment);
            Id opp1 = (tempSub.AS_opportunity__c!=null)?tempSub.AS_opportunity__c:null; 
            Id opp2 = (tempSub.AS_Subscription__r.AS_Opportunity__c!=null)?tempSub.AS_Subscription__r.AS_Opportunity__c:null;
            Boolean forRenew = tempSub.AS_forRenewalFirstPayment__c;
            Id emailConId = (tempSub.AS_Subscription__r.Account__r.PersonContactId!=null)?tempSub.AS_Subscription__r.Account__r.PersonContactId:null;
            System.debug('opp1 =>'+opp1);
            System.debug('opp2 =>'+opp2);
            System.debug('forRenew =>'+forRenew);
            System.debug('subsHasPayment =>'+subsHasPayment +' => '+subsHasPayment.containsKey(pay.ASPHPP__PSubscription__c)  );
            System.debug('oppHasPayment =>'+oppHasPayment +' => '+oppHasPayment.containsKey(opp1));
            if((opp1!=null && opp1 == opp2) && forRenew == false && !subsHasPayment.containsKey(pay.ASPHPP__PSubscription__c) && !oppHasPayment.containsKey(opp1)) {
            		System.debug('condition 1');
                if(pay.ASPHPP__Payment_Status__c == 'Failed' || pay.ASPHPP__Payment_Status__c == 'Success') {
                		System.debug('condition 1 A');
                    subsHasPayment.put(pay.ASPHPP__PSubscription__c,true);
                    oppHasPayment.put(opp1,true);
                     
                    ASPHPP__Subscription__c indiUpdatePSubs = new ASPHPP__Subscription__c();
                    indiUpdatePSubs.Id = pay.ASPHPP__PSubscription__c;
                    indiUpdatePSubs.AS_forRenewalFirstPayment__c = true;
                    
                    Opportunity indiOpp = new Opportunity();
                    indiOpp.Id = opp1;
                    indiOpp.StageName = 'Closed Won';
                    if(pay.ASPHPP__Payment_Status__c == 'Success') {
                        indiOpp.CloseDate = Date.today();
                        
                    // added for updating the payment subscription once the opportunity is closed won starts here 12/10/18 (#PSA-332)                   
                    if(tempSub.AS_opportunity__r.Pricebook2.AS_X6_Month_Subscription__c == true) {
                        indiUpdatePSubs.ASPHPP__End_Date__c = Date.today().addDays(170); 
		                } else {
		                    indiUpdatePSubs.ASPHPP__End_Date__c = Date.today().addDays(364);
		                }
		                // added for updating the payment subscription once the opportunity is closed won ends here 12/10/18 (#PSA-332)
                    }
                    allUpdatePSubs.add(indiUpdatePSubs);
                    allUpdateOpp.add(indiOpp);
                }
                // commented as per michelle request for ticket PSA-325
                /*
                if(pay.ASPHPP__Payment_Status__c == 'Failed' && emailConId != null) {
                		System.debug('condition 1 B');
                		
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        
                    mail.setTemplateId(emailTempErrorPay.Id);
                    
                    mail.setTargetObjectId(emailConId);
                    
                    if(owea.size()>0) {
                        mail.setorgWideEmailAddressId(owea[0].Id);
                    }
                    
                    mail.setSaveAsActivity(false);
                    allmsg.add(mail);
                }
                */
            } else if(tempSub.ASPHPP__Payment_Source__r.recordTypeId == bankRecordTypeId && opp1!=null && pay.ASPHPP__Payment_Status__c == 'Success' && (tempSub.AS_opportunity__r.StageName != 'Closed Won' && tempSub.AS_opportunity__r.StageName != 'Closed Lost')) {
                    Opportunity indiOpp = new Opportunity();
                    indiOpp.Id = opp1;
                    indiOpp.StageName = 'Closed Won';
                    indiOpp.CloseDate = Date.today();
                    allUpdateOpp.add(indiOpp);
                    
                    ASPHPP__Subscription__c indiUpdatePSubs = new ASPHPP__Subscription__c();
                    indiUpdatePSubs.Id = pay.ASPHPP__PSubscription__c;
                    
                    // added for updating the payment subscription once the opportunity is closed won starts here 12/10/18 (#PSA-332)                   
                    if(tempSub.AS_opportunity__r.Pricebook2.AS_X6_Month_Subscription__c == true) {
                        indiUpdatePSubs.ASPHPP__End_Date__c = Date.today().addDays(170); 
            } else {
                indiUpdatePSubs.ASPHPP__End_Date__c = Date.today().addDays(364);
            }
            // added for updating the payment subscription once the opportunity is closed won ends here 12/10/18 (#PSA-332)
            allUpdatePSubs.add(indiUpdatePSubs);
            }
        }
    }
    System.debug('allUpdatePSubs :' + allUpdatePSubs);
    System.debug('allUpdateOpp :' + allUpdateOpp);
    
    update allUpdatePSubs;
    update allUpdateOpp;
    
}