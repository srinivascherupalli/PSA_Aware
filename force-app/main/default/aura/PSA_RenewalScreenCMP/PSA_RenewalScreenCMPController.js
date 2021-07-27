({
    doInit : function( c, e, h ) {  
        document.title = 'PSA';
        c.set("v.isLoading", true);

        //fetch Invoice Id for Payment
        var queryString = window.location.search;
        var urlParams = new URLSearchParams(queryString);
        var invoiceId = urlParams.get('invoiceId');
        c.set("v.invoiceId",invoiceId);
        c.set("v.isLoading", false);

        var screenName = c.get("v.screenName");

        var action = c.get("c.getInvoiceStatus");
        action.setParams({
            "invoiceId": invoiceId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var headerNav = c.find("headerNav");
            if(state === "SUCCESS") {
                var invoiceStatus=response.getReturnValue();
                c.set("v.invoiceStatus", invoiceStatus); 
                if(invoiceStatus==='Draft') { 
                    screenName = 'screen1';
                }else if(invoiceStatus==='Posted'){
                    screenName = 'screen2'; 
                }else{
                    screenName = 'screen1';
                }
                c.set("v.screenName", screenName); 
               
                headerNav.doInit();
                console.log(response.getReturnValue())
            }else{
               console.log('Fail'); 
            }
        });
        $A.enqueueAction(action);
        
        var invoiceId = c.get("v.invoiceId");
        console.log('invoiceId:::', invoiceId);
        var menuItems = [ 
            { label: '1. Renewal', screen: 'screen1', active: true, class: 'fas fa-folder-open'},
            { label: '2. Payment', screen: 'screen2', active: true, class: 'fas fa-folder-open'},
            { label: '3. Review and Confirm',  screen: 'screen3', active: false, class: 'fas fa-folder-open'}
        ];
        
        menuItems.forEach(item => {
            item.active = (item.screen === screenName);
        });
            
        c.set("v.menuItems", menuItems);
		if($A.util.isEmpty(invoiceId)) return;
        
    },
    
    handleToken: function(c , e, h) {
        console.log(e.target.value);
    }
})