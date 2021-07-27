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
public class TestTrainingPlansSearchCtrl {

    static testMethod void testSearchWithEntries(){

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
                                            ,Name
                                            ,Enable_Self_Registration__c
                                            ,Self_Registration_Access__c
                                            from Training_Plan__c];

        System.assertEquals(1,tplans.size());
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;
        tplan.Self_Registration_Access__c = 'Public';
        update tplan;


        
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
            	PageReference ref = Page.TrainingPlansSearch;
            	System.debug('tplan : ' + tplan);
        ref.getParameters().put('q',tplan.Name);
        Test.setCurrentPageReference(ref);
                TrainingPlansSearchController cont = new TrainingPlansSearchController();
                
                System.assert(cont.getSearchResults().size()>0);
                System.assert(cont.hasMessages == false);
                System.assert(cont.getHasPrevious() == false);
                System.assert(cont.getHasNext() == false);
                System.assert(cont.getPageNumber() == 1);
                System.assert(cont.getTotalPages() == 1);
                
                cont.doNext();
                cont.doPrevious();
                System.assert(cont.hasMessages == false);
            }

        Test.stopTest();

    }


}