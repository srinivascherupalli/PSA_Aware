public class DL_Orders{
	
    @AuraEnabled
    public static string completeOrderItems(String order_ID){
        string response = null;
        
        try{
            List<OrderItem> order_Items = [SELECT ID,OrderID,AS_Shipping_Status__c FROM OrderItem 
                                                        WHERE OrderID = :order_ID];


            For(OrderItem order_Item : order_Items){
                order_Item.AS_Shipping_Status__c = 'Completed';
            }

            update order_Items;

            return response = 'Order '+ order_ID + ' OrderItems Updated Successfully';
        }

        catch(Exception e){
            return response = e.getMessage();
        }  
    }

    @AuraEnabled
    public static string processingOrderItems(String order_ID){
        string response = null;
        
        try{
            List<OrderItem> order_Items = [SELECT ID,OrderID,AS_Shipping_Status__c FROM OrderItem 
                                                        WHERE OrderID = :order_ID];


            For(OrderItem order_Item : order_Items){
                order_Item.AS_Shipping_Status__c = 'Processing';
            }

            update order_Items;

            return response = 'Order '+ order_ID + ' OrderItems Updated Successfully';
        }

        catch(Exception e){
            return response = e.getMessage();
        }  
    }
}