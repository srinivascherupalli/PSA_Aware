/*
Copyright (c) 2014, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors
    may be used to endorse or promote products derived from this software
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
OF THE POSSIBILITY OF SUCH DAMAGE.

*/
global with sharing class TrainingPlanPreviewController extends LMSBaseController{

    public TrainingPlan tPlan{get;private set;}
    public List<User> lUsersWithAchievement {get;private set;}
    private Id trainingPlanId;
    public Training_Plan_Access_Request__c dummyRequest{get;set;}
    public Training_Plan_Access_Request__c existingRequest{get;set;}
    public Boolean isApprovalRequired{get;private set;}
    public String redirectURL{get;set;}
    public Boolean hasMessages{get{return ApexPages.hasMessages();}}
    public String TrackType{get;set;}
     
    //public String TrainingPlan_ID{get;set;}
    public Boolean UserValidation_error{get;set;}
    public String userErrorMessage{get;set;}

    //JRC
    public Boolean isAlreadyInBookMark {get;set;}
    public boolean isMemberser {get;set;}
    public boolean canViewTrainPlan = false;// for checking if user can view Training plan preview

    //MLO
    public String processStatus {get;set;}
    public String oppId {get;set;}
    public String redirectExtURL {get;set;} 
    public String isGuest {get;set;}
    public String fromEvent { get; set; }
    public String siteUrl { get; set; }
    
    public String isEvent {get;set;}
    public String nonMember_memberBenefit { get; set; }
    
    public String currentUserId { get; set; }
    public String currentTPlanId { get; set; }

    //It's important to keep this as a custom controller so that we can bypass sharing restrictions for preview purposes
    global TrainingPlanPreviewController(){
      
        String netid = ApexPages.currentPage().getParameters().get('netid'); 
        //if(netid != null) siteUrl = Network.getLoginUrl(netid).replace('login',''); 
        siteUrl = ASPSASettings__c.getOrgDefaults().Portal_URL__c;
        
        if(UserInfo.getUserType() == 'Guest'){
            isGuest = 'guest';
        }
        trainingPlanId = ApexPages.currentPage().getParameters().get('id');
        isAlreadyInBookMark = AsTrainingPlanBookMark.isCheckTrainingPlanInBookMark( UserInfo.getUserId() , trainingPlanId );
        init();
        
        if(canViewTrainPlan == false && !AS_HelperClass.TrainingPlanPreviewValidation(UserInfo.getUserId())){
            nonMember_memberBenefit = 'Paid';
        }
        system.debug('nonMember_Memberbenefit set to: ' + nonMember_memberBenefit);
        
        Boolean parentCamp = false;
        isEvent = 'Enrol Now';
        Set<String> campIds = new Set<String>(); 
        Set<String> recIds = new Set<String>(); 
        Set<String> campId = new Set<String>();
        Id recordTypeC = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Event').getRecordTypeId();
        Id recordTypeL = Schema.SObjectType.Learning__c.getRecordTypeInfosByName().get('Event').getRecordTypeId();
        Set<String> learningId = new Set<String>();
        List<Training_Plan_Section_Item__c> sectionItem = [Select Id, Learning__c, Learning__r.RecordTypeId, Training_Plan_Section__r.Training_Plan__c From Training_Plan_Section_Item__c Where Training_Plan_Section__r.Training_Plan__c =: trainingplanId];
        for(Training_Plan_Section_Item__c planSec : sectionItem){
            recIds.add(planSec.Learning__r.RecordTypeId);
            //learningId.add(planSec.Learning__c);
        }
        if(recIds.contains(recordTypeL)) isEvent = 'Select Date';
        else isEvent = 'Enrol Now';
        /*List<Campaign> camps = [SELECT Id, ParentId, AS_Event__c, Learning__c, Learning__r.RecordTypeId FROM Campaign WHERE Training_Plan__c =: trainingPlanId];
        System.debug('camp.Id: '+trainingplanId);
        for(Campaign camp: camps){
            System.debug('camp.Id: '+camp.Id);
            if(camp.Learning__c != null && camp.Learning__r.RecordTypeId == recordTypeL) {
                campId.add(camp.Id);
                isEvent = 'Select Date';
            }
            else if(camp.Learning__c != null && camp.Learning__r.RecordTypeId != recordTypeL){
                isEvent = 'Enrol Now';
            }
            else{
                parentCamp = true;
                campId.add(camp.Id);
                System.debug('campId: '+campId);
            }
        }
        
        if(campId != null && parentCamp == true){
            List<Campaign> campaigns = [SELECT Id, Learning__r.RecordTypeId FROM Campaign WHERE ParentId In: campId];
            for(Campaign camp: campaigns){
                if(camp.Learning__r.RecordTypeId == recordTypeL) isEvent = 'Select Date';
                else isEvent = 'Enrol Now';
            }
        }  */

        //MLO
        processStatus = ApexPages.currentPage().getParameters().get('processStatus');
        oppId = ApexPages.currentPage().getParameters().get('oppId');
		fromEvent = ApexPages.currentPage().getParameters().get('p');
        System.debug('..................................................fromEvent : ' + fromEvent);
            
        //-->custom code<---
        List<Training_Track_Level_Item__c> TTLItem = [select Id, Name, Training_Track_Level__c from Training_Track_Level_Item__c where Training_Plan__c =: trainingPlanId];

        if(TTLItem.size() > 0){
            /*Set<ID> TTLitem_ID = new Set<ID>();
            for(Training_Track_Level_Item__c TTLitem_list : TTLItem){
                TTLitem_ID.add(TTLitem_list.Training_Track_Level__c);           
            }*/
            
            List<Training_Track_Level__c> TTL_list = [select Id, Name, Training_Track__r.AS_Track_Type__c from Training_Track_Level__c where Id =: TTLItem[0].Training_Track_Level__c];
            if(TTL_list.size() > 0){
                TrackType = TTL_list[0].Training_Track__r.AS_Track_Type__c;
            }
        }
        
        ///system.debug('@@@tPlan: ' + JSON.serializePretty(tPlan));
    }

    private void init(){
        try{
            loadTrainingPlanInfo();
            isApprovalRequired = false;
            dummyRequest = new Training_Plan_Access_Request__c();
            existingRequest = null;

            if(tPlan != null){
                if(tPlan.trainingPlan.Self_Registration_Access__c == 'Requires Approval'){
                    isApprovalRequired = true;
                }

                if(tPlan.mainAchievement != null){
                    lUsersWithAchievement = LMSService.getUsersForAchievement(tPlan.mainAchievement.Id, LMSConstants.AA_ACQUIRED_STATUS, 12);
                }
            }else{
                System.debug('Error here from init 1');
                LMSUtils.addErrorMessage(System.Label.ALMS_Training_Plan_No_Access_Message);
            }

        }catch(Exception e){
            System.debug('Error here from init');
            LMSUtils.logException(e,'TrainingPlanPreviewController');
            LMSUtils.addGenericUnknownErrorMessage('TrainingPlanPreviewController - init (1)');
        }
    }

    private void loadTrainingPlanInfo(){
        tPlan = LMSWrappersService.getTrainingPlanDetails(trainingPlanId,UserInfo.getUserId(),true, true);
         
        if( AS_HelperClass.isUserMember(UserInfo.getUserId()) || !AS_HelperClass.TrainingPlanPreviewValidation(UserInfo.getUserId()) ){
            isMemberser = true;
            
            // 9/9/2018 for update if user can view training plan by type
            if(AS_HelperClass.isUserMember(UserInfo.getUserId())) {
                canViewTrainPlan = true;
            } else if(!AS_HelperClass.TrainingPlanPreviewValidation(UserInfo.getUserId())) {
                canViewTrainPlan = false;
            }
        } else {
             isMemberser = false;
        }
        
    }
    
    
    public PageReference checkAssignment(){
        System.debug(' >>>>>>> CHECK ASSIGNMENT <<<<<<< ::: ' + hasTrainingPlanAssignment());
        if(hasTrainingPlanAssignment()){
            return redirectToPlanDetailPage();
        }else{
            return null;
        }
    }
    
    public PageReference eventEnrol() {
        PageReference pr = Page.EventEnrol;
        pr.getParameters().put('id',trainingPlanId);
        pr.getParameters().put('netid',LMSUtils.getCurrentNetworkId());
        if(Test.isRunningTest()) registerForTrainingPlan();
        System.debug(pr);
        return pr;
    }

    //Create assignment is user doesn't have the assignment already
        public PageReference registerForTrainingPlan() {
            System.debug('controller registerForTrainingPlan');
            redirectURL = null;
            String memberNonMember; // possible values (member, non-member,null)
            if(canViewTrainPlan) {
                memberNonMember = 'member';
            } else if(!AS_HelperClass.TrainingPlanPreviewValidation(UserInfo.getUserId())) {
                memberNonMember = 'non-member';
            }
            try{
                List<Training_Plan__c> redirect_field = [SELECT Id, 
                                                                                                        AS_Registration_URL__c, 
                                                                                                        AS_Event__r.AS_Event_URL__c 
                                                                                                        FROM Training_Plan__c 
                                                                                                    WHERE 
                                                                                                    Id =: tPlan.trainingPlan.Id
                                                                                                ];
                if(UserInfo.getUserType() == 'Guest'){
                        userErrorMessage = 'Please login/register to access this course.';
                        UserValidation_error = true;
                        isGuest = 'guest';
                        
                        String startUrl = System.currentPageReference().getParameters().get('startURL');
                        PageReference ref = Network.forwardToAuthPage(startUrl);
                        ref.setRedirect(true);
                        redirectExtURL = ref.getUrl();
                        return null;
                } else {
                    if(tPlan.trainingPlan.Type__c == 'Member Only (Free)') {
                        System.debug('Member Only (Free) here' + fromEvent);
                        if(memberNonMember == 'member') {
                            System.debug('Member Only (Free) here 2');
                            //Map<Id,List<Learning_Assignment__c>> wew = LMSService.upsertAssignments(new Set<Id>{UserInfo.getUserId()}, trainingPlanId, LMSUtils.getCurrentNetworkId());
                            //System.debug('Member Only (Free) here 2 : ' + wew);
                            AsOpportunityTriggerHandler.myFutureMethod(new Set<Id>{UserInfo.getUserId()}, trainingPlanId, LMSUtils.getCurrentNetworkId());
                        } else if(memberNonMember == 'non-member') {
                            System.debug('Member Only (Free) here 3'); 
                            ASPSASettings__c psaSettings = ASPSASettings__c.getOrgDefaults();
                            String theFullurl = (psaSettings.AsMembershipRegistrationURL__c!=null)?String.valueOf(psaSettings.AsMembershipRegistrationURL__c):'https://staging-staging-pharmaceuticalaus.cs6.force.com'; //staging url as default if no given data
                            userErrorMessage = 'In order to access this course, please sign up to become a PSA Member here ('+theFullurl+')';
                            UserValidation_error = true; 
                            return null;
                        }
                    } else if(tPlan.trainingPlan.Type__c == 'Paid') {
                        Opportunity opp = AS_HelperClass.TrainingPlanRegisterHelper(UserInfo.getUserId(), tPlan.trainingPlan.AS_Product__c, tPlan.trainingPlan.CampaignId__c);
                            System.debug('solod na diri opp:' + opp);   
                        if(opp != null) {
                            PageReference ref = new PageReference('/apex/Paymentpage'); 
                            ref.getParameters().put('oppId', opp.Id);
                            ref.getParameters().put('tPlanId', trainingPlanId);
                            System.debug('IS NOT RTO');
                            return ref;
                        } else {
                            userErrorMessage = 'A problem was encountered during opportunity creation. Please contact administrator.';
                            UserValidation_error = true;
                            return null;
                        }
                    } else if(tPlan.trainingPlan.Type__c == 'RTO') {
                        User theUser = [Select Id,AccountId from User where Id = :userinfo.getuserId()];
                        if(theUser.AccountId != null) {
                            //PageReference ref = new PageReference('https://www.tfaforms.com/4688962');  jrc : ticket PSA-218
                            PageReference ref = new PageReference('https://www.tfaforms.com/4692606');  // jrc : ticket PSA-218
                            ref.getParameters().put('id', theUser.AccountId);
                            ref.getParameters().put('trackid', trainingPlanId);
                            ref.setRedirect(false);
                            redirectExtURL = ref.getUrl();
                            System.debug('IS RTO');
                        }else{
                            userErrorMessage = 'You cannot enroll to this kind of Training Plan. Your credential is not connected to any Account';
                            UserValidation_error = true;
                        }
                        return null;
                    } else if(tPlan.trainingPlan.Type__c == 'Event') {
                        if(redirect_field.size() > 0 && redirect_field[0].AS_Event__r.AS_Event_URL__c!=null){
                            System.debug('Event : if' + redirect_field[0].AS_Event__r.AS_Event_URL__c);
                            PageReference ref = new PageReference(redirect_field[0].AS_Event__r.AS_Event_URL__c);
        
                            ref.setRedirect(true);
                            redirectExtURL = ref.getUrl();
                            return null;
                        } else {
                            System.debug('Event : else');
                            userErrorMessage = 'No event url is set for this training plan related event.';
                            UserValidation_error = true;
                        }
                    } else if(tPlan.trainingPlan.Type__c == 'Member Benefit') {
                        if(memberNonMember == 'member') {
                            AsOpportunityTriggerHandler.myFutureMethod(new Set<Id>{UserInfo.getUserId()}, trainingPlanId, LMSUtils.getCurrentNetworkId());
                            //AS_EnrolmentFormHandler.CreateTraiingplanAssignmentBulk( new Set<Id>{UserInfo.getUserId()}  , new set<Id>{trainingPlanId},new map<Id,Id>()  );
                            //LMSService.upsertAssignments(new Set<Id>{UserInfo.getUserId()}, trainingPlanId, LMSUtils.getCurrentNetworkId());
                            System.debug('******* AFTER FUTURE METHOD ********');
                        } else if(memberNonMember == 'non-member') {
                            Opportunity opp = AS_HelperClass.TrainingPlanRegisterHelper(UserInfo.getUserId(), tPlan.trainingPlan.AS_Product__c, tPlan.trainingPlan.CampaignId__c);
                            System.debug('solod na diri opp:' + opp);   
                            if(opp != null) {
                                PageReference ref = new PageReference('/apex/Paymentpage');
                                ref.getParameters().put('oppId', opp.Id);
                                ref.getParameters().put('tPlanId', trainingPlanId);
                                System.debug('IS NOT RTO');
                                return ref;
                            } else {
                                userErrorMessage = 'A problem was encountered during opportunity creation. Please contact administrator.';
                                UserValidation_error = true;
                                return null;
                            }
                        }
                    } else if(tPlan.trainingPlan.Type__c == 'Member Only (Paid)') {
                        if(memberNonMember == 'member') {
                            Opportunity opp = AS_HelperClass.TrainingPlanRegisterHelper(UserInfo.getUserId(), tPlan.trainingPlan.AS_Product__c, tPlan.trainingPlan.CampaignId__c);
                            System.debug('solod na diri opp:' + opp);   
                            if(opp != null) {
                                PageReference ref = new PageReference('/apex/Paymentpage');
                                ref.getParameters().put('oppId', opp.Id);
                                ref.getParameters().put('tPlanId', trainingPlanId);
                                System.debug('IS NOT RTO');
                                return ref;
                            } else {
                                userErrorMessage = 'A problem was encountered during opportunity creation. Please contact administrator.';
                                UserValidation_error = true;
                                return null;
                            }
                        } else if(memberNonMember == 'non-member') {
                            ASPSASettings__c psaSettings = ASPSASettings__c.getOrgDefaults();
                            String theFullurl = (psaSettings.AsMembershipRegistrationURL__c!=null)?String.valueOf(psaSettings.AsMembershipRegistrationURL__c):'https://staging-staging-pharmaceuticalaus.cs6.force.com'; //staging url as default if no given data
                            userErrorMessage = 'In order to access this course, please sign up to become a PSA Member here ('+theFullurl+')';
                            UserValidation_error = true;
                             return null;
                        }
                    } else if (tPlan.trainingPlan.Type__c == 'Public') {
                      	//Map<Id,List<Learning_Assignment__c>> LearnAssMap =  LMSService.upsertAssignments(new Set<Id>{UserInfo.getUserId()}, trainingPlanId, LMSUtils.getCurrentNetworkId());
                        //system.debug('tp--> '+ LearnAssMap );
                        AsOpportunityTriggerHandler.myFutureMethod(new Set<Id>{UserInfo.getUserId()}, trainingPlanId, LMSUtils.getCurrentNetworkId());
                    } 
                    
                    System.debug('******* TRY{} ********');
                }
            }catch(Exception e){
                System.debug('EXCEPTION E : ' + e);
                LMSUtils.addErrorMessage(e.getStackTraceString());
                return null;
            } 
            System.debug('userErrorMessage->'+userErrorMessage+'  '+UserValidation_error);
            System.debug('!!!!!!!!!!!!! before redirect: ' + trainingPlanId);
            PageReference oldPageReference = new PageReference('/apex/TrainingPlanPreview?Id='+trainingPlanId); // this is added for ticket (#PSA-307)
            return oldPageReference;
            
        }

    public PageReference fetchTrainingPlanInfo(){
        existingRequest = null;
        List<Training_Plan__c> selectedTPlans= LMSService.getTrainingPlans(new Set<Id>{trainingPlanId}, LMSUtils.isPortalUser());
        List<Training_Plan_Access_Request__c> existingReqs = LMSService.fetchTrainingPlanAccessRequest(UserInfo.getUserId(),trainingPlanId,null,LMSUtils.isPortalUser());
        if(existingReqs.size()>0){
            existingRequest = existingReqs.get(0);
        }
        return null;
    }

    public PageReference requestAccessForTrainingPlan(){

        try{
            Training_Plan_Access_Request__c tpar = LMSService.createTrainingPlanAccessRequest(UserInfo.getUserId(),trainingPlanId,dummyRequest.Comments__c, LMSUtils.isPortalUser());
            dummyRequest = new Training_Plan_Access_Request__c();
            LMSUtils.addSuccessMessage(System.Label.ALMS_Public_Plan_Request_Submitted);
            return null;
        }catch(Exception e){
            LMSUtils.addErrorMessage(e.getStackTraceString());
            return null;
        }
    }
    @TestVisible
    public PageReference redirectToPlanDetailPage(){
        //LT Davanti 30/07/2020 - Change redirect to lightning community detail page
        System.debug(' >>>>>>> REDIRECT TO TPLAN DETAIL PAGE <<<<<<<');
        ASPSASettings__c psaSettings = ASPSASettings__c.getOrgDefaults();
        String commUrl = psaSettings.Portal_URL__c;//https://cpd-my-psa.cs73.force.com/
        PageReference ref = new PageReference(commUrl + 's/training-plan/' + trainingPlanId);
        // String namespace = '';
        // if(LMSUtils.getPackageNamespace() != null){
        //     namespace = LMSUtils.getPackageNamespace();
        // }
        // PageReference ref = new PageReference(LMSUtils.updateURLCommunityPath('/apex/'+namespace+'TrainingPlanDetail'));
        // ref.getParameters().put('id', trainingPlanId);        
        ref.setRedirect(true);
        System.debug(' >>>>>>> REDIRECTing.... TO TPLAN DETAIL PAGE <<<<<<<' + ref);
        return ref;
    }
    @TestVisible
    private Boolean hasTrainingPlanAssignment(){
        if(String.isBlank(trainingPlanId)){
            return false;
        }
        //Get assignments for existing training plans
        List<Training_Plan_Assignment__c> tPlanAsgmts = [select id from Training_Plan_Assignment__c where User__c = :UserInfo.getUserId() and Training_Plan__c = :trainingPlanId];
        System.debug('tPlanAsgmts : ' + tPlanAsgmts + ' - ' + UserInfo.getUserId() +  ' - ' + trainingPlanId);
        return tPlanAsgmts.size()>0;
    }
    
    public void custom_redirectToDetail(){
        System.debug(' >>>>>>> CUSTOM REDIRECT TO TPLAN DETAIL PAGE <<<<<<< ::: ' + trainingPlanId);
        redirectToPlanDetailPage();
    }
    
    @RemoteAction
    global static String check_futureJobComplete(String userId, String tplanId, String dt){
        // dd/MM/YYYY@HH:MM:ampm
        System.debug('*** dt: ' + dt);
        Datetime currentDT = Datetime.parse(dt);
        Date dateVal = Date.valueOf(currentDT);
        System.debug('user Id : ' + userId);
        System.debug(currentDT);
        if(String.isNotBlank(tplanId) && String.isNotBlank(userId)){
			List<AsyncApexJob > job = [SELECT Id, JobType, CompletedDate, CreatedById
                                       	FROM AsyncApexJob 
                                       	WHERE MethodName = 'myFutureMethod' 
                                       		AND ApexClass.Name = 'AsOpportunityTriggerHandler' 
                                       		AND JobType = 'Future'
                                       		AND Status = 'Completed' 
                                       		AND CreatedById =: userId
                                       	order by CompletedDate desc LIMIT 1]; 
            System.debug('///// job : ' + job);
            
            if(job.size()>0){
                return tplanId;
            }
            
        }
        return null;
    } 


    /*
    * Author : Jet R. Compayan  
    * Description:
    * Parameter : None
    * Return : None
    */
    public PageReference createTrainingPlanBookmark() {
        if ( AsTrainingPlanBookMark.isCreateTrainingPlanBookmark(  UserInfo.getUserId() , trainingPlanId ) ){
            isAlreadyInBookMark  = false ; 
        } else {
            userErrorMessage = 'You don\'t seem to have an active CPD Plan to add this course to. Please contact your administrator for assistance.';
            UserValidation_error = true;

        }
        System.debug('userErrorMessage ==>'+userErrorMessage);
        return null; 
    }
     
    
    /*
    * Author : Michael Vincent L. Largo 
    * Description:
    * Parameter : None
    * Return : None
    */
    
   
    
 
}