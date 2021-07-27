/**
     * Aura version of the TrainingTrackDetailCtrl class
     * 
     * @author	Davanti:
     * @author	Surbhi Sharma (Davanti),
     * @since	24/07/2020 
     * @date	24/07/2020 - Surbhi Sharma (Davanti): created initial version
     * @return  pageStateWrapper 
     * @see     CourseDetail_Track.cmp
     */
public with sharing class TrainingTrackDetailCtrl_Lightning {
	public static pageStateWrapper state;
    @AuraEnabled
    public static pageStateWrapper getTrainingTrackState(Id trainingTrackId){
        state = new pageStateWrapper();
        state.canViewTrainPlan=false; //set not able to view as default

        if(UserInfo.getUserType() == 'Guest'){
            state.isGuest = 'guest';
        }
        state.trackId = trainingTrackId;

        init();
        return state;
        
    }
    public static void init() {
        state.isEnrolledInTrack = false;
        state.totalItems = 0;
        state.totalCompleted = 0;
        state.tPlan= LMSWrappersService.getTrainingTrackDetails(state.trackId);
        List < Training_Track__c > tracksList = LMSService.getTrainingTracks('Active', state.trackId, LMSUtils.isPortalUser());

        // If we have access to the track header, proceed to fetch track item details
        if (tracksList.size() > 0) {
            state.track = tracksList.get(0);
            if(state.track!=null){
              if(state.track.Status__c =='Active' && state.track.PSA_Start_Date__c <= system.today() && state.track.PSA_Accreditation_Expiry_Date__c >system.today()){
                    state.isvalidPlan = true;
                }
                else{
                    state.isvalidPlan = false;
                }  
            }
                

            state.trackLevels = LMSWrappersService.getTrainingTrackLevels(LMSService.getTrainingTrackLevels(state.trackId, LMSUtils.isPortalUser()));
						System.debug('trackLevels : ' + state.trackLevels);
            //Fetch overall progress
            for (TrainingTrackLevel ttlevel: state.trackLevels) {
                for (TrainingTrackItem ti: ttlevel.trackItems) {
                    state.totalItems++;
                    if (ti.tplanAssignment != null & ti.tplanAssignment.Status__c == LMSConstants.TPLAN_STATUS_COMPLETED) {
                        state.totalCompleted++;
                    }

                    if (ti.trackItem.Training_Plan__r != null) {
                        ti.isExpired = !LMSService.isActiveTrainingPlan(ti.trackItem.Training_Plan__r);
                    }
                }
            }

        } else {
            LMSUtils.addErrorMessage(System.Label.ALMS_Training_Track_No_Access);
        }
				
        state.trainTrackUser = [SELECT AccountId FROM User WHERE Id =: UserInfo.getUserId()];

        //--->custom code<---
        state.trackTy = [select Id, Name, AS_Track_Type__c, AS_Code__c, Information__c, Product__c,AS_Learning_Package__c,AS_Learning_Package__r.AS_Accreditation_level__c,AS_Learning_Package__r.AS_product__c,AS_Learning_Package__r.AS_Event_selection__c 
                         
                         from Training_Track__c where Id =: state.trackId];
        
        
        if (state.trackTy != null) {
            System.debug(' trackTy ==> ' + state.trackTy);
            if (state.trackTy.AS_Track_Type__c != null) state.TrackType = state.trackTy.AS_Track_Type__c;
        }
        
        if(state.trainTrackUser.AccountId != null && state.trackTy != null) {
        	List<Training_Track_Account__c> oneTrainTrackAcc = [Select Id from Training_Track_Account__c where Training_Track__c = :state.trackTy.Id AND Account__c =: state.trainTrackUser.AccountId LIMIT 1];
        	if(oneTrainTrackAcc.size() > 0) {
        		state.isEnrolledInTrack = true;
        	}
        }
        
        if( AS_HelperClass.isUserMember(UserInfo.getUserId()) ){
            state.isLogin = true;
            state.canViewTrainPlan = true;
            
        } else {
            state.isLogin = false;
            state.canViewTrainPlan = false;
        } 

        // coded by danryl (10/23/2019) - ticket #PRI-134
        List<Id> unitIds = new List<Id>();
        List<Id> tpIds = new List<Id>();
        List<Learning_Package_Unit__c> lpuList = [SELECT Id, AS_Unit__c FROM Learning_Package_Unit__c WHERE AS_Learning_Package__c =: state.trackTy.AS_Learning_Package__c];
        for( Learning_Package_Unit__c lpu : lpuList ) {
            unitIds.add( lpu.AS_Unit__c );
        }
 
        List<Unit__c> unitList = [SELECT Id, AS_Training_Plan__c, AS_Is_Event__c FROM Unit__c WHERE Id IN : unitIds ];
        for( Unit__c u : unitList ) {
            if ( u.AS_Is_Event__c == true ) {
                tpIds.add( u.AS_Training_Plan__c );
            }
        }
        state.trainIds = new List<Id>();
        state.trainIds.addAll( tpIds );
    
        
    }

    /**
     * Aura version of the TrainingTrackDetailCtrl method
     * 
     * @author	Davanti:
     * @author	LToohey (Davanti),
     * @since	24/07/2020 
     * @date	24/07/2020 - LToohey (Davanti): created initial version
     * @return  pageStateWrapper 
     * @see     CourseDetail_Track.cmp
     */
    @AuraEnabled 
    public static pageStateWrapper purchase(pageStateWrapper inputState) {

        //Static class variable to maintain 'page state' for lightning component
        state = inputState; 

        //Reset error msg and redirect URLs
        state.userErrorMessage = null;
        state.redirectURL=null;
        state.redirectExternalURL=null;
        state.communityPage=null;

        String memberNonMember; // possible values (member, non-member,null)
        String baseURL = URL.getSalesforceBaseUrl().toExternalForm(); //https://cpd-my-psa.cs73.force.com

        if (state.canViewTrainPlan) {
            memberNonMember = 'member';
        } else if (!AS_HelperClass.TrainingPlanPreviewValidation(UserInfo.getUserId())) {
            memberNonMember = 'non-member';
        }
        try{
            switch on state.trackTy.AS_Track_Type__c{
                when 'Member Only (Free)'{
                    System.debug('Member Only (Free)');
                    if (memberNonMember == 'member') {
                        Training_Track_Account__c trackAcc = new Training_Track_Account__c();
                        trackAcc.Account__c = state.trainTrackUser.AccountId;
                        trackAcc.AS_Approval_Status__c = 'Confirmed';
                        trackAcc.Training_Track__c = state.trackId;
                        insert trackAcc;    
                    }else if (memberNonMember == 'non-member') {
                        // ASPSASettings__c psaSettings = ASPSASettings__c.getOrgDefaults();
                        // String theFullurl = (psaSettings.AsMembershipRegistrationURL__c != null) ? String.valueOf(psaSettings.AsMembershipRegistrationURL__c) : 'https://staging-staging-pharmaceuticalaus.cs6.force.com'; //staging url as default if no given data
                        state.isGuest = 'non-member';
                        state.userErrorMessage = 'Register error';
                    }
                }          
                when 'Paid'{
                    Opportunity opp = AS_HelperClass.TrainingPlanRegisterHelper(UserInfo.getUserId(), state.trackTy.Product__c, null);
                    System.debug('Paid opp:' + opp);
                    if (opp != null) {
                        PageReference ref = Page.PaymentPage;
                        ref.getParameters().put('oppId', opp.Id);
                        ref.getParameters().put('trainTrackId', state.trackTy.Id);
                        state.redirectURL =  baseURL + '/s/sfdcpage/' + EncodingUtil.urlEncode(ref.getUrl(),'UTF-8');
                    } else {
                        state.isGuest = 'member';
                        state.userErrorMessage = 'A problem was encountered during opportunity creation. Please contact administrator.';
                    }
                }
                // this is the RTO
                when 'Diploma', 'Intern Training Program', 'Qualification'{
                    User theUser = [Select Id, AccountId,Account.PersonEmail,Contact.AccountId from User where Id =: userinfo.getuserId()];
                    
                    if (theUser.AccountId != null && state.trackTy.AS_Learning_Package__c !=null) {
                        List<String> enrolStatus = new List<String>{ 'Cancelled/Withdrawn', 'Rejected', 'Expired' };
                            
                        state.recordTypeId = Schema.SObjectType.Enrolment_Form__c.getRecordTypeInfosByName().get('PSA Enrolment').getRecordTypeId();
                        List<Enrolment_Form__c> enrolrecList = [SELECT Id,AS_Learning_Package__c,AS_Account__c,AS_Enrolment_Type__c,Enrolment_Status__c,CreatedDate,AS_Email__c FROM Enrolment_Form__c WHERE AS_Learning_Package__c =: state.trackTy.AS_Learning_Package__c AND AS_Account__c =: theUser.AccountId AND Enrolment_Status__c NOT IN : enrolStatus];
                        
                        if (!enrolrecList.isEmpty() ) {
                            //Return Community Page name to direct to - must be API name
                            state.communityPage = 'my_enrolments__c';
                        } else {
                            if (state.trackTy.AS_Learning_Package__r.AS_Event_selection__c == true ) {
                                PageReference pr = Page.EventEnrol;
                                pr.getParameters().put( 'id', JSON.serialize( state.trainIds ) );
                                pr.getParameters().put( 'learning', state.trackTy.AS_Learning_Package__c );
                                pr.getParameters().put( 'trackId', state.trackTy.Id );
                                pr.getParameters().put( 'track', 'true' );
                                state.redirectURL =  baseURL + '/s/sfdcpage/' + EncodingUtil.urlEncode(pr.getUrl(),'UTF-8');
                            } else {
                                // creation of enrolment
                                Enrolment_Form__c enrollist = new Enrolment_Form__c();
                                enrollist.RecordTypeId = state.recordTypeId;
                                enrollist.AS_Account__c = theUser.AccountId;
                                enrollist.AS_Learning_Package__c = state.trackTy.AS_Learning_Package__c;
                                enrollist.AS_Email__c = theUser.Account.PersonEmail;
                                enrollist.AS_Enrolment_Type__c = state.trackTy.AS_Learning_Package__r.AS_Accreditation_level__c;
                                enrollist.Enrolment_Status__c = 'Draft';
                                insert  enrollist;
                                
                                PageReference redirectPage = new PageReference(baseURL + '/s/enrolment-form');
                                redirectPage.getParameters().put('enrolid', enrollist.Id);
                                redirectPage.getParameters().put('accountid',theUser.AccountId);
                                state.redirectURL = redirectPage.getUrl();
                            }
                        }
                    } else {
                        state.isGuest = 'non-member';
                        state.userErrorMessage = 'You cannot enroll to this kind of Training Plan. Your credential is not connected to any Account';
                    }
                }
                //Member benefit
                when 'Member Benefit'{
                    if (memberNonMember == 'member') {
                        Training_Track_Account__c trackAcc = new Training_Track_Account__c();
                        trackAcc.Account__c = state.trainTrackUser.AccountId;
                        trackAcc.AS_Approval_Status__c = 'Confirmed';
                        trackAcc.Training_Track__c = state.trackId;
                        insert trackAcc;
                        System.debug('Member Benefit : ' + trackAcc);
                    } else if (memberNonMember == 'non-member') {
                        //TO-DO: Wrap oppy - Util class adds APEX PAGE MESSAGES
                        Opportunity opp = AS_HelperClass.TrainingPlanRegisterHelper(UserInfo.getUserId(), state.trackTy.Product__c, null);
                        System.debug('Member Benefit opp:' + opp);
                        if (opp != null) {
                            PageReference ref = Page.PaymentPage;
                            ref.getParameters().put('oppId', opp.Id);
                            ref.getParameters().put('trainTrackId', state.trackTy.Id);
                            System.debug('Member Benefit');
                            state.redirectURL =  baseURL + '/s/sfdcpage/' + EncodingUtil.urlEncode(ref.getUrl(),'UTF-8');
                        } else {
                            state.isGuest = 'non-member';
                            state.userErrorMessage = 'A problem was encountered during opportunity creation. Please contact administrator.';
                        }
                    }
                }
                //Member only Paid
                when 'Member Only (Paid)'{
                    System.debug('Member Only (Paid) HERE');
                    if (memberNonMember == 'member') {
                        //TO-DO: Wrap oppy - util method adds APEX PAGE MESSAGES
                        Opportunity opp = AS_HelperClass.TrainingPlanRegisterHelper(UserInfo.getUserId(), state.trackTy.Product__c, null);
                        System.debug('Member Only (Paid):' + opp);
                        if (opp != null) {
                            PageReference ref = Page.PaymentPage;
                            ref.getParameters().put('oppId', opp.Id);
                            ref.getParameters().put('trainTrackId', state.trackTy.Id);
                            System.debug('Member Only (Paid)');
                            
                            state.redirectURL =  baseURL + '/s/sfdcpage/' + EncodingUtil.urlEncode(ref.getUrl(),'UTF-8');
                        } else {
                            state.isGuest = 'non-member';
                            state.userErrorMessage = 'A problem was encountered during opportunity creation. Please contact administrator.';   
                        }
                    } else if (memberNonMember == 'non-member') {
                        // ASPSASettings__c psaSettings = ASPSASettings__c.getOrgDefaults();
                        // String theFullurl = (psaSettings.AsMembershipRegistrationURL__c != null) ? String.valueOf(psaSettings.AsMembershipRegistrationURL__c) : 'https://staging-staging-pharmaceuticalaus.cs6.force.com'; //staging url as default if no given data
                        state.isGuest = 'non-member';
                        state.userErrorMessage = 'Register error'; //Used on lightning component side to show modal content
                    }  
                }
                when 'Public'{
                    Training_Track_Account__c trackAcc = new Training_Track_Account__c();
                    trackAcc.Account__c = state.trainTrackUser.AccountId;
                    trackAcc.AS_Approval_Status__c = 'Confirmed';
                    trackAcc.Training_Track__c = state.trackId;
                    insert trackAcc;
                    System.debug('Public ' + trackAcc);
                }
                when else{
                    //Unable to find the training plan type
                    state.userErrorMessage = 'This training tracck does not have a valid Type set. Please contact administrator.';
                }
            }
        }catch(Exception e){
            //Throw aura exception back to page
            System.debug('TrainingPlanPreviewController_Lightning ERROR: Trace: ' + e.getStackTraceString() + ' Cause: ' + e.getCause());
            throw new AuraHandledException('An error occurred while attempting to enrol: ' + e.getMessage());
        } 

        return state;
    }


    
    public class pageStateWrapper{
        //Community page name to direc to
        @AuraEnabled public String communityPage {get; set;}
        
        //Purchase Method variables
        @AuraEnabled public Id recordTypeId{get; set;}
        @AuraEnabled public User trainTrackUser{get; set;}
        @AuraEnabled public String redirectURL {get; set;}
        @AuraEnabled public String redirectExternalURL {get; set;}
        @AuraEnabled public String userErrorMessage{get; set;}
        @AuraEnabled public String isGuest{get; set;}
        @AuraEnabled public boolean isLogin{get; set;}
        @AuraEnabled public Boolean isEnrolledInTrack{get; set;}

        @AuraEnabled public TrainingTrack tPlan{get; set;}
        @AuraEnabled public string trackId{get; set;}
        @AuraEnabled public Integer totalItems{get; set;}
        @AuraEnabled public Integer totalCompleted{get; set;}
        @AuraEnabled public String TrackType{get; set;}
        @AuraEnabled public Training_Track__c track {get; set;}
        @AuraEnabled public Training_Track__c trackTy {get; set;}
        @AuraEnabled public boolean canViewTrainPlan {get; set;}
         @AuraEnabled public boolean isvalidPlan {get;set;}
        @AuraEnabled public List<Id> trainIds{get; set;}
        @AuraEnabled public List < TrainingTrackLevel > trackLevels{get; set;}
        @AuraEnabled public transient Achievement__c mainAchievement{get;set;}
    	@AuraEnabled public transient List<Training_Track_FAQ__c > tpFAQs{get;set;}
    	@AuraEnabled public transient List<Education_FAQ__c> listFAQs{get;set;}
    	@AuraEnabled public transient Education_FAQ__c mainFAQ{get;set;}
    	@AuraEnabled public Training_Plan__c prerequsite1Plan{get;set;}
    	@AuraEnabled public Training_Plan__c prerequsite2Plan{get;set;}
        @AuraEnabled public Training_Plan__c prerequsite3Plan{get;set;}
        @AuraEnabled public Training_Plan__c related1Plan{get;set;}
        @AuraEnabled public Training_Plan__c related2Plan{get;set;}
        @AuraEnabled public Training_Plan__c related3Plan{get;set;}
        @AuraEnabled public Training_Plan__c related4Plan{get;set;}
    }

    @AuraEnabled
    public Static User getUserAccountDetails(String userId) {
        List<User> userList = [
            SELECT Id, ContactId, Contact.AccountId, 
            Account.CPQ_Membership_Product__pc,
            Account.CPQ_Membership_Status__pc
            FROM User 
            WHERE Id=:userId
        ] ;
         
         return !userList.isEmpty() ? userList[0] : new User();
                 
     }

     @AuraEnabled
     public Static List<Training_Plan__c> getTrainingPackageDetails(String tId) {
 
         List<Training_Plan__c> tplans = [select id,
                                            AS_Product__c,
                                            Enable_Self_Registration__c,
                                            Self_Registration_Access__c,
                                            Available_for_Essential__c
                                            from Training_Plan__c 
                                            where Id=:tId];
          
          return tplans;
                  
      }
        
}