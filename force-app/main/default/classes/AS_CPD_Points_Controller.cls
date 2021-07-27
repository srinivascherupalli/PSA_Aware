@RestResource(urlMapping='/CPDPointsAllocator/*')
global with sharing class AS_CPD_Points_Controller {
      
    @HttpPost
    global static ResponseWrapper doPost(AS_CPD_Points_Parser.StrPoints strPoints) {
        System.debug('*** strPoints: ' + strPoints);
        RestRequest req  = RestContext.request;
        RestResponse res = RestContext.response;
        
        ResponseWrapper response = new ResponseWrapper();

        if(!String.isBlank(strPoints.courseId) && !String.isBlank(strPoints.userId) && !String.isBlank(strPoints.courseResult)){
            try{
                List<Learning_Assignment__c> lrnAsgnList = [SELECT Id, 
                                                                    LMS_Course_Enrolment__c, 
                                                                    LMS_Course_Enrolment__r.LMS_Course__c, 
                                                                    LMS_Course_Enrolment__r.LMS_User__c, 
                                                                    Learning__r.AS_Group_1_CPD__c, 
                                                                    Learning__r.AS_Group_2_CPD__c, 
                                                                    Training_Plan__r.AS_Group_1_and_Group_2_CPD_Available__c 
                                                                FROM Learning_Assignment__c 
                                                                WHERE LMS_Course_Enrolment__r.LMS_Course__c =: strPoints.courseId
                                                                AND LMS_Course_Enrolment__r.LMS_User__c =: strPoints.userId];

                System.debug('lrnAsgnList: ' + lrnAsgnList);

                if(lrnAsgnList.size() > 0){
                    List<LMS_Course_Enrolment__c> lceUpdate = new List<LMS_Course_Enrolment__c>();
                    List<Learning_Assignment__c> lrnAsgnUpdate = new List<Learning_Assignment__c>();

                    for(Learning_Assignment__c la : lrnAsgnList){
                        LMS_Course_Enrolment__c lce = new LMS_Course_Enrolment__c();
                        lce.Id                      = la.LMS_Course_Enrolment__c;
                        lce.Completion_Status__c    = (strPoints.courseResult == 'a' || strPoints.courseResult == 'c') ? 'Pass' : 'Fail';

                        if(strPoints.courseResult == 'a'){
                            la.AS_Passed__c            = true;
                            la.Progress__c             = 'Read';
                            la.AS_Group_1_CPD__c       = la.Learning__r.AS_Group_1_CPD__c;
                        }else if(strPoints.courseResult == 'b'){                
                            la.AS_Passed__c            = false;
                            la.Progress__c             = 'Failed';
                        }else if(strPoints.courseResult == 'c'){
                            la.AS_Passed__c            = true;
                            la.Progress__c             = 'Completed';
                            la.AS_Group_2_CPD__c       = la.Learning__r.AS_Group_2_CPD__c;
                            
                            if(!la.Training_Plan__r.AS_Group_1_and_Group_2_CPD_Available__c) la.AS_Group_1_CPD__c = 0;
                        }

                        System.debug('lce: ' + lce);
                        System.debug('la: ' + la);
                        lceUpdate.add(lce);
                        lrnAsgnUpdate.add(la);
                    }

                    if(lceUpdate.size() > 0) update lceUpdate;
                    if(lrnAsgnUpdate.size() > 0) update lrnAsgnUpdate;

                    res.StatusCode   = 200;
                    response.status  = 'Success';
                    response.message = 'Process is successful';
                    return response;
                }else{
                    res.StatusCode   = 500;
                    response.status  = 'Error';
                    response.message = 'Processing failed: No records found.';
                    return response;
                }
            }catch(Exception ex){
                res.StatusCode   = 500;
                response.status  = 'Error';
                response.message = 'Processing failed: ' + ex.getMessage();
                return response;
            }
        }else{
            res.StatusCode = 400;
            response.status = 'Failed';
            response.message = 'courseId, userId, and courseResult are required';
            return response;
        }
    }

    global class ResponseWrapper {

        //public Opportunity oppResult;
        public String status;
        public String message;

        public ResponseWrapper() {
            //oppResult = new Opportunity();
        }
    }
}