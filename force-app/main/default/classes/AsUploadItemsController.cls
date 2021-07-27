/**
 * @author: Jet R. Compayan <jet@alphasys.com.au>
 * @since Sept 5 , 2019
 */ 
public with sharing class AsUploadItemsController {
 
    /**
     * This Method will save the image uploaded from the lightning component.
     * @param  parentId    parentId as Enrollment Id
     * @param  fileName    Filename of the file uploaded
     * @param  base64Data  base64Data  The Image file was converted to base64data to upload in the salesforce.
     * @param  contentType contentType 
     * @param  fileId      fileId 
     * @return             This will return an Attacment Id.
     */ 
    @AuraEnabled
    public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) {
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  which is save the check data and return the attachemnt Id after insert, 
        //  next time (in else) we are call the appentTOFile() method
        //   for update the attachment with reamins chunks   
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        } else {
           // appendToFile(fileId, base64Data); 
        }
        return Id.valueOf(fileId);
    }
    
    /**
     * This method will process the insert the file into the Enrollment Record.
     * @param  parentId    parentId description
     * @param  fileName    Filename of the file uploaded
     * @param  base64Data  base64Data  The Image file was converted to base64data to upload in the salesforce.
     * @param  contentType contentType 
     * @return This will return an Attacment Id.
     */ 
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
 
        Attachment oAttachment = new Attachment();
        oAttachment.parentId = parentId;
 
        oAttachment.Body = EncodingUtil.base64Decode(base64Data);
        oAttachment.Name = fileName;
        oAttachment.ContentType = contentType;
 
        insert oAttachment;
 
        return oAttachment.Id;
    }

    // private static void appendToFile(Id fileId, String base64Data) {
    //     base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
 
    //     Attachment a = [
    //         SELECT Id, Body
    //         FROM Attachment
    //         WHERE Id =: fileId
    //     ];
 
    //     String existingBody = EncodingUtil.base64Encode(a.Body);
 
    //     a.Body = EncodingUtil.base64Decode(existingBody + base64Data);
 
    //     update a;
    // }
 
}