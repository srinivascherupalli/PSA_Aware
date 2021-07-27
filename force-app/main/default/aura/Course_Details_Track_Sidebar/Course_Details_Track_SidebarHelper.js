({
    //Shows custom login modal that directs to the login or register page
    //Shows Login and register with message for modalType=Login
    //Shows register and separate message for modalType==Register
    showLoginModal: function showLoginModal(cmp, event, modalType) {
        console.log("trying to show the modal : + " + modalType);
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
        console.log("Navigating to: " + extUrl); //Navigate to new page

        cmp.find("navService").navigate({
            type: "standard__webPage",
            attributes: {
                url: extUrl
            }
        }); //Refresh the page

        $A.get("e.force:refreshView").fire();
    },
    navigateCommunityPage: function navigateCommunityPage(cmp, pageName) {
        //Use navigate service to go to an external URL
        console.log("Navigating to: " + pageName); //Navigate to new page

        cmp.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                name: pageName
            }
        });
    },
    showSpinner: function showSpinner(cmp) {
        cmp.set("v.showSpinner", true);
    },
    hideSpinner: function hideSpinner(cmp) {
        cmp.set("v.showSpinner", false);
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
        var isAvailableForEssential=component.get("v.isAvailableForEssential");
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
                    console.log('acctDetails1 ',acctDetails)
                    if (!(acctDetails.CPQ_Membership_Product__pc != undefined && (acctDetails.CPQ_Membership_Product__pc).indexOf('Essential') != -1 && (acctDetails.CPQ_Membership_Status__pc == 'Current' || acctDetails.CPQ_Membership_Status__pc == 'Pending'))) {
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