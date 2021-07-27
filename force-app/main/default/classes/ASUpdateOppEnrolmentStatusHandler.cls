/**
 * @author Ronald Santander
 * @since Sept 18 , 2019
 * @update Nov. 8 2019 by IVer <juliver@alphasys.com.au>
 */
public with sharing class ASUpdateOppEnrolmentStatusHandler {

    private static Boolean recursiveVal = false;

    /**
     * This method will check if the Opportunity meet the criteria to update it's related Enrolment record.
     * @param  SetOppId: The Id of all Opportunity the being trigger.
     */ 
    public static void checkOpportunity(Set<Id> SetOppId){

        if(recursiveVal == false){
            recursiveVal = true;
            Id oppEDRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Education').getRecordTypeId();

            List<Enrolment_Form__c> toUpdateEnrol = new List<Enrolment_Form__c>();
            List<Opportunity> toUpdateOpp = new List<Opportunity>();

            for(Opportunity opp : [SELECT Id,
                                            Name,
                                            AS_Enrolment__c,
                                            AS_Enrolment__r.AS_Learning_Package__c,
                                            AS_Enrolment__r.Enrolment_Status__c,
                                            RecordTypeId,
                                            Amount,
                                            IsWon,
                                            IsClosed,
                                            StageName
                                        FROM Opportunity
                                        WHERE Id IN: SetOppId 
                                        AND RecordTypeId =: oppEDRecordTypeId ]){  

            System.debug( 'wwwwwwwwwwwww' + opp );
            
                if( opp.AS_Enrolment__c != null && opp.AS_Enrolment__r.AS_Learning_Package__c != null && opp.RecordTypeId == oppEDRecordTypeId ){
                     System.debug( 'sulod?' + opp.Amount );

                     system.debug(' This trigger ASUpdateOppEnrolmentStatusHandler run ');

                    if ( opp.Amount == 0 ) {
                        system.debug('get in Closed won');
                        Opportunity newOpp = new Opportunity();
                        newOpp.Id           = opp.Id;
                        newOpp.StageName    = 'Closed Won';
                        toUpdateOpp.add(newOpp);

                        Enrolment_Form__c newEnrol = new Enrolment_Form__c();
                        newEnrol.Id = opp.AS_Enrolment__c;
                        if (opp.AS_Enrolment__r.Enrolment_Status__c == 'Pending Payment'){
                            newEnrol.Enrolment_Status__c    = 'Pending';
                        }
                        toUpdateEnrol.add(newEnrol);

                    } else if( opp.IsWon == true && opp.IsClosed == true ) {

                        system.debug('sulod pending');
                        Enrolment_Form__c newEnrol = new Enrolment_Form__c();
                        newEnrol.Id                     = opp.AS_Enrolment__c;
                        if (opp.AS_Enrolment__r.Enrolment_Status__c == 'Pending Payment'){
                            newEnrol.Enrolment_Status__c    = 'Pending';
                        }
                        toUpdateEnrol.add(newEnrol);

                    // } else if ( opp.Amount == null ) {
                    //     system.debug('Amount is null or empty ');
                    } else {
                        system.debug('Conditions above did not meet ');
                    }

                } else {
                    system.debug('Condition did not meet');
                }

            }

            if(!toUpdateOpp.isEmpty()) update toUpdateOpp; System.debug( 'hahaha' + toUpdateOpp );
            if(!toUpdateEnrol.isEmpty()) update toUpdateEnrol;
        }
    }
}