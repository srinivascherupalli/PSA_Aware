/*
 * Author : WEW
 * Description: trigger to call the PDF creator
 * Parameter : None
 * Return : None
 */
trigger AS_createInvoiceOrder on Order(after insert, after update) {
    AsOrderHandler handler = new AsOrderHandler(true);
    
    /* after Insert */
    if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new,Trigger.newMap);
    } 
    /* After Update */
    else if(Trigger.isUpdate && Trigger.isAfter) {
      if (AS_commonFunction.runOrdTriggerOnce()) {
        System.debug('runOrdTriggerOnce');
        Set < Id > setOrderId = new Set < Id > ();
        Set < Id > ordersUpdateSet = new Set < Id > ();
        for (Order ord: Trigger.New) {
    
          Boolean oldGenerate = Trigger.OldMap.get(ord.Id).AS_Generate_Invoice__c;
          Boolean newGenerate = Trigger.NewMap.get(ord.Id).AS_Generate_Invoice__c;
          String oldStatus = Trigger.oldMap.get(ord.Id).Status;
          String newStatus = Trigger.NewMap.get(ord.Id).Status;
    
          if (newStatus == 'Activated') {
    
            ordersUpdateSet.add(ord.Id);
    
          }
                System.debug('oldStatus :' + oldStatus);
                System.debug('newStatus :' + newStatus);
                System.debug('oldGenerate :' + oldGenerate);
                System.debug('newGenerate :' + newGenerate);
          if ((oldStatus != newStatus || oldGenerate != newGenerate) && newGenerate == true && newStatus == 'Activated') {
            setOrderId.add(ord.Id);
          }
        }
    
        Integer max25 = 0;
    
        System.debug('setOrderId :' + setOrderId);
    
        list < id > allOrderIdforPDF = new list < id > ();
    
        for (Order ord: [Select Id, (Select Id from OrderItems) from Order where ID IN: setOrderId]) {
    
          if (max25 <= 25 && ord.OrderItems.size() > 0) {
    
            allOrderIdforPDF.add(ord.Id);
            max25++;
    
          } else if (max25 > 25) {
    
            break;
    
          }
    
        }
    
    
        // call the pdf creator class starts here
        if (allOrderIdforPDF.size() > 0) {
    
          System.debug('allOrderIdforPDF : ' + allOrderIdforPDF);
          
          if(!System.isFuture() && !System.isBatch()) {
            AS_pdfTriggerController.addinvoicePDFandEmail(allOrderIdforPDF);
          }
          AS_commonFunction.runOrdTrigger = false;
    
        } else {
    
          AS_commonFunction.runOrdTrigger = true;
    
        }
      }
    }
}