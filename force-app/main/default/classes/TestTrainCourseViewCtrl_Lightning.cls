/**
 * Test class for the TrainingCourseViewController_Lightning class
 * 
 * @author	Davanti:
 * @author	LToohey(Davanti),
 * @since	05/08/2020 
 * @date	05/08/2020 - LToohey(Davanti): created initial class structure
 * @see		TrainingCourseViewController_Lightning 
 */
@isTest
private class TestTrainCourseViewCtrl_Lightning {
    
    /**
     * @author	Davanti:
     * @author	LToohey(Davanti),
     * @since	05/08/2020 
     * @see		TrainingCourseViewController_Lightning#allFilterTrainingPlanmethod
     */
    static testMethod void testallFilterTrainingPlanmethod() {
        System.runAs(gettestUser()) {
            // Test specific setup
            // Set null filters as default
            list<string> categoryFilter = new List<string>();
            List<string> deliveryFilter = new List<string>();
            List<string> TypeFilter = new List<string>();
            List<string> TargetFilter = new List<string>();
            string sortedBy = '';
            
            // Start Test
            Test.StartTest();
                TrainingCourseViewController_Lightning.courseCatalogWrapper wrapper =  TrainingCourseViewController_Lightning.allFilterTrainingPlanmethod(categoryFilter, deliveryFilter, TypeFilter, TargetFilter, sortedBy);
                //Update filters
                categoryFilter.add('Test');
                deliveryFilter.add('Test');
                TypeFilter.add('Test');
                TargetFilter.add('Test');
                //Permutations of sortedBy
                sortedBy='dpn';
                wrapper =  TrainingCourseViewController_Lightning.allFilterTrainingPlanmethod(categoryFilter, deliveryFilter, TypeFilter, TargetFilter, sortedBy);
                sortedBy='dpo';
                wrapper =  TrainingCourseViewController_Lightning.allFilterTrainingPlanmethod(categoryFilter, deliveryFilter, TypeFilter, TargetFilter, sortedBy);
                sortedBy='az';
                wrapper =  TrainingCourseViewController_Lightning.allFilterTrainingPlanmethod(categoryFilter, deliveryFilter, TypeFilter, TargetFilter, sortedBy);
                sortedBy='za';
                wrapper =  TrainingCourseViewController_Lightning.allFilterTrainingPlanmethod(categoryFilter, deliveryFilter, TypeFilter, TargetFilter, sortedBy);
                sortedBy='accExDateOtoN';
                wrapper =  TrainingCourseViewController_Lightning.allFilterTrainingPlanmethod(categoryFilter, deliveryFilter, TypeFilter, TargetFilter, sortedBy);
            Test.StopTest();

        }
    }    
    
    /**
     * create all the required data for use in these test methods
     */
    @testSetup static void setup(){
        //TODO: create all the testdata. this will then be retrieved by the following "get" methods
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