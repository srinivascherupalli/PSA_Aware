({
    loadLP : function(component, event, helper) {
	console.log(" Load Core and Elective Units ");
    document.body.scrollTop = 0;
    document.documentElement.scrollTop = 0;

    var userId = component.get("v.currentUserId");
    console.log("UserId: "+userId);
    component.set("v.showSpinner", true);
    //var userId = $A.get("$SObjectType.CurrentUser.Id");
    var action = component.get("c.initLoadUsersEnrollment");
    action.setParams({"accId" : component.get('v.AccountId'),
                      "EnroLLmentId" : component.get('v.EnrollmentId')
                    });

    action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            component.set("v.showSpinner", true);
            var storeResponse = response.getReturnValue();

            console.log('storeResponse==> ', storeResponse);
            
          	var NumbEnrolledUnitser = storeResponse['enrolledNoOfUnits'];
            
            component.set("v.getPackgetUnitList", storeResponse['learningPackageUnitList']);
            console.log('learningPackageUnitList: ' ,storeResponse['learningPackageUnitList']);
            component.set("v.getEnrollmentState", storeResponse['enroLLmentStates']);
            console.log('enrollment state and status: ' ,storeResponse['enroLLmentStates']);
            component.set("v.getEnrolledUnitList", storeResponse['enroLLedUnitList']);
            component.set("v.getEnrolmentRec", storeResponse['learningPackageDetails']); 

            //check if Learning package unit is only 1
            if (storeResponse['learningPackageUnitList'].length == 1) {
                component.set("v.showSpinner", true);
                //Create enrolment and call next
                console.log('size lpunits : ' ,storeResponse['learningPackageUnitList'].length);
                
                try {
                    var getlpuId = storeResponse['learningPackageUnitList'][0];
                    var LPUid = getlpuId['LPUId'];
                    console.log('LPUID is get? '+LPUid);
                } catch (err){
                    console.log("error: "+err);
                }
                
                console.log('LPUID is get? '+LPUid);
                console.log('Enrollment Id '+component.get('v.EnrollmentId'));
                console.log('Account Id '+component.get('v.AccountId'));
                
                var enroLunit = component.get('c.createEnrolledUnits');
               
                enroLunit.setParams({"acctId": component.get('v.AccountId'),
                                "EnrollmentId": component.get('v.EnrollmentId'),
                                "lpuID" : LPUid
                                });

                enroLunit.setCallback(this, function(a) {
                    var res = a.getReturnValue();
                    console.log('is succes? '+ res);
                    if (res == 'Enrolment success') {
                        component.set("v.showSpinner", true);
                        console.log('true? '+ res);
                        var cmpEvent = component.getEvent("Enrolment_Event");
                        var cmpEvent = $A.get("e.c:EnrolmentActiveStep");
                        cmpEvent.setParams({
                        enrolmentStep : "step10"});
                        cmpEvent.fire();
                    } else if (res == 'LPUId is null') {
                        component.set("v.showSpinner", true);
                        console.log('true? '+ res);
                        var cmpEvent = component.getEvent("Enrolment_Event");
                        var cmpEvent = $A.get("e.c:EnrolmentActiveStep");
                        cmpEvent.setParams({
                        enrolmentStep : "step10"});
                        cmpEvent.fire();
                    } 
                });
                $A.enqueueAction(enroLunit); 
            } else if (storeResponse['learningPackageUnitList'].length == 0) {

                        var cmpEvent = component.getEvent("Enrolment_Event");
                        var cmpEvent = $A.get("e.c:EnrolmentActiveStep");
                        cmpEvent.setParams({
                        enrolmentStep : "step10"});
                        cmpEvent.fire();

            } else { //else display the component, if learning package units are more than 1
                component.set("v.showSpinner", false);

                var getLearningPackageDetails = storeResponse['learningPackageDetails'];

                helper.NumberOfElectives = parseInt(getLearningPackageDetails['numberOfElectives']);

                var ramainingInt = parseInt(getLearningPackageDetails['numberOfElectives']) - NumbEnrolledUnitser ;
                component.set('v.countRemaining', ramainingInt );
                helper.RemainingPackage = ramainingInt; 
                component.set('v.countSelected',   NumbEnrolledUnitser  );

                var lPUnitMap = {};
                
                for( var i = 0 ; i <  storeResponse['learningPackageUnitList'].length ; i++ ){
                    var res = storeResponse['learningPackageUnitList'][i];
                    lPUnitMap[ res.LPUId ] = res.LPUId;
                    helper.UnitsIdObj[ res.LPUId ] = false; 
                }
                
                setTimeout( function() {
                    for( var i = 0; i < storeResponse['enroLLedUnitList'].length; i++ ){
                        var res = storeResponse['enroLLedUnitList'][i];

                        if( typeof lPUnitMap[ res.enrolledUnitgetUnitId ] !== 'undefined' ){
                            
                            if( typeof res.isElective !== 'undefined'   ){
                                if(res.isElective){
                                    helper.UnitsIdObj[ res.enrolledUnitgetUnitId ] = true; 
                                    console.log(lPUnitMap[ res.enrolledUnitgetUnitId ]);
                                    document.getElementById(""+lPUnitMap[ res.enrolledUnitgetUnitId ]).checked = true;
                                }
                            }
                        
                            
                        }   
                    } 
                }, 500);
            }
            

        }
        
    });
    $A.enqueueAction(action); 
    },
    
    manageLPUnits : function(component, event, helper) {

        var noOfElectives = component.get("v.noOfElectives");
        var ctSelected = component.get("v.countSelected");
        var LPId = component.get("v.LPId");
        var enroLLmentId =  component.get("v.getEnrolmentRec.enrolledId");
        //var LPUId = event.currentTarget.getAttribute("id");
        var LPUId = event.target.dataset.num;
    
        if (event.target.checked == true){
            if( helper.RemainingPackage == 0 ){
                event.target.checked = false;
            } else {
                helper.UnitsIdObj[ LPUId ] = true; 
            }
        } else {

            helper.UnitsIdObj[ LPUId ] = false; 
        } 

        var countSelected = 0;

        for (var key in helper.UnitsIdObj) {
            if( helper.UnitsIdObj[key]  ){
                countSelected +=1;
            }
        }

        var getRemaining = component.get('v.countRemaining');
        //console.log({countSelected});
        getRemaining = helper.NumberOfElectives - countSelected  ;
        
        helper.RemainingPackage = getRemaining;

        component.set('v.countSelected',  countSelected  );
        component.set('v.countRemaining',  getRemaining  );



 
    },
    saveAndEmail: function( cmp, event, helper ){
        cmp.set("v.showSpinner", true);
        var toastEvent = $A.get("e.force:showToast");
        // Object selectedUnitIdMap , Id learningPackage , Id EnrollmentId
        var action = cmp.get("c.createEnrollmenUnits");
        var f = false;
        
        action.setParams({"selectedUnitIdMap" :  helper.UnitsIdObj 
                         , "EnrollmentId": cmp.get('v.EnrollmentId')
                         , "acctId": cmp.get('v.AccountId')
                         , "sendMeLink" : f
                        });
                    
        action.setCallback(this, function(response) {
            var status = response.getState();
            if( status === "SUCCESS" ) {
                var rBody = response.getReturnValue();
                console.log( 'rBody', rBody );
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "Email has been sent"
                });
                toastEvent.fire();
                cmp.set("v.showSpinner", false);
                
            } else {
                cmp.set("v.showSpinner", false);
                // toastEvent.setParams({
                //     "title": "Error!",
                //     "type" : 'error',
                //     "message": "Please fill up the required fields!"
                // });
                // toastEvent.fire();
                console.log( response.getError() );
            }
        });
        $A.enqueueAction(action);
         
    },
    saveAndContinue: function( cmp, event, helper ){
    	cmp.set("v.showSpinner", true);
        // Object selectedUnitIdMap , Id learningPackage , Id EnrollmentId
        var action = cmp.get("c.createEnrollmenUnits");
        var t = true;

        action.setParams({"selectedUnitIdMap" :  helper.UnitsIdObj 
                         , "EnrollmentId": cmp.get('v.EnrollmentId')
                         , "acctId": cmp.get('v.AccountId')
                         , "sendMeLink" : t
                        });
    
        action.setCallback(this, function(response) {
            //alert('Save Complete');
            var status = response.getState();
            if( status === "SUCCESS" ) {
                var rBody = response.getReturnValue();
                console.log( 'rBody', rBody );
                cmp.set("v.showSpinner", false);
                helper.callNextStep( cmp, true );
            } else {
                cmp.set("v.showSpinner", false);
                // toastEvent.setParams({
                //     "title": "Error!",
                //     "type" : 'error',
                //     "message": "Please fill up the required fields!"
                // });
                // toastEvent.fire();
                console.log( response.getError() );
            }
        });
        $A.enqueueAction(action);
         
    },

    cancelcallback : function( cmp, event, helper ){
        cmp.set("v.showSpinner", true);
        
        var enrolId = cmp.get("v.EnrollmentId");
        var deleteEnrol = cmp.get("c.deleteEnrolment");

        deleteEnrol.setParams({
            "enrolId": enrolId
        });

        deleteEnrol.setCallback( this, function( response ) {
            var status = response.getState();
            if( status === "SUCCESS" ) {
                var rBody = response.getReturnValue();
                window.location.href = window.location.origin + '/s/my-enrolments';
            } else {
                console.log( response.getError() );
            }
            cmp.set("v.showSpinner", false);
        });
        $A.enqueueAction( deleteEnrol );

    },

    backCallback: function( cmp, event, helper ) {
        helper.backCallback( cmp );
    }
    
      
})