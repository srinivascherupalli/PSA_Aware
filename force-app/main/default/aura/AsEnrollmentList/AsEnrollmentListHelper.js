({
	getEnrolUnit : function( cmp, enrolId ) {

        var action = cmp.get("c.getEnrolUnit");
		var subdata = cmp.get('v.subdata');
        var objArr = [];
        
        action.setParams({
            "enrolmentId" : enrolId
       	});

        action.setCallback(this, function(response) {
            
            var state = response.getState();
			var rows = response.getReturnValue();
            
            if ( state === "SUCCESS" ) {
                
                for (var i = 0; i < rows.length; i++){
                    if(rows[i].AS_Unit__c != null){
                        var settxt = rows[i].AS_Unit__r.Name;
                        var setnameupppercase = settxt.charAt(0).toUpperCase() + settxt.slice(1);
                        
                        rows[i].Unit = setnameupppercase;
                        rows[i]['enrolid'] = enrolId;
                    }
                    
					objArr.push(rows[i]);
                }
            } else {
                  console.log('error', rows);
            }
        });
        
        $A.enqueueAction(action);
        
       return objArr;
		
	},
    enrolListCallback : function( cmp, userid ) {
        
        var getAccountEnrol = cmp.get( 'c.getAccountEnrol' );
        //var accountId = cmp.get('v.accountId');
        
        getAccountEnrol.setParams({
            'accountId' : userid
        });
        
        getAccountEnrol.setCallback(this, function(response) {
            
            var state = response.getState();
            
			var reval = response.getReturnValue();
            
            if (state === "SUCCESS") {

                for( var x = 0,newObj = []; x < reval.length; x++ ) {
					newObj[x] = this.getEnrolUnit( cmp, reval[x].Id );
                    
                    if( reval[x].Enrolment_Status__c == 'Draft') {
                        reval[x].Enrolment_Status__c = 'Continue with your application';
                        reval[x]['class'] = 'slds-draft-btn';
                    }
                    
                    if( reval[x].Enrolment_Status__c == 'Pending Payment') {
						reval[x]['class'] = 'slds-pending-payment-btn';
					}
                    
					if( reval[x].Enrolment_Status__c == 'Pending') {
						reval[x]['class'] = 'slds-pending-btn';
					}
 
                }

                cmp.set("v.data", reval);

                var newArr = [];

                setTimeout(function() {
                    for( var y = 0; y < newObj.length; y++ ) {
                        for( var z = 0,n = newObj[y]; z < n.length; z++ ) {
                      		 newArr.push(n[z]);
                        }
                    }
                    cmp.set('v.subdata', newArr );
                    cmp.set('v.showtable', true );
				}, 1000);

            } else {
                console.log( 'reval' , reval );
            }
        });
        
        $A.enqueueAction(getAccountEnrol);
    },
    getUserCallback : function( cmp, event ) {

        var func = cmp.get('c.getCurrentUser');

        func.setCallback(this, function(res) {
            
            var state = res.getState();
			var userid = res.getReturnValue();
            
            if ( state === "SUCCESS" ) {

                cmp.set('v.accountId', userid );
                this.enrolListCallback( cmp, userid );
            } else {
                console.log('error', userid);
            }
        });

        $A.enqueueAction(func);
    }
})