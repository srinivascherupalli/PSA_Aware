/*
 * Author : WEW
 * Description: class use for pdf attachment creation
 * Parameter : None
 * Return : None
 */
global class AS_pdfTriggerController {

    /*
     * Author : WEW
     * Description: method to generate membership subscription certificate
     * Parameter : None
     * Return : None
     */
    @Future(callout = true) @auraEnabled
    public static void addPDFAttach(Map < Id, Id > IdMap) {
        System.debug('addPDFAttach IdMap:' + IdMap);
        list < attachment > insertAttachment = new list < attachment > ();
        List < AS_Subscription__c > allUpdateSubs = new List < AS_Subscription__c > ();

        Map < Id, String > allAccName = new Map < Id, String > ();
        for (AS_Subscription__c sub: [Select Id, Account__r.Name from AS_Subscription__c where Id IN: IdMap.keySet()]) {
            allAccName.put(sub.Id, sub.Account__r.Name);
        }
        System.debug('allAccName :' + allAccName);
        for (Id subsId: IdMap.KeySet()) {

            //create a pageReference instance of the VF page.
            pageReference pdf = Page.AS_Membership_Certificate_PDF;
            //pass the Account Id parameter to the class.
            pdf.getParameters().put('id', subsId);
            Attachment attach = new Attachment();
            Blob body;
            if (!test.isRunningTest()) {
                body = pdf.getContent();
            } else {
                body = blob.valueOf('TestString');
            }
            attach.Body = body;

            if (allAccName.get(subsId) != null) {
                String accNameString = allAccName.get(subsId);
                attach.Name = accNameString + ' Membership Certificate.pdf';
            } else {
                attach.Name = 'Subscription -' + subsId + '.pdf';
            }

            attach.IsPrivate = false;

            if (IdMap.get(subsId) != null) {
                attach.ParentId = IdMap.get(subsId); //This is the record to which the pdf will be attached
            } else {
                attach.ParentId = subsId; //This is the record to which the pdf will be attached
            }
            insertAttachment.add(attach);

            AS_Subscription__c indiUpdateSubs = new AS_Subscription__c();
            indiUpdateSubs.Id = subsId;
            indiUpdateSubs.AS_Generate_Subscription__c = false;
            allUpdateSubs.add(indiUpdateSubs);

        }
        //insert the list
        System.debug('insertAttachment for subscription:' + insertAttachment);
        insert insertAttachment;

        update allUpdateSubs;
    }


    /*
     * Author : WEW
     * Description: method to generate order invoice
     * Parameter : None
     * Return : None
     */
    @Future(callout = true) @auraEnabled
    webservice static void addinvoicePDFandEmail(list < id > IdList) {
        System.debug('addinvoicePDFandEmail IdList :' + IdList);
        EmailTemplate emailTempInvoice = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Invoice_PDF_email_1'];
        list < attachment > insertinvoiceAttachment = new list < attachment > ();
        List < Order > allUpdateOrder = new List < Order > ();
        List < Opportunity > allUpdateOpp = new List < Opportunity > ();
        List < Messaging.SingleEmailMessage > allmsg = new List < Messaging.SingleEmailMessage > ();
        List < OrgWideEmailAddress > owea = [select Id, Address from OrgWideEmailAddress where Address = 'noreply@psa.org.au'];
        Map < Id, Order > mapAllOrder = new Map < Id, Order > ();

        //added person or business account code
        Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Id businessAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();

        for (Order ord: [Select
                Id,
                AccountId,
                Account.PersonContactId,
                Account.Name,
                Account.PersonEmail,
                Account.Primary_Contact__c,
                Account.AS_Account_Email__c,
                AS_Generate_Invoice__c,
                status,
                AS_Invoice_Number__c,
                Account.RecordTypeId,
                BillToContactId,
                OpportunityId,
                Opportunity.AS_PSA_Subscription__r.Account__r.PersonContactId
                from
                Order
                where Id IN: IdList
            ]) {
            mapAllOrder.put(ord.Id, ord);
        }
        System.debug('mapAllOrder :' + mapAllOrder);

        System.debug('IdList :' + IdList);
        for (Id orderId: IdList) {
            if (mapAllOrder.get(orderId).AS_Generate_Invoice__c == true && mapAllOrder.get(orderId).Status == 'Activated') {

                //create a pageReference instance of the VF page.
                pageReference pdf;
                String theUserType = userinfo.getUserType().toLowerCase();
                if (theUserType == 'guest') {
                    ASPSASettings__c psaSettings = ASPSASettings__c.getOrgDefaults();
                    String theFullurl = (psaSettings.AsInvoicePDFUrl__c != null) ? String.valueOf(psaSettings.AsInvoicePDFUrl__c) + '/AS_InvoicePdf' : 'https://psa.secure.force.com/AS_InvoicePdf'; //staging url as default if no given data
                    pdf = new PageReference(theFullurl);
                } else {
                    pdf = Page.AS_InvoicePdf;
                } 

                //pass the Account Id parameter to the class.
                pdf.getParameters().put('id', orderId);
                Attachment attach = new Attachment();
                Blob body;
                if (!test.isRunningTest()) {
                    body = pdf.getContent();
                } else {
                    body = blob.valueOf('TestString');
                }
                attach.Body = body;

                if (mapAllOrder.get(orderId).AS_Invoice_Number__c != null) {
                    String invString = mapAllOrder.get(orderId).AS_Invoice_Number__c;
                    attach.Name = invString + '.pdf';
                } else {
                    attach.Name = 'Invoice - ' + orderId + '.pdf';
                }
                attach.IsPrivate = false;
                attach.ParentId = orderId; //This is the record to which the pdf will be attached
                insertinvoiceAttachment.add(attach);
                // for email
                if (mapAllOrder.get(orderId).Account.PersonEmail != null || mapAllOrder.get(orderId).Account.AS_Account_Email__c != null) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                    Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
                    efa1.setFileName(attach.Name);
                    efa1.setBody(attach.Body);

                    mail.setTemplateId(emailTempInvoice.Id);

                    if (mapAllOrder.get(orderId).Account.RecordTypeId == personAccRecId) { // PSAS-31 , March 8

                        mail.setTargetObjectId(mapAllOrder.get(orderId).Account.PersonContactId);

                    } else if (mapAllOrder.get(orderId).Account.RecordTypeId == businessAccRecId) {

                        // mail.setToAddresses( mapAllOrder.get(orderId).Account.AS_Account_Email__c );
                        mail.setTargetObjectId(mapAllOrder.get(orderId).Account.Primary_Contact__c);

                    } else {

                    } 


                    if (owea.size() > 0) {

                        mail.setorgWideEmailAddressId(owea[0].Id);

                    }

                    mail.setWhatId(orderId); 
                    mail.setFileAttachments(new Messaging.EmailFileAttachment[] {
                        efa1
                    }); // this is for attachment
                    mail.setSaveAsActivity(false);
                    allmsg.add(mail);
                }
                // for order
                Order indiUpdateOrder = new Order();
                indiUpdateOrder.Id = orderId;
                indiUpdateOrder.As_Account_Name__c = mapAllOrder.get(orderId).Account.Name;
                indiUpdateOrder.AS_Generate_Invoice__c = false;
                allUpdateOrder.add(indiUpdateOrder);

                // for opportunity 
                if (mapAllOrder.get(orderId).OpportunityId != null) {
                    Opportunity indiUpdateOpp = new Opportunity();
                    indiUpdateOpp.Id = mapAllOrder.get(orderId).OpportunityId;
                    indiUpdateOpp.Generate_Order__c = false;
                    allUpdateOpp.add(indiUpdateOpp); 
                }
            } 

        }
        //insert the list
        System.debug('insertinvoiceAttachment :' + insertinvoiceAttachment);
        System.debug('allUpdateOrder :' + allUpdateOrder);
        System.debug('allUpdateOpp :' + allUpdateOpp);
        System.debug('allmsg :' + allmsg);

        insert insertinvoiceAttachment;

        update allUpdateOrder;
        update allUpdateOpp;

        Messaging.SendEmailResult[] wew = Messaging.sendEmail(allmsg, false);


    }

    @AuraEnabled
    webservice static void createInvoiceByButton(Id OrderId) {
        system.debug('OrderId : ' + OrderId);

        Order updateOrd = new Order();
        updateOrd.Id = OrderId;
        updateOrd.AS_Generate_Invoice__c = true;
        update updateOrd;
    }

    @AuraEnabled
    webservice static void createSubsCertByButton(Id subscriptionId) {
        system.debug('subscriptionId : ' + subscriptionId);

        AS_Subscription__c indiUpdateSubs = new AS_Subscription__c();
        indiUpdateSubs.Id = subscriptionId;
        indiUpdateSubs.AS_Generate_Subscription__c = true;
        update indiUpdateSubs;

        system.debug('indiUpdateSubs : ' + indiUpdateSubs);
    }

    public Id OrderId {
        get;
        set;
    }

    public Order getfinalOrderData() {
        Order finalNameStr = [Select Account.Name, OrderNumber, Account.PSA_PSA_ID__c from Order where ID =: OrderId LIMIT 1];
        return finalNameStr;
    }


    /*
    public String OrderId {
    get {

    return allprocessOrdItem;
    }
    set;
    }
    */
}