/*Author : John Hope
*Description : This is a class that handles the passing of data from salesforce to moodle
*Date Created : 
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data : LMS User
*/
public class AsMoodleApiCalloutQueueable implements Queueable, Database.AllowsCallouts {
    public List<AsMoodleWrapper> finalmoodleData {get;set;}
    
    @TestVisible static Boolean makeCallout = true;
    
    public AsMoodleApiCalloutQueueable(List<AsMoodleWrapper> theData) {
        System.debug('AsMoodleApiCalloutQueueable is called');
        finalmoodleData = theData;
    }
    //perform callout
    public void execute(QueueableContext context) {
        if (makeCallout) performCallout();
    }

    public void performCallout() {
        if(finalmoodleData.size() > 0) {
            System.debug('finalmoodleData : ' + finalmoodleData);
            String format = 'json';
            String moodleFunctionStr;
            String EndPointURL = finalmoodleData[0].url+'?wstoken='+finalmoodleData[0].token+'&wsfunction='+finalmoodleData[0].function+'&moodlewsrestformat='+ format;
            String reqBody;
            
            /*if(obj == 'category'){
reqBody = 'categories%5B'+'0'+'%5D%5B'+'sf_id'+'%5D='+ sfId;

if(request != 'delete'){
reqBody += '&categories%5B0%5D%5Bname%5D='+ str1;
reqBody += '&categories%5B0%5D%5Bdescription%5D='+ str2;
}else{
reqBody += '1'; //0
}
}else if(obj == 'users'){
reqBody = 'users%5B0%5D%5Bsf_id%5D='+ sfId;

if(request != 'delete'){
reqBody += '&users%5B0%5D%5Busername%5D='+ str1;
//reqBody += '&users%5B0%5D%5Bpassword%5D='+ str2;
reqBody += '&users%5B0%5D%5Bfirstname%5D='+ str3;
reqBody += '&users%5B0%5D%5Blastname%5D='+ str4;
reqBody += '&users%5B0%5D%5Bemail%5D='+ str5;
}
}else*/
            
            Integer moodleDataCntr = 0;
            reqBody = '';
            for(AsMoodleWrapper moodleData : finalmoodleData) {
                reqBody += (moodleDataCntr > 0)?'&':''; // added to add '&' character for multiple moodle data
                
                if(moodleData.obj == 'courses'){
                    moodleFunctionStr = 'courses';
                    reqBody += 'courses%5B'+moodleDataCntr+'%5D%5Bsf_id%5D='+ moodleData.sfId;
                    
                    if(moodleData.request != 'delete'){
                        reqBody += '&courses%5B'+moodleDataCntr+'%5D%5Bfullname%5D='+ moodleData.name;
                        reqBody += '&courses%5B'+moodleDataCntr+'%5D%5Bshortname%5D='+ moodleData.shortname;
                        //reqBody += '&courses%5B0%5D%5Bcategoryid%5D='+ '';//str3;
                    }
                    
                }else if(moodleData.obj == 'enrolUsers'){
                    moodleFunctionStr = 'enrolUsers';
                    reqBody += 'enrolments%5B'+moodleDataCntr+'%5D%5Bsf_id%5D='+ moodleData.sfId;
                    if(moodleData.request != 'delete'){
                        reqBody += '&enrolments%5B'+moodleDataCntr+'%5D%5Broleid%5D='+ moodleData.name;
                        reqBody += '&enrolments%5B'+moodleDataCntr+'%5D%5Bcourseid%5D='+ moodleData.shortname;
                        reqBody += '&enrolments%5B'+moodleDataCntr+'%5D%5Busername%5D='+ moodleData.username;
                        reqBody += '&enrolments%5B'+moodleDataCntr+'%5D%5Bfirstname%5D='+ moodleData.firstname;
                        reqBody += '&enrolments%5B'+moodleDataCntr+'%5D%5Blastname%5D='+ moodleData.lastname;
                        reqBody += '&enrolments%5B'+moodleDataCntr+'%5D%5Bemail%5D='+ moodleData.email;
                        reqBody += '&enrolments%5B'+moodleDataCntr+'%5D%5Buserid%5D='+ moodleData.userid;
                        
                        String finalStr8 = (moodleData.restriction == 'Restrict by IP')?'ip':moodleData.restriction.toLowerCase();
                        reqBody += '&enrolments%5B'+moodleDataCntr+'%5D%5Bauth%5D='+ finalStr8;
                    }
                    
                    if(finalmoodleData.size() == 1) { // this condition is added so that queueable will not run again when http response doesn't return a moodle Id
                        AS_LMS_Course_EnrolmentHandler.runCallMoodle = false;
                    }
                    
                } else if (moodleData.obj == 'updateUsers') {
                    reqBody += 'users%5B'+moodleDataCntr+'%5D%5Bsf_id%5D='+ moodleData.sfId;
                    reqBody += '&users%5B'+moodleDataCntr+'%5D%5Bfirstname%5D='+ moodleData.firstname;
                    reqBody += '&users%5B'+moodleDataCntr+'%5D%5Blastname%5D='+ moodleData.lastname;
                    reqBody += '&users%5B'+moodleDataCntr+'%5D%5Bemail%5D='+ moodleData.email;  
                    
                    String finalStr8 = (moodleData.restriction == 'Restrict by IP')?'ip':moodleData.restriction.toLowerCase();
                    reqBody += '&users%5B'+moodleDataCntr+'%5D%5Bauth%5D='+ finalStr8;
                    
                    
                    if(finalmoodleData.size() == 1) { // this condition is added so that queueable will not run again when http response doesn't return a moodle Id
                        AsLMSUserTriggerHandler.runCallMoodle = false;
                    }
                    
                } else if (moodleData.obj == 'activities'){
                    reqBody += '&activities%5B'+moodleDataCntr+'%5D%5Bactivitysfid%5D='+ moodleData.activitysfid;
                    reqBody += '&activities%5B'+moodleDataCntr+'%5D%5Bname%5D='+ moodleData.actname; 
                    reqBody += '&activities%5B'+moodleDataCntr+'%5D%5Bcourseid%5D='+ moodleData.courseId;
                    reqBody += '&activities%5B'+moodleDataCntr+'%5D%5Bmodtype%5D='+ moodleData.acttype.toLowerCase();
                    reqBody += '&activities%5B'+moodleDataCntr+'%5D%5Btypename%5D='+ moodleData.request;
 
                }
                moodleDataCntr++;
            }
            String response;
            
            /*try {*/
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint(EndPointURL);
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                req.setTimeout(120000);
                req.setBody(reqBody);
                System.debug('** reqBody: ' + reqBody);
                
                HttpResponse res = http.send(req);
                response = res.getBody();
                System.debug('** response: ' + response);
                
                List<Object> responseDetailList = (List<Object>) JSON.deserializeUntyped(response);
                List<LMS_Course__c> allLmsCourse = new List<LMS_Course__c>();
                List<LMS_User__c> allLmsUser = new List<LMS_User__c>();
                List<LMS_Course_Enrolment__c> allLmsEnroll = new List<LMS_Course_Enrolment__c>();
                List<LMS_Activity__c> allLmsActivity = new List<LMS_Activity__c>();

                for(Object responseObject : responseDetailList) {
                    Map<String,Object> singleresponseDetailMap = (Map<String,Object>) responseObject;
                    if(finalmoodleData[0].obj == 'courses'){
                        LMS_Course__c newLmsCourse = new LMS_Course__c();
                        newLmsCourse.id = String.valueOf(singleresponseDetailMap.get('sf_id'));
                        newLmsCourse.Moodle_Course_Id__c  = String.valueOf(singleresponseDetailMap.get('courseid'));
                        newLmsCourse.AsMoodleResponse__c  = String.valueOf(singleresponseDetailMap.get('message'));
                        allLmsCourse.add(newLmsCourse);
                    } else if(finalmoodleData[0].obj == 'enrolUsers') {
                        LMS_User__c newLmsUser = new LMS_User__c();
                        newLmsUser.Id = String.valueOf(singleresponseDetailMap.get('usersfid'));
                        newLmsUser.Moodle_User_Id__c = String.valueOf(singleresponseDetailMap.get('userid'));
                        newLmsUser.As_Creation_Status__c = (singleresponseDetailMap.get('status') == true)? 'Success' : 'In Progress';
                        allLmsUser.add(newLmsUser);
                        
                        LMS_Course_Enrolment__c newLmsEnroll = new LMS_Course_Enrolment__c();
                        newLmsEnroll.Id = String.valueOf(singleresponseDetailMap.get('enrolsfid'));
                        newLmsEnroll.As_Moodle_Id__c = String.valueOf(singleresponseDetailMap.get('enrolid'));
                        newLmsEnroll.AsMoodleResponse__c = String.valueOf(singleresponseDetailMap.get('message'));
                        newLmsEnroll.As_Creation_Status__c = (singleresponseDetailMap.get('status') == true)? 'Success' : 'In Progress';//'Success';
                        allLmsEnroll.add(newLmsEnroll);
                    } else if (finalmoodleData[0].obj == 'activities') {
                        LMS_Activity__c newLmsActivity = new LMS_Activity__c();
                        newLmsActivity.Id = String.valueOf(singleresponseDetailMap.get('activitysfid'));
                        newLmsActivity.Moodle_Activity_Id__c = String.valueOf(singleresponseDetailMap.get('activityid'));
                        newLmsActivity.AsMoodleResponse__c = String.valueOf(singleresponseDetailMap.get('message'));
                        allLmsActivity.add(newLmsActivity);
                    }
                }
                
                // for update of lms course
                System.debug('allLmsCourse : ' + allLmsCourse);
                if(allLmsCourse.size() > 0) {
                    database.update(allLmsCourse,false);
                }
                if(allLmsUser.size() > 0) {
                    database.update(allLmsUser,false);
                }
                if(allLmsEnroll.size() > 0) {
                    database.update(allLmsEnroll,false);
                }
                 // for update of lms activity
                if(allLmsActivity.size() > 0) {
                    database.update(allLmsActivity,false);
                } 
            /*} catch(Exception ex) {
                System.debug(' AN ERROR OCCUR : ' + ex.getMessage());
                System.debug(' AN ERROR OCCUR Line: ' + ex.getLineNumber());
                System.debug(' AN ERROR OCCUR Line: ' + ex.getStackTraceString());
                System.debug(' AN ERROR OCCUR Line: ' + ex.getCause());
                Boolean maperror = false;
                if(ex.getMessage() == 'Invalid conversion from runtime type Map<String,ANY> to List<ANY>'){
                    maperror = true;
                }
                
                List<LMS_Course_Enrolment__c> errorallLmsEnroll = new List<LMS_Course_Enrolment__c>();
                Set<Id> lmsCourseEnrolIdSet = new Set<Id>();
                
                Map<String,Object> errorMap;
                if(!Test.IsRunningTest() && maperror == true){
                    errorMap = (Map<String,Object>) JSON.deserializeUntyped(response);
                }else if(Test.IsRunningTest()){
                    errorMap = new Map<String,Object>();
                }
                
                system.debug('errorMap: '+errorMap);
                
                for (AsMoodleWrapper moodleData : finalmoodleData) {
                    
                    if(!lmsCourseEnrolIdSet.contains(moodleData.sfId) && moodleFunctionStr == 'enrolUsers'){
                        System.debug('error response: '+String.valueOf(errorMap.get('message')));
                        
                        LMS_Course_Enrolment__c newLmsEnroll = new LMS_Course_Enrolment__c();
                        newLmsEnroll.Id = moodleData.sfId;
                        
                        if(maperror){
                            newLmsEnroll.AsMoodleResponse__c = String.valueOf(errorMap.get('message'));
                        }else{
                            newLmsEnroll.AsMoodleResponse__c = String.valueOf(ex.getMessage());
                        }
                        
                        errorallLmsEnroll.add(newLmsEnroll);
                        lmsCourseEnrolIdSet.add(moodleData.sfId);
                    }
                    
                }
                
                if(errorallLmsEnroll.size() > 0){
                    Database.update(errorallLmsEnroll,false);
                }
            }*/
        }
    } 
  
}