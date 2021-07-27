/*
* Author : WEW
* Description: Serves as a wrapper class to combine data that is shown in "PaymentPage".
* Parameter : 
* Return : 
*/
public class AS_paymentWrapper {
	public String OPPORTUNITYID;
	public String ACCOUNTID;
	public String PRICEBOOKID;
	public String SUBTOTAL; 
	public dscnt DISCOUNT;
	public String HASDISCOUNT;
	public String TOTAL;
	public String PAYBY;
	public cardDet CARDDETAILS;
	public accDet ACCOUNTDETAILS;
	public Boolean ACKNOWLEDGEDBRQSTSRVC;
	public Boolean CONSENTTOGIVESGNTR;
	public Boolean ONCEOFF;
    
    public class dscnt {
    	public String type;
    	public String value;
    	public String coupon;
    }
    
    public class cardDet {
    	public String Name_On_Card;
    	public String Card_Type;
    	public String Card_Number;
    	public String Card_Expiry_Month;
    	public String Card_Expiry_Year;
    	public String CCV;
    }
    
    public class accDet {
    	public String Account_Name;
    	public String Account_Type;
    	public String Account_Number;
    	public String Account_Routing_Number;
    	public String First_Payment_Date;
    }
    
}