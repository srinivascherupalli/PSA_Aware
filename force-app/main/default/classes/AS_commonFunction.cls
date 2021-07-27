public class AS_commonFunction {
	public AS_commonFunction() {
		
	}
	
	public static String generateRandomString(Integer len) {
	    final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
	    String randStr = '';
	    while (randStr.length() < len) {
	       Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
	       randStr += chars.substring(idx, idx+1);
	    }
	    Datetime dt = Datetime.now();
		Long l = dt.getTime();
	    return randStr+String.valueOf(l); 
	}
	
	public static String generateRandomIntString(Integer len) {
	    final String chars = '0123456789';
	    String randStr = '';
	    while (randStr.length() < len) {
	       Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
	       randStr += chars.substring(idx, idx+1);
	    }
	    return randStr; 
	}

	public static boolean run = true;
    public static boolean runOnce(){
        if(run){
         run=false;
         return true;
        }else{
            return run;
        }
    }
    
    public static boolean runOrdIteTrigger = true;
    public static boolean runOrdIteTriggerOnce(){
        if(runOrdIteTrigger){
         runOrdIteTrigger=false;
         return true;
        }else{
            return runOrdIteTrigger;
        }
    }
    
    public static boolean runupdateAccount = true;
    public static boolean runupdateAccountOnce(){
        if(runOrdIteTrigger){
         runOrdIteTrigger=false;
         return true;
        }else{
            return runOrdIteTrigger;
        }
    }
    
    public static boolean runOrdTrigger = true;
    public static boolean runOrdTriggerOnce(){
        if(runOrdTrigger){
         runOrdTrigger=false;
         return true;
        }else{
            return runOrdTrigger;
        }
    }
    
    public static boolean runOppCloseWon = true;
    public static boolean runOppCloseWonOnce(){
        if(runOppCloseWon){
         runOppCloseWon=false;
         return true;
        }else{
            return runOppCloseWon;
        }
    }

    public static boolean runSendEmailBgCurseEn =true;
    public static boolean runSendEmailBgCurseEnOnce() {
        if(runSendEmailBgCurseEn){
            runSendEmailBgCurseEn=false;
            return true;
        }else{ 
            return runSendEmailBgCurseEn;
        }
    }

 //   public static void resetRunOnceFlag() {
	//	run = TRUE;
	//}

    /*
    @future
    public static void updateUsers(Set<Id> setUsers){
    	List<Profile> listProfile = [Select Id,Name from Profile where Name='Non Member Login User' LIMIT 1];
    	List<User> listUser = new List<User>();
    	for(User usr : [Select Id,Name,Email,ProfileId from User where Id IN :setUsers]){
    		if(listProfile[0]!=null){
	    		User usr2Update = new User();
				usr2Update.Id = usr.Id;
				usr2Update.ProfileId = listProfile[0].Id;
	    		listUser.add(usr2Update);
	    	}
    	}

    	update listUser;
    }
    */
    
    public static Boolean isSandbox() {
    	Organization org = [SELECT IsSandbox FROM Organization LIMIT 1];
    	return org.IsSandbox;
    }
    
    public static Id ownerId(){
    	List<User> ownerUser = new List<User>();
    	if(isSandbox()) {
        	ownerUser = [SELECT isActive,Profile.Name,Id FROM User where Profile.Name='System Administrator' AND isActive=true AND Name='Alphasys' Limit 1];
        } else {
        	ownerUser = [SELECT isActive,Profile.Name,Id FROM User where Profile.Name='System Administrator' AND isActive=true ORDER BY CreatedDate ASC Limit 1];
        }
        return ownerUser[0].Id;
    }
    
    public static String convertListStrToStr(List<String> theList) {
	    System.debug('finalStr the list: ' + theList);
	    String finalStr = '';
	    for(String str :theList) {
	    	finalStr += '\'';
	    	finalStr += String.escapeSingleQuotes(str);
	    	finalStr += '\'';
	    	finalStr += ',';
	    }
			finalStr = finalStr.removeEnd(',');
			System.debug('finalStr : ' + finalStr);
			return finalStr;
    }

}