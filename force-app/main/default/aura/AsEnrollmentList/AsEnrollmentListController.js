({
	displayData : function( cmp, event, helper ) {
        helper.getUserCallback( cmp, event );
	},
	ShowInfo : function(cmp, event, helper){
        
		event.getSource().set('v.value', ( ! Boolean( event.getSource().get('v.value') ) ) ? true : false );  
        
        event.getSource().set('v.iconName', ( ! Boolean( event.getSource().get('v.value') ) ) ? 'utility:chevrondown' : 'utility:chevronright' );
      
        for( var x = 0, isdefined = false, item = event.target.parentElement.childNodes; x < item.length; x++ ) {
            if( item[x].nodeName == 'TABLE' ) {
                isdefined = true;
                item[x].style =  ( ! Boolean( event.getSource().get('v.value') ) ) ? 'display: block' : 'display: none';
            }
        }

        if( ! isdefined ) {
            event.target.parentElement.nextSibling.style.display = ( ! Boolean( event.getSource().get('v.value') ) ) ? 'block' : 'none';
        }
	},
    statusCallback : function(cmp, event, helper) {
        var eventTarget =  event.target.outerText;

        var accountId = cmp.get('v.accountId');

        var enrolId = event.getSource().get('v.value');

        //var learningId = event.getSource().get('v.name');

		if( eventTarget == 'Continue with your application' || eventTarget == 'Pending' || eventTarget == 'Pending Payment' ) {
            window.open( window.location.origin + '/s/enrolment-form?accountid=' + accountId + '&enrolid=' + enrolId ); 
        }
    },
    launchCallback : function(cmp, event, helper) {
   
         window.open( encodeURI( window.location.origin + '/s/detail/'+ event.getSource().get('v.name') ) ); 
        
    }
})