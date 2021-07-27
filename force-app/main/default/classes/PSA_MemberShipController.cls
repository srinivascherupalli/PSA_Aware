public without Sharing class PSA_MemberShipController {
    
    public static Order testOrder;
    
    final static Map<String, String> memRoleMap = new Map<String, String> {
            'Pharmacist' => 'essential',
            'Pharmacy Assistant' => 'graduate',
            'Pharmacy Intern' => 'intern',  
            'Pharmacy Student' => 'student',
            'Health Sector Worker' => 'essential'
            };

    @AuraEnabled
    public Static User fetchCurrentUser(String userId) {
       List<User> userList = [SELECT Id,
                             Email,
                             ContactId,
                             Contact.Email,
                             Contact.Title,
                             Contact.Salutation,
                             Contact.FirstName,
                             Contact.LastName,
                             Contact.Gender__c,
                             Contact.Birthdate,
                             Contact.AS_Personal_Email__c,
                             Contact.MailingCountry,
                             Contact.Phone,
                             Contact.MailingStreet,
                             Contact.MailingCity,
                             Contact.MailingPostalCode,
                             Contact.MailingState,
                             Contact.AS_Role__c,
                             Contact.AS_Graduation_Year__c,
                             Contact.AS_AHPRA_Number__c,
                             Contact.AS_Hours_Worked_Per_Week__c,
                             Contact.AS_Student_Number__c,
                             Contact.PSA_Primary_Employment_Sector__c,
                             Contact.AS_Yr_of_Initial_Registration_in_Aust__c,
                             Contact.parental_leave_date__c,
                             Account.Student_University_Email__c,
                             Account.University__c,
                             Account.Graduation_Month__c,
                             Contact.AccountId,
                             Account.Signed_Up__c
                             FROM User
                             WHERE Id =: userId] ;
        
        return !userList.isEmpty() ? userList[0] : new User();
                
    }
    
    @AuraEnabled
    public Static string CheckisUserAvailability(String email) {
        if(String.isBlank(email)) return null;
        
        List<User> userList = [SELECT Id,Account.Signed_Up__c FROM User WHERE Contact.Email =: email];
        return (userList.isEmpty() ? 'Not registered' : (userList[0].Account.Signed_Up__c ? 'Member' : 'Not a member'));
    }
    
    public static List<User> getUserByEmail(string userEmail)
    {
        try
        {            
            return [select id from  User where Contact.Email =: userEmail];
        }
        catch(Exception e)
        {
            return NULL;
        }
    }

    @AuraEnabled
    public static Contract getUserMembershipDetails(String accountId) {
        list<Contract> reslist = new list<Contract>();

        Contract res = null;

        reslist = [Select Id, 
                    (Select SBQQ__Product__c,
                        SBQQ__ProductName__c,
                        SBQQ__StartDate__c,
                        SBQQ__EndDate__c,
                        SBQQ__BillingFrequency__c,
                        productcode__c,
                        SBQQ__Bundle__c,
                        SBQQ__RequiredById__c,
                        Auto_Renew__c
                    From SBQQ__Subscriptions__r
                    )
                From Contract 
                Where AccountId =: accountId 
                And SBQQ__ActiveContract__c=1 
                limit 1];

        if(!reslist.isEmpty()){
            res = new Contract();
            res = reslist[0];
        }

        return res;
    }

    @AuraEnabled
    public static PSAUTils.PaymentResponse ProcessPayment(String paymentdetails, string invoiceId) {
       return PSAUtils.ProcessPayment(paymentdetails,invoiceId);
       
    }

    @AuraEnabled
    public static PSAUTils.PaymentResponse ProcessPaymentForGivenQuote(String paymentdetails, string quoteId) {
        
       return PSAUtils.ProcessPaymentForQuote(paymentdetails,quoteId);        
    }
    
    // Method to check if the payment process has been completed for a guest user
    @AuraEnabled
    public static PSAUtils.PaymentResponse CheckPaymentProcess(String invoiceId, String sessionId)
    {
        map<string, object> payload = PSAUtils.CheckPaymentProcess(invoiceId);
        system.debug('#### Response after asych process ' + JSON.serializePretty(payload));
        if (payload != null)
        {
            PSAUtils.PaymentResponse pResponse = (PSAUtils.PaymentResponse)JSON.deserialize(JSON.serialize(payload.get('response')), PSAUtils.PaymentResponse.class);           
            if (pResponse.isSuccess)
            {
                Account acc = [select Id from Account where Id = :String.valueOf(payload.get('accountId'))];
                acc.Signed_Up__c = true;
                update acc;
                
                Opportunity opp =	[Select Id from Opportunity where AccountId=:acc.Id and Sign_Up_Session_Id__c = :sessionId]; 
                opp.Is_Abandoned__c = false;
                update opp;
            }
            
            return pResponse;
        }
        else
            return null;
    }
    
    @AuraEnabled
    public static Boolean CheckPaymentProcessByQuoteId(String quoteId, String sessionId)
    {
        map<string, object> payload = PSAUtils.CheckPaymentProcessByQuoteId(quoteId);
        system.debug('#### Response after asych process ' + JSON.serializePretty(payload));
        if (payload != null)
        {            
            return true;
        }
        else
            return false;
    }

    @AuraEnabled
    public static void updatePaymentWithInvoiceId(string quoteId, string invoiceId) {
 
        string code = 'System.enqueueJob(new PaymentProcessQueueable(\'' + quoteId + '\',\'' + invoiceId + '\',4));';
        string encodedCode = EncodingUtil.urlEncode(code, 'UTF-8');
        PSAUtils.makeCallout('GET', 'tooling/executeAnonymous/?anonymousBody=' + encodedCode, null);
        system.debug('##### successfully pushed Payment update payload to queue for asych processing');  

    }
    
    @AuraEnabled
    public static String CreateMember(String userJson) {

        System.debug('payload:- ' + userJson);

        RequestMembershipData reqData = (RequestMembershipData)json.deserialize(userJson, RequestMembershipData.class);
        System.Debug('Formatted Payload: ' + JSON.serializePretty(reqData)); 
        
        String userId;
        Savepoint sp = Database.setSavepoint();
        try
        {
            //check for existing user
            List<User> existingUser  = getUserByEmail(reqData.email);
            if(!existingUser.isEmpty() && existingUser.size() > 0)
            {
                userId = existingUser[0].Id;
            }
            //Create a new Portal User
            else 
            {            
                /*if(String.IsNotBlank(reqData.email) &&  String.IsNotBlank(reqData.firstname) && String.IsNotBlank(reqData.lastname) && String.IsNotBlank(reqData.password))
                {
                    User portalUser = new User();
                    portalUser.Username = reqData.email;
                    portalUser.Email = reqData.email;
                    portalUser.FirstName = reqData.firstname;
                    portalUser.LastName = reqData.lastname;
                    portalUser.CommunityNickname = portalUser.FirstName+portalUser.LastName+As_commonFunction.generateRandomIntString(2);
                    portalUser.ProfileId = [Select id from Profile where name = 'Non Member Login User' limit 1].Id;

                    try
                    {
                        userId = Site.createPersonAccountPortalUser(portalUser, '0059D000002LnvSQAS', reqData.password);
                        System.debug('newUserCreated:- ' + userId);
                    }                
                    catch(Site.ExternalUserCreateException ex)
                    {
                        System.debug('Error while creating Person Account Portal User StackTrace=>'+ex.getStackTraceString()+'Message=>'+ex.getMessage());
                        return null;
                    }                
                }*/                
            }

            if(String.IsNotBlank(userId))
            {                    
                Account updateAccount = updateAccountDetails(userId, reqData);
                update updateAccount;  

                System.debug('updatedAccountId:- ' + updateAccount.Id);
                return updateAccount.Id;
            }
        
        return null;

        }
        catch (Exception ex) 
        {
            System.debug('Error while creating & updating Person Account Portal User StackTrace =>'+ex.getStackTraceString()+'Message=>'+ex.getMessage());
            Database.rollback(sp);
            return null;
        }
        
       

        
    }

    public static Account updateAccountDetails(String userId, RequestMembershipData reqData)
    {
        Account updateAccount = new Account();
        Contact updateContact = new Contact();
        User currUser = [Select AccountId,ContactId from User where Id =: userId];
        updateAccount.Id = currUser.AccountId;      
        updateContact.Id = currUser.ContactId;

        if(String.isNotBlank(reqData.phone)) 
            updateAccount.Phone = reqData.phone;

        if(String.isNotBlank(reqData.title)) 
            updateAccount.Salutation = reqData.title;
        
        if(String.isNotBlank(reqData.dobdate)) 
            updateAccount.PersonBirthdate = Date.valueOf(reqData.dobdate);
        
        if(String.isNotBlank(reqData.gender)) 
           updateAccount.Gender__pc = reqData.gender;

        string address1 = String.isNotBlank(reqData.address1)? reqData.address1 : '' ;
        string address2 = String.isNotBlank(reqData.address2)? reqData.address2 : '' ;
        updateAccount.BillingStreet = address1 + ' ' + address2; 

        if(String.isNotBlank(reqData.city))                    
            updateAccount.BillingCity = reqData.city;
        if(String.isNotBlank(reqData.state))
            updateAccount.BillingState = reqData.state;
        if(String.isNotBlank(reqData.postalCode))
            updateAccount.BillingPostalCode = reqData.postalCode;
        if(String.isNotBlank(reqData.country))
            updateAccount.BillingCountry = reqData.country;


        //career details updated values
        if(String.isNotBlank(reqData.role)) 
            updateAccount.AS_Role__pc = reqData.role;

      
        updateAccount.PSA_Primary_Employment_Sector__pc = reqData.employment; 

        //Date of Initial Pharmacy Qualification
        updateAccount.AS_Graduation_Year__pc =reqData.yrofqualification;
        updateAccount.Graduation_Month__c =reqData.monthofqualification;
        updateAccount.AS_AHPRA_Number__pc=reqData.AHPRA;

        //Year of Initial registration as Pharmacist in Australia
        if(reqData.oversearegistration != null  && reqData.oversearegistration)
            updateAccount.AS_Yr_of_Initial_Registration_in_Aust__pc= reqData.yrOfRegistration;
        else 
            updateAccount.AS_Yr_of_Initial_Registration_in_Aust__pc= '';

        updateAccount.AS_Hours_Worked_Per_Week__pc=reqData.hoursworkedperweek;

        //Return to Work date if on Parental leave
        if(reqData.parentalLeave != null  && reqData.parentalLeave)
            updateAccount.parental_leave_date__pc= Date.valueOf(reqData.returnToWorkDate);
        else 
            updateAccount.parental_leave_date__pc= null;


        //Intended University of Graduation for Pharmacy Student OR  University of Graduation for Pharmacy Intern
        updateAccount.University__c =reqData.university; 

        updateAccount.AS_Student_Number__pc=reqData.studentnumber;
        updateAccount.Student_University_Email__c =reqData.studentUniversityEmail;
		
        updateContact.MailingStreet = updateAccount.BillingStreet;
        updateContact.MailingCity = updateAccount.BillingCity;
        updateContact.MailingState = updateAccount.BillingState;
        updateContact.MailingPostalCode = updateAccount.BillingPostalCode;
        updateContact.MailingCountry = updateAccount.BillingCountry;
        update updateContact;
        
        return updateAccount;
    }
    
    
    public Static list<PSAUtils.returnProductAura> getMemberShipProducts(String frequency, String type) {  
        //frequency=monthly, annually, quarterly
        
        System.debug('frequency:- ' + frequency);
        //System.debug('role:- ' + role);
        
        //String query= createSOQL(memRoleMap.get(role));
        String query= createSOQL(type);
        System.debug('query:- ' + query);
        List<product2> returnproducts = Database.query(query);   
        
        Map<string,product2> productmap = new map<string,product2>();  //map of productcode to product
        
        for (product2 p: returnproducts) {
            productmap.put(p.productcode, p);
        }
        
        list <ListPrice__c> lp = [SELECT Frequency__c, 
                                    ismember__c,
                                    isStudent__c,
                                    ListPrice__c,
                                    productcode__c, 
                                    aftertax__c,
                                    ActualPrice__c,
                                    Inclusions__c
                                  FROM ListPrice__c
                                  WHERE productcode__c=: productmap.keySet()
                                  AND (Frequency__c=:frequency OR Frequency__c=null) ];
                                    
        map <string,  ListPrice__c> pricemap=new map <string,  ListPrice__c>();
        for (ListPrice__c l : lp) {
            pricemap.put(l.productcode__c, l);
        }

        List<PSAUtils.returnProductAura> rpa = createRPA (returnproducts,pricemap);       
        
        string s = '';
        for (PSAUtils.returnProductAura r : rpa) s += '\n' + r;
        system.debug('subList:- ' + s);

        return rpa;
    }

    @AuraEnabled
    public static String getPremiumListPrice(list<String> productNames){
        String result = null;
        system.debug('prodNames:- ' + productNames);
        // list<String> prods = new list<String>();
        // prods = (productNames!=null)? productNames.split(',') : prods;
        if(!productNames.isEmpty()){
            list <ListPrice__c> lp = [SELECT Name, Frequency__c, 
                                    ismember__c,
                                    isStudent__c,
                                    ListPrice__c,
                                    productcode__c, 
                                    aftertax__c,
                                    ActualPrice__c
                                  FROM ListPrice__c
                                  WHERE Name In :productNames ];
            if(!lp.isEmpty()){
                result = JSON.serialize(lp);
            }
        }
        return result;
    }

    //Added for premium bundle
    @AuraEnabled
    public static String getPremiumProduct(String accountId, String sessionId) {
        String result = null;
        String productId = [Select Id From Product2 Where ProductCode='INS - PRE' And Isactive=true Limit 1].Id;
        if(productId!=null){
            list<SBQQ__ProductOption__c> pos = [Select Id,Name,SBQQ__OptionalSKU__c, SBQQ__ProductName__c,SBQQ__UnitPrice__c,SBQQ__ProductCode__c From SBQQ__ProductOption__c Where SBQQ__ConfiguredSKU__c=:productId];
            result = (pos.size()>0)?JSON.serialize(pos):null;
        }
        return result;
        /* ProductReader preader = new ProductReader();
        
        String pricebookId = [Select Id From Pricebook2 Where Name='Standard Price Book' And Isactive=true Limit 1].Id;
        System.debug('Pricebook: ' + pricebookId);
        String productId = [Select Id From Product2 Where ProductCode='INS - PRE' And Isactive=true Limit 1].Id;
        System.debug('Product: ' + productId);
        CPQModels.ProductModel product = preader.read(productId,pricebookId,null);
        System.debug('Product: ' + JSON.serialize(product));
        Product2 p1 = new Product2(Id=productId);
        p1.ProductAPIJson__c = JSON.serialize(product);
        update p1;
        return JSON.serialize(product); */
    }

    @AuraEnabled
    public Static list<PSAUtils.returnProductAura> getMemberShipProductPackages(String frequency, String accountId) {  
        //frequency=monthly, annually, quarterly
        
        System.debug('frequency:- ' + frequency);
        System.debug('accountId:- ' + accountId);

        list<PSAUtils.returnProductAura> packageList = new List<PSAUtils.returnProductAura>();       

        List<Account> accList = [Select Id, AS_Role__pc,AS_Years_Since_Graduation__pc,BillingCountry,AS_AHPRA_Number__pc, AS_Yr_of_Initial_Registration_in_Aust__pc, AS_Hours_Worked_Per_Week__pc, parental_leave_date__pc  from Account where Id=: accountId];
        if(!accList.isEmpty() &&  accList.size()> 0 ) 
        {
            if (String.isNotBlank(accList[0].AS_Role__pc))
            {
                string accRole = accList[0].AS_Role__pc;
                string billingCountry = accList[0].BillingCountry;
                string hrsWorkedPerWeek = accList[0].AS_Hours_Worked_Per_Week__pc;
                decimal yearsSinceGraduation = accList[0].AS_Years_Since_Graduation__pc;
                date parentalLeaveDate = accList[0].parental_leave_date__pc;

                if(accRole.equalsIgnoreCase('Pharmacist'))
                {
                    if(billingCountry!= 'Australia' 
                            || hrsWorkedPerWeek.containsIgnoreCase('Part Time') 
                            || (yearsSinceGraduation > 2 && yearsSinceGraduation < 5) 
                            || parentalLeaveDate > System.Today())
                    {
                        //Essential
                        System.debug('Came in Pharmacist Essential');
                        packageList =  getMemberShipProducts(frequency, 'Essential');
                    }
                    else 
                    {
                        //AdvantageProfessionalPlus      
                        packageList =  getMemberShipProducts(frequency, 'AdvantageProfessionalPlus');                 
                    }
                }
                else if(accRole.equalsIgnoreCase('Pharmacy Student')) {
                    //StudentEssential
                    packageList = getMemberShipProducts(frequency, 'StudentEssential');                   
                }
                else if(accRole.equalsIgnoreCase('Pharmacy Intern'))
                {
                    //GraduateEssential
                    packageList = getMemberShipProducts(frequency, 'GraduateEssential');
                }
                else {
                    //Essential
                    packageList = getMemberShipProducts(frequency, 'Essential');
                }

            }
            else {
            return null;
            }
        }

        string n = '';
        for (PSAUtils.returnProductAura pkg : packageList) n += '\n' + pkg;
        system.debug('finalList:- ' + n);

        return packageList;

        
       
    }
    
    static string createSOQL (string type) {
        final String FROMProduct ='Product2 ';  
    
        list<PSAAuraProductFields__mdt> productMeta = [SELECT Fields_Criteria__c, Fields_Select__c FROM PSAAuraProductFields__mdt  WHERE Type__c=:type];
        
        string myQuery='SELECT ID, productcode, ';
        
        for (PSAAuraProductFields__mdt f: productMeta ) {
             myQuery+= f.Fields_Select__c ;
        }
        
        myQuery+= ' FROM ' + FROMProduct + ' WHERE ';

        for (PSAAuraProductFields__mdt f: productMeta ) {
             myQuery+= f.Fields_Criteria__c;
        }
    
        return myQuery;
    }
    
    static list<PSAUtils.returnProductAura> createRPA (list<product2> returnproducts, map <string,  ListPrice__c> pricemap){
        
        list<PSAUtils.returnProductAura> rpa=new  list<PSAUtils.returnProductAura> ();
        
        for (product2 p : returnproducts) {
        
        system.debug('aaaaaaa ' +p.productcode);
        
            if (pricemap.containsKey(p.productcode)){
                PSAUtils.returnProductAura rp = new PSAUtils.returnProductAura();
                rp.product=p;
                rp.actualprice=pricemap.get(p.productcode).ActualPrice__c;
                rp.listprice=pricemap.get(p.productcode).ListPrice__c;
                rp.netprice=pricemap.get(p.productcode).aftertax__c;
                rp.inclusions=pricemap.get(p.productcode).inclusions__c;
                rp.configuredSKU = null;
                rp.isBundle = false;
                rp.optionId = null;
                rp.optionType = null;
                rpa.add(rp);                
            }    
        }
         
         return rpa;
     }


     //After product/shopping has been selected and submitted, communities should pass the wrapper returnProductAura, and accountid.
    //code then creates Opportunity.
    //there is already an existing processbuilder (from phase1) that will autocreate the Quote.
    /*public static string productSelectionBk(list<returnProductAura> products, string accountId) {

        try
        {   
            opportunity opp= new opportunity();
            opp.closedate=system.today();
            opp.stagename='Prospecting';
            opp.Name=[SELECT name FROM Account WHERE id=:accountId].name;
            opp.AccountId = accountId;
            opp.Pricebook2id=[SELECT Id from Pricebook2 WHERE Name='Standard Price Book' AND isactive=true].id;
            opp.recordtypeid=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CPQ').getRecordTypeId();
            insert opp;

            List<Opportunity> oppList =[Select SBQQ__PrimaryQuote__r.Id, SBQQ__Ordered__c from Opportunity where Id=: opp.Id];
            if(!oppList.isEmpty() && oppList.size() > 0 )
            {
                string quoteId = oppList[0].SBQQ__PrimaryQuote__r.Id;

                if(quoteId != null)
                {
                    
                    //prepare a key map to get all the products from the list received from FE

                    Map<String, Product2> productmap = new map<String, Product2>();
                    for (returnProductAura rp: products) {
                        productmap.put(rp.product.ProductCode, rp.product);
                    }

                    //get all the required twinning fields from Product2 object to map into Quote Lines fields
                    List<Product2> productList = [SELECT ProductCode, SBQQ__ChargeType__c, SBQQ__BillingType__c, SBQQ__BillingFrequency__c,SBQQ__SubscriptionTerm__c,SBQQ__SubscriptionPricing__c,SBQQ__SubscriptionType__c FROM Product2 WHERE productcode =: productmap.keySet() ];

                    
                    //Build a map with received Products vs Twinning fields or additional fields from Product2 object
                    Map<String, Product2> chargeTypeMap=new Map<String, Product2>();

                    for (Product2 product : productList) {
                        chargeTypeMap.put(product.ProductCode, product);
                    }


                    //Code to create Quote Lines

                    List<SBQQ__QuoteLine__c> quoteLineItemiList = new List<SBQQ__QuoteLine__c>();
            
                    for(returnProductAura rpa  : products) {    

                        SBQQ__QuoteLine__c quoteLineItem =new SBQQ__QuoteLine__c ();
                        
                        quoteLineItem.SBQQ__Product__c=rpa.product.Id;
                        quoteLineItem.SBQQ__Quote__c = quoteId;
                        quoteLineItem.SBQQ__Quantity__c = 1;
                        quoteLineItem.SBQQ__ListPrice__c = rpa.listprice;
                        //quoteLineItem.SBQQ__RegularPrice__c = 300;
                        //quoteLineItem.SBQQ__CustomerPrice__c = 312;
                        quoteLineItem.SBQQ__NetPrice__c = rpa.listprice;
                        quoteLineItem.SBQQ__PricebookEntryId__c = '01u7F000004K48yQAC';

                        if(chargeTypeMap.containsKey(rpa.product.productcode))
                        {
                            quoteLineItem.SBQQ__ChargeType__c = chargeTypeMap.get(rpa.product.productcode).SBQQ__ChargeType__c;
                            quoteLineItem.SBQQ__BillingType__c = chargeTypeMap.get(rpa.product.productcode).SBQQ__BillingType__c;
                            quoteLineItem.SBQQ__BillingFrequency__c = chargeTypeMap.get(rpa.product.productcode).SBQQ__BillingFrequency__c;

                            quoteLineItem.SBQQ__SubscriptionPricing__c = chargeTypeMap.get(rpa.product.productcode).SBQQ__SubscriptionPricing__c;
                            //quoteLineItem.SBQQ__ProductSubscriptionType__c = chargeTypeMap.get(rpa.product.productcode).SBQQ__SubscriptionType__c;
                            quoteLineItem.SBQQ__DefaultSubscriptionTerm__c = chargeTypeMap.get(rpa.product.productcode).SBQQ__SubscriptionTerm__c;
                        }

                        quoteLineItemiList.add(quoteLineItem);              
                    }
                    if(!quoteLineItemiList.isEmpty())
                        insert quoteLineItemiList;

                     

                    //Code to update the status of quote to accepted
                    List<SBQQ__Quote__c> quoteList = [Select SBQQ__Status__c From SBQQ__Quote__c where Id=: quoteId];
                    if(quoteList.size() > 0 && !quoteList.isEmpty())
                    {
                        System.debug('Came');
                        SBQQ__Quote__c quote = quoteList[0];
                        quote.SBQQ__Status__c = 'Accepted';
                        update quote;
                    }


                    //code to trigger contract from order
                    List<Order> orderList = [Select Id, SBQQ__Contracted__c, blng__BillNow__c, Status From Order where SBQQ__Quote__r.Id=: quoteId and Status='Activated'];
                    if(!orderList.isEmpty()  && orderList.size() > 0)
                    {
                        Order updateOrder = orderList[0];
                        updateOrder.SBQQ__Contracted__c = true;
                        update updateOrder;        

                        return updateOrder.Id;          
                       
                    }

                    

                }
            }            

            return null;
        }
        catch(exception e) {
               return e.getmessage();        
        }
        
    }*/

    public static void createOpportunity(string productName, ID accountId, string sessionId)
    {
            opportunity opp= new opportunity();
        	opp.Is_Abandoned__c = true;
            opp.closedate=system.today();
            opp.stagename='Prospecting';
            opp.Name=[SELECT name FROM Account WHERE id=:accountId].name + ' ' + productName;
            opp.AccountId = accountId;
            opp.Created_by_Community__c = true;
        	opp.Sign_Up_Session_Id__c = sessionId;
            opp.Pricebook2id=!Test.isRunningTest() ? [SELECT Id from Pricebook2 WHERE Name='Standard Price Book' AND isactive=true].id
                : Test.getStandardPricebookId();
            opp.recordtypeid=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CPQ').getRecordTypeId();
            insert opp;
        
        /*//list<PSAUtils.returnProductAura> products = (list<PSAUtils.returnProductAura>)JSON.deserialize(productJSON, list<PSAUtils.returnProductAura>.class);
            List<Opportunity> oppList =[Select SBQQ__PrimaryQuote__c, SBQQ__Ordered__c from Opportunity where Id=:opp.Id];
            if(!oppList.isEmpty() && oppList.size() > 0 )
            {
                string quoteId = oppList[0].SBQQ__PrimaryQuote__c;

                if(quoteId != null)
                {
                    
                    //prepare a key map to get all the products from the list received from FE

                    Map<String, Product2> productmap = new map<String, Product2>();
                    for (PSAUtils.returnProductAura rp: products) {
                        productmap.put(rp.product.ProductCode, rp.product);
                    }

                    //get all the required twinning fields from Product2 object to map into Quote Lines fields
                    List<Product2> productList = [SELECT ProductCode, SBQQ__ChargeType__c, SBQQ__BillingType__c, SBQQ__BillingFrequency__c,SBQQ__SubscriptionTerm__c,SBQQ__SubscriptionPricing__c,SBQQ__SubscriptionType__c FROM Product2 WHERE productcode =: productmap.keySet() ];

                    
                    //Build a map with received Products vs Twinning fields or additional fields from Product2 object
                    Map<String, Product2> chargeTypeMap=new Map<String, Product2>();

                    for (Product2 product : productList) {
                        chargeTypeMap.put(product.ProductCode, product);
                    }


                    //Code to create Quote Lines

                    List<SBQQ__QuoteLine__c> quoteLineItemiList = new List<SBQQ__QuoteLine__c>();
            
                    for(PSAUtils.returnProductAura rpa  : products) {    

                        SBQQ__QuoteLine__c quoteLineItem =new SBQQ__QuoteLine__c ();
                        
                        quoteLineItem.SBQQ__Product__c=rpa.product.Id;
                        quoteLineItem.SBQQ__Quote__c = quoteId;
                        quoteLineItem.SBQQ__Quantity__c = 1;
                        quoteLineItem.SBQQ__ListPrice__c = rpa.listprice;
                        //quoteLineItem.SBQQ__RegularPrice__c = 300;
                        //quoteLineItem.SBQQ__CustomerPrice__c = 312;
                        quoteLineItem.SBQQ__NetPrice__c = rpa.listprice;
                        quoteLineItem.SBQQ__PricebookEntryId__c = [SELECT Id FROM PricebookEntry WHERE Pricebook2Id =: opp.Pricebook2id AND Product2Id =: rpa.product.Id].Id; //'01u7F000004K48yQAC';

                        if(chargeTypeMap.containsKey(rpa.product.productcode))
                        {
                            quoteLineItem.SBQQ__ChargeType__c = chargeTypeMap.get(rpa.product.productcode).SBQQ__ChargeType__c;
                            quoteLineItem.SBQQ__BillingType__c = chargeTypeMap.get(rpa.product.productcode).SBQQ__BillingType__c;
                            quoteLineItem.SBQQ__BillingFrequency__c = chargeTypeMap.get(rpa.product.productcode).SBQQ__BillingFrequency__c;

                            quoteLineItem.SBQQ__SubscriptionPricing__c = chargeTypeMap.get(rpa.product.productcode).SBQQ__SubscriptionPricing__c;
                            //quoteLineItem.SBQQ__ProductSubscriptionType__c = chargeTypeMap.get(rpa.product.productcode).SBQQ__SubscriptionType__c;
                            quoteLineItem.SBQQ__DefaultSubscriptionTerm__c = chargeTypeMap.get(rpa.product.productcode).SBQQ__SubscriptionTerm__c;
                        }

                        quoteLineItemiList.add(quoteLineItem);              
                    }
                    if(!quoteLineItemiList.isEmpty())
                        insert quoteLineItemiList;

                }
            }  */
    }
    
    @AuraEnabled
    public static void productSelection(string productName, string accountId, string sessionId) 
    {
        //string code = 'Database.executeBatch(new PaymentProcessQueueable(\'' + productName + '\',\'' + accountId + '\',\'' + sessionId + '\'));';
        string code = 'System.enqueueJob(new PaymentProcessQueueable(\'' + productName + '\',\'' + accountId + '\',\'' + sessionId + '\'));';
       	string encodedCode = EncodingUtil.urlEncode(code, 'UTF-8');
        PSAUtils.makeCallout('GET', 'tooling/executeAnonymous/?anonymousBody=' + encodedCode, null);
    }

    @AuraEnabled
    public static void createAmendmentQuote(string contractId) 
    {
        //string code = 'Database.executeBatch(new PaymentProcessQueueable(\'' + productName + '\',\'' + accountId + '\',\'' + sessionId + '\'));';
        List<SBQQ__Quote__c> quoteList = [Select Id,SBQQ__Status__c From SBQQ__Quote__c where SBQQ__Type__c='Amendment' And SBQQ__Status__c='Draft' And SBQQ__MasterContract__c = :contractId And SystemModstamp > :Datetime.now().addMinutes(-60) Limit 1];
        if(quoteList.isEmpty()){
            string code = 'System.enqueueJob(new PaymentProcessQueueable(\'' + contractId + '\'));';
            string encodedCode = EncodingUtil.urlEncode(code, 'UTF-8');
            PSAUtils.makeCallout('GET', 'tooling/executeAnonymous/?anonymousBody=' + encodedCode, null);
        }
    }

    public static void createAmendmentQuoteInternal(String contractId){
        CPQ_AmenderAPI amender =new CPQ_AmenderAPI();
        CPQ_QuoteModel qm=new CPQ_QuoteModel ();
        qm = amender.load(contractId);
        SBQQ__Quote__c q = qm.record;
        q.Externally_Generated_Quote__c = true;
        update q;
        System.debug('Amendment Quote: ' + q.Id);
    }

    @AuraEnabled
    public static String getAmendmentQuote(String contractId){
        List<SBQQ__Quote__c> quoteList = [Select Id,SBQQ__Status__c From SBQQ__Quote__c where SBQQ__Type__c='Amendment' And SBQQ__Status__c='Draft' And SBQQ__MasterContract__c = :contractId And SystemModstamp > :Datetime.now().addMinutes(-10) Limit 1];

        String res = null;
        if(!quoteList.isEmpty()){
            res = quoteList[0].Id;
        }
        return res;
    }

    //Added for premium bundle
    @AuraEnabled
    public static String getPremiumBundleProduct(String accountId, String sessionId)
    {
        String result = null;
        list<PSAUtils.returnProductAura> reslist = new list<PSAUtils.returnProductAura>();
        list<Product2> bundleProduct = new list<Product2>();
        bundleProduct = [Select Id, Name, productcode From Product2 Where ProductCode='INS - PRE' And Isactive=true Limit 1];
        
        if(!bundleProduct.isEmpty()){
            
            String prodjson = '{"listprice": 0.00,"netprice": 0.00,"product":{"ProductCode":"' + bundleProduct[0].productcode + '","Id":"' + bundleProduct[0].Id + '","Name": "'+ bundleProduct[0].Name +'"}}';

            PSAUtils.returnProductAura prodStruct = (PSAUtils.returnProductAura) JSON.deserialize(prodjson, PSAUtils.returnProductAura.class);
            prodStruct.isBundle = true;
            prodStruct.configuredSKU = null;
            reslist.add(prodStruct);

            String productId = bundleProduct[0].Id;
            if(productId!=null){

                for(SBQQ__ProductOption__c pos : [Select Id,Name,SBQQ__OptionalSKU__c, SBQQ__ProductName__c,SBQQ__UnitPrice__c,SBQQ__ProductCode__c,SBQQ__Type__c From SBQQ__ProductOption__c Where SBQQ__ConfiguredSKU__c=:productId]){
                    PSAUtils.returnProductAura cons = new PSAUtils.returnProductAura();
                    cons.listprice = pos.SBQQ__UnitPrice__c;
                    cons.netprice = 0.00;
                    cons.isBundle = false;
                    cons.configuredSKU = productId;
                    cons.optionId = pos.Id;
                    cons.optionType = pos.SBQQ__Type__c;
                    Product2 p2 = new Product2();
                    p2.Id = pos.SBQQ__OptionalSKU__c;
                    p2.ProductCode = pos.SBQQ__ProductCode__c;
                    p2.Name = pos.SBQQ__ProductName__c;
                    cons.product = p2;
                    reslist.add(cons);
                }
            }
        
        }

        result = JSON.serialize(reslist);

        return result;
    }

   
    public static void createQuoteLinesInternal(list<PSAUtils.returnProductAura> products, string quoteId, string paymentFrequency)
    {
        system.debug('##### createQuoteLinesInternal products ' + JSON.serialize(products));
        Opportunity opp = [select Id, Pricebook2id from Opportunity where SBQQ__PrimaryQuote__c = :quoteId];
		set<string> productCodes = new set<string>();
        Map<String,Boolean> prodBundle = new Map<String,Boolean>();
        Map<String,Boolean> prodOptions = new Map<String,Boolean>();
        
        for (PSAUtils.returnProductAura rp: products){
             productCodes.add(rp.product.ProductCode);
        }

        List<SBQQ__QuoteLine__c> quoteLineBundleiList = new List<SBQQ__QuoteLine__c>();

        //get all the required twinning fields from Product2 object to map into Quote Lines fields
        List<Product2> productList = [SELECT ProductCode, SBQQ__ChargeType__c, SBQQ__BillingType__c, 
                                      SBQQ__BillingFrequency__c,SBQQ__SubscriptionTerm__c,
                                      SBQQ__SubscriptionPricing__c,SBQQ__SubscriptionType__c 
                                      FROM Product2 WHERE productcode in :productCodes];

                    
        //Build a map with received Products vs Twinning fields or additional fields from Product2 object
       	Map<String, Product2> chargeTypeMap=new Map<String, Product2>();

      	for (Product2 product : productList)
            chargeTypeMap.put(product.ProductCode, product);

		//Code to create Quote Lines
		List<SBQQ__QuoteLine__c> quoteLineItemiList = new List<SBQQ__QuoteLine__c>();
            
        for(PSAUtils.returnProductAura rpa  : products) 
        {    
			SBQQ__QuoteLine__c quoteLineItem =new SBQQ__QuoteLine__c ();
                        
            quoteLineItem.SBQQ__Product__c=rpa.product.Id;
            quoteLineItem.SBQQ__Quote__c = quoteId;
            quoteLineItem.SBQQ__Quantity__c = 1;
            quoteLineItem.SBQQ__ListPrice__c = rpa.listprice;
            
            Date sdt = Date.today();
            Date edt = Date.today().addYears(1).addDays(-1);
            quoteLineItem.SBQQ__StartDate__c = sdt;
            quoteLineItem.SBQQ__EndDate__c = edt;
            //quoteLineItem.SBQQ__CustomerPrice__c = 312;
            //quoteLineItem.SBQQ__NetPrice__c = rpa.netprice;
            quoteLineItem.SBQQ__PricebookEntryId__c = [SELECT Id FROM PricebookEntry WHERE Pricebook2Id =: opp.Pricebook2id AND Product2Id =: rpa.product.Id].Id; //'01u7F000004K48yQAC';

            if(chargeTypeMap.containsKey(rpa.product.productcode))
            {
               quoteLineItem.SBQQ__ChargeType__c = chargeTypeMap.get(rpa.product.productcode).SBQQ__ChargeType__c;
               quoteLineItem.SBQQ__BillingType__c = chargeTypeMap.get(rpa.product.productcode).SBQQ__BillingType__c;
               quoteLineItem.SBQQ__BillingFrequency__c = paymentFrequency;

               quoteLineItem.SBQQ__SubscriptionPricing__c = chargeTypeMap.get(rpa.product.productcode).SBQQ__SubscriptionPricing__c;
               //quoteLineItem.SBQQ__ProductSubscriptionType__c = chargeTypeMap.get(rpa.product.productcode).SBQQ__SubscriptionType__c;
              	quoteLineItem.SBQQ__DefaultSubscriptionTerm__c = chargeTypeMap.get(rpa.product.productcode).SBQQ__SubscriptionTerm__c;
                quoteLineItem.SBQQ__SubscriptionTerm__c = chargeTypeMap.get(rpa.product.productcode).SBQQ__SubscriptionTerm__c;
                quoteLineItem.SBQQ__SubscriptionType__c = 'Renewable';
                quoteLineItem.SBQQ__ProductSubscriptionType__c = 'Renewable';
            }

            quoteLineItemiList.add(quoteLineItem);

       }

       insert quoteLineItemiList;
    }

    public static void addPremiumInsuranceInternal(Date sDate, string quoteId, string paymentFrequency, Boolean parentonly)
    {
        system.debug('##### addPremiumInsuranceInternal start date ' + sDate);
        Opportunity opp = [select Id, Pricebook2id from Opportunity where SBQQ__PrimaryQuote__c = :quoteId];
		set<string> productCodes = new set<string>();
        Map<String,Boolean> prodBundle = new Map<String,Boolean>();
        Map<String,Boolean> prodOptions = new Map<String,Boolean>();

        String prodJSON = getPremiumBundleProduct(null, null);

        list<PSAUtils.returnProductAura> products = (list<PSAUtils.returnProductAura>) JSON.deserialize(prodJSON, list<PSAUtils.returnProductAura>.class);

        system.debug('##### addPremiumInsuranceInternal products ' + products);
        String parentQli = null;
        list<SBQQ__QuoteLine__c> qlis = new list<SBQQ__QuoteLine__c>();

        if(!parentonly){
            parentQli = getQuoteLinesPremiumParent(quoteId);
        }
        else{
            qlis = fetchQuoteLines(quoteId);
        }

        for (PSAUtils.returnProductAura rp: products){
             productCodes.add(rp.product.ProductCode);
             if(rp.isBundle)
                prodBundle.put(rp.product.ProductCode,rp.isBundle);
             else if(rp.optionId!=null)
                prodOptions.put(rp.product.ProductCode,true);
        }

        Date endDate = null;

        for(SBQQ__QuoteLine__c eqli: qlis){
            if(!productCodes.contains(eqli.SBQQ__ProductCode__c)){
                endDate = eqli.SBQQ__EndDate__c;
            }
        }

        List<SBQQ__QuoteLine__c> quoteLineBundleiList = new List<SBQQ__QuoteLine__c>();

        //get all the required twinning fields from Product2 object to map into Quote Lines fields
        List<Product2> productList = [SELECT ProductCode, SBQQ__ChargeType__c, SBQQ__BillingType__c, 
                                      SBQQ__BillingFrequency__c,SBQQ__SubscriptionTerm__c,
                                      SBQQ__SubscriptionPricing__c,SBQQ__SubscriptionType__c 
                                      FROM Product2 WHERE productcode in :productCodes];

                    
        //Build a map with received Products vs Twinning fields or additional fields from Product2 object
       	Map<String, Product2> chargeTypeMap=new Map<String, Product2>();

      	for (Product2 product : productList)
            chargeTypeMap.put(product.ProductCode, product);

		//Code to create Quote Lines
		List<SBQQ__QuoteLine__c> quoteLineItemiList = new List<SBQQ__QuoteLine__c>();
            
        for(PSAUtils.returnProductAura rpa  : products) 
        {    
			SBQQ__QuoteLine__c quoteLineItem =new SBQQ__QuoteLine__c ();
                        
            quoteLineItem.SBQQ__Product__c=rpa.product.Id;
            quoteLineItem.SBQQ__Quote__c = quoteId;
            quoteLineItem.SBQQ__Quantity__c = 1;
            quoteLineItem.SBQQ__ListPrice__c = rpa.listprice;
            quoteLineItem.SBQQ__StartDate__c = sDate;
            quoteLineItem.SBQQ__EndDate__c = endDate;
            quoteLineItem.SBQQ__Bundle__c = (prodBundle.get(rpa.product.ProductCode)!=null)?prodBundle.get(rpa.product.ProductCode):false;
            if(rpa.configuredSKU!=null){
                quoteLineItem.SBQQ__ProductOption__c = rpa.optionId;
                quoteLineItem.SBQQ__OptionType__c = rpa.optionType;
                quoteLineItem.SBQQ__RequiredBy__c = parentQli;
            }
            //quoteLineItem.SBQQ__RegularPrice__c = 300;
            //quoteLineItem.SBQQ__CustomerPrice__c = 312;
            //quoteLineItem.SBQQ__NetPrice__c = rpa.netprice;
            quoteLineItem.SBQQ__PricebookEntryId__c = [SELECT Id FROM PricebookEntry WHERE Pricebook2Id =: opp.Pricebook2id AND Product2Id =: rpa.product.Id].Id; //'01u7F000004K48yQAC';

            if(chargeTypeMap.containsKey(rpa.product.productcode))
            {
               quoteLineItem.SBQQ__ChargeType__c = chargeTypeMap.get(rpa.product.productcode).SBQQ__ChargeType__c;
               quoteLineItem.SBQQ__BillingType__c = chargeTypeMap.get(rpa.product.productcode).SBQQ__BillingType__c;
               quoteLineItem.SBQQ__BillingFrequency__c = paymentFrequency;

               quoteLineItem.SBQQ__SubscriptionPricing__c = chargeTypeMap.get(rpa.product.productcode).SBQQ__SubscriptionPricing__c;
               //quoteLineItem.SBQQ__ProductSubscriptionType__c = chargeTypeMap.get(rpa.product.productcode).SBQQ__SubscriptionType__c;
              	quoteLineItem.SBQQ__DefaultSubscriptionTerm__c = chargeTypeMap.get(rpa.product.productcode).SBQQ__SubscriptionTerm__c;
                quoteLineItem.SBQQ__SubscriptionTerm__c = chargeTypeMap.get(rpa.product.productcode).SBQQ__SubscriptionTerm__c;
                quoteLineItem.SBQQ__SubscriptionType__c = 'Renewable';
                quoteLineItem.SBQQ__ProductSubscriptionType__c = 'Renewable';
            }

            if(quoteLineItem.SBQQ__Bundle__c){
                quoteLineBundleiList.add(quoteLineItem);
            }
            else{
                quoteLineItemiList.add(quoteLineItem);
            }
       }

       if(parentonly){
            insert quoteLineBundleiList;
       }
       else{
            insert quoteLineItemiList;
       }
    }
    
    @AuraEnabled
    public static void createQuoteLines(string productsJSON, string quoteId, string paymentFrequency) 
    {
        system.debug('##### productsJSON ' + productsJSON);
        //string code = 'System.enqueueJob(new PaymentProcessQueueable(\'' + productsJSON + '\',\'' + quoteId + '\',\'' + paymentFrequency + '\',false));';
        string code = 'Database.executeBatch(new PaymentProcessQueueable(\'' + productsJSON + '\',\'' + quoteId + '\',\'' + paymentFrequency + '\',false));';
       	string encodedCode = EncodingUtil.urlEncode(code, 'UTF-8');
        PSAUtils.makeCallout('GET', 'tooling/executeAnonymous/?anonymousBody=' + encodedCode, null);
    }

    @AuraEnabled
    public static void addPremiumInsurance(String startDate, string quoteId, String paymentFrequency, Boolean parentOnly)
    {
        System.debug('##### paymentFrequency ' + paymentFrequency);

        Set<String> productCodes = new Set<String>();

        String prodJSON = getPremiumBundleProduct(null, null);

        list<PSAUtils.returnProductAura> products = (list<PSAUtils.returnProductAura>) JSON.deserialize(prodJSON, list<PSAUtils.returnProductAura>.class);

        for (PSAUtils.returnProductAura rp: products){
            if(rp.isBundle)
                productCodes.add(rp.product.ProductCode);
        }

        Integer res = getPremiumQliOptionStatus(quoteId, JSON.serialize(productCodes));

        if(res <= 0){

            String code = 'Database.executeBatch(new PaymentProcessQueueable(\'' + startDate + '\',\'' + quoteId + '\',\'' + paymentFrequency + '\',\'' + String.valueOf(parentOnly) + '\',\'2\'));';

            System.debug('##### code ' + code);
            
            string encodedCode = EncodingUtil.urlEncode(code, 'UTF-8');
            PSAUtils.makeCallout('GET', 'tooling/executeAnonymous/?anonymousBody=' + encodedCode, null);
        }
    }

    @AuraEnabled
    public static String createPremiumQLIOptions(String startDate, String quoteId, string parentId)
    {
        system.debug('##### parentId ' + parentId);
        //string code = 'System.enqueueJob(new PaymentProcessQueueable(\'' + productsJSON + '\',\'' + quoteId + '\',\'' + paymentFrequency + '\',false));';
        Set<String> productCodes = new Set<String>();

        String prodJSON = getPremiumBundleProduct(null, null);

        list<PSAUtils.returnProductAura> products = (list<PSAUtils.returnProductAura>) JSON.deserialize(prodJSON, list<PSAUtils.returnProductAura>.class);

        for (PSAUtils.returnProductAura rp: products){
            if(!rp.isBundle)
                productCodes.add(rp.product.ProductCode);
        }

        Integer res = getPremiumQliOptionStatus(quoteId, JSON.serialize(productCodes));

        if(res <= 0){

            String code = 'Database.executeBatch(new PaymentProcessQueueable(\'' + startDate + '\',\'' + quoteId + '\',\'' + parentId + '\',\'false\',\'3\'));';
            String encodedCode = EncodingUtil.urlEncode(code, 'UTF-8');
            PSAUtils.makeCallout('GET', 'tooling/executeAnonymous/?anonymousBody=' + encodedCode, null);
        }

        return JSON.serialize(productCodes);

    }

    @AuraEnabled
    public static list<SBQQ__QuoteLine__c> fetchQuoteLines(String quoteId)
    {
        System.debug('##### fetchQuoteLines ' + quoteId);

        list<SBQQ__QuoteLine__c> qliRecList = new list<SBQQ__QuoteLine__c>();

        qliRecList = [Select Id, SBQQ__ProductName__c, SBQQ__Number__c, SBQQ__ProductCode__c, SBQQ__BillingFrequency__c, blng__BillableUnitPrice__c, SBQQ__StartDate__c, SBQQ__EndDate__c From SBQQ__QuoteLine__c Where SBQQ__Quote__c = :quoteId order by SBQQ__Number__c desc];

        return qliRecList;
    }

    @AuraEnabled
    public static SBQQ__Quote__c fetchQuoteDetails(String quoteId)
    {
        System.debug('##### fetchQuoteLines ' + quoteId);

        list<SBQQ__Quote__c> qliList = new list<SBQQ__Quote__c>();

        qliList = [Select Id, SBQQ__Type__c, SBQQ__Primary__c, SBQQ__Account__c, SBQQ__Status__c, SBQQ__StartDate__c, SBQQ__EndDate__c,SBQ_Subtotal_Calculated__c, SBQ_Total_GST__c From SBQQ__Quote__c Where Id = :quoteId Limit 1];

        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q = (!qliList.isEmpty())?qliList[0]:null;

        return q;
    }

    @AuraEnabled
    public static Integer getPremiumQliOptionStatus(string quoteId, string optionsStr)
    {
        System.debug('##### optionsStr ' + optionsStr);
        Set<String> prodCodes = new Set<String>();
        if(!String.isBlank(optionsStr)){
            prodCodes = (Set<String>) JSON.deserialize(optionsStr, Set<String>.class);
        }

        list<SBQQ__QuoteLine__c> qliRecList = new list<SBQQ__QuoteLine__c>();

        System.debug('##### Query params ' + quoteId);
        System.debug('##### Query params ' + prodCodes);

        qliRecList = [Select Id From SBQQ__QuoteLine__c Where SBQQ__Quote__c = :quoteId And SBQQ__ProductCode__c In :prodCodes];

        return qliRecList.size();
    }

    public static void updatePremiumQlisInternal(String quoteId, String parentQliId)
    {
        System.debug('##### updatePremiumQlisInternal parentId ' + parentQliId);

		set<string> productCodes = new set<string>();
        Map<String,Boolean> prodBundle = new Map<String,Boolean>();
        Map<String,Boolean> prodOptions = new Map<String,Boolean>();

        String prodJSON = getPremiumBundleProduct(null, null);

        SBQQ__QuoteLine__c qliRec = [Select Id, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__BillingFrequency__c, SBQQ__Quote__r.SBQQ__PriceBook__c From SBQQ__QuoteLine__c Where Id = :parentQliId Limit 1];

        list<PSAUtils.returnProductAura> products = (list<PSAUtils.returnProductAura>) JSON.deserialize(prodJSON, list<PSAUtils.returnProductAura>.class);

        system.debug('##### updatePremiumQlisInternal products ' + products);
        String parentQli = parentQliId;

        for (PSAUtils.returnProductAura rp: products){
            if(!rp.isBundle)
                productCodes.add(rp.product.ProductCode);
        }

        List<Product2> productList = [SELECT ProductCode, SBQQ__ChargeType__c, SBQQ__BillingType__c, 
                                      SBQQ__BillingFrequency__c,SBQQ__SubscriptionTerm__c,
                                      SBQQ__SubscriptionPricing__c,SBQQ__SubscriptionType__c 
                                      FROM Product2 WHERE productcode in :productCodes];

                    
        //Build a map with received Products vs Twinning fields or additional fields from Product2 object
       	Map<String, Product2> chargeTypeMap=new Map<String, Product2>();

      	for (Product2 product : productList)
            chargeTypeMap.put(product.ProductCode, product);

		//Code to create Quote Lines
		List<SBQQ__QuoteLine__c> quoteLineItemiList = new List<SBQQ__QuoteLine__c>();
            
        for(PSAUtils.returnProductAura rpa  : products) 
        {
            if(!rpa.isBundle){
                SBQQ__QuoteLine__c quoteLineItem =new SBQQ__QuoteLine__c ();
                            
                quoteLineItem.SBQQ__Product__c=rpa.product.Id;
                quoteLineItem.SBQQ__Quote__c = quoteId;
                quoteLineItem.SBQQ__Quantity__c = 1;
                quoteLineItem.SBQQ__ListPrice__c = rpa.listprice;
                quoteLineItem.SBQQ__Bundle__c = false;
                quoteLineItem.SBQQ__ProductOption__c = rpa.optionId;
                quoteLineItem.SBQQ__OptionType__c = rpa.optionType;
                quoteLineItem.SBQQ__RequiredBy__c = parentQli;
                quoteLineItem.SBQQ__StartDate__c = qliRec.SBQQ__StartDate__c;
                quoteLineItem.SBQQ__EndDate__c = qliRec.SBQQ__EndDate__c;
                //quoteLineItem.SBQQ__RegularPrice__c = 300;
                //quoteLineItem.SBQQ__CustomerPrice__c = 312;
                //quoteLineItem.SBQQ__NetPrice__c = rpa.netprice;
                quoteLineItem.SBQQ__PricebookEntryId__c = [SELECT Id FROM PricebookEntry WHERE Pricebook2Id =: qliRec.SBQQ__Quote__r.SBQQ__PriceBook__c AND Product2Id =: rpa.product.Id].Id; //'01u7F000004K48yQAC';

                if(chargeTypeMap.containsKey(rpa.product.productcode))
                {
                quoteLineItem.SBQQ__ChargeType__c = chargeTypeMap.get(rpa.product.productcode).SBQQ__ChargeType__c;
                quoteLineItem.SBQQ__BillingType__c = chargeTypeMap.get(rpa.product.productcode).SBQQ__BillingType__c;
                quoteLineItem.SBQQ__BillingFrequency__c = qliRec.SBQQ__BillingFrequency__c;

                quoteLineItem.SBQQ__SubscriptionPricing__c = chargeTypeMap.get(rpa.product.productcode).SBQQ__SubscriptionPricing__c;
                //quoteLineItem.SBQQ__ProductSubscriptionType__c = chargeTypeMap.get(rpa.product.productcode).SBQQ__SubscriptionType__c;
                    quoteLineItem.SBQQ__DefaultSubscriptionTerm__c = chargeTypeMap.get(rpa.product.productcode).SBQQ__SubscriptionTerm__c;
                    quoteLineItem.SBQQ__SubscriptionTerm__c = chargeTypeMap.get(rpa.product.productcode).SBQQ__SubscriptionTerm__c;
                    quoteLineItem.SBQQ__SubscriptionType__c = 'Renewable';
                    quoteLineItem.SBQQ__ProductSubscriptionType__c = 'Renewable';
                }

                quoteLineItemiList.add(quoteLineItem);
            }
       }


       System.debug('##### updatePremiumQlisInternal quoteLineItemiList: ' + quoteLineItemiList);
            
       insert quoteLineItemiList;

        /* List<SBQQ__QuoteLine__c> quoteLineList =[Select Id,SBQQ__RequiredBy__c From SBQQ__QuoteLine__c Where SBQQ__Quote__c=:quoteId And SBQQ__ProductCode__c IN :productCodes];

        for(SBQQ__QuoteLine__c qli: quoteLineList){
            qli.SBQQ__RequiredBy__c = parentQli;
        }

        update quoteLineList; */

    }

    @AuraEnabled
    public static String getQuoteLinesPremiumParent(string quoteId) 
    {
        system.debug('##### getQuoteLinesCompleteionFlag Method:- ' + quoteId);
        List<SBQQ__QuoteLine__c> quoteLineList =[Select Id from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteId And SBQQ__ProductCode__c='INS - PRE'] ;
        if(!quoteLineList.isEmpty())
            return quoteLineList[0].Id;
        else
            return null;
    }
    
    @AuraEnabled
    public static boolean getQuoteLinesCompleteionFlag(string quoteId) 
    {
        system.debug('##### getQuoteLinesCompleteionFlag Method:- ' + quoteId);
        List<SBQQ__QuoteLine__c> quoteLineList =[Select Id from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteId] ;
        if(!quoteLineList.isEmpty())
            return true;       
        else
            return false;
    }
    
    @AuraEnabled
    public static String getQuoteDetailsById(string quoteId) 
    {
        system.debug('##### getQuoteDetailsById Method:- ' + quoteId);
        List<SBQQ__QuoteLine__c> quoteLineList =[Select Id, SBQQ__ProductName__c,SBQQ__ProductCode__c,SBQQ__Quantity__c,SBQQ__BillingFrequency__c, SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__Bundle__c,SBQQ__RequiredBy__c From SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteId] ;
        if(!quoteLineList.isEmpty())
            return JSON.serialize(quoteLineList);
        else
            return null;
    }
    
    @AuraEnabled
    public static string getQuoteId(string accountId, string sessionId) 
    {
         List<Opportunity> oppList =[Select SBQQ__PrimaryQuote__c, SBQQ__Ordered__c from Opportunity 
                                    where AccountId=:accountId 
                                   and Sign_Up_Session_Id__c = :sessionId];
        if(!oppList.isEmpty())
            return oppList[0].SBQQ__PrimaryQuote__c;       
        else
            return null;
    }
    
    public static void createOrderInternal(string quoteId)
    {
        //Code to update the status of quote to accepted
        List<SBQQ__Quote__c> quoteList = [Select SBQQ__Status__c From SBQQ__Quote__c where Id=: quoteId];
        if(quoteList.size() > 0 && !quoteList.isEmpty())
        {
            System.debug('Came');
            SBQQ__Quote__c quote = quoteList[0];
            quote.SBQQ__Status__c = 'Accepted';
            update quote;
        }

       /*//code to trigger contract from order
       List<Order> orderList = [Select Id, SBQQ__Contracted__c, blng__BillNow__c, Status From Order where SBQQ__Quote__r.Id=: quoteId and Status='Activated'];
       if(!orderList.isEmpty()  && orderList.size() > 0)
       {
           Order updateOrder = orderList[0];
           updateOrder.SBQQ__Contracted__c = true;
           update updateOrder;        
       }  */         
    }
 
    @AuraEnabled
    public static void createOrder(string quoteId)
    {
         string code = 'System.enqueueJob(new PaymentProcessQueueable(\'' + quoteId + '\'));';
       	 string encodedCode = EncodingUtil.urlEncode(code, 'UTF-8');
         PSAUtils.makeCallout('GET', 'tooling/executeAnonymous/?anonymousBody=' + encodedCode, null);  
    }

    @AuraEnabled
    public static string getOrderId(string quoteId) 
    {
       //code to trigger contract from order
       	List<Order> orderList = [Select Id, SBQQ__Contracted__c, blng__BillNow__c, Status From Order where SBQQ__Quote__r.Id=: quoteId and Status='Activated'];
       	if (Test.isRunningTest() && testOrder != null) orderList.add(testOrder);
        if(!orderList.isEmpty())
       	{
           Order updateOrder = orderList[0];
           /*updateOrder.SBQQ__Contracted__c = true;
           update updateOrder;       
            
           return updateOrder.Id;*/
            
          	string body = '{"SBQQ__Contracted__c":true}';
         	PSAUtils.makeCallout('PATCH', 'sobjects/Order/' + updateOrder.Id, body);
            return updateOrder.Id;
       	} 
        else
            return null;
        
 
        
        
        /*System.debug('quote:- ' + quoteId);
        List<Order> orderList = [Select Id, SBQQ__Contracted__c, blng__BillNow__c, Status From Order where SBQQ__Quote__r.Id=: quoteId and Status='Activated'];  
        if(!orderList.isEmpty())
			return orderList[0].Id;
        else
        	return null;*/
    }

    @AuraEnabled
    public static string getInvoiceId(string orderId, boolean optOutforRenewal, boolean isStudentPackage, string sessionId) {

         //code to generate invoice from order and check if contract has been generated
         try
         { 
            List<Contract> contractList = [Select AccountId,SBQQ__Order__c, Status,Auto_Renew__c From Contract where SBQQ__Order__c=: orderId ];
            if( contractList.size() > 0)
            {
               if (!isStudentPackage)
               {
                   Order updateOrderforInvoice  = [Select Id, SBQQ__Contracted__c, blng__BillNow__c, Status From Order where Id=: orderId];            
                   /*updateOrderforInvoice.blng__BillNow__c = true;
                   update updateOrderforInvoice;*/
                    
                    string body = '{"blng__BillNow__c":true}';
                    PSAUtils.makeCallout('PATCH', 'sobjects/Order/' + updateOrderforInvoice.Id, body);
       
                   List<blng__Invoice__c> invoiceList = [select id, blng__InvoiceStatus__c, blng__PaymentStatus__c from blng__Invoice__c where blng__Order__c=: orderId ];
                   if(invoiceList.size() > 0)
                   {
                       if (invoiceList[0].blng__InvoiceStatus__c == 'Draft' && (Test.isRunningTest() || invoiceList[0].blng__PaymentStatus__c == 'Partially Paid'  || invoiceList[0].blng__PaymentStatus__c == 'Unpaid'))
                       { 
                           blng__Invoice__c updateInvoice =  invoiceList[0];          
                           /*updateInvoice.blng__InvoiceStatus__c='Posted';
                           updateInvoice.blng__Notes__c = 'Invoice has been posted  by membership external user';
                           update updateInvoice;*/
                           
                            body = '{"blng__InvoiceStatus__c":"Posted","blng__Notes__c":"Invoice has been posted  by membership external user"}';
                            PSAUtils.makeCallout('PATCH', 'sobjects/blng__Invoice__c/' + updateInvoice.Id, body);
                       
                            //Activate the contract and update  the contract for auto renewal (opt out yes or no based on user input)
                            Contract cont =  contractList[0];
                            cont.Status = 'Activated';
                            cont.Auto_Renew__c = optOutforRenewal;
                            update cont;                        
               
                           return updateInvoice.Id;
                       }
                   }
               }
               else
               {
                    //Activate the contract and update  the contract for auto renewal (opt out yes or no based on user input)
                    Contract cont =  contractList[0];
                    cont.Status = 'Activated';
                    cont.Auto_Renew__c = !optOutforRenewal;
                    update cont;

                	Account acc = [select Id from Account where Id = :contractList[0].AccountId];
                	acc.Signed_Up__c = true;
                	update acc;
                
                	Opportunity opp =	[Select Id from Opportunity where AccountId=:acc.Id and Sign_Up_Session_Id__c = :sessionId]; 
                	opp.Is_Abandoned__c = false;
                	update opp; 
                   
                   return contractList[0].Id;
               }
            }
           
            return null;

         }
         catch(exception e) {
            return e.getmessage();        
        }         

    }

    
     @AuraEnabled
     public static List<String> getPicklistvalues(String objectName, String field_apiname,Boolean nullRequired){
         List<String> optionlist = new List<String>();       
         Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
         Map<String, Schema.SObjectField> field_map = gd.get(objectName.toLowerCase()).getDescribe().fields.getMap();        
         List<Schema.PicklistEntry> picklistValues = field_map.get(field_apiname).getDescribe().getPickListValues();       
         if(nullRequired == true){
             optionlist.add('--None--');
         }       
         for (Schema.PicklistEntry pv : picklistValues) {
             optionlist.add(pv.getValue());
         }
         return optionlist;
     }
    
    //Ezidebit record details
    @AuraEnabled
    public static List<ChargentBase__Gateway__c> fetchGateways() {
        return PSAUtils.fetchGateways();
    }    
    
     //Billing Payment Gateway > pass the chargent Ezidebit Gateway id (which is chargent base Gateway object record)
    @AuraEnabled
    public static List<blng__PaymentGateway__c> fetchBillingPaymentGateway(Id gatewayId) {
    	return PSAUtils.fetchBillingPaymentGateway(gatewayId);
    } 
    /*public class returnProductAura
    {
        @AuraEnabled public product2 product;
        @AuraEnabled public decimal actualprice;
        @AuraEnabled public decimal listprice;
        @AuraEnabled public decimal netprice;  //after tax
    }
    
    public class PaymentResponse {
        @AuraEnabled public Boolean isSuccess { get; set; }
        @AuraEnabled public String message { get; set; }
    }*/

    public class RequestMembershipData
    {       
        public String email{get;set;}
        public String password{get;set;}
        public String title{get;set;}
        public String firstname{get;set;}
        public String lastname{get;set;}
        public String gender{get;set;}
        public String dobdate{get;set;}
        public String primaryEmail{get;set;}
        public String phone{get;set;}        

        public String address1{get;set;}
        public String address2{get;set;}        
        public String city{get;set;}
        public String state{get;set;}
        public String postalCode{get;set;}
        public String country{get;set;}

        public String role{get;set;}
        public Boolean sameAsAcountEmail{get;set;}
        public String employment{get;set;}
        public String yrofqualification{get;set;}
        public String monthofqualification{get;set;}
        public String yrOfRegistration{get;set;}
        public String AHPRA{get;set;}
        public Boolean oversearegistration{get;set;}
        public String hoursworkedperweek{get;set;}
        public Boolean parentalLeave{get;set;}
        public String returnToWorkDate{get;set;}
        public String yrofGraduation{get;set;}
        public String monthofGraduation{get;set;}
        public String university{get;set;}
        public String studentnumber{get;set;}
        public String studentUniversityEmail{get;set;}
        
    }
}