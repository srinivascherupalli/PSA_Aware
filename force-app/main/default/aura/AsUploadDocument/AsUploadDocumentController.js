({
    doInit : function(component, event, helper) {

        helper.getEnrolInfo( component, helper );

        helper.getdomcumentValues(component,helper,function( res ){
           
            if( res['lpDocPicklistValue'].length == 0 ){
               helper.callNextStep(component); 
            } else {
                component.set('v.priceBooksList',res['lpDocPicklistValue']);
            }

        });

        document.body.scrollTop = 0;
        document.documentElement.scrollTop = 0;
        
    },
	cancelCallback : function( cmp, event, helper ) {
        
        cmp.set("v.showSpinner", true); 
     
        var deleteEnrol = cmp.get("c.deleteEnrolment");

        deleteEnrol.setParams({
            "enrolId": cmp.get("v.parentId")
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

    },backCallback: function( cmp, event, helper ) {
        helper.backCallback( cmp );
    },saveRecord: function( component, event, helper ){
        /*var slides = document.getElementsByClassName("upload-file-name");
        for(var i = 0; i < slides.length; i++)
        { 
        console.log(slides.item(i).dataset.filename);
        console.log(slides.item(i).innerHTML);
        }*/
        helper.saveChanges( component , false ); 
    },
    saveSendLink: function( component, event, helper ){
		 helper.saveChanges( component , true );
    }

})