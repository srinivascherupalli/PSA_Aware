public class CPQ_AmenderAPI
{

    public CPQ_QuoteModel load(String contractId) {
        String quoteJSON = SBQQ.ServiceRouter.load('SBQQ.ContractManipulationAPI.ContractAmender', contractId, null);
        return (CPQ_QuoteModel) JSON.deserialize(quoteJSON, CPQ_QuoteModel.class);
    }

/*    
    public class QuoteModel {
        public SBQQ__Quote__c record;
        //public QuoteLineModel[] lineItems;
        //public QuoteLineGroupModel[] lineItemGroups;
        public Integer nextKey;
        public Boolean applyAdditionalDiscountLast;
        public Boolean applyPartnerDiscountFirst;
        public Boolean channelDiscountsOffList;
        public Decimal customerTotal;
        public Decimal netTotal;
        public Decimal netNonSegmentTotal;
    } 
*/


/*
    public static void example(List<blng__Invoiceline__c> invline) 
    {
        /**
         * Note: this doesn’t perform a calculatation. Reference the calculate API to see how to calculate a quote.
         */
        /*
        //the Id of the quote
        String quoteId = 'a0Wf100000J1vk1';
        
        //the Id of the product to add to the quote
        String productId = '01tj0000003P1SN';
        
        //the Id of the pricebook for the quote and product being added
        String pricebookId = '01sj0000003THhKAAW';
        
        //the currency code
        String currencyCode = 'USD';
        
        //the JSON formatted String representing the quote model to add a product to
        String quoteModel = SBQQ.ServiceRouter.read('SBQQ.QuoteAPI.QuoteReader', quoteId);
        
        //the JSON formatted String representing the product to be added to the quote
        String productModel = SBQQ.ServiceRouter.load('SBQQ.ProductAPI.ProductLoader', productId, '{"pricebookId" : "' + pricebookId + '", "currencyCode" : "' + currencyCode + '"}');
        
        //the JSON formatted String representing the quote with the product added to it
        String updatedQuoteModel = SBQQ.ServiceRouter.load('SBQQ.QuoteAPI.QuoteProductAdder', null, '{"quote" : ' + quoteModel + ', "products" : [' + productModel + '], "ignoreCalculate" : true}');
        
        //the JSON formatted String represeting the saved quote
        String savedQuoteModel = SBQQ.ServiceRouter.save('SBQQ.QuoteAPI.QuoteSaver', updatedQuoteModel);
    }
    */        
}