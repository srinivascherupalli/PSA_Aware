/**
 * Test class for the PSA_Progress class
 * 
 * @author	Davanti:
 * @author	LToohey(Davanti),
 * @since	05/08/2020 
 * @date	05/08/2020 - LToohey(Davanti): created initial class structure
 * @see		PSA_Progress 
 */
@isTest
private class TestPSA_Progress {
    
    /**
     * @author	Davanti:
     * @author	LToohey(Davanti),
     * @since	05/08/2020 
     * @see		PSA_Progress#allCPDPlanmethod
     */
    static testMethod void testallCPDPlanmethod_withoutCredits() {
        
        //Get User
        User testUser = gettestUser();
        System.runAs(testUser) {
        
            //Get active CPD planner record type Id - AsActiveCPDPlanner
            Id activeRecordTypeId = Schema.SObjectType.AsCPDPlanner__c.getRecordTypeInfosByDeveloperName().get('AsActiveCPDPlanner').getRecordTypeId();

            //Create AsCPDPlanner__c data
            AsCPDPlanner__c cpd = new AsCPDPlanner__c(
                Name='CPD test',
                AsUser__c=testUser.Id,
                AS_Plan_Year__c='2020',
                AS_Current_CPD_Plan__c=true,
                AS_Accredited_pharmacist__c=false,
                RecordTypeId=activeRecordTypeId
            );
            insert cpd;
            
            //Create learning
            AsCPD_Learning_Summary__c cpdLearn = new AsCPD_Learning_Summary__c(
                Name='TestLearn',
                CPD_Planner__c = cpd.Id,
                Status__c='Complete',AS_Reflections__c='test ref',
                AsSummary_Plan__c = true,
                Group_1_CPD__c=60            );
            insert cpdLearn;
            
            System.debug('CPD inserted' + cpd + 'Learning inserted' + cpdLearn);
            
            // Test specific setup
            AsCPDPlanner__c cpd1 = [select Name,id,AS_My_Plan_Goals__c from AsCPDPlanner__c limit 1];
            System.assertNotEquals(cpd1, null);
            System.debug('CPD PLANNER: ' + cpd1);
        	AsCPD_Learning_Summary__c cpdSummary =[select id,AsSummary_Plan__c,AS_Reflections__c from AsCPD_Learning_Summary__c limit 1];
			 System.assertNotEquals(cpdSummary, null);
            // Start Test
            Test.StartTest();
               PSA_Progress.courseCatalogWrapper allCPDPlan = PSA_Progress.allCPDPlanmethod(cpd1.Id);
                PSA_Progress.courseCatalogWrapper allCPDPlanEmpty = PSA_Progress.allCPDPlanmethod('');
                allCPDPlan.AccConRelation=null;
                PSA_Progress.updateCheck(true, cpd1.Id);
                PSA_Progress.updateGoal('My goals String', cpd1.Id);
           	    PSA_Progress.updateReflection('My reflection String', cpdSummary.Id);
            	PSA_Progress.updateSelection(0, cpdSummary.Id);
            	PSA_Progress.generateCPDPlanReport(cpd1.Id);
            
            Test.StopTest();

        }
    }

    /**
     * @author	Davanti:
     * @author	LToohey(Davanti),
     * @since	05/08/2020 
     * @see		PSA_Progress#allCPDPlanmethod
     */
    static testMethod void testallCPDPlanmethod_withCredits() {
        
        //Get User
        User testUser = gettestUser();
        System.runAs(testUser) {
        
            //Get active CPD planner record type Id - AsActiveCPDPlanner
            Id activeRecordTypeId = Schema.SObjectType.AsCPDPlanner__c.getRecordTypeInfosByDeveloperName().get('AsActiveCPDPlanner').getRecordTypeId();

            //Create AsCPDPlanner__c data
            AsCPDPlanner__c cpd = new AsCPDPlanner__c(
                Name='CPD test',
                AsUser__c=testUser.Id,
                AS_Plan_Year__c='2020',
                AS_Current_CPD_Plan__c=true,
                AS_Accredited_pharmacist__c=false,
                RecordTypeId=activeRecordTypeId
            );
            insert cpd;
            
            //Create completed learning - StatusEQUALSComplete) AND (Include in CPD Plan SummaryEQUALSTrue
            AsCPD_Learning_Summary__c cpdLearn = new AsCPD_Learning_Summary__c(
                Name='TestLearn',
                CPD_Planner__c = cpd.Id,
                Status__c='Complete',
                AsSummary_Plan__c = true,
                Group_1_CPD__c=40
            );
            insert cpdLearn;

            //cpd.Total_CPD_Credits_Achieved__c!=0
            
            System.debug('CPD inserted' + cpd + 'Learning inserted' + cpdLearn);
            
            // Test specific setup
            AsCPDPlanner__c cpd1 = [select Name, id from AsCPDPlanner__c limit 1];
            System.assertNotEquals(cpd1, null);
            System.debug('CPD PLANNER: ' + cpd1);
        
            // Start Test
            Test.StartTest();
               PSA_Progress.courseCatalogWrapper allCPDPlan = PSA_Progress.allCPDPlanmethod(cpd1.Id);
            	PSA_Progress.generateCPDPlanReport('');

            Test.StopTest();

        }
    }
    

    /**
     * create all the required data for use in these test methods
     */
    @testSetup static void setup(){

    }
    
    /**
     * return a user object to run this test as.
     */
    private static User gettestUser(){
        // Perform operation as first invocation only
        if (testUser == null){
            //Create admin users
            List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');

            System.runAs(adminUsers.get(0)){
                //Assign corresponding perm sets
                TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            }
            testUser = adminUsers.get(0);
        }
        return testUser;
    }
    private static User testUser = null;

}