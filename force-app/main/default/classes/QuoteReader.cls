public with sharing class QuoteReader {
    
    public CPQModels.QuoteModel read(String quoteId) {
        String quoteJSON = SBQQ.ServiceRouter.read('SBQQ.QuoteAPI.QuoteReader', quoteId);
        return (CPQModels.QuoteModel) JSON.deserialize(quoteJSON, CPQModels.QuoteModel.class);
    }
}