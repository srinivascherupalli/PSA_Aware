trigger AS_ppaymentAutoOpp on ASPHPP__Payment__c (before insert,before update) {

    Map<Id,ASPHPP__Subscription__c> mapSubscription = new Map<Id,ASPHPP__Subscription__c>();
    Set<Id> setPSAsub = new Set<Id>();

    for(ASPHPP__Payment__c ppayment : Trigger.new){
        if(ppayment.ASPHPP__PSubscription__c !=null){
            setPSAsub.add(ppayment.ASPHPP__PSubscription__c);
        }
    }

    for(ASPHPP__Subscription__c psaSub : [Select Id,AS_opportunity__c,AS_Order__c,AS_Subscription__c from ASPHPP__Subscription__c where Id IN:setPSAsub]){
        mapSubscription.put(psaSub.Id,psaSub);
    }

    system.debug('xmapSubscription : '+mapSubscription);

    for(ASPHPP__Payment__c ppayment : Trigger.new){
        if(ppayment.ASPHPP__PSubscription__c !=null){
            ppayment.ASPHPP__Opportunity__c = ( mapSubscription.get(ppayment.ASPHPP__PSubscription__c).AS_opportunity__c != null)? mapSubscription.get(ppayment.ASPHPP__PSubscription__c).AS_opportunity__c :null;
            system.debug('pPaymentOpp : '+ppayment.ASPHPP__Opportunity__c);

            //link ppayment to order
            ppayment.AS_Order__c = ( mapSubscription.get(ppayment.ASPHPP__PSubscription__c).AS_Order__c != null)? mapSubscription.get(ppayment.ASPHPP__PSubscription__c).AS_Order__c :null;
            system.debug('pPaymentOrder : '+ppayment.AS_Order__c);

            //link ppayment to membership subscription
            ppayment.AS_Subscription__c = ( mapSubscription.get(ppayment.ASPHPP__PSubscription__c).AS_Subscription__c != null)? mapSubscription.get(ppayment.ASPHPP__PSubscription__c).AS_Subscription__c :null;
            system.debug('pPaymentSub : '+ppayment.AS_Subscription__c);
        }

    }
}