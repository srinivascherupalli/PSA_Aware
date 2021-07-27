({
    handleFilesChange: function(component, event, helper) {
         var fileName = 'No File Selected..';
 
         component.set('v.showFile', false );
 
         if (event.getSource().get("v.files").length > 0) {
             fileName = event.getSource().get("v.files")[0]['name'];
 
             var type = event.getSource().get("v.files")[0]['type'];
 
             var ftype = 'unknown';
 
             if( type.split('/')[1] == 'jpg' || type.split('/')[1] == 'png' ) {
                 ftype = 'image'
             } else if( type.split('/')[1] == 'docs' ) {
                 ftype = 'gdocs';
             } else {
                 ftype = 'pdf';
             }
 
             component.set('v.filetype', 'doctype:' + ftype );
 
             component.set('v.filePhisicalName',fileName);
         }
  
         if (component.find("fileId").get("v.files").length > 0) {
             helper.uploadHelper(component, event);
         } else {
             alert('Please Select a Valid File');
         }
     },
 })