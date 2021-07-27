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
    initWrapper: function initWrapper(cmp, event, helper) {
        //helper.handleRedirect(cmp, event, helper);
    },

    /* 
      Handles functions that are called from the Enrol Now button.
    */
    handleEnrol: function handleEnrol(cmp, event, helper) {
        var state = cmp.get("v.pageStateWrapper");
        var disableEnrol = cmp.get("v.disableEnrol");
        console.log("1: " + cmp.get("v.disableEnrol"));
        var enrolAction;
        //console.log("entered handleEnrol function: ");

        if (
            state.isGuest == "guest"
            //&&
            //state.tPlan.trainingPlan.Type__c != "Public"
        ) {
            helper.showLoginModal(cmp, event, "Login");
        } else if (state.isEvent == "Select Date") {
            enrolAction = cmp.get("c.enrolInEvent");
        } else {
            enrolAction = cmp.get("c.registerForTraining");
            /* console.log(
               "Registering for training: " + state.tPlan.trainingPlan.Type__c
             );*/
        }

        if ((enrolAction != null) && (disableEnrol == false)) {
            $A.enqueueAction(enrolAction);
            cmp.set("v.disableEnrol", "true");
            console.log("2: " + cmp.get("v.disableEnrol"));
        }
    },

    /*   
      Directs to the VF EventEnrol page 
    */
    enrolInEvent: function enrolInEvent(cmp, event, helper) {
        //helper.showSpinner(cmp);
        var action = cmp.get("c.eventEnrol");
        var state = cmp.get("v.pageStateWrapper");
        action.setParams({
            trainingPlanId: state.trainingPlanId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state == "SUCCESS") {
                var urlString = response.getReturnValue();
                //console.log("navigating to URL: " + urlString);
                helper.navigateExternalURL(cmp, urlString);
            } else {
                helper.showToast(
                    "error",
                    "Error",
                    "There was a problem while trying to enrol. Please contact an Administrator"
                );
            }
            cmp.set("v.disableEnrol", "false");
            console.log("3: " + cmp.get("v.disableEnrol"));
            helper.hideSpinner(cmp);
        });
        $A.enqueueAction(action);
    },

    /* 
        Registration method called when pressing the 'Enrol now' button
    */
    registerForTraining: function registerForTraining(cmp, event, helper) {
        helper.showSpinner(cmp);
        var currentState = cmp.get("v.pageStateWrapper");
        var action = cmp.get("c.registerForTrainingPlan");
        action.setParams({
            inputState: currentState
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var wrapper = response.getReturnValue();
            //console.log(JSON.stringify(wrapper));

            if (state == "SUCCESS") {
                //Potential return types: Community redirect, External redirect, user errors, future method waiting.
                if (wrapper.userErrorMessage != null) {
                    //Show modal if error is due to Register error
                    if (wrapper.userErrorMessage == "Register error") {
                        /*console.log(
                          "Showing modal becase of error: " + wrapper.userErrorMessage
                        );*/
                        helper.hideSpinner(cmp);
                        helper.showLoginModal(cmp, event, "Register");
                    } else {
                        helper.hideSpinner(cmp);
                        helper.showToast("error", "Error", wrapper.userErrorMessage);
                    }
                } else if (wrapper.redirectURL != null) {
                    //Navigate to a sites vf page
                    helper.hideSpinner(cmp);
                    helper.navigateExternalURL(cmp, wrapper.redirectURL);
                } else if (wrapper.redirectExternalURL) {
                    //Navigate to external page
                    helper.hideSpinner(cmp);
                    helper.navigateExternalURL(cmp, wrapper.redirectExternalURL);
                } else if (wrapper.futureMethodCalled == true) {
                    //Future method called in controller. Use helper method to look for finished job and refresh page.
                    helper.handleFutureMethod(cmp, event, helper);
                } else {
                    //Assume success and refresh the page
                    //console.log("Success without re-direct");
                    $A.get("e.force:refreshView").fire();
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
        });
        $A.enqueueAction(action);
    },

    /*   
          Add to plan functionality from button
          Returns userErrormessage if errors.
          Otherwise sets isAlreadyInBookmark 
      */
    addToPlan: function addToPlan(cmp, event, helper) {
        //console.log("attempting to add to plan");

        if (
            confirm(
                "You are about to add this course to your current CPD Plan. Click OK if you wish to continue."
            )
        ) {
            var action = cmp.get("c.createTrainingPlanBookmark");
            action.setParams({
                inputState: cmp.get("v.pageStateWrapper")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var wrapper = response.getReturnValue();
                //console.log(JSON.stringify(wrapper));

                if (state == "SUCCESS") {
                    //Set the bookmark value to new value in wrapper
                    cmp.set("v.pageStateWrapper", response.getReturnValue());
                    helper.showToast(
                        "success",
                        "Success!",
                        "Training plan successfully added to your CPD Plan"
                    );
                } else if (state == "ERROR") {
                    //Throw toast with error
                    var errors = response.getError();
                    var message = "An unknown error occurred.";

                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        message = errors[0].message;
                    }

                    helper.showToast("error", "Error", message);
                }
            });
            $A.enqueueAction(action);
        }
    },
    handleEnrolMain: function handleEnrolMain(cmp, event, helper) {
        //console.log("handle enrol main");
        helper.handleRedirect(cmp, event, helper); // helper.refreshCurrentPage(cmp, event);
    },
    openModel: function(component, event, helper) {
        component.set("v.isModalOpen", true);
    },
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
    }
});