/*
* Author : wew
* Description: Create OpportunityLineItem after creation of new opportunity from visual flow
* Parameter : 
* Return : 
*/
trigger AS_createOppProdFromViFlow on Opportunity (before insert,before update, after insert,after update) {
    if(Trigger.isbefore) {
        Id idOppMembership = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();
        for(Opportunity opp : trigger.new) {
            if(opp.recordTypeId == idOppMembership && opp.AS_Account_Number__c != null) {
                opp.AccountId = Id.valueOf(opp.AS_Account_Number__c);
            }
            
            // block below is added as per peter's call 9/11/18
            if(trigger.isInsert) {
                opp.ASPHPP__Do_Not_Create_Payment_Transactions__c = true;
            }
        }
    } else if(Trigger.isAfter) {
        Id educRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Education').getRecordTypeId();
    
    List<OpportunityLineItem> allOppLineList = new List<OpportunityLineItem>();
    
    Set<Id> allProdSet = new Set<Id>();
    Set<Id> allPrBookSet = new Set<Id>();
    List<Id> allProdList = new List<Id>();
    List<Id> allPrBookList = new List<Id>();
    for(Opportunity opp:Trigger.New){ 
        if((opp.AS_Create_Subscription__c == true && opp.AS_Add_Products__c == true) || (opp.recordTypeId == educRecId && opp.AS_Add_Products__c == true)) {
            allProdSet.add(opp.AS_Product__c);
            allPrBookSet.add(opp.Pricebook2Id);
        }
    }
    allProdList.addAll(allProdSet);
    allPrBookList.addAll(allPrBookSet);
    System.debug('allProdSet :' + allProdSet);
    System.debug('allPrBookSet :' + allPrBookSet);
    
    Map<String,Id> prodPreEntry = new Map<String,Id>();
    for(PricebookEntry prBookEntry : [Select Id,Name,Product2Id,Pricebook2Id from PricebookEntry where Product2Id IN :allProdList AND Pricebook2Id IN :allPrBookList]) {
        prodPreEntry.put(String.valueOf(prBookEntry.Product2Id).toLowerCase()+String.valueOf(prBookEntry.Pricebook2Id).toLowerCase(),prBookEntry.Id);
    }
    
    System.debug('prodPreEntry :' + prodPreEntry);
    
    for(Opportunity opp:Trigger.New){
        // added condition as of -7-26-2018 by wew to segregate creation of opportunity line item for insert and update
        if(Trigger.isInsert) {
            if((opp.AS_Create_Subscription__c == true && opp.AS_Add_Products__c == true && opp.AS_Product_Price__c != null) || (opp.recordTypeId == educRecId && opp.AS_Add_Products__c == true && opp.AS_Product_Price__c != null)) {
                OpportunityLineItem indiOppLine = new OpportunityLineItem();
                indiOppLine.OpportunityId = opp.Id;
                indiOppLine.quantity =1;
                indiOppLine.Product2Id  = opp.AS_Product__c;
                indiOppLine.UnitPrice  = opp.AS_Product_Price__c;
                
                indiOppLine.PricebookEntryId = prodPreEntry.containsKey(String.valueOf(opp.AS_Product__c).toLowerCase()+String.valueOf(opp.Pricebook2Id).toLowerCase())?prodPreEntry.get(String.valueOf(opp.AS_Product__c).toLowerCase()+String.valueOf(opp.Pricebook2Id).toLowerCase()):null;
                allOppLineList.add(indiOppLine);
            }
        } else if(Trigger.isUpdate) {
            if(opp.recordTypeId == educRecId && opp.AS_Add_Products__c == true && opp.AS_Product_Price__c != null && Trigger.OldMap.get(opp.Id).AS_Add_Products__c != Trigger.NewMap.get(opp.Id).AS_Add_Products__c){
                OpportunityLineItem indiOppLine = new OpportunityLineItem();
                indiOppLine.OpportunityId = opp.Id;
                indiOppLine.quantity =1;
                indiOppLine.Product2Id  = opp.AS_Product__c;
                indiOppLine.UnitPrice  = opp.AS_Product_Price__c;
                
                indiOppLine.PricebookEntryId = prodPreEntry.containsKey(String.valueOf(opp.AS_Product__c).toLowerCase()+String.valueOf(opp.Pricebook2Id).toLowerCase())?prodPreEntry.get(String.valueOf(opp.AS_Product__c).toLowerCase()+String.valueOf(opp.Pricebook2Id).toLowerCase()):null;
                allOppLineList.add(indiOppLine);
            }
        }
    } 
    
    insert allOppLineList;
    }
}