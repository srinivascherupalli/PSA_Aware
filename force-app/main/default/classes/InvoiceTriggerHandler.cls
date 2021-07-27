public class InvoiceTriggerHandler {

    public static void afterInsert(set<Id> invoiceIds){
        List<blng__Invoice__c> invoices = [SELECT Id, blng__Account__c, blng__Order__c, blng__Order__r.Chargent_Processing_Status__c, blng__InvoiceStatus__c, blng__Order__r.Chargent_Order__c,
                                           blng__Order__r.Chargent_Order__r.ChargentOrders__Transaction_Total__c, blng__Order__r.Chargent_Order__r.ChargentOrders__Payment_Method__c 
                                           FROM blng__Invoice__c
                                           WHERE Id in :invoiceIds
                                           AND blng__Order__r.Chargent_Order__c != null
                                           AND blng__Order__r.Chargent_Processing_Status__c = 'Initialised'];
        
        List<Order> orders = new List<Order>();
        
        for(blng__Invoice__c inv : invoices){
            inv.blng__InvoiceStatus__c = 'Posted';
            
            Order ord = new Order();
            ord.Id = inv.blng__Order__c;
            ord.Chargent_Processing_Status__c = 'Completed';
            
            orders.add(ord);
        }
        
        database.update(invoices);
        database.update(orders);
        
        createPayments(invoices);
    }
    
    public static void createPayments(List<blng__Invoice__c> invoices){
        List<blng__Payment__c> payments = new List<blng__Payment__c>();
        
        for(blng__Invoice__c inv : invoices){
            blng__Payment__c p = new blng__Payment__c();
            p.blng__Account__c = inv.blng__Account__c;
            p.blng__Invoice__c = inv.Id;
            p.blng__PaymentDate__c = system.today();
            p.blng__PaymentType__c = inv.blng__Order__r.Chargent_Order__r.ChargentOrders__Payment_Method__c;
            p.blng__Amount__c = inv.blng__Order__r.Chargent_Order__r.ChargentOrders__Transaction_Total__c;
            p.blng__Status__c = 'Draft';
            
            payments.add(p);
        }
        
        database.insert(payments);
        createPaymentAllocations(payments);
    }
    
    public static void createPaymentAllocations(List<blng__Payment__c> payments){
        List<blng__PaymentAllocationInvoice__c> allocations = new List<blng__PaymentAllocationInvoice__c>();
        
        for(blng__Payment__c payment : payments){
            blng__PaymentAllocationInvoice__c pa = new blng__PaymentAllocationInvoice__c();
            pa.blng__Invoice__c = payment.blng__Invoice__c;
            pa.blng__Payment__c = payment.Id;
            pa.blng__Amount__c = payment.blng__Amount__c;
            pa.blng__Type__c = 'Allocation';
            
            allocations.add(pa);
            
            payment.blng__Status__c = 'Posted';
        }
        
        database.insert(allocations);
		database.update(payments);
    }
    
}