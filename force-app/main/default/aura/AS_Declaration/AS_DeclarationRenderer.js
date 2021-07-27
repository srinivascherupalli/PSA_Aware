({
    afterRender : function( cmp, helper ) {
        helper.doInit(cmp);
        this.superAfterRender();
    }
})