/*
* Author : WEW
* Description: Trigger to call the PDF creator when order item is created or updated
* Parameter : None
* Return : None
*/
trigger AS_createInvoice on OrderItem (after insert, after update) {
    /*
    if(AS_commonFunction.runOrdIteTriggerOnce()) { 
        Set<Id> setOrderId = new Set<Id>();
        List<Id> listOrderId = new List<Id>();
        for(OrderItem ordItem : Trigger.New){
            setOrderId.add(ordItem.OrderId);
        }
        listOrderId.addAll(setOrderId);
        
        Integer max25 = 0;
        
        System.debug('listOrderId :' + listOrderId);
        
        list<id> allOrderIdforPDF = new list<id>();
        for(Order ord : [Select Id,Name,Status,AS_Generate_Invoice__c from Order where ID IN :listOrderId]) {
            if(ord.Status == 'Activated' && ord.AS_Generate_Invoice__c == true && max25<= 25){
                allOrderIdforPDF.add(ord.Id);
                max25++;
            } else if(max25 > 25){
                break;
            }
        }
        
        System.debug('allOrderIdforPDF :' + allOrderIdforPDF);
        // call the pdf creator class starts here
        if(allOrderIdforPDF.size()>0) {
            System.debug('allOrderIdforPDF : ' + allOrderIdforPDF);
            AS_pdfTriggerController.addinvoicePDFandEmail(allOrderIdforPDF);
            
            AS_commonFunction.runOrdIteTrigger = false;
        } else {
            AS_commonFunction.runOrdIteTrigger = true;
        }
    }
    */
}