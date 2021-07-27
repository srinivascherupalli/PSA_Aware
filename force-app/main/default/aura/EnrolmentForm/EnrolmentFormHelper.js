({
    accountfunc : function( cmp, accountId ) {

        var func = cmp.get("c.getAccountInfo");

        accountId = ( typeof accountId == 'undefined' ) ? cmp.get('v.accountId') : accountId;

        func.setParams({
            "recordID": accountId
        });

        func.setCallback( this,function( res ){
            var status = res.getState();

            if(status === "SUCCESS"){

                var qresult = res.getReturnValue();
                cmp.set("v.account",qresult); 
            }
        });
        $A.enqueueAction(func);
    },
    enrolfunc : function( cmp, enrolId ) {
        
        enrolId = ( typeof enrolId == 'undefined' ) ? cmp.get('v.enrolId') : enrolId;

        var func = cmp.get("c.getEnrolmentInfo");

        func.setParams({
            "recordID": enrolId
        });

        func.setCallback( this,function( res ){
            var status = res.getState();

            if(status === "SUCCESS"){

                var qresult = res.getReturnValue();

                if( qresult.Enrolment_Status__c == 'Draft' ) {
                    if( typeof qresult.AS_Enrolment_Stage__c != 'undefined' ) {
                        cmp.set('v.currentStep', 'step' + qresult.AS_Enrolment_Stage__c.match(/\d+/)[0] );
                    }
                }
    
                cmp.set( "v.enrolment", qresult );
                cmp.set( "v.isloaded", true );

            } else {
                console.log('err', res.getError() );
            }
        });
        $A.enqueueAction(func);

    },

    preTrainfunc : function( cmp, enrolId ) {

        enrolId = ( typeof enrolId == 'undefined' ) ? cmp.get('v.enrolId') : enrolId;

        var func = cmp.get("c.getTrainingReview");
        
        func.setParams({
            "recordID": enrolId
        });

        func.setCallback( this, function( res ){
            var status = res.getState();
            if(status === "SUCCESS"){
                var qresult = res.getReturnValue();
                cmp.set("v.preTrainId",qresult); 
            }
        });
        $A.enqueueAction(func);
    },
    getUnitFunc : function(cmp, accountId, enrolmentId) {

        var action = component.get("c.initLoadUsersEnrollment");

        action.setParams({
            "accId" : accountId,
            "EnroLLmentId" :enrolmentId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            console.log('in');

            // console.log('state', state );

            // if (state === "SUCCESS") {

            //     var storeResponse = response.getReturnValue();
            //     console.log( 'storeResponse', storeResponse );
            //     if (storeResponse['learningPackageUnitList'].length > 1) {
            //         console.log('more than one');
            //     } else {
            //         console.log('only one')
            //     }
            // }
            
        });
        $A.enqueueAction(action); 
    },
    getQueryParams : function( name ) { 
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS );
        var results = regex.exec( url );
        return results == null ? null : results[1];
    }
     
})