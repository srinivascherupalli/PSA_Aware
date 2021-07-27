({
    doInit : function( component, event, helper ) {  
        document.title = 'PSA';
        component.set("v.isLoading", true);

        //fetch Invoice Id for Payment
        var queryString = window.location.search;
        var urlParams = new URLSearchParams(queryString);
        var quoteId = urlParams.get('quoteId');
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
            studentnumber: ''
        }
        component.set("v.profileDetail", profileDetail);
        helper.getCurrentUserInfo(component, event);
        var userProfile = component.get("v.profileDetail");
        component.set("v.isLoading", false);
    },

    handleUserMembership: function(component, event, helper){
        component.set("v.screenName","screen1b");

        var menuItems = [
            { label: '1. Insurance', screen: 'screen1b', active: true, class: 'fas fa-folder-open'},
            { label: '2. Payment', screen: 'screen2', active: true, class: 'fas fa-folder-open'},
            { label: '3. Review and Confirm',  screen: 'screen3', active: false, class: 'fas fa-folder-open'}
        ];

        menuItems.forEach(item => {
            item.active = (item.screen === component.get("v.screenName"));
        });
            
        component.set("v.menuItems", menuItems);
        component.set("v.isLoading", false);
    },
    
    handleToken: function(c , e, h) {
        console.log(e.target.value);
    }
})