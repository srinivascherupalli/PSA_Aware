public class AS_PSA_StoreEmail {
	public String emailAddress {get; set;}
    
    public void onload()
    { 
        emailAddress = UserInfo.getUserEmail();
    }
    
}