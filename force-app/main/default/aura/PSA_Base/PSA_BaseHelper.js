({
    doCallout: function(component, methodName, params, callBackFunc) {
        doCallout(component, methodName, params, callBackFunc, false, false);
    },
    
    doCallout: function(component, methodName, params, callBackFunc, isSetStorable, isSetBackground) {
        var action = component.get(methodName);
        action.setParams(params);
        action.setCallback(this, callBackFunc);
        if (isSetStorable) action.setStorable();
        if (isSetBackground) action.setBackground();
        $A.enqueueAction(action);
    },   
    
    handleErrors: function(component, event, errors, isShowNotificationLibrary) { 
        var message;
        if (errors) {
            if (errors[0] && errors[0].message) {
                message = errors[0].message;
            } else if (errors[0] && errors[0].pageErrors) {
                message = errors[0].pageErrors[0].message;
            } else {
                message = "Unknown error";
            }
        }
        
        if(isShowNotificationLibrary){
            component.find('notifLib').showNotice({
                "variant": "error",
                "header": "ERROR",
                "message": message,
            });
        }else{
            (this).showToast('Error', 'error', '5000', message);
        }
    },
    
    showToast: function(title, type, duration, message) {  
        var toastEvent = $A.get("e.force:showToast");
        
        if(!toastEvent) { alert(message); return;}
        
        toastEvent.setParams({
            title: title,
            type: type,
            duration: duration,
            message: message
        });
        toastEvent.fire();
    },
    apexRequest : function (component, actionName, params) {
        return new Promise (function (resolve, reject) {
            this.hideShowSpinner(component, true); 
            var action = component.get(['c', actionName].join('.'));
            if (params && typeof params === 'object') {
                action.setParams(params);
            }
            
            function cb (response) {
                var state = response.getState();
                this.hideShowSpinner(component, false); 
                if (state === 'SUCCESS' && component.isValid()) {
                    resolve(response.getReturnValue());
                } else {
                    reject(response.getError());
                }
            }

            action.setCallback(this, cb);

            try {
                $A.enqueueAction(action);
            } catch (e) {
                reject(e.message);
            }

        }.bind(this));
    },
    withCallback : function (component, fn) {
        var context = this;
        return $A.getCallback(function () {
            var args = [].slice.call(arguments);
            return fn.apply(context, [component].concat(args));
        }.bind(context));
    },
    
    hideShowSpinner: function(component, showhide) {
        if(showhide)
        	component.set("v.isLoading", true);
        else
            component.set("v.isLoading", false);
    }
    
})