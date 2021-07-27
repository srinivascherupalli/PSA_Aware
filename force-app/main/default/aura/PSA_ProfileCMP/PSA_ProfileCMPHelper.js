({
    getCurrentUserInfo: function(component, event) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        if (userId) {
            console.log(userId);
            this.apexRequest(component, 'fetchCurrentUser', {
                    userId: userId
                })
                .then($A.getCallback(function(response) {
                    var userdetail = response.Contact;
                    var accdetail = response.Account;
                    var months = {
                        'January': '01',
                        'February': '02',
                        'March': '03',
                        'April': '04',
                        'May': '05',
                        'June': '06',
                        'July': '07',
                        'August': '08',
                        'September': '09',
                        'October': '10',
                        'November': '11',
                        'December': '12'
                    };
                    console.log(userdetail, response)

                    if (response.ContactId) {
                        component.set("v.accountId", userdetail.AccountId);
                        var profileDetail = {
                            email: userdetail.Email ? userdetail.Email : response.Email,
                            password: '',
                            title: userdetail.Title,
                            firstname: userdetail.FirstName,
                            lastname: userdetail.LastName,
                            gender: userdetail.Gender__c,
                            dobdate: userdetail.Birthdate,
                            primaryEmail: userdetail.AS_Personal_Email__c,
                            country: userdetail.MailingCountry,
                            phone: userdetail.Phone,
                            address1: userdetail.MailingStreet,
                            address2: '',
                            city: userdetail.MailingCity,
                            postalCode: userdetail.MailingPostalCode,
                            state: userdetail.MailingState,
                            role: userdetail.AS_Role__c,
                            sameAsAcountEmail: false,
                            employment: userdetail.PSA_Primary_Employment_Sector__c,
                            yrofqualification: userdetail.AS_Graduation_Year__c,
                            monthofqualification: accdetail.Graduation_Month__c,
                            dateofqualification: userdetail.AS_Graduation_Year__c + '-' + months[accdetail.Graduation_Month__c] + '-' + '01',
                            AHPRA: userdetail.AS_AHPRA_Number__c,
                            oversearegistration: userdetail.AS_Yr_of_Initial_Registration_in_Aust__c ? true : false,
                            yrOfRegistration: userdetail.AS_Yr_of_Initial_Registration_in_Aust__c,
                            hoursworkedperweek: userdetail.AS_Hours_Worked_Per_Week__c,
                            yrofgraduation: userdetail.AS_Graduation_Year__c,
                            studentnumber: userdetail.AS_Student_Number__c,
                            //signedUp: accdetail.Signed_Up__c, 
                            //If user id exists means the user is already signed in into the application. So setting the value to false
                            signedUp: false,
                            parentalLeave: userdetail.parental_leave_date__c ? true : false,
                            returnToWorkDate: userdetail.parental_leave_date__c,
                            monthofGraduation: accdetail.Graduation_Month__c,
                            studentUniversityEmail: accdetail.Student_University_Email__c,
                            university: accdetail.University__c,
                            dateOfGraduation: userdetail.AS_Graduation_Year__c + '-' + months[accdetail.Graduation_Month__c] + '-' + '01'

                        }
                        component.set("v.profileDetail", profileDetail);
                        if (profileDetail.signedUp) {
                            var continueBtn = component.find("screen_2");
                            $A.util.addClass(continueBtn, "disabled");
                        }

                        if (profileDetail.dobdate) {
                            component.set("v.isDOBAvailable", true);
                        } else {
                            component.set("v.isDOBAvailable", false);
                        }
                        console.log('profileDetail ', profileDetail);
                    }
                }))
                .catch(error => console.log(error));
        }
        this.apexRequest(component, 'getPicklistvalues', {
                objectName: 'Contact',
                field_apiname: 'PSA_Primary_Employment_Sector__c',
                nullRequired: false
            })
            .then($A.getCallback(function(response) {
                var empAreaoptions = [];
                response.forEach(function(emp) {
                    empAreaoptions.push({ label: emp, value: emp })
                });
                component.set("v.empAreaoptions", empAreaoptions);
                console.log(response)
            })).catch(error => console.log(error));


    },

    handleValidation: function(component, event, screenName) {
        var helper = this;
        let isAllValid = true;
        let inputCmps = component.find('forminput');
        if (inputCmps && Array.isArray(inputCmps) && inputCmps.length > 0) {
            var firstInvalidCmp;
            let validityList = [];
            inputCmps.forEach((cmp) => {
                if (cmp && cmp.reportValidity) {
                    var cmpValidity = cmp.reportValidity();
                    if (typeof cmpValidity === "boolean") {
                        validityList.push(cmpValidity);
                        if (cmpValidity != true && !firstInvalidCmp) firstInvalidCmp = cmp;
                    }
                }
            });
            isAllValid = validityList.every(Boolean);
            if (firstInvalidCmp) helper.scrollToCmp(component, firstInvalidCmp);
        }

        if (isAllValid && !component.get('v.existingEmail')) {
            console.log(JSON.stringify(component.get("v.profileDetail")))
            this.apexRequest(component, 'CreateMember', {
                    userJson: JSON.stringify(component.get("v.profileDetail"))
                })
                .then($A.getCallback(function(response) {

                    component.set("v.accountId", response);
                    sessionStorage.setItem('accountId', response);

                    scrollTo({ top: 0, behavior: 'smooth' });
                    // Trigger event to handle screen validation
                    var navEvent = $A.get("e.c:PSA_NavigationEvent");
                    navEvent.setParams({ screenName, "from": 'CMP' });
                    navEvent.fire();
                }))
                .catch(this.withCallback(component, this.handleError));

        } else {
            var notifLib = component.find('notifLib');
            if (!notifLib || !notifLib.showToast) return;
            notifLib.showToast({
                "title": "Warning!",
                "message": component.get('v.existingEmail') ? "User already exist with entered email." : "Please fill all required fields.",
                "variant": "error",
                "duration": "2000"
            });
        }
    },

    CheckEmailAvailability: function(component, cmp) {
        component.set('v.existingEmail', false);
        component.set('v.isEmailAvailable', false);
        component.set('v.isNewAcount', false);
        this.apexRequest(component, 'CheckisUserAvailability', {
                email: cmp.get('v.value')
            })
            .then(function(response) {
                component.set("v.showLoading", false);
                if (response == 'Member' || response == 'Not a member') {
                    cmp.setCustomValidity("User already exists with this email.");
                    cmp.reportValidity();
                    component.set('v.existingEmail', true);
                    component.set('v.isEmailAvailable', true);
                } else {
                    component.set('v.isNewAcount', true);
                    //window.location.href = '../CommunitiesSelfReg?startURL=/s/psa-membership';
                }
            })
            .catch(this.withCallback(component, this.handleError));
    },

    handleError: function(component, errors) {
        console.log(errors);
        this.handleErrors(component, null, errors);
    },

    scrollToCmp: function(component, cmpTarget, cmpElement, cmpName) {
        if (!component || (!cmpName && !cmpElement && !cmpTarget)) return;

        if (!cmpTarget) cmpTarget = component.find(cmpName);
        if (!cmpTarget || (!cmpTarget.getElement && !cmpTarget.focus)) return;

        if (cmpTarget.focus) {
            cmpTarget.focus();
            return;
        }

        if (!cmpElement) cmpElement = cmpTarget.getElement();
        if (!cmpElement || (!cmpElement.getBoundingClientRect && !cmpElement.scrollIntoView)) return;
        if (cmpElement.scrollIntoView) {
            cmpElement.scrollIntoView();
            return;
        }


        var cmpRect = cmpElement.getBoundingClientRect();
        if (!cmpRect || !cmpRect.top) return;

        scrollTo({ top: Math.abs(cmpRect.top), behavior: 'smooth' });
    }

})