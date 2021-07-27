/**
 * @author Juliver Anoos <juliver@alphasys.com.au>
 * @since October 10 , 2019
 */
public without sharing  class AsPaymentOptionController {

    /**
     * This method will Inintiat the Pricebook list and Learning Package Details.
     * @param  AccountId: Account from the Enrollement.
     * @param  EnrollmentId: The Enrollment Id.
     * @return return Return and Object Map.
     */ 
    @AuraEnabled
    public static map<String, Object>  InitPaymentPage( Id AccountId , Id EnrollmentId ){

        Id userId = UserInfo.getUserId();
            //Boolean isMember = AS_HelperClass.isUserMember(userId);
            //System.debug('ismember ' + isMember);
        boolean isMember = false;
        if(userId != null){
            User currentUser = [SELECT Id, Profile.Name FROM User WHERE Id =: userId];
            if(currentUser.Profile.Name == 'Member Login User' ){
                isMember = true;
            }
        }
         
        system.debug('isMember: '+ isMember);
        
        Map< String , Object > returnMap  = new Map< String , Object >();

        // Query Enrollment Record by the Enrollment Id.
        List< Enrolment_Form__c > enrollmentList = [SELECT
                                                        Id,
                                                        Enrolment_Status__c,
                                                        Funded_position__c,
                                                        AS_Account__c,
                                                        AS_Account__r.Member__c, 
                                                        AS_Learning_Package__c,
                                                        AS_Learning_Package__r.AS_product__c,
                                                        AS_Learning_Package__r.Name,
                                                        AS_Learning_Package__r.AS_Funding_eligible__c,
                                                        Opportunity__c,
                                                        Opportunity__r.Amount,
                                                        Opportunity__r.Pricebook2Id,
                                                        Opportunity__r.Pricebook2.Name
                                                    FROM
                                                        Enrolment_Form__c
                                                    WHERE
                                                        Id =:EnrollmentId                
                                                    ];

        // Check the enrollmentList that allow to procced if the list is not empty or 0
        if( enrollmentList.size() != 0 ){

            Enrolment_Form__c enrolment = enrollmentList[0];
            Id productId =  enrolment.AS_Learning_Package__r.AS_product__c;
            String learningPackageName = enrolment.AS_Learning_Package__r.Name;
            Id prodIdFOrVcode = enrolment.AS_Learning_Package__r.AS_product__c;
            //iver - get enrolment fields to be used in the controller
            String enrolmentStatus = enrolment.Enrolment_Status__c;
            Boolean fundedPosition = enrolment.Funded_position__c;
            Boolean fundEligible = enrolment.AS_Learning_Package__r.AS_Funding_eligible__c;
            Id oppId = enrolment.Opportunity__c;
            Double oppAmount = enrolment.Opportunity__r.Amount;
            Id pBook2Id = enrolment.Opportunity__r.Pricebook2Id;

            String pBook2IdName = '';
            if (enrolment.Opportunity__r.Pricebook2.Name == 'PSA Member') {
                pBook2IdName = 'One-off payment';
            } else if (enrolment.Opportunity__r.Pricebook2.Name == 'Monthly Membership') {
                pBook2IdName = 'Monthly';
            } else if (enrolment.Opportunity__r.Pricebook2.Name == 'Quarterly Membership') {
                pBook2IdName = 'Quarterly';
            } else if (enrolment.Opportunity__r.Pricebook2.Name == '6 Month Pricebook') {
                pBook2IdName = '6x monthly installments';
            } else if (enrolment.Opportunity__r.Pricebook2.Name == 'PSA Non-member') {
                pBook2IdName = 'One-off payment';
            } 
            
            system.debug ('OppInfos ===> ');
            system.debug ('amount : '+oppAmount);
            system.debug ('pBook2Id: '+pBook2Id);
            system.debug ('pBook2IdName: '+pBook2IdName);
            
            //get Oppamount, Pricebookid, pbookName if opp exist
            returnMap.put( 'oppInfoAmount' , oppAmount  );
            returnMap.put( 'oppInfopBook2Id' , pBook2Id  );
            returnMap.put( 'oppInfopBook2IdName' , pBook2IdName  );

            //Query PriceEntry to the the Pricebook Details and the Unit price
            list< PricebookEntry > priceBookEntryList = [
                                                        SELECT
                                                            Id,
                                                            Pricebook2Id,
                                                            Pricebook2.Name,
                                                            Product2Id,
                                                            UnitPrice,
                                                            ProductCode 
                                                        FROM
                                                            PricebookEntry
                                                        WHERE
                                                            Product2Id =:productId
                                                        //AND Pricebook2.Name = 'PSA Member'
                                                    ];
            //get productid for vcode
            returnMap.put( 'prodIdFOrVcode' , prodIdFOrVcode  );
            // Put learningPackageName to  the map to dispaly into the client side.
            returnMap.put( 'learningPackageName' , learningPackageName  );
            //iver
            returnMap.put( 'enrolmentStatus' , enrolmentStatus  );
            returnMap.put( 'fundedPosition' , fundedPosition  );
            returnMap.put( 'fundEligible' , fundEligible  );
            returnMap.put( 'oppId' , oppId  );
            returnMap.put( 'oppAmount' , oppAmount  );

            Map< String , String  > isNotMemberMapPriceBook = new Map< String , String >();
            isNotMemberMapPriceBook.put( 'PSA Non-member' ,'One-off payment');
            isNotMemberMapPriceBook.put('6 Month Pricebook','6x monthly installments');

            Map< String , String  > MemberMapPriceBook = new Map< String , String >();
            MemberMapPriceBook.put('PSA Member' ,'One-off payment');
            MemberMapPriceBook.put('Monthly Membership','Monthly');
            MemberMapPriceBook.put('Quarterly Membership','Quarterly');
            MemberMapPriceBook.put('6 Month Pricebook','6x monthly installments');

            List< PriceBookWrapper > priceBookRecordList = new List< PriceBookWrapper >();
            
            for( PricebookEntry pbe : priceBookEntryList  ){
                PriceBookWrapper pbw = new PriceBookWrapper(); 
                if( isMember ){
                    if ( pbe.Pricebook2.Name == 'PSA Member'){
                        pbw.priceBookId = pbe.Pricebook2Id;
                        pbw.unitPrice = pbe.UnitPrice;
                        pbw.priceBookName = 'One-off payment';
                        pbw.isOnceOff = true;
                        pbw.membership = pbe.Pricebook2.Name;
                        priceBookRecordList.add(pbw);
                    } else if ( pbe.Pricebook2.Name == 'Monthly Membership'){
                         pbw.priceBookId = pbe.Pricebook2Id;
                        pbw.unitPrice = pbe.UnitPrice;
                        pbw.priceBookName = 'Monthly';
                        pbw.isOnceOff = false;
                        pbw.membership = pbe.Pricebook2.Name;
                        priceBookRecordList.add(pbw);
                    } else if ( pbe.Pricebook2.Name == 'Quarterly Membership'){
                        pbw.priceBookId = pbe.Pricebook2Id;
                        pbw.unitPrice = pbe.UnitPrice;
                        pbw.priceBookName = 'Quarterly';
                        pbw.isOnceOff = false;
                        pbw.membership = pbe.Pricebook2.Name;
                        priceBookRecordList.add(pbw);
                    } else if ( pbe.Pricebook2.Name == '6 Month Pricebook'){
                        pbw.priceBookId = pbe.Pricebook2Id;
                        pbw.unitPrice = pbe.UnitPrice;
                        pbw.priceBookName = '6x monthly installments';
                        pbw.isOnceOff = false;
                        pbw.membership = pbe.Pricebook2.Name;
                        priceBookRecordList.add(pbw);
                    }
                     system.debug('pricebookList isMember'+priceBookRecordList);
                } else  if( !isMember ) {
                     if ( pbe.Pricebook2.Name == 'PSA Non-member'){
                        pbw.priceBookId = pbe.Pricebook2Id;
                        pbw.unitPrice = pbe.UnitPrice;
                        pbw.priceBookName = 'One-off payment';
                        pbw.isOnceOff = true;
                        pbw.membership = pbe.Pricebook2.Name;
                        priceBookRecordList.add(pbw);
                    } else if ( pbe.Pricebook2.Name == '6 Month Pricebook'){
                        pbw.priceBookId = pbe.Pricebook2Id;
                        pbw.unitPrice = pbe.UnitPrice;
                        pbw.priceBookName = '6x monthly installments';
                        pbw.isOnceOff = false;
                        pbw.membership = pbe.Pricebook2.Name;
                        priceBookRecordList.add(pbw);
                    }
                    system.debug('pricebookList isNonMember'+priceBookRecordList);
                }
                

            }
            system.debug('pricebookList '+priceBookRecordList);
            returnMap.put( 'priceBookRecordList' , priceBookRecordList );
        }
        return returnMap; 
    }
     /**
    * callback handler for cancel button (delete enrolment record)
    *
    * @param enrolId enrolment id to be deleted
    */
    @AuraEnabled
    public static String deleteEnrolment( Id enrolId ) {
        String message = '';
        List<Enrolment_Form__c> deleteEnrol = new List<Enrolment_Form__c>();
        if( enrolId != null ) {
            List<Enrolment_Form__c> getEnrolInfo = [SELECT Id FROM Enrolment_Form__c 
                                                    WHERE Id =: enrolId AND Enrolment_Status__c = 'Draft'];
            if ( !getEnrolInfo.isEmpty() ) {
                deleteEnrol.addAll( getEnrolInfo );
            }

        }
        if ( !deleteEnrol.isEmpty() ) {
            delete deleteEnrol;
            message = 'Enrolment sucessfully deleted!';
        } else {
            message = 'No record to be deleted!';
        }
        return message;
    }

    /**
    * @details  This method will be invoked by doInit js function if fundedPosition, fundEligible are true && oppId is null: to create Opportunity
    * @author Juliver A | 10/10/2019 
    * @param EnrollmentId 
    * @param acctId 
    * @return void 
    **/
    @AuraEnabled
    public static Map<String, Object> createOppOnEnrolment(Id EnrollmentId, Id acctId, Id priceBookId, Double unitPrice){

        // Id userId = UserInfo.getUserId();
        // //Boolean isMember = AS_HelperClass.isUserMember(userId);
        // //System.debug('ismember ' + isMember);
        // boolean isMember = false;
        // if(userId != null){
        //     User currentUser = [SELECT Id, Profile.Name FROM User WHERE Id =: userId];
        //     if(currentUser.Profile.Name == 'Member Login User' ){
        //         isMember = true;
        //     }
        // }
        
        // system.debug('isMember: '+ isMember);
        system.debug('Enrolment Id '+EnrollmentId);
        system.debug('Acct Id '+acctId);
        system.debug('priceBookId '+priceBookId);
        system.debug('unitPrice '+unitPrice);
        
        Map<String, Object> retOppId = new Map<String, Object>();
        List< Enrolment_Form__c > enrollmentList = [SELECT
                                                        Id, Name,
                                                        Enrolment_Status__c,
                                                        Funded_position__c,
                                                        AS_Account__c,
                                                        AS_Account__r.Member__c, 
                                                        AS_Account__r.Name, 
                                                        AS_Learning_Package__c,
                                                        AS_Learning_Package__r.Id,
                                                        AS_Learning_Package__r.AS_product__c,
                                                        AS_Learning_Package__r.AS_product__r.Name,
                                                        AS_Learning_Package__r.AS_product__r.Id,
                                                        AS_Learning_Package__r.Name,
                                                        AS_Learning_Package__r.AS_Funding_eligible__c,
                                                        Opportunity__c,
                                                        Opportunity__r.Amount
                                                    FROM
                                                        Enrolment_Form__c
                                                    WHERE
                                                        Id =:EnrollmentId   
                                                    AND 
                                                        AS_Account__c =: acctId   
                                                    LIMIT 1       
                                                    ];
        List<Opportunity> newOppL = new List<Opportunity>();
        PriceBookWrapper pbWrapper = new PriceBookWrapper();
        Id productId = enrollmentList[0].AS_Learning_Package__r.AS_product__c;
        Boolean fundedPos = enrollmentList[0].Funded_position__c;
        Boolean fundedElig = enrollmentList[0].AS_Learning_Package__r.AS_Funding_eligible__c;
        
        Id educationId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Education').getRecordTypeId();
       
        Opportunity newOpp = new Opportunity();
        for (Enrolment_Form__c getEnrolmentInfo : enrollmentList ) {
            
            newOpp.Name = 'Enrolment - ' + getEnrolmentInfo.AS_Account__r.Name + ' - ' + getEnrolmentInfo.Name;
            newOpp.StageName = 'Prospecting';
            newOpp.AS_Add_Products__c = true;
            newOpp.AccountId = acctId;
            newOpp.AS_Product__c = getEnrolmentInfo.AS_Learning_Package__r.AS_product__c;
            newOpp.AS_Create_Subscription__c = true;

            newOpp.AS_Product_Price__c = unitPrice;
            newOpp.Pricebook2Id = priceBookId;
        
            newOpp.RecordTypeId = educationId;
            newOpp.Generate_Order__c = true;
            newOpp.AS_Enrolment__c = getEnrolmentInfo.Id;
            newOpp.CloseDate = Date.today();//to be confirmed
            //newOppL.add(newOpp);
        }
        insert newOpp;
        system.debug('Created Opp For enrollment? ' + newOpp);

        
        List<Enrolment_Form__c> newUpdateEnrolList = new List<Enrolment_Form__c>();

        Enrolment_Form__c newUpdateEnrol = new Enrolment_Form__c();
        newUpdateEnrol.Id = EnrollmentId;
        newUpdateEnrol.Opportunity__c = newOpp.Id;
        
        if(fundedPos || fundedElig){
            newUpdateEnrol.Enrolment_Status__c = 'Pending';
        } else {
            newUpdateEnrol.Enrolment_Status__c = 'Pending Payment';
        }
        //newUpdateEnrol.AS_Email__c = 'juliver@alphays.com';
        // newUpdateEnrol.AS_Learning_Package__c = ;
        newUpdateEnrolList.add(newUpdateEnrol);
        
        try {
            update newUpdateEnrolList;
            System.debug('Enrolment updated ' + newUpdateEnrolList);
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }

        retOppId.put('fundedEligible',enrollmentList[0].AS_Learning_Package__r.AS_Funding_eligible__c);
        retOppId.put('fundedPosition',enrollmentList[0].Funded_position__c);
        retOppId.put('OpportunityId',newOpp.Id);
        return retOppId;
    }

    /**
    * @details  This method will be invoked by js function: saveNEmail
    * @author   Juliver A | 10/10/2019 
    * @param EnrollmentId 
    * @param acctId 
    * @return string 
    **/
    @AuraEnabled
    public static string updateEnrollment(Id EnrollmentId, Id acctId){

        string msg = '';

        if ( EnrollmentId != null ){

            List< Enrolment_Form__c > enrollmentList = [SELECT
                                                            Id,
                                                            Enrolment_Status__c,
                                                            Funded_position__c,
                                                            AS_Account__c,
                                                            AS_Account__r.Member__c, 
                                                            AS_Account__r.Name, 
                                                            AS_Learning_Package__c,
                                                            AS_Learning_Package__r.AS_product__c,
                                                            AS_Learning_Package__r.AS_product__r.Name,
                                                            AS_Learning_Package__r.Name,
                                                            AS_Learning_Package__r.AS_Funding_eligible__c,
                                                            Opportunity__c,
                                                            Opportunity__r.Amount
                                                        FROM
                                                            Enrolment_Form__c
                                                        WHERE
                                                            Id =:EnrollmentId   
                                                        AND 
                                                            AS_Account__c =: acctId          
                                                        ];
            List< Enrolment_Form__c > updEnrolmentLst = new List< Enrolment_Form__c >();
            for ( Enrolment_Form__c updateEnrolment : enrollmentList) {

                    updateEnrolment.Id = EnrollmentId;
                    updateEnrolment.AS_Saved_Enrolment_Form__c = true;
                    updateEnrolment.AS_Enrolment_Stage__c = 'Page 13: Payment options';
                    updateEnrolment.AS_Enrollment_Last_Modify_Date__c = Date.today();
                    updateEnrolment.AS_Send_enrollment_link__c = true;
                    updEnrolmentLst.add( updateEnrolment );
            }
            update updEnrolmentLst;

            if( updEnrolmentLst.size() > 0 ) {
                msg = 'Enrolment updated!';
            } else {
                msg = 'Update failed.';
            }
        }
        return msg;
    }
    
    /**
    * @details This will update enrolment.status to Pending if enrolment is funded
    * @author Juliver Anoos | 10/17/2019 
    * @param EnrollmentId 
    * @param acctId 
    * @return string 
    **/
    @AuraEnabled
    public static string updateEnrollmentToPending(Id EnrollmentId, Id acctId) {
            string msg = '';

        if ( EnrollmentId != null ){

            List< Enrolment_Form__c > enrollmentList = [SELECT
                                                            Id,
                                                            Enrolment_Status__c
                                                        FROM
                                                            Enrolment_Form__c
                                                        WHERE
                                                            Id =:EnrollmentId   
                                                        AND 
                                                            AS_Account__c =: acctId          
                                                        ];
            List< Enrolment_Form__c > updEnrolmentLst = new List< Enrolment_Form__c >();
            for ( Enrolment_Form__c updateEnrolment : enrollmentList) {

                    updateEnrolment.Id = EnrollmentId;
                    updateEnrolment.Enrolment_Status__c = 'Pending';
                    updEnrolmentLst.add( updateEnrolment );
            }
            update updEnrolmentLst;

            system.debug('Updated Enrolment Pending Payment ' + updEnrolmentLst);

            if( updEnrolmentLst.size() > 0 ) {
                msg = 'Enrolment updated!';
            } else {
                msg = 'Update failed.';
            }
        }
        system.debug('return msg ' + msg);
        return msg;
    }

    /**
    * @details This will update enrolment.status to Pending Payment if opportunity is created via continue with payment
    * @author Juliver Anoos | 10/17/2019 
    * @param EnrollmentId 
    * @param acctId 
    * @return string 
    **/
    @AuraEnabled
    public static string updateEnrollmentToPendingPayment(Id EnrollmentId, Id acctId) {
            string msg = '';

        if ( EnrollmentId != null ){

            List< Enrolment_Form__c > enrollmentList = [SELECT
                                                            Id,
                                                            Enrolment_Status__c
                                                        FROM
                                                            Enrolment_Form__c
                                                        WHERE
                                                            Id =:EnrollmentId   
                                                        AND 
                                                            AS_Account__c =: acctId          
                                                        ];
            List< Enrolment_Form__c > updEnrolmentLst = new List< Enrolment_Form__c >();
            for ( Enrolment_Form__c updateEnrolment : enrollmentList) {

                    updateEnrolment.Id = EnrollmentId;
                    updateEnrolment.Enrolment_Status__c = 'Pending Payment';
                    updEnrolmentLst.add( updateEnrolment );
            }
            update updEnrolmentLst;

            system.debug('Updated Enrolment Pending Payment ' + updEnrolmentLst);

            if( updEnrolmentLst.size() > 0 ) {
                msg = 'Enrolment updated!';
            } else {
                msg = 'Update failed.';
            }
        }
        system.debug('return msg ' + msg);
        return msg;
    }

    @AuraEnabled
    public static string updateEnrollmentToPendingAndCreateOpp(Id EnrollmentId, Id acctId) {
        string msg = '';

        Id userId = UserInfo.getUserId();
            //Boolean isMember = AS_HelperClass.isUserMember(userId);
            //System.debug('ismember ' + isMember);
        boolean isMember = false;
        if(userId != null){
            User currentUser = [SELECT Id, Profile.Name FROM User WHERE Id =: userId];
            if(currentUser.Profile.Name == 'Member Login User' ){
                isMember = true;
            }
        }
         
        system.debug('isMember: '+ isMember);
        
        List< Enrolment_Form__c > enrollmentList = [SELECT
                                                        Id,
                                                        AS_Account__r.Name,
                                                        AS_Learning_Package__r.Name,
                                                        Enrolment_Status__c,
                                                        Opportunity__c,
                                                        AS_Learning_Package__c,
                                                        AS_Learning_Package__r.AS_product__c
                                                    FROM
                                                        Enrolment_Form__c
                                                    WHERE
                                                        Id =:EnrollmentId   
                                                    AND 
                                                        AS_Account__c =: acctId          
                                                    ];

        Id productId = enrollmentList[0].AS_Learning_Package__r.AS_product__c;

        List<PriceBookEntry> priceBookEntries = [SELECT
                                                        Id,
                                                        Pricebook2Id,
                                                        Pricebook2.Name,
                                                        Product2Id,
                                                        UnitPrice,
                                                        ProductCode 
                                                    FROM
                                                        PricebookEntry
                                                    WHERE
                                                        Product2Id =:productId
                                                    //AND Pricebook2.Name = 'PSA Member'
                                                    ];
            //for psa member pricebook
            Id PSAMemberBDId;
            Double psamemPrice;

            //for Psa Non member pricebook
            Double psaNonmemPrice;
            Id PSANonMemberBDId;

            //filter pricebook for specific member
            for(PriceBookEntry prBookname : priceBookEntries ) {
                if(prBookname.Pricebook2.Name == 'PSA Member') {
                    PSAMemberBDId = prBookname.Pricebook2Id;
                    psamemPrice = prBookname.UnitPrice;
                } else if(prBookname.Pricebook2.Name == 'PSA Non-member') {
                    PSANonMemberBDId = prBookname.Pricebook2Id;
                    psaNonmemPrice = prBookname.UnitPrice;
                }
            }
            system.debug('Price books PSAMember Id' + PSAMemberBDId+'\nPrice '+psamemPrice);
            system.debug('Price books PSANoneMember Id' + PSANonMemberBDId+'\nPrice '+psaNonmemPrice);
        
        Id educationId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Education').getRecordTypeId();
        List< Enrolment_Form__c > updEnrolmentLst = new List< Enrolment_Form__c >();
        Opportunity newOpp = new Opportunity();
        for ( Enrolment_Form__c getEnrolmentInf : enrollmentList) {
                newOpp.Name = 'Enrolment - ' + getEnrolmentInf.AS_Account__r.Name + ' - ' + getEnrolmentInf.AS_Learning_Package__r.Name;
                newOpp.StageName = 'Prospecting';
                newOpp.AS_Add_Products__c = true;
                newOpp.AccountId = acctId;
                newOpp.AS_Product__c = getEnrolmentInf.AS_Learning_Package__r.AS_product__c;
                newOpp.AS_Create_Subscription__c = true;

                //pricebook to be mapped if psa member or non member
                if(  isMember ) {
                    //pricebook and unitprice for psa member
                    newOpp.AS_Product_Price__c = psamemPrice;
                    newOpp.Pricebook2Id = PSAMemberBDId;
                } else {
                    //pricebook and unitprice for non member
                    newOpp.AS_Product_Price__c = psaNonmemPrice;
                    newOpp.Pricebook2Id = PSANonMemberBDId;
                }
            
                newOpp.RecordTypeId = educationId;
                newOpp.Generate_Order__c = true;
                newOpp.AS_Enrolment__c = getEnrolmentInf.Id;
                newOpp.CloseDate = Date.today();
        }
        insert newOpp;

        system.debug('Created opp: ' + newOpp);

        Enrolment_Form__c newUpdateEnrol = new Enrolment_Form__c();
        newUpdateEnrol.Id = EnrollmentId;
        newUpdateEnrol.Opportunity__c = newOpp.Id;
        newUpdateEnrol.Enrolment_Status__c = 'Pending';
        
        //newUpdateEnrol.AS_Email__c = 'juliver@alphays.com';
        // newUpdateEnrol.AS_Learning_Package__c = ;
        updEnrolmentLst.add(newUpdateEnrol);

        system.debug('Updated Enrolment Pending ' + updEnrolmentLst);

        if( updEnrolmentLst.size() > 0 ) {
            update updEnrolmentLst;
            msg = 'Updated Successfully';
        } else {
            msg = 'Update failed';
        }
    
    system.debug('return msg ' + msg);
    return msg;
    }

    @AuraEnabled 
    public static string validateVoucherCode (String vCode, Id prodId) {
        
        String isvCode;
        if (vCode == null || vCode == '') {
            isvCode = 'Cannot validate an empty field';

        } else {
            

            // List <  Product2 > cou = [SELECT Id, Name,
            //                                 AS_Include_in_Coupon__c,
            //                                 AS_Include_in_Coupon__r.Id,
            //                                 AS_Include_in_Coupon__r.AS_Code__c,
            //                                 AS_Include_in_Coupon__r.AS_Discount_Amount__c,
            //                          		AS_Include_in_Coupon__r.AS_Status__c,
            //                          		AS_Include_in_Coupon__r.AS_Generic_Coupon__c,
            //                          		AS_Include_in_Coupon__r.Multiple_Use__c
            // 							FROM Product2
            //                          	//WHERE AS_Include_in_Coupon__r.AS_Code__c =: vCode
            // 						    //AND AS_Include_in_Coupon__r.AS_Status__c = 'Active'
            //                             //AND Id =:prodId
            //                             WHERE Id =:prodId
            //                             LIMIT 1 ];
            List < AS_Coupon__c > cou = [SELECT Id, Name,
                                            AS_Discount_Amount__c,
                                            AS_Percentage_Discount__c,
                                            AS_Code__c,
                                            RecordTypeId,
                                     		AS_Product__c,
                                     		AS_Status__c ,
                                     		AS_Generic_Coupon__c,
                                     		Multiple_Use__c
            							FROM AS_Coupon__c
                                     	WHERE AS_Code__c =: vCode
                                        //AND AS_Status__c = 'Active'
                                        ORDER BY createdDate LIMIT 1 ];
            system.debug('Coupon: '+ cou);

            if (cou.size() > 0) {
                
                if (cou[0].AS_Status__c == 'Active') {
                    try{
                        isvCode = 'Voucher is available and ready to use';
                    } catch (Exception err) {
                        system.debug('Error: '+err);
                    }
                } else if (cou[0].AS_Status__c == 'Expired') {
                    
                    isvCode = 'Voucher code has expired and no longer valid';
                } else {
                    
                    isvCode = 'Voucher code has already been used';
                }
            } else {
                isvCode = 'Invalid voucher code for this product';
            }   
        }
        system.debug('isVcode: '+isvCode);
        return isvCode;
    }

    @AuraEnabled 
    public static Map<String, Object> createOppLineItems(Id EnrollmentId, Id acctId, Id priceBookId, Double unitPrice, String vCode){

        // Id userId = UserInfo.getUserId();
        // //Boolean isMember = AS_HelperClass.isUserMember(userId);
        // //System.debug('ismember ' + isMember);
        // boolean isMember = false;
        // if(userId != null){
        //     User currentUser = [SELECT Id, Profile.Name FROM User WHERE Id =: userId];
        //     if(currentUser.Profile.Name == 'Member Login User' ){
        //         isMember = true;
        //     }
        // }
        
        // system.debug('isMember: '+ isMember);
        system.debug('Enrolment Id '+EnrollmentId);
        system.debug('Acct Id '+acctId);
        system.debug('priceBookId '+priceBookId);
        system.debug('unitPrice '+unitPrice);
        
        Map<String, Object> retOppId = new Map<String, Object>();
        List< Enrolment_Form__c > enrollmentList = [SELECT
                                                        Id, Name,
                                                        Enrolment_Status__c,
                                                        Funded_position__c,
                                                        AS_Account__c,
                                                        AS_Account__r.Member__c, 
                                                        AS_Account__r.Name, 
                                                        AS_Learning_Package__c,
                                                        AS_Learning_Package__r.Id,
                                                        AS_Learning_Package__r.AS_product__c,
                                                        AS_Learning_Package__r.AS_product__r.Name,
                                                        AS_Learning_Package__r.AS_product__r.Id,
                                                        AS_Learning_Package__r.Name,
                                                        AS_Learning_Package__r.AS_Funding_eligible__c,
                                                        Opportunity__c,
                                                        Opportunity__r.Amount
                                                    FROM
                                                        Enrolment_Form__c
                                                    WHERE
                                                        Id =:EnrollmentId   
                                                    AND 
                                                        AS_Account__c =: acctId   
                                                    LIMIT 1       
                                                    ];
        List<Opportunity> newOppL = new List<Opportunity>();
        PriceBookWrapper pbWrapper = new PriceBookWrapper();
        Id productId = enrollmentList[0].AS_Learning_Package__r.AS_product__c;
        Boolean fundedPos = enrollmentList[0].Funded_position__c;
        Boolean fundedElig = enrollmentList[0].AS_Learning_Package__r.AS_Funding_eligible__c;

        List < PricebookEntry > priEntry = [Select Id, Name from PricebookEntry where Product2Id =: productId AND Pricebook2Id =: priceBookId LIMIT 1];
        Id priEntryId = priEntry[0].Id;
        /**
        * @details Get coupon 
        * @author Juliver Anoos | 10/17/2019 
        **/
        Id amountRecordTypeId = Schema.SObjectType.AS_Coupon__c.getRecordTypeInfosByName().get('Amount').getRecordTypeId();
        Id percentRecordTypeId = Schema.SObjectType.AS_Coupon__c.getRecordTypeInfosByName().get('Percentage').getRecordTypeId();
        //get coupon 
        List < AS_Coupon__c > cou = [SELECT Id, Name,
                                            AS_Discount_Amount__c,
                                            AS_Percentage_Discount__c,
                                            AS_Code__c,
                                            RecordTypeId,
                                     		AS_Product__c,
                                     		AS_Status__c ,
                                     		AS_Generic_Coupon__c,
                                     		AS_Opportunity__c,
                                     		Multiple_Use__c
            							FROM AS_Coupon__c
                                     	WHERE AS_Code__c =: vCode
                                        AND AS_Status__c = 'Active'
                                        ORDER BY createdDate LIMIT 1 ];
        system.debug('Coupon check==> '+cou);

        Id educationId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Education').getRecordTypeId();
        //List<Opportunity> newOpp = new List<Opportunity>();
        Opportunity newOpp = new Opportunity();
        for (Enrolment_Form__c getEnrolmentInfo : enrollmentList ) {
            
            newOpp.Name = 'Enrolment - ' + getEnrolmentInfo.AS_Account__r.Name + ' - ' + getEnrolmentInfo.Name;
            newOpp.StageName = 'Prospecting';
            newOpp.AS_Add_Products__c = true;
            newOpp.AccountId = acctId;
            newOpp.Coupon__c = cou[0].Id;
            newOpp.AS_Product__c = getEnrolmentInfo.AS_Learning_Package__r.AS_product__c;
            newOpp.AS_Create_Subscription__c = true;

            newOpp.AS_Product_Price__c = unitPrice;
            newOpp.Pricebook2Id = priceBookId;
        
            newOpp.RecordTypeId = educationId;
            newOpp.Generate_Order__c = true;
            newOpp.AS_Enrolment__c = getEnrolmentInfo.Id;
            newOpp.CloseDate = Date.today();//to be confirmed
            //newOppL.add(newOpp);
        }
        insert newOpp;
        system.debug('Created Opp For enrollment? ' + newOpp);

        
        List < Opportunity > finalOpp = [Select Id, Name, Amount, Coupon__c from Opportunity where Id =: newOpp.Id limit 1];
        system.debug('get amount of created opp ' + finalOpp);
        Double oPPAmount = finalOpp[0].Amount;
        Double finalPrice;
        if (cou.size() > 0) {

            for ( AS_Coupon__c getCoup : cou ) {

                if ( getCoup.RecordTypeId ==  amountRecordTypeId ) {

                    if ( oPPAmount - Math.abs(getCoup.AS_Discount_Amount__c) >= 0) {
                            finalPrice = Math.abs(getCoup.AS_Discount_Amount__c);
                            system.debug('1st condition'+finalPrice);
                        } else {
                            Double difRes = oPPAmount - Math.abs(getCoup.AS_Discount_Amount__c);
                            finalPrice = Math.abs(getCoup.AS_Discount_Amount__c) - Math.abs(difRes);
                             system.debug('2nd condition'+finalPrice);
                        }

                } else if ( getCoup.RecordTypeId ==  percentRecordTypeId )  {
                    Double tempPrice = oPPAmount * (getCoup.AS_Percentage_Discount__c / 100);
                    if ( oPPAmount - tempPrice >= 0) {
                            finalPrice = tempPrice;
                        } else {
                            Double difRes = oPPAmount - tempPrice;
                            finalPrice = tempPrice - Math.abs(difRes);
                        }
                }
            }

            //create oppLineItem for coupon
            
            OpportunityLineItem indiOppLineItemCoupon = new OpportunityLineItem();
            indiOppLineItemCoupon.OpportunityId = finalOpp[0].Id;
            indiOppLineItemCoupon.PricebookEntryId = priEntryId;
            indiOppLineItemCoupon.UnitPrice = -1 * finalPrice;
            indiOppLineItemCoupon.Description = vCode;
            indiOppLineItemCoupon.Quantity = 1;

            System.debug('indiOppLineItemCoupon : ' + indiOppLineItemCoupon);
            insert indiOppLineItemCoupon;

            //update coupon status
            List< AS_Coupon__c > coupUpdate = new List< AS_Coupon__c >();

            for ( AS_Coupon__c getCoupon : cou ) {
                if ( getCoupon.Multiple_Use__c == true ) {
                    getCoupon.AS_Status__c = 'Active';
                } else {
                    getCoupon.AS_Status__c = 'Used';
                }
                getCoupon.AS_Product__c = productId;
                getCoupon.AS_Opportunity__c = finalOpp[0].Id;
                coupUpdate.add(getCoupon);
            }
            update coupUpdate;
            system.debug('coup Updated: '+coupUpdate);
            //end coupon          
        }
        //get oppamount
        List < Opportunity > getUpdatedOpp = [Select Id, StageName, Name, Amount, Coupon__c from Opportunity where Id =: newOpp.Id limit 1];
        system.debug('query opp: '+getUpdatedOpp);
        //update enrolment
        List<Enrolment_Form__c> newUpdateEnrolList = new List<Enrolment_Form__c>();

        Enrolment_Form__c newUpdateEnrol = new Enrolment_Form__c();
        newUpdateEnrol.Id = EnrollmentId;
        newUpdateEnrol.Opportunity__c = newOpp.Id;
        
        if(fundedPos || fundedElig){
            newUpdateEnrol.Enrolment_Status__c = 'Pending';
        } else if ( getUpdatedOpp[0].Amount <= 0 ) {
            newUpdateEnrol.Enrolment_Status__c = 'Pending';
        } else {
            newUpdateEnrol.Enrolment_Status__c = 'Pending Payment';
        }
        //newUpdateEnrol.AS_Email__c = 'juliver@alphays.com';
        // newUpdateEnrol.AS_Learning_Package__c = ;
        newUpdateEnrolList.add(newUpdateEnrol);
        
        try {
            update newUpdateEnrolList;
            System.debug('Enrolment updated ' + newUpdateEnrolList);
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        //this will invoke opp trigger on update
        List<Opportunity> upOppList = new List<Opportunity>();
        for (Opportunity upOpp : getUpdatedOpp) {
            upOpp.Id = getUpdatedOpp[0].Id;

            if ( upOpp.Amount <= 0 ) {
                upOpp.StageName = 'Closed Won';
            } else {
                upOpp.StageName = 'Prospecting';
            }
            upOppList.add(upOpp);
        }
        update upOppList;//end
        system.debug('closed won?'+upOppList);

        System.debug('FinalOpp: ' + getUpdatedOpp);
        retOppId.put('fundedEligible',enrollmentList[0].AS_Learning_Package__r.AS_Funding_eligible__c);
        retOppId.put('fundedPosition',enrollmentList[0].Funded_position__c);
        retOppId.put('OpportunityId',newOpp.Id);
        retOppId.put('OpportunityAmount',getUpdatedOpp[0].Amount);
        return retOppId;
    }


    public class PriceBookWrapper {
        @AuraEnabled public Id priceBookId {get;set;}
        @AuraEnabled public String priceBookName {get;set;}
        @AuraEnabled public String membership {get;set;}
        @AuraEnabled public Double unitPrice {get;set;}
        @AuraEnabled public Boolean isOnceOff {get;set;}
    }

}