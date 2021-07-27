({
    doInit : function(cmp, event, helper){
        console.log('opened modal with val: ' + cmp.get("v.modalType"));
    },
    
    goToLogin : function(cmp, event, helper){
        //'https://psa-my-psa.cs114.force.com/CommunitiesLogin';
        cmp.find("navService").navigate({
            type: "comm__loginPage",
            attributes: {
                actionName: "login"
            }
        });
    },
    
    goToRegister : function(cmp, event, helper){
        //'https://psa-my-psa.cs114.force.com/CommunitiesSelfReg';
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        var selfRegURL = baseURL + "/CommunitiesSelfReg";
        console.log('Navigating to register' + selfRegURL);

        window.location.href = selfRegURL;

        /* 
        cmp.find("navService").navigate({
            type: "standard__webPage",
            attributes: {
                url: selfRegURL
            }
        }); */
    },

    goToMemberSignup : function(cmp, event, helper){
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        var signUpURL = baseURL + "/MembershipSignUp";
        console.log('Navigating to signUp' + signUpURL);
        
        window.location.href = signUpURL;
    }
})