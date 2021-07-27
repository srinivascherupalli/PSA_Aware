/**
*@author Juniel
*@details AsEnrollmentListController is use in the AsEnrollmentList component as a server side
*@date September 19, 2019 
*/
public without sharing class AsEnrollmentListController {
    
	/**
     * Get all Enrolled Units.
     * @par getEnrolUnit Method:
     * This method will get all the Enrolled Units under Enrolment record.
     *
     * @param enrolmentId: It is the record id of the Enrolment.
     */
    @AuraEnabled
    public static List<AS_Enrolled_Unit__c> getEnrolUnit(Id enrolmentId){

        
        List<AS_Enrolled_Unit__c> enrolUnitList = [SELECT Id,
			AS_Unit__c,
			AS_Unit__r.Name,
            AS_Unit__r.AS_Training_Plan__c,
			AS_Status__c,
            AS_Training_Plan_Assignment__r.Training_Plan__c
			FROM AS_Enrolled_Unit__c 
			WHERE AS_Enrolment__c =: enrolmentId];
        
                
        return enrolUnitList; 
  
    }
    
    @AuraEnabled
	public static List<Enrolment_Form__c> getAccountEnrol(Id accountId) {

		List<Enrolment_Form__c> enrolList = [
            SELECT Id,
            AS_Learning_Package__c,
            AS_Learning_Package__r.Name,
            Enrolment_Status__c
            FROM Enrolment_Form__c 
            WHERE AS_Account__c =: accountId
            AND Enrolment_Status__c !=: 'Rejected'
            AND Enrolment_Status__c !=: 'Expired'
            AND Enrolment_Status__c !=: 'Cancelled/Withdrawn'
        ];
	
        return enrolList;
	}
    
    @AuraEnabled
	public static Map<Id, AS_Enrolled_Unit__c> getMapEnrolUnit(Id enrolmentId) {
         
         Map<Id, AS_Enrolled_Unit__c> mapEnrol = new Map<Id, AS_Enrolled_Unit__c>( [SELECT Id, AS_Unit__c, AS_Unit__r.Name, AS_Status__c  FROM AS_Enrolled_Unit__c WHERE AS_Enrolment__c =: enrolmentId  ] );
         
         return mapEnrol;
	}

    @AuraEnabled 
    public static Id getCurrentUser(){
       User u = [Select Id, ContactId, Name FROM User WHERE Id =: userInfo.getUserId()];

        Account acc = [Select Id FROM Account WHERE PersonContactId =: u.ContactId ];

        return acc.Id;
    }
}