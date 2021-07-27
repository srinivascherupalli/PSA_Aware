/**
 * @description       : 
 * @author            : matt.bathersby@theawaregroup.com.au
 * @group             : 
 * @last modified on  : 14-07-2021
 * @last modified by  : matt.bathersby@theawaregroup.com.au
 * Modifications Log 
 * Ver   Date         Author                                Modification
 * 1.0   14-07-2021   matt.bathersby@theawaregroup.com.au   Initial Version
**/
public class CreateActivatedOrderQueueable implements Queueable {
    
    List<Opportunity> opps;
    final Standalone_Order_Defaults__c DEFAULTS = Standalone_Order_Defaults__c.getInstance();
    
    public CreateActivatedOrderQueueable(List<Opportunity> opps) {
        this.opps = opps;
    }
    
    public void execute(QueueableContext context) {
        List<Order> lstOrders = new List<Order>();
        List<OrderItem> lstOrderItems = new List<OrderItem>();
        
        for(Opportunity opp : opps){
            string matchingkey = AS_commonFunction.generateRandomString(40);
            
            Order newOrder = new Order();
            newOrder.AS_extId__c = matchingkey;
            newOrder.blng__BillingDayOfMonth__c = String.valueOf(system.today().day());
            newOrder.OpportunityId = opp.Id;
            newOrder.AccountId = opp.AccountId;
            newOrder.blng__BillingAccount__c = opp.AccountId;
            newOrder.BillingCity = opp.Account.BillingCity;
            newOrder.BillingCountry = opp.Account.BillingCountry;
            newOrder.BillingPostalCode = opp.Account.BillingPostalCode;
            newOrder.BillingState = opp.Account.BillingState;
            newOrder.BillingStreet = opp.Account.BillingStreet; //  
            newOrder.ShippingCity = opp.Account.ShippingCity;
            newOrder.ShippingCountry = opp.Account.ShippingCountry;
            newOrder.ShippingPostalCode = opp.Account.ShippingPostalCode; //
            newOrder.ShippingState = opp.Account.ShippingState;
            newOrder.ShippingStreet = opp.Account.ShippingStreet;
            newOrder.Pricebook2Id = opp.Pricebook2Id;
            newOrder.EffectiveDate = opp.CloseDate;
            newOrder.Status = 'Draft';
            newOrder.Chargent_Order__c = opp.Chargent_Order__c;
            newOrder.Chargent_Processing_Status__c = 'Queued';
            newOrder.blng__BillNow__c = false;
            lstOrders.add(newORder);
            
            Order orderRef = new Order();
            orderRef.AS_extId__c = matchingKey;
            
            for (OpportunityLineItem oppLine: opp.OpportunityLineItems) {
                //Product2 indiprodToUpdate = new Product2();
                OrderItem orderItemsNew = new OrderItem();
                orderItemsNew.blng__BillingAccount__c = opp.AccountId;
                orderItemsNew.blng__BillableUnitPrice__c = oppLine.UnitPrice + oppLine.AS_Taxable_Amount__c;
                orderItemsNew.PricebookEntryId = oppLine.PricebookEntryId;
                orderItemsNew.Order = orderRef;
                orderItemsNew.UnitPrice = oppLine.UnitPrice + oppLine.AS_Taxable_Amount__c;
                orderItemsNew.Quantity = oppLine.Quantity;
                orderItemsNew.AS_Discount__c = oppLine.Discount; //
                orderItemsNew.AS_Tax_Rate__c = oppLine.AS_Taxable_Rate__c; //
                orderItemsNew.AS_Taxable__c = oppLine.AS_GST_Product__c; //
                orderItemsNew.Description = oppLine.Description; //
                orderItemsNew.ServiceDate = opp.CloseDate;

                orderItemsNew.blng__BillingGLRule__c = defaults.Billing_GL_Rule_ID__c;
                orderItemsNew.blng__BillingGLTreatment__c = defaults.Billing_GL_Treatment_ID__c;
                orderItemsNew.blng__BillingRule__c = defaults.Billing_Rule_ID__c;
                orderItemsNew.blng__BillingTreatment__c = defaults.Billing_Treatment_ID__c;
                orderItemsNew.blng__FinanceBookAccounting__c = defaults.Finance_Book_Accounting_ID__c;
                orderItemsNew.blng__RevenueRecognitionRule__c = defaults.Revenue_Recognition_Rule_ID__c;
                orderItemsNew.blng__TaxStatus__c = 'Queued';
                
                lstOrderItems.add(orderItemsNew);
            }       
        }
        
        
        List<sObject> forInsert = new List<sObject>();
        List<Database.SaveResult> orderResults = database.insert(lstOrders, false);
        List<Database.SaveResult> orderItemResults = database.insert(lstOrderItems, false);
        
        List<Opportunity> opptys = new List<Opportunity>();
        List<Order> orders = new List<Order>();
        
        for(integer i = 0; i < orderResults.size(); i++){
            Opportunity o = new Opportunity();
            o.Id = lstOrders[i].OpportunityId;
            
            if(!orderResults[i].isSuccess()){
                o.Chargent_Processing_Status__c = 'Error';
                o.Chargent_Processing_Error__c = orderResults[i].getErrors()[0].getMessage();                
            }
            else {
                o.Chargent_Processing_Status__c = 'Completed';
                
                Order ord = new Order();
                ord.Id = orderResults[i].getId();
                ord.Status = 'Activated';
                
                orders.add(ord);
            }
            
            opptys.add(o);
        }
        
        if(!opps.isEmpty()){
            database.update(opptys);
        }
        
        if(!orders.isEmpty()){
            database.update(orders);
        }
        
        System.enqueueJob(new CreateInvoiceQueueable());
    }

}