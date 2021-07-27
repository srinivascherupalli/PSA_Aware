@isTest(SeeAllData=true)
public class DL_BG_Course_Enrolment_Schedulable_Test {

    @isTest(SeeAllData=true)
    public static void BGCE_Enrolment_Test(){
        Id certIIIComPharmacy_id = 'a1m0o00000KawZfAAJ';
        AS_BG_Course_Enrolment__c cloneableBGCE = [SELECT Id,Parent_Banner_Group_Course__c,AS_Banner_Group_Course__c, AS_Contact__c, AS_Enrolment_Confirmation_Status__c FROM AS_BG_Course_Enrolment__c WHERE Parent_Banner_Group_Course__c = 'a1m0o00000KawZfAAJ' LIMIT 1];
        AS_BG_Course_Enrolment__c newBGCE = cloneableBGCE.clone(false,true,false,false);
        newBGCE.AS_Enrolment_Confirmation_Status__c = 'Under Review';
        Test.startTest(); 
        insert newBGCE;

        List<AS_BG_Course_Enrolment__c> bgList = [SELECT Id,Parent_Banner_Group_Course__c, AS_Enrolment_Confirmation_Status__c 
                                                            FROM AS_BG_Course_Enrolment__c 
                                                            WHERE Parent_Banner_Group_Course__c = :certIIIComPharmacy_id
                                                            AND AS_Enrolment_Confirmation_Status__c = 'Under Review' 
                                                            LIMIT 10];
                
        for(AS_BG_Course_Enrolment__c bgEnrolment : bgList){
            bgEnrolment.AS_Enrolment_Confirmation_Status__c = 'Confirmed';
        }


               
            System.debug(bgList);
            update bgList;
        Test.stopTest();

    }

}