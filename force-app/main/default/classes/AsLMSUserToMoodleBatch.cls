global class AsLMSUserToMoodleBatch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {

    /*
    *Author : Michael Vincent Largo
    *Description : Batch for lms_user
    *Date Created : 01/15/2019
    *Last Modified By: None 
    *Date Last Modified: 01/15/2019
    *Related Metadata : None
    *Action : Database.Batchable
    *Param : List<LMS_Instance__c> theData
    *Return : None
    */

    String query;
    Integer indexToRemove = 0;
    list<LMS_Instance__c> newallInstanceList = new list<LMS_Instance__c>();
    String idStr;

    public AsLMSUserToMoodleBatch(List<LMS_Instance__c> allInstanceList) {
    //System.debug('AsMoodleApiCalloutQueueable is called');
       
        Integer indexCnt = 0;
        indexToRemove = indexCnt;
        newallInstanceList = allInstanceList;


        idStr = String.valueOf(allInstanceList[indexCnt].Id);

        query = 'SELECT '+
                            'Id,'+
                            'Name,'+
                            'LMS_Instance__r.Token__c,'+
                            'LMS_Instance__r.URL__c,'+
                            'Moodle_User_Id__c,'+
                            'FirstName__c,'+
                            'LastName__c,'+
                            'Email__c,'+
                            'As_Sync_Attempt__c,'+
                            'AS_Authentication_Method__c '+
                        'FROM LMS_User__c '+
                        'WHERE '+
                            'LMS_Instance__c =: idStr'+
                            ' AND Moodle_User_Id__c <> null'+
                            ' AND As_Creation_Status__c = \'In Progress\'';
    }


    global Database.QueryLocator start(Database.BatchableContext BC){
        //String query = 'Select Id, AS_Authentication_Method__c, FirstName__c, LastName__c, Email__c, As_Creation_Status__c, LMS_Instance__c, Moodle_User_Id__c From LMS_User__c where As_Creation_Status__c = \'In Progress\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<LMS_User__c> LMSuserScope){
        

        string function = 'local_psa_integration_update_users';   
        String format = 'json';
        String EndPointURL = newallInstanceList[0].URL__c+'?wstoken='+newallInstanceList[0].Token__c+'&wsfunction='+function+'&moodlewsrestformat='+ format;
        String reqBody = '';
        Integer moodleDataCntr = 0;
        String response;
        List<LMS_User__c> countSyncAttemptUpdate = new List<LMS_User__c>();


        for(LMS_User__c moodleData : LMSuserScope){

            LMS_User__c tobecountSyncAttempt = new LMS_User__c();
            tobecountSyncAttempt.Id = moodleData.Id;
            tobecountSyncAttempt.As_Sync_Attempt__c = (moodleData.As_Sync_Attempt__c !=null) ? moodleData.As_Sync_Attempt__c + 1 : 1;
            countSyncAttemptUpdate.add(tobecountSyncAttempt);

            reqBody += (moodleDataCntr > 0)?'&':'';
            reqBody += 'users%5B'+moodleDataCntr+'%5D%5Bsf_id%5D='+ moodleData.Id;
            reqBody += '&users%5B'+moodleDataCntr+'%5D%5Bfirstname%5D='+ moodleData.FirstName__c;
            reqBody += '&users%5B'+moodleDataCntr+'%5D%5Blastname%5D='+ moodleData.LastName__c;
            reqBody += '&users%5B'+moodleDataCntr+'%5D%5Bemail%5D='+ moodleData.Email__c;

            String finalStr8 = (moodleData.AS_Authentication_Method__c == 'Restrict by IP')?'ip':moodleData.AS_Authentication_Method__c.toLowerCase();
            reqBody += '&users%5B'+moodleDataCntr+'%5D%5Bauth%5D='+ finalStr8;
      
            moodleDataCntr++;

        }
          System.debug('reqBody: '+reqBody);  
        try {

            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(EndPointURL);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setTimeout(120000);
            req.setBody(reqBody);

            HttpResponse res = http.send(req);
            response = res.getBody();
            System.debug('req: '+req);
            System.debug('response: '+response);
          
            List<Object> responseDetailList = (List<Object>) JSON.deserializeUntyped(response);

                List<LMS_User__c> allLmsUser = new List<LMS_User__c>();

                for(Object responseObject : responseDetailList) {
                    Map<String,Object> singleresponseDetailMap = (Map<String,Object>) responseObject;

                    LMS_User__c newLmsUser = new LMS_User__c();
                    newLmsUser.Id = String.valueOf(singleresponseDetailMap.get('sf_id'));
                    If(String.isNotBlank(String.valueOf(singleresponseDetailMap.get('userid')))){
                      newLmsUser.Moodle_User_Id__c = String.valueOf(singleresponseDetailMap.get('userid'));  
                    }
                    newLmsUser.As_Creation_Status__c = (singleresponseDetailMap.get('status') == true) ? 'Success' : 'In Progress';
                    allLmsUser.add(newLmsUser);
                }
        	if(countSyncAttemptUpdate.size() > 0) {
                database.update(countSyncAttemptUpdate,false);
            }
                system.debug('allLmsUser: '+allLmsUser);
                if(allLmsUser.size() > 0) {
                    database.update(allLmsUser,false);
                }

            } catch(Exception ex) {
                System.debug('ERROR OCCUR ON UPDATE OF MOODLE USER' + ex);
                List<LMS_User__c> errorallLmsUser = new List<LMS_User__c>();
                Set<Id> lmsUserSet = new Set<Id>();

               // if(!Test.IsRunningTest()){

                for (LMS_User__c moodleData : LMSuserScope){

                        if(!lmsUserSet.contains(moodleData.Id)){ 

                            LMS_User__c newLmsUser = new LMS_User__c();
                            newLmsUser.Id = String.valueOf(moodleData.Id);
                            newLmsUser.As_Sync_Attempt__c = (moodleData.As_Sync_Attempt__c != null) ? moodleData.As_Sync_Attempt__c + 1 : 1;

                            errorallLmsUser.add(newLmsUser);
                            lmsUserSet.add(moodleData.Id);
                        }
                    }
                //}
                system.debug('lmsUserSet==>: ' + lmsUserSet);

                if(errorallLmsUser.size() > 0){
                    Database.update(errorallLmsUser,false);
                }
            }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        newallInstanceList.remove(indexToRemove);
        if (newallInstanceList.size() > 0){
            AsLMSUserToMoodleBatch usertomoodle = new AsLMSUserToMoodleBatch(newallInstanceList);
            Database.executeBatch(usertomoodle);
        } 
    }
}