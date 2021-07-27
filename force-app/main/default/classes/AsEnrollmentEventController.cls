/**
 * @author: Jet R. Compayan
 * @since: October 18, 2019
 */ 
public without sharing class AsEnrollmentEventController {
  
    @AuraEnabled 
    public static Object loadEvents( Id EnrollmentId ){

        map< Id, Learning_Package_Unit__c >  learningPackageUnitMap = new map< Id, Learning_Package_Unit__c >();

        // Query Enrollment Record by the Enrollment Id.
        List< Enrolment_Form__c > enrollmentList = [
            Select
                Id,
                AS_Account__r.Member__c, 
                AS_Learning_Package__c,
                Enrolment_Status__c,
                AS_Enrollment_State__c
            From
                Enrolment_Form__c
            WHERE
                Id =:EnrollmentId                
        ];
          
        set<Id> tPlanIdSet = new set<Id>();

        if( enrollmentList.size() != 0 ){

            Id learningPackageId = enrollmentList[0].AS_Learning_Package__c;

            //Query Learning Package Unit to the learning package Id
            for( Learning_Package_Unit__c learningPkgUnit : [
                Select 
                    Id,
                    AS_Learning_Package__c, 
                    AS_Unit__r.AS_Training_Plan__c,
                    AS_Unit__r.Name
                From 
                    Learning_Package_Unit__c
                Where
                    (
                        AS_Learning_Package__c =:learningPackageId AND
                        AS_Unit__r.AS_State__c =: null AND
                        AS_Unit__r.AS_Is_Event__c = true
                    )
                    OR 
                    ( 
                        AS_Learning_Package__c =:learningPackageId AND
                        AS_Unit__r.AS_State__c =:enrollmentList[0].AS_Enrollment_State__c AND
                        AS_Unit__r.AS_Is_Event__c = true
                    )
            ] ){
                  
                tPlanIdSet.add( learningPkgUnit.AS_Unit__r.AS_Training_Plan__c ); 
                learningPackageUnitMap.put( learningPkgUnit.AS_Unit__r.AS_Training_Plan__c , learningPkgUnit );
                 
            }
  
        }
 
        return getEvnts( tPlanIdSet , learningPackageUnitMap , enrollmentList[0].Enrolment_Status__c ); 
         
    }
    

    public static Object getEvnts(  set<Id> tPlanIdSet , map< Id, Learning_Package_Unit__c > learningPackageUnitMap , String enrollmentStatus   ){ 
        
        User usr = [SELECT Id, FirstName, LastName, ContactId FROM User WHERE Id =: UserInfo.getUserId()];

        map<String,Id> attendeeTPlanMap = new map<String,Id>();


        List<AS_Attendee__c> attsList = [
            Select 
                Id,
                AS_Event__c,
                AS_Event__r.AS_Session_Campaign__r.Learning__c,
                AS_Training_Plan__c
            From 
                AS_Attendee__c 
            Where  
                AS_User__c =: usr.ContactId AND 
                AS_Attendee_Last_Name__c =: usr.LastName AND
                AS_Attendee_First_Name__c =: usr.FirstName 
        ];

        for( AS_Attendee__c att : attsList ){ 

            if( att.AS_Training_Plan__c != null ){
  
                attendeeTPlanMap.put(  att.AS_Event__r.AS_Session_Campaign__r.Learning__c+''+att.AS_Event__c+''+att.AS_Training_Plan__c , att.Id );
 
            }
            
        }


        Set<String> learningId = new Set<String>();

        Id recordType = Schema.SObjectType.Learning__c.getRecordTypeInfosByName().get('Event').getRecordTypeId();

        List<Training_Plan_Section_Item__c> sectionItem = [
            Select  
                Id, 
                Learning__c, 
                Learning__r.RecordTypeId, 
                Training_Plan_Section__r.Training_Plan__c 
            From 
                Training_Plan_Section_Item__c 
            Where 
                Training_Plan_Section__r.Training_Plan__c In: tPlanIdSet
        ];
        
        for(Training_Plan_Section_Item__c planSec : sectionItem){
            if(planSec.Learning__r.RecordTypeId == recordType){
                learningId.add(planSec.Learning__c);
            }
        }

        Date dt = date.today();

        list< AS_Event__c > eventSessionList = [SELECT 
                    Id,
                    Space_Remaining__c,
                    AS_Total_Capacity__c,
                    Name,
                    AS_Start_Time__c,
                    AS_Start_Date__c,
                    AS_End_Time__c, 
                    AS_Location__c,
                    AS_End_Date__c,
                    AS_Registration_End_Date__c,
                    AS_Session_Campaign__r.Learning__c,
                    AS_Session_Campaign__r.Training_Plan__c
                FROM 
                    AS_Event__c  
                Where 
                    AS_Session_Campaign__r.Learning__c In: learningId 
                    AND 
                    AS_Session_Campaign__r.AS_Include_in_Portal__c = true 
                    AND
                    AS_Session_Campaign__r.Training_Plan__c IN:tPlanIdSet
                    AND
                    AS_Registration_End_Date__c >= TODAY
                    ORDER BY 
                    AS_Start_Date__c 
                    ASC];

 
        Map< Id , list< EventWrapper > > EventUnitLGroupByMap = new Map< Id , list< EventWrapper > >();

        for( AS_Event__c eventList :  eventSessionList ){

                        

            if( EventUnitLGroupByMap.containsKey( eventList.AS_Session_Campaign__r.Training_Plan__c ) ){

                list< EventWrapper > eventWrperList = EventUnitLGroupByMap.get( eventList.AS_Session_Campaign__r.Training_Plan__c );
                EventWrapper eventWrper = new EventWrapper();
                eventWrper.eventSession = eventList;
                eventWrper.isEnabled = ( enrollmentStatus != 'Draft' ? true : false ); 
                eventWrper.isAttened = attendeeTPlanMap.containsKey(eventList.AS_Session_Campaign__r.Learning__c+''+eventList.Id+''+eventList.AS_Session_Campaign__r.Training_Plan__c );
                eventWrper.AttenedId =  eventList.AS_Session_Campaign__r.Learning__c+''+eventList.Id+''+eventList.AS_Session_Campaign__r.Training_Plan__c;
                eventWrper.learningPackageUnit = learningPackageUnitMap.get( eventList.AS_Session_Campaign__r.Training_Plan__c );
                eventWrperList.add( eventWrper );
   
            } else {  

                list< EventWrapper > eventWrperList = new list< EventWrapper >();
                EventWrapper eventWrper = new EventWrapper();
                eventWrper.eventSession = eventList;
                eventWrper.isEnabled = ( enrollmentStatus != 'Draft' ? true : false ); 
                eventWrper.isAttened = attendeeTPlanMap.containsKey(eventList.AS_Session_Campaign__r.Learning__c+''+eventList.Id+''+eventList.AS_Session_Campaign__r.Training_Plan__c );
                eventWrper.AttenedId =  eventList.AS_Session_Campaign__r.Learning__c+''+eventList.Id+''+eventList.AS_Session_Campaign__r.Training_Plan__c;
                eventWrper.learningPackageUnit = learningPackageUnitMap.get( eventList.AS_Session_Campaign__r.Training_Plan__c );
                eventWrperList.add( eventWrper );

                EventUnitLGroupByMap.put( eventList.AS_Session_Campaign__r.Training_Plan__c , eventWrperList  );
 
            }
             
        } 
 
        return EventUnitLGroupByMap;
    } 

    public class EventWrapper{
        @AuraEnabled public AS_Event__c eventSession {get;set;}
        @AuraEnabled public Boolean isAttened {get;set;}
        @AuraEnabled public String AttenedId {get;set;} 
        @AuraEnabled public Boolean isEnabled {get;set;}
        @AuraEnabled public Learning_Package_Unit__c learningPackageUnit {get;set;}
    }

 
    @AuraEnabled 
    public static void createAttendeeFromSession( Map<String, Object> params , Id enrolId, Boolean sendmelink ){

        // Updated Juniel PRI-198
        Enrolment_Form__c enrol = new Enrolment_Form__c();
        enrol.Id = enrolId;
        enrol.AS_Saved_Enrolment_Form__c = true;
        enrol.AS_Enrolment_Stage__c = 'Page 10: Event Selection';
        enrol.AS_Enrollment_Last_Modify_Date__c = Date.today();
        if( sendmelink ) enrol.AS_Send_enrollment_link__c = true;
        update enrol;
        // end PRI-198

        User usr = [SELECT Id, FirstName, LastName, ContactId FROM User WHERE Id =: UserInfo.getUserId()];

        map<String,Id> attendeeTPlanMap = new map<String,Id>();


        List<AS_Attendee__c> attsList = [
            Select 
                Id,
                AS_Event__c,
                AS_Training_Plan__c,
                AS_Event__r.AS_Session_Campaign__r.Learning__c,
                AS_Event__r.AS_Session_Campaign__r.Training_Plan__c
            From 
                AS_Attendee__c 
            Where  
                AS_User__c =: usr.ContactId AND 
                AS_Attendee_Last_Name__c =: usr.LastName AND
                AS_Attendee_First_Name__c =: usr.FirstName 
        ];

        for( AS_Attendee__c att : attsList ){

            if( att.AS_Training_Plan__c != null ){

                system.debug('keys => Learning: '+att.AS_Event__r.AS_Session_Campaign__r.Learning__c+' Event: '+att.AS_Event__c+' TPlan:'+att.AS_Training_Plan__c);
                attendeeTPlanMap.put(  att.AS_Event__r.AS_Session_Campaign__r.Learning__c+''+att.AS_Training_Plan__c , att.Id );
 
    
            }
            
        }


        list< AS_Attendee__c > attnList = new list< AS_Attendee__c >();
        
        set<Id> tPlanIdSet = new set<Id>();
        set<Id> eventIdSet = new set<Id>();
 
        for( String key : params.keySet() ){ 

            eventIdSet.add( key );
            tPlanIdSet.add( string.valueof( params.get( key ) ) );
 
        }


        list< AS_Event__c > eventSessionList = [SELECT 
                    Id,
                    Space_Remaining__c,
                    AS_Total_Capacity__c,
                    Name,
                    AS_Start_Time__c,
                    AS_Start_Date__c,
                    AS_End_Time__c, 
                    AS_Location__c,
                    AS_End_Date__c,
                    AS_Session_Campaign__r.Learning__c,
                    AS_Session_Campaign__r.Training_Plan__c 
                FROM 
                    AS_Event__c  
                Where 
                    Id In:eventIdSet
                    AND 
                    AS_Session_Campaign__r.Training_Plan__c In:tPlanIdSet];

        Map<Id,AS_Event__c> eventSessionMapById = new   Map<Id,AS_Event__c>();       

        for( AS_Event__c eventList :  eventSessionList ){

            eventSessionMapById.put( eventList.Id , eventList );

        }

        for( String key : params.keySet() ){ 

            AS_Event__c eventList = eventSessionMapById.get( key );

            system.debug( 'eventList==>'+eventList );
 
            system.debug(' Map Id=> Learning: '+ eventList.AS_Session_Campaign__r.Learning__c+' Event: '+eventList.Id+' tplanId: '+eventList.AS_Session_Campaign__r.Training_Plan__c);

            if( attendeeTPlanMap.containsKey( eventList.AS_Session_Campaign__r.Learning__c+''+eventList.AS_Session_Campaign__r.Training_Plan__c ) ){
                
                AS_Attendee__c attendee = new AS_Attendee__c(
                    Id = attendeeTPlanMap.get( eventList.AS_Session_Campaign__r.Learning__c+''+eventList.AS_Session_Campaign__r.Training_Plan__c ),
                    AS_Event__c =  key
                ); 

                attnList.add( attendee ); 
 
            } else {

                AS_Attendee__c attendee = new AS_Attendee__c(
                    AS_Attendee_First_Name__c = usr.FirstName,
                    AS_Attendee_Last_Name__c = usr.LastName, 
                    AS_Status__c = 'Registered',
                    AS_User__c = usr.ContactId,
                    AS_Training_Plan__c =  string.valueof( params.get( key ) ),
                    AS_Agrees_to_terms_and_conditions__c = true,
                    AS_Event__c =  key
                );

                attnList.add( attendee );

            }


        }

        if( attnList.size() != 0 ){

            upsert attnList;
            system.debug( 'attnList==>'+attnList );
            saveChanges( enrolId , sendmelink );

        } 

 


 
      //List<AS_Attendee__c> atts = [Select Id From AS_Attendee__c Where AS_User__c =: usr.ContactId AND AS_Training_Plan__c =: tpId AND AS_Attendee_Last_Name__c =: usr.LastName AND AS_Attendee_First_Name__c =: usr.FirstName AND AS_Event__c =: tpEvent];
 

    }

    public static boolean saveChanges( Id enrolId, Boolean sendmelink ){

        Boolean returnStatus = false; 

        try { 

            Enrolment_Form__c enrol = new Enrolment_Form__c(); 
            enrol.Id = enrolId;
            enrol.AS_Saved_Enrolment_Form__c = true;
            enrol.AS_Enrolment_Stage__c = 'Page 10: Event Page';
            enrol.AS_Enrollment_Last_Modify_Date__c = Datetime.now();
            if( sendmelink ) enrol.AS_Send_enrollment_link__c = true; 
            update enrol;
 
            returnStatus = true;

        }catch( Exception er ){ 

            returnStatus = false; 

        }

        return returnStatus;
    }

    /**
     * callback handler for cancel button (delete enrolment record)
     *
     * @param enrolId enrolment id to be deleted
     */
    @AuraEnabled 
    public static String deleteEnrolment( Id enrolId ) {

        String message = '';

        List<Enrolment_Form__c> deleteEnrol = new List<Enrolment_Form__c>();

        if( enrolId != null ) {
            List<Enrolment_Form__c> getEnrolInfo = [SELECT Id FROM Enrolment_Form__c 
                                                    WHERE Id =: enrolId AND Enrolment_Status__c = 'Draft'];

            if ( !getEnrolInfo.isEmpty() ) {
                deleteEnrol.addAll( getEnrolInfo );
            }
 
        }

        if ( !deleteEnrol.isEmpty() ) {

            delete deleteEnrol;
            message = 'Enrolment sucessfully deleted!';
        } else {
            message = 'No record to be deleted!';
        }

        return message;
    }


}