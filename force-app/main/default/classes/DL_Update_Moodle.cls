public class DL_Update_Moodle {
    
    @future(callout=true)
    Public Static void UpdateUsername(String lmsUserID){
        LMS_User__c lmsUser = [SELECT ID,Email__c,LMS_Instance__c,firstNAme__c,LastNAme__c,PSA_Imis_ID__c FROM LMS_USer__c where id = :lmsUserID];
        LMS_Instance__c lmsInstance = [SELECT URL__c,Token__c FROM LMS_Instance__c WHERE ID = :lmsUser.LMS_Instance__c];

        String apiToken = lmsInstance.Token__c;
        String url = lmsInstance.URL__c;
        String body = 'users%5B0%5D%5Bsf_id%5D='+ lmsUser.Id;
        body += '&users%5B0%5D%5Bemail%5D='+ lmsUser.Email__c;
        body += '&users%5B0%5D%5Bfirstname%5D='+ lmsUser.FirstName__c;
        body += '&users%5B0%5D%5Blastname%5D='+ lmsUser.LastName__c;
	    body += '&users%5B0%5D%5Busername%5D='+ lmsUser.Email__c;
        body += '&users%5B0%5D%5Bidnumber%5D='+ lmsUser.PSA_Imis_ID__c;
        
        
        HTTP http = new HTTP();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url+'?wstoken='+apiToken+'&wsfunction=local_psa_integration_update_users&moodlewsrestformat=json');
        request.setMethod('POST');
        request.setBody(body);
        request.setTimeout(10000);
 
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            /////Success/////
            //Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            //System.debug(String.valueof(results.get('message')));
        }
        
        else{
            System.debug(response);
        }   
    }


    @future(callout=true)
    Public Static void UnenrolUser(ID trainingPlanAssignmentId){
        Training_Plan_Assignment__c TPA = [SELECT Id,Name,Training_Plan__c FROM Training_Plan_Assignment__c WHERE Id = :trainingPlanAssignmentId];

        List<Training_Plan_Section_Assignment__c> TPSAs = [SELECT Id,Name,Training_Plan_Assignment__c 
                                                            From Training_Plan_Section_Assignment__c 
                                                            WHERE Training_Plan_Assignment__c = :trainingPlanAssignmentId];

        List<Learning_Assignment__c> learningAssignments = [SELECT Id,Name,LMS_Course_Enrolment__r.LMS_Course__c, LMS_Instance__c,LMS_Course_Enrolment__r.LMS_User__c
                                                            FROM Learning_Assignment__c 
                                                            WHERE Training_Plan_Section_Assignment__c in :TPSAs];

        LMS_Instance__c lmsInstance = [SELECT URL__c,Token__c FROM LMS_Instance__c WHERE ID = :learningAssignments[0].LMS_Instance__c];
        

        List<Id> LMSCourseIds = new List<Id>();

        for(Learning_Assignment__c LA : learningAssignments){
            if(LA.LMS_Course_Enrolment__r != null){
                LMSCourseIds.add(LA.LMS_Course_Enrolment__r.LMS_Course__c);
            }
        }


        for(Id LMSCourseId : LMSCourseIds){
            String apiToken = lmsInstance.Token__c;
            String url = lmsInstance.URL__c;
            String body = 'enrolments%5B0%5D%5Buserid%5D='+ learningAssignments[0].LMS_Course_Enrolment__r.LMS_User__c;
            body += '&enrolments%5B0%5D%5Bcourseid%5D='+  LMSCourseId;

            System.debug(body);

            
            HTTP http = new HTTP();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(url+'?wstoken='+apiToken+'&wsfunction=local_psa_integration_unenrol_users&moodlewsrestformat=json');
            request.setMethod('POST');
            request.setBody(body);
            request.setTimeout(10000);
    
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                /////Success/////
                System.debug(response.getBody());
                //Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                //System.debug(String.valueof(results.get('message')));
                //System.debug(String.valueof(results.get('debuginfo')));
            }
            
            else{
                System.debug(response);
            }
            
        }    
    }
    

}