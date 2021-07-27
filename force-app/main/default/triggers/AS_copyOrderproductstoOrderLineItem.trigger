trigger AS_copyOrderproductstoOrderLineItem on OrderItem (before insert, before update) {
    System.debug('AS_copyOrderproductstoOrderLineItem');
  Set<Id> allPriIdSet = new Set<Id>();
  for(OrderItem ordItem: Trigger.New){
    allPriIdSet.add(ordItem.PricebookEntryId);
  }
  
  Map<Id,Boolean> prodHasTaxMap = new Map<Id,Boolean>();
  Map<Id,Decimal> prodStockLevelMap = new Map<Id,Decimal>();
  if( allPriIdSet.size() > 0 ) {
    for(PricebookEntry pri : [Select Id,Name,Product2.AS_GST_Product__c,Product2.AS_Stock_Level__c from PricebookEntry where Id IN :allPriIdSet]){
        prodHasTaxMap.put(pri.Id,pri.Product2.AS_GST_Product__c);
        prodStockLevelMap.put(pri.Id,pri.Product2.AS_Stock_Level__c);
      }
  }
  
  System.debug('prodHasTaxMap :' + prodHasTaxMap);
  // for appending the data 
  for(OrderItem ordItem: Trigger.New){
    ordItem.AS_Taxable__c = prodHasTaxMap.get(ordItem.PricebookEntryId);
    
    if( Trigger.isInsert ) {
        ordItem.AS_Product_Stock_Level__c = prodStockLevelMap.get(ordItem.PricebookEntryId);
    }
  }
  
}