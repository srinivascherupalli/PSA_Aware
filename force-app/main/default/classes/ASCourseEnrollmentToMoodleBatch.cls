/*Author : Ronald Santander
*Description : batch class that handles the passing of data from salesforce to moodle
*Date Created : 1/15/2019
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data : LMS Course Enrolment
*/

global class ASCourseEnrollmentToMoodleBatch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts{
  String query;
  Integer indexToRemove;
  list<LMS_Instance__c> newallInstanceList = new list<LMS_Instance__c>();
  String idStr;
  Id lmsCourseEnrolID;

  public ASCourseEnrollmentToMoodleBatch(list<LMS_Instance__c> allInstanceList,Id singleID){

    if (singleID != null){
      lmsCourseEnrolID = singleID;
      query = 'SELECT '+
                          'Id,'+
                          'As_Sync_Attempts__c,'+
                          'Name,'+
                          'LMS_Course__c,'+
                          'LMS_Instance__r.Token__c,'+
                          'LMS_Instance__r.URL__c,'+
                          'As_Moodle_Id__c,'+
                          'LMS_User__r.Firstname__c,'+
                          'LMS_User__r.Lastname__c,'+
                          'LMS_User__r.Email__c,'+
                          'LMS_User__r.As_Sync_Attempt__c,'+
                          'LMS_User__c,'+
                          'LMS_User__r.AS_Authentication_Method__c '+
                      'FROM LMS_Course_Enrolment__c '+
                      'WHERE '+
                          'Id =: lmsCourseEnrolID'+
                          ' AND As_Creation_Status__c = \'In Progress\'';
    }else{
      Integer indexCnt = 0;
      indexToRemove = indexCnt;
      newallInstanceList = allInstanceList;

      idStr = String.valueOf(allInstanceList[indexCnt].Id);

      query = 'SELECT '+
                          'Id,'+
                          'As_Sync_Attempts__c,'+
                          'Name,'+
                          'LMS_Course__c,'+
                          'LMS_Instance__r.Token__c,'+
                          'LMS_Instance__r.URL__c,'+
                          'As_Moodle_Id__c,'+
                          'LMS_User__r.Firstname__c,'+
                          'LMS_User__r.Lastname__c,'+
                          'LMS_User__r.Email__c,'+
                          'LMS_User__r.As_Sync_Attempt__c,'+
                          'LMS_User__c,'+
                          'LMS_User__r.AS_Authentication_Method__c '+
                      'FROM LMS_Course_Enrolment__c '+
                      'WHERE '+
                          'LMS_Instance__c =: idStr'+
                          ' AND As_Creation_Status__c = \'In Progress\'';
    }
  }

  global Database.QueryLocator start(Database.BatchableContext BC){
    system.debug('query: '+query);
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext BC, List<LMS_Course_Enrolment__c> scope){

    Set<Id> allLmsUserIdSet = new Set<Id>();
    Map<Id,LMS_User__c> allLmsUserMap = new Map<Id,LMS_User__c>();
    Map<Id,User> allUserMap = new Map<Id,User>();
    List<LMS_Course_Enrolment__c> updateAttemptList = new List<LMS_Course_Enrolment__c>();

    for (LMS_Course_Enrolment__c lmsEnroll : scope){
                if (lmsEnroll.LMS_User__c != null) {
                    allLmsUserIdSet.add(lmsEnroll.LMS_User__c);
                }
    }

    allLmsUserMap = new Map<Id,LMS_User__c>([SELECT Firstname__c, Lastname__c, Email__c,AS_Authentication_Method__c FROM LMS_User__c WHERE Id = :allLmsUserIdSet]);

    for(User theUser : [SELECT 
                                                    Id, 
                                                    Firstname, 
                                                    Lastname, 
                                                    CommunityNickname, 
                                                    Email, 
                                                    Username,
                                                    LMS_Instance__c,
                                                    LMS_User__c
                                                FROM 
                                                    User 
                                                WHERE 
                                                    LMS_User__c  IN :allLmsUserIdSet
                                                ]){
            allUserMap.put(theUser.LMS_User__c,theUser);    
        }
    
    String FORMATSTR = 'json';
    String FUNCTIONSTR = 'local_psa_integration_enrol_users';
    String EndPointURL = scope[0].LMS_Instance__r.URL__c+'?wstoken='+scope[0].LMS_Instance__r.Token__c+'&wsfunction='+FUNCTIONSTR+'&moodlewsrestformat='+ FORMATSTR;
    String reqBodyStr = '';
    String responseStr;

    Integer moodleDataCntr = 0;
    for (LMS_Course_Enrolment__c courseEnrol : scope){
      try {
	      String uernameStr = '';
	
	      LMS_Course_Enrolment__c updateAttempt = new LMS_Course_Enrolment__c();
	      updateAttempt.Id = courseEnrol.Id;
	      updateAttempt.As_Sync_Attempts__c = (courseEnrol.As_Sync_Attempts__c != null) ? courseEnrol.As_Sync_Attempts__c + 1 : 1;
	
	      updateAttemptList.add(updateAttempt);
	
	      if(allUserMap.containsKey(courseEnrol.LMS_User__c)) {
	          uernameStr = allUserMap.get(courseEnrol.LMS_User__c).Username;
	      } else {
	         uernameStr = allLmsUserMap.get(courseEnrol.LMS_User__c).Email__c;
	      }
	
	      if (reqBodyStr != ''){
	          reqBodyStr += '&enrolments%5B'+moodleDataCntr+'%5D%5Bsf_id%5D='+ courseEnrol.Id;
	      }
	      else {
	          reqBodyStr += 'enrolments%5B'+moodleDataCntr+'%5D%5Bsf_id%5D='+ courseEnrol.Id;
	      }
	      reqBodyStr += '&enrolments%5B'+moodleDataCntr+'%5D%5Broleid%5D='+ '5';
	      reqBodyStr += '&enrolments%5B'+moodleDataCntr+'%5D%5Bcourseid%5D='+ courseEnrol.LMS_Course__c;
	      reqBodyStr += '&enrolments%5B'+moodleDataCntr+'%5D%5Busername%5D='+ uernameStr;
	      reqBodyStr += '&enrolments%5B'+moodleDataCntr+'%5D%5Bfirstname%5D='+ courseEnrol.LMS_User__r.Firstname__c;
	      reqBodyStr += '&enrolments%5B'+moodleDataCntr+'%5D%5Blastname%5D='+ courseEnrol.LMS_User__r.Lastname__c;
	      reqBodyStr += '&enrolments%5B'+moodleDataCntr+'%5D%5Bemail%5D='+ courseEnrol.LMS_User__r.Email__c;
	      reqBodyStr += '&enrolments%5B'+moodleDataCntr+'%5D%5Buserid%5D='+ courseEnrol.LMS_User__c;
	
	      String finalStr8 = (courseEnrol.LMS_User__r.AS_Authentication_Method__c == 'Restrict by IP')?'ip':courseEnrol.LMS_User__r.AS_Authentication_Method__c.toLowerCase();
	      reqBodyStr += '&enrolments%5B'+moodleDataCntr+'%5D%5Bauth%5D='+ finalStr8;
	
	      moodleDataCntr++;
      } catch (Exception ex) { // added by john hope for ticket (#377)
      	
    		LMS_Course_Enrolment__c updateAttempt = new LMS_Course_Enrolment__c();
	      updateAttempt.Id = courseEnrol.Id;
	      updateAttempt.As_Sync_Attempts__c = (courseEnrol.As_Sync_Attempts__c != null) ? courseEnrol.As_Sync_Attempts__c + 1 : 1;
	      updateAttempt.AsMoodleResponse__c = 'ERROR - '+ ex.getMessage();
	      
	      System.debug('updateAttempt : ' + updateAttempt);
	
	      updateAttemptList.add(updateAttempt);
    	}
    }

    try {
      system.debug('reqBody: '+reqBodyStr);
      Http http = new Http();
      HttpRequest req = new HttpRequest();
      req.setEndpoint(EndPointURL);
      req.setMethod('POST');
      req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
      req.setTimeout(120000);
      req.setBody(reqBodyStr);

      //if(!Test.IsRunningTest()){
        HttpResponse res = http.send(req);
        responseStr = res.getBody();
        System.debug('** response: ' + responseStr);


      
        List<Object> responseDetailList = (List<Object>) JSON.deserializeUntyped(responseStr);
        system.debug('responseDetailList: '+responseDetailList);
            
        List<LMS_Course_Enrolment__c> allLmsEnroll = new List<LMS_Course_Enrolment__c>();
        List<LMS_User__c> allLmsUser = new List<LMS_User__c>();
        Set<Id> useridSet = new Set<Id>();

        for (Object responseObject : responseDetailList){

            Map<String,Object> singleresponseDetailMap = (Map<String,Object>) responseObject;

          if(!useridSet.contains(String.valueOf(singleresponseDetailMap.get('usersfid')))){
            LMS_User__c newLmsUser = new LMS_User__c();
            newLmsUser.Id = String.valueOf(singleresponseDetailMap.get('usersfid'));
            newLmsUser.Moodle_User_Id__c = String.valueOf(singleresponseDetailMap.get('userid'));
            newLmsUser.As_Creation_Status__c = (singleresponseDetailMap.get('status') == true)? 'Success' : 'In Progress';
            allLmsUser.add(newLmsUser);
            useridSet.add(String.valueOf(singleresponseDetailMap.get('usersfid')));
          }

          LMS_Course_Enrolment__c newLmsEnroll = new LMS_Course_Enrolment__c();
          newLmsEnroll.Id = String.valueOf(singleresponseDetailMap.get('enrolsfid'));
          newLmsEnroll.As_Moodle_Id__c = String.valueOf(singleresponseDetailMap.get('enrolid'));
          newLmsEnroll.AsMoodleResponse__c = String.valueOf(singleresponseDetailMap.get('message'));
          newLmsEnroll.As_Creation_Status__c = (singleresponseDetailMap.get('status') == true)? 'Success' : 'In Progress';//'Success';
          allLmsEnroll.add(newLmsEnroll);

        }
  	
        if (updateAttemptList.size() > 0) database.update(updateAttemptList,false);
        
        system.debug('allLmsEnroll: '+allLmsEnroll);
        if(allLmsEnroll.size() > 0) {
            database.update(allLmsEnroll,false);
        }

        system.debug('allLmsUser: '+allLmsUser);
        if(allLmsUser.size() > 0) {
          database.update(allLmsUser,false);
        }
      //}
      
    }catch(Exception ex) {

      System.debug(' AN ERROR OCCUR : ' + ex.getMessage());
      Boolean maperror = false;
      if(ex.getMessage() == 'Invalid conversion from runtime type Map<String,ANY> to List<ANY>'){
        maperror = true;
      }

      List<LMS_Course_Enrolment__c> errorallLmsEnroll = new List<LMS_Course_Enrolment__c>();
      Set<Id> lmsCourseEnrolIdSet = new Set<Id>();

      Map<String,Object> errorMap;
      if(!Test.IsRunningTest()){
        if(maperror) errorMap = (Map<String,Object>) JSON.deserializeUntyped(responseStr);
      }
      if(Test.IsRunningTest()){
        errorMap = new Map<String,Object>();
      }

        system.debug('errorMap: '+errorMap);
        //system.debug('errorMap key: '+errorMap.keySet());
        
        for (LMS_Course_Enrolment__c courseEnrol : scope){

          if(!lmsCourseEnrolIdSet.contains(courseEnrol.Id)){
            //System.debug('error response: '+String.valueOf(errorMap.get('message')));

            //LMS_User__c newLmsUser = new LMS_User__c();
            //newLmsUser.Id = String.valueOf(singleresponseDetailMap.get('usersfid'));
            //newLmsUser.As_Sync_Attempt__c

            LMS_Course_Enrolment__c newLmsEnroll = new LMS_Course_Enrolment__c();
            newLmsEnroll.Id = String.valueOf(courseEnrol.Id);
            newLmsEnroll.As_Sync_Attempts__c = (courseEnrol.As_Sync_Attempts__c != null) ? courseEnrol.As_Sync_Attempts__c + 1 : 1;

            if(maperror){
              newLmsEnroll.AsMoodleResponse__c = String.valueOf(errorMap.get('message'));
            }else{
              newLmsEnroll.AsMoodleResponse__c = String.valueOf(ex.getMessage());
            }
            
            errorallLmsEnroll.add(newLmsEnroll);
            lmsCourseEnrolIdSet.add(courseEnrol.Id);
          }
        
        }

      if(errorallLmsEnroll.size() > 0){
        Database.update(errorallLmsEnroll,false);
      }
    }

  }
  global void finish(Database.BatchableContext BC){
    if(lmsCourseEnrolID == null){
      system.debug('finish indexToRemove: '+indexToRemove);
      newallInstanceList.remove(indexToRemove);
      //newallInstanceList = newallInstanceList;
      if (newallInstanceList.size() > 0){
              ASCourseEnrollmentToMoodleBatch courseEnrollmentToMoodle = new ASCourseEnrollmentToMoodleBatch(newallInstanceList,null);
              Database.executeBatch(courseEnrollmentToMoodle,50);
      }
      else{
          if (newallInstanceList.size() == 0){
              List<LMS_Instance__c> allLMSInstanceList = [Select
                                                          Id,
                                                            Domain_URL__c,
                                                            Status__c,
                                                            Token__c,
                                                            Type__c,
                                                            URL__c
                                                          from
                                                            LMS_Instance__c
                                                          where
                                                            URL__c <> null
                                                          and
                                                            Token__c <> null
                                                         ];
              if(allLMSInstanceList.size() > 0) {
                  AsLMSUserToMoodleBatch runBatch = new AsLMSUserToMoodleBatch(allLMSInstanceList); // this part call's ronald batch process
                  database.executeBatch(runBatch,50);
              }
          }
      }
    }
  }

  public LMS_Course_Enrolment__c objlmsCourseE;


  global ASCourseEnrollmentToMoodleBatch(ApexPages.StandardController stdController){
       objlmsCourseE= (LMS_Course_Enrolment__c)stdController.getRecord();
  }

  public PageReference sendToMoodle(){
    ASCourseEnrolToMoodle(objlmsCourseE.Id);
    return new PageReference(url.getsalesforcebaseurl().toexternalform()+'/'+objlmsCourseE.Id);
  }

  Webservice static void ASCourseEnrolToMoodle(Id recId){
    
      //list<LMS_Instance__c> allInstanceList = new list<LMS_Instance__c>();
      ASCourseEnrollmentToMoodleBatch courseEnrollmentToMoodle = new ASCourseEnrollmentToMoodleBatch(null,recId);
      //if(!Test.IsRunningTest()){
        Database.executeBatch(courseEnrollmentToMoodle);
      //}
    
  }
}