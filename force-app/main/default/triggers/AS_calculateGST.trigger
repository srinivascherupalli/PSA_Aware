trigger AS_calculateGST on OpportunityLineItem (after insert,before update) {
    
    if(as_checkRecursive.runOnce_AS_calculateGST())
    { 
        set< Id > oppLineId = new set< Id >();
        for ( OpportunityLineItem oppLineItem : Trigger.new ) { oppLineId.add( oppLineItem.Id ); }
        
        list< OpportunityLineItem > oppLineItemsList = new list< OpportunityLineItem >( );
        map< Id , Boolean > gstProducts = new map< Id , Boolean >();
        
        if ( Trigger.IsUpdate ) {
            
            for ( OpportunityLineItem oppLineItem : [ SELECT AS_GST_Product__c,TotalPrice,Product2.AS_GST_Product__c FROM OpportunityLineItem where Id in: oppLineId ] ) {
                gstProducts.put( oppLineItem.Id , oppLineItem.Product2.AS_GST_Product__c );     
            }
            
            for(  OpportunityLineItem oppLineItem : Trigger.new ){    
                oppLineItem.AS_GST_Product__c  = gstProducts.get(oppLineItem.Id);  
            }
            
        } else {
            
            for ( OpportunityLineItem oppLineItem : [ SELECT Id,AS_GST_Product__c,TotalPrice,Product2.AS_GST_Product__c FROM OpportunityLineItem where Id in: oppLineId ] ) {    
                OpportunityLineItem oppnew = new OpportunityLineItem( Id = oppLineItem.Id );
                oppnew.AS_GST_Product__c  = oppLineItem.Product2.AS_GST_Product__c;  
                oppLineItemsList.add(oppnew);
            }
            
            update oppLineItemsList;
        }
       
    }
    

    
 
}