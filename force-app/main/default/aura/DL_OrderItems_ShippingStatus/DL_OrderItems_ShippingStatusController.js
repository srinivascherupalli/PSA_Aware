({
	complete_OrderItems : function(component, event, helper) {
        helper.completeOrderItems(component, event, helper);
        helper.closeModal(component, event, helper);
    },

    processing_OrderItems : function(component, event, helper) {
        helper.processingOrderItems(component, event, helper);
        helper.closeModal2(component, event, helper);
    },


    showModal : function(component, event, helper){
        $A.util.removeClass(component.find('confirmationModal'), 'slds-hide');
        $A.util.addClass(component.find('confirmationModal'), 'slds-show');
        
        component.set('v.loadingBool', 'true');
        
        document.getElementById("modal-content-id-1").innerHTML = '<p>Set Order Products as \'Completed\'?</p>'; 
    },

    showModal2 : function(component, event, helper){
        $A.util.removeClass(component.find('confirmationModal2'), 'slds-hide');
        $A.util.addClass(component.find('confirmationModal2'), 'slds-show');
        
        component.set('v.loadingBool', 'true');
        
        document.getElementById("modal-content-id-2").innerHTML = '<p>Set Order Products as \'Processing\'?</p>'; 
    },


    closeModal : function(component, event, helper){
        $A.util.removeClass(component.find('confirmationModal'), 'slds-show');
        $A.util.addClass(component.find('confirmationModal'), 'slds-hide');
        component.set('v.loadingBool', 'false');
    },

    closeModal2 : function(component, event, helper){
        $A.util.removeClass(component.find('confirmationModal2'), 'slds-show');
        $A.util.addClass(component.find('confirmationModal2'), 'slds-hide');
        component.set('v.loadingBool', 'false');
    },
})