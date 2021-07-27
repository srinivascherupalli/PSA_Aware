/**
 * Test class for the PSA_MyEducation class
 * 
 * @author	Davanti:
 * @author	LToohey(Davanti),
 * @since	05/08/2020 
 * @date	05/08/2020 - LToohey(Davanti): created initial class structure
 * @see		PSA_MyEducation 
 */
@isTest
private class TestPSA_myEducation {
    
    /**
     * @author	Davanti:
     * @author	LToohey(Davanti),
     * @since	05/08/2020 
     * @see		PSA_MyEducation#allCPDPlanmethod
     */
    static testMethod void testallCPDPlanmethod_withoutCredits() {
        
        //Get User
        User testUser = gettestUser();
        System.runAs(testUser) {
			//Create Training_plan__c data
			TestTrainingPlanData.createSampleData();
            List<Training_Plan__c> tplans = [select id
                                                ,Enable_Self_Registration__c
                                                ,Self_Registration_Access__c
                                                from Training_Plan__c];
    
            System.assertEquals(1,tplans.size()); 
            Training_Plan__c tplan = tplans.get(0);
            
            //Create Training_Plan_Assignment__c data
            Training_Plan_Assignment__c cpd = new Training_Plan_Assignment__c(
                //Name='CPD test',
                User__c=testUser.Id,
                Status__c='Completed',
                Completed_On__c=system.today(),
                Training_Plan__c=tplan.Id
            );
            insert cpd;
            Training_Plan_Assignment__c cpd1 = [select Name, id from Training_Plan_Assignment__c limit 1];
            System.assertNotEquals(cpd1, null);
            
            // Start Test
            Test.StartTest();
                PSA_MyEducation.courseCatalogWrapper allCPDPlan = PSA_MyEducation.allCPDPlanmethod();
            Test.StopTest();

        }
    }
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