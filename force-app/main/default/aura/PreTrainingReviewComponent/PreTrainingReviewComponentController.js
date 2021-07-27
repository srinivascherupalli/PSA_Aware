({
    doinit : function(cmp, event, helper) {
        helper.getFieldPicklist(cmp, event);
        helper.preTrainfunc( cmp, helper );
        helper.getEnrolmentStatus(cmp);

        document.body.scrollTop = 0;
        document.documentElement.scrollTop = 0;
    },
   
    saveRecord : function(cmp, event, helper) {


        var toastEvent = $A.get("e.force:showToast");

        var allValid = cmp.find('slds-field-required').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);

        if(  !allValid ) {
            toastEvent.setParams({
                "title": "Error!",
                "type" : 'error',
                "message": "Please fill up the required fields!"
            });
            toastEvent.fire();

        } else {
            helper.savePreTrainingviewRecord(cmp, event,false);
        }
    },
    cancelCallback : function(cmp,event,helper){ 
       
        cmp.set("v.showSpinner", true); 
        var deleteEnrol = cmp.get("c.deleteEnrolment");
        
        deleteEnrol.setParams({
            "enrolId": cmp.get('v.parentId')
        });
        
        deleteEnrol.setCallback( this, function( response ) {
            var status = response.getState();
            if( status === "SUCCESS" ) {
                cmp.set("v.showSpinner", false);
                var rBody = response.getReturnValue();
                window.location.href = window.location.origin + '/s/my-enrolments';
            } else {
                cmp.set("v.showSpinner", false);
                toastEvent.setParams({
                    "title": "Error!",
                    "type" : 'error',
                    "message": "Please fill up the required fields!"
                });
                toastEvent.fire();
            }
            
        });
        $A.enqueueAction( deleteEnrol );
  
    },
    saveSendLink : function(cmp,event,helper){ 

        var toastEvent = $A.get("e.force:showToast");

        var allValid = cmp.find('slds-field-required').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);

        if(  !allValid ) {
            toastEvent.setParams({
                "title": "Error!",
                "type" : 'error',
                "message": "Please fill up the required fields!"
            });
            toastEvent.fire();

        } else {
           helper.savePreTrainingviewRecord(cmp, event,true);
        }
    },
     handleChange : function (component, event) {
        //alert(event.getParam('value'));
        var pretraining = component.get("v.pretrainingreview");
         if(event.getSource().get("v.name") === 'S2_S3_Dispensary_Skill__c'){
             pretraining.S2_S3_Dispensary_Skill__c = event.getSource().get("v.value");
         } else if (event.getSource().get("v.name") === 'Difficult_Assessment_Methods__c') {
             pretraining.Difficult_Assessment_Methods__c = event.getSource().get("v.value");
         } else if (event.getSource().get("v.name") === 'Computer_Skills__c') {
             pretraining.Computer_Skills__c = event.getSource().get("v.value");
         } else if (event.getSource().get("v.name") === 'Support_Required__c') {
             pretraining.Support_Required__c = event.getSource().get("v.value");
         } else if (event.getSource().get("v.name") === 'Government__c') {
             pretraining.Government__c = event.getSource().get("v.value");
         } else if (event.getSource().get("v.reorder") === 'How_do_you_like_to_learn__c') {
             pretraining.Government__c = event.getSource().get("v.reorder");
         }
    },

    handleChangeGovernment: function( cmp,event,helper ) {
        var pretraining = cmp.get("v.pretrainingreview");
        pretraining.State__c = ( pretraining.Government__c == 'true' ? pretraining.State__c : '' );
        var bol = ( pretraining.Government__c == 'true' ? true : false );
        cmp.set("v.governmentCheck", bol );
        cmp.set("v.pretrainingreview", pretraining);
    },
    
    toggleReorder : function (component, event) {
        const reorderGroup = document.getElementById('reorder');
        //console.log(reorderGroup);
        //reorderGroup.disabled = !reorderGroup.disabled;
        /*reorderGroup.addEventListener('ionItemReorder', ({detail}) => {
                                                          detail.complete(true);
                                                         });*/
    },
    afterScriptsLoaded : function( cmp, event, helper) {
       
        var el = document.getElementById('sortable');

        var sortable = Sortable.create(el, {
            onUpdate : function( evt ) {

                var toastEvent = $A.get("e.force:showToast");

                toastEvent.setParams({
                    "title": "Success!",
                    "type" : 'success',
                    "message": "Successfully Sorted!"
                });
                toastEvent.fire();
            }
        });

    }, 
    backCallback: function( cmp, event, helper ) {
        helper.backCallback( cmp );
    }
    
})