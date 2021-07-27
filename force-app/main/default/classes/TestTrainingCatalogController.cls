/*
Copyright (c) 2014, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors
    may be used to endorse or promote products derived from this software
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
OF THE POSSIBILITY OF SUCH DAMAGE.

*/
@isTest
private class TestTrainingCatalogController {

    static testMethod void testCatalogPageWithInvalidCategoryId(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(2,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        PageReference ref = Page.TrainingCatalogDetail;
        Test.setCurrentPageReference(ref);
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
            		System.debug('lmsUsers.get(0) :' + lmsUsers.get(0));
                TrainingCatalogDetailController cont = new TrainingCatalogDetailController();
                System.assertEquals(0,cont.tPlans.size());
            }

        Test.stopTest();

    }
		
    static testMethod void testWithValidCategoryId(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(2,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
				
        List<Training_Plan__c> tplans = [select id
                                            ,Enable_Self_Registration__c
                                            ,Self_Registration_Access__c
                                            from Training_Plan__c];

        System.assertEquals(1,tplans.size());
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;
        tplan.Self_Registration_Access__c = 'Public';
        update tplan;

        System.assertEquals(0,getTrainingPlanAssignmentsCount(tplan.Id));

        List<Training_Plan_Category__c> tplanCategories = [select id
                                                                ,Learning_Category__c
                                                                from Training_Plan_Category__c
                                                                where Training_Plan__c = :tplan.Id];
        PageReference ref = Page.TrainingCatalogDetail;
        ref.getParameters().put('id',tplanCategories.get(0).Learning_Category__c);

        Test.setCurrentPageReference(ref);
        
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                TrainingCatalogDetailController cont = new TrainingCatalogDetailController();
                System.assert(cont.tPlans.size()>0);
            }
        Test.stopTest();
				
    }
		
    private static Integer getTrainingPlanAssignmentsCount(Id tplanId){
        return [select count() from Training_Plan_Assignment__c where Training_Plan__c = :tplanId];
    }


    /*
     *Author : JRC
      *Description : method to get all picklist value from target audience field in training plan object
      *Date Created :
      *Last Modified By : 
      *Date Last Modified :
      *Param : 
      *Return : 
    */ 
     static testMethod void getfilterTargetAudienceTest() {
        TrainingCatalogHomeController trainingCatHome = new TrainingCatalogHomeController();
        System.debug(trainingCatHome.getfilterTargetAudience());
     }

    /*
      *Author : JRC
      *Description : method to get all picklist value from Training Plan Type field in training plan object
      *Date Created :
      *Last Modified By : 
      *Date Last Modified :
      *Param : 
      *Return : 
    */ 
      static testMethod void getfilterTrainingPlanTypeTest() {
        TrainingCatalogHomeController trainingCatHome = new TrainingCatalogHomeController();
        System.debug(trainingCatHome.getfilterTrainingPlanType());
    }


        
    /*
      *Author : JRC
      *Description : method to get all picklist value from Category field in training plan object
      *Date Created :
      *Last Modified By : 
      *Date Last Modified :
      *Param : 
      *Return : 
     */ 
    static testMethod void getfilterCategoryTest() {
        TrainingCatalogHomeController trainingCatHome = new TrainingCatalogHomeController();
        System.debug(trainingCatHome.getfilterCategory());
    }

    /*
       *Author : JRC
      *Description : method to get all training plan from filter
      *Date Created :
      *Last Modified By : 
      *Date Last Modified :
      *Param : 
      *Return : 
     */ 
    static testMethod void allFilterTrainingPlanTest() {
        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(2,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();

        List<Training_Plan__c> tplans = [select id
        ,Enable_Self_Registration__c
        ,Self_Registration_Access__c
        from Training_Plan__c];

        System.assertEquals(1,tplans.size());
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;
        tplan.Self_Registration_Access__c = 'Public';
        update tplan;
  list<String> param = new list<String>{
          '{"TargetAudience":["Industry pharmacist","General practice pharmacist"],"CourseType":["Australian Pharmacist","Blended learning"],"Category":[],"Delivery":[]}'
          ,'dpn'
        };

        TrainingCatalogHomeController.allFilterTrainingPlan(param);

         list<String> param2 = new list<String>{
          '{"TargetAudience":["Industry pharmacist","General practice pharmacist"],"CourseType":["Australian Pharmacist","Blended learning"],"Category":[],"Delivery":[]}'
          ,'dpo'
        };

        TrainingCatalogHomeController.allFilterTrainingPlan(param2);

         list<String> param3 = new list<String>{
          '{"TargetAudience":["Industry pharmacist","General practice pharmacist"],"CourseType":["Australian Pharmacist","Blended learning"],"Category":[],"Delivery":[]}'
          ,'az'
        };

        TrainingCatalogHomeController.allFilterTrainingPlan(param3);

         list<String> param4 = new list<String>{
          '{"TargetAudience":["Industry pharmacist","General practice pharmacist"],"CourseType":["Australian Pharmacist","Blended learning"],"Category":[],"Delivery":[]}'
          ,'za'
        };

        TrainingCatalogHomeController.allFilterTrainingPlan(param4);

        list<String> param5 = new list<String>{
          '{"TargetAudience":["Industry pharmacist","General practice pharmacist"],"CourseType":["Australian Pharmacist","Blended learning"],"Category":[],"Delivery":[]}'
          ,'accExDateOtoN'
        }; 

        TrainingCatalogHomeController.allFilterTrainingPlan(param5);
    }
}