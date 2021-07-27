public with sharing class DL_Password{
    
    @AuraEnabled
    Public static Boolean CheckPassword(String password){
        
        Boolean lowerCase = Pattern.compile('(.*[a-z].*)|([a-z].*)').matcher(password).matches();
        Boolean upperCase = Pattern.compile('(.*[A-Z].*)|([A-Z].*)').matcher(password).matches();
        Boolean alpha = Pattern.compile('(.*[a-zA-Z].*)|([a-zA-Z].*)').matcher(password).matches();
        Boolean nonAlpha = Pattern.compile('(.*[^A-Z].*)|([^A-Z].*)').matcher(password).matches();
        Boolean numeric = Pattern.compile('(.*[0-9].*)|([0-9].*)').matcher(password).matches();
        Boolean special = Pattern.compile('(.*[~!@#$%^&*()_,.?<>{}].*)|([~!@#$%^&*()_,.?<>{}].*)').matcher(password).matches();

        return (lowerCase && upperCase && special && numeric && password.length() >= 8 );
    }
    
    /*
    @AuraEnabled
    Public static String ResetPassword(String memberid,String password){//'912246'
        
        UserInfo.getSessionId();
        
        String response = memberid +':'+password; 
        ID userId;
        
        try{
            userId = [SELECT ID from user where AS_Imis_ID__c = :memberid].id;
            try{
                System.setPassword(userId, password);
                response = 'Password reset successfull';
            }
            
            catch(Exception e){
                response = 'Password reset was not successfull';
                System.debug(e.getMessage());
            }
        }
        
        catch(Exception e){
            System.debug(e.getMessage());
            response = 'Error: Invalid Member ID';
        }
        

        return response;

    }
	*/
}