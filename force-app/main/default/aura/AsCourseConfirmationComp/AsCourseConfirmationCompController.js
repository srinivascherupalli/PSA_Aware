({
    init : function (component) {
        // Find the component whose aura:id is "flowData"
        var flow = component.find("flowData");
        
        var inputVariables = [
         { name : "AccountID", type : "String", value: '001N000001JwP6oIAF' },
          { name : "ProductID", type : "String", value: '01tN0000004rB6l' }
        ]
        
        // In that component, start your flow. Reference the flow's Unique Name. 
        flow.startFlow("CourseConfirmation",inputVariables);
    },
    handleStatusChange : function (component, event) {
        if(event.getParam("status") === "FINISHED") { 
            var outputVariables = event.getParam("outputVariables");
            var outputVar;
            for(var i = 0; i < outputVariables.length; i++) {
                outputVar = outputVariables[i];
                if(outputVar.name === "OpportunityId") {
                    alert('outputVar.OpportunityId  ==> ',outputVar.value);
                }
            }  
    	} 
    }

})