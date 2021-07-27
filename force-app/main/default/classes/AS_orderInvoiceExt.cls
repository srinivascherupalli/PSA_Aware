/*
* Author : WEW
* Description: extension class to get order line item for order invoice
* Parameter : None
* Return : None
*/
global without sharing class AS_orderInvoiceExt {
    
    public final Order finalOrder;
    
    public AS_orderInvoiceExt(ApexPages.StandardController stdController) {
       /*
        this.finalOrder = (Order)stdController.getRecord();
        
        System.debug('finalOrder : ' + finalOrder + ' - ' +finalOrder.Id);
        Id finalId = finalOrder.Id;
       */ 
            Id finalId = ApexPages.currentPage().getParameters().get('id');
            theOrder = [Select 
                            Account.PSA_PSA_ID__c,
                            EffectiveDate,
                            AS_Invoice_Number__c,
                            Account.Name,
                            BillToContactId,
                            BillToContact.Name,
                            BillingStreet,
                            BillingCity,
                            BillingState,
                            BillingPostalCode,
                            BillingCountry,
                            ShippingStreet,
                            ShippingCity,
                            ShippingState,
                            ShippingPostalCode,
                            ShippingCountry,
                            AS_Purchase_Order__c,
                            TotalAmount,
                            AS_Taxable_Amount__c,
                            AS_Invoiced_Amount__c,
                            AS_Payment_Amount__c,
                            AS_Outstanding_Amount__c,
                            AS_Payment_Terms__c,
                            Account.PSA_BPAY_CRN__c,
                            Id,
                            Name
                        from 
                            Order 
                        where Id = :finalId 
                            order by createdDate DESC
                        ];
        for(OrderItem ord : [SELECT AS_Discount__c,Description,UnitPrice,Quantity,TotalPrice,Pricebookentry.Product2.Name,ListPrice FROM OrderItem where orderId = :finalId order by createdDate DESC]) {
            
            Double indiExtend = (ord.AS_Discount__c!=null && ord.AS_Discount__c!=0)?ord.UnitPrice-((ord.AS_Discount__c/100)*ord.UnitPrice):ord.UnitPrice;
        //  Double indiExtend = (ord.AS_Discount__c!=null && ord.AS_Discount__c!=0)?ord.UnitPrice:0;
            processOrderItem pr = new processOrderItem(ord.Quantity,ord.AS_Discount__c,ord.Pricebookentry.Product2.Name,ord.ListPrice,ord.TotalPrice);
            allprocessOrdItem.add(pr);
            
        }
        
        System.debug('allprocessOrdItem :' + allprocessOrdItem);
        
        Id businessAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        
        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        List<Order> ordAcc = [Select Id, Name, ShipToContact.Name,AS_Ship_To_Contact__c, Account.recordTypeId, Account.Name from Order where Id = :finalId];
        
        System.debug('ordAcc[0].AS_Ship_To_Contact__c :' + ordAcc.size() + ordAcc + personAccountId);
        if(ordAcc[0].AS_Ship_To_Contact__c  != null && ordAcc[0].Account.recordTypeId  == personAccountId) {
            shipToContactStr = ordAcc[0].AS_Ship_To_Contact__c;
            shipToContactAccStr = null;
        } else if(ordAcc[0].AS_Ship_To_Contact__c  != null && ordAcc[0].Account.recordTypeId  == businessAccountId) {
            shipToContactStr = ordAcc[0].AS_Ship_To_Contact__c;
            shipToContactAccStr = ordAcc[0].Account.Name;
        } else if(ordAcc[0].AS_Ship_To_Contact__c  == null) {
            shipToContactStr = null;
            shipToContactAccStr = ordAcc[0].Account.Name;
        }
        
    }
    
    public Order theOrder {
      get {
          if(theOrder == null) {
              theOrder = new Order();
          }
          return theOrder;
      }
      set;
    }
    
    public String shipToContactStr {
      get {
          if(shipToContactStr == null) {
              shipToContactStr = null;
          }
          return shipToContactStr;
      }
      set;
    }
    
    public String shipToContactAccStr {
      get {
          if(shipToContactAccStr == null) {
              shipToContactAccStr = null;
          }
          return shipToContactAccStr;
      }
      set;
    }
    
    public List<processOrderItem> allprocessOrdItem {
      get {
          if(allprocessOrdItem == null) {
              allprocessOrdItem = new List<processOrderItem>();
          }
          return allprocessOrdItem;
      }
      set;
    }
  
  /*
    * Author : WEW
    * Description: wrapper class for order line item
    * Parameter : None
    * Return : None
    */
    global class processOrderItem {  
        public decimal quantity {get; set;}
        public decimal discount {get; set;}
        public String description {get; set;}
        public decimal unitprice {get; set;}
        public decimal extendedprice {get; set;}
        
        public processOrderItem(decimal quan,decimal dis, String des,decimal unit, decimal extend) {
            quantity = quan;
            discount = dis;
            description = des;
            unitprice = unit;
            extendedprice = extend;
        }
    }
}