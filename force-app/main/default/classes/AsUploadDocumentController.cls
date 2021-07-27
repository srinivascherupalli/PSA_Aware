/**
 * @author: Jet R. Compayan <jet@alphasys.com.au>
 * @since Sept 5 , 2019
 */ 
public without sharing class AsUploadDocumentController {

    /**
     * This Method will get the Picklist value of Document field in the learning Package. 
     * @return   return Picklist values.
     */ 
    @AuraEnabled 
    public static map<String, Object>  InitDocumentUpload( Id parentId ){

        Map< String , Object > returnMap  = new Map< String , Object >();
        system.debug('parentId > '+parentId);
        list<String> lpDocPicklist = new List<String>();
        list< String > lpDocPicklistValue = new List< String >();

        Schema.DescribeFieldResult fieldResult = Learning_Package__c.AS_Documents__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
           lpDocPicklist.add(f.getLabel());
        }     

        list< Enrolment_Form__c > enrollmentList = [ Select Id, AS_Learning_Package__c, AS_Learning_Package__r.AS_Documents__c FROM  Enrolment_Form__c  WHERE Id =:parentId ];
        for( Enrolment_Form__c enRol : enrollmentList ){
            if ( enRol.AS_Learning_Package__r.AS_Documents__c !=null) {
                lpDocPicklistValue = enRol.AS_Learning_Package__r.AS_Documents__c.split(';');
            }
        }
        returnMap.put( 'LearnPackageDoc' , lpDocPicklist );
        returnMap.put( 'lpDocPicklistValue' , lpDocPicklistValue );

           
        return returnMap;
    } 
     
    /**
     * 
	 */
    @AuraEnabled
    public static boolean saveChanges( Id enrolId, Boolean sendmelink ){
        Boolean returnStatus = false; 
        try { 

            Enrolment_Form__c enrol = new Enrolment_Form__c(); 
            enrol.Id = enrolId;
            enrol.AS_Saved_Enrolment_Form__c = true;
            enrol.AS_Enrolment_Stage__c = 'Page 11: Document upload';
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

            //delete deleteEnrol;
            message = 'Enrolment sucessfully deleted!';
        } else {
            message = 'No record to be deleted!';
        }

        return message;
    }

    @AuraEnabled
    public static Enrolment_Form__c getEnrolInfo( Id recordID ) {

        Enrolment_Form__c enrol = [
            SELECT Id,
            Enrolment_Status__c
            FROM Enrolment_Form__c 
            WHERE Id =: recordID
        ];
        return enrol;
    }

}