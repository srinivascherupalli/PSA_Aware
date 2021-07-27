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
public with sharing class TrainingTrackDetailCtrl extends LMSBaseController {

    private String trackId {
        get;
        private set;
    }
    public transient Training_Track__c track {
        get;
        private set;
    }
    public transient List < TrainingTrackLevel > trackLevels {
        get;
        private set;
    }
    public Integer totalItems {
        get;
        private set;
    }
    public Integer totalCompleted { 
        get;
        private set;
    }
    public String TrackType {
        get;
        set;
    }

    //MLO
    public String redirectURL {
        get;
        set;
    }
    public String userErrorMessage {
        get;
        set;
    }
    public String isGuest {
        get;
        set;
    }

    //jrc
    public Training_Track__c trackTy {
        get;
        set;
    }
    /*Added object in ticket PRI-69*/
    public Enrolment_Form__c EnrolForm {
        get;
        set; 
    }
    public Id recordTypeId {
        get;
        set;
    }
      /*END Added object in ticket PRI-69*/
    public User trainTrackUser {
        get;
        set;
    }

    //john
    public boolean canViewTrainPlan = false; // for checking if user can view Training track detail
    public boolean isLogin {
        get;set;
    }
    public Boolean UserValidation_error {
        get;
        set;
    }
    public Boolean isEnrolledInTrack {
        get;
        set;
    }

    //Debug param
    public String dbg {
        get;
        set;
    }

    public List<Id> trainIds {get; set;}

    public TrainingTrackDetailCtrl() {
        trackId = ApexPages.currentPage().getParameters().get('id');
        init();
    }

    private void init() {

        dbg = ApexPages.currentPage().getParameters().get('dbg');

        isEnrolledInTrack = false;
        totalItems = 0;
        totalCompleted = 0;
        List < Training_Track__c > tracks = LMSService.getTrainingTracks('Active', trackId, LMSUtils.isPortalUser());

        // If we have access to the track header, proceed to fetch track item details
        if (tracks.size() > 0) {
            track = tracks.get(0);


            trackLevels = LMSWrappersService.getTrainingTrackLevels(LMSService.getTrainingTrackLevels(trackId, LMSUtils.isPortalUser()));
						System.debug('trackLevels : ' + trackLevels);
            //Fetch overall progress
            for (TrainingTrackLevel ttlevel: trackLevels) {
                for (TrainingTrackItem ti: ttlevel.trackItems) {
                    totalItems++;
                    if (ti.tplanAssignment != null & ti.tplanAssignment.Status__c == LMSConstants.TPLAN_STATUS_COMPLETED) {
                        totalCompleted++;
                    }

                    if (ti.trackItem.Training_Plan__r != null) {
                        ti.isExpired = !LMSService.isActiveTrainingPlan(ti.trackItem.Training_Plan__r);
                    }
                }
            }

        } else {
            LMSUtils.addErrorMessage(System.Label.ALMS_Training_Track_No_Access);
        }
				
        trainTrackUser = [SELECT AccountId FROM User WHERE Id =: UserInfo.getUserId()];

        //--->custom code<---
        trackTy = [select Id, Name, AS_Track_Type__c, AS_Code__c, Information__c, Product__c,AS_Learning_Package__c,AS_Learning_Package__r.AS_Accreditation_level__c,AS_Learning_Package__r.AS_product__c,AS_Learning_Package__r.AS_Event_selection__c from Training_Track__c where Id =: trackId];
        
        
        if (trackTy != null) {
            System.debug(' trackTy ==> ' + trackTy);
            if (trackTy.AS_Track_Type__c != null) TrackType = trackTy.AS_Track_Type__c;
        }
        
        if(trainTrackUser != null && trackTy != null) {
        	List<Training_Track_Account__c> oneTrainTrackAcc = [Select Id from Training_Track_Account__c where Training_Track__c = :trackTy.Id AND Account__c =: trainTrackUser.AccountId LIMIT 1];
        	if(oneTrainTrackAcc.size() > 0) {
        		isEnrolledInTrack = true;
        	}
        }
        
        if (AS_HelperClass.isUserMember(UserInfo.getUserId())) {
            canViewTrainPlan = true;
            isLogin = true;
        } else if (!AS_HelperClass.TrainingPlanPreviewValidation(UserInfo.getUserId())) {
            canViewTrainPlan = false;
            isLogin = false;
        }

        // coded by danryl (10/23/2019) - ticket #PRI-134
        List<Id> unitIds = new List<Id>();
        List<Id> tpIds = new List<Id>();
        List<Learning_Package_Unit__c> lpuList = [SELECT Id, AS_Unit__c FROM Learning_Package_Unit__c WHERE AS_Learning_Package__c =: trackTy.AS_Learning_Package__c];
        for( Learning_Package_Unit__c lpu : lpuList ) {
            unitIds.add( lpu.AS_Unit__c );
        }
 
        List<Unit__c> unitList = [SELECT Id, AS_Training_Plan__c, AS_Is_Event__c FROM Unit__c WHERE Id IN : unitIds ];
        for( Unit__c u : unitList ) {
            if ( u.AS_Is_Event__c == true ) {
                tpIds.add( u.AS_Training_Plan__c );
            }
        }
        trainIds = new List<Id>();
        trainIds.addAll( tpIds );
    }

    public PageReference purchase() {


        String memberNonMember; // possible values (member, non-member,null)
        if (canViewTrainPlan) {
            memberNonMember = 'member';
        } else if (!AS_HelperClass.TrainingPlanPreviewValidation(UserInfo.getUserId())) {
            memberNonMember = 'non-member';
        }

        System.debug('purchase training track');
        if (UserInfo.getUserType() == 'Guest') {
            isGuest = 'guest';
            userErrorMessage = 'Please create an account and log in.';

            String startUrl = System.currentPageReference().getParameters().get('startURL');
            PageReference ref = Network.forwardToAuthPage(startUrl);
            ref.setRedirect(true);
            redirectURL = ref.getUrl();
            return null;
        } else {
            if (trackTy.AS_Track_Type__c == 'Member Only (Free)') {
                System.debug('Member Only (Free) here');
                if (memberNonMember == 'member') {

                    Training_Track_Account__c trackAcc = new Training_Track_Account__c();
                    trackAcc.Account__c = trainTrackUser.AccountId;
                    trackAcc.AS_Approval_Status__c = 'Confirmed';
                    trackAcc.Training_Track__c = trackId;
                    insert trackAcc;
                    System.debug('Member Only (Free) trackAcc : ' + trackAcc);

                } else if (memberNonMember == 'non-member') {
                    System.debug('Member Only (Free) here 3');
                    ASPSASettings__c psaSettings = ASPSASettings__c.getOrgDefaults();
                    String theFullurl = (psaSettings.AsMembershipRegistrationURL__c != null) ? String.valueOf(psaSettings.AsMembershipRegistrationURL__c) : 'https://staging-staging-pharmaceuticalaus.cs6.force.com'; //staging url as default if no given data
                    isGuest = 'non-member';
                    userErrorMessage = 'In order to access this course, please sign up to become a PSA Member here (' + theFullurl + ')';
                    UserValidation_error = true;
                }
            } else if (trackTy.AS_Track_Type__c == 'Paid') {
                Opportunity opp = AS_HelperClass.TrainingPlanRegisterHelper(UserInfo.getUserId(), trackTy.Product__c, null);
                System.debug('Paid opp:' + opp);
                if (opp != null) {
                    PageReference ref = new PageReference('/apex/Paymentpage');
                    ref.getParameters().put('oppId', opp.Id);
                    ref.getParameters().put('trainTrackId', trackTy.Id);
                    System.debug('IS NOT RTO');
                    return ref; 
                } else {
                    isGuest = 'member';
                    userErrorMessage = 'A problem was encountered during opportunity creation. Please contact administrator.';
                    UserValidation_error = true; 
                    return null;
                }
            } else if (trackTy.AS_Track_Type__c == 'Diploma' || trackTy.AS_Track_Type__c == 'Intern Training Program' || trackTy.AS_Track_Type__c == 'Qualification') { // this is the RTO
                User theUser = [Select Id, AccountId,Account.PersonEmail,Contact.AccountId from User where Id =: userinfo.getuserId()];
                
                if (theUser.AccountId != null && trackTy.AS_Learning_Package__c !=null) {

                    try {

                        List<String> enrolStatus = new List<String>{ 'Cancelled/Withdrawn', 'Rejected', 'Expired' };

                        recordTypeId = Schema.SObjectType.Enrolment_Form__c.getRecordTypeInfosByName().get('PSA Enrolment').getRecordTypeId();
                        List<Enrolment_Form__c> enrolrecList = [SELECT Id,AS_Learning_Package__c,AS_Account__c,AS_Enrolment_Type__c,Enrolment_Status__c,CreatedDate,AS_Email__c FROM Enrolment_Form__c WHERE AS_Learning_Package__c =: trackTy.AS_Learning_Package__c AND AS_Account__c =: theUser.AccountId AND Enrolment_Status__c NOT IN : enrolStatus];
                        system.debug('enrolrecList==>'+enrolrecList);
                        system.debug('trackTy.AS_Learning_Package__c==>'+trackTy.AS_Learning_Package__c);
                        system.debug('enrolrecList==>'+theUser.AccountId);

                        if ( !enrolrecList.isEmpty() ) {

                            system.debug('not enter here');
                            String baseUrl=URL.getSalesforceBaseUrl().toExternalForm();
                            PageReference redirectPage = new PageReference(baseUrl+'/s/my-enrolments');
                            return redirectPage;

                        } else {

                            if ( trackTy.AS_Learning_Package__r.AS_Event_selection__c == true ) {

                                PageReference pr = Page.EventEnrol;
                                pr.getParameters().put( 'id', JSON.serialize( trainIds ) );
                                pr.getParameters().put( 'learning', trackTy.AS_Learning_Package__c );
                                pr.getParameters().put( 'trackId', trackTy.Id );
                                pr.getParameters().put( 'track', 'true' );
                                return pr;

                            } else {
                                // creation of enrolment

                                Enrolment_Form__c enrollist = new Enrolment_Form__c();
                                enrollist.RecordTypeId = recordTypeId;
                                enrollist.AS_Account__c = theUser.AccountId;
                                enrollist.AS_Learning_Package__c = trackTy.AS_Learning_Package__c;
                                enrollist.AS_Email__c = theUser.Account.PersonEmail;
                                enrollist.AS_Enrolment_Type__c = trackTy.AS_Learning_Package__r.AS_Accreditation_level__c;
                                enrollist.Enrolment_Status__c = 'Draft';
                                insert  enrollist;
                                
                                String baseUrl=URL.getSalesforceBaseUrl().toExternalForm();
                                PageReference redirectPage = new PageReference(baseUrl+'/s/enrolment-form');
                                redirectPage.getParameters().put('enrolid', enrollist.Id);
                                redirectPage.getParameters().put('accountid',theUser.AccountId);
                                //redirectPage.getParameters().put('lpid', trackTy.AS_Learning_Package__c);
                                return redirectPage;

                            }

                        }

                    } catch( Exception e ) {
                        System.debug( 'psaaaaaaaaa'+e );
                    }
                    
                    


                    // if (!enrolrecList.isEmpty()){
                        
                    //     for (Enrolment_Form__c enrolrec : enrolrecList) {
                            
                    //         if (enrolrec.Enrolment_Status__c == 'Cancelled/Withdrawn' || enrolrec.Enrolment_Status__c == 'Rejected' || enrolrec.Enrolment_Status__c == 'Expired'){
                    //             system.debug('enter here');
                    //             system.debug('trackTy.AS_Learning_Package__r.AS_Event_selection__c==> :' +trackTy.AS_Learning_Package__r.AS_Event_selection__c);
                                
                    //             if (trackTy.AS_Learning_Package__r.AS_Event_selection__c == true) {

                    //                 try {
 
                    //                     PageReference pr = Page.EventEnrol;
                    //                     pr.getParameters().put( 'id', JSON.serialize( trainIds ) );
                    //                     pr.getParameters().put( 'learning', trackTy.AS_Learning_Package__c );
                    //                     pr.getParameters().put( 'trackId', trackTy.Id );
                    //                     pr.getParameters().put( 'track', 'true' );
                    //                     // //if(Test.isRunningTest()) registerForTrainingPlan();
                    //                     System.debug('sssssss'+pr);
                    //                     return pr;
                    
                    //                 } catch ( Exception e ) {
                    //                     System.debug( 'weeeew' + e );
                    //                 }
 
                                   

                    //                 // system.debug('event wew' + String.join( trainIds, ',' ) );
                    //                 //not included in the functionality 
                    //                 /*Launch modal as per PSAMOPT-24  and PSAMOPT-37 
                    //                 To find the event sessions 
                    //                 look for all learning package units for the learning package where unit.isevent = TRUE then use the training plan of   that unit to follow collect the events sessions as per event enhancement functionality 
                    //                 MODAL FUNCTIONALITY WILL BE RE USE. 
                    //                 when the user selects an event it will pass to a modal confirmation page. After modal confirmation it will create the attendee record of the event selected as per existing events functionality
                    //                */
                                    
                    //                 /*Enrolment_Form__c newenrolSelectTrue = new Enrolment_Form__c();
                    //                 newenrolSelectTrue.RecordTypeId = recordTypeId;
                    //                 newenrolSelectTrue.AS_Account__c = theUser.AccountId;
                    //                 newenrolSelectTrue.AS_Learning_Package__c = trackTy.AS_Learning_Package__c;
                    //                 newenrolSelectTrue.AS_Email__c = theUser.Account.PersonEmail;
                    //                 newenrolSelectTrue.AS_Enrolment_Type__c = trackTy.AS_Learning_Package__r.AS_Accreditation_level__c;
                    //                 newenrolSelectTrue.Enrolment_Status__c = 'Draft';
                    //                 //MapenrolmentNew.put(newenrolSelectTrue.Id,newenrolSelectTrue);
                    //                 insert  newenrolSelectTrue;
                                    
                    //                 String baseUrl=URL.getSalesforceBaseUrl().toExternalForm();
                    //                 PageReference redirectPage = new PageReference(baseUrl+'/s/enrolment-form');
                    //                 redirectPage.getParameters().put('enrolid', newenrolSelectTrue.Id);
                    //                 redirectPage.getParameters().put('accountid',theUser.AccountId);
                    //                 //redirectPage.getParameters().put('lpid', trackTy.AS_Learning_Package__c);
                    //                 return redirectPage;*/
                                    
                    //             } else {
                                    
                    //                 system.debug('false');
                    //                 Enrolment_Form__c newenrolSelectFalse = new Enrolment_Form__c();
                    //                 newenrolSelectFalse.RecordTypeId = recordTypeId;
                    //                 newenrolSelectFalse.AS_Account__c = theUser.AccountId;
                    //                 newenrolSelectFalse.AS_Learning_Package__c = trackTy.AS_Learning_Package__c;
                    //                 newenrolSelectFalse.AS_Email__c = theUser.Account.PersonEmail;
                    //                 newenrolSelectFalse.AS_Enrolment_Type__c = trackTy.AS_Learning_Package__r.AS_Accreditation_level__c;
                    //                 newenrolSelectFalse.Enrolment_Status__c = 'Draft';
                    //                 insert  newenrolSelectFalse;
                                    
                    //                 String baseUrl=URL.getSalesforceBaseUrl().toExternalForm();
                    //                 PageReference redirectPage = new PageReference(baseUrl+'/s/enrolment-form');
                    //                 redirectPage.getParameters().put('enrolid', newenrolSelectFalse.Id);
                    //                 redirectPage.getParameters().put('accountid',theUser.AccountId);
                    //                 //redirectPage.getParameters().put('lpid', trackTy.AS_Learning_Package__c);
                    //                 return redirectPage;
                    //             }
                                
                    //         } else {
                                
                    //             system.debug('not enter here');
                    //             String baseUrl=URL.getSalesforceBaseUrl().toExternalForm();
                    //             PageReference redirectPage = new PageReference(baseUrl+'/s/my-enrolments');
                    //             return redirectPage;
                    //         }
                    //     }
                        
                    // } else {
                        
                    //         Enrolment_Form__c enrollist = new Enrolment_Form__c();
                    //         enrollist.RecordTypeId = recordTypeId;
                    //         enrollist.AS_Account__c = theUser.AccountId;
                    //         enrollist.AS_Learning_Package__c = trackTy.AS_Learning_Package__c;
                    //         enrollist.AS_Email__c = theUser.Account.PersonEmail;
                    //         enrollist.AS_Enrolment_Type__c = trackTy.AS_Learning_Package__r.AS_Accreditation_level__c;
                    //         enrollist.Enrolment_Status__c = 'Draft';
                    //         insert  enrollist;
                            
                    //         String baseUrl=URL.getSalesforceBaseUrl().toExternalForm();
                    //         PageReference redirectPage = new PageReference(baseUrl+'/s/enrolment-form');
                    //         redirectPage.getParameters().put('enrolid', enrollist.Id);
                    //         redirectPage.getParameters().put('accountid',theUser.AccountId);
                    //         //redirectPage.getParameters().put('lpid', trackTy.AS_Learning_Package__c);
                    //         return redirectPage;
                    // }
                    
                    
                    /*Added funtionality in ticket PRI - 69*///temporary commented for ticket PRI-134//
                    /*recordTypeId = Schema.SObjectType.Enrolment_Form__c.getRecordTypeInfosByName().get('PSA Enrolment').getRecordTypeId();
                    List<Enrolment_Form__c> enrolrecList = [SELECT Id,AS_Learning_Package__c,AS_Account__c,AS_Enrolment_Type__c,Enrolment_Status__c,CreatedDate FROM Enrolment_Form__c WHERE AS_Learning_Package__c =: trackTy.AS_Learning_Package__c AND AS_Account__c =: theUser.AccountId ORDER BY createdDate DESC];
                    system.debug('enrolrecList==>'+enrolrecList);
                    
                    
                    if (!enrolrecList.isEmpty()){
                        
                        DateTime dt;
                        Id enrolmentID;
                        
                        for (Enrolment_Form__c enrolrec : enrolrecList){
                        
                            if (enrolrec.Enrolment_Status__c !=null){
                                
                                if (dt == null){
                                    dt = enrolrec.CreatedDate;
                                    enrolmentID = enrolrec.Id;
                                }else{
                                    if(dt < enrolrec.CreatedDate){
                                        dt = enrolrec.CreatedDate;
                                        enrolmentID = enrolrec.Id;
                                    }
                                }
                                
                            } 
                        }
                        
                        String baseUrl=URL.getSalesforceBaseUrl().toExternalForm();
                        PageReference redirectPage = new PageReference(baseUrl+'/s/enrolment-form');
                        redirectPage.getParameters().put('enrolid', enrolmentID);
                        redirectPage.getParameters().put('accountid',theUser.AccountId);
                        redirectPage.getParameters().put('lpid', trackTy.AS_Learning_Package__c);
                        redirectPage.getParameters().put('lpprodid', trackTy.AS_Learning_Package__r.AS_product__c);
                        return redirectPage;
                        
                    } else {
                        
                        Enrolment_Form__c newenrol = new Enrolment_Form__c();
                        newenrol.RecordTypeId = recordTypeId;
                        newenrol.AS_Account__c = theUser.AccountId;
                        newenrol.AS_Learning_Package__c = trackTy.AS_Learning_Package__c;
                        newenrol.AS_Enrolment_Type__c = trackTy.AS_Learning_Package__r.AS_Accreditation_level__c;
                        newenrol.Enrolment_Status__c = 'Draft';
                        insert  newenrol;
                        
                        String baseUrl=URL.getSalesforceBaseUrl().toExternalForm();
                        PageReference redirectPage = new PageReference(baseUrl+'/s/enrolment-form');
                        redirectPage.getParameters().put('enrolid', newenrol.Id);
                        redirectPage.getParameters().put('accountid',theUser.AccountId);
                        redirectPage.getParameters().put('lpid', trackTy.AS_Learning_Package__c);
                        redirectPage.getParameters().put('lpprodid', trackTy.AS_Learning_Package__r.AS_product__c);
                        return redirectPage;
                    }*/
                    
                    /* END Added funtionality in ticket PRI - 69*/
                            
                    /*This is the old RTO PAGE in formAssembly temporary commented for new ticket PRI-69 functionality*/
                    /*PageReference ref = new PageReference('https://www.tfaforms.com/4692605'); //jrc : ticket PSA-218
                    ref.getParameters().put('trackid', trackId);
                    ref.getParameters().put('id', theUser.AccountId);
                    redirectURL = ref.getUrl();
                    System.debug('IS RTO');*/
                } else {
                    isGuest = 'non-member';
                    userErrorMessage = 'You cannot enroll to this kind of Training Plan. Your credential is not connected to any Account';
                    UserValidation_error = true;
                    system.debug('check===> '+ theUser );
                    system.debug('check===> '+ trackTy );
                }
                return null;
                
                
            } else if (trackTy.AS_Track_Type__c == 'Member Benefit') {
                if (memberNonMember == 'member') {
                    Training_Track_Account__c trackAcc = new Training_Track_Account__c();
                    trackAcc.Account__c = trainTrackUser.AccountId;
                    trackAcc.AS_Approval_Status__c = 'Confirmed';
                    trackAcc.Training_Track__c = trackId;
                    insert trackAcc;
                    System.debug('Member Benefit : ' + trackAcc);
                } else if (memberNonMember == 'non-member') {
                    Opportunity opp = AS_HelperClass.TrainingPlanRegisterHelper(UserInfo.getUserId(), trackTy.Product__c, null);
                    System.debug('Member Benefit opp:' + opp);
                    if (opp != null) {
                        PageReference ref = new PageReference('/apex/Paymentpage');
                        ref.getParameters().put('oppId', opp.Id);
                        ref.getParameters().put('trainTrackId', trackTy.Id);
                        System.debug('Member Benefit');
                        return ref;
                    } else {
                        isGuest = 'non-member';
                        userErrorMessage = 'A problem was encountered during opportunity creation. Please contact administrator.';
                        UserValidation_error = true;
                        return null;
                    }
                }
            } else if (trackTy.AS_Track_Type__c == 'Member Only (Paid)') {
                System.debug('Member Only (Paid) HERE');
                if (memberNonMember == 'member') {
                    Opportunity opp = AS_HelperClass.TrainingPlanRegisterHelper(UserInfo.getUserId(), trackTy.Product__c, null);
                    System.debug('Member Only (Paid):' + opp);
                    if (opp != null) {
                        PageReference ref = new PageReference('/apex/Paymentpage');
                        ref.getParameters().put('oppId', opp.Id);
                        ref.getParameters().put('trainTrackId', trackTy.Id);
                        System.debug('Member Only (Paid)');
                        return ref;
                    } else {
                        isGuest = 'non-member';
                        userErrorMessage = 'A problem was encountered during opportunity creation. Please contact administrator.';
                        UserValidation_error = true;
                        return null;
                    }
                } else if (memberNonMember == 'non-member') {
                    ASPSASettings__c psaSettings = ASPSASettings__c.getOrgDefaults();
                    String theFullurl = (psaSettings.AsMembershipRegistrationURL__c != null) ? String.valueOf(psaSettings.AsMembershipRegistrationURL__c) : 'https://staging-staging-pharmaceuticalaus.cs6.force.com'; //staging url as default if no given data
                    isGuest = 'non-member';
                    userErrorMessage = 'In order to access this course, please sign up to become a PSA Member here (' + theFullurl + ')';
                    System.debug('Error for Member Only (Paid) :' + userErrorMessage);
                    UserValidation_error = true;
                }
            } else if (trackTy.AS_Track_Type__c == 'Public'){
            		Training_Track_Account__c trackAcc = new Training_Track_Account__c();
		            trackAcc.Account__c = trainTrackUser.AccountId;
		            trackAcc.AS_Approval_Status__c = 'Confirmed';
		            trackAcc.Training_Track__c = trackId;
		            insert trackAcc;
		            System.debug('Public ' + trackAcc);
            }
        }
        PageReference oldPageReference = new PageReference('/apex/TrainingTrackDetail?Id='+trackId); // this is added for ticket (#PSA-307)
        return oldPageReference;
    }
}