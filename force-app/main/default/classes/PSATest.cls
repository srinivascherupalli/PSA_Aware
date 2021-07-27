@isTest
private class PSATest {
    @isTest static void testData1() {
        
        User u = PSA.fetchUser();
        AccountContactRelation acr = PSA.getAccountContactRelation();
        String planId = PSA.getPlanId( 'a1o0o0000063pCtAAI' );
        Decimal target = PSA.currentCPDTarget( 'a1o0o0000063pCtAAI' );
        Decimal target1 = PSA.currentCPDTarget( '' );
        Integer total = PSA.currentCPDActivitiesSummaryTotal( 'a1o0o0000063pCtAAI' );
        Integer total1 = PSA.currentCPDActivitiesSummaryTotal( '' );
        Double percentage = PSA.currentCPDActivitiesSummaryPercentage( 'a1o0o0000063pCtAAI' );
        Double percentage1 = PSA.currentCPDActivitiesSummaryPercentage( '' );
        AsCPDPlanner__c cpd = PSA.currentCPD( 'a1o0o0000063pCtAAI' );
        AsCPDPlanner__c cpd1 = PSA.currentCPD( '' );
        List<Map<String,String>> a1 = PSA.getPlannedActivities( 'a1o0o0000063pCtAAI' );
        List<Map<String,String>> a2 = PSA.getInProgressActivities( 'a1o0o0000063pCtAAI' );
        List<Map<String,String>> a3 = PSA.getNotStartedActivities( 'a1o0o0000063pCtAAI' );
        List<Map<String,String>> a4 = PSA.getCompleteActivities( 'a1o0o0000063pCtAAI' );
        List<Map<String,String>> a11 = PSA.getPlannedActivities( '' );
        List<Map<String,String>> a22 = PSA.getInProgressActivities( '' );
        List<Map<String,String>> a33 = PSA.getNotStartedActivities( '' );
        List<Map<String,String>> a44 = PSA.getCompleteActivities( '' );
        List<AsCPDPlanner__c> plans = PSA.getPlans();
        Attachment attachment = PSA.getPlanAttachment( 'a1o0o0000063pCtAAI' );
        Attachment attachment1 = PSA.getPlanAttachment( '' );
        String reflection = PSA.getReflection( 'a1x0o0000044N2nAAE' );
        Boolean added1 = PSA.addReflection( 'a1x0o0000044N2nAAE', 'Test!' );
        Boolean added2 = PSA.saveIncludeStatus( 'a1x0o0000044N2nAAE', '1' );
        Boolean added3 = PSA.generateCPDPlanReport( 'a1o0o0000063pCtAAI' );
        List<String> c = PSA.hasCourse();
        List<Attachment> attachments = PSA.getPlanAttachments( 'a1o0o0000063pCtAAI' );
        List<Attachment> attachments1 = PSA.getPlanAttachments( '' );
        Boolean added4 = PSA.setAccreditedPharmacist( 'a1o0o0000063pCtAAI' );
    }
    
    @isTest static void testNum() {
        PSA.getNum();
        PSA.getNum1();
        PSA.getNum2();
        PSA.getNum3();
    }
}