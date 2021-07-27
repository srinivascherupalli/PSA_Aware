({
	doInit : function(component, event, helper) {
		var Id = component.get( "v.recordId" ); 
        var url = location.href;  // entire url including querystring - also: window.location.href;
        var baseURL = url.substring(0, url.indexOf('/', 14));
        var toLower = url.toLowerCase();
        console.log(url + " - " + baseURL + " - " + toLower);
        /*
        if(toLower.indexOf("membership") !=-1) {
           	
          //  window.open('/membership/AsPsaCpdPlanningTool?cpdId='+Id, '_blank');
          window.open('/membership/s/cpd-planning-tool?cpdId='+Id, '_blank');
          
        } else {
            window.open(baseURL+'/apex/AsPsaCpdPlanningTool?cpdId='+Id, '_blank');
        }
        */
        
        
        if(toLower.indexOf("membership") !=-1) {
        	
        	var urlEvent = $A.get("e.force:navigateToURL");
		    urlEvent.setParams({
		        "url": "/cpd-planning-tool?cpdId="+Id
		    });
		    urlEvent.fire();
		    $A.enqueueAction(component.get('c.hidemodal'));
        } else {
            window.open(baseURL+'/apex/AsPsaCpdPlanningTool?cpdId='+Id, '_blank');
        }
	},
	hidemodal : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})