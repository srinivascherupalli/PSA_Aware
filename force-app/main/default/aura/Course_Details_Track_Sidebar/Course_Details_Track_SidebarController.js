({
    doInit: function doInit(cmp, event, helper) {
        //Do nothing
        var url=window.location.pathname.split('/');
        console.log(url)
        var tId=url[3];

        var action = cmp.get("c.getTrainingPackageDetails");
        action.setParams({
            'tId': tId
        });
        action.setCallback(this, function(action) {
            var h=helper;
            var state = action.getState();
            if (state === "SUCCESS") {
                var response = action.getReturnValue();
                console.log(response);
                cmp.set("v.isAvailableForEssential",response[0].Available_for_Essential__c);
                window.setTimeout(
                    $A.getCallback(function() {
                        h.loadUserDetails(cmp, event, h);
                    }), 1000
                );

            } else {
                //do nothing
                console.log('in error');
            }
        });
        $A.enqueueAction(action);
    },
    //OnChange handler for the page state wrapper
    testNavComm: function testNavComm(cmp, event, helper) {
        // helper.navigateCommunityPage(cmp, "my_enrolments__c");
        helper.navigateExternalURL(
            cmp,
            "https://cpd-my-psa.cs73.force.com/s/enrolment-form"
        );
    },

    /* 
        Registration method called when pressing the purchase button
    */
    handlePurchase: function handlePurchase(cmp, event, helper) {
        var action;
        var currentState = cmp.get("v.pageStateWrapper");
        helper.showSpinner(cmp);

        if (currentState.isGuest == "guest") {
            helper.showLoginModal(cmp, event, "Login");
            helper.hideSpinner(cmp);
        } else {
            action = cmp.get("c.purchase");
            action.setParams({
                inputState: currentState
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var wrapper = response.getReturnValue();
                console.log(JSON.stringify(wrapper));

                if (state == "SUCCESS") {
                    //Potential return types: Community redirect, External redirect, user errors, future method waiting.
                    if (wrapper.userErrorMessage != null) {
                        helper.showToast("error", "Error", wrapper.userErrorMessage);
                    } else if (wrapper.redirectURL != null) {
                        //Navigate to a sites vf page
                        helper.navigateExternalURL(cmp, wrapper.redirectURL);
                    } else if (wrapper.redirectExternalURL) {
                        //Navigate to external page
                        helper.navigateExternalURL(cmp, wrapper.redirectExternalURL);
                    } else if (wrapper.communityPage != null) {
                        //Navigate to external page
                        helper.navigateCommunityPage(cmp, wrapper.communityPage);
                    } else {
                        //Assume success and refresh the page
                        console.log("Success without re-direct");
                        helper.delayedRefresh(cmp, event);
                    }
                } else if (state == "ERROR") {
                    //Throw toast with error
                    var errors = response.getError();
                    var message = "An unknown error occurred.";

                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        message = errors[0].message;
                    }

                    helper.showToast("error", "Error", message);
                }

                helper.hideSpinner(cmp);
            });
        }

        if (action != null) {
            $A.enqueueAction(action);
        }
    },
    openModel: function(component, event, helper) {
        component.set("v.isModalOpen", true);
    },
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
    }
});