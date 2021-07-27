({
    helperMethod : function() {

    },

    getCurrentEnrolment: function( cmp ) {

        var recordID = cmp.get("v.recordIdEnrol");
        var enrolInfo = cmp.get("c.getEnrolmentInfo");

        enrolInfo.setParams({
            "recordID": recordID
        });

        enrolInfo.setCallback(this,function(response){
            var status = response.getState();
            if( status === "SUCCESS" ) {
                var qresult = response.getReturnValue();
                if(qresult != null){
                    var arrkeys = Object.keys( qresult );
                    for( var x = 0, newArr = {}; x < arrkeys.length; x++ ) {
                        if( typeof qresult[arrkeys[x]] == 'boolean' ) {
                            newArr[arrkeys[x]] = ( qresult[arrkeys[x]] ) ? 'true' : 'false';
                        } else {
                            newArr[arrkeys[x]] = qresult[arrkeys[x]];
                        }
                    }
                   
                }
                cmp.set("v.enrolment",newArr);
            }
        });
        $A.enqueueAction(enrolInfo);
    },

    getAccount : function( cmp, recordId ) {

        var getFieldCallback = cmp.get( 'c.getAccountFields' );
        var recordId = cmp.get("v.recordId");

        getFieldCallback.setParams({
            'recordID' : recordId
        });

        getFieldCallback.setCallback( this, function(response) {

            var state = response.getState();
            var fieldval = response.getReturnValue();

            if( state === 'SUCCESS' ) {

                var arrkeys = Object.keys( fieldval );
                for( var x = 0, newArr = {}; x < arrkeys.length; x++ ) {
                    if( typeof fieldval[arrkeys[x]] == 'boolean' ) {
                        newArr[arrkeys[x]] = ( fieldval[arrkeys[x]] ) ? 'true' : 'false';
                    } else {
                        newArr[arrkeys[x]] = fieldval[arrkeys[x]];
                    }
                }
                
                cmp.set( 'v.account', newArr );
                //cmp.set('v.otherlanguageif', ( newArr.AS_BG_Speaks_Languages_Other_Than_Englis__pc == 'true' ) ? true : false ); 
                //cmp.set('v.otherdisabilityif', ( newArr.AS_disability_type__c == 'Other' ) ? true : false );
                //cmp.set('v.disabilitylongtermcondition', ( newArr.AS_Has_Disability_Impairment_or_Long_Ter__pc == 'true' ) ? true : false );

                // populate disability field
                //this.populateDisabilityType( cmp );
                this.populateDisabilityLongTerm( cmp );

            } else {
                console.log('error', returnvar);
            }
        } );

        $A.enqueueAction(getFieldCallback);

    },

    getPicklistOption : function( cmp, picklistname, objname, fieldname, isRadio ) {
        cmp.set("v.showSpinner", true);

        console.log('picklist');
        var getpicklistVal = cmp.get("c.getPicklistValue");

        getpicklistVal.setParams({
            "fieldname": picklistname,
            "objectname": objname
        });

        getpicklistVal.setCallback(this,function(response){
            var status = response.getState();
            console.log('state', status );
            if( status === "SUCCESS" ) {
                var qresult = response.getReturnValue();

                var reArr = [
                    'Hearing impairment is used to refer to a person who has an acquired mild, moderate, severe or profound hearing loss after learning to speak, communicates orally and maximises residual hearing with the assistance of amplification. A person who is deaf has a severe or profound hearing loss from, at, or near birth and mainly relies upon vision to communicate, whether through lip reading, gestures, cued speech, finger spelling and/or sign language.',
                    'A physical disability affects the mobility or dexterity of a person and may include a total or partial loss of a part of the body. A physical disability may have existed since birth or may be the result of an accident, illness, or injury suffered later in life; for example, amputation, arthritis, cerebral palsy, multiple sclerosis, muscular dystrophy, paraplegia, quadriplegia or post-polio syndrome.',
                    'Mental illness refers to a cluster of psychological and physiological symptoms that cause a person suffering or distress and which represent a departure from a person’s usual pattern and level of functioning',
                    'Acquired brain impairment is injury to the brain that results in deterioration in cognitive, physical, emotional or independent functioning. Acquired brain impairment can occur as a result of trauma, hypoxia, infection, tumour, accidents, violence, substance abuse, degenerative neurological diseases or stroke. These impairments may be either temporary or permanent and cause partial or total disability or psychosocial maladjustment',
                    'This covers a partial loss of sight causing difficulties in seeing, up to and including blindness. This may be present from birth or acquired as a result of disease, illness or injury.',
                    'Medical condition is a temporary or permanent condition that may be hereditary, genetically acquired or of unknown origin. The condition may not be obvious or readily identifiable, yet may be mildly or severely debilitating and result in fluctuating levels of wellness and sickness, and/or periods of hospitalisation; for example, HIV/AIDS, cancer, chronic fatigue syndrome, Crohn’s disease, cystic fibrosis, asthma or diabetes.',
                    'A disability, impairment or long-term condition which is not suitably described by one or several disability types in combination. Autism spectrum disorders are reported under this category.'
                ];

                if ( isRadio ) {
                    
                    var disabilityList = cmp.get('v.enrolment').AS_Details_of_Disability__c;

                    var dis = '';

                    if( typeof disabilityList != 'undefined' ) {
                        dis = cmp.get('v.enrolment').AS_Details_of_Disability__c,
                        dis = dis.split(';');
                    }
                    
                    var disArr = cmp.get('v.disArray');

                    for( var y = 0, thisArr = [] ,arrNew = [], labelarr = [], isTrue = false, disvar = ''; y < qresult.length; y++ ) {
                        
                        if( dis.length > 0 ) {
                            isTrue = ( dis.indexOf(qresult[y]) > -1 );

                            disvar = ( isTrue ) ? dis[dis.indexOf(qresult[y])] : '';

                            if( isTrue ) {
                                disArr.push( dis[dis.indexOf(qresult[y])] );
                                cmp.set('v.disArray', disArr );
                            }
                        }

                        thisArr[y] = {
                            'label' : qresult[y],
                            'helptext' : reArr[y],
                            'value' : disvar,
                            'checked' : ( isTrue ) ? 'true' : 'false',
                            'count' : 0,
                            'options' : [
                                { 'label' : '', 'value' : qresult[y] }
                            ]
                        }

                        labelarr.push( qresult[y] );
                    }

                    for( var i = 0; i < dis.length; i++ ) {
                        if( labelarr.indexOf(dis[i]) == -1 ) {

                            thisArr['6'].checked = 'true';
                            thisArr['6'].value = 'Other';

                            cmp.set('v.otherdisabilityif', true );
                            cmp.set('v.otherDisabilityTypeValue', dis[i] );
                            cmp.set('v.isRequiredOther', true );

                            disArr.push('Other');
                            
                        }
                    }

                    console.log('thisArr', thisArr );

                    cmp.set('v.disabilityTypeValue', disabilityList );

                    arrNew = Object.assign( [], thisArr );

                    cmp.set('v.disabilityTypeArr', arrNew );

                } else {
                    cmp.set( 'v.' + fieldname, qresult );
                }
            }
            cmp.set('v.showSpinner', false );
        });
        $A.enqueueAction(getpicklistVal);
    },
 
    populateDisabilityType : function( cmp ) {

        var accObj = cmp.get( 'v.account' );
        var enrolObj = cmp.get( 'v.enrolment' );
        var disabilityTypeArr = cmp.get( 'v.disabilityTypeArr' );
        
        if( accObj == null ) return;
        if( enrolObj == null ) return;

        var detailsVal = '';
        var otherDisVal = '';

        if ( enrolObj.AS_Details_of_Disability__c != null && enrolObj.AS_Details_of_Disability__c != '' ) {
            detailsVal = enrolObj.AS_Details_of_Disability__c;
        } else if( accObj.AS_disability_type__c != null && accObj.AS_disability_type__c != '' ) {
            detailsVal = accObj.AS_disability_type__c;
        }

        if ( detailsVal != '' ) {
            var typ = [];
            for( var i = 0; i < disabilityTypeArr.length; i++ ) {
                if( typeof disabilityTypeArr[i].label != 'null' && typeof disabilityTypeArr[i].label != 'undefined' ) {
                    typ.push( disabilityTypeArr[i].label );
                }
            }
 
            if ( !typ.includes( detailsVal ) ) {
                otherDisVal = detailsVal;
                detailsVal = 'Other';
            }
        }

        if ( detailsVal == 'Other' ) {
            cmp.set( 'v.otherdisabilityif', true );
        }

        if( typeof enrolObj.AS_Has_Disability__c != 'undefined' ) {
            if( enrolObj.AS_Has_Disability__c == 'false' ) {
                detailsVal = '';
            }
        } else if( typeof accObj.AS_Has_Disability_Impairment_or_Long_Ter__c != 'undefined' ) {
            
            if( accObj.AS_Has_Disability_Impairment_or_Long_Ter__c == 'false' ) {
                detailsVal = '';
            }
        }

        cmp.set( 'v.disabilityTypeValue', detailsVal );
    
        cmp.set( 'v.otherDisabilityTypeValue', otherDisVal );
    },

    populateDisabilityLongTerm : function( cmp ) {

        var accObj = cmp.get( 'v.account' );
        var enrolObj = cmp.get( 'v.enrolment' );

        if( accObj == null ) return;
        if( enrolObj == null ) return;

        var LongTerm = 'false';

        if ( enrolObj.AS_Has_Disability__c == 'true' ) {
            LongTerm = 'true';
        } else if( accObj.AS_Has_Disability_Impairment_or_Long_Ter__c == 'true' ) {
            LongTerm = 'true';
        }

        if ( LongTerm == 'true' ) {
            cmp.set( 'v.disabilitylongtermcondition', true );
            cmp.set( 'v.isRequired', true );
        }
        
        cmp.set( 'v.disabilityLongTermVal', LongTerm );
    },

    saveChangesHelper: function( cmp, sendmelink ) {

        cmp.set("v.showSpinner", true);

        var toastEvent = $A.get("e.force:showToast");
        var disability = cmp.get( 'v.disabilityTypeValue' );
        var disabilityOther = cmp.get( 'v.otherDisabilityTypeValue' );
        var disabilityLongTerm = cmp.get( 'v.disabilityLongTermVal' );

        var enrolId = cmp.get("v.recordIdEnrol");
        var recordId = cmp.get("v.recordId");

        var disArr = [];

        if( typeof disability != 'undefined' ) {

            disArr = disability.split(';');
    
            if( disArr.indexOf('Other') > -1 ) {
                disArr.splice(disArr.indexOf('Other'), 1 );
            }
        }

        if ( typeof disabilityOther != 'undefined' ) {
            disArr.push(disabilityOther);
        }

        var enrolInfo = {
            'AS_Details_of_Disability__c' : disArr.join(';').slice(0, -1),
            'AS_Has_Disability__c' : ( disabilityLongTerm == 'true' ? true : false )
        };

        var saveChanges = cmp.get("c.saveEnrolChanges");

        saveChanges.setParams({
            "enrolId": enrolId,
            "accId" : recordId,
            "enrolRecord" : enrolInfo,
            "sendmelink" : sendmelink
        });

        saveChanges.setCallback( this, function( response ) {
            var status = response.getState();

            if( status === "SUCCESS" ) {
                var rBody = response.getReturnValue();
                cmp.set("v.showSpinner", false);

                if( sendmelink ) {
                    toastEvent.setParams({
                        "title": "Success!",
                        "type" : 'success',
                        "message": "Email has been sent!"
                    });
                    toastEvent.fire();
                } else {
                    this.callNextStep(cmp, true );
                }
            } else {
                cmp.set("v.showSpinner", false);
                toastEvent.setParams({
                    "title": "Error!",
                    "type" : 'error',
                    "message": "Error occured, please try again!"
                });
                toastEvent.fire();
                //console.log( response.getError() );
            }
        });
        $A.enqueueAction( saveChanges );

    },
    
    callNextStep :function(cmp, iscompleted) {
        var cmpEvent = cmp.getEvent("Enrolment_Event");
        var cmpEvent = $A.get("e.c:EnrolmentActiveStep");

        var nextstep = ( iscompleted ) ? 'step6 - completed' : 'step6';
        cmpEvent.setParams({
            enrolmentStep : nextstep});
        cmpEvent.fire();
    },

    backCallback: function( cmp ) {
        var cmpEvent = cmp.getEvent("Enrolment_Event");
        var cmpEvent = $A.get("e.c:EnrolmentActiveStep");
        cmpEvent.setParams({
            enrolmentStep : "step4 - back"});
        cmpEvent.fire();
    }
})