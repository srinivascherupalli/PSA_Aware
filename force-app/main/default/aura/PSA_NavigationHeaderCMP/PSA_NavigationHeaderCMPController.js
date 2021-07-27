({ 
    doInit : function(cmp, event, helper) {
        var menuItems = cmp.get("v.menuItems");
        var screen = cmp.get("v.screenName");
        menuItems.forEach((item, index) => {
            item.id = 'menu-item-' + index;
            item.active = screen == item.screen ? true : false;
        }); 
        cmp.set("v.items", menuItems);    
    }, 
    
    handleNavigation: function( cmp, event, helper) {
        
        if(!event.target || !event.target.id ) return; 
        
        var elId = event.target.id;
        
        var menuItems = cmp.get("v.menuItems");
        var result = menuItems.find(item => {
          	return item.id === elId;
        });
        
        let currentScreen = cmp.get("v.screenName");
        if(currentScreen != result.screen) {
            //cmp.set("v.screenName", result.screen);
            // Trigger event to handle screen validation
            var navEvent = $A.get("e.c:PSA_NavigationEvent");
            navEvent.setParams({ 
                "screenName" : result.screen,
                "from" : 'Navigation' 
            });
            navEvent.fire();
        }
    },

    handleScreenNavigation: function(cmp, event) {
        var fromCMP =  event.getParam('from');
        if(!fromCMP || fromCMP == 'Navigation') return;

        var screen = event.getParam('screenName');
        cmp.set('v.screenName', screen);
        var menuItems = cmp.get("v.menuItems");
        menuItems.forEach(item => {
            item.active = screen == item.screen ? true : false;
        });
        cmp.set("v.menuItems", menuItems); 
    }
})