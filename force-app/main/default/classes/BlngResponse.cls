public class BlngResponse {

    public string isSuccess;
    public salesforceResponse salesforceResponse;
    public gatewayResponse gatewayResponse;

    public class salesforceResponse
    {
        public string paymentTransactionId;
        public string paymentId;
    }
    
    public class gatewayResponse
    {
        public string responseStatus;
        public string responseCode;    
        public string responseMessage;         
    }

}



/*
{
   "salesforceResponse":{
      "paymentTransactionId":"a6A9D0000004GKAUA2",
      "paymentId":"a6B9D0000004SDJUA2"
   },
   "gatewayResponse":{
      "responseStatus":"Approved",
      "responseCode":"0",
      "responseMessage":"APPROVED"
   },
   "isSuccess":true
}
*/