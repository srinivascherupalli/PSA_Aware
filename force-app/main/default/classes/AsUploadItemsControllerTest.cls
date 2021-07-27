@isTest
public class AsUploadItemsControllerTest {
    
    public static testmethod void  saveChunk(){
        contact objContact =  new Contact(lastName='test contact');
        insert objContact ;
        
        blob file=  Blob.valueOf('sample text');
        Attachment objAttachment=new Attachment(); 
        objAttachment.Body= file;
        objAttachment.Name = 'test Attachment';
        objAttachment.ParentId = objContact.Id;
        insert objAttachment;
        
        AsUploadItemsController.saveChunk(objContact.id,'testAttachment',file.toString(),'jpg',objAttachment.Id);
        AsUploadItemsController.saveChunk(objContact.id,'testAttachment',file.toString(),'jpg','');
    }
    
    //public static testmethod void  return_account(){
    //    AsUploadItemsController.return_account();
    //}

}