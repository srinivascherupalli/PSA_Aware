({
    
    getFieldPicklist : function( cmp, event ) {
         
        var allFields = [
            'Employment_duration_for_current_position__c',
            'S2_S3_Dispensary_Skill__c',
            'Difficult_Assessment_Methods__c',
            'Computer_Skills__c',
            'Support_Required__c',
            'How_do_you_like_to_learn__c',
            'State__c'
        ];
             
         for( var x = 0, fieldval = [], newArr = []; x < allFields.length; x++ ) {
             this.PickListValCallback( cmp, allFields[x] ); 
         }
     },
     
     PickListValCallback : function( cmp, fieldname ) {
         
         var fielValue = cmp.get('c.getPicklistValue');

         console.log('fieldname', fieldname );
         
         fielValue.setParams({
             'fieldname' : fieldname,
             'objectname'  : 'Pre_Training_Review__c'
         });
         
         fielValue.setCallback( this, function(response) {
             
             var state = response.getState();
             var fieldval = response.getReturnValue();
 
             if( state === 'SUCCESS' ) {
 
                 if ( fieldname != 'State__c' ) {
                     for( var y = 0, thisArr = [] ,arrNew = []; y < fieldval.length; y++ ) {
                         thisArr[y] = {
                             'label' : fieldval[y],
                             'value' : fieldval[y]
                         }
                     }
     
                     arrNew = Object.assign( [], thisArr );
                     cmp.set( 'v.' + fieldname, arrNew );
                     
                 } else {
                     cmp.set( 'v.' + fieldname, fieldval );
                 }
                 
             } else {
                 console.log('error', returnvar);
             }
         });
         $A.enqueueAction(fielValue);
     },
     
      getPreTrainingRecord : function(cmp, priTrainID ) {

         var pretrainInfo = cmp.get("c.getPreTrainingReviewInfo");
 
         pretrainInfo.setParams({
             "recordID": priTrainID
         });
 
         pretrainInfo.setCallback(this,function(response){
 
             var status = response.getState();
 
             if( status === "SUCCESS" ) {
                 
                 var qresult = response.getReturnValue();
                 
                 if( qresult != null ) {

                    if ( typeof qresult['Learning_preferences__c'] != 'undefined' ) {
 
                        var oldListdata = qresult['Learning_preferences__c'].split(';');
                        var oldList = [];
                    
                        for (var i = 0; i < oldListdata.length; i++) {

                            var jsn = {
                                'label' : oldListdata[i],
                                'value' : oldListdata[i]
                            };

                            oldList.push( jsn );
                        }
                        cmp.set('v.How_do_you_like_to_learn__c', oldList ); 
                    }
 
                    if ( typeof qresult['Government__c'] != 'undefined' ) {
                        qresult.Government__c = ( qresult['Government__c'] ) ? 'true' : 'false';
                        cmp.set("v.governmentCheck", qresult['Government__c']);
                    }

                    cmp.set("v.pretrainingreview", qresult);
 
                 }
 
             }
         });
         $A.enqueueAction(pretrainInfo);
     },
     
      savePreTrainingviewRecord : function(cmp, event, sendmelink) {
         cmp.set("v.showSpinner", true);

         var toastEvent = $A.get("e.force:showToast");
 
         var preInfo = cmp.get("v.pretrainingreview");
         
         var savepreInfo = cmp.get("c.savePreTraininInfo");
 
         var pretrain = cmp.get("v.governmentCheck");
  
         
         var sortArr = [];
 
          
          var sorta = document.getElementById('sortable');
          for( var x = 0, c = sorta.childNodes; x < c.length; x++ ) {
              sortArr.push( c[x].childNodes[1].textContent );
          }
 
         preInfo['Learning_preferences__c'] = sortArr.join(';');
         preInfo['Government__c'] = pretrain;
 
           savepreInfo.setParams({
             "preRecord": preInfo,
             "preId": cmp.get('v.preTrainnigPreviewId'),
             "parentId": cmp.get('v.parentId'),
             "recordId": cmp.get( 'v.recordId' ),
             "sendmelink": sendmelink  
         });
 
         savepreInfo.setCallback(this,function(response){
             var status = response.getState();
             if(status === "SUCCESS"){
                 var qresult = response.getReturnValue();
                 cmp.set("v.showSpinner", false); 
                 if ( qresult ) {

                     if( sendmelink ) {
                         cmp.set('v.showSpinner', false );
                         toastEvent.setParams({
                             "title": "Success!",
                             "type" : 'success',
                             "message": "Email has been sent!"
                         });
                         toastEvent.fire();
                         
                     } else {
                         this.callNextStep( cmp, true );
                     }
                 }
 
             } else {
                 console.log( response.getError() );
                 cmp.set("v.showSpinner", false);
                 toastEvent.setParams({
                     "title": "Error!",
                     "type" : 'error',
                     "message": "Error occured, please try again!"
                 });
                 toastEvent.fire();
             }
             
         });
         $A.enqueueAction(savepreInfo);
        //  window.location.reload();
     }, 
     callNextStep :function(cmp, iscompleted) {
        var cmpEvent = cmp.getEvent("Enrolment_Event");
        var cmpEvent = $A.get("e.c:EnrolmentActiveStep");

        var nextStep =  'step9';

        console.log('callNextStep iscompleted', iscompleted );

        if( iscompleted ) {
            nextStep = 'step9 - completed';
        }
         //console.log( nextStep );
        cmpEvent.setParams({
             enrolmentStep : nextStep
        });
         cmpEvent.fire();
     },
     backCallback: function( cmp ) {
         var cmpEvent = cmp.getEvent("Enrolment_Event");
         var cmpEvent = $A.get("e.c:EnrolmentActiveStep");
         cmpEvent.setParams({
             enrolmentStep : "step7"});
         cmpEvent.fire();
     },

     getEnrolmentStatus : function( cmp ) {

        cmp.set("v.showSpinner", true);

        var func = cmp.get('c.getEnrolmentInfo');
         
        func.setParams({
            'recordID' : cmp.get('v.parentId')
        });
        
        func.setCallback( this, function(response) {
            
            var state = response.getState();
            var fieldval = response.getReturnValue();

            if( state === 'SUCCESS' ) {

                cmp.set('v.enrolmentStatus', fieldval.Enrolment_Status__c );

                if ( typeof fieldval.AS_Learning_Package__r == 'undefined' ||  fieldval.AS_Learning_Package__r.AS_Accreditation_level__c != 'Qualification' ) {
                    var cmpEvent = cmp.getEvent("Enrolment_Event");
                    var cmpEvent = $A.get("e.c:EnrolmentActiveStep");
                    cmpEvent.setParams({
                    enrolmentStep : "step9"});
                    cmpEvent.fire();
                }
            
              cmp.set("v.showSpinner", false); 
                
            } else {
                console.log('error', returnvar);
            }
        });
        $A.enqueueAction(func);
    },

    preTrainfunc : function( cmp, helper ) {

        var enrolId = cmp.get('v.parentId');

        console.log('enrolId', enrolId );

        var func = cmp.get("c.getTrainingReview");
        
        func.setParams({
            "recordID": enrolId
        });

        func.setCallback( this, function( res ){
            var status = res.getState();

            if(status === "SUCCESS"){
                var qresult = res.getReturnValue();

                if( qresult != null) {
                    helper.getPreTrainingRecord(cmp, qresult);
                }
            }
        });
        $A.enqueueAction(func);
    }
     
 })