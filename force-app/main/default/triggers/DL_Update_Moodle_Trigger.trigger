trigger DL_Update_Moodle_Trigger on LMS_User__c (after update) {
    
    for(LMS_User__c lmsUser : Trigger.new){
        User user;
        LMS_User__c oldRecord;
        
        for(LMS_User__c oldlmsUser : Trigger.old){
            if(oldlmsUser.id == lmsUser.id){
                oldRecord = oldlmsUser;
            }
        }
    

        try{
            user = [SELECT ID,AS_Imis_ID__c,Username FROM User WHERE AS_Imis_ID__c = :lmsUser.PSA_Imis_ID__c];
        }

        catch(Exception e){
            System.debug(e.getMessage());
        }

        if(oldRecord.Email__c != lmsUser.Email__c && user != null){
            if(lmsUser.Email__c == user.Username){
                DL_Update_Moodle.UpdateUsername(String.valueof(lmsUser.id));
            }
            
            else{
                System.debug('LMS_User__C.Email__c != User.Username');
                throw new DL_Exception( '************************************************ \n Update Username on User Object before attempting '+ 
                                    'to update the LMS User Email \n ************************************************* \n');
            }
        }
        
    }
}