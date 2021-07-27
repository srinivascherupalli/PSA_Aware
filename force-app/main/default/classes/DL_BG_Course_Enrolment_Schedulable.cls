global with sharing class DL_BG_Course_Enrolment_Schedulable implements Schedulable {

    global void execute(SchedulableContext sc) {
       	List<Id> certIIIComPharmacy_ids = new List<Id>();
        certIIIComPharmacy_ids.add('a1m0o00000KawZfAAJ');
        certIIIComPharmacy_ids.add('a1m0o00000Kh1izAAB');
        certIIIComPharmacy_ids.add('a1m0o00000Kh2j2AAB');
        
        try{
            List<AS_BG_Course_Enrolment__c> bgList = [SELECT Id,Parent_Banner_Group_Course__c, AS_Enrolment_Confirmation_Status__c 
                                                        FROM AS_BG_Course_Enrolment__c 
                                                        WHERE Parent_Banner_Group_Course__c in :certIIIComPharmacy_ids
                                                        AND AS_Enrolment_Confirmation_Status__c = 'Under Review' 
                                                        LIMIT 10];
            
            for(AS_BG_Course_Enrolment__c bgEnrolment : bgList){
                bgEnrolment.AS_Enrolment_Confirmation_Status__c = 'Confirmed';
            }
            
            System.debug(bgList);
            update bgList;
        }

        catch(Exception e){
            System.debug(e.getMessage());
        }
    }

    global String GetCRONExpression(Datetime dt) {
        return ('' + dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year());
    }
}