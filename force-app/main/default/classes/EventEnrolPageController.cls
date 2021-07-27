public without sharing class EventEnrolPageController {
    
    @AuraEnabled
    public static learningRetrun getLearnings(String trainingplanId, String isTrack ){
        Set<String> learningId = new Set<String>();
        Set<String> learningIds = new Set<String>();
        Id recordTypeL = Schema.SObjectType.Learning__c.getRecordTypeInfosByName().get('Event').getRecordTypeId();

        List<Training_Plan_Section_Item__c> sectionItem;
        
        Map<Id, Id> learningTr = new Map<Id, Id>();
        Map<Id, Id> learningTrFinal = new Map<Id, Id>();
        
        if ( isTrack == null || isTrack == 'null' ) {
            sectionItem = [Select Id, Learning__c, Training_Plan_Section__r.Training_Plan__c From Training_Plan_Section_Item__c Where Training_Plan_Section__r.Training_Plan__c =: trainingplanId];
        } else {
            List<id> trainIds = (List<Id>) JSON.deserialize( trainingplanId, List<Id>.class );
            sectionItem = [Select Id, Learning__c, Training_Plan_Section__r.Training_Plan__c From Training_Plan_Section_Item__c Where Training_Plan_Section__r.Training_Plan__c IN : trainIds];
        }

        for(Training_Plan_Section_Item__c planSec : sectionItem){
            learningId.add(planSec.Learning__c);
            learningTr.put( planSec.Learning__c, planSec.Training_Plan_Section__r.Training_Plan__c );
        }
        Date dt = date.today();
        List<AS_Event__c> events = [SELECT Id, AS_Session_Campaign__r.Learning__c FROM AS_Event__c Where AS_Session_Campaign__r.Learning__c IN: learningId AND AS_Registration_End_Date__c >=: dt AND AS_Session_Campaign__r.AS_Include_in_Portal__c = true];
        for(AS_Event__c ev : events){
            learningIds.add(ev.AS_Session_Campaign__r.Learning__c);
            learningTrFinal.put( ev.AS_Session_Campaign__r.Learning__c, learningTr.get( ev.AS_Session_Campaign__r.Learning__c ) );
        }
        //return [Select Id, Name From Learning__c where Id IN: learningIds AND RecordTypeId =: recordTypeL];

        learningRetrun lr = new learningRetrun();
        lr.learning = [Select Id, Name From Learning__c where Id IN: learningIds AND RecordTypeId =: recordTypeL];
        lr.learningTrFinal = learningTrFinal;
        return lr;

       // else return null;
       // return [Select Id, Name From Learning__c where Id IN: learningId AND RecordTypeId =: recordTypeL];
    }
    @AuraEnabled
    public static List<Achievement__c> getIcon(String trainingplanId, String isTrack){
        Set<String> achId = new Set<String>();

        List<Training_Plan_Achievement__c> tpAchs; 
        if ( isTrack == null || isTrack == 'null' ) {
           tpAchs = [Select Achievement__c From Training_Plan_Achievement__c Where Training_Plan__c =: trainingplanId ORDER BY CreatedDate DESC LIMIT 1];
        } else {
            List<id> trainIds = (List<Id>) JSON.deserialize( trainingplanId, List<Id>.class );
            tpAchs = [Select Achievement__c From Training_Plan_Achievement__c Where Training_Plan__c IN : trainIds ORDER BY CreatedDate DESC LIMIT 1];
        }
        
        for(Training_Plan_Achievement__c tpAch : tpAchs){
            achId.add(tpAch.Achievement__c);
        }
        System.debug('achId'+achId);
        System.debug('Select Eligible_Image__c From Achievement__c WHERE Id IN: achId'+[Select Eligible_Image__c From Achievement__c WHERE Id IN: achId]);
        return [Select Eligible_Image__c From Achievement__c WHERE Id IN: achId];
    }
    @AuraEnabled
    public static Boolean getAccessType(String trainingplanId, String isTrack){
        Boolean view = true;

        List<Training_Plan__c> plans;

        if ( isTrack == null || isTrack == 'null' ) {
            plans = [Select Type__c From Training_Plan__c Where Id =: trainingplanId];
        } else {
            List<id> trainIds = (List<Id>) JSON.deserialize( trainingplanId, List<Id>.class );
            plans = [Select Type__c From Training_Plan__c Where Id IN : trainIds];
        }

        Set<String> customerUserTypes = new Set<String> {'Non Member Login User'};
        Profile UserprofileId = [SELECT Id FROM Profile WHERE Name in :customerUserTypes limit 1];
        if(plans[0].Type__c == 'Member Only (Free)' || plans[0].Type__c == 'Member Only (Paid)'){
            Id userId = UserInfo.getUserId();
            User usr = [SELECT Id, ProfileId FROM User WHERE Id =: userId LIMIT 1];
            if(usr.ProfileId == UserprofileId.Id) view = false;
        }
        return view;
    }
    @AuraEnabled
    public static Boolean isGuestUserAccess(){
        boolean guest=false;
        if(UserInfo.getUserType() == 'Guest'){
            guest=true;
        }
        return guest;
    }
    @AuraEnabled
    public static List<AS_Event__c> getEvnts(String trainingplanId, String isTrack){
        System.debug( 'sdffsfs' + trainingplanId );
        System.debug( 'sdffsfs' + isTrack );
        Set<String> learningId = new Set<String>();
        Id recordType = Schema.SObjectType.Learning__c.getRecordTypeInfosByName().get('Event').getRecordTypeId();

        List<Training_Plan_Section_Item__c> sectionItem;
        List<Campaign> camps;

        if ( isTrack == null || isTrack == 'null' ) {
            sectionItem = [Select Id, Learning__c, Learning__r.RecordTypeId, Training_Plan_Section__r.Training_Plan__c From Training_Plan_Section_Item__c Where Training_Plan_Section__r.Training_Plan__c =: trainingplanId];
            camps = [SELECT Id, ParentId, AS_Event__c FROM Campaign WHERE Training_Plan__c =: trainingplanId];// AND RecordTypeId =: recordType];
        } else {
            List<id> trainIds = (List<Id>) JSON.deserialize( trainingplanId, List<Id>.class );
            sectionItem = [Select Id, Learning__c, Learning__r.RecordTypeId, Training_Plan_Section__r.Training_Plan__c From Training_Plan_Section_Item__c Where Training_Plan_Section__r.Training_Plan__c IN : trainIds];
            camps = [SELECT Id, ParentId, AS_Event__c FROM Campaign WHERE Training_Plan__c IN : trainIds];// AND RecordTypeId =: recordType];
        }

        System.debug( 'sectionItem danryl' + sectionItem );
        System.debug( 'campaign danryl' + camps );
        for(Training_Plan_Section_Item__c planSec : sectionItem){
            if(planSec.Learning__r.RecordTypeId == recordType) learningId.add(planSec.Learning__c);
        }
        //List<AS_Event__c> events = [SELECT Id, Space_Remaining__c, AS_Total_Capacity__c, Name, AS_Start_Time__c, AS_Start_Date__c, AS_End_Time__c, AS_Location__c, AS_End_Date__c, AS_Session_Campaign__r.Learning__c, AS_Session_Campaign__r.Learning__r.Name FROM AS_Event__c Where AS_Session_Campaign__r.Learning__c =: learningId];
        Boolean parentCamp = false;
        Set<String> campIds = new Set<String>();
        Set<String> campId = new Set<String>();
        
        System.debug('camp.Id: '+trainingplanId);
        for(Campaign camp: camps){
            System.debug('camp.Id: '+camp.Id);
            if(camp.AS_Event__c != null) campIds.add(camp.Id);
            else{
                parentCamp = true;
                campId.add(camp.Id);
                System.debug('campId: '+campId);
            }
        }
        
        if(campId != null && parentCamp == true){
            List<Campaign> campaigns = [SELECT Id FROM Campaign WHERE ParentId In: campId];
            for(Campaign camp: campaigns){
                campIds.add(camp.Id);
                System.debug('campIds: '+campIds);
            }
        }  
        
        System.debug('campIds: '+campIds);
        System.debug('evnt: '+[SELECT Id, Name, AS_Session_Campaign__r.Start_Time_Text__c, AS_Session_Campaign__r.End_Time_Text__c, AS_Start_Time__c, AS_End_Time__c, AS_Location__c FROM AS_Event__c WHERE AS_Session_Campaign__c IN: campIds]);
        //Date dt = date.today();
        //return [SELECT Id, Space_Remaining__c, AS_Session_Campaign__r.Description, AS_Total_Capacity__c, Name, AS_Start_Time__c, AS_Start_Date__c, AS_End_Time__c, AS_Location__c, AS_End_Date__c FROM AS_Event__c WHERE AS_Session_Campaign__c IN: campIds AND AS_Registration_End_Date__c >=: dt AND AS_Session_Campaign__r.AS_Include_in_Portal__c = true];
        Date dt = date.today();
        return [SELECT Id, Space_Remaining__c, AS_Total_Capacity__c, Name, AS_Session_Campaign__r.Start_Time_Text__c, AS_Session_Campaign__r.End_Time_Text__c, AS_Start_Time__c, AS_Start_Date__c, AS_End_Time__c, AS_Location__c, AS_End_Date__c, AS_Session_Campaign__r.Learning__c FROM AS_Event__c Where AS_Session_Campaign__r.Learning__c In: learningId AND AS_Registration_End_Date__c >=: dt AND AS_Session_Campaign__r.AS_Include_in_Portal__c = true ORDER BY AS_Start_Date__c ASC];
    }
    @AuraEnabled
    public static List<AS_Event__c> getEvents(String trainingplanId, String learningId){
        /*Set<String> learningId = new Set<String>();
        List<Training_Plan_Section_Item__c> sectionItem = [Select Id, Learning__c, Training_Plan_Section__r.Training_Plan__c From Training_Plan_Section_Item__c Where Training_Plan_Section__r.Training_Plan__c =: trainingplanId];
        for(Training_Plan_Section_Item__c planSec : sectionItem){
            learningId.add(planSec.Learning__c);
        }*/
        //List<AS_Event__c> events = [SELECT Id, Space_Remaining__c, AS_Total_Capacity__c, Name, AS_Start_Time__c, AS_Start_Date__c, AS_End_Time__c, AS_Location__c, AS_End_Date__c, AS_Session_Campaign__r.Learning__c, AS_Session_Campaign__r.Learning__r.Name FROM AS_Event__c Where AS_Session_Campaign__r.Learning__c =: learningId];
        /*Boolean parentCamp = false;
        Set<String> campIds = new Set<String>();
        Set<String> campId = new Set<String>();
        Id recordType = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Event').getRecordTypeId();
        List<Campaign> camps = [SELECT Id, ParentId, AS_Event__c FROM Campaign WHERE Training_Plan__c =: trainingplanId];// AND RecordTypeId =: recordType];
        System.debug('camp.Id: '+trainingplanId);
        for(Campaign camp: camps){
            System.debug('camp.Id: '+camp.Id);
            if(camp.AS_Event__c != null) campIds.add(camp.Id);
            else{
                parentCamp = true;
                campId.add(camp.Id);
                System.debug('campId: '+campId);
            }
        }
        
        if(campId != null && parentCamp == true){
            List<Campaign> campaigns = [SELECT Id FROM Campaign WHERE ParentId In: campId];
            for(Campaign camp: campaigns){
                campIds.add(camp.Id);
                System.debug('campIds: '+campIds);
            }
        }  
        
        System.debug('campIds: '+campIds);
        System.debug('evnt: '+[SELECT Id, Name, AS_Start_Time__c, AS_End_Time__c, AS_Location__c FROM AS_Event__c WHERE AS_Session_Campaign__c IN: campIds]);*/
        
        //return null;//[SELECT Id, Space_Remaining__c, AS_Total_Capacity__c, Name, AS_Start_Time__c, AS_Start_Date__c, AS_End_Time__c, AS_Location__c, AS_End_Date__c FROM AS_Event__c WHERE AS_Session_Campaign__c IN: campIds];
        Date dt = date.today();
        System.debug('Query restult : ' +  [SELECT Id, Space_Remaining__c, AS_Total_Capacity__c, Name, AS_Session_Campaign__r.Start_Time_Text__c, AS_Session_Campaign__r.End_Time_Text__c, AS_Start_Time__c, AS_Start_Date__c, AS_End_Time__c, AS_Location__c, AS_End_Date__c, AS_Session_Campaign__r.Learning__c FROM AS_Event__c Where AS_Session_Campaign__r.Learning__c =: learningId AND AS_Registration_End_Date__c >=: dt AND AS_Session_Campaign__r.AS_Include_in_Portal__c = true ORDER BY AS_Start_Date__c ASC]);
        return [SELECT Id, Space_Remaining__c, AS_Total_Capacity__c, Name, AS_Session_Campaign__r.Start_Time_Text__c, AS_Session_Campaign__r.End_Time_Text__c, AS_Start_Time__c, AS_Start_Date__c, AS_End_Time__c, AS_Location__c, AS_End_Date__c, AS_Session_Campaign__r.Learning__c FROM AS_Event__c Where AS_Session_Campaign__r.Learning__c =: learningId AND AS_Registration_End_Date__c >=: dt AND AS_Session_Campaign__r.AS_Include_in_Portal__c = true ORDER BY AS_Start_Date__c ASC];
    }
    @AuraEnabled 
    public static PriceBookEntry getPrice(String trainingplanId){
        Id profileId = UserInfo.getProfileId();
        String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
        String rate = '';
        
        Set<String> prodId = new Set<String>();
        List<Training_Plan__c> tainingPlans = [SELECT Id, Name, AS_Product__c, Description__c, AS_Product__r.AS_Taxable_Rate__c FROM Training_Plan__c WHERE Id =: trainingplanId];
        for(Training_Plan__c tp : tainingPlans){
            prodId.add(tp.AS_Product__c);
            if(tp.AS_Product__r.AS_Taxable_Rate__c != null) rate = '.'+String.valueOf(tp.AS_Product__r.AS_Taxable_Rate__c);
        }
        if(!Test.isRunningTest()){
            PriceBookEntry price;
            if(profileName == 'Member Login User'){
                price = [Select Id, Product2Id, UnitPrice, Product2.AS_Taxable_Rate__c From PriceBookEntry Where Product2Id IN: prodId AND Pricebook2.Name = 'PSA Member'];
            }
            else if(profileName == 'Non Member Login User'){
                price = [Select Id, Product2Id, UnitPrice, Product2.AS_Taxable_Rate__c From PriceBookEntry Where Product2Id IN: prodId AND Pricebook2.Name = 'PSA Non-member'];
            }
            if(price.UnitPrice != null && rate != ''){
                rate = String.valueOf(price.UnitPrice*Decimal.valueOf(rate));
                price.UnitPrice = price.UnitPrice+Decimal.valueOf(rate);
            }
            if(price != null) return price;
            else return null;
        }
        else return null;
    }
    @AuraEnabled
    public static String getUrl(){
        /*String base = System.URL.getSalesforceBaseUrl().toExternalForm().substringAfter('.');
        String domain = System.URL.getOrgDomainUrl().toExternalForm().substringBefore('.');
    String inst = [SELECT InstanceName, Name, IsSandbox, OrganizationType FROM Organization].InstanceName;*/
        String url;
        ASPSASettings__c psaSettings = ASPSASettings__c.getOrgDefaults();
        if(psaSettings.Internal_VF_URL__c != null) url = psaSettings.Internal_VF_URL__c;//domain + '--c.' + inst + '.visual.' + base.substringAfter('.');//base.substringBefore('.') 
        
        //System.debug('*********************** ' + domain + '--c.' + base.substringBefore('.') + '.visual.' + base.substringAfter('.'));
        
        return url;
    }
    
    @AuraEnabled  
    public static Boolean getTrainingPlanType(String trainingplanId, String isTrack){
        Boolean free = true;
        List<Training_Plan__c> plans;
        if ( isTrack == null || isTrack == 'null' ) {
            plans = [Select Type__c From Training_Plan__c Where Id =: trainingplanId];
        } else {
            List<id> trainIds = (List<Id>) JSON.deserialize( trainingplanId, List<Id>.class );
            plans = [Select Type__c From Training_Plan__c Where Id IN : trainIds];
        }
        
        System.debug('tpanmsssss' + plans);
        
        if(plans[0].Type__c == 'Paid'){
            free = false;
        }
        return free;
    }
    
    @AuraEnabled  
    public static Training_Plan__c getTrainingPlan(String trainingplanId){
        //return [SELECT Id, Name, Type__c, Description__c, AS_Event__r.AS_Event__r.Name, AS_Event__r.AS_Event__r.AS_Start_Time__c, AS_Event__r.AS_Event__r.AS_End_Time__c, AS_Event__r.AS_Event__r.AS_Location__c, AS_Event__r.AS_Event__r.Id  FROM Training_Plan__c WHERE Id =: trainingplanId];
        return [SELECT Id, Name, Type__c, Description__c FROM Training_Plan__c WHERE Id =: trainingplanId];
    }
    @AuraEnabled  
    public static AS_Event__c getEvent(String evntId){
        return [SELECT Id, Name, AS_Session_Campaign__r.Start_Time_Text__c, AS_Session_Campaign__r.End_Time_Text__c, AS_Start_Time__c, AS_Start_Date__c, AS_End_Time__c, AS_Location__c, Space_Remaining__c, AS_Total_Capacity__c, AS_End_Date__c, AS_Session_Campaign__r.Description FROM AS_Event__c WHERE Id =: evntId];
    }
    @AuraEnabled  
    public static void passEvt(String tpId, String tpEvent, String trackId){
        AS_HelperClass.createAttendeeFromSession(tpId, tpEvent, trackId);
    }

    @AuraEnabled  
    public static Enrolment_Form__c createEnrolment( Id learning ) {
        
        Id recordTypeId = Schema.SObjectType.Enrolment_Form__c.getRecordTypeInfosByName().get('PSA Enrolment').getRecordTypeId();
        User theUser = [Select Id, AccountId,Account.PersonEmail,Contact.AccountId from User where Id =: userinfo.getuserId()];

        System.debug( 'recordTypeIdbroooo' + recordTypeId );
        System.debug( 'theUserbroooo' + theUser );
        System.debug('wetwwee'+ theUser.AccountId );

        Enrolment_Form__c enrollist = new Enrolment_Form__c();

        if ( Test.isRunningTest() ) {

            Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            Account Accnt = new Account(
                RecordTypeID=personAccountId,
                FirstName='Test FName',
                LastName='Test LName',
                PersonMailingStreet='test@alphasys.com.au',
                PersonMailingPostalCode='12345',
                PersonMailingCity='SFO',
                PersonEmail='test@alphasys.com.au',
                PersonHomePhone='1234567',
                PersonMobilePhone='12345678',
                AS_Unique_Student_Identifier__c='01234',
                AS_Has_Disability_Impairment_or_Long_Ter__pc = true,
                AS_BG_Speaks_Languages_Other_Than_Englis__pc = true,
                AS_disability_type__c = 'Hearing/deaf',
                AS_Other_Disability_pc__c = 'test sample'
            );
            
            insert Accnt;
            enrollist.AS_Account__c = Accnt.Id;
        } else {
            enrollist.AS_Account__c = theUser.AccountId;
        }

        enrollist.RecordTypeId = recordTypeId;        
        enrollist.AS_Learning_Package__c = learning;
        enrollist.AS_Email__c = theUser.Account.PersonEmail;
        // enrollist.AS_Enrolment_Type__c = trackTy.AS_Learning_Package__r.AS_Accreditation_level__c;
        enrollist.Enrolment_Status__c = 'Draft';
        insert  enrollist;
        

        return enrollist;
    }

    public class learningRetrun {
        @AuraEnabled public List<Learning__c> learning {get; set;}
        @AuraEnabled public Map<Id, Id> learningTrFinal {get; set;}
    }
}