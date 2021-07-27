public class OnlineSalesProcessor {
    
    public class OpptyToOrder implements Queueable {
        public void execute(QueueableContext context) {
            // Your processing logic here       
     
            // Call OrderToInvoiceQueueable
            // System.enqueueJob(new SecondJob());
        }
    }
}