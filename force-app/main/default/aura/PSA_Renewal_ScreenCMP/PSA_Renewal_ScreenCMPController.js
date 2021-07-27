({
    doInit : function( c, e, h ) {  
        document.title = 'PSA';
        c.set("v.isLoading", true);

        //fetch Invoice Id for Payment
        var queryString = window.location.search;
        var urlParams = new URLSearchParams(queryString);
        var quoteId = urlParams.get('quoteId');
        c.set("v.quoteId",quoteId);
        c.set("v.isLoading", false);

        var screenName = c.get("v.screenName");

        var action = c.get("c.getQuoteStatusByQuoteId");
        action.setParams({
            "quoteId": quoteId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var headerNav = c.find("headerNav");
            if(state === "SUCCESS") {
                var invoiceStatus=response.getReturnValue();
                if(invoiceStatus){
                    c.set("v.invoiceStatus", invoiceStatus); 
                }else{
                    c.set("v.invoiceStatus", 'Error'); 
                }
               // if(invoiceStatus==='Draft') { 
                    //screenName = 'screen1';
                /*} else if(invoiceStatus==='Posted'){
                    screenName = 'screen2'; 
                }else{
                    screenName = 'screen1';
                } */
                c.set("v.screenName", screenName); 
               
                headerNav.doInit();
                console.log(response.getReturnValue())
            }else{
               console.log('Fail'); 
            }
        });
        $A.enqueueAction(action);
        
        var quoteId = c.get("v.quoteId");
        console.log('quoteId:::', quoteId);
        var menuItems = [ 
            { label: '1. Renewal', screen: 'screen1', active: true, class: 'fas fa-folder-open'},
            { label: '2. Benefit', screen: 'screen1b', active: true, class: 'fas fa-folder-open'},
            { label: '3. Payment', screen: 'screen2', active: true, class: 'fas fa-folder-open'},
            { label: '4. Review and Confirm',  screen: 'screen3', active: false, class: 'fas fa-folder-open'}
        ];
        
        menuItems.forEach(item => {
            item.active = (item.screen === screenName);
        });
            
        c.set("v.menuItems", menuItems);
		if($A.util.isEmpty(quoteId)) return;
        
    },
    
    handleToken: function(c , e, h) {
        console.log(e.target.value);
    }
})