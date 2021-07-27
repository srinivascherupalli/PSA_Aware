public class ProcessPaidOrdersBatch implements Database.Batchable<sObject>, database.Stateful{

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Pricebook2Id, CloseDate, Id, AccountId, Account.Name, Account.BillingAddress,
                                         Account.BillingCity, Account.BillingCountry, Account.BillingPostalCode,
                                         Account.BillingState, Account.BillingStreet, Account.ShippingAddress,
                                         Account.ShippingCity, Account.ShippingCountry, Account.ShippingPostalCode,
                                         Account.ShippingState, Account.ShippingStreet, Chargent_Order__c, 
                                         	(select Id, OpportunityId, PricebookEntryId, Product2Id, UnitPrice, Quantity, Discount, AS_Taxable_Amount__c, AS_Taxable_Rate__c, AS_GST_Product__c, Description, Product2.AS_Stock_Level__c 
                                             from OpportunityLineItems)
                                         FROM Opportunity 
                                         WHERE IsWon = false
                                         AND Chargent_Order__c != null
                                         AND Chargent_Processing_Status__c = 'Queued']);
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> scope){
        
        OpportunityStage oppStageName = [SELECT Id, MasterLabel 
                                         FROM OpportunityStage 
                                         WHERE IsClosed = true 
                                         AND IsWon = true 
                                         LIMIT 1];
        
        for(Opportunity o : scope){
            o.StageName = oppStageName.MasterLabel;
            o.Chargent_Processing_Status__c = 'Initialised';
        }
        
        update scope;
        
        System.enqueueJob(new CreateActivatedOrderQueueable(scope));
        
        // create order with items
        	// related to chargent order
        	// set chargent processing status 
        	// activate
        	// bill now
        // createPayments(scope);
        	// 
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
    
    /*private static void createPayments(List<blng__Invoice__c> invoices){
        List<blng__Payment__c> payments = new List<blng__Payment__c>();
        
        for(blng__Invoice__c inv : invoices){
            blng__Payment__c p = new blng__Payment__c();
            p.blng__Account__c = inv.blng__Account__c;
            p.blng__Invoice__c = inv.Id;
            p.blng__PaymentDate__c = system.today();
            p.blng__PaymentType__c = inv.blng__Order__r.Chargent_Order__r.ChargentOrders__Payment_Method__c;
            p.blng__Amount__c = inv.blng__Order__r.Chargent_Order__r.ChargentOrders__Transaction_Total__c;
            
            payments.add(p);
        }
        
        database.insert(payments);
        
        createPaymentAllocations(payments);
    }
    
    private static void createPaymentAllocations(List<blng__Payment__c> payments){
        List<blng__PaymentAllocationInvoice__c> allocations = new List<blng__PaymentAllocationInvoice__c>();
        
        for(blng__Payment__c payment : payments){
            blng__PaymentAllocationInvoice__c pa = new blng__PaymentAllocationInvoice__c();
            pa.blng__Invoice__c = payment.blng__Invoice__c;
            pa.blng__Payment__c = payment.Id;
            pa.blng__Amount__c = payment.blng__Amount__c;
            pa.blng__Type__c = 'Allocation';
            
            allocations.add(pa);
        }
        
        database.insert(allocations);
    }*/
    
}