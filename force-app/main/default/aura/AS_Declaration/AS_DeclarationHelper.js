({
    doInit : function(cmp) {

        var canvas, ctx, flag = false,
            prevX = 0,
            currX = 0,
            prevY = 0,
            currY = 0,
            dot_flag = false;
    
        var x = "black",
            y = 2,
            w,h;

        canvas = cmp.find('can').getElement();
        
        var ratio = Math.max(window.devicePixelRatio || 1, 1);

        ctx = canvas.getContext("2d");

        ctx.canvas.height = 300;

        if( window.innerWidth > '768' ) {
            ctx.canvas.width  = 820;
        } else if( window.innerWidth > '425' ) {
            ctx.canvas.width  = 320;
        } else {
            ctx.canvas.width  = 280;
        }

        ctx.beginPath();
        ctx.fillStyle = '#fff';
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        ctx.closePath();
    
        canvas.addEventListener("mousemove", function (e) {
            findxy('move', e)
        }, false);

        canvas.addEventListener("mousedown", function (e) {
            findxy('down', e)
        }, false);

        canvas.addEventListener("mouseup", function (e) {
            findxy('up', e)
        }, false);

        canvas.addEventListener("mouseout", function (e) {
            findxy('out', e)
        }, false);

        // Set up touch events for mobile, etc
        canvas.addEventListener("touchstart", function (e) {
            var touch = e.touches[0];
            console.log('touch start:='+touch);
            var mouseEvent = new MouseEvent("mousedown", {
                clientX: touch.clientX,
                clientY: touch.clientY
            });
            canvas.dispatchEvent(mouseEvent);

            var textcenter = cmp.find('sigtextcenter').getElement();
            textcenter.style = "display:none";

            e.preventDefault();
        }, false);
        
        canvas.addEventListener("touchend", function (e) {
            var mouseEvent = new MouseEvent("mouseup", {});
            canvas.dispatchEvent(mouseEvent);
        }, false);
        canvas.addEventListener("touchmove", function (e) {
            var touch = e.touches[0];
            var mouseEvent = new MouseEvent("mousemove", {
                clientX: touch.clientX,
                clientY: touch.clientY
            });
            canvas.dispatchEvent(mouseEvent);
            e.preventDefault();
        
        }, false);
    
        // Get the position of a touch relative to the canvas
        function getTouchPos(canvasDom, touchEvent) {
            var rect = canvasDom.getBoundingClientRect();
            return {
                x: touchEvent.touches[0].clientX - rect.left,
                y: touchEvent.touches[0].clientY - rect.top
            };
        }
    
        function findxy(res, e){
            const rect = canvas.getBoundingClientRect();
            if (res == 'down') {
                prevX = currX;
                prevY = currY;
                currX = e.clientX - rect.left ;
                currY = e.clientY -  rect.top;
            
                flag = true;
                dot_flag = true;
                if (dot_flag) {
                    ctx.beginPath();
                    ctx.fillStyle = x;
                    ctx.fillRect(currX, currY, 2, 2);
                    ctx.closePath();
                    dot_flag = false;
                }
            }
            if (res == 'up' || res == "out") {
                flag = false;
            }
            if (res == 'move') {
                if (flag) {
                    prevX = currX;
                    prevY = currY;
                    currX = e.clientX -  rect.left;
                    currY = e.clientY - rect.top;
                    draw(cmp,ctx);
                }
            }
        }
        function draw() {
            
            var textcenter = cmp.find('sigtextcenter').getElement();
            textcenter.style = "display:none";

            ctx.beginPath();
            ctx.moveTo(prevX, prevY);
            ctx.lineTo(currX, currY);
            ctx.strokeStyle = x;
            ctx.lineWidth = y;
            ctx.stroke();
            ctx.closePath();
        }
   
    },
    eraseHelper : function(cmp, event, helper){

        var canvas = cmp.find('can').getElement();
        var textcenter = cmp.find('sigtextcenter').getElement();

        var ctx = canvas.getContext("2d");
        var w = canvas.width;
        var h = canvas.height;
        ctx.clearRect(0, 0, w, h);

        textcenter.style = "display:block";
    },
    saveHelper : function(cmp, sendemail){
        cmp.set("v.showSpinner", true);
        var pad=cmp.find('can').getElement();
        var dataUrl = pad.toDataURL();
  
        var permissionPub = cmp.get('v.permissionPub');
        var optedout = cmp.get('v.optedout');

        var strDataURI = dataUrl.replace(/^data:image\/(png|jpg);base64,/, "");

        var action = cmp.get("c.saveSignature");

        var accountId = cmp.get('v.accountId');
        var enrolId = cmp.get('v.enrolId');

        var toastEvent = $A.get("e.force:showToast");
        if( typeof permissionPub != 'string' ) {

            toastEvent.setParams({
                "title": "Error!",
                "type" : "error",
                "message": "PSA promotions/publications is required"
            });
            toastEvent.fire();

            return;
        }

        var permissionPub = {
            'AS_Permission_to_Publish__c' : permissionPub
        }

        var optedout = {
            'PersonHasOptedOutOfEmail' : optedout
        }
        
        action.setParams({
            'accountId' : accountId,
            'enrolId'   : enrolId,
            'signatureBody' : strDataURI,
            'permissionPub' : JSON.stringify( permissionPub ),
            'optedout' : JSON.stringify( optedout ),
            sendmelink : sendemail
        });
        action.setCallback(this,function(res){
            var state = res.getState();
            var idval = res.getReturnValue();

            if( state ==="SUCCESS" ){
                cmp.set("v.showSpinner", false);
                if( sendemail ) {
                    toastEvent.setParams({
                        "title": "Success!",
                        "type" : "success",
                        "message": "Email has been sent!"
                    });
                    toastEvent.fire();
                } else {
                    this.callNextStep( cmp, true );
                }
            } else {
                console.log( 'error', res.getError() );
                cmp.set("v.showSpinner", false);
                toastEvent.setParams({
                    "title": "Error!",
                    "type" : "error",
                    "message": "Error occured, please try again later or contact administrator!"
                });
                toastEvent.fire();
            }
        });       
        $A.enqueueAction(action);
    },
    getEnrolState : function(cmp, event ) {

        var enrolStateCallback = cmp.get('c.getFieldEnrolState');
        var enrolId = cmp.get('v.enrolId');

        enrolStateCallback.setParams({
            'recordID' : enrolId
        });

        enrolStateCallback.setCallback(this, function(res){
            var state = res.getState();
            var reval = res.getReturnValue();

            console.log('call getEnrolState', reval);
            console.log('call state', state);

            if( state ==="SUCCESS" ) {

                if( typeof reval['AS_Permission_to_Publish__c'] == 'boolean' ) {
                    cmp.set('v.permissionPub', ( reval['AS_Permission_to_Publish__c'] ) ? 'true' : 'false' );
                }

                if( reval['AS_Enrollment_State__c'] == 'VIC' ) {
                    cmp.set('v.isVic', true);
                }

                cmp.set( 'v.enrolStatus', reval['Enrolment_Status__c'] );

                //helper.getAccountEmailOpt(cmp, event);  

            } else {
 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type" : "error",
                    "message": "Enrolment ID not recognized"
                });
                toastEvent.fire();
            }
            cmp.set("v.showSpinner", false);
        });       
        $A.enqueueAction(enrolStateCallback);
    },
    getAccountEmailOpt : function(cmp, event ) {
        
        var accountId = cmp.get('v.accountId');
 
        var getFieldAccount = cmp.get('c.getFieldAccount');

        getFieldAccount.setParams({
            'accountID' : accountId
        });

        getFieldAccount.setCallback(this, function(res){
            var state = res.getState();
            var reval = res.getReturnValue();

            console.log('call getAccountEmailOpt', reval);
            console.log('call state', state);

            if( state ==="SUCCESS" ) {
                if( typeof reval['PersonHasOptedOutOfEmail'] == 'boolean' ) {
                    cmp.set('v.optedout', reval['PersonHasOptedOutOfEmail'] );
                }
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type" : "error",
                    "message": "Account ID not recognized"
                });
                toastEvent.fire();
            }
        }); 
        $A.enqueueAction(getFieldAccount);
    },

    callNextStep :function(cmp, iscompleted) {
        var cmpEvent = cmp.getEvent("Enrolment_Event");
        var cmpEvent = $A.get("e.c:EnrolmentActiveStep");

        var nextstep = ( iscompleted ) ? 'step13 - completed' : 'step13'; 

        cmpEvent.setParams({
            enrolmentStep : nextstep});
        cmpEvent.fire();
    },

    backCallback: function( cmp ) {
        var cmpEvent = cmp.getEvent("Enrolment_Event");
        var cmpEvent = $A.get("e.c:EnrolmentActiveStep");
        cmpEvent.setParams({
            enrolmentStep : "step11 - back"});
        cmpEvent.fire();
    }

})