public class EziDebitUtils {
    
        private static final String GENERATE_TOKEN_XML = 'generateTokenXML ';
        private static final String GENERATE_AUTHORIZE_XML = 'generateAuthorizeXML ';
        private static final String GENERATE_CHARGE_XML = 'generateChargeXML ';
        private static final String GENERATE_VOID_XML = 'generateVoidXML ';
        private static final String GENERATE_REFUND_XML = 'generateRefundXML ';
        private static final String GENERATE_ACH_CHARGE_XML = 'generateACHChargeXML ';
        private static final String GENERATE_ACH_VOID_XML = 'generateACHVoidXML ';
        private static final String GENERATE_ACH_REFUND_XML = 'generateACHRefundXML ';
        private static final String GET_ELEMENTS = 'getElements ';
        private static Boolean IS_MULTICURRENCY_ORG = UserInfo.isMultiCurrencyOrganization();
        private static String CURRENCYISOCODE = 'CurrencyIsoCode';
        
        //Fortino 2021-02-04
        private static final String GENERATE_TOKEN_CRCARD_XML = 'generateTokenCrCardXML ';
        private static final String GENERATE_PAYMENT_DETAIL_XML = 'generatePaymentDetailXML ';
      
    
       // private Attribute to implement singleton pattern for CyberSourceUtils class
       private static EziDebitUtils eziDebitXMLGeneratorInstance;

       private static Map<string, string> mapOfResponseValueByKey = new Map<string, string>();
   
       
       public static EziDebitUtils getInstance() 
       {
           if (NULL == eziDebitXMLGeneratorInstance) 
           {
                eziDebitXMLGeneratorInstance = new EziDebitUtils();
           }
           return eziDebitXMLGeneratorInstance;
       }
       
       
       //Fortino 2021-02-10
          public void generatePaymentDetailXML(List<blng.TransactionParameter> listOfTransactionParameter) 
        {
                       System.debug('Inside Utils - generatePaymentDetailXML');
            try
            {    
                for(blng.TransactionParameter transactionParameterToProcess : listOfTransactionParameter)
                {
                    System.debug('Inside transactionParameterToProcess ');
                    XmlStreamWriter writer = new XmlStreamWriter();
                    // Populate Document start
                    writer.writeStartDocument('utf-8', '1.0');  
                    // Populate Envelope start
                    writer.writeStartElement('soapenv','Envelope','http://schemas.xmlsoap.org/soap/envelope/');
                    writer.writeAttribute('xmlns', 'http://schemas.xmlsoap.org/soap/envelope/', 'soapenv', 'http://schemas.xmlsoap.org/soap/envelope/');
                    writer.writeAttribute('xmlns', 'http://schemas.xmlsoap.org/soap/envelope/', 'px', 'https://px.ezidebit.com.au/');
                        // Populate Header start
                        writer.writeStartElement('soapenv','Header','http://schemas.xmlsoap.org/soap/envelope/');    
                        writer.writeEndElement();                            
                        // Populate Header end
                        // Populate Body start
                        writer.writeStartElement('soapenv','Body','');                                

                        writer.writeStartElement('px','GetPaymentDetail','');

                        // Populate Digital Key start
                        writer.writeStartElement('px','DigitalKey','');
                        writer.writeCharacters('59984E22-9ED0-4832-1ACA-593E7A6E2E21');
                        writer.writeEndElement();
  
                        // Populate PaymentID start
                        writer.writeStartElement('px','PaymentReference','');
                        writer.writeCharacters(transactionParameterToProcess.getTransaction().blng__GatewayID__c);                            
                        //writer.writeCharacters('50820752256931');
                        writer.writeEndElement();                                                               

                        writer.writeEndElement();
                        // Populate Body end
                        writer.writeEndElement();
                        // Populate Envelope end
                        writer.writeEndDocument();
                        transactionParameterToProcess.setRequestBody(writer.getXmlString());
                        writer.close();
                }
            }
            catch (Exception e) 
            {
            throw e;
            }   
        }  
                     
       
       //Fortino 2021-02-05
       
           public void generateRefundXML(List<blng.TransactionParameter> listOfTransactionParameter) 
        {
                       System.debug('Inside Utils - generatetokenxml');
            try
            {    
                for(blng.TransactionParameter transactionParameterToProcess : listOfTransactionParameter)
                {
                    System.debug('Inside transactionParameterToProcess ');
                    XmlStreamWriter writer = new XmlStreamWriter();
                    // Populate Document start
                    writer.writeStartDocument('utf-8', '1.0');  
                    // Populate Envelope start
                    writer.writeStartElement('soapenv','Envelope','http://schemas.xmlsoap.org/soap/envelope/');
                    writer.writeAttribute('xmlns', 'http://schemas.xmlsoap.org/soap/envelope/', 'soapenv', 'http://schemas.xmlsoap.org/soap/envelope/');
                    writer.writeAttribute('xmlns', 'http://schemas.xmlsoap.org/soap/envelope/', 'px', 'https://px.ezidebit.com.au/');
                        // Populate Header start
                        writer.writeStartElement('soapenv','Header','http://schemas.xmlsoap.org/soap/envelope/');    
                        writer.writeEndElement();                            
                        // Populate Header end
                        // Populate Body start
                        writer.writeStartElement('soapenv','Body','');                                

                        writer.writeStartElement('px','ProcessRefund','');

                        // Populate Digital Key start
                        writer.writeStartElement('px','DigitalKey','');
                        writer.writeCharacters('59984E22-9ED0-4832-1ACA-593E7A6E2E21');
                        writer.writeEndElement();
  
                        // Populate PaymentID start
                        writer.writeStartElement('px','PaymentID','');
                        //writer.writeCharacters(transactionParameterToProcess.getPaymentMethod().id);
                        //writer.writeCharacters(transactionParameterToProcess.getPayment().blng__Transaction__c.blng__Authorization__c);    
                        
                        writer.writeCharacters('32969652');       
                        writer.writeEndElement();
                        
                        // Populate BankReceiptIDstart
                        writer.writeStartElement('px','BankReceiptID','');
                        //writer.writeCharacters(transactionParameterToProcess.getPaymentMethod().id);                       
                        writer.writeCharacters('');       
                        writer.writeEndElement();         
                        
                        // Populate BankReceiptIDstart
                        writer.writeStartElement('px','RefundAmountInCents','');
                        //writer.writeCharacters((Decimal)transactionParameterToProcess.getPayment().blng__Amount__c);                       
                        writer.writeCharacters('100');       
                        writer.writeEndElement();                                            
                        
                        writer.writeEndElement();
                        //end AddCustomer
                        writer.writeEndElement();
                        // Populate Body end
                        writer.writeEndElement();
                        // Populate Envelope end
                        writer.writeEndDocument();
                        transactionParameterToProcess.setRequestBody(writer.getXmlString());
                        writer.close();
                }
            }
            catch (Exception e) 
            {
            throw e;
            }   
        }    
           
       //Fortino 2021-02-04
          public void generateTokenCrCardXML(List<blng.TransactionParameter> listOfTransactionParameter) 
        {
                       System.debug('Inside Utils - generatetokenxml');
            try
            {    
                for(blng.TransactionParameter transactionParameterToProcess : listOfTransactionParameter)
                {
                    System.debug('Inside transactionParameterToProcess ');
                    XmlStreamWriter writer = new XmlStreamWriter();
                    // Populate Document start
                    writer.writeStartDocument('utf-8', '1.0');  
                    // Populate Envelope start
                    writer.writeStartElement('soapenv','Envelope','http://schemas.xmlsoap.org/soap/envelope/');
                    writer.writeAttribute('xmlns', 'http://schemas.xmlsoap.org/soap/envelope/', 'soapenv', 'http://schemas.xmlsoap.org/soap/envelope/');
                    writer.writeAttribute('xmlns', 'http://schemas.xmlsoap.org/soap/envelope/', 'px', 'https://px.ezidebit.com.au/');
                        // Populate Header start
                        writer.writeStartElement('soapenv','Header','http://schemas.xmlsoap.org/soap/envelope/');    
                        writer.writeEndElement();                            
                        // Populate Header end
                        // Populate Body start
                        writer.writeStartElement('soapenv','Body','');                                

                        writer.writeStartElement('px','AddCardDebit','');

                        // Populate Digital Key start
                        writer.writeStartElement('px','DigitalKey','');
                        writer.writeCharacters('59984E22-9ED0-4832-1ACA-593E7A6E2E21');
                        writer.writeEndElement();
  
                        // Populate YourSystemReference start
                        writer.writeStartElement('px','YourSystemReference','');
                        //writer.writeCharacters((String)transactionParameterToProcess.getAccount().get('Name'));
                        writer.writeCharacters(transactionParameterToProcess.getPaymentMethod().id);                       
                        //writer.writeCharacters('Myacc11123');       
                        writer.writeEndElement();
       
                        // Populate LastName start
                        writer.writeStartElement('px','LastName','');
                        writer.writeCharacters(transactionParameterToProcess.getPaymentMethod().blng__BillingLastName__c);
                        //writer.writeCharacters('KayJinTest33');   
                        writer.writeEndElement();
                        // Populate FirstName start
                        writer.writeStartElement('px','FirstName','');
                        //writer.writeCharacters(transactionParameterToProcess.getFirstName());
                        writer.writeCharacters(transactionParameterToProcess.getPaymentMethod().blng__BillingFirstName__c);
                        //writer.writeCharacters('KayJinTest33');   
                        writer.writeEndElement();
                        
                        // Populate EmailAddress start
                        writer.writeStartElement('px','EmailAddress','');
                        writer.writeCharacters(transactionParameterToProcess.getPaymentMethod().blng__BillingEmail__c);              
                        writer.writeEndElement();
                        
                        // Populate MobilePhoneNumber start
                        writer.writeStartElement('px','MobilePhoneNumber','');
                        writer.writeCharacters(transactionParameterToProcess.getPaymentMethod().blng__BillingPhone__c);            
                        writer.writeEndElement();
                        
                        // Populate Payment Reference
                        writer.writeStartElement('px','PaymentReference','');
                        writer.writeCharacters(transactionParameterToProcess.getPaymentMethod().blng__Account__c);                           
                        //writer.writeCharacters('KayJinTest3123');          
                        writer.writeEndElement();
                 
                        // Populate NameOnCreditCard
                        writer.writeStartElement('px','NameOnCreditCard','');
                        //writer.writeCharacters(transactionParameterToProcess.getPhone());
                        writer.writeCharacters(transactionParameterToProcess.getPaymentMethod().blng__Nameoncard__c);   
                        //writer.writeCharacters('KayJinTest3');            
                        writer.writeEndElement();
                        
                         // Populate CreditCardNumber
                        writer.writeStartElement('px','CreditCardNumber','');
                        //writer.writeCharacters(transactionParameterToProcess.getPhone());
                        writer.writeCharacters(transactionParameterToProcess.getPaymentMethod().blng__CardNumber__c);      
                        //writer.writeCharacters('4987654321098769');   
                        writer.writeEndElement();
                                                 
                        // Populate CreditCardExpiryYear
                        writer.writeStartElement('px','CreditCardExpiryYear','');
                        //writer.writeCharacters(transactionParameterToProcess.getPhone());
                        writer.writeCharacters(transactionParameterToProcess.getPaymentMethod().blng__CardExpirationYear__c);        
                        //writer.writeCharacters('2021');       
                        writer.writeEndElement();
                                                 
                        // Populate CreditCardExpiryMonth
                        writer.writeStartElement('px','CreditCardExpiryMonth','');
                        writer.writeCharacters(transactionParameterToProcess.getPaymentMethod().blng__CardExpirationMonth__c);            
                        writer.writeEndElement();

                        // Populate PaymentAmountInCents
                        writer.writeStartElement('px','PaymentAmountInCents','');
                        //writer.writeCharacters(transactionParameterToProcess.getPaymentMethod().blng__CardExpirationMonth__c);   
                        writer.writeCharacters('100');         
                        writer.writeEndElement();

                        // Populate DebitDate
                        writer.writeStartElement('px','DebitDate','');
                        //writer.writeCharacters(transactionParameterToProcess.getPaymentMethod().blng__CardExpirationMonth__c);   
                        writer.writeCharacters('2021-02-20');         
                        writer.writeEndElement();
                                                                                                 
                        // Populate SmsPaymentReminder start
                        writer.writeStartElement('px','SmsPaymentReminder','');
                        writer.writeCharacters('YES');
                        writer.writeEndElement();
                        
                        // Populate SmsFailedNotification start
                        writer.writeStartElement('px','SmsFailedNotification','');
                        writer.writeCharacters('YES');
                        writer.writeEndElement();
                        
                        // Populate SmsExpiredCard start
                        writer.writeStartElement('px','SmsExpiredCard','');
                        writer.writeCharacters('YES');
                        writer.writeEndElement();
                        
                        // Populate SmsExpiredCard start
                        writer.writeStartElement('px','Username','');
                        writer.writeCharacters('IntegrationUser');
                        writer.writeEndElement();
                        
                        writer.writeEndElement();
                        //end AddCustomer
                        writer.writeEndElement();
                        // Populate Body end
                        writer.writeEndElement();
                        // Populate Envelope end
                        writer.writeEndDocument();
                        transactionParameterToProcess.setRequestBody(writer.getXmlString());
                        writer.close();
                }
            }
            catch (Exception e) 
            {
            throw e;
            }   
        }

        public void generateTokenXML(List<blng.TransactionParameter> listOfTransactionParameter) 
        {
                       System.debug('Inside Utils - generatetokenxml');
            try
            {    
                for(blng.TransactionParameter transactionParameterToProcess : listOfTransactionParameter)
                {
                               System.debug('Inside transactionParameterToProcess ');
                    XmlStreamWriter writer = new XmlStreamWriter();
                    // Populate Document start
                    writer.writeStartDocument('utf-8', '1.0');  
                    // Populate Envelope start
                    writer.writeStartElement('soapenv','Envelope','http://schemas.xmlsoap.org/soap/envelope/');
                    writer.writeAttribute('xmlns', 'http://schemas.xmlsoap.org/soap/envelope/', 'soapenv', 'http://schemas.xmlsoap.org/soap/envelope/');
                    writer.writeAttribute('xmlns', 'http://schemas.xmlsoap.org/soap/envelope/', 'px', 'https://px.ezidebit.com.au/');
                        // Populate Header start
                        writer.writeStartElement('soapenv','Header','http://schemas.xmlsoap.org/soap/envelope/');    
                        writer.writeEndElement();                            
                        // Populate Header end
                        // Populate Body start
                        writer.writeStartElement('soapenv','Body','');                                

                        writer.writeStartElement('px','AddCustomer','');

                        // Populate Digital Key start
                        writer.writeStartElement('px','DigitalKey','');
                        //writer.writeCharacters('241F14E6-9094-48E3-55B6-7D21CAA5E7A5');
                        writer.writeCharacters('59984E22-9ED0-4832-1ACA-593E7A6E2E21');
                        writer.writeEndElement();
                        // Populate YourGeneralReference start
                        writer.writeStartElement('px','YourGeneralReference','');
                        writer.writeCharacters('');
                        writer.writeEndElement();
                        // Populate YourSystemReference start
                        writer.writeStartElement('px','YourSystemReference','');
                        writer.writeCharacters((String)transactionParameterToProcess.getAccount().get('Name'));
                        writer.writeEndElement();
                        // Populate LastName start
                        writer.writeStartElement('px','LastName','');
                        writer.writeCharacters(transactionParameterToProcess.getPaymentMethod().blng__BillingLastName__c);
                        writer.writeEndElement();
                        // Populate FirstName start
                        writer.writeStartElement('px','FirstName','');
                        //writer.writeCharacters(transactionParameterToProcess.getFirstName());
                        writer.writeCharacters(transactionParameterToProcess.getPaymentMethod().blng__BillingFirstName__c);
                        writer.writeEndElement();
                        // Populate AddressLine1 start
                        writer.writeStartElement('px','AddressLine1','');
                        //writer.writeCharacters(transactionParameterToProcess.getStreet());
                        writer.writeCharacters(transactionParameterToProcess.getPaymentMethod().blng__BillingStreet__c);
                        writer.writeEndElement();
                        // Populate AddressLine2 start
                        writer.writeStartElement('px','AddressLine2','');
                        writer.writeCharacters('');
                        writer.writeEndElement();
                        // Populate AddressSuburb start
                        writer.writeStartElement('px','AddressSuburb','');
                       // writer.writeCharacters(transactionParameterToProcess.getStreet());
                        writer.writeCharacters(transactionParameterToProcess.getPaymentMethod().blng__BillingCity__c);
                        writer.writeEndElement();
                        // Populate AddressState start
                        writer.writeStartElement('px','AddressState','');
                        //writer.writeCharacters(transactionParameterToProcess.getState());
                        writer.writeCharacters(transactionParameterToProcess.getPaymentMethod().blng__BillingStateProvince__c);
                        writer.writeEndElement();
                        // Populate AddressPostCode start
                        writer.writeStartElement('px','AddressPostCode','');
                        writer.writeCharacters(transactionParameterToProcess.getZipCode());
                        writer.writeEndElement();
                        // Populate EmailAddress start
                        writer.writeStartElement('px','EmailAddress','');
                        writer.writeCharacters(transactionParameterToProcess.getEmailId());
                        writer.writeEndElement();
                        // Populate MobilePhoneNumber start
                        writer.writeStartElement('px','MobilePhoneNumber','');
                        writer.writeCharacters(transactionParameterToProcess.getPhone());
                        writer.writeEndElement();
                        // Populate ContractStartDate start
                        writer.writeStartElement('px','ContractStartDate','');
                        writer.writeCharacters('2021-02-20');
                        writer.writeEndElement();
                        // Populate SmsPaymentReminder start
                        writer.writeStartElement('px','SmsPaymentReminder','');
                        writer.writeCharacters('YES');
                        writer.writeEndElement();
                        // Populate SmsFailedNotification start
                        writer.writeStartElement('px','SmsFailedNotification','');
                        writer.writeCharacters('YES');
                        writer.writeEndElement();
                        // Populate SmsExpiredCard start
                        writer.writeStartElement('px','SmsExpiredCard','');
                        writer.writeCharacters('YES');
                        writer.writeEndElement();
                        // Populate SmsExpiredCard start
                        writer.writeStartElement('px','Username','');
                        writer.writeCharacters('IntegrationUser');
                        writer.writeEndElement();
                        
                        writer.writeEndElement();
                        //end AddCustomer
                        writer.writeEndElement();
                        // Populate Body end
                        writer.writeEndElement();
                        // Populate Envelope end
                        writer.writeEndDocument();
                        transactionParameterToProcess.setRequestBody(writer.getXmlString());
                        writer.close();
                }
            }
            catch (Exception e) 
            {
            throw e;
            }   
        }
        
        public void generateChargeXML(Map<String, blng.TransactionParameter> mapOfTransactionParameterByInvoiceId)
        {
            try
            {    
                for(String idToProcess : mapOfTransactionParameterByInvoiceId.keySet())
                {
                    blng.TransactionParameter transactionParameterToProcess = mapOfTransactionParameterByInvoiceId.get(idToProcess);
                    XmlStreamWriter writer = new XmlStreamWriter();
                    if(NULL == mapOfTransactionParameterByInvoiceId.get(idToProcess).getTransaction()) 
                    {
                        // Populate Document start
                        writer.writeStartDocument('utf-8', '1.0');  
                            // Populate Envelope start
                            writer.writeStartElement('soapenv','Envelope','http://schemas.xmlsoap.org/soap/envelope/');
                            writer.writeAttribute('xmlns', 'http://schemas.xmlsoap.org/soap/envelope/', 'soapenv', 'http://schemas.xmlsoap.org/soap/envelope/');
                            writer.writeAttribute('xmlns', 'http://schemas.xmlsoap.org/soap/envelope/', 'px', 'https://px.ezidebit.com.au/');
                                // Populate Header start
                                writer.writeStartElement('soapenv','Header','http://schemas.xmlsoap.org/soap/envelope/');    
                                writer.writeEndElement();                            
                                // Populate Header end
                                // Populate Body start
                                writer.writeStartElement('soapenv','Body','');                                

                                writer.writeStartElement('px','AddPayment','');

                                // Populate Digital start
                                writer.writeStartElement('px','DigitalKey','');
                                writer.writeCharacters('241F14E6-9094-48E3-55B6-7D21CAA5E7A5');
                                writer.writeEndElement();
                                // Populate EziDebitCustomerID start
                                writer.writeStartElement('px','EziDebitCustomerID','');
                                writer.writeCharacters('');
                                writer.writeEndElement();
                                // Populate YourSystemReference start
                                writer.writeStartElement('px','YourSystemReference','');
                                writer.writeCharacters('ViniC');
                                writer.writeEndElement();
                                // Populate DebitDate start
                                writer.writeStartElement('px','DebitDate','');
                                writer.writeCharacters('2020-11-25');
                                writer.writeEndElement();
                                // Populate PaymentAmountInCents start
                                writer.writeStartElement('px','PaymentAmountInCents','');
                                writer.writeCharacters('100');
                                writer.writeEndElement();
                                // Populate PaymentReference start
                                writer.writeStartElement('px','PaymentReference','');
                                writer.writeCharacters('');
                                writer.writeEndElement();
                                // Populate Username start
                                writer.writeStartElement('px','Username','');
                                writer.writeCharacters('TestUser');
                                writer.writeEndElement();
                                
                                writer.writeEndElement();
                                //end AddPayment
                                writer.writeEndElement();
                                // Populate Body end
                                writer.writeEndElement();
                                // Populate Envelope end
                                writer.writeEndDocument();
                                transactionParameterToProcess.setRequestBody(writer.getXmlString());
                                writer.close();
                    }
                          
                }
            } 
            catch (Exception e) 
            {
                throw e;
            }
        }

        public String validateCurrency(blng.TransactionParameter transactionParameterToProcess)
        {
            
            if(IS_MULTICURRENCY_ORG)
                {
                    if(NULL != transactionParameterToProcess.getInvoice())
                    {
                        return getCurrencyISOCode(transactionParameterToProcess.getInvoice());
                    }
                    else if(NULL != transactionParameterToProcess.getAccount())
                    {
                        return getCurrencyISOCode(transactionParameterToProcess.getAccount());
                    }    
                    
                }
                else
                {
                    return UserInfo.getDefaultCurrency();
                }

            return NULL;     
        }
    
        public String getCurrencyISOCode(SObject sObjectInstance)
        {
            if(UserInfo.isMultiCurrencyOrganization()) 
            {
                return (String)sObjectInstance.get(CURRENCYISOCODE);
            }
            return NULL;
        }
        
        public static Map<string, string> getElements(DOM.XMLNode node) 
        {
        
            if(node.getNodeType() == DOM.XMLNodeType.ELEMENT)
            {
                if(String.IsNotBlank(node.getText().trim())) 
                {
                    mapOfResponseValueByKey.put(node.getName(), node.getText().trim());
                }
                
                for(Dom.XMLNode child : node.getChildElements())
                {
                    getElements(child);
                }
            }
            return mapOfResponseValueByKey;
        }
}