({
    doInit: function(component, event, helper) {
        if (document.URL.indexOf("#1") == -1) {
            window.location = window.location + '#1';
            window.location.reload();
        }
    }
})