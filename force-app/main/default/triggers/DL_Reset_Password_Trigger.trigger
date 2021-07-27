trigger DL_Reset_Password_Trigger on Account (before update) {

    for(Account acct : Trigger.new){
        
        if(acct.DL_Reset_Password__c == true && String.isNotBlank(acct.DL_Set_Password__c)){
            String password = acct.DL_Set_Password__c;
            String error = 'Check Password Complexity';
            
            Boolean passwordCheck = DL_Password.CheckPassword(password);
            
            if(passwordCheck){
                System.debug('DL_Password.CheckPassword == true');
                User user = [SELECT id,accountId from User where AccountId = :acct.id];
                System.setPassword(user.Id, password);
                acct.DL_Set_Password__c = '';
            }
            
            else{
                acct.DL_Set_Password__c = error;
                System.debug(error);
            }
            
            acct.DL_Reset_Password__c = false;
        }     
        
        else{
            acct.DL_Set_Password__c = null;
        }
    }
}