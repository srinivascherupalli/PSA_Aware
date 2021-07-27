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
public with sharing class TrainingPlanDetailController extends LMSBaseController{

    public TrainingPlan tPlan{get;set;}
    public String learningLaunchURL{get;set;}
    public String learningTarget{get;set;}
 

    public Boolean byPassLaunchModal{get;set;}
    public Boolean hasPreRequisite{get;private set;}

    public String selectedSectionId{get;set;}
    public String selectedItemId{get;set;}
    public TrainingPlanSectionItem selectedItem{get;set;}

    public transient List<User> lUsersWithAchievement{get;set;}
    public transient String tPlanAssignmentStatus{get;private set;}

    public Boolean isAlreadyInBookMark {get;set;}
    public boolean isMemberser {get;set;}


    //added by jrc
    public String redirectURL{get;set;}
    public Boolean UserValidation_error{get;set;}
    public String userErrorMessage{get;set;}
    public String redirectExtURL {get;set;} 
    public String isGuest {get;set;}

    public String selectedItemStatusLabel{get{
        if(selectedItem != null && selectedItem.latestAssignment != null && selectedItem.latestAssignment.Progress__c != null){
            if(selectedItem.latestAssignment.Progress__c == LMSConstants.ASSIGNMENT_STATUS_COMPLETED){
                return 'success';
            }else if(selectedItem.latestAssignment.Progress__c == LMSConstants.ASSIGNMENT_STATUS_IN_PROGRESS){
                return 'warning';
            }else{
                return 'default';
            }
        }else{
            return 'default';
        }
    }}

    private Id trainingPlanId;

    //Custom exception class
    public class TrainingPlanDetailException extends Exception{}

    public TrainingPlanDetailController(ApexPages.StandardController cont){
        trainingPlanId = cont.getId();
        init();
    }

    public TrainingPlanDetailController(){
        trainingPlanId = ApexPages.currentPage().getParameters().get('id');
        isAlreadyInBookMark = AsTrainingPlanBookMark.isCheckTrainingPlanInBookMark( UserInfo.getUserId() , trainingPlanId );
        init();
    }

    @TestVisible
    private void init(){
        try{
            tPlanAssignmentStatus = null;
            learningLaunchURL = null;
            learningTarget = '_self';
            selectedItem = null;
            byPassLaunchModal = false;
            hasPreRequisite = false;
            loadTrainingPlanInfo();
            if(tPlan != null){
                if(tPlan.mainAchievement != null){
                    lUsersWithAchievement = LMSService.getUsersForAchievement(tPlan.mainAchievement.Id, LMSConstants.AA_ACQUIRED_STATUS, 10);
                }
                loadAssignmentStatus();
            }
        }catch(Exception e){
            LMSUtils.logException(e,'TrainingPlanDetailController');
            LMSUtils.addGenericUnknownErrorMessage('TrainingPlanDetailController - init (1)');
        }
    }

    private void loadAssignmentStatus(){
        Map<Id,Map<Id,Training_Plan_Assignment__c>> assignmentsMap = LMSService.getTrainingPlanAssignments(new Set<Id>{UserInfo.getUserId()}, new Set<Id>{trainingPlanId});
        if(assignmentsMap.size()>0 && assignmentsMap.get(UserInfo.getUserId()) != null){
            Map<Id,Training_Plan_Assignment__c> tplanAssignmentMap = assignmentsMap.get(UserInfo.getUserId());
            Training_Plan_Assignment__c userTPlanAssignment = tplanAssignmentMap.get(trainingPlanId);
            if(userTPlanAssignment != null){
                tPlanAssignmentStatus = userTPlanAssignment.Status__c;
            }
        } 
    }
 
    private void loadTrainingPlanInfo(){
        tPlan = LMSWrappersService.getTrainingPlanDetails(trainingPlanId,UserInfo.getUserId(),false, true);
        System.debug('tPlan: ' + tPlan);
        if( AS_HelperClass.isUserMember(UserInfo.getUserId()) || !AS_HelperClass.TrainingPlanPreviewValidation(UserInfo.getUserId()) ){
            isMemberser = true;
        } else {
             isMemberser = false;
        }
        // load and validate the learning from the campagin.
        //campaignStatusButton();
    }
 
    public void retrieveItemDetails(){
         
        try{

            byPassLaunchModal = false;

            if(String.isBlank(selectedSectionId) || String.isBlank(selectedItemId)){
                throw new TrainingPlanDetailException(System.Label.ALMS_Invalid_Parameters_Message);
            }else{

                Set<Id> previousSectionIds = new Set<Id>();

                TrainingPlanSectionItem currentItem = null;
                List<TrainingPlanSection> planSections  = tPlan.sections;

                for(TrainingPlanSection s :planSections){

                    if(s.previousSectionId != null && !s.previousSectionOptional){
                        previousSectionIds.add(s.previousSectionId);
                    }

                    if(s.TrainingPlanSection.Id == selectedSectionId){

                        List<TrainingPlanSectionItem> items = s.items;

                        for(TrainingPlanSectionItem item : items){

                            if(item.currentSectionItemId == selectedItemId){
                                currentItem = item;
                                break;
                            }

                        }

                        break;
                    }

                }

                if(currentItem != null){

                    selectedItem = currentItem;

                    //Validate sequence if applicable
                    if(tPlan.trainingPlan.Enforce_Sequence__c){

                        LMSService.WithoutSharingOps wsops = new LMSService.WithoutSharingOps();

                        hasPreRequisite = false;

                        //Validate previous section item, if applicable
                        if(selectedItem.previousSectionItemId != null){
                            if(wsops.hasIncompleteLearningAssignment(selectedItem.previousSectionItemId, UserInfo.getUserId())){
                                hasPreRequisite = true;
                            }
                        }

                        //Always validate that the previous sections have been completed, if applicable
                        if(!hasPreRequisite && previousSectionIds.size()>0){
                            //Verify status of the assignment for the previous sections
                            if(wsops.hasIncompleteTPlanSectionAssignments(previousSectionIds, UserInfo.getUserId())){
                                hasPreRequisite = true;
                            }
                        }

                    }

                }else{
                    throw new TrainingPlanDetailException(System.Label.ALMS_Unable_Retrieve_Assignment_Info);
                }

                if(!hasPreRequisite && !(selectedItem.launchBehavior=='ask_user' || selectedItem.launchBehavior=='update_version')){
                    launchLearning();
                    byPassLaunchModal = true;
                }

            }


        }catch(Exception e){
            LMSUtils.logException(e,'TrainingPlanDetailController');
            LMSUtils.addGenericUnknownErrorMessage('TrainingPlanDetailController - retrieveItemDetails (2)');
        }
    }

    public PageReference launchLearning(){

        PageReference ref = null;
        PageReference eventRef = null;
        PageReference moodleRef = null;

        Learning__c learning = selectedItem.learning;

        PageReference lPR = null;
        String currentRecordType = learning.RecordType.DeveloperName;

        if(currentRecordType == LMSConstants.RT_TASK){

            lPR = Page.TaskViewer;

            learningTarget = '_self';
        }else if(currentRecordType == LMSConstants.RT_TRAINING_RESOURCE){
            //Not necessary to enforce CRUD/FLS here, this is just to determine how to handle the content no data is exposed to the user
            LMSService.WithoutSharingOps wsops = new LMSService.WithoutSharingOps();
            Learning__c l = wsops.getLearningDetails(learning.Id);

            lPR = Page.ResourceViewer;

            if(l.Current_Published_Version__r.Training_Resource__r.Display_in_Iframe__c){
                learningTarget = 'iframe';
            }else{
                learningTarget = '_blank';
                String resourceURL = l.Current_Published_Version__r.Training_Resource__r.Resource_URL__c;
                if(resourceURL != null && (resourceURL.contains('.visual.force.com/apex/') || resourceURL.contains('.lightning.force.com/'))){
                    learningTarget = '_internal';
                }
            }
        }else if(currentRecordType == LMSConstants.RT_QUIZ){
            lPR = Page.QuizViewer;
            learningTarget = '_self';
        } else if ( currentRecordType == 'Moodle' ) {

            String resourceURL;

            LMSService.WithoutSharingOps wsops = new LMSService.WithoutSharingOps();
            Learning__c l = wsops.getLearningDetails(learning.Id);
            system.debug('eL iver'+l);

            lPR = Page.ResourceViewer;

            if(l.Current_Published_Version__r.Training_Resource__r.Display_in_Iframe__c){
                learningTarget = 'iframe';
                resourceURL = l.AsMoodle_Course_URL__c;
            }else{
                learningTarget = '_blank';
                resourceURL = l.AsMoodle_Course_URL__c;
                if(resourceURL != null && (resourceURL.contains('.visual.force.com/apex/') || resourceURL.contains('.lightning.force.com/'))){
                    learningTarget = '_internal';
                }
            }
            moodleRef = new Pagereference( resourceURL );
        } else if ( currentRecordType == 'Event' ) {
            eventRef = AS_HelperClass.LearningEventRecType(currentRecordType, learning.Campaign__r.AS_Event_URL__c); //MLO dead//
        } else {
            learningTarget = '_internal';
            //Check for plugin launch URL
            LMSPlugins.LearningConfig customLearningConfig = LMSPlugins.getLearningPluginConfig(currentRecordType);
            lPR = new PageReference(customLearningConfig.getLaunchURLWithNamespace());
            Set<String> validLaunchTargets = new Set<String>{'_self','_blank','_internal','iframe'};
            learningTarget = validLaunchTargets.contains(customLearningConfig.launchTarget)?customLearningConfig.launchTarget:'_internal';
        }

        if ( eventRef != null ) {

            learningLaunchURL = eventRef.getUrl();

        } else if ( moodleRef != null ) {

            learningLaunchURL = moodleRef.getUrl();

        } else {

            if(learning.Custom_Preview_URL__c != null){
                ref = new PageReference(learning.Custom_Preview_URL__c);
            }else{
                ref = lPR;
            }

            if(ref != null){
                ref.setRedirect(true);
                ref.getParameters().put('aid',selectedItem.latestAssignment.Id);
                ref.getParameters().put('tpid',trainingPlanId);
                ref.getParameters().put('tpsid',selectedSectionId);
                ref.getParameters().put('tpitid',selectedItemId);
            }

            learningLaunchURL = LMSUtils.updateURLCommunityPath(ref.getUrl());
        }

        return null;
        // system.debug('hello jrc load');
        // PageReference ref = null;

        // Learning__c learning = selectedItem.learning;
        // system.debug('learning =>'+ learning);

        // PageReference lPR = null;
        // String currentRecordType = learning.RecordType.DeveloperName;
    
        // if(currentRecordType == LMSConstants.RT_TASK){
        //     system.debug('lpr ==>' + lPR);
        //     lPR = Page.TaskViewer;
        //     system.debug('LPR Pageref'+ lPR);
        //     learningTarget = '_self';
        //     System.debug('if 1');
        //     ref = lPR;
            
        // }else if(currentRecordType == LMSConstants.RT_TRAINING_RESOURCE ){
        //     System.debug(' else if 2');
        //     //Not necessary to enforce CRUD/FLS here, this is just to determine how to handle the content no data is exposed to the user
        //     LMSService.WithoutSharingOps wsops = new LMSService.WithoutSharingOps();
        //     Learning__c l = wsops.getLearningDetails(learning.Id);

        //     lPR = Page.ResourceViewer;
        //     String resourceURL; //iver
        //     if(l.Current_Published_Version__r.Training_Resource__r.Display_in_Iframe__c){

        //         learningTarget = 'iframe';
        //         //start iver
        //         system.debug('iver iframe?: '+learningTarget);
        //         resourceURL = l.Current_Published_Version__r.Training_Resource__r.Resource_URL__c;
        //         system.debug('iver resourceURL: '+resourceURL);
        //         //end iver
        //     }else{
        //         learningTarget = '_blank';
        //         resourceURL = l.Current_Published_Version__r.Training_Resource__r.Resource_URL__c;
        //         if(resourceURL != null && (resourceURL.contains('.visual.force.com/apex/') || resourceURL.contains('.lightning.force.com/'))){
        //             learningTarget = '_internal';
        //         }
        //     }
        //     system.debug('learningTarget ==> '+ learningTarget);
        //     //ref = new PageReference(learning.AsMoodle_Course_URL__c);
        //     ref = new PageReference(resourceURL); //iver
        // } else if(currentRecordType == 'Moodle') {
        //     LMSService.WithoutSharingOps wsops = new LMSService.WithoutSharingOps();
        //     Learning__c l = wsops.getLearningDetails(learning.Id);

        //     lPR = Page.ResourceViewer;
        //     String resourceURL; //iver
        //     if(l.Current_Published_Version__r.Training_Resource__r.Display_in_Iframe__c){

        //         learningTarget = 'iframe';
        //         //start iver
        //         system.debug('iver iframe?: '+learningTarget);
        //         resourceURL = l.AsMoodle_Course_URL__c;
        //         system.debug('iver resourceURL: '+resourceURL);
        //         //end iver
        //     }else{
        //         learningTarget = '_blank';
        //         resourceURL = l.AsMoodle_Course_URL__c;
        //         if(resourceURL != null && (resourceURL.contains('.visual.force.com/apex/') || resourceURL.contains('.lightning.force.com/'))){
        //             learningTarget = '_internal';
        //         }
        //     }
        //     system.debug('learningTarget ==> '+ learningTarget);
        //     //ref = new PageReference(learning.AsMoodle_Course_URL__c);
        //     ref = new PageReference(resourceURL); //iver

        // } else if(currentRecordType == LMSConstants.RT_QUIZ){
        // 		System.debug(' else if 3');
        //     lPR = Page.QuizViewer;
        //     learningTarget = '_self';
        //     ref = lPR;
        // } else {
        // 	System.debug(' else 1');
        //     if(currentRecordType == 'Event'){
        //         ref = AS_HelperClass.LearningEventRecType(currentRecordType, learning.Campaign__r.AS_Event_URL__c); //MLO dead//
        //     } else {

        //         learningTarget = '_internal';
              
        //         //Check for plugin launch URL
        //         LMSPlugins.LearningConfig customLearningConfig = LMSPlugins.getLearningPluginConfig(currentRecordType);
        //         lPR = new PageReference(customLearningConfig.getLaunchURLWithNamespace());
        //         Set<String> validLaunchTargets = new Set<String>{'_self','_blank','_internal','iframe'};
        //         learningTarget = validLaunchTargets.contains(customLearningConfig.launchTarget)?customLearningConfig.launchTarget:'_internal';
                
        //         /* Jrc add this part */
        //         ref = lPR;
        //         ref.setRedirect(true);
        //         ref.getParameters().put('aid',selectedItem.latestAssignment.Id);
        //         ref.getParameters().put('tpid',trainingPlanId);
        //         ref.getParameters().put('tpsid',selectedSectionId);
        //         ref.getParameters().put('tpitid',selectedItemId);
        //     } 
        // }
        // system.debug(' currentRecordType ==>  '+currentRecordType);

        // /*Jrc Comment on this part 
        // if(currentRecordType == 'Moodle'){
          
        // }else{
        //     ref = lPR;
        //     ref.setRedirect(true);
        //     ref.getParameters().put('aid',selectedItem.latestAssignment.Id);
        //     ref.getParameters().put('tpid',trainingPlanId);
        //     ref.getParameters().put('tpsid',selectedSectionId);
        //     ref.getParameters().put('tpitid',selectedItemId);
        // } */
		// 		if(ref != null) {
		// 			learningLaunchURL = ref.getUrl();
		// 		}
        
        // return null;

    }

    public PageReference updateToNewVersionAndLaunch(){
        selectedItem.updateToLatestVersion();
        byPassLaunchModal = true;
        return launchLearning();
    }

    public PageReference keepOldVersionAndLaunch(){
        selectedItem.keepOldVersion();
        byPassLaunchModal = true;
        return launchLearning();
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
 
        return null; 
    }

    public void printCertificate(){
        //   AsCPDPdfController.createTrainPlanAssignPdf(trainingPlanId);
    }
    
    
    public String strJson {get;set;}
    public void campaignStatusButton(){
 
        Id loginUserId =  UserInfo.getUserId();
        Id eventRecId = Schema.SObjectType.Learning__c.getRecordTypeInfosByName().get('Event').getRecordTypeId();
        Id campRecId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Event').getRecordTypeId();
        User loginUser = [ Select ContactId From User Where Id=:loginUserId ];
        Map<Id,Id> userIdToContactIdMap = new  Map<Id,Id>();
        userIdToContactIdMap.put(loginUserId,loginUser.ContactId);
        // system.debug('lgUser ==> '+ lgUser);
        
        set<Id> learningIdSet = new set<Id>();
        set<Id> CampIdSet = new set<Id>();
        map<Id,Id> campAndLearnMap = new map<Id,Id>();
        set<Id> learningIdconId = new set<Id>();
        if( tPlan != null ){
                if(tPlan.sections.size() > 0) {

                for( TrainingPlanSection tSection : tPlan.sections  ){
                    for( TrainingPlanSectionItem tSecItem : tSection.items ){
                        if( tSecItem.learning.RecordTypeId == eventRecId ){
                            if( tSecItem.learning.Campaign__c != null ){
                                  learningIdSet.add(tSecItem.learning.Id);
                                  CampIdSet.add( tSecItem.learning.Campaign__c );
                                  campAndLearnMap.put(tSecItem.learning.Campaign__c  ,  tSecItem.learning.Id);
                            }
                          
                            system.debug('tSecItem.learning ==> '+ tSecItem.learning.Campaign__c);
                        }
                    }
                }

                system.debug('learningIdSet ==> '+ learningIdSet); 
           


                //Learning Assignment
                Map<Id,Id> userIdAndLearniingIdMap = new Map<Id,Id>();
                for( Learning_Assignment__c learningAss : [ Select Id, Name,Learning__r.Campaign__c , User__c From Learning_Assignment__c WHERE Learning__c In:learningIdSet And User__c =:loginUserId ] ){
                    userIdAndLearniingIdMap.put(learningAss.Learning__r.Campaign__c,userIdToContactIdMap.get(learningAss.User__c));
                }

                system.debug('userIdAndLearniingIdMap ==> '+ userIdAndLearniingIdMap); 
        
                //Campaing and Campaign Member
                Map<Id,String> LearningStatusMp = new Map<Id,String>(); 
                for( CampaignMember campMember : [SELECT Id,Status,Campaign.RecordTypeId,Campaign.Name,Campaign.Learning__c,ContactId, CampaignId FROM CampaignMember WHERE CampaignId In:CampIdSet AND Campaign.RecordTypeId =:campRecId And ContactId =:loginUser.ContactId ] ){
               
                    if(  userIdAndLearniingIdMap.get(campMember.CampaignId) == campMember.ContactId  ){
                        if( campMember.Status == 'Attending'  ){
                            LearningStatusMp.put(  campAndLearnMap.get( campMember.CampaignId ) , 'Attending' );
                        } else if( campMember.Status == 'Checked in' ){
                            LearningStatusMp.put(campAndLearnMap.get(  campMember.CampaignId )  , 'Checked in' );
                        }
                    }

                } 

                system.debug('LearningStatusMp ==> '+ LearningStatusMp);
                if(LearningStatusMp.size() != 0 ){
                    strJson =JSON.serialize(LearningStatusMp);
                }
            }
        }

    }
    
}