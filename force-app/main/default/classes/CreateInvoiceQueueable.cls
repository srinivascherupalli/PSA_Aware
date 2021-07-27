public class CreateInvoiceQueueable implements Queueable {
    
    List<Order> ords;
    
    public CreateInvoiceQueueable() {
        this.ords = [select Id, Status, blng__BillNow__c, Chargent_Processing_Status__c from Order where Chargent_Processing_Status__c = 'Queued'];
    }
    
    public void execute(QueueableContext context) {
        for(Order ord : ords){
            ord.blng__BillNow__c = true;
            ord.Chargent_Processing_Status__c = 'Initialised';
        }
        database.update(ords);
    }
}