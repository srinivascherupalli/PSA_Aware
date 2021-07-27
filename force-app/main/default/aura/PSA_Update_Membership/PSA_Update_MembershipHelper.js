({
    getCurrentUserInfo: function(component, event) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");

        var that = this;

        component.set("v.isLoading", true);
        
        if (userId) {
            console.log(userId);
            let premiumCustomer = false;
            this.apexRequest(component, 'fetchCurrentUser', {
                    userId: userId
                })
                .then(function(response){
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

                    if(userdetail.AccountId !=null ){
                        that.apexRequest(component, 'getUserMembershipDetails', {
                            accountId: userdetail.AccountId
                        })
                        .then(function(res){
                            let membership = null;
                            if(res!=null){
                                component.set("v.contractId",res.Id);
                                if(res.SBQQ__Subscriptions__r!=null){
                                    let subs = res.SBQQ__Subscriptions__r;
                                    subs.forEach(function(s,i){
                                        if(s.SBQQ__RequiredById__c==null && s.SBQQ__Bundle__c==false){
                                            membership = s;
                                        }
                                        else if(s.productcode__c=="INS - PRE"){
                                            premiumCustomer = true;
                                            component.set("v.premiumCustomer", premiumCustomer);
                                        }
                                    });
                                }
                            }
                            component.set("v.userMemberhip",membership);
                            component.set("v.isLoading", false);
                        });
                    }

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
                            signedUp: accdetail.Signed_Up__c,
                            parentalLeave: userdetail.parental_leave_date__c ? true : false,
                            returnToWorkDate: userdetail.parental_leave_date__c,
                            monthofGraduation: accdetail.Graduation_Month__c,
                            studentUniversityEmail: accdetail.Student_University_Email__c,
                            university: accdetail.University__c,
                            dateOfGraduation: userdetail.AS_Graduation_Year__c + '-' + months[accdetail.Graduation_Month__c] + '-' + '01'

                        }
                        component.set("v.profileDetail", profileDetail);

                    }
                })
                .catch(error => console.log(error));
        }

    }
})