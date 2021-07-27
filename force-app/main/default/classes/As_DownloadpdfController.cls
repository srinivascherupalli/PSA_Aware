global class As_DownloadpdfController {
    
/*
* Author : vincent
* Date : 6/6/2019
* Description: click button to download invoice pdf in locally.
* Parameter : recID,recIDdraft
* Return : attpdf.Id,orderRec.status
*/
    
    @AuraEnabled
    public static Id addinvoicePDF(Id recID){
        //System.debug('addinvoicePDF IdList :' + IdList);
        attachment attpdf = new attachment();
        if (recID != null){
            
            list<attachment> insertinvoiceAttachment = new list<attachment>();
          
            Order orderRec = [Select Id,AccountId,Account.PersonContactId,Account.PersonEmail,Account.Primary_Contact__c,Account.AS_Account_Email__c,AS_Generate_Invoice__c,status,AS_Invoice_Number__c,Account.RecordTypeId,BillToContactId,OpportunityId from Order where Id =:recID];
         
            if(orderRec != null){ //for(Id orderId: IdList)
                if(orderRec.Status == 'Activated') {
                    
                    //create a pageReference instance of the VF page.
                    pageReference pdf;
                    String theUserType = userinfo.getUserType().toLowerCase();
                    if(theUserType == 'guest') {
                        ASPSASettings__c psaSettings = ASPSASettings__c.getOrgDefaults();
                        String theFullurl = (psaSettings.AsInvoicePDFUrl__c!=null)?String.valueOf(psaSettings.AsInvoicePDFUrl__c)+'/apex/AS_InvoicePdf':'https://staging-staging-pharmaceuticalaus.cs6.force.com/apex/AS_InvoicePdf'; //staging url as default if no given data
                        pdf = new PageReference(theFullurl);
                    } else {
                        pdf =Page.AS_InvoicePdf;
                    }
                    
                    //pass the Account Id parameter to the class.
                    pdf.getParameters().put('id',orderRec.Id);
                    Attachment attach = new Attachment();
                    Blob body;
                    if(!test.isRunningTest()){
                        body = pdf.getContent();
                    }else{
                        body=blob.valueOf('TestString');
                    }
                    attach.Body = body;
                    
                    if(orderRec.AS_Invoice_Number__c != null){
                        String invString = orderRec.AS_Invoice_Number__c;
                        attach.Name = invString +'.pdf';
                    } else {
                        attach.Name = 'Invoice - '+orderRec.Id+'.pdf';
                    }
                    attach.IsPrivate = false;
                    attach.ParentId = orderRec.Id;//This is the record to which the pdf will be attached
                    insertinvoiceAttachment.add(attach);
                    
                } 
                
            }
            //insert the list
            System.debug('insertinvoiceAttachment :' + insertinvoiceAttachment);
                     
            insert insertinvoiceAttachment;
            
            //////////////////show attachment pdf////////////////////////
            
            Id userId = UserInfo.getUserId();
            
            Attachment listatt = [Select Id, Name, ContentType, LastModifiedDate, BodyLength, OwnerId, ParentId	
                                        from Attachment WHERE ParentId =:orderRec.Id ORDER BY CreatedDate  DESc Limit 1];
            
           attpdf = listatt;
        }
        return attpdf.Id;
        
    }
    
    @AuraEnabled
    public static String CheckOrderStatus(Id recIDdraft){
		System.debug(recIDdraft);  
        Order orderRec = [Select Id,status from Order where Id =:recIDdraft];
        return orderRec.status;
				
       
    }
    ///updated "6/26/2019" base on ticket PSAMOPT-61
    @AuraEnabled
    public static void Deleteattachment(Id delattchId){
        //System.debug('delattchId===>:'+delattchId);
        if(delattchId!=null){
            Attachment listatt = [Select Id, Name, ContentType, LastModifiedDate, BodyLength, OwnerId, ParentId	
                                  from Attachment WHERE Id =:delattchId];
            delete listatt;
			 //System.debug('listatt===>:'+listatt);
        }
    }
    
}