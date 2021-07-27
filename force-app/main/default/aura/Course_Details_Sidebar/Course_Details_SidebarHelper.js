({
    showSpinner: function showSpinner(cmp) {
        cmp.set("v.showSpinner", true);
    },
    hideSpinner: function hideSpinner(cmp) {
        cmp.set("v.showSpinner", false);
    },
    showToast: function showToast(type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            title: title,
            message: message
        });
        toastEvent.fire();
    },
    navigateExternalURL: function navigateExternalURL(cmp, extUrl) {
        //Use navigate service to go to an external URL
        //log("Navigating to: " + extUrl); //Navigate to new page

        cmp.find("navService").navigate({
            type: "standard__webPage",
            attributes: {
                url: extUrl
            }
        }); //Refresh the page

        this.hideSpinner(cmp);
        //console.log('working?');
        $A.get("e.force:refreshView").fire();
    },
    //Reloads the current page and strips any url
    refreshCurrentPage: function refreshCurrentPage(cmp, event) {
        var state = cmp.get("v.pageStateWrapper");
        var url = "/s/training-plan/";
        cmp.find("navService").navigate({
            type: "standard__webPage",
            attributes: {
                url: "/s/training-plan/" + state.trainingPlanId
            }
        });
    },
    //Shows custom login modal that directs to the login or register page
    //Shows Login and register with message for modalType=Login
    //Shows register and separate message for modalType==Register
    showLoginModal: function showLoginModal(cmp, event, modalType) {
        //console.log("trying to show the modal : + " + modalType);
        this.hideSpinner(cmp);
        var modalBody;
        var modalHeader;
        $A.createComponents(
            [
                [
                    "c:Course_LoginRegisterModal",
                    {
                        modalType: modalType
                    }
                ],
                ["c:Course_LoginRegisterModalHeader", {}]
            ],
            function(components, status) {
                if (status === "SUCCESS") {
                    modalBody = components[0];
                    modalHeader = components[1];
                    cmp.find("overlayLib").showCustomModal({
                        header: modalHeader,
                        body: modalBody,
                        showCloseButton: true
                    });
                }
            }
        );
    },

    /* 
        Called once enrol button completes.
        Sets a loop to check for a future method to complete
        Errors if future job doesn't complete in 10 seconds.
    */
    handleFutureMethod: function handleFutureMethod(cmp, event, helper) {
        //execute callApexMethod() again after half second each
        //Reset the component count
        cmp.set("v.futureMethodCounter", 0);
        var interval = window.setInterval(
            $A.getCallback(function() {
                helper.checkFutureMethod(cmp, event, helper);
            }),
            500
        ); //Set the id so the interval can be cleared later

        cmp.set("v.setIntervalId", interval);
    },

    /* 
        Calls an apex method to check if the future method
        for this Training plan has completed.
    */
    checkFutureMethod: function checkFutureMethod(cmp, event, helper) {
        // TO-DO: Should this also throw spinner up so we know something is waiting??
        this.showSpinner(cmp);
        var calloutCount = cmp.get("v.futureMethodCounter");
        //console.log("called future method reprocessing: " + calloutCount);
        cmp.set("v.futureMethodCounter", calloutCount + 1);
        var jobComplete = false;
        var checkAction = cmp.get("c.check_futureJobComplete");
        var state = cmp.get("v.pageStateWrapper"); //Set params

        checkAction.setParams({
            tplanId: state.trainingPlanId
        }); //Callback throws toast and refreshes page.

        checkAction.setCallback(this, function(response) {
            var state = response.getState();
            jobComplete = response.getReturnValue();

            if (state == "SUCCESS") {
                if (calloutCount < 20) {
                    if (jobComplete == true) {
                        //Throw alert and cancel the ongoing fetch for future jobs
                        helper.showToast(
                            "success",
                            "Success!",
                            "You have successfully enrolled in this course"
                        );
                        window.clearInterval(cmp.get("v.setIntervalId"));
                        helper.delayedRefresh(cmp, event);
                        this.hideSpinner(cmp);
                    }
                } else if (calloutCount > 20 && jobComplete == false) {
                    helper.showToast(
                        "error",
                        "Error",
                        "A problem was encountered when trying to enrol. Please contact Administrator"
                    );
                    window.clearInterval(cmp.get("v.setIntervalId"));
                    this.hideSpinner(cmp);
                    helper.delayedRefresh(cmp, event);
                }
            } else {
                helper.showToast(
                    "error",
                    "Error",
                    "A problem was encountered when trying to enrol. Please contact Administrator"
                );
                window.clearInterval(cmp.get("v.setIntervalId"));
                this.hideSpinner(cmp);
                helper.delayedRefresh(cmp, event);
            }
        });
        $A.enqueueAction(checkAction);
    },
    delayedRefresh: function delayedRefresh(cmp, event) {
        window.setTimeout(
            $A.getCallback(function() {
                $A.get("e.force:refreshView").fire();
            }),
            2500
        );
    },
    loadUserDetails: function(component, event, helper) {
        //getTrainingPackageDetails
        var isAvailableForEssential=component.get("v.isAvailableForEssential");
        console.log(isAvailableForEssential)
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var action = component.get("c.getUserAccountDetails");
        action.setParams({
            'userId': userId
        });
        action.setCallback(this, function(action) {
            var state = action.getState();
            if (state === "SUCCESS") {
                var response = action.getReturnValue();
                var acctDetails = null;
                if (response.Account != null) {
                    acctDetails = response.Account;
                    console.log('acctDetails ',acctDetails)

                    if ((acctDetails.CPQ_Membership_Product__pc != undefined && (acctDetails.CPQ_Membership_Product__pc).indexOf('Essential') != -1 && (acctDetails.CPQ_Membership_Status__pc == 'Current' || acctDetails.CPQ_Membership_Status__pc == 'Pending'))) {
                        if(!isAvailableForEssential){
                            component.set('v.disableEnrollBtn', true);
                        }
            
                    }
                }
            } else {
                //do nothing
                console.log('in error');
            }
        });
        $A.enqueueAction(action);
    }
});