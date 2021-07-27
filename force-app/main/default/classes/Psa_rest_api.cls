@RestResource(urlMapping='/PSA_process_order/*')
global with sharing class Psa_rest_api {
	
    private static List<sObject> objcts = new List<sObject>();
    private static Map<String,sObject> objcts2 = new Map<String,sObject>();
    
  
    
    @HttpPost
    global static Map<String,sObject>  doPost() {
       
        String body = System.RestContext.request.requestBody.toString();
        List<String> account_field_list = new List<String>{'Order_id','AccountRecordType','CompanyName','FirstName','LastName','PersonEmail','Phone','Order_total','Discount_Percentage','Discount_total','Product_Discount_pe','Stripe_source_id','BillingStreet','BillingCity','BillinCountry','BillingPostalCode','BillingState','IsShiptoDifAdd','ShippingFname','ShippingLname','ShippingStreet','ShippingCity','ShippingCountry','ShippingPostalCode','ShippingState','Order_note','FileName','FileContent','StoreCredit','Gateway_id', 'Transaction_id', 'Order_Status'};
	    Map<String, String> account_details = new Map<String, String>();
      
        List<Map<String,String>> product_order_details = new List<Map<String,String>>();
        
        JSONParser parser = JSON.createParser(body);	
	    while ( parser.nextToken() != null)  {
		    String key =  parser.getText() ;
            if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) && ( account_field_list.contains( key ) == true ) ) {
                parser.nextToken();
                account_details.put( key, parser.getText() );
            }
			
           if ( parser.getCurrentToken() == JSONToken.START_ARRAY ) {
                while ( parser.nextToken() != null ) {
				    if ( parser.getCurrentToken() == JSONToken.START_OBJECT ) {
                        Order_detail od = (Order_detail)parser.readValueAs( Order_detail.class );
                        Map<String,String> pod = new Map<String,String>{
                            'id' => od.product_id ,
                            'quantity' =>String.valueOf(od.quantity),
                            'price' => String.valueOf(od.price),
                            'totalprice' => String.valueOf(od.totalprice),
                            'pricebookentry' => od.PriceBookEntry,
                            'tax_rate'	=> String.valueOf( od.tax_rate ),
                            'percentage_discount' => String.valueOf( od.percentage_discount )
                        };
                        product_order_details.add(pod);
                       	parser.skipChildren();
                    }
                }
            }
        }
        
        Account Account_touse=null;
        String contact_id =null;
        if( account_details.get('AccountRecordType') =='Person Account' ){
            Account test_accnt_exist = null; 
            List<Account> accs = [SELECT id,FirstName,LastName,Name FROM Account where  LastName=:account_details.get('LastName') and PersonEmail=:account_details.get('PersonEmail')];
            if( !accs.isEmpty() ){
                test_accnt_exist = accs[0];
                Account_touse = test_accnt_exist;
            } else {
                Account new_acnt = new Account(
                FirstName=account_details.get('FirstName'),
                LastName=account_details.get('LastName'),
                PersonEmail= account_details.get('PersonEmail'),
                BillingCity= account_details.get('BillingCity'),
                BillingCountry= account_details.get('BillinCountry'),
                BillingPostalCode= account_details.get('BillingPostalCode'),
                BillingState= account_details.get('BillingState'),
                BillingStreet= account_details.get('BillingStreet'),
                ShippingCity= account_details.get('ShippingCity'),
                ShippingCountry= account_details.get('ShippingCountry'),
                ShippingPostalCode= account_details.get('ShippingPostalCode'),
                ShippingState= account_details.get('ShippingState'),
                ShippingStreet= account_details.get('ShippingStreet'),
            	Phone = account_details.get('Phone')
                        
                );
                insert new_acnt;
                Account_touse = new_acnt;
            }

            Account temp = [Select PersonContactId From Account Where Id = :Account_touse.Id];
            contact_id = temp.PersonContactId;
        } else {
            
            Account test_accnt_exist = null; 
            List<Account> accs = [SELECT id,Name FROM Account where Name=:account_details.get('CompanyName') ];
            if( !accs.isEmpty() ) {
                test_accnt_exist = accs[0];
                Account_touse = test_accnt_exist;
            } else {
                Id recordtype_id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();

                String accName = null;

                if ( account_details.get('CompanyName') == '' || account_details.get('CompanyName') == null ) {
                    
                    accName = account_details.get('FirstName') + ' ' + account_details.get('LastName');

                } else {

                    accName = account_details.get('CompanyName');

                }

                Account new_acnt = new Account(
                	RecordTypeId= recordtype_id,
					Name	= accName,
                    BillingCity= account_details.get('BillingCity'),
                    BillingCountry= account_details.get('BillinCountry'),
                    BillingPostalCode= account_details.get('BillingPostalCode'),
                    BillingState= account_details.get('BillingState'),
                    BillingStreet= account_details.get('BillingStreet'),
                    ShippingCity= account_details.get('ShippingCity'),
                    ShippingCountry= account_details.get('ShippingCountry'),
                    ShippingPostalCode= account_details.get('ShippingPostalCode'),
                    ShippingState= account_details.get('ShippingState'),
                    ShippingStreet= account_details.get('ShippingStreet'),
                	Phone = account_details.get('Phone')
                );
                insert new_acnt;
                Account_touse = new_acnt;
            }
            
            if( String.isNotEmpty(Account_touse.Id) ) {
              Contact temp_con = create_contact( Account_touse , account_details );
              contact_id = temp_con.Id;
            }
        }
        
        if( String.isNotEmpty( Account_touse.Id ) ) {
          objcts2.put( 'Account', Account_touse );

            Opportunity created_opp = create_opp( account_details, Account_touse, product_order_details );

            if ( String.isNotEmpty( created_opp.Id ) ) {

                objcts2.put( 'Opportunity', created_opp );
                String order_id_str = null;

                if ( account_details.get('Order_Status') != 'failed' ) {

                    Order r = createOrder( account_details, Account_touse, created_opp );
                    order_id_str = r.Id;

                    if( String.isNotEmpty( r.Id ) ) {
                        create_note( r.Id, account_details.get('Order_note')  );
                        addorderlineitem( r, product_order_details, account_details.get('Discount_total'), account_details.get('Product_Discount_pe'), account_details.get('StoreCredit') );
                        add_contact_to_order( r, contact_id );
                        objcts2.put('Order', r);
                    }
                }
                
                save_pp_payment( account_details.get('Order_id'), Account_touse,  account_details.get('Stripe_source_id'), Decimal.valueOf( account_details.get('Order_total') ), created_opp.Id, order_id_str, account_details.get('Gateway_id'), account_details.get('Transaction_id'), account_details.get('Order_Status') );
            }
        }
       
        return objcts2;
    }
    
    
    @TestVisible private static void add_contact_to_order( Order r, String contact_id  ){
    	r.BillToContactId = contact_id;
        update r;
    }
    
    @TestVisible private static void create_note( String owner_id, String note_body  ){
      if( String.isNotEmpty( note_body )  ){
    	note n = new note();
        n.parentId = owner_id; //Id of the opportunity for which you want to add this note
        n.body = note_body; // body of the note. this should be populated from the notes field that you have shown in the screenshot
        n.title = 'Order Note'; // the title of the note
        n.isPrivate=false;  // if private it will be visible only for the owner and any user with modify all permission
        insert n; //insert the record
      }
    }
    
    
    @TestVisible private static void create_attachment( String id, Map<String, String> account_details ) {
        String Filename = account_details.get( 'FileName' );
        String FileContent = account_details.get( 'FileContent' );

        if( String.isNotEmpty( Filename ) ){
            Blob ret =  EncodingUtil.base64Decode( FileContent );
            Attachment att = new Attachment();
            att.Body = ret;
            att.Name = Filename;
            att.parentId = id;
            insert att;
        }
    }
    
    @TestVisible private static Contact create_contact( Account acnt, Map<String, String> account_details ){
        List<Contact> contcts = [SELECT id,FirstName,LastName FROM Contact where FirstName=:account_details.get('FirstName') and LastName=:account_details.get('LastName') and Email=:account_details.get('PersonEmail') and IsPersonAccount = false ];
        if( !contcts.isEmpty() ){
            contcts[0].AccountId = acnt.Id ;
            update contcts[0];
            return contcts[0];
        } else {
            Contact new_contact = new Contact(
    			AccountId	= acnt.Id,
            	FirstName	= account_details.get('FirstName'),
    			LastName	= account_details.get('LastName'),
    			Email		= account_details.get('PersonEmail'),	
                MailingCity = account_details.get('BillingCity'),
                MailingCountry = account_details.get('BillinCountry'),
                MailingPostalCode = account_details.get('BillingPostalCode'),
                MailingState= account_details.get('BillingState'),
                MailingStreet= account_details.get('BillingStreet')
            );
     		insert new_contact;
        	return new_contact;
        }
    }
    
    @TestVisible private static Opportunity create_opp( Map<String, String> account_details, Account accnt, List<Map<String,String>> products ) {

	    Id opp_recordtypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Online Shop').getRecordTypeId();
    	String nme = ( String.isNotEmpty( accnt.Name ) ) ? accnt.Name : accnt.FirstName+' '+accnt.LastName;
        String oppName = nme + ' - ' + 'Order #'+ account_details.get('Order_id');
        String Order_Status = account_details.get('Order_Status');

        List<Opportunity> listOpp = [SELECT Id,Name,RecordTypeId FROM Opportunity WHERE RecordTypeId=:opp_recordtypeid AND Name=:oppName];
        Opportunity new_opp = new Opportunity();

        if ( listOpp.size() > 0 ) {

            new_opp.Id = listOpp[0].Id;
            new_opp.StageName    = ( Order_Status == 'failed' ? 'Closed Lost' : 'Closed Won' );
            new_opp.CloseDate    = system.today();
            update new_opp;

        } else {

            new_opp.RecordTypeId = opp_recordtypeid;
            new_opp.Name         = oppName;
            new_opp.AccountId    = accnt.Id;
            new_opp.StageName    = 'Prospecting';
            new_opp.CloseDate    = system.today();
            new_opp.AS_Payment_Amount__c = Decimal.valueOf( account_details.get('Order_total') );
            new_opp.AS_Generate_Order_Without_Invoice__c = false;
            insert new_opp;

            if ( String.isNotEmpty( new_opp.Id ) ) {
                addlineitems( new_opp, products, account_details );
                update_stock( products );
                create_attachment( new_opp.Id, account_details );
            }

        }
    	return new_opp;
    }

    @TestVisible private static void addlineitems( Opportunity opp, List<Map<String,String>> products, Map<String, String> account_details ) {
        
        String StoreCredit = account_details.get('StoreCredit');
        String Order_Status = account_details.get('Order_Status');

        List<OpportunityLineItem> oli_list = new List<OpportunityLineItem>();
        Integer counter = 1;
        for( Map<String,String> p : products  ) {
            if( String.isNotEmpty( p.get('pricebookentry') ) ) {
                OpportunityLineItem oli = new OpportunityLineItem();
                oli.OpportunityId = opp.Id;
                oli.Quantity = Decimal.valueOf( p.get('quantity') );
                oli.PricebookEntryId  = p.get('pricebookentry') ;
                oli.UnitPrice = Decimal.valueOf( p.get('price') );
                if( Decimal.valueOf( p.get('percentage_discount') ) > 0 ){
                	oli.Discount =  Decimal.valueOf( p.get('percentage_discount') );    
                }
                oli_list.add(oli);
                objcts2.put( 'Opportunity '+opp.Id+' Line Item '+counter, oli );
                counter++;
            }
        }

        if ( Decimal.valueof( StoreCredit ) > 0 ) {
            Product2 storecreditprod = [SELECT Id FROM Product2 WHERE Name = 'Store Credit'];
            PricebookEntry pbe = [SELECT Pricebook2Id FROM PricebookEntry WHERE Id =: products[0].get( 'pricebookentry' ) ];
            PricebookEntry sc_pb = [SELECT Id FROM PricebookEntry WHERE Product2Id =: storecreditprod.Id AND Pricebook2Id =: pbe.Pricebook2Id];
            
            OpportunityLineItem oli_store_credit = new OpportunityLineItem();
            oli_store_credit.OpportunityId = opp.Id;
            oli_store_credit.Quantity = 1;
            oli_store_credit.PricebookEntryId  = sc_pb.Id;
            oli_store_credit.UnitPrice = Decimal.valueOf( StoreCredit ) * -1;
            oli_list.add(oli_store_credit);
        }
            
        insert oli_list; 

        // update opporunity stage
        opp.StageName = ( Order_Status == 'failed' ? 'Closed Lost' : 'Closed Won' );
        update opp;
    }
    
    @TestVisible private static Order createOrder(Map<String,String> od,Account accnt,Opportunity opp){
        Order ordr = new Order();
        ordr.AccountId = accnt.Id;
        ordr.EffectiveDate  = system.today();
        ordr.OpportunityId = opp.Id;
        ordr.BillingCity = od.get('BillingCity');
        ordr.BillingCountry = od.get('BillingCountry');
        ordr.BillingPostalCode = od.get('BillingPostalCode');
        ordr.BillingState = od.get('BillingState');
        ordr.BillingStreet = od.get('BillingStreet');
        ordr.ShippingCity = od.get('ShippingCity');
        ordr.ShippingCountry = od.get('ShippingCountry');
        ordr.ShippingPostalCode = od.get('ShippingPostalCode');
        ordr.ShippingState = od.get('ShippingState');
        ordr.ShippingStreet = od.get('ShippingStreet');
        /*ordr.AS_Shipping_Status__c = 'Pending';*/
        ordr.AS_Payment_Amount__c = Decimal.valueOf( od.get('Order_total') );
        ordr.Status = 'Draft';
        ordr.Description = od.get('Order_note');
        if ( od.get('IsShiptoDifAdd') == 'true' ) {
            ordr.AS_Ship_To_Contact__c = od.get('ShippingFname') +' '+od.get('ShippingLname');
        }
        
        insert ordr;
        return ordr;
    }
    
    @TestVisible private static void addorderlineitem(Order ordr,List<Map<String,String>> products, String Order_total_discount , String Product_discount_pe, String StoreCredit ){
      
        for ( Map<String,String> p1 : products  ) {
            if ( String.isNotEmpty( p1.get('pricebookentry') ) ) {
                PricebookEntry current_pb = [ SELECT Pricebook2Id FROM PricebookEntry WHERE Id =:p1.get('pricebookentry') ]; 
                ordr.Pricebook2Id = current_pb.Pricebook2Id;
            }
        }
        update ordr;
        
        List<OrderItem> order_item_list = new List<OrderItem>();
        List<OrderItem> order_item_list_update = new List<OrderItem>();
        
        Integer counter = 1;
        for ( Map<String,String> p : products  ) {
            if ( String.isNotEmpty( p.get('pricebookentry') ) ) {
                OrderItem oil = new OrderItem();
               
                Decimal percentage_discount = Decimal.valueof( p.get('percentage_discount') ) / 100;
                Decimal less_amount = (Decimal.valueOf( p.get('totalprice') ) * percentage_discount );
                Decimal total_price = Decimal.valueOf( p.get('totalprice') );
                
                Decimal entry_price = (total_price - less_amount) / Decimal.valueOf( p.get('quantity') );
                Decimal taxable_amount =  ( less_amount * percentage_discount );
                
                oil.OrderId = ordr.Id;
                oil.UnitPrice = entry_price;
                oil.AS_Discount__c = Decimal.valueOf( p.get('percentage_discount') );
                oil.Quantity = Decimal.valueOf( p.get('quantity') );
                oil.PricebookEntryId  = p.get('pricebookentry') ;
                oil.AS_Tax_Rate__c = Decimal.valueOf( p.get('tax_rate') );
				oil.AS_Shipping_Status__c = 'Pending';
                order_item_list.add(oil);
                objcts2.put('Order '+ordr.Id+' Line Item '+counter, oil);
                counter++;
            }
        }


         if ( Decimal.valueof( StoreCredit ) > 0 ) {

            Product2 storecreditprod = [SELECT Id FROM Product2 WHERE Name = 'Store Credit'];
            PricebookEntry pbe = [SELECT Pricebook2Id FROM PricebookEntry WHERE Id =: products[0].get( 'pricebookentry' ) ];
            PricebookEntry sc_pb = [SELECT Id FROM PricebookEntry WHERE Product2Id =: storecreditprod.Id AND Pricebook2Id =: pbe.Pricebook2Id];
            
            OrderItem oli_store_credit = new OrderItem();
            oli_store_credit.OrderId = ordr.Id;
            oli_store_credit.UnitPrice =  Decimal.valueOf( StoreCredit ) * -1;
            oli_store_credit.PricebookEntryId  = sc_pb.Id;
            oli_store_credit.Quantity = 1;
            oli_store_credit.AS_Shipping_Status__c = 'Pending';
            order_item_list.add(oli_store_credit);

        }
        
        /*if( Decimal.valueOf( Order_total_discount ) < 0 ){
        	
            OrderItem oil = new OrderItem();
            oil.OrderId = ordr.Id;
            oil.UnitPrice = Decimal.valueOf( Order_total_discount );
            oil.Quantity = 1;
            oil.PricebookEntryId  = Product_discount_pe;
            order_item_list.add(oil);
            
        }*/
        //If AS_Current_Stock_Level__c <= 0, then AS_Backorder_Calculation__c = Quantity
		//If AS_Current_Stock_Level__c > 0, then AS_Backorder_Calculation__c = Quantity - AS_Current_Stock_Level_c
        
        insert order_item_list;
        
        for( OrderItem o : order_item_list ){
        	OrderItem oi = [SELECT id,AS_Current_Stock_Level__c,AS_Backorder_Calculation__c,Quantity FROM OrderItem where  id=:o.Id ];
        	
            if( oi.AS_Current_Stock_Level__c <= 0 ){
            	oi.AS_Backorder_Calculation__c = oi.Quantity;
            }else{
                oi.AS_Backorder_Calculation__c = oi.Quantity - oi.AS_Current_Stock_Level__c ;
            }
			
			order_item_list_update.add( oi );            
        }
        
        update order_item_list_update;

        ordr.AS_Generate_Invoice__c = true;
        ordr.Status = 'Activated';
        
        update ordr;
        
    }
    
    @TestVisible private static void update_stock( List<Map<String,String>> products ){
        
        List<Product2> prdcts = new List<Product2>();
        for(Map<String,String> prd : products){
            Product2 p = [SELECT Id,Name,AS_Stock_Level__c  FROM Product2 where Id=: prd.get('id')];
            Integer sl = ( p.AS_Stock_Level__c !=null ) ? Integer.valueOf( p.AS_Stock_Level__c ) : 0 ;
            p.AS_Stock_Level__c = sl - Integer.valueOf( prd.get('quantity') );
            System.debug('Product'+p.Id+' Difference '+p.AS_Stock_Level__c+' - '+prd.get('quantity') );
            prdcts.add(p);
        }
		update prdcts;
    }
    
   @TestVisible private static void save_pp_payment( String order_id,Account acnt , String r_id , Decimal ammount ,String Opp_id, String sf_order_id, String gateway_id, String transaction_id, String Order_Status ){
       
       String nme = ( String.isNotEmpty( acnt.Name ) ) ? acnt.Name : acnt.FirstName+' '+acnt.LastName;
       String ppsearch = '%' + nme + ' Online Shop #' + order_id + '%';

       List<ASPHPP__Payment__c> ppayment = [SELECT Id,Name FROM ASPHPP__Payment__c WHERE ASPHPP__Process_Payment__c = 'Web' AND ASPHPP__Payment_Type__c = 'Credit Card' AND Name LIKE :ppsearch];

       ASPHPP__Payment__c n_p = new ASPHPP__Payment__c();

       if ( ppayment.size() > 0 ) {

            n_p.Id = ppayment[0].Id;
            n_p.ASPHPP__Payment_Date__c =  date.today();
            n_p.ASPHPP__Payment_Status__c = ( Order_Status == 'failed' ? 'Failed' : 'Success' );
            if ( sf_order_id != null ) {
                n_p.AS_Order__c = sf_order_id;
            }
            n_p.ASPHPP__Payment_ID__c = transaction_id;
            update n_p;

        } else {

            n_p.Name = nme+' Online Shop #'+ order_id +' '+ system.today().format();
            n_p.ASPHPP__Amount__c = ammount;
            n_p.ASPHPP__Account__c = acnt.Id;
            n_p.ASPHPP__Payment_Date__c =  date.today();
            n_p.ASPHPP__Payment_Status__c = ( Order_Status == 'failed' ? 'Failed' : 'Success' );
            n_p.ASPHPP__Process_Payment__c ='Web';
            n_p.ASPHPP__Reference__c = r_id;
            n_p.ASPHPP__Payment_Type__c = 'Credit Card';
            n_p.ASPHPP__Opportunity__c = Opp_id;
            if ( sf_order_id != null ) {
                n_p.AS_Order__c = sf_order_id;
            }
            if ( gateway_id != '' && gateway_id != null && gateway_id != 'null' ) {
                n_p.ASPHPP__Gateway__c = gateway_id;
            }
            n_p.ASPHPP__Payment_ID__c = transaction_id;
           
            insert n_p;
        }
    }
}