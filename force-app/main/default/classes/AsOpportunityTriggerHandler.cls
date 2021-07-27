/*Author : John Hope
*Description : This is a class that handles Opportunity File Object Trigger.
*Date Created : 
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data : Opportunity
*/
public class AsOpportunityTriggerHandler {
    private boolean isExecutingBool = false;
    
    /*Author : John Hope
*Description : this is a constructor
*Date Created : 
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data :
*Param : 
0. boolean - set value for isExecutingBool 
*Return : 
*/
    public AsOpportunityTriggerHandler(boolean isExecuting){
        isExecutingBool = isExecuting;
    }
    
    /*Author : John Hope
*Description : handler for before insert trigger for object Opportunity
*Date Created : 
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data :
*Param : 
0. List<Opportunity> - the new Opportunity from trigger
*Return : 
*/
    
    public void OnBeforeInsert(Opportunity[] newOpportunities){
        autoPopulateData(newOpportunities, new map<Id,Opportunity>(), new map<Id,Opportunity>(), 'insert');
    }
    
    /*Author : John Hope
*Description : handler for after insert trigger for object Opportunity
*Date Created : 
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data :
*Param :
0. List<Object> - the new Object from trigger
*Return : 
*/
    public void OnAfterInsert(Opportunity[] newOpportunities,Map<Id,Opportunity> newMapOpportunities) {
        
        Id onlineShopRecordId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Online_Shop').getRecordTypeId();
        Map < Id, Boolean > oppWithOrdbutNoInvMap = new  Map < Id, Boolean >();
        map < Id, String > mapOppReferences = new map < Id, String > ();
        
        //Adding check for CPQ Opps
        Id cpqRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CPQ').getRecordTypeId();
        
        Map<String, OpportunityStage> mapOppStage = new Map <String, OpportunityStage> ();
        for (OpportunityStage oppStage: [SELECT IsClosed, IsWon, MasterLabel FROM OpportunityStage where IsClosed = true AND IsWon = true]) {
            mapOppStage.put(oppStage.MasterLabel.toLowerCase(), oppStage);
        }
        
        
        //Filter Record not to run on Online_Shope Recrod Type.
        list< Opportunity > filterdOppList = new list< Opportunity >();
        set< Id > OppIdOnlineRecordIdset = new set< Id >();
        for( Opportunity oppRecord : newOpportunities ){
            
            if(oppRecord.RecordTypeId != cpqRecordTypeId){ // Skip for CPQ Opps
                
                if( oppRecord.RecordTypeId != onlineShopRecordId ) {
                    
                    filterdOppList.add( oppRecord );
                    
                }
                
                if( oppRecord.RecordTypeId == onlineShopRecordId ) {
                    
                    if( mapOppStage.containsKey(oppRecord.StageName.toLowerCase()) ){
                        
                        if ( oppRecord.Generate_Order__c == true   || oppRecord.AS_Generate_Order_Without_Invoice__c == true ) { //if and else if
                            
                            String THERANDOMSTRING1 = AS_commonFunction.generateRandomString(40);
                            
                            OppIdOnlineRecordIdset.add( oppRecord.Id  ); 
                            
                            mapOppReferences.put(oppRecord.Id, THERANDOMSTRING1);
                            
                            if (oppRecord.AS_Generate_Order_Without_Invoice__c == true) { 
                                oppWithOrdbutNoInvMap.put(oppRecord.Id, true);
                            }
                            
                        }  
                        
                    } 
                    
                }
                
            }// skip CPQ opps
            
            if(  filterdOppList.size() != 0 ){
                
                filterOppData(newOpportunities, new Map<Id,Opportunity>(), newMapOpportunities, 'insert');
                
                
            } else  {
                
                if( OppIdOnlineRecordIdset.size() != 0 ){
                    CreateOrderAndOrderItem( OppIdOnlineRecordIdset ,  oppWithOrdbutNoInvMap, mapOppReferences );
                }
                
            }
        }
        
    }
    
    /*Author : John Hope
*Description : handler for before update trigger for object Opportunity
*Date Created : 
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data :
*Param :
0. List<Opportunity> - the old Opportunity from trigger
1. List<Opportunity> - the new Opportunity from trigger
2. List<Opportunity> - the new Map Opportunity from trigger
*Return : 
*/
    
    public void OnBeforeUpdate(Opportunity[] updatedOpportunities, Map<Id,Opportunity> oldMap, Map<Id,Opportunity> newMap){
        autoPopulateData(updatedOpportunities, oldMap, newMap, 'update');
    }
    
    /*Author : John Hope
*Description : handler for after update trigger for object Opportunity
*Date Created : 
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data :
*Param :
0. List<Opportunity> - the old Opportunity from trigger
1. List<Opportunity> - the new Opportunity from trigger
2. List<Opportunity> - the new Map Opportunity from trigger
*Return : 
*/
    public void OnAfterUpdate(Opportunity[] updatedOpportunities,Map<Id,Opportunity> oldMap,Map<Id,Opportunity> newMap) {
        
        String action ='update';
        
        Id onlineShopRecordId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Online_Shop').getRecordTypeId();
        Map < Id, Boolean > oppWithOrdbutNoInvMap = new  Map < Id, Boolean >();
        map < Id, String > mapOppReferences = new map < Id, String > ();
        
        
        Map<String, OpportunityStage> mapOppStage = new Map <String, OpportunityStage> ();
        for (OpportunityStage oppStage: [SELECT IsClosed, IsWon, MasterLabel FROM OpportunityStage where IsClosed = true AND IsWon = true]) {
            mapOppStage.put(oppStage.MasterLabel.toLowerCase(), oppStage);
        }
        
        
        //Adding check for CPQ Opps
        Id cpqRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CPQ').getRecordTypeId();
        
        //Filter Record not to run on Online_Shope Recrod Type.
        list< Opportunity > filterdOppList = new list< Opportunity >();
        set< Id > OppIdOnlineRecordIdset = new set< Id >();
        for( Opportunity oppRecord : updatedOpportunities ){
            
            if( oppRecord.RecordTypeId != cpqRecordTypeId ) { //Skip for CPQ opps 
                
                if( oppRecord.RecordTypeId != onlineShopRecordId ) {
                    
                    filterdOppList.add( oppRecord );
                    
                } 
                
                if( oppRecord.RecordTypeId == onlineShopRecordId ) {
                    
                    if( mapOppStage.containsKey(oppRecord.StageName.toLowerCase()) ){
                        
                        if ((oppRecord.Generate_Order__c == true && (  newMap.get(oppRecord.Id).StageName != oldMap.get(oppRecord.Id).StageName ||  newMap.get(oppRecord.Id).Generate_Order__c != oldMap.get(oppRecord.Id).Generate_Order__c )   ) || (oppRecord.AS_Generate_Order_Without_Invoice__c == true)) { //if and else if
                            
                            String THERANDOMSTRING1 = AS_commonFunction.generateRandomString(40);
                            
                            OppIdOnlineRecordIdset.add( oppRecord.Id  ); 
                            
                            mapOppReferences.put(oppRecord.Id, THERANDOMSTRING1);
                            
                            if (oppRecord.AS_Generate_Order_Without_Invoice__c == true) {
                                oppWithOrdbutNoInvMap.put(oppRecord.Id, true);
                            }
                            
                        }
                        
                    }
                    
                }
            }
            
        }
        
        if(  filterdOppList.size() != 0 ){
            
            filterOppData(updatedOpportunities,oldMap,newMap,'update');
            
        } else  {
            if( OppIdOnlineRecordIdset.size() != 0 ){
                CreateOrderAndOrderItem( OppIdOnlineRecordIdset ,  oppWithOrdbutNoInvMap, mapOppReferences );
            }
            
        }
        
        
    }
    
    /*Author : John Hope
*Description : handler for before delete trigger for object Opportunity
*Date Created : 
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data :
*Param : List<Opportunity>,List<Opportunity>
0. List<Opportunity> - the old Opportunity data from trigger
1. Map<Id,Opportunity> - the old Map data from trigger
*Return : 
*/
    /*
public void OnBeforeDelete(Opportunity[] oldOpportunities,Map<Id,Opportunity>  MapOpportunitiesMap){

}
*/
    /*Author : John Hope
*Description : handler for after delete trigger for object Opportunity
*Date Created : 
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data :
*Param : 
0. List<Opportunity> - the old Opportunity data list from trigger
1. Map<Id,Opportunity> - the old Opportunity data map from trigger
*Return : 
*/
    /*
public void OnAfterDelete(Opportunity[] deletedOpportunities,Map<Id,Opportunity>  MapOpportunitiesMap){
// AFTER DELETE LOGIC
}
*/
    /*Author : John Hope
*Description : handler for undelete trigger for object Opportunity
*Date Created : 
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data :
*Param :
0. List<Opportunity> - the new Opportunity data list from trigger
*Return : 
*/
    /*
public void OnUndelete(Opportunity[] restoredOpportunities){
// AFTER UNDELETE LOGIC
}
*/
    /*Author : John Hope
*Description : checker if trigger is running
*Date Created : 
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data :
*Param : 
*Return : boolean
*/
    public boolean IsTriggerContext{
        get{ return isExecutingBool;}
    }
    
    /*Author : John Hope
*Description : filter opportunity base on its update to reduce the functionality to be called.
*Date Created : Feb. 25, 2019
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data :
*Param : 
*Return : 
*/
    public void autoPopulateData(Opportunity[] newObject,Map<Id,Opportunity> oldMap,Map<Id,Opportunity> newMap,String action) {
        Id idOppMembership = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership').getRecordTypeId();
        //Adding check for CPQ Opps
        Id cpqRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CPQ').getRecordTypeId();
        for(Opportunity opp : newObject) {
            if(opp.recordTypeId != cpqRecordTypeId)  {// Skip for CPQ Opps
                if(opp.recordTypeId == idOppMembership && opp.AS_Account_Number__c != null) {
                    opp.AccountId = Id.valueOf(opp.AS_Account_Number__c);
                }
                
                // block below is added as per peter's call 9/11/18
                if(action == 'insert') {
                    opp.ASPHPP__Do_Not_Create_Payment_Transactions__c = true;
                }
            }
        }
    }
    
    /*Author : John Hope
*Description : filter opportunity base on its update to reduce the functionality to be called.
*Date Created : Feb. 25, 2019
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data :
*Param : 
*Return : 
*/
    public void filterOppData(Opportunity[] newObject,Map<Id,Opportunity> oldMap,Map<Id,Opportunity> newMap,String action) {
        System.debug('Opportunity Trigger here');
        List<Opportunity> allOppForCloseWonList = new List<Opportunity>();
        List<Opportunity> allOppForOppLineList = new List<Opportunity>();
        Map<String, OpportunityStage> mapOppStage = new Map <String, OpportunityStage> ();
        for (OpportunityStage oppStage: [SELECT IsClosed, IsWon, MasterLabel FROM OpportunityStage where IsClosed = true AND IsWon = true]) {
            mapOppStage.put(oppStage.MasterLabel.toLowerCase(), oppStage);
        }
        
        Id educRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Education').getRecordTypeId();
        
        
        for (Opportunity opp: newObject) {
            // run the close won process filter starts here
            system.debug('opp.StageName.toLowerCase() : ' + opp.StageName.toLowerCase());
            if (mapOppStage.containsKey(opp.StageName.toLowerCase()) && (action == 'insert' || (action == 'update' && newMap.get(opp.Id).StageName != oldMap.get(opp.Id).StageName))) {
                allOppForCloseWonList.add(opp);
            }
            // run the close won process filter starts here
            
            // Create OpportunityLineItem after creation of new opportunity from visual flow filter starts here
            if(action == 'insert' && ((opp.AS_Create_Subscription__c == true && opp.AS_Add_Products__c == true && opp.AS_Product_Price__c != null) || (opp.recordTypeId == educRecId && opp.AS_Add_Products__c == true && opp.AS_Product_Price__c != null))) {
                allOppForOppLineList.add(opp);
            } else if(action == 'update' && (opp.recordTypeId == educRecId && opp.AS_Add_Products__c == true && opp.AS_Product_Price__c != null && oldMap.get(opp.Id).AS_Add_Products__c != newMap.get(opp.Id).AS_Add_Products__c)){
                allOppForOppLineList.add(opp);
            }
            // Create OpportunityLineItem after creation of new opportunity from visual flow filter ends here
        }
        
        System.debug('allOppForCloseWonList :' + allOppForCloseWonList);
        if(allOppForCloseWonList.size() > 0) {
            
            // Get only opportunities that Record type is not Online Store
            
            // List<Opportunity> OppNoTOnlineShop = new List<Opportunity>();
            
            // for( Opportunity opp : allOppForOppLineList ) {
            //     if( opp.RecordTypeId != onlineShopRecordId ) {
            //         OppNoTOnlineShop.add( opp );
            //     }
            // } 
            
            // if( OppNoTOnlineShop.size() != 0 ){
            
            //     system.debug(' This trigger AsOpportunityTriggerHandler run the close won. ');
            
            oppCloseWonProcess(allOppForCloseWonList,oldMap,newMap,action); 
            
            // }
            
        }
        
        System.debug('allOppForOppLineList :' + allOppForOppLineList);
        if(allOppForOppLineList.size() > 0) {
            createOppProdFromViFlow(allOppForOppLineList,oldMap,newMap,action);
        }
        
    }
    
    /*Author : John Hope
*Description : this will be called when opportunity is closed won as a replacement for AS_oppClosedWonTrigger.
*Date Created : Feb. 25, 2019
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data :
*Param : 
*Return : 
*/
    public void createOppProdFromViFlow(Opportunity[] filteredOpp,Map<Id,Opportunity> oldMap,Map<Id,Opportunity> newMap,String action) {
        Id educRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Education').getRecordTypeId();
        
        List<OpportunityLineItem> allOppLineList = new List<OpportunityLineItem>();
        
        Set<Id> allProdSet = new Set<Id>();
        Set<Id> allPrBookSet = new Set<Id>();
        List<Id> allProdList = new List<Id>();
        List<Id> allPrBookList = new List<Id>();
        for(Opportunity opp:filteredOpp){ 
            allProdSet.add(opp.AS_Product__c);
            allPrBookSet.add(opp.Pricebook2Id);
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
        
        for(Opportunity opp:filteredOpp){
            // added condition as of -7-26-2018 by wew to segregate creation of opportunity line item for insert and update
            OpportunityLineItem indiOppLine = new OpportunityLineItem();
            indiOppLine.OpportunityId = opp.Id;
            indiOppLine.quantity =1;
            indiOppLine.Product2Id  = opp.AS_Product__c;
            indiOppLine.UnitPrice  = opp.AS_Product_Price__c;
            
            indiOppLine.PricebookEntryId = prodPreEntry.containsKey(String.valueOf(opp.AS_Product__c).toLowerCase()+String.valueOf(opp.Pricebook2Id).toLowerCase())?prodPreEntry.get(String.valueOf(opp.AS_Product__c).toLowerCase()+String.valueOf(opp.Pricebook2Id).toLowerCase()):null;
            allOppLineList.add(indiOppLine);
        }
        
        insert allOppLineList;
        
    }
    
    
    /*Author : John Hope
*Description : this will be called when opportunity is closed won as a replacement for AS_oppClosedWonTrigger.
*Date Created : Feb. 25, 2019
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data :
*Param : 
*Return : 
*/
    public void oppCloseWonProcess(Opportunity[] filteredOpp,Map<Id,Opportunity> oldMap,Map<Id,Opportunity> newMap,String action) {
        
        System.debug('AS_commonFunction.runOppCloseWon : ' + AS_commonFunction.runOppCloseWon);
        
        if (AS_commonFunction.runOppCloseWonOnce()) {
            
            System.debug('AS_commonFunction counter');
            
            Id idOppMembership = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership').getRecordTypeId();
            Id idSubscription = Schema.SObjectType.AS_Subscription__c.getRecordTypeInfosByDeveloperName().get('Membership').getRecordTypeId();
            Map < Id, Pricebook2 > mapIdPriceBook = new Map < Id, Pricebook2 > ();
            Map < String, OpportunityStage > mapOppStage = new Map < String, OpportunityStage > ();
            Set < Id > setOppIds = new Set < Id > ();
            Set < Id > setPricebookIds = new Set < Id > ();
            Set < Id > setPSAsubscriptions = new Set < Id > ();
            Set < Id > setPaymentSources = new Set < Id > ();
            Set < Id > setProductFromOpp = new Set < Id > ();
            Set < Id > setOppAccount = new Set < Id > ();
            set < ID > oppId = new set < ID > ();
            Set < Id > setOppProductId = new Set < Id > ();
            Set < Id > setAccUpdateSubscriptionEmail = new Set < Id > ();
            List < OpportunityLineItem > listOppProduct = new List < OpportunityLineItem > ();
            List < AS_Subscription__c > listSubscriptionInsert = new List < AS_Subscription__c > ();
            List < AS_Subscription__c > listSubscriptionUpdate = new List < AS_Subscription__c > ();
            List < Opportunity > listOpp2Update = new List < Opportunity > ();
            Map < Id, AS_Subscription__c > mapIdSubscription = new Map < Id, AS_Subscription__c > ();
            Map < Id, Id > mapIdPPSubscription = new Map < Id, Id > (); //Jan 9
            Map < Id, Id > mapIdPPayment = new Map < Id, Id > (); //Jan 9
            Map < Id, Account > mapIdAccount = new Map < Id, Account > ();
            Map < Id, Product2 > mapIdProduct = new Map < Id, Product2 > ();
            Map < Id, Training_Plan__c > mapIdTrainingPlan = new Map < Id, Training_Plan__c > ();
            Map <Id,Training_Track__c> trainTrackPlanMap = new Map <Id,Training_Track__c>();
            Map < Id, Id > allAccountUser = new Map < Id, Id > ();
            String THERANDOMSTRING = '';
            List < ASPHPP__Subscription__c > listPSubscriptionUpdate = new List < ASPHPP__Subscription__c > (); //Jan 9
            List < ASPHPP__Payment__c > listPPaymentUpdate = new List < ASPHPP__Payment__c > (); //Jan 9
            List < Product2 > listProducts = new List < Product2 > ();
            List < Product2 > allprodToUpdateList = new List < Product2 > ();
            list < Order > lstOrders = new list < Order > ();
            List < OrderItem > lstOrderItems = new List < OrderItem > ();
            Map < Id, Boolean > oppWithOrdbutNoInvMap = new Map < Id, Boolean > ();
            
            for (OpportunityStage oppStage: [SELECT IsClosed, IsWon, MasterLabel FROM OpportunityStage where IsClosed = true AND IsWon = true]) {
                mapOppStage.put(oppStage.MasterLabel.toLowerCase(), oppStage);
            }
            
            system.debug('mapOppStage : ' + mapOppStage);
            for (Opportunity opp: filteredOpp) {
                system.debug('opp.StageName.toLowerCase() : ' + opp.StageName.toLowerCase());
                setOppIds.add(opp.Id);
                setPricebookIds.add(opp.Pricebook2Id);
                setPSAsubscriptions.add(opp.AS_PSA_Subscription__c);
                setPaymentSources.add(opp.ASPHPP__Payment_Source__c);
                setOppAccount.add(opp.AccountId);
                setOppProductId.add(opp.AS_Product__c);
            }
            
            system.debug('xSET : ' + setOppIds);
            if (setOppIds.size() > 0) {
                for (OpportunityLineItem oppProd: [Select Id, OpportunityId, Product2.AS_Parent_Product__c from OpportunityLineItem where OpportunityId IN: setOppIds]) {
                    system.debug('oppProd ==>: ' + oppProd);
                    listOppProduct.add(oppProd);
                }
                
                // added as of 1-8-19 for ticket (#PSA-336) next code block is the update for the commented code starts here
                for(Opportunity theOpp : [SELECT Id,(Select Id,ASPHPP__PSubscription__c from ASPHPP__Payments__r where ASPHPP__Payment_Status__c = 'Success' order by lastModifiedDate desc limit 1) FROM Opportunity where Id IN :setOppIds]) {
                    if(theOpp.ASPHPP__Payments__r.size() > 0) {
                        for(ASPHPP__Payment__c pPayment : theOpp.ASPHPP__Payments__r) {
                            if(pPayment.ASPHPP__PSubscription__c !=null) {
                                mapIdPPSubscription.put(theOpp.Id, pPayment.ASPHPP__PSubscription__c);
                            }
                            
                            mapIdPPayment.put(theOpp.Id, pPayment.Id);
                        }
                    }
                }
                // added as of 1-8-19 for ticket (#PSA-336) next code block is the update for the commented code ends here
            }
            if (setPricebookIds.size() > 0) {
                for (Pricebook2 priceBook: [SELECT Id, AS_Frequency__c FROM Pricebook2 where Id IN: setPricebookIds]) {
                    mapIdPriceBook.put(priceBook.Id, priceBook);
                }
            }
            if (setPSAsubscriptions.size() > 0) {
                for (AS_Subscription__c psaSubscription: [Select Id, AS_Frequency__c, AS_End_Date__c, AS_Type__c, AS_Payment_Source__c, AS_Membership_Span__c, AS_Opportunity__c, AS_User__c from AS_Subscription__c where Id IN: setPSAsubscriptions]) {
                    mapIdSubscription.put(psaSubscription.Id, psaSubscription);
                }
            }
            if (setOppProductId.size() > 0) {
                for (Product2 prod2: [Select Id, Name, AS_Membership_Type__c, AS_Membership_Type__r.Name from Product2 where Id IN: setOppProductId]) {
                    mapIdProduct.put(prod2.Id, prod2);
                }
                
                // block added by john july 10 for #PSA-79
                for (Training_Plan__c train : [Select Id, Name, AS_Product__c, Type__c from Training_Plan__c where AS_Product__c IN: setOppProductId]) {
                    mapIdTrainingPlan.put(train.AS_Product__c, train);
                }
                
                // block added by john october 25 for #PSAS-101
                for (Training_Track__c trainTrack : [Select Id, Name, Product__c, AS_Track_Type__c from Training_Track__c where Product__c IN: setOppProductId]) {
                    trainTrackPlanMap.put(trainTrack.Product__c, trainTrack);
                }
            }
            
            system.debug('klistProducts : ' + listProducts);
            // added to update the account/opportunity ownership for student 2-16-18
            List < User > theGuest = new List < User > ();
            if (setOppIds.size() > 0) {
                theGuest = [Select Id, Name, ProfileId from User where Name = 'membership sign up site guest user' AND isActive = true LIMIT 1];
            }
            
            List < Account > allUpdateAcc = new List < Account > ();
            if (setOppAccount.size() > 0) {
                for (Account acc: [Select Id, Name, AS_Graduation_Year__pc, OwnerId, (Select Id from Users) from Account where Id IN: setOppAccount]) {
                    mapIdAccount.put(acc.Id, acc);
                    // added to update the account ownership for student 2-16-18
                    if (theGuest.size() > 0 && acc.OwnerId == theGuest[0].Id) {
                        Account indiUpdateAcc = new Account();
                        indiUpdateAcc.Id = acc.Id;
                        indiUpdateAcc.OwnerId = AS_commonFunction.ownerId();
                        allUpdateAcc.add(indiUpdateAcc);
                    }
                    // added to get account user 7/10/18 by wew
                    if (acc.Users.size() > 0) {
                        allAccountUser.put(acc.Id, acc.Users[0].Id);
                    }
                }
            }
            //Jan9
            system.debug('mapOppStage => ' + mapOppStage);
            map < Id, String > mapOppReferences = new map < Id, String > ();
            list < Training_Plan_Assignment__c > allTrainPlanAss = new list < Training_Plan_Assignment__c > ();
            list<Training_Track_Account__c> allTobeAddedTrainTrackAcc = new list<Training_Track_Account__c>();
            for (Opportunity opp: filteredOpp) {
                THERANDOMSTRING = AS_commonFunction.generateRandomString(40);
                String THERANDOMSTRING1 = AS_commonFunction.generateRandomString(40);
                
                // block added by john july 10 for #PSA-79
                System.debug('mapIdTrainingPlan :' + mapIdTrainingPlan);
                System.debug('allAccountUser :' + allAccountUser);
                System.debug('checking for training plan assignments :' + opp.AS_Product__c + ' - ' + opp.AccountId + ' -- ');
                if (opp.AS_Product__c != null && mapIdTrainingPlan.containsKey(opp.AS_Product__c) && allAccountUser.containsKey(opp.AccountId)) {
                    // below code is updated for ticket(#PSA-360)
                    Training_Plan__c finalTrainPlan = mapIdTrainingPlan.get(opp.AS_Product__c);
                    if(finalTrainPlan.Type__c != 'RTO') {
                        Training_Plan_Assignment__c TrainPlanAss = new Training_Plan_Assignment__c();
                        TrainPlanAss.User__c = UserInfo.getUserId();//-------------------------------------------allAccountUser.get(opp.AccountId);
                        TrainPlanAss.Training_Plan__c = mapIdTrainingPlan.get(opp.AS_Product__c).Id;
                        TrainPlanAss.Status__c = 'Not Started';
                        allTrainPlanAss.add(TrainPlanAss);
                    }
                }
                
                // code block below is for ticket (#PSAS-101)
                if (opp.AS_Product__c != null && trainTrackPlanMap.containsKey(opp.AS_Product__c) && allAccountUser.containsKey(opp.AccountId)) {
                    // below code is updated for ticket(#PSA-359)
                    Training_Track__c finalTrainTrack = trainTrackPlanMap.get(opp.AS_Product__c);
                    if(finalTrainTrack.AS_Track_Type__c != 'Diploma' && finalTrainTrack.AS_Track_Type__c != 'Intern Training Program' && finalTrainTrack.AS_Track_Type__c != 'Qualification'){
                        Training_Track_Account__c trainTrackAcc = new Training_Track_Account__c();
                        trainTrackAcc.Account__c = opp.AccountId;
                        trainTrackAcc.AS_Approval_Status__c = 'Confirmed';
                        trainTrackAcc.Training_Track__c = trainTrackPlanMap.get(opp.AS_Product__c).Id;
                        trainTrackAcc.AsExternalId__c = THERANDOMSTRING;
                        allTobeAddedTrainTrackAcc.add(trainTrackAcc);
                        
                        Training_Track_Account__c trainTrackAccReference = new Training_Track_Account__c();
                        trainTrackAccReference.AsExternalId__c = THERANDOMSTRING;
                        
                        Opportunity updatedOpp = new Opportunity();
                        updatedOpp.Training_Track_Account__r = trainTrackAccReference;
                        updatedOpp.Id = opp.Id;
                        listOpp2Update.add(updatedOpp);
                    }
                    
                }
                
                Boolean ifNoParent = true;
                for (OpportunityLineItem oppProduct: listOppProduct) {
                    if (oppProduct.OpportunityId == opp.Id && oppProduct.Product2.AS_Parent_Product__c != null) {
                        ifNoParent = false;
                    }
                }
                System.debug('recordType: '+opp.RecordTypeId+'   >>>idOppMembership  ===  '+idOppMembership);
                if (opp.RecordTypeId == idOppMembership) { 
                    oppId.add(opp.Id);
                    mapOppReferences.put(opp.Id, THERANDOMSTRING1);
                    system.debug('mMembership !!!');
                    system.debug('mMembership !!! ==>  ' +mapOppReferences);
                    if (opp.AS_Create_Subscription__c == true) { // New Membership Subscription
                        if (ifNoParent) {
                            system.debug('mNew Membership Subscription !!!' + THERANDOMSTRING1);
                            AS_Subscription__c newSubscription = new AS_Subscription__c();
                            system.debug('debug my opp ==> ' + opp);
                            newSubscription.AS_Auto_Renew__c = (opp.ASPHPP__Payment_Source__c != null) ? true : false;
                            newSubscription.AS_Frequency__c = (mapIdPriceBook.get(opp.Pricebook2Id).AS_Frequency__c != null) ? mapIdPriceBook.get(opp.Pricebook2Id).AS_Frequency__c : 1;
                            newSubscription.AS_Start_Date__c = opp.CloseDate;
                            system.debug('mapIdProduct.get(opp.AS_Product__c).AS_Membership_Type__r.Name==> ' + mapIdProduct.get(opp.AS_Product__c).AS_Membership_Type__r.Name);
                            system.debug('mapIdProduct=> ' + mapIdProduct);
                            if (opp.AS_Product__c != null) {
                                if (mapIdProduct.get(opp.AS_Product__c).AS_Membership_Type__r.Name.tolowerCase().trim() == 'student members' && mapIdProduct.get(opp.AS_Product__c).AS_Membership_Type__r.Name != null) {
                                    if (String.isNotBlank(mapIdAccount.get(opp.AccountId).AS_Graduation_Year__pc)) {
                                        newSubscription.AS_End_Date__c = Date.newInstance(Integer.valueof(mapIdAccount.get(opp.AccountId).AS_Graduation_Year__pc) + 1, 1, 15); // added for (#PSA-334)
                                    } else {
                                        newSubscription.AS_End_Date__c = Date.newInstance(Date.Today().addYears(1).year(), 1, 15);
                                    }
                                } else {
                                    newSubscription.AS_End_Date__c = opp.CloseDate.addYears(1);
                                }
                            } else {
                                newSubscription.AS_End_Date__c = opp.CloseDate.addYears(1);
                            }
                            newSubscription.AS_Type__c = 'Member';
                            newSubscription.AS_Payment_Source__c = (opp.ASPHPP__Payment_Source__c != null) ? opp.ASPHPP__Payment_Source__c : null;
                            newSubscription.AS_Membership_Span__c = 1;
                            newSubscription.AS_Price_Book__c = opp.Pricebook2Id;
                            newSubscription.AS_ExtID__c = THERANDOMSTRING;
                            newSubscription.Account__c = opp.AccountId;
                            newSubscription.AS_Membership_Status__c = 'Pending'; //Jan 9
                            newSubscription.AS_Product__c = (opp.AS_Product__c != null) ? opp.AS_Product__c : null; //Jan 10
                            newSubscription.RecordTypeId = idSubscription;
                            /* newly added  */
                            newSubscription.AS_Membership_Renewal_Date__c = opp.CloseDate;
                            AS_Subscription__c referenceSubscript = new AS_Subscription__c();
                            referenceSubscript.AS_ExtID__c = THERANDOMSTRING;
                            Opportunity updatedOpp = new Opportunity();
                            updatedOpp.Id = opp.Id;
                            updatedOpp.AS_PSA_Subscription__r = referenceSubscript;
                            if (theGuest.size() > 0 && opp.OwnerId == theGuest[0].Id) {
                                updatedOpp.OwnerId = AS_commonFunction.ownerId();
                            }
                            listOpp2Update.add(updatedOpp);
                            listSubscriptionInsert.add(newSubscription);
                            Order referenceOppRef = new Order(AS_extId__c = THERANDOMSTRING1);
                            
                            
                            system.debug('referenceSubscript==>'+ referenceSubscript );
                            
                            system.debug('referenceOppRef==>'+ referenceOppRef );
                            
                            
                            // added as of 1-8-19 for ticket (#PSA-336)
                            if (mapIdPPSubscription.containsKey(opp.Id)) {
                                ASPHPP__Subscription__c pSubscription = new ASPHPP__Subscription__c();
                                pSubscription.Id = mapIdPPSubscription.get(opp.Id);
                                pSubscription.AS_Subscription__r = referenceSubscript;
                                pSubscription.AS_Order__r = referenceOppRef;
                                listPSubscriptionUpdate.add(pSubscription);
                            }
                            
                            if (mapIdPPayment.containsKey(opp.Id)) {
                                
                                system.debug('ming solod diri 1');
                                
                                ASPHPP__Payment__c pPayment = new ASPHPP__Payment__c();
                                pPayment.Id = mapIdPPayment.get(opp.Id);
                                pPayment.AS_Subscription__r = referenceSubscript;
                                pPayment.AS_Order__r = referenceOppRef;
                                listPPaymentUpdate.add(pPayment);
                                
                                system.debug('listPPaymentUpdate=> '+ listPPaymentUpdate);
                                
                            } 
                            // added as of 1-8-19 for ticket (#PSA-336)
                        }
                    } else { // Existing Membership Subscription
                        
                        system.debug('xExisting Membership Subscription !!!');
                        
                        if (opp.AS_PSA_Subscription__c != null) {
                            
                            AS_Subscription__c updateSubscription = new AS_Subscription__c();
                            
                            updateSubscription.Id = opp.AS_PSA_Subscription__c;
                            
                            updateSubscription.AS_Frequency__c = (mapIdPriceBook.get(opp.Pricebook2Id).AS_Frequency__c != null) ? mapIdPriceBook.get(opp.Pricebook2Id).AS_Frequency__c : 1;
                            
                            if (opp.AS_Product__c != null) {
                                if (mapIdProduct.get(opp.AS_Product__c).AS_Membership_Type__r.Name == 'Student Members') {
                                    if (String.isNotBlank(mapIdAccount.get(opp.AccountId).AS_Graduation_Year__pc)) {
                                        updateSubscription.AS_End_Date__c = Date.newInstance(Integer.valueof(mapIdAccount.get(opp.AccountId).AS_Graduation_Year__pc) + 1, 1, 15); // added for (#PSA-334)
                                    } else {
                                        updateSubscription.AS_End_Date__c = Date.newInstance(Date.Today().addYears(1).year(), 1, 15);
                                    }
                                } else {
                                    //   updateSubscription.AS_End_Date__c = opp.CloseDate.addDays(364); // commented and new line below added for #PSA-276
                                    updateSubscription.AS_End_Date__c = (mapIdSubscription.get(opp.AS_PSA_Subscription__c).AS_End_Date__c != null) ? mapIdSubscription.get(opp.AS_PSA_Subscription__c).AS_End_Date__c.addDays(365) : opp.CloseDate.addDays(364);
                                }
                            } else {
                                // updateSubscription.AS_End_Date__c = opp.CloseDate.addDays(364); // commented and new line below added for #PSA-276
                                updateSubscription.AS_End_Date__c = (mapIdSubscription.get(opp.AS_PSA_Subscription__c).AS_End_Date__c != null) ? mapIdSubscription.get(opp.AS_PSA_Subscription__c).AS_End_Date__c.addDays(365) : opp.CloseDate.addDays(364);
                            }
                            updateSubscription.AS_Type__c = 'Member';
                            updateSubscription.AS_Payment_Source__c = (opp.ASPHPP__Payment_Source__c != null) ? opp.ASPHPP__Payment_Source__c : null;
                            updateSubscription.AS_Membership_Span__c = mapIdSubscription.get(opp.AS_PSA_Subscription__c).AS_Membership_Span__c + 1;
                            updateSubscription.Account__c = opp.AccountId;
                            if (action == 'insert') {
                                //setAccUpdateSubscriptionEmail.add(opp.AccountId);
                            } else if (action == 'update') {
                                String oldStageName = oldMap.get(opp.Id).StageName;
                                if (!mapOppStage.containsKey(oldStageName)) {
                                    setAccUpdateSubscriptionEmail.add(opp.AccountId); //Jan 12
                                }
                            }
                            updateSubscription.AS_Price_Book__c = opp.Pricebook2Id; //Jan 4
                            updateSubscription.AS_Membership_Status__c = 'Current'; //Jan 9
                            updateSubscription.AS_Product__c = (opp.AS_Product__c != null) ? opp.AS_Product__c : null; //Jan 10
                            /* newly added  */
                            updateSubscription.AS_Membership_Renewal_Date__c = opp.CloseDate;
                            listSubscriptionUpdate.add(updateSubscription);
                            Order referenceOppRef = new Order(AS_extId__c = THERANDOMSTRING1);
                            
                            // commented as of 1-8-19 for ticket (#PSA-336) next code block is the update for the commented code starts here
                            
                            /*
for (ASPHPP__Subscription__c sub: mapIdPPSubscription.values()) {
if (sub.AS_opportunity__c == opp.Id) {
ASPHPP__Subscription__c pSubscription = new ASPHPP__Subscription__c();
pSubscription.Id = sub.Id;
pSubscription.AS_Subscription__c = opp.AS_PSA_Subscription__c;
pSubscription.AS_Order__r = referenceOppRef;
listPSubscriptionUpdate.add(pSubscription);
} //if
} //for
for (ASPHPP__Payment__c pay: mapIdPPayment.values()) {
if (pay.ASPHPP__Opportunity__c == opp.Id) {
ASPHPP__Payment__c pPayment = new ASPHPP__Payment__c();
pPayment.Id = pay.Id;
pPayment.AS_Subscription__c = opp.AS_PSA_Subscription__c;
pPayment.AS_Order__r = referenceOppRef;
listPPaymentUpdate.add(pPayment);
} //if 
} //for
*/
                            
                            if (mapIdPPSubscription.containsKey(opp.Id)) {
                                ASPHPP__Subscription__c pSubscription = new ASPHPP__Subscription__c();
                                pSubscription.Id = mapIdPPSubscription.get(opp.Id);
                                pSubscription.AS_Subscription__c = opp.AS_PSA_Subscription__c;
                                pSubscription.AS_Order__r = referenceOppRef;
                                listPSubscriptionUpdate.add(pSubscription);
                            }
                            
                            if (mapIdPPayment.containsKey(opp.Id)) {
                                system.debug('ming solod diri 2');
                                ASPHPP__Payment__c pPayment = new ASPHPP__Payment__c();
                                pPayment.Id = mapIdPPayment.get(opp.Id);
                                pPayment.AS_Subscription__c = opp.AS_PSA_Subscription__c;
                                pPayment.AS_Order__r = referenceOppRef;
                                listPPaymentUpdate.add(pPayment);
                            }
                            // commented as of 1-8-19 for ticket (#PSA-336) next code block is the update for the commented code ends here
                        } //if
                    } //else
                }
                // code below added to create an order even for non member recordtype and for creation of order without invoice
                else if ((opp.Generate_Order__c == true && (action == 'insert' || (action == 'update' && newMap.get(opp.Id).StageName != oldMap.get(opp.Id).StageName) || (action == 'update' && newMap.get(opp.Id).Generate_Order__c != oldMap.get(opp.Id).Generate_Order__c))) || (opp.AS_Generate_Order_Without_Invoice__c == true)) { //if and else if
                    oppId.add(opp.Id);
                    mapOppReferences.put(opp.Id, THERANDOMSTRING1);
                    if (opp.AS_Generate_Order_Without_Invoice__c == true) {
                        oppWithOrdbutNoInvMap.put(opp.Id, true);
                    }
                }
                else if(String.isNotBlank(opp.Chargent_Order__c)){
                    oppId.add(opp.Id);
                    mapOppReferences.put(opp.Id, THERANDOMSTRING1);
                }
            } //for 
            
            if (oppId.size() > 0) {
                System.debug('oppId :' + oppId);
                
                Standalone_Order_Defaults__c defaults = Standalone_Order_Defaults__c.getInstance();
                
                for (Opportunity opp: [SELECT Pricebook2Id, AS_Payment_Amount__c, AS_Generate_Order_Without_Invoice__c, CloseDate, Id, AccountId, Account.Name, Account.BillingAddress,
                                       Account.BillingCity, Account.BillingCountry, Account.BillingPostalCode,
                                       Account.BillingState, Account.BillingStreet, Account.ShippingAddress,
                                       Account.ShippingCity, Account.ShippingCountry, Account.ShippingPostalCode,
                                       Account.ShippingState, Account.ShippingStreet, Chargent_Order__c,
                                       (Select Id, OpportunityId, PricebookEntryId, Product2Id, UnitPrice, Quantity, Discount, AS_Taxable_Amount__c, AS_Taxable_Rate__c, AS_GST_Product__c, Description, Product2.AS_Stock_Level__c From OpportunityLineItems)
                                       FROM Opportunity WHERE Id IN: oppId
                                      ]) {
                                          if(String.isBlank(opp.Chargent_Order__c)){
                                              Order newOrder = new Order();
                                              newOrder.blng__BillingDayOfMonth__c = String.valueOf(system.today().day());
                                              //newOrder.EffectiveDate = system.today();
                                              newOrder.OpportunityId = opp.Id;
                                              newOrder.AccountId = opp.AccountId;
                                              newOrder.blng__BillingAccount__c = opp.AccountId;
                                              //newOrder.BillingAddress = opp.Account.BillingAddress;
                                              newOrder.BillingCity = opp.Account.BillingCity;
                                              newOrder.BillingCountry = opp.Account.BillingCountry;
                                              newOrder.BillingPostalCode = opp.Account.BillingPostalCode;
                                              newOrder.BillingState = opp.Account.BillingState;
                                              newOrder.BillingStreet = opp.Account.BillingStreet; //  
                                              //newOrder.ShippingAddress = opp.Account.ShippingAddress;
                                              newOrder.ShippingCity = opp.Account.ShippingCity;
                                              newOrder.ShippingCountry = opp.Account.ShippingCountry;
                                              newOrder.ShippingPostalCode = opp.Account.ShippingPostalCode; //
                                              newOrder.ShippingState = opp.Account.ShippingState;
                                              newOrder.ShippingStreet = opp.Account.ShippingStreet;
                                              newOrder.Pricebook2Id = opp.Pricebook2Id;
                                              newOrder.EffectiveDate = opp.CloseDate;
                                              newOrder.Status = 'Draft';
                                              newOrder.AS_Payment_Amount__c = opp.AS_Payment_Amount__c;
                                              if (opp.AS_Generate_Order_Without_Invoice__c == true) {
                                                  newOrder.AS_Generate_Invoice__c = false;
                                              } else {
                                                  newOrder.AS_Generate_Invoice__c = true; // updated to true as michelle said that we will get rid of this field.
                                              }
                                              newORder.AS_extId__c = mapOppReferences.get(opp.Id);
                                              lstOrders.add(newORder);
                                              
                                              Order referenceOppsd = new Order(AS_extId__c = mapOppReferences.get(opp.Id));
                                              
                                              for (OpportunityLineItem oppLine: opp.OpportunityLineItems) {
                                                  Product2 indiprodToUpdate = new Product2();
                                                  OrderItem orderItemsNew = new OrderItem();
                                                  orderItemsNew.blng__BillingAccount__c = opp.AccountId;
                                                  orderItemsNew.blng__BillableUnitPrice__c = oppLine.UnitPrice + oppLine.AS_Taxable_Amount__c;
                                                  orderItemsNew.PricebookEntryId = oppLine.PricebookEntryId;
                                                  orderItemsNew.Order = referenceOppsd;
                                                  orderItemsNew.UnitPrice = oppLine.UnitPrice + oppLine.AS_Taxable_Amount__c;
                                                  orderItemsNew.Quantity = oppLine.Quantity;
                                                  orderItemsNew.AS_Discount__c = oppLine.Discount; //
                                                  orderItemsNew.AS_Tax_Rate__c = oppLine.AS_Taxable_Rate__c; //
                                                  orderItemsNew.AS_Taxable__c = oppLine.AS_GST_Product__c; //
                                                  orderItemsNew.Description = oppLine.Description; //
                                                  
                                                  orderItemsNew.blng__BillingGLRule__c = defaults.Billing_GL_Rule_ID__c;
                                                  orderItemsNew.blng__BillingGLTreatment__c = defaults.Billing_GL_Treatment_ID__c;
                                                  orderItemsNew.blng__BillingRule__c = defaults.Billing_Rule_ID__c;
                                                  orderItemsNew.blng__BillingTreatment__c = defaults.Billing_Treatment_ID__c;
                                                  orderItemsNew.blng__FinanceBookAccounting__c = defaults.Finance_Book_Accounting_ID__c;
                                                  orderItemsNew.blng__RevenueRecognitionRule__c = defaults.Revenue_Recognition_Rule_ID__c;
                                                  
                                                  if (oppLine.Product2.AS_Stock_Level__c != null) {
                                                      orderItemsNew.AS_Product_Stock_Level__c = oppLine.Product2.AS_Stock_Level__c;
                                                      if (oppLine.Product2.AS_Stock_Level__c >= 0) {
                                                          orderItemsNew.AS_Backorder_Calculation__c = oppLine.Quantity - oppLine.Product2.AS_Stock_Level__c;
                                                      } else {
                                                          orderItemsNew.AS_Backorder_Calculation__c = oppLine.Quantity;
                                                      }
                                                      // for updating of product stock level 
                                                      indiprodToUpdate.Id = oppLine.Product2Id;
                                                      indiprodToUpdate.AS_Stock_Level__c = oppLine.Product2.AS_Stock_Level__c - oppLine.Quantity;
                                                      allprodToUpdateList.add(indiprodToUpdate);
                                                  }
                                                  
                                                  lstOrderItems.add(orderItemsNew);
                                              }
                                          }
                                      }
            }
            System.debug('lstOrders : ' + lstOrders);
            /*
system.debug('zzzzzz1 '  + [SELECT id FROM blng__GLRule__c] );

system.debug('zzzzzz2 '  + [SELECT id FROM blng__GLTreatment__c] );
system.debug('zzzzzz3 '  + [SELECT id FROM blng__BillingRule__c] );   
system.debug('zzzzzz4 '  + [SELECT id FROM blng__BillingTreatment__c] );
system.debug('zzzzzz5 '  + [SELECT id FROM blng__LegalEntity__c] );
system.debug('zzzzzz6 '  + [SELECT id FROM blng__RevenueRecognitionRule__c] );
system.debug('zzzzzz7 '  + [SELECT id FROM blng__GLRule__c] );
system.debug('zzzzzz8 '  + [SELECT id FROM blng__TaxRule__c] );
*/
            
            if (lstOrders.size() != 0) {
                insert lstOrders;
            }
            
            /*order O1= [select blng__BillingDayOfMonth__c , EffectiveDate FROM order where id in :lstOrders];
            system.debug('zzzzzzzz ' + O1);*/
            
            if (lstOrderItems.size() != 0) {
                system.debug('zzzzz ' + lstOrderItems);
                insert lstOrderItems;
            }
            list < Order > lstReupdate = new list < Order > ();
            for (Order reUpdate: lstOrders) {
                Order reUp = new Order();
                reUp.Id = reUpdate.Id;
                reUp.Status = 'Activated';
                reUp.blng__BillNow__c = true;
                if (!oppWithOrdbutNoInvMap.containsKey(reUpdate.OpportunityId)) {
                    reUp.AS_Generate_Invoice__c = true;
                }
                lstReupdate.add(reUp);
            }
            if (lstReupdate.size() != 0) {
                Database.Update(lstReupdate, false);
            }
            if (allprodToUpdateList.size() > 0) {
                Database.Update(allprodToUpdateList);
            }
            if (setOppIds.size() > 0) {
                List <Messaging.SingleEmailMessage> allmsg = new List <Messaging.SingleEmailMessage>();
                EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'AS_Subscription_Update_Confirmation'];
                list<OrgWideEmailAddress> owea = [select Id, Address from OrgWideEmailAddress where Address = 'noreply@psa.org.au'];
                for (Account acc2mail: [Select Id, Name, PersonContactId from Account where Id IN: setAccUpdateSubscriptionEmail]) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTemplateId(et.Id);
                    mail.setTargetObjectId(acc2mail.PersonContactId);
                    if (owea.size() > 0) {
                        mail.setorgWideEmailAddressId(owea[0].Id);
                    }
                    mail.setSaveAsActivity(false);
                    allmsg.add(mail);
                }
                System.debug('1 allTrainPlanAss : ' + allTrainPlanAss.size() + ' - ' + allTrainPlanAss);
                if (listSubscriptionInsert.size() > 0 || listSubscriptionUpdate.size() > 0 || lstOrders.size() > 0 || allTrainPlanAss.size() > 0 || allTobeAddedTrainTrackAcc.size() > 0) {
                    AS_commonFunction.runOppCloseWon = false;
                    
                    // added in the upper part to capture new data for opportunity update
                    if(allTobeAddedTrainTrackAcc.size() > 0) {
                        System.debug('allTobeAddedTrainTrackAcc : ' + allTobeAddedTrainTrackAcc[0]);
                        insert allTobeAddedTrainTrackAcc[0]; // only create one record for train track account creation (#PSAS-101)
                    }
                    
                    if(allUpdateAcc.size() > 0) {
                        update allUpdateAcc; // added to update the account ownership for student 2-16-18
                    }
                    
                    if(listSubscriptionInsert.size() > 0) {
                        insert listSubscriptionInsert;
                    }
                    
                    if(listSubscriptionUpdate.size() > 0) {
                        update listSubscriptionUpdate;
                        // code below is for updating the user profile to 'member' as per ticket (#PSA-375) starts here
                        Set<Id> allIdForUpdateToCurrentSet = new Set<Id>();
                        for(AS_Subscription__c memSub : listSubscriptionUpdate) {
                            
                            if(mapIdSubscription.containsKey(memSub.Id) && mapIdSubscription.get(memSub.Id).AS_User__c != null) {
                                allIdForUpdateToCurrentSet.add(mapIdSubscription.get(memSub.Id).AS_User__c);
                            }
                        }
                        
                        if(allIdForUpdateToCurrentSet.size()>0){
                            List<Id> allIdForUpdateToCurrentList = new List<Id>();
                            allIdForUpdateToCurrentList.addAll(allIdForUpdateToCurrentSet);
                            System.debug('allIdForUpdateToCurrentList : ' + allIdForUpdateToCurrentList);
                            System.enqueueJob(new AS_createUserFuture(allIdForUpdateToCurrentList));
                        }
                        // code below is for updating the user profile to 'member' as per ticket (#PSA-375) starts here
                        
                        
                    }
                    
                    if (listOpp2Update.size() > 0) {
                        System.debug('listOpp2Update : ' + listOpp2Update);
                        database.Update(listOpp2Update, false); // added for (#PSAS-101)
                    }
                    
                    if (listPSubscriptionUpdate.size() > 0) {
                        update listPSubscriptionUpdate; //Jan 9
                    }
                    
                    if (listPPaymentUpdate.size() > 0) {
                        update listPPaymentUpdate; //Jan 9
                    }
                    
                    if (allmsg.size() > 0) {
                        Messaging.sendEmail(allmsg, false);
                    }
                    
                    if (allTrainPlanAss.size() > 0) { // #PSA-79
                        LMSService.upsertAssignments(new Set < Id > {
                            allTrainPlanAss[0].User__c
                                }, allTrainPlanAss[0].Training_Plan__c, LMSUtils.getCurrentNetworkId());
                    }
                } else {
                    AS_commonFunction.runOppCloseWon = true;
                }
            }
            // system.debug('mapOppReferences ==> '+ mapOppReferences);
            
            // Boolean orderHasRecord = CreateOrderAndOrderItem( oppId , oppWithOrdbutNoInvMap , mapOppReferences );
            
            // if (setOppIds.size() > 0) {
            
            //     List <Messaging.SingleEmailMessage> allmsg = new List <Messaging.SingleEmailMessage>();
            
            //     EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'AS_Subscription_Update_Confirmation'];
            
            //     list<OrgWideEmailAddress> owea = [select Id, Address from OrgWideEmailAddress where Address = 'noreply@psa.org.au'];
            
            //     for (Account acc2mail: [Select Id, Name, PersonContactId from Account where Id IN: setAccUpdateSubscriptionEmail]) {
            
            //         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            //         mail.setTemplateId(et.Id); 
            
            //         mail.setTargetObjectId(acc2mail.PersonContactId);
            //         if (owea.size() > 0) {
            //             mail.setorgWideEmailAddressId(owea[0].Id);
            //         }
            //         mail.setSaveAsActivity(false);
            //         allmsg.add(mail);
            
            //     }
            
            //     System.debug('1 allTrainPlanAss : ' + allTrainPlanAss.size() + ' - ' + allTrainPlanAss);
            
            //     if (listSubscriptionInsert.size() > 0 || listSubscriptionUpdate.size() > 0 || orderHasRecord == true || allTrainPlanAss.size() > 0 || allTobeAddedTrainTrackAcc.size() > 0) {
            
            //         AS_commonFunction.runOppCloseWon = false;
            
            //         // added in the upper part to capture new data for opportunity update
            //         if(allTobeAddedTrainTrackAcc.size() > 0) {
            //             System.debug('allTobeAddedTrainTrackAcc : ' + allTobeAddedTrainTrackAcc[0]);
            //             insert allTobeAddedTrainTrackAcc[0]; // only create one record for train track account creation (#PSAS-101)
            //         }
            
            //         if(allUpdateAcc.size() > 0) {
            //             update allUpdateAcc; // added to update the account ownership for student 2-16-18
            //         }
            
            //         if(listSubscriptionInsert.size() > 0) {
            //             insert listSubscriptionInsert;
            //         }
            
            //         if(listSubscriptionUpdate.size() > 0) {
            
            //             update listSubscriptionUpdate;
            //             // code below is for updating the user profile to 'member' as per ticket (#PSA-375) starts here
            //             Set<Id> allIdForUpdateToCurrentSet = new Set<Id>();
            //             for(AS_Subscription__c memSub : listSubscriptionUpdate) {
            
            //                 if(mapIdSubscription.containsKey(memSub.Id) && mapIdSubscription.get(memSub.Id).AS_User__c != null) {
            //                     allIdForUpdateToCurrentSet.add(mapIdSubscription.get(memSub.Id).AS_User__c);
            //                 }
            //             }
            
            //             if(allIdForUpdateToCurrentSet.size()>0){
            //                 List<Id> allIdForUpdateToCurrentList = new List<Id>();
            //                 allIdForUpdateToCurrentList.addAll(allIdForUpdateToCurrentSet);
            //                 System.debug('allIdForUpdateToCurrentList : ' + allIdForUpdateToCurrentList);
            //                 System.enqueueJob(new AS_createUserFuture(allIdForUpdateToCurrentList));
            //             }
            //             // code below is for updating the user profile to 'member' as per ticket (#PSA-375) starts here
            
            //         }
            
            //         if (listOpp2Update.size() > 0) {
            
            //             System.debug('listOpp2Update : ' + listOpp2Update);
            //             database.Update(listOpp2Update, false); // added for (#PSAS-101)
            
            //         }
            
            //         if (listPSubscriptionUpdate.size() > 0) {
            
            //             update listPSubscriptionUpdate; //Jan 9
            
            //         }
            
            //         if (listPPaymentUpdate.size() > 0) {
            
            //             update listPPaymentUpdate; //Jan 9
            
            //         }
            
            //         if (allmsg.size() > 0) {
            
            //             Messaging.sendEmail(allmsg, false);
            
            //         }
            
            //         if (allTrainPlanAss.size() > 0) { // #PSA-79
            
            //             LMSService.upsertAssignments(new Set < Id > {
            //                 allTrainPlanAss[0].User__c
            //             }, allTrainPlanAss[0].Training_Plan__c, LMSUtils.getCurrentNetworkId());
            
            //         }
            
            //     } else {
            //         AS_commonFunction.runOppCloseWon = true;
            //     }
            // }
            
        } //recursive
        
    }
    
    
    public boolean CreateOrderAndOrderItem(  set < ID > oppId ,  Map < Id, Boolean > oppWithOrdbutNoInvMap , map < Id, String > mapOppReferences){ 
        system.debug('CreateOrderAndOrderItem mapOppReferences==> '+mapOppReferences);
        Boolean HasRecord = false;
        if (AS_commonFunction.runOppCloseWonOnce()) {
            
            list < Order > lstOrders = new list < Order > ();
            List < OrderItem > lstOrderItems = new List < OrderItem > ();
            List < Product2 > allprodToUpdateList = new List < Product2 > ();
            
            if (oppId.size() > 0) {
                System.debug('oppId :' + oppId);
                for (Opportunity opp: [SELECT Pricebook2Id, AS_Payment_Amount__c, AS_Generate_Order_Without_Invoice__c, CloseDate, Id, AccountId, Account.Name, Account.BillingAddress,
                                       Account.BillingCity, Account.BillingCountry, Account.BillingPostalCode,
                                       Account.BillingState, Account.BillingStreet, Account.ShippingAddress,
                                       Account.ShippingCity, Account.ShippingCountry, Account.ShippingPostalCode,
                                       Account.ShippingState, Account.ShippingStreet,
                                       (Select Id, OpportunityId, PricebookEntryId, Product2Id, UnitPrice, Quantity, Discount, AS_Taxable_Rate__c, AS_GST_Product__c, Description, Product2.AS_Stock_Level__c From OpportunityLineItems)
                                       FROM Opportunity WHERE Id IN: oppId
                                      ]) {
                                          ORder newOrder = new Order();
                                          newOrder.OpportunityId = opp.Id;
                                          newOrder.AccountId = opp.AccountId;
                                          //newOrder.BillingAddress = opp.Account.BillingAddress;
                                          newOrder.BillingCity = opp.Account.BillingCity;
                                          newOrder.BillingCountry = opp.Account.BillingCountry;
                                          newOrder.BillingPostalCode = opp.Account.BillingPostalCode;
                                          newOrder.BillingState = opp.Account.BillingState;
                                          newOrder.BillingStreet = opp.Account.BillingStreet; //  
                                          //newOrder.ShippingAddress = opp.Account.ShippingAddress;
                                          newOrder.ShippingCity = opp.Account.ShippingCity;
                                          newOrder.ShippingCountry = opp.Account.ShippingCountry;
                                          newOrder.ShippingPostalCode = opp.Account.ShippingPostalCode; //
                                          newOrder.ShippingState = opp.Account.ShippingState;
                                          newOrder.ShippingStreet = opp.Account.ShippingStreet;
                                          newOrder.Pricebook2Id = opp.Pricebook2Id;
                                          newOrder.EffectiveDate = opp.CloseDate;
                                          newOrder.Status = 'Draft';
                                          newOrder.AS_Payment_Amount__c = opp.AS_Payment_Amount__c;
                                          if (opp.AS_Generate_Order_Without_Invoice__c == true) {
                                              newOrder.AS_Generate_Invoice__c = false;
                                          } else {
                                              newOrder.AS_Generate_Invoice__c = true; // updated to true as michelle said that we will get rid of this field.
                                          }
                                          newORder.AS_extId__c = mapOppReferences.get(opp.Id);
                                          lstOrders.add(newORder);
                                          Order referenceOppsd = new Order(AS_extId__c = mapOppReferences.get(opp.Id));
                                          for (OpportunityLineItem oppLine: opp.OpportunityLineItems) {
                                              Product2 indiprodToUpdate = new Product2();
                                              OrderItem orderItemsNew = new OrderItem();
                                              orderItemsNew.PricebookEntryId = oppLine.PricebookEntryId;
                                              orderItemsNew.Order = referenceOppsd;
                                              orderItemsNew.UnitPrice = oppLine.UnitPrice;
                                              orderItemsNew.Quantity = oppLine.Quantity;
                                              orderItemsNew.AS_Discount__c = oppLine.Discount; //
                                              orderItemsNew.AS_Tax_Rate__c = oppLine.AS_Taxable_Rate__c; //
                                              orderItemsNew.AS_Taxable__c = oppLine.AS_GST_Product__c; //
                                              orderItemsNew.Description = oppLine.Description; //
                                              if (oppLine.Product2.AS_Stock_Level__c != null) {
                                                  orderItemsNew.AS_Product_Stock_Level__c = oppLine.Product2.AS_Stock_Level__c;
                                                  if (oppLine.Product2.AS_Stock_Level__c >= 0) {
                                                      orderItemsNew.AS_Backorder_Calculation__c = oppLine.Quantity - oppLine.Product2.AS_Stock_Level__c;
                                                  } else {
                                                      orderItemsNew.AS_Backorder_Calculation__c = oppLine.Quantity;
                                                  }
                                                  // for updating of product stock level 
                                                  indiprodToUpdate.Id = oppLine.Product2Id;
                                                  indiprodToUpdate.AS_Stock_Level__c = oppLine.Product2.AS_Stock_Level__c - oppLine.Quantity;
                                                  allprodToUpdateList.add(indiprodToUpdate);
                                              }
                                              lstOrderItems.add(orderItemsNew);
                                          }
                                      }
            }
            System.debug('lstOrders : ' + lstOrders);
            if (lstOrders.size() != 0) {
                insert lstOrders;
            }
            if (lstOrderItems.size() != 0) {
                insert lstOrderItems;
            }
            list < Order > lstReupdate = new list < Order > ();
            for (Order reUpdate: lstOrders) {
                Order reUp = new Order();
                reUp.Id = reUpdate.Id;
                reUp.Status = 'Activated';
                if (!oppWithOrdbutNoInvMap.containsKey(reUpdate.OpportunityId)) {
                    reUp.AS_Generate_Invoice__c = true;
                }
                lstReupdate.add(reUp);
            }
            if (lstReupdate.size() != 0) {
                Database.Update(lstReupdate, false);
            }
            if (allprodToUpdateList.size() > 0) {
                Database.Update(allprodToUpdateList);
            }
            
            
            
            if( lstOrders.size() > 0 ){
                HasRecord = true; 
            }
            
        }
        
        return HasRecord;
    } 
    
    @future
    public static void myFutureMethod(Set<Id> userIds, Id tPlanId, Id netId){
        LMSService.upsertAssignments(userIds, tPlanId, netId);
    }
    
}