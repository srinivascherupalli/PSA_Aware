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
trigger LearningAssignmentTrigger on Learning_Assignment__c (before insert,before update,before delete,after insert,after update,after undelete, after delete) {

    LearningAssignmentsHelper helper = new LearningAssignmentsHelper();

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            helper.processBeforeInserts(Trigger.new);
            AS_HelperClass As_helper = new AS_HelperClass();
            As_helper.OnBeforeInsert(Trigger.new, Trigger.oldMap, Trigger.newMap);
        }else if(Trigger.isUpdate){
            helper.processBeforeUpdates(Trigger.oldMap,Trigger.newMap);

        }else if(Trigger.isDelete){
            helper.processBeforeDeletes(Trigger.old);
        }

        /** MLO
         * assign LMS_Instance from Learning
         */ 
        if(!Trigger.isDelete){
            List<Learning_Assignment__c> lrnAsgn = Trigger.new;
            Id learningInstance = [SELECT Id, LMS_Instance__c FROM Learning__c 
                                        WHERE Id =: lrnAsgn[0].Learning__c].LMS_Instance__c;

            //AS_HelperClass.LMS_Integration_LearningAssignment(Trigger.new, 'before');
            lrnAsgn[0].LMS_Instance__c  = learningInstance;
        }
    }else if(Trigger.isAfter){
        if(Trigger.isInsert){
            helper.processAfterInserts(Trigger.new);

            //MLO
            //AS_HelperClass.LMS_Integration_LearningAssignment(Trigger.new, 'after insert');
            
            // added by wew for (#PSABG-45)
            AS_HelperClass As_helper = new AS_HelperClass();
    				As_helper.createLmsCourseEnrollmentChecker(Trigger.new, new Map<Id,Learning_Assignment__c>(), new Map<Id,Learning_Assignment__c>(), 'INSERT');
    

        }else if(Trigger.isUpdate){
            helper.processAfterUpdates(Trigger.oldMap,Trigger.newMap);
            
            //MLO
            AS_HelperClass.LearningAssignmentTriggerHelper(Trigger.new);
            
             // added by wew for (#PSABG-45)
            AS_HelperClass As_helper = new AS_HelperClass();
    	    As_helper.createLmsCourseEnrollmentChecker(Trigger.new, Trigger.oldMap, Trigger.newMap, 'UPDATE');
            
            //Added functionality in ticket PRI-132 by vincent
            if(!System.isBatch()){
                AS_LearningAssignmentHandler.UpdateLearningAssignmentBaseOnTrainingplanAssignmentResult(Trigger.new);
                system.debug('fire learningass');
              
            }
        }else if(Trigger.isUndelete){
            helper.processAfterUnDeletes(Trigger.new);
        }else if(Trigger.isDelete){
            helper.processAfterDeletes(Trigger.old);
        }
    }

}