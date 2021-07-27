({
    doInit : function( c, e, h ) {  
        var screenName = c.get("v.screenName");
        if(!screenName) { screenName = 'screen1'; c.set("v.screenName", screenName); }

        var menuItems = [ 
                { label: '1. Profile', screen: 'screen1', active: true, class: 'fas fa-check-circle'},
                { label: '2. Membership', screen: 'screen2', active: false, class: 'fas fa-check-circle'},
                { label: '3. Benefit', screen: 'screen3', active: false, class: 'fas fa-check-circle'},
                { label: '4. Payment', screen: 'screen4', active: false, class: 'fas fa-folder-open'},
                { label: '5. Review and Confirm',  screen: 'screen5', active: false, class: 'fas fa-folder-open'}
            ];      
        
        menuItems.forEach(item => {
            item.active = (item.screen === screenName);
        });
        c.set("v.menuItems", menuItems);

    },
    
    handleToken: function(c , e, h) {
        console.log(e.target.value);
    }
})