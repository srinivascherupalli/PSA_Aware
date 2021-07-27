public with sharing class HttpService 
{   
    
    private static HttpService httpServiceInstance;
    
    private HttpResponse httpResponse;
    private Map<String,String> mapOfHeaderParameter = new Map<String,String>();
    private enum Method {GET, POST}
    

    public static HttpService getInstance() 
    {
        if (NULL == httpServiceInstance) 
        {
            httpServiceInstance =  new HttpService();  
        }
        return httpServiceInstance;
    }
    

    public void get(String endPoint) 
    {
        send(newRequest(Method.GET, endPoint));
    }
    

    public void post(String endPoint, String requestBody)
    {
        send(newRequest(Method.POST, endPoint, requestBody));
    }
    

    public void addHeader(String name, String value)
    {
        mapOfHeaderParameter.put(name, value);
    }
    

    private void setHeader(HttpRequest request) 
    {
        for(String headerValue : mapOfHeaderParameter.keySet())
        {
            request.setHeader(headerValue, mapOfHeaderParameter.get(headerValue));
        }
    }
    

    public void setAuthorizationHeader(String userName,String password) 
    {
        if(String.isNotBlank(userName) && String.isNotBlank(password))
        {
            Blob headerValue = blob.valueOf(userName + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            addHeader('Authorization', authorizationHeader);
        }
    }
    

    public void setTokenisationHeader(String userName,String password) 
    {
        if(String.isNotBlank(userName) && String.isNotBlank(password))
        {
            Blob headerValue = blob.valueOf(userName + ':' + password);
            String tokenisationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            addHeader('Tokenisation', tokenisationHeader);
        }
    }
    

    private HttpRequest newRequest(Method method, String endPoint)
    {
        return newRequest(method, endPoint, NULL);
    }
    

    private HttpRequest newRequest(Method method, String endPoint, String requestBody) 
    {
        HttpRequest request = new HttpRequest();
        request.setMethod(Method.name());
        setHeader(request);
        request.setEndpoint(endPoint);
        if (String.isNotBlank(requestBody)) 
        {
            request.setBody(requestBody);
        }   
        request.setTimeout(120000);
        return request;
    }
    

    private void send(HttpRequest request) 
    {
        try 
        {
            httpResponse = new Http().send(request);
        }
        catch(Exception e) 
        {
          throw e;    
        }
    }
    

    public HttpResponse getResponse()
    {
        return httpResponse;
    }
    
 
    public String getResponseToString()
    {
        return getResponse().toString();
    }
}