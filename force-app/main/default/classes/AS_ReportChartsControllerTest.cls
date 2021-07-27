@isTest
public class AS_ReportChartsControllerTest {
	static testMethod void myUnitTest() {
        AsCPDPlanner__c cpdPlan = new AsCPDPlanner__c(
        	Name = 'Test Name',
            AS_Plan_Year__c = '2018',
            AsUser__c = UserInfo.getUserId()
        );
        insert cpdPlan;
        
        System.assert(cpdPlan != null, 'CPD Plan is empty!');
        
        AsCPD_Learning_Summary__c actSum = new AsCPD_Learning_Summary__c(
        	Name= 'Test Activity Summary',
            CPD_Planner__c = cpdPlan.Id,
            Status__c = 'Planned'
        );
        insert actSum;
        
        System.assertEquals(cpdPlan.Id, actSum.CPD_Planner__c);
        System.assert(cpdPlan != null, 'CPD Learning Summary is empty!');
        
        AS_ReportChartsController.cpdActivityReport(cpdPlan.Id);
        AS_ReportChartsController.cpdPlanProgressReport(cpdPlan.Id);
    }
}