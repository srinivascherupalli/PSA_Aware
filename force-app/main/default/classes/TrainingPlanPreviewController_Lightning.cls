public with sharing class TrainingPlanPreviewController_Lightning extends LMSBaseController {

    //Get data and return without state to start with
    public static pageStateWrapper state;
    
    /* Constructor for lightning component. Returns pageState wrapper*/
    @AuraEnabled
    public static pageStateWrapper getTrainingPlanState(Id planId){
        state = new pageStateWrapper();
        state.canViewTrainPlan=false; //set not able to view as default
		
        if(UserInfo.getUserType() == 'Guest'){
            state.isGuest = 'guest';
            state.isPreview=True;
        }
        else{
            state.isPreview=false;
        }
        
        
        state.trainingPlanId = planId;
        state.isAlreadyInBookMark = AsTrainingPlanBookMark.isCheckTrainingPlanInBookMark( UserInfo.getUserId() , state.trainingPlanId );
        //Check if a user is already enrolled in the training plan we're viewing
        state.userEnrolled = enrolledInTrainingPlan(planId);
        
        /* INIT METHOD */
        init();
        
        if(state.canViewTrainPlan == false && !AS_HelperClass.TrainingPlanPreviewValidation(UserInfo.getUserId())){
            state.nonMember_memberBenefit = 'Paid';
        }
        
        // Event record type details and soql
        Boolean parentCamp = false;
        state.isEvent = 'Enrol Now';
        Set<String> campIds = new Set<String>(); 
        Set<String> recIds = new Set<String>(); 
        Set<String> campId = new Set<String>();
        Id recordTypeC = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Event').getRecordTypeId();
        Id recordTypeL = Schema.SObjectType.Learning__c.getRecordTypeInfosByName().get('Event').getRecordTypeId();
        Set<String> learningId = new Set<String>();
        List<Training_Plan_Section_Item__c> sectionItem = [Select Id, Learning__c, Learning__r.RecordTypeId, Training_Plan_Section__r.Training_Plan__c From Training_Plan_Section_Item__c Where Training_Plan_Section__r.Training_Plan__c =: state.trainingplanId];
        for(Training_Plan_Section_Item__c planSec : sectionItem){
            recIds.add(planSec.Learning__r.RecordTypeId);
            //learningId.add(planSec.Learning__c);
        }
        if(recIds.contains(recordTypeL)) state.isEvent = 'Select Date';
        else state.isEvent = 'Enrol Now';

        //Training_Track_Level_Item__c
        List<Training_Track_Level_Item__c> TTLItem = [select Id, Name, Training_Track_Level__c from Training_Track_Level_Item__c where Training_Plan__c =: state.trainingPlanId];

        if(TTLItem.size() > 0){
            List<Training_Track_Level__c> TTL_list = [select Id, Name, Training_Track__r.AS_Track_Type__c from Training_Track_Level__c where Id =: TTLItem[0].Training_Track_Level__c];
            if(TTL_list.size() > 0){
                state.trackType = TTL_list[0].Training_Track__r.AS_Track_Type__c;
            }
        }

        system.debug('Exiting getTrainingPlanState with state: ' + JSON.serializePretty(state));
        system.debug('User: ' + UserInfo.getUserId() );
        return state;
    }

    //Init used in getTrainingPlans above
    private static void init(){
        try{
            loadTrainingPlanInfo();
            state.isApprovalRequired = false;
            
            state.dummyRequest = new Training_Plan_Access_Request__c();
            state.existingRequest = null;
            

            if(state.tPlan != null){
                if(state.tPlan.trainingPlan.Self_Registration_Access__c == 'Requires Approval'){
                    state.isApprovalRequired = true;
                }
                if(state.tPlan.mainAchievement != null){
                    state.lUsersWithAchievement = LMSService.getUsersForAchievement(state.tPlan.mainAchievement.Id, LMSConstants.AA_ACQUIRED_STATUS, 12);
                }
            }else{
                System.debug('Error here from init 1');
                /* LMSUtils.addErrorMessage(System.Label.ALMS_Training_Plan_No_Access_Message);  */
                    throw new AuraHandledException(System.Label.ALMS_Training_Plan_No_Access_Message);
                }
                
            }catch(Exception e){
                System.debug('Error here from init');
                LMSUtils.logException(e,'TrainingPlanPreviewController_Lightning');
                
                /*LMSUtils.addGenericUnknownErrorMessage('TrainingPlanPreviewController - init (1)');*/
                throw new AuraHandledException('An unkown error occurred. Please contact you administrator');
        }
    }

    /* Check if current user is enrolled in the current training plan */
    public static boolean enrolledInTrainingPlan(Id tplanId){
        Boolean enrolled=false;
        try{
            List<Training_Plan_Assignment__c> trainPlanAssign =[Select Id, User__c, Status__c,Training_Plan__c FROM Training_Plan_Assignment__c WHERE User__c=:UserInfo.getUserId() AND Training_Plan__c=: tplanId];
            if(trainPlanAssign!=null && trainPlanAssign.size()>0){
                enrolled=true;
            }
        }catch (Exception e){
            System.debug('Error in enrolledInTrainingPlan: ' + e.getMessage());
        }
        return enrolled;
    }

    /* Load Training Plan info */
    public static void loadTrainingPlanInfo(){
        state.tPlan = LMSWrappersService.getTrainingPlanDetails(state.trainingPlanId,UserInfo.getUserId(),state.isPreview, true);
        
        if(state.tPlan!= null){
            /*state.isvalidPlan = true;
            if(!LMSService.isActiveTrainingPlan(state.tPlan.trainingPlan)){
                state.isvalidPlan = false;
            }*/
            //Detail page with Enrol buttons
                if(state.tPlan.trainingPlan.Status__c =='Active' && state.tPlan.trainingPlan.Start_Date__c!=null  && state.tPlan.trainingPlan.Start_Date__c <= system.today() &&state.tPlan.trainingPlan.End_Date__c!=null && state.tPlan.trainingPlan.End_Date__c >=system.today()){
                    state.isvalidPlan = true;
                }
            //Detail page without Enrol buttons
                else if(state.tPlan.trainingPlan.Hide_After_End_Date__c == false && state.tPlan.trainingPlan.Status__c == LMSConstants.TPLAN_STATUS_ARCHIVED && state.tPlan.trainingPlan.Start_Date__c!=null  && state.tPlan.trainingPlan.Start_Date__c > system.today() && state.tPlan.trainingPlan.End_Date__c!=null && state.tPlan.trainingPlan.End_Date__c < system.today()){
                	state.isvalidPlan = false;
            	}
            
            else{
                state.isvalidPlan = false;
            }
                
          }
        
        if( AS_HelperClass.isUserMember(UserInfo.getUserId()) ){
            state.isMemberser = true;
            
            // 9/9/2018 for update if user can view training plan by type
            if(AS_HelperClass.isUserMember(UserInfo.getUserId())) {
                state.canViewTrainPlan = true;
            } else if(!AS_HelperClass.TrainingPlanPreviewValidation(UserInfo.getUserId())) {
                state.canViewTrainPlan = false;
            }
        } else {
            state.isMemberser = false;
        } 
        System.debug('State can view train plan: ' + state.canViewTrainPlan + ' isMemberser: ' + state.isMemberser );
    }
    
    /**
     * Aura version of the TrainingPlanPreviewController method
     * Checks training plan type and redirects to appropriate page or throws errors
     * Also calls future method where status needs to be checked on component side
     * 
     * @author	Davanti:
     * @author	LToohey (Davanti),
     * @since	22/07/2020 
     * @date	22/07/2020 - LToohey (Davanti): created initial version
     * @return  pageStateWrapper 
     * @see     Course_Details.cmp
     */
    @AuraEnabled
    public static pageStateWrapper registerForTrainingPlan(pageStateWrapper inputState) {
        
        system.debug(inputState.canViewTrainPlan);
        //Set state from component
        state = inputState;
        
        //Test all event types:
        //state.tplan.trainingPlan.Type__c = 'Public';
        
        //Reset current State values
        state.userErrorMessage = null;
        state.redirectURL = null;
        state.redirectExternalURL = null;
        state.futureMethodCalled=false;
        System.debug('Entering TrainingPlanPreviewController_Lightning: registerForTrainingPlan with state: ' + JSON.SerializePretty(state));
        String memberNonMember; // possible values (member, non-member,null)
        String baseURL = URL.getSalesforceBaseUrl().toExternalForm(); //https://cpd-my-psa.cs73.force.com

        //Set member type for the current user 
        if(state.canViewTrainPlan){
            memberNonMember = 'member';
        } else if(!AS_HelperClass.TrainingPlanPreviewValidation(UserInfo.getUserId())) {
            memberNonMember = 'non-member';
        }
        try{
            System.debug('Member non member val: ' + memberNonMember);
            //Check current Training Plan Type 
            switch on state.tplan.trainingPlan.Type__c{
                when 'Member Only (Free)'{
                    System.debug('Member Only (Free)');
                    if(memberNonMember == 'member') {
                        //FUTURE METHOD CALLED
                        state.futureMethodCalled=true;
                        System.debug('Future Method called: ' + JSON.SerializePretty(state));
                        AsOpportunityTriggerHandler.myFutureMethod(new Set<Id>{UserInfo.getUserId()}, state.trainingPlanId, LMSUtils.getCurrentNetworkId());
                    } else if(memberNonMember == 'non-member') {
                        ASPSASettings__c psaSettings = ASPSASettings__c.getOrgDefaults();
                        String theFullurl = (psaSettings.AsMembershipRegistrationURL__c!=null)?String.valueOf(psaSettings.AsMembershipRegistrationURL__c):'https://staging-staging-pharmaceuticalaus.cs6.force.com'; //staging url as default if no given data
                        state.userErrorMessage = 'Register error';
                    }
                }
                when 'Paid'{
                    System.debug('Paid');
                    //Create an opportunity and re-direct to the payment page
                    // TO-DO: Helper classes set apex page messages -- Need to change the util, or catch the error when attempting to set page messages?
                    Opportunity opp = AS_HelperClass.TrainingPlanRegisterHelper(UserInfo.getUserId(), state.tPlan.trainingPlan.AS_Product__c, state.tPlan.trainingPlan.CampaignId__c);

                    if(opp != null) {
                        //Build payment URL string and set to the payment page
                        //Looks like need to build the full URL: https://cpd-my-psa.cs73.force.com/s/sfdcpage/%2Fapex%2FPaymentPage%3FoppId%3Da116D000000Cdg7QAC%26tPlanId%3D3Da116D000000Cdg7QAC
                        PageReference ref = Page.PaymentPage;//'/apex/PayementPage' 
                        ref.getParameters().put('oppId', opp.Id);
                        ref.getParameters().put('tPlanId', state.trainingPlanId);
                        state.redirectUrl = baseURL + '/s/sfdcpage/' + EncodingUtil.urlEncode(ref.getUrl(),'UTF-8');
                    } else {
                        //Set error message to be thrown as toast
                        state.userErrorMessage = 'A problem was encountered during opportunity creation. Please contact administrator.';
                    }
                }
                when 'RTO'{
                    System.debug('RTO');
                    User theUser = [Select Id, AccountId from User where Id = :userinfo.getuserId()];
                    if(theUser.AccountId != null) {
                        PageReference ref = new PageReference('https://www.tfaforms.com/4692606');  // jrc : ticket PSA-218
                        ref.getParameters().put('id', theUser.AccountId);
                        ref.getParameters().put('trackid', state.trainingPlanId);
                        state.redirectExternalURL = ref.getUrl();
                    }else{
                        //Throw aura handled exception to be shown as toast
                        state.userErrorMessage = 'You cannot enrol to this kind of Training Plan. Your credential is not connected to any Account';
                    }
                }
                when 'Event'{
                    System.debug('Event');
                    //Check for event URL from Training Plan
                    List<Training_Plan__c> redirect_field = [SELECT Id, AS_Registration_URL__c, AS_Event__r.AS_Event_URL__c FROM Training_Plan__c WHERE Id =: state.tPlan.trainingPlan.Id];
                    
                    if(redirect_field.size() > 0 && redirect_field[0].AS_Event__r.AS_Event_URL__c!=null){
                        //Create page ref to navigate to event
                        PageReference ref = new PageReference(redirect_field[0].AS_Event__r.AS_Event_URL__c);                        
                        ref.setRedirect(true);
                        state.redirectExternalURL = ref.getUrl();
                    } else{
                        //Set error message to be shown as toast
                        state.userErrorMessage = 'No event url is set for this training plan related event.';
                    }
                }
                when 'Member Benefit'{
                    System.debug('Member Benefit');
                    if(memberNonMember == 'member') {
                        //FUTURE METHOD
                        state.futureMethodCalled=true;
                        AsOpportunityTriggerHandler.myFutureMethod(new Set<Id>{UserInfo.getUserId()}, state.trainingPlanId, LMSUtils.getCurrentNetworkId());
                    } else if(memberNonMember == 'non-member') {
                        // TO-DO: Helper classes set apex page messages -- Need to change the util, or catch the error when attempting to set page messages?
                        Opportunity opp = AS_HelperClass.TrainingPlanRegisterHelper(UserInfo.getUserId(), state.tPlan.trainingPlan.AS_Product__c, state.tPlan.trainingPlan.CampaignId__c);
                        
                        if(opp != null) {
                            PageReference ref = Page.PaymentPage;
                            ref.getParameters().put('oppId', opp.Id);
                            ref.getParameters().put('tPlanId', state.trainingPlanId);
                            state.redirectUrl = baseURL + '/s/sfdcpage/' + EncodingUtil.urlEncode(ref.getUrl(),'UTF-8');
                        } else {
                            state.userErrorMessage = 'A problem was encountered during opportunity creation. Please contact administrator.';
                        }
                    }
                }
                when 'Member Only (Paid)'{
                    System.debug('Member only (paid)');
                    if(memberNonMember == 'member') {
                        //Create new opportunity using helper class
                        // TO-DO: Helper classes set apex page messages -- Need to change the util, or catch the error when attempting to set page messages?
                        Opportunity opp = AS_HelperClass.TrainingPlanRegisterHelper(UserInfo.getUserId(), state.tPlan.trainingPlan.AS_Product__c, state.tPlan.trainingPlan.CampaignId__c);
                        if(opp != null) {
                            PageReference ref = Page.Paymentpage; //'/apex/Paymentpage'
                            ref.getParameters().put('oppId', opp.Id);
                            ref.getParameters().put('tPlanId', state.trainingPlanId);
                            state.redirectURL =  baseURL + '/s/sfdcpage/' + EncodingUtil.urlEncode(ref.getUrl(),'UTF-8');
                        } else {
                            state.userErrorMessage = 'A problem was encountered during opportunity creation. Please contact administrator.';
                        }
                    } else if(memberNonMember == 'non-member') {
                        ASPSASettings__c psaSettings = ASPSASettings__c.getOrgDefaults();
                        String theFullurl = (psaSettings.AsMembershipRegistrationURL__c!=null)?String.valueOf(psaSettings.AsMembershipRegistrationURL__c):'https://staging-staging-pharmaceuticalaus.cs6.force.com'; //staging url as default if no given data
                        state.userErrorMessage = 'Register error';
                    }
                }
                when 'Public'{
                    state.futureMethodCalled=true;
                    AsOpportunityTriggerHandler.myFutureMethod(new Set<Id>{UserInfo.getUserId()}, state.trainingPlanId, LMSUtils.getCurrentNetworkId());
                    System.debug('Public');
                }
                when else{
                    //Unable to find the training plan type
                    state.userErrorMessage = 'This training plan does not have a valid Type set. Please contact administrator.';
                }
            }
        }catch(Exception e){
            //Throw aura exception back to page
            System.debug('TrainingPlanPreviewController_Lightning ERROR: Trace: ' + e.getStackTraceString() + ' Cause: ' + e.getCause());
            throw new AuraHandledException('An error occurred while attempting to enrol: ' + e.getMessage());
        } 
        //Return updated state wrapper to handle on component side
        return state;
    }

      /**
     * Aura version of the TrainingPlanPreviewController method
     * Sets params and re-directs to the event enrol page
     * 
     * @author	Davanti:
     * @author	LToohey (Davanti),
     * @since	22/07/2020 
     * @date	22/07/2020 - LToohey (Davanti): created initial version
     * @return  pageStateWrapper 
     * @see     Course_Details.cmp
     */
    @AuraEnabled
    public static String eventEnrol(Id trainingPlanId) {
        String baseURL = URL.getSalesforceBaseUrl().toExternalForm(); //https://cpd-my-psa.cs73.force.com

        PageReference ref = Page.EventEnrol;
        ref.getParameters().put('id', trainingPlanId);
        ref.getParameters().put('netid', LMSUtils.getCurrentNetworkId());
        String redirectUrl = baseURL + '/s/sfdcpage/' + EncodingUtil.urlEncode(ref.getUrl(),'UTF-8');

        return redirectUrl;
    }

    /**
     * Aura version of createTrainingPlanBookmark
     * migrated from old vf page controller: TrainingPlanPreviewController
     * 
     * @author	Davanti:
     * @author	LToohey (Davanti),
     * @since	27/07/2020 
     * @date	27/07/2020 - LToohey (Davanti): created initial version
     * @see	
     */
    @AuraEnabled 
    public static pageStateWrapper createTrainingPlanBookmark(pageStateWrapper inputState){
        System.debug('Entered createTrainingPlanBookmark with state: ' + JSON.serializePretty(inputState));
        state = inputState;
        state.userErrorMessage=null;
        try{
            if ( AsTrainingPlanBookMark.isCreateTrainingPlanBookmark(  UserInfo.getUserId() , state.trainingPlanId ) ){
                state.isAlreadyInBookMark  = false ; 
            } else {
                state.userErrorMessage = 'You don\'t seem to have an active CPD Plan to add this course to. Please contact your administrator for assistance.';
            }
            System.debug('userErrorMessage ==>'+state.userErrorMessage);
        }catch(Exception e){
            system.debug('An error occurred in createTrainingPlanBookmark ' + e.getMessage() + ' trace ' + e.getStackTraceString());
            state.userErrorMessage = 'An unexpected error occurred. Please contact your adminstrator for assistance.' + e.getMessage();
        }
        return state; 
    }

    /**
     * Aura version of check_FutureJobComplete
     * migrated from old vf page controller: TrainingPlanPreviewController
     * 
     * @author	Davanti:
     * @author	LToohey(Davanti),
     * @since	28/07/2020 
     * @date	28/07/2020 - LToohey(Davanti): created initial version
     * @see	    
     */
    @AuraEnabled
    public static boolean check_futureJobComplete(String tplanId){
        Boolean jobComplete = false;
        String userId = UserInfo.getUserId();

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
                jobComplete = true;
            }
        }
        return jobComplete;
    } 

    /* 
        Return community URL from custom setting.
    */
    @AuraEnabled
    public static String getUrl(){
        String url;
        ASPSASettings__c psaSettings = ASPSASettings__c.getOrgDefaults();
        if(psaSettings.Internal_VF_URL__c != null) url = psaSettings.Internal_VF_URL__c;//domain + '--c.' + inst + '.visual.' + base.substringAfter('.');//base.substringBefore('.') 

        return url;
    }
    
    /* Class to maintain state between calls to/from component */
    public class pageStateWrapper{
        
        @AuraEnabled public TrainingPlan tPlan{get; set;}
        @AuraEnabled public String isGuest {get; set;}
        @AuraEnabled public String isEvent {get; set;}
        @AuraEnabled public String trainingPlanId {get; set;}
        @AuraEnabled public String trackType{get;set;}
        @AuraEnabled public String nonMember_memberBenefit {get;set;}
        @AuraEnabled public boolean isPreview {get;set;}
        @AuraEnabled public boolean isAlreadyInBookMark {get; set;}
        @AuraEnabled public boolean isApprovalRequired {get; set;}
        @AuraEnabled public boolean isMemberser {get;set;}
        @AuraEnabled public boolean canViewTrainPlan {get;set;}
        @AuraEnabled public boolean isvalidPlan {get;set;}
        //registerForTrainingPlan variables
        @AuraEnabled public String userErrorMessage{get;set;}
        @AuraEnabled public String redirectURL{get;set;}
        @AuraEnabled public String redirectExternalURL{get;set;}
        @AuraEnabled public boolean futureMethodCalled{get;set;}
        @AuraEnabled public boolean userEnrolled{get;set;}
        
        @AuraEnabled public Training_Plan_Access_Request__c dummyRequest{get;set;}
        @AuraEnabled public Training_Plan_Access_Request__c existingRequest{get;set;}

        @AuraEnabled public List<User> lUsersWithAchievement{get; set;}
        

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

        List<Training_Plan__c> tplans = [select id
                                            ,Enable_Self_Registration__c
                                            ,Self_Registration_Access__c,
                                            Available_for_Essential__c
                                            from Training_Plan__c where Id=:tId];
         
         return tplans;
                 
     }

}