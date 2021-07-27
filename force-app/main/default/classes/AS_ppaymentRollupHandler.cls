/*
* Author: Danryl T. Carpio 
* Created Date: March 2020
* Description: Roll up payment object amount and update Opportunity paid amount field
* and should not trigger when Opportunity is Online Shop
*/
public class AS_ppaymentRollupHandler {

    public static void processTrigger( List<ASPHPP__Payment__c>  payment ) {

        Set<Id> opp = new Set<Id>();
        Set<Id> sub = new Set<Id>();
        Set<Id> ord = new Set<Id>();

        for ( ASPHPP__Payment__c pay : payment ) { 
            
            if ( pay.ASPHPP__Process_Payment__c != null && pay.ASPHPP__Process_Payment__c != 'Web' ) {

                // opportunity
                if ( pay.ASPHPP__Opportunity__c != null ) {
                    opp.add( pay.ASPHPP__Opportunity__c );
                }
                
                // subscription
                if ( pay.ASPHPP__PSubscription__c != null ) {
                    sub.add( pay.ASPHPP__PSubscription__c );
                }
                
                // order
                if ( pay.AS_Order__c != null ) {
                    ord.add( pay.AS_Order__c );
                }

            }
            
        }

        if ( opp.size() > 0 ) {
            // process rollup opportunity
            rollupOpportunity( opp );
        }
        
        if ( sub.size() > 0 ) {

            // process subscription
            rollupSubscription( sub );
        }
        
        if ( ord.size() > 0 ) {

            // process order
            rollupOrder( ord );
        }

    }

    private static void rollupOpportunity( Set<Id> oppId ) {

        List<Opportunity> oppUpdate = new List<Opportunity>();

        // check if there is ids need to be process
        if ( oppId.size() > 0 ) {

            Id onlineShopRType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Online_Shop').getRecordTypeId();
        
            // sum of the payments per opportunity
        //    list<AggregateResult> oppSum = [ Select ASPHPP__Opportunity__c, 
        //                                             SUM(ASPHPP__Amount__c) 
        //                                                 FROM   
        //                                             ASPHPP__Payment__c 
        //                                                 WHERE  
        //                                             ASPHPP__Opportunity__c IN : oppId  
        //                                                 AND 
        //                                             ASPHPP__Opportunity__r.RecordTypeId !=: onlineShopRType
        //                                                 AND
        //                                             ASPHPP__Payment_Status__c = 'Success'
        //                                                 GROUP BY ASPHPP__Opportunity__c ];
            
             list<AggregateResult> oppSum = [ Select ASPHPP__Opportunity__c,  
                                                        SUM(ASPHPP__Amount__c) 
                                                            FROM 
                                                        ASPHPP__Payment__c 
                                                            WHERE 
                                                        ASPHPP__Opportunity__c IN : oppId 
                                                            AND
                                                        ASPHPP__Payment_Status__c = 'Success'
                                                            GROUP BY ASPHPP__Opportunity__c ];

            // iteration
            for( AggregateResult resOpp : oppSum ) {
 
                // check sum field not 
                if( ((Decimal)resOpp.get('expr0')) != null && ((Decimal)resOpp.get('expr0')) > 0 ) {
                    
                    // construct opportunity update
                    Opportunity oppNew = new Opportunity();
                    oppNew.Id = ((Id)resOpp.get('ASPHPP__Opportunity__c'));
                    oppNew.AS_Payment_Amount__c = ((Decimal)resOpp.get('expr0'));
                    oppUpdate.add( oppNew );

                }

            }
            
        }

        // check size before dml
        if ( oppUpdate.size() > 0 ) {
            update oppUpdate;
        }

    }

    private static void rollupSubscription( Set<Id> sub ) {

        // container of the subscription to be roll up
        List<ASPHPP__Subscription__c> subUpdate = new List<ASPHPP__Subscription__c>();

        List<AggregateResult> resSubs = [ Select ASPHPP__PSubscription__c, 
                                                    SUM(ASPHPP__Amount__c) 
                                                        FROM 
                                                    ASPHPP__Payment__c 
                                                        WHERE 
                                                    ASPHPP__PSubscription__c IN : sub 
                                                        AND 
                                                    ASPHPP__Payment_Status__c = 'Success' 
                                                        GROUP BY ASPHPP__PSubscription__c ];

        // iteration
        for( AggregateResult resSub : resSubs ) {

            if( ((Decimal)resSub.get('expr0')) != null && ((Decimal)resSub.get('expr0')) > 0 ) {

                // construct subscription 
                ASPHPP__Subscription__c subNew = new ASPHPP__Subscription__c();
                subNew.Id = ((Id)resSub.get('ASPHPP__PSubscription__c'));
                subNew.AS_Payment_Amount__c = ((Decimal)resSub.get('expr0'));
                subUpdate.add( subNew );
                
            }

        }
 
        // check size before dml
        if ( subUpdate.size() > 0 ) {
            update subUpdate;
        }

    }

    private static void rollupOrder( Set<Id> setOrder ) {

        // container of the order to be roll up
        List<Order> listOrderUpdate = new List<Order>();

        List<AggregateResult> resOrdrs = [ Select AS_Order__c, 
                                                    SUM(ASPHPP__Amount__c) 
                                                        FROM 
                                                    ASPHPP__Payment__c 
                                                        WHERE 
                                                    AS_Order__c IN : setOrder 
                                                        AND  
                                                    ASPHPP__Payment_Status__c = 'Success'
                                                        GROUP BY AS_Order__c ];
        
        // iteration
        for( AggregateResult resOrder : resOrdrs ) {

            // construct order
            if( ((Decimal)resOrder.get('expr0')) != null && ((Decimal)resOrder.get('expr0')) > 0 ) {
                Order orderNew = new Order();
                orderNew.Id = ((Id)resOrder.get('AS_Order__c'));
                orderNew.AS_Payment_Amount__c = ((Decimal)resOrder.get('expr0'));
                listOrderUpdate.add( orderNew );
            }
        } 

        // check size before dml
        if ( listOrderUpdate.size() > 0 ) {
            update listOrderUpdate;
        }

    }

}