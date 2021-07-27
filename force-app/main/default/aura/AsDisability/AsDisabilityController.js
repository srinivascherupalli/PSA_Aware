({
    init : function( cmp, event, helper ) {
       
        helper.getCurrentEnrolment( cmp );
        helper.getPicklistOption( cmp, 'AS_disability_type__c', 'Account', 'disabilityType', true );
        helper.getAccount( cmp );
        
        document.body.scrollTop = 0;
        document.documentElement.scrollTop = 0;
    },

    disabilityChange: function( cmp, event, helper ) {
        var disTerm = cmp.get( 'v.disabilityLongTermVal' );
        if ( disTerm == 'true' ) {

            cmp.set( 'v.disabilitylongtermcondition', true );
            cmp.set( 'v.isRequired', true );
            
        } else {

            cmp.set( 'v.disabilitylongtermcondition', false );
            cmp.set( 'v.disabilityTypeValue', '' );
            cmp.set( 'v.otherdisabilityif', false );

            for(var x = 0, z = cmp.get('v.disabilityTypeArr'), newArr = []; x < z.length; x++ ) {
                z[x].value = '';
                z[x].title = 'false';

                newArr[x] = z[x];
            }

            cmp.set('v.disArray', [] );

            for( var i = 0, y = cmp.find('disability-custom'); i < y.length; i++ ) {
                console.log('y[i]',  y[i] );
                y[i].set('v.title', 'false' );
            }

            cmp.set('v.otherDisabilityTypeValue', '' );

            cmp.set('v.disabilityTypeArr', newArr );
           
        }
    },

    disabilityTypeChange: function( cmp, event, helper ) {
        var disability = cmp.get( 'v.disabilityTypeValue' );
        if ( disability == 'Other' ) {
            cmp.set( 'v.otherdisabilityif', true );
            cmp.set( 'v.isRequiredOther', true );
        } else {
            cmp.set( 'v.otherdisabilityif', false );
            cmp.set( 'v.otherDisabilityTypeValue', '' );
            cmp.set( 'v.isRequiredOther', false );
        }
    },

    saveChanges: function( cmp, event, helper ) {

        var toastEvent = $A.get("e.force:showToast");

        var disabilityArr = cmp.get('v.disabilityTypeValue');

        var allValid = false;

        try{ 

        if( cmp.find('disability-field-1').get('v.value') == 'false' ) {
            allValid = true;
        } else if( typeof disabilityArr != 'undefined' &&  disabilityArr.length > 0 ) {
            console.log('disabilityArr', disabilityArr.length );
            allValid = true;

            disabilityArr = disabilityArr.split(';');

            console.log('disabilityArr', disabilityArr );

            if( disabilityArr.indexOf('Other') > -1 ) {
                if( cmp.get('v.otherDisabilityTypeValue').length == 0 ) {
                    allValid = false;
                }
            }
        }
        console.log( 'allValid', allValid );
        if(  !allValid ) {
            toastEvent.setParams({
                "title": "Error!",
                "type" : 'error',
                "message": "Please fill up the required fields!"
            });
            toastEvent.fire();
        } else {
            helper.saveChangesHelper( cmp, false );
        }
        } catch( err ) {
            console.log('err', err );
        }
    },

    sendMeLinkChanges: function( cmp, event, helper ) {
        var toastEvent = $A.get("e.force:showToast");

        var allValid = false;

        if( cmp.find('disability-field-1').get('v.value') == 'false' ) {
            allValid = true;
        } else if( cmp.find('disability-field-2').get('v.value').length > 0 ) {
            allValid = true;
            if( cmp.find('disability-field-2').get('v.value') == 'Other' ) {
                if( cmp.find('disability-field-3').get('v.value').length == 0 ) {
                    allValid = false;
                }
            }
        }

        if(  !allValid ) {
            toastEvent.setParams({
                "title": "Error!",
                "type" : 'error',
                "message": "Please fill up the required fields!"
            });
            toastEvent.fire();
            //alert("Please fill up the required fields!");
        } else {
            helper.saveChangesHelper( cmp, true );
        }
    },

    cancelCallback : function( cmp, event, helper ) {
        
        cmp.set("v.showSpinner", true);
        
        var enrolId = cmp.get("v.recordIdEnrol");
        var deleteEnrol = cmp.get("c.deleteEnrolment");
        var toastEvent = $A.get("e.force:showToast");

        deleteEnrol.setParams({
            "enrolId": enrolId
        });

        deleteEnrol.setCallback( this, function( response ) {
            var status = response.getState();
            if( status === "SUCCESS" ) {
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
            cmp.set("v.showSpinner", false);
        });
        $A.enqueueAction( deleteEnrol );

    },
     
    backCallback: function( cmp, event, helper ) {
        helper.backCallback( cmp );
    },

    disabilityfunc : function( cmp, event, helper ) {

        var count = event.getSource().get('v.class');

        var disability = event.getSource().get('v.label');

        var enrol = cmp.get('v.enrolment');

        event.getSource().set('v.class', count + 1 );

        if( count == 1 ) {

            var disArray = cmp.get('v.disArray');

            console.log('disArray', disArray );

            console.log("disArray.indexOf(disability) == -1", disArray.indexOf(disability) == -1 );
            
            if( event.getSource().get('v.title') == 'false' ) {
        
                if( disArray.indexOf(disability) == -1 ) {
                    disArray.push(disability);
                }

                event.getSource().set('v.title', 'true' );
                event.getSource().set('v.value', disability );

            } else {

                event.getSource().set('v.title', 'false' );
                event.getSource().set('v.value', '' );

                if( disArray.indexOf(disability) > -1 ) {
                    disArray.splice( disArray.indexOf(disability), 1 );
                }
            }

            if( disArray.indexOf('Other') > -1 && disability == 'Other' &&  event.getSource().get('v.title' ) == 'true' ) {

                cmp.set( 'v.otherdisabilityif', true );
                cmp.set( 'v.isRequiredOther', true );

            } else if( disability == 'Other'  &&  event.getSource().get('v.title' ) == 'false' ) {

                cmp.set( 'v.otherdisabilityif', false );
                cmp.set( 'v.otherDisabilityTypeValue', '' );
                cmp.set( 'v.isRequiredOther', false );
            }

            console.log('disArray', disArray );

            cmp.set('v.disabilityTypeValue', disArray.join(';'));

            event.getSource().set('v.class', 0 );

        }

     
    }

});