/**
 * @details            : AsCoreAndElectiveUnitsClass.cls
 * @details            : Class controller for the component AsCoreAndElectiveUnit
 * @author             : Juliver Anoos
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 11/18/2019, 10:06:48 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    9/5/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
 **/
public without sharing class AsCoreAndElectiveUnitsClass {
 
    // @AuraEnabled
    // public static map < String, Object > getPackage(Id userId) {
  
    //     Id EnroLLmentId = 'a1i9D0000001TsC';
    //     Id accId = '0019D000005AFyB';
    //     // Add method Types
        
        
    //     return initLoadUsersEnrollment(accId, EnroLLmentId);
        
    // }

    @AuraEnabled
    /**
    * @description Load Learning Package Units of the current Learning Package of an account in the component
    * @author Juliver Anoos | 9/11/2019 
    * @param accId 
    * @param EnroLLmentId 
    * @return map<String, Object> 
    **/
    public static map < String, Object > initLoadUsersEnrollment(Id accId, Id EnroLLmentId) {
        
        //Learning Package Id
        Set < Id > LPIDs = new Set < Id > ();
        //return map value
        Map < String, Object > mapReturn = new Map < String, Object > ();
       
        //get current enroLLment to get the Learning package id
        List < Enrolment_Form__c > getEnroLLments = [SELECT Id 
                                                     		,AS_Account__c
                                                     		,AS_Enrollment_State__c
                                                            ,Enrolment_Status__c
                                                     		,AS_Account__r.Id
                                                     		,AS_Learning_Package__c
                                                     		,AS_Learning_Package__r.Id
                                                     		,AS_Learning_Package__r.Name
                                                     		,AS_Learning_Package__r.AS_Number_Electives__c
                                                     FROM Enrolment_Form__c
                                                     WHERE AS_Account__c =: accId
                                                     AND Id =: EnroLLmentId
                                                    ];
            //get enrolment state
            String enrState;
            //put Learning package id to a map aLong with the state
            for (Enrolment_Form__c getLPID: getEnroLLments) {
                
                Id LPID = getLPID.AS_Learning_Package__r.Id;
                LPIDs.add(LPID);

                if (getLPID.AS_Enrollment_State__c != null){
                    enrState = getLPID.AS_Enrollment_State__c;
                }
                
                AsCoreElectiveClassWrapper getEnrollState = new AsCoreElectiveClassWrapper();
                getEnrollState.enroLLmentState = getLPID.AS_Enrollment_State__c;
                getEnrollState.enroLLmentStatus = getLPID.Enrolment_Status__c;
                mapReturn.put('enroLLmentStates', getEnrollState);
            }
            system.debug('Enr State: ' +enrState);
        //get Learning Package Name and Number of electives
        List < Learning_Package__c > getLPackage = [SELECT Id
                                                    	  ,Name
                                                    	  ,AS_Number_Electives__c
                                                    FROM Learning_Package__c
                                                    WHERE Id =: LPIDs
                                                   ];
            //put Learning package id, Name and Number of electives to a map, return value
            for (Learning_Package__c getLPackageList: getLPackage) {
                AsCoreElectiveClassWrapper enroLLsWrapper = new AsCoreElectiveClassWrapper();
                if (getLPackage[0].AS_Number_Electives__c == null) {
                    enroLLsWrapper.numberOfElectives = 0;
                } else {
                    enroLLsWrapper.numberOfElectives = Integer.ValueOf(getLPackage[0].AS_Number_Electives__c);
                }
                
                enroLLsWrapper.LPName = getLPackageList.Name;
                enroLLsWrapper.LPId = getLPackageList.Id;
                enroLLsWrapper.enrolledId = EnroLLmentId;
                
                mapReturn.put('learningPackageDetails', enroLLsWrapper);
            }
        //initiate recordType IDs for core and elective
        Id coreRecType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Core'].Id;
        Id electiveRecType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Elective'].Id;
        
        //get LPUnits  where recordtypeid is elective, this is to be used on the js controller to check current enrolled units
        Set < Id > eLectiveUnitsIDs = new Set < Id > (); 
        //Package Unit Elective Identifier
        Map < Id, Boolean > PackageUnitMapElectiveIdentifier = new Map < Id, Boolean > ();
        //query Learning package units of the current Learning package where recordtypeid is elective
        List < Learning_Package_Unit__c > getLPUPackList = [SELECT Id
                                                            	,RecordTypeId
                                                            	,AS_Unit__c
                                                            	,AS_Unit__r.Id
                                                            	,RecordType.Name
                                                            	,AS_Learning_Package__c
                                                            FROM Learning_Package_Unit__c
                                                            WHERE AS_Learning_Package__c =: LPIDs
                                                            AND RecordTypeId =: electiveRecType
                                                           ];
        system.debug('LPU Electives ' + getLPUPackList.size());
        
            //put unit ids that are elective to be used in js controller
            for (Learning_Package_Unit__c getElectTypes: getLPUPackList) {
                
                Boolean isElective = false;
                if (getElectTypes.RecordType.Name == 'Elective') {
                    isElective = true;
                }
                
                PackageUnitMapElectiveIdentifier.put(getElectTypes.AS_Unit__c, isElective);
                eLectiveUnitsIDs.add(getElectTypes.AS_Unit__c);
             }

        //get all enrolled units where recordtype are electives
        List < AS_Enrolled_Unit__c > enroLLedElectives = [SELECT Id, AS_Unit__c
                                                          FROM AS_Enrolled_Unit__c
                                                          WHERE AS_Unit__c =: eLectiveUnitsIDs
                                                          AND AS_Enrolment__c =: EnroLLmentId
                                                          AND AS_Enrolment__r.AS_Learning_Package__r.Id =: LPIDs
                                                         ];
        
        system.debug('enrolled electives ' + enroLLedElectives.size());
        
        	//initiate a default value 0 if size is 0 to avoid getting a NaN value
            mapReturn.put('enrolledNoOfUnits', 0);
            //get the size of enrolled units where recordtypeid is elective of the current account if size > 0
            if (enroLLedElectives.size() > 0) { 
                mapReturn.put('enrolledNoOfUnits',  enroLLedElectives.size());
            }
        
        system.debug('enrolled No OfUnits ' + mapReturn);
        
        //query enrolled unit list regardless of its recordTypeId
        List < AS_Enrolled_Unit__c > enroLLedUnits = [SELECT Id
                                                      		,Name
                                                      		,AS_Unit__c
                                                      		,AS_Unit__r.Id
                                                      		,AS_Enrolment__c
                                                      		,AS_Enrolment__r.AS_Learning_Package__r.Id
                                                      		,AS_Unit__r.AS_Training_Plan__c
                                                      		,AS_Unit__r.AS_Vettrak_Unit_ID__c
                                                      		,AS_Unit__r.Name,AS_Unit__r.AS_State__c
                                                      		,AS_Unit__r.AS_Training_Plan__r.Id
                                                      		,AS_Unit__r.AS_Training_Plan__r.Description__c
                                                      		,AS_Status__c
                                                      		,AS_Result__c
                                                      FROM AS_Enrolled_Unit__c
                                                      WHERE AS_Enrolment__c =: EnroLLmentId
                                                      AND AS_Enrolment__r.AS_Learning_Package__r.Id =: LPIDs
                                                     ];
        //get enrolledUnits and put to a map, mapReturn => return value
        List < AsCoreElectiveClassWrapper > getenroLLedListWrap = new List < AsCoreElectiveClassWrapper >();
            for (AS_Enrolled_Unit__c getEnrolledUnitsList: enroLLedUnits) {
                AsCoreElectiveClassWrapper enroLLUnitsWrapper = new AsCoreElectiveClassWrapper();
                enroLLUnitsWrapper.enrolledUnitId = getEnrolledUnitsList.Id;
                enroLLUnitsWrapper.isElective = PackageUnitMapElectiveIdentifier.get(getEnrolledUnitsList.AS_Unit__c);
                enroLLUnitsWrapper.enrolledUnitgetUnitId = getEnrolledUnitsList.AS_Unit__c; 
                //enroLLUnitsWrapper.enrolledId = getEnrolledUnitsList.AS_Enrolment__c ;
                enroLLUnitsWrapper.enrolledUnitName = getEnrolledUnitsList.AS_Unit__r.Name;
                enroLLUnitsWrapper.enrolledUnitDescription = getEnrolledUnitsList.AS_Unit__r.AS_Training_Plan__r.Description__c;
                
                getenroLLedListWrap.add(enroLLUnitsWrapper);
            }
            mapReturn.put('enroLLedUnitList', getenroLLedListWrap);

        //get List of  Learning package unit    
        list < AsCoreElectiveClassWrapper > returnList = new list < AsCoreElectiveClassWrapper > ();
        List < Learning_Package_Unit__c > getLPackageUnitList = [SELECT Id
                                                                 		,RecordTypeId
                                                                 		,Name
                                                                 		,AS_Order__c
                                                                 		,AS_Unit__c
                                                                 		,AS_Learning_Package__c
                                                                 		,AS_Learning_Package__r.Id
                                                                 		,AS_Learning_Package__r.Name
                                                                 		,AS_Learning_Package__r.AS_Number_Electives__c
                                                                 		,AS_Unit__r.Id
                                                                 		,AS_Unit__r.Name
                                                                 		,AS_Unit__r.AS_Training_Plan__c
                                                                 		,AS_Unit__r.AS_Vettrak_Unit_ID__c
                                                                 		,AS_Unit__r.AS_State__c
                                                                 		,AS_Unit__r.AS_Training_Plan__r.Id
                                                                 		,AS_Unit__r.AS_Training_Plan__r.Description__c
                                                                 		,AS_Unit__r.AS_Training_Plan__r.Name
                                                                        ,AS_Unit__r.AS_Training_Plan__r.ASCourse_Code__c
                                                                 FROM Learning_Package_Unit__c
                                                                 WHERE AS_Learning_Package__c =: LPIDs
                                                                 AND (AS_Unit__r.AS_State__c =: enrState
                                                                 OR AS_Unit__r.AS_State__c = null)
                                                                 ORDER BY AS_Order__c ASC
                                                                ];
        	system.debug('LPUnits by state: '+getLPackageUnitList);
            /**
             * @details get queried Learning package unit of the current Learning package
             * @return   return This will get all learning package units to be displayed in the component
             */ 
            for (Learning_Package_Unit__c getLPUnits: getLPackageUnitList) {
                system.debug('LPUnits for loop by state: '+getLPUnits.AS_Unit__r.AS_State__c);
                AsCoreElectiveClassWrapper LPUnitsWrapper = new AsCoreElectiveClassWrapper();
                
                LPUnitsWrapper.UnitState = getLPUnits.AS_Unit__r.AS_State__c;
                LPUnitsWrapper.OrderNo = getLPUnits.AS_Order__c;
                LPUnitsWrapper.recTypeId = getLPUnits.RecordTypeId;
                
                //to identify Learning package unit, use in aura:if to separate 2 different recordType of Learning Package Unit 
                if (getLPUnits.RecordTypeId == coreRecType) {
                    LPUnitsWrapper.core = getLPUnits.RecordTypeId;
                } else if (getLPUnits.RecordTypeId == electiveRecType) {
                    LPUnitsWrapper.eLec = getLPUnits.RecordTypeId;
                }
                
                LPUnitsWrapper.LPUName = getLPUnits.AS_Unit__r.Name;
                LPUnitsWrapper.LPUId = getLPUnits.AS_Unit__c;
                LPUnitsWrapper.LPUTPDescription = getLPUnits.AS_Unit__r.AS_Training_Plan__r.Description__c;
                //enhancement added by iver
                LPUnitsWrapper.AsCourseCode = getLPUnits.AS_Unit__r.AS_Training_Plan__r.ASCourse_Code__c;
                //LPUnitsWrapper.enrolledId = EnroLLmentId;
                returnList.add(LPUnitsWrapper);
                
             }
        	 mapReturn.put('learningPackageUnitList', returnList);
        //return mapped values
        return mapReturn;
    }


     @AuraEnabled
     /**
     * @details This method is for deleting old records and create new enrolled unit (Elective and Core) records for the current enrollment.
     * @author Juliver ANoos | 9/11/2019 
     * @param selectedUnitIdMap These are IDs of the selected elective units from the component
     * @param EnrollmentId EnrollmentId to be managed
     * @param acctId Account Id of the current user
     * @return void 
     **/
     public static void createEnrollmenUnits(Map < Id, Boolean > selectedUnitIdMap, Id EnrollmentId, Id acctId, Boolean sendMeLink) {
        
        //use to hold the set of Unit IDs
        set < Id > unitIdSet = new set < Id > ();

        //to get the learning package of the current enrollment
        Enrolment_Form__c getEnroLLments = [SELECT Id
                                                  ,AS_Account__c
                                                  ,AS_Enrollment_State__c
                                                  ,AS_Account__r.Id
                                                  ,AS_Learning_Package__c
                                                  ,AS_Learning_Package__r.Id
                                                  ,AS_Learning_Package__r.Name
                                                  ,AS_Learning_Package__r.AS_Number_Electives__c
                                           FROM Enrolment_Form__c
                                           WHERE AS_Account__c =: acctId
                                           AND Id =: EnrollmentId
                                          ];
        
        String enrState = getEnroLLments.AS_Enrollment_State__c;
        //update enrollment fields
        Enrolment_Form__c updateEnrollment = new Enrolment_Form__c();

        if ( sendMeLink == true ) {

            updateEnrollment.Id = getEnroLLments.Id;
            updateEnrollment.AS_Saved_Enrolment_Form__c = true;
            updateEnrollment.AS_Enrollment_Last_Modify_Date__c = Date.today();
            updateEnrollment.AS_Enrolment_Stage__c = 'Page 9: Elective selection and unit confirmation';

        } else {        
            
            updateEnrollment.Id = getEnroLLments.Id;
            updateEnrollment.AS_Saved_Enrolment_Form__c = true;
            updateEnrollment.AS_Enrollment_Last_Modify_Date__c = Date.today();
            updateEnrollment.AS_Send_enrollment_link__c = true;
            updateEnrollment.AS_Enrolment_Stage__c = 'Page 9: Elective selection and unit confirmation';
        }
        update updateEnrollment;
    
        //get id for core recordtype
        Id coreRecType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Core'].Id;
        //get Learning package units that recordtypes are core and state = enrolment.state
        List < Learning_Package_Unit__c > getLPUCores = [SELECT Id
                                                                ,RecordTypeId
                                                                ,AS_Unit__c
                                                                ,AS_Learning_Package__c
                                                                ,AS_Learning_Package__r.Id
                                                                ,AS_Unit__r.Id
                                                        FROM Learning_Package_Unit__c
                                                        WHERE AS_Learning_Package__c =: getEnroLLments.AS_Learning_Package__r.Id
                                                        AND RecordTypeId =: coreRecType
                                                        AND (AS_Unit__r.AS_State__c =: enrState
                                                        OR AS_Unit__r.AS_State__c = null) 
                                                        ];
        System.debug('LearningPackageUnits' + getLPUCores);

                //if size is greater than 0, add unit id to the set Id holder
                if (getLPUCores.size() > 0) {
                
                    for (Learning_Package_Unit__c getUnitCoreIDs: getLPUCores) {
                        
                            unitIdSet.add(getUnitCoreIDs.AS_Unit__r.Id);
                        
                    }
                }
        
        //get enrolled units from the current enrollment and delete all enrolled records
        List < AS_Enrolled_Unit__c > enroLLedUnitList = [SELECT Id
                                                            ,Name
                                                            ,AS_Unit__c
                                                            ,AS_Unit__r.Id
                                                            ,AS_Enrolment__c
                                                            ,AS_Enrolment__r.AS_Learning_Package__r.Id
                                                            ,AS_Unit__r.AS_Training_Plan__c
                                                            ,AS_Unit__r.AS_Vettrak_Unit_ID__c
                                                            ,AS_Unit__r.Name
                                                            ,AS_Unit__r.AS_State__c
                                                            ,AS_Unit__r.AS_Training_Plan__r.Id
                                                            ,AS_Unit__r.AS_Training_Plan__r.Description__c
                                                            ,AS_Status__c
                                                            ,AS_Result__c
                                                        FROM AS_Enrolled_Unit__c
                                                        WHERE AS_Enrolment__c =: EnrollmentId
                                                        //AND AS_Enrolment__r.AS_Learning_Package__r.Id =: getEnroLLments.AS_Learning_Package__r.Id
                                                        ];
        
        System.debug('enrolled LP Units' + enroLLedUnitList);
                //if there are old enrolled units, delete these
                if ( enroLLedUnitList.size() > 0 ) {
                    
                    delete enroLLedUnitList;
                }
                System.debug('DELETED Enrolled' + enroLLedUnitList);
                //if there are selected units, these will get the Ids for a new creation of enrolled units,
                for (Id keyUnitId: selectedUnitIdMap.keySet()) {
                    
                    if (selectedUnitIdMap.get(keyUnitId)) {
                            unitIdSet.add(keyUnitId);
                    }
                }
                System.debug('UnitIDs to be created for enrollment ' + unitIdSet);
        
        //get Learning package units where Unit Ids are in <unitIdSet>
        List < Learning_Package_Unit__c > getUnitsToEnroll = [SELECT Id
                                                                    ,AS_Learning_Package__c
                                                                    ,AS_Learning_Package__r.Id
                                                                    ,AS_Learning_Package__r.Name
                                                                    ,AS_Learning_Package__r.AS_Number_Electives__c
                                                                    ,AS_Unit__c
                                                                    ,AS_Unit__r.Id
                                                                    ,AS_Unit__r.AS_Training_Plan__c
                                                                    ,AS_Unit__r.AS_Vettrak_Unit_ID__c
                                                                    ,AS_Unit__r.Name
                                                                    ,AS_Unit__r.AS_State__c
                                                                    ,AS_Unit__r.AS_Training_Plan__r.Id
                                                                    ,AS_Unit__r.AS_Training_Plan__r.Description__c
                                                            FROM Learning_Package_Unit__c
                                                            WHERE 
                                                                AS_Unit__r.Id IN: unitIdSet
                                                            AND
                                                                AS_Learning_Package__c =:getEnroLLments.AS_Learning_Package__r.Id
                                                            ];
        
        System.debug('Units Details to be enrolled ' + getUnitsToEnroll);

        //get queried Learning package unit details and use them to create enrolled unit records for the current enrollment ID of the current Account
        List < AS_Enrolled_Unit__c > newUnitsToEnroll = new List < AS_Enrolled_Unit__c >();
            
            for (Learning_Package_Unit__c enroLLUnitsNow: getUnitsToEnroll) {
                
                AS_Enrolled_Unit__c enroLLMe = new AS_Enrolled_Unit__c();
                enroLLMe.AS_Enrolment__c = getEnroLLments.Id;
                enroLLMe.AS_Unit__c = enroLLUnitsNow.AS_Unit__c;
                enroLLMe.AS_Status__c = 'Pending';
                
                newUnitsToEnroll.add(enroLLMe);
            }
            //upon insertions, selected units from the component will be created to enrolled units
            insert newUnitsToEnroll;  
        }

    /**
    * @details callback handler for cancel button (delete enrolment record)
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
            //delete deleteEnrol;
            message = 'Enrolment sucessfully deleted!';
        } else {
            message = 'No record to be deleted!';
        }
        return message;
    }

    @AuraEnabled
    public static string createEnrolledUnits(Id EnrollmentId, Id acctId, Id lpuID){
        String returnMsg = '';

        List<AS_Enrolled_Unit__c> checkEnrolledUnits = [SELECT Id
                                                  FROM AS_Enrolled_Unit__c
                                                  WHERE AS_Enrolment__c =: EnrollmentId];

        if ( checkEnrolledUnits.size() > 0) {
            delete checkEnrolledUnits;
        }

        if ( lpuID != null){
            List < Unit__c > getUnitsToEnroll = [SELECT Id
                                                FROM Unit__c
                                                WHERE 
                                                    Id =: lpuID
                                                ];

            
            List < AS_Enrolled_Unit__c > newUnitsToEnroll = new List < AS_Enrolled_Unit__c >();

            for ( Unit__c lpunits : getUnitsToEnroll ) {
                
                    AS_Enrolled_Unit__c enroLLMe = new AS_Enrolled_Unit__c();
                    enroLLMe.AS_Enrolment__c = EnrollmentId;
                    enroLLMe.AS_Unit__c = lpunits.Id;
                    enroLLMe.AS_Status__c = 'Pending';
                    
                    newUnitsToEnroll.add(enroLLMe);

            }
            
            if (newUnitsToEnroll.size() > 0){
                insert newUnitsToEnroll;
                returnMsg = 'Enrolment success';
            } else {
                returnMsg = 'Enrolment failed';
            }
            
        } else {
            returnMsg = 'LPUId is null';
        }


        return returnMsg;
    }

}