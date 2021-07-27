({
    doInit: function(component, event, helper) {

        if (!$A.util.isEmpty(component.get("v.accountId"))) return;

        var profileDetail = {
            email: '',
            password: '',
            Salutation: '',
            firstname: '',
            lastname: '',
            gender: '',
            dobdate: '',
            primaryEmail: '',
            country: 'Australia',
            phone: '',
            address1: '',
            address2: '',
            city: '',
            postalCode: '',
            state: '',
            role: '',
            sameAsAcountEmail: false,
            employment: '',
            yrofqualification: '',
            monthofqualification: '',
            yrOfRegistration: '',
            AHPRA: '',
            oversearegistration: false,
            hoursworkedperweek: '',
            parentalLeave: '',
            returnToWorkDate: '',
            yrofGraduation: '',
            monthofGraduation: '',
            studentUniversityEmail: '',
            university: '',
            studentnumber: '',
            signedUp: true
        }
        component.set("v.profileDetail", profileDetail);
        helper.getCurrentUserInfo(component, event);
    },

    onRoleChange: function(component, event, helper) {
        component.set("v.profileDetail.employment", '');
        component.set("v.profileDetail.dateofqualification", '');
        component.set("v.profileDetail.AHPRA", '');
        component.set("v.profileDetail.oversearegistration", false);
        component.set("v.profileDetail.yrOfRegistration", '');
        component.set("v.profileDetail.hoursworkedperweek", '');
        component.set("v.profileDetail.parentalLeave", false);
        component.set("v.profileDetail.returnToWorkDate", '');
        component.set("v.profileDetail.dateOfGraduation", '');
        component.set("v.profileDetail.university", '');
        component.set("v.profileDetail.studentUniversityEmail", '');
        component.set("v.profileDetail.studentnumber", '');
    },

    setQualificationDate: function(component, event, helper) {
        var mlist = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
        var LastYearTodayDate = new Date(new Date().setFullYear(new Date().getFullYear() - 1))
        var dateofqualification = component.get("v.profileDetail.dateofqualification");
        var splitDate = dateofqualification.split('-')
        var month = parseInt(splitDate[1]) - 1;
        var enteredDate = new Date(splitDate[0], month.toString(), splitDate[2]);
        var cmpTarget = component.find("dateOfQualification");
        var cmpTargetMsg = component.find("dateOfQualificationMsg");
        var cmpTarget2 = component.find("dateOfQualification2");
        var cmpTargetMsg2 = component.find("dateOfQualificationMsg2");

        if (enteredDate < LastYearTodayDate) {
            $A.util.removeClass(cmpTarget, "slds-has-error");
            $A.util.addClass(cmpTargetMsg, "hide");
            $A.util.removeClass(cmpTarget2, "slds-has-error");
            $A.util.addClass(cmpTargetMsg2, "hide");
        } else {
            $A.util.addClass(cmpTarget, "slds-has-error");
            $A.util.removeClass(cmpTargetMsg, "hide");
            $A.util.addClass(cmpTarget2, "slds-has-error");
            $A.util.removeClass(cmpTargetMsg2, "hide");
        }

        component.set("v.profileDetail.yrofqualification", splitDate[0]);
        component.set("v.profileDetail.monthofqualification", mlist[parseInt(splitDate[1] - 1)]);
        console.log("date", mlist[parseInt(splitDate[1] - 1)]);
        console.log(enteredDate + ' ' + todayDate)
    },

    setDateOfGraduation: function(component, event, helper) {
        var mlist = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
        var todayDate = new Date();
        var dateOfGraduation = component.get("v.profileDetail.dateOfGraduation");
        var splitDate = dateOfGraduation.split('-');
        var month = parseInt(splitDate[1]) - 1;
        var enteredDate = new Date(splitDate[0], month.toString(), splitDate[2]);
        var cmpTarget = component.find('dateOfGraduation');
        var cmpTargetMsg = component.find('dateOfGraduationMsg');
        if (enteredDate > todayDate) {
            $A.util.removeClass(cmpTarget, 'slds-has-error');
            $A.util.addClass(cmpTargetMsg, 'hide');
        } else {
            $A.util.addClass(cmpTarget, 'slds-has-error');
            $A.util.removeClass(cmpTargetMsg, 'hide');
        }
        component.set("v.profileDetail.yrofqualification", splitDate[0]);
        component.set("v.profileDetail.monthofqualification", mlist[parseInt(splitDate[1] - 1)]);
        console.log("date", mlist[parseInt(splitDate[1] - 1)]);
    },

    handleSameEmail: function(component, event, helper) {
        var profileDetail = component.get("v.profileDetail");
        if (profileDetail.sameAsAcountEmail) {
            profileDetail.primaryEmail = profileDetail.email;
            component.set("v.profileDetail", profileDetail);
        }
    },

    checkEmailAvailability: function(component, event, helper) {
        let inputCmps = component.find('forminput');
        component.set('v.existingEmail', false);
        if (!$A.util.isEmpty(component.get("v.accountId"))) return;
        component.set("v.showLoading", true);
        if (inputCmps && Array.isArray(inputCmps) && inputCmps.length > 0) {
            inputCmps.forEach((cmp) => {
                if (cmp && cmp.reportValidity && cmp.get("v.name") == 'email01') {
                    cmp.setCustomValidity("");
                    var cmpValidity = cmp.reportValidity();
                    if (cmpValidity == true) {
                        helper.CheckEmailAvailability(component, cmp);
                    } else {
                        component.set("v.showLoading", false);
                    }
                }
            });
        }
    },

    resetEmailFieldErrors: function(component, event, helper) {
        component.set('v.existingEmail', false);
        component.set('v.isNewAcount', false);
    },

    validateEmail: function(component, event, helper) {
        var profileDetail = component.get("v.profileDetail");
        if (profileDetail.sameAsAcountEmail) {
            let inputCmps = component.find('forminput');
            if (inputCmps && Array.isArray(inputCmps) && inputCmps.length > 0) {
                inputCmps.forEach((cmp) => {
                    console.log(cmp.get("v.name"));
                    if (cmp && cmp.reportValidity && cmp.get("v.name") == 'email') {
                        cmp.reportValidity();
                    }
                });
            }
        }
    },

    //
    validateGraduationDate: function(component, event, helper) {
        component.set('v.isFutureDate', false);
        component.set('v.isPastDate', false);
        var hasError = false;
        var mlist = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
        var todayDate = new Date();
        var currentYear = todayDate.getUTCFullYear();
        var currentMonth = todayDate.getMonth();

        var selectedMonth = component.get('v.profileDetail.monthofqualification');
        var selectedYear = component.get('v.profileDetail.yrofqualification');

        var months = 0;
        months = (currentYear - selectedYear) * 12;
        months -= mlist.indexOf(selectedMonth);
        months += currentMonth;
        months <= 0 ? 0 : months;

        var cmp1 = component.find('monthOfGraduation');
        var cmp2 = component.find('yearOfGraduation');

        if (months >= 0) {
            //consider as past date
            component.set('v.isPastDate', true);
            hasError = true;
        }
        if (hasError) {
            $A.util.addClass(cmp1, 'slds-has-error');
            $A.util.addClass(cmp2, 'slds-has-error');
        } else {
            $A.util.removeClass(cmp1, 'slds-has-error');
            $A.util.removeClass(cmp2, 'slds-has-error');
        }
    },

    validateQualificationDate: function(component, event, helper) {
        component.set('v.isFutureDate', false);
        component.set('v.isPastDate', false);
        var hasError = false;
        var mlist = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
        var todayDate = new Date();
        var currentYear = todayDate.getUTCFullYear();
        var currentMonth = todayDate.getMonth();

        var selectedMonth = component.get('v.profileDetail.monthofqualification');
        var selectedYear = component.get('v.profileDetail.yrofqualification');

        var months = 0;
        months = (currentYear - selectedYear) * 12;
        months -= mlist.indexOf(selectedMonth);
        months += currentMonth;
        months <= 0 ? 0 : months;

        var cmp1 = component.find('monthOfQualification2');
        var cmp2 = component.find('yearOfQualification2');

        if (months > 0 && months < 12) {
            component.set('v.isPastDate', true);
            hasError = true;
        } else {
            if (months < 0) {
                component.set('v.isFutureDate', true);
            }
        }

        if (hasError) {
            $A.util.addClass(cmp1, 'slds-has-error');
            $A.util.addClass(cmp2, 'slds-has-error');
        } else {
            $A.util.removeClass(cmp1, 'slds-has-error');
            $A.util.removeClass(cmp2, 'slds-has-error');
        }
    },

    formatPhoneNumber: function(component, event, helper) {
        /*var phoneNo = event.getSource().get('v.value');
        var numbers = phoneNo.replace(/\D/g, ""),
            char = {
            0: "(",
            3: ") ",
            6: "-"
            };
        var formattedphone = "";
        for (var i = 0; i < numbers.length; i++) {
            formattedphone += (char[i] || "") + numbers[i];
        }
        event.getSource().set('v.value', formattedphone );*/
    },

    handleButtonClick: function(component, event, helper) {

        var screenName = event && event.getParam ? event.getParam("screenName") : undefined;
        screenName = screenName ? screenName : 'screen2';
        var fromCMP = event && event.getParam ? event.getParam('from') : undefined;
        if ((fromCMP && fromCMP == 'CMP') || screenName != 'screen2') return;

        helper.handleValidation(component, event, screenName);
    }
})