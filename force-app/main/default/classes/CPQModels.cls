public with sharing class CPQModels {
    
    public class ProductModel {
        public Product2 record;
        public Id upgradedAssetId;
        public String currencySymbol;
        public String currencyCode;
        public String[] featureCategories;
        public OptionModel[] options;
        public FeatureModel[] features;
        public ConfigurationModel configuration;
        public ConfigAttributeModel[] configurationAttributes;
        public ConfigAttributeModel[] inheritedConfigurationAttributes;
        public ConstraintModel[] constraints; 
    }

    public class QuoteModel {
        public SBQQ__Quote__c record;
        public QuoteLineModel[] lineItems;
        public QuoteLineGroupModel[] lineItemGroups;
        public Integer nextKey;
        public Boolean applyAdditionalDiscountLast;
        public Boolean applyPartnerDiscountFirst;
        public Boolean channelDiscountsOffList;
        public Decimal customerTotal;
        public Decimal netTotal;
        public Decimal netNonSegmentTotal;
    }

    public class QuoteLineModel {
        public SBQQ__QuoteLine__c record;
        public Boolean amountDiscountProrated;
        public Integer parentGroupKey;
        public Integer parentItemKey;
        public Integer key;
        public Boolean upliftable;
        public String configurationType;
        public String configurationEvent;
        public Boolean reconfigurationDisabled;
        public Boolean descriptionLocked;
        public Boolean productQuantityEditable;
        public Decimal productQuantityScale;
        public String dimensionType;
        public Boolean productHasDimensions;
        public Decimal targetCustomerAmount;
        public Decimal targetCustomerTotal;
    }

    public class FeatureModel { 
        public SBQQ__ProductFeature__c record; 
        public String instructionsText; 
        public Boolean containsUpgrades; 
    }

    public class QuoteLineGroupModel {
        public SBQQ__QuoteLineGroup__c record;
        public Decimal netNonSegmentTotal;
        public Integer key;
    }

    public class OptionModel { 
        public SBQQ__ProductOption__c record; 
        public Map<String,String> externalConfigurationData; 
        public Boolean configurable; 
        public Boolean configurationRequired; 
        public Boolean quantityEditable; 
        public Boolean priceEditable; 
        public Decimal productQuantityScale; 
        public Boolean priorOptionExists; 
        public Set<Id> dependentIds; 
        public Map<String,Set<Id>> controllingGroups; 
        public Map<String,Set<Id>> exclusionGroups; 
        public String reconfigureDimensionWarning; 
        public Boolean hasDimension; 
        public Boolean isUpgrade; 
        public String dynamicOptionKey; 
    }

    public class ConfigAttributeModel { 
        public String name; 
        public String targetFieldName; 
        public Decimal displayOrder; 
        public String colmnOrder;
        public Boolean required;
        public Id featureId;
        public String position;
        public Boolean appliedImmediately;
        public Boolean applyToProductOptions;
        public Boolean autoSelect;
        public String[] shownValues;
        public String[] hiddenValues;
        public Boolean hidden;
        public String noSuchFieldName;
        public Id myId;
    }

    public class ConfigurationModel { 
        public Id configuredProductId; 
        public Id optionId; 
        public SBQQ__ProductOption__c optionData; // Editable data about the option in question, such as quantity or discount 
        public SBQQ__ProductOption__c configurationData; 
        public SBQQ__ProductOption__c inheritedConfigurationData; 
        public ConfigurationModel[] optionConfigurations; 
        public Boolean configured; 
        public Boolean changedByProductActions; 
        public Boolean isDynamicOption; 
        public Boolean isUpgrade; 
        public Set<Id> disabledOptionIds; 
        public Set<Id> hiddenOptionIds; 
        public Decimal listPrice; 
        public Boolean priceEditable; 
        public String[] validationMessages; 
        public String dynamicOptionKey; 
    }

    public class ConstraintModel { 
        public SBQQ__OptionConstraint__c record; 
        public Boolean priorOptionExists; 
    }

    public class QuoteProposalModel {
        public String name;
        public Id quoteId;
        public Id templateId;
        public String language;
        public String outputFormat;
        public String paperSize;
    }

    public class QuoteTermModel {
        public String value;
        public String type;
        public Id standardTermId;
        public Id quoteId;
        public Boolean locked;
        public String label;
        public Id id;
    }

}