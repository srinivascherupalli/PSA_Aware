public class AS_PSA_CustomLogoutController {

    public PSA_Community__c psaURL {get; set;}
    
    public AS_PSA_CustomLogoutController(){}
    
    
    public void onloadEmail( String emailAddress )
    {
        //String emailAddress = UserInfo.getUserEmail();
        psaURL = [SELECT URLS__c FROM PSA_Community__c];
        list<String> psaLogUrl = String.valueOf(psaURL.URLS__c).split(',');
        for( String rest_url : psaLogUrl ) {
             String mode = ( rest_url.contains( 'local_psa_integration_user_logout' ) ) ? 'moodle' : 'wp';
             String param = generateParam( emailAddress, mode );
            HttpResponse resp = restCallout( rest_url, param, mode );
            //system.debug( 'logout response==========>' + resp.getBody());
     	}
    }
    
    public string generateParam( String email, String mode ) {
        
        if ( mode == 'wp' ) {
        	JSONGenerator jsonGenerator = JSON.createGenerator(true);
            jsonGenerator.writeStartObject();
            jsonGenerator.writeStringField('email', email);
            jsonGenerator.writeEndObject();
            return jsonGenerator.getAsString(); 
        } else {
			return 'user%5B0%5D%5Bemail%5D='+email;
		}

    }
    
    public HttpResponse restCallout( String logoutUrl, String param, string mode ) {
           
        Http http = new Http(); 
        HttpRequest httpRequest = new HttpRequest();
        
       	httpRequest.setEndpoint( logoutUrl );
        httpRequest.setMethod('POST');
        httpRequest.setTimeout(20000);
        
        if ( mode == 'wp' ) {
           httpRequest.setHeader('Content-Type', 'application/json');
        } else {
			httpRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded');
		}
       
        httpRequest.setBody( param );
        
        HttpResponse httpResponse = http.send(httpRequest);
        return httpResponse;  
    }
    
    public string emailStr {get;set;}
    public void  pushValue() {
      emailStr = Apexpages.currentPage().getParameters().get('myParam');
	  onloadEmail( emailStr );
      system.debug(emailStr);
    }
    
}