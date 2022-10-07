/**
 * @description Helper Class for AssociatedProductsTriggerHanlder
 * @see ..AssociatedProductsTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | August 17, 2022       | DEPP-2665              | Created File                 |
 */


public without sharing class AssociatedProductsTriggerHelper {

    public static final String CCE_CATALOG = 'CCE Catalog';
    public static final String CCE_CATEGORY_QLS = 'QUTeX Learning Solutions'; 
    public static final String CCE_CATEGORY_CB = 'Corporate Bundle';

    public static final List<String> PROD2_CATEGORIES = new List<String>{
        CCE_CATEGORY_CB,
        CCE_CATEGORY_QLS
    };

    private static final Id PR_CORPBUNDLE_RECTYPEID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName()
        .get('Corporate_Bundle')
        .getRecordTypeId();

    public static final Id PR_STANDOFFERARRANGE_RECTYPEID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName()
        .get('Standing_Offer_Arrangement')
        .getRecordTypeId(); 


    /**
     * @description method to include Product to Store
     * @param prod2New - Map of Product2.Trigger.new
     */
    public static void includeProductToStore( Map<Id, Associated_Products__c> aProdNew){
        //Query the Product Request of the Associated Product
        List<Associated_Products__c> associcateProductRequests = [
            SELECT
                Id,
                Product_Request__c,
                Product_Request__r.RecordTypeId
            FROM Associated_Products__c
            WHERE Id IN :aProdNew.keySet()
        ];

        // Convert Associated Product List to Map
        Map<Id, Associated_Products__c> assocProdRecTypeMap = new Map<Id, Associated_Products__c>(associcateProductRequests);

        List<Associated_Products__c> assocProdNewList = aProdNew.values();

        Set<Id> productRequestIdSet = new Set<Id>();
        Set<Id> productIdSet = new Set<Id>();
        // Map<Id, String> productRequestRecTypeMap = new Map<Id,Id>();
        for(Associated_Products__c associatedProduct : assocProdNewList){
            //Add the product Request Ids
            if(String.isNotBlank(associatedProduct.Product_Request__c)){
                productRequestIdSet.add(associatedProduct.Product_Request__c);
            }
            //Add the Product Ids
            if(String.isNotBlank(associatedProduct.Product__c)){
                productIdSet.add(associatedProduct.Product__c);
            }
        }

         // Query Buyer Group of the Associated Product
        Set<Id> buyerGroupIdSet = new Set<Id>();
        Map<Id, Id> productReqBGMap = new Map<Id, Id>();
        List <BuyerGroup> buyerGroups = [SELECT 
                                             Id,
                                             Name,
                                             buyerGroup.Product_Request__c
                                          FROM BuyerGroup 
                                          WHERE Product_Request__c IN : productRequestIdSet];
        if(!buyerGroups.isEmpty()){
            for(BuyerGroup buyerGroup : buyerGroups){
                buyerGroupIdSet.add(buyerGroup.Id);
                productReqBGMap.put(buyerGroup.Product_Request__c , buyerGroup.Id);
            }
        }

        // Get Product Categories & Catalogs
        Map<String, ProductCategory> prodCategoryMap = new Map<String, ProductCategory>();
        Set<Id> prodCategIdSet = new Set<Id>();
        Set<Id> prodCatalogIdSet = new Set<Id>();
        for (ProductCategory prodCategory : [
            SELECT Id, Name, CatalogId
            FROM ProductCategory
            WHERE
                Name IN :PROD2_CATEGORIES
                AND Catalog.Name =: CCE_CATALOG
        ]) {
            prodCategoryMap.put(prodCategory.Name, prodCategory);
            prodCategIdSet.add(prodCategory.Id);
            prodCatalogIdSet.add(prodCategory.CatalogId);
        }

        //Query Entitlement Policy based on Buyer Group

         // Get CCE Entitlement Policy Map
        Map<Id, Id> entPolicyCCEMap = new Map<Id, Id>();
        Set<Id> entPolicyCCESet = new Set<Id>();
        for(CommerceEntitlementBuyerGroup commEntBG : [
                                                        SELECT BuyerGroupId, PolicyId
                                                        FROM CommerceEntitlementBuyerGroup
                                                        WHERE BuyerGroupId IN : buyerGroupIdSet
                                                        AND PolicyId != null
        ]) {
            // Assign BuyerGroup Id as Key and Policy Id as value on CCE Entitlment Policy Map
            entPolicyCCEMap.put(commEntBG.BuyerGroupId, commEntBG.PolicyId);
        }

        // Get Existing Products on Product Catalog Products
        Map<String, Set<Id>> prodCategProdIdMap = new Map<String, Set<Id>>();
        for (ProductCategoryProduct prodCategProd : [
                                                        SELECT ProductCategory.Name, ProductId
                                                        FROM ProductCategoryProduct
                                                        WHERE
                                                            CatalogId IN :prodCatalogIdSet
                                                            AND ProductCategoryId IN :prodCategIdSet]) 
        {
            if (prodCategProdIdMap.containsKey(prodCategProd.ProductCategory.Name)){
                // If Category Name Exists in Map, Get Set of Product Ids and Add new Product Id to Set
                Set<Id> prodCategProdIdSet = prodCategProdIdMap.get(
                    prodCategProd.ProductCategory.Name
                );
                prodCategProdIdSet.add(prodCategProd.ProductId);
                prodCategProdIdMap.put(
                    prodCategProd.ProductCategory.Name,
                    prodCategProdIdSet
                );
            } else {
                // If Category Name does not Exists in Map, Create Entry in Map
                prodCategProdIdMap.put(
                    prodCategProd.ProductCategory.Name,
                    new Set<Id>{ prodCategProd.ProductId }
                );
            }
        }

        // Get Existing Products on CCE Product Catalog Products
        Map<Id, Set<Id>> prodEntPolicyCCEMap = new Map<Id, Set<Id>>();
        for (CommerceEntitlementProduct prodEntCCEPolicy : [
            SELECT PolicyId, ProductId
            FROM CommerceEntitlementProduct
            WHERE
                PolicyId IN :entPolicyCCEMap.values()
                AND ProductId IN :productIdSet
        ]) {
            if (prodEntPolicyCCEMap.containsKey(prodEntCCEPolicy.PolicyId)){
                // If Policy Exists in Map, Get Set of Product Ids and Add new Product Id to Set
                Set<Id> prodEntProdIdSet = prodEntPolicyCCEMap.get(prodEntCCEPolicy.PolicyId);
                prodEntProdIdSet.add(prodEntCCEPolicy.ProductId);
                prodEntPolicyCCEMap.put(
                    prodEntCCEPolicy.PolicyId,
                    prodEntProdIdSet
                );
            } else {
                // If Policy Name does not Exists in Map, Create Entry in Map
                prodEntPolicyCCEMap.put(
                    prodEntCCEPolicy.PolicyId,
                    new Set<Id>{ prodEntCCEPolicy.ProductId }
                );
            }
        }


        //Process
        List<ProductCategoryProduct> insertProdCategProdList = new List<ProductCategoryProduct>();
        List<CommerceEntitlementProduct> insertProdEntPolicyList = new List<CommerceEntitlementProduct>();
        for(Associated_Products__c assocProd : assocProdNewList){
            Id entPolicyCCE;
            Id prod2PRRecType;

            Associated_Products__c apRecTypeMap = (Associated_Products__c) assocProdRecTypeMap.get(assocProd.Id);
            //Get Entitlment Policy
            if(String.IsNotBlank(apRecTypeMap.Product_Request__c) && 
                productReqBGMap.containsKey(apRecTypeMap.Product_Request__c) &&
                entPolicyCCEMap.containsKey(productReqBGMap.get(apRecTypeMap.Product_Request__c))
            ){
                entPolicyCCE = (Id) entPolicyCCEMap.get(productReqBGMap.get(apRecTypeMap.Product_Request__c));
                prod2PRRecType = apRecTypeMap.Product_Request__r.RecordTypeId;
            }

            //Get Set of Ids that Exists in CCE Product Category Products
            Set<Id> prodCategProdCCESet = new Set<Id>();
            if (prodEntPolicyCCEMap.containsKey(entPolicyCCE)) {
                prodCategProdCCESet = prodEntPolicyCCEMap.get(entPolicyCCE);
            }

            //Insert to CCE Product Store
            //QUTeX Learning Solutions Category
            if(prod2PRRecType ==  PR_STANDOFFERARRANGE_RECTYPEID && prodCategoryMap.containsKey(CCE_CATEGORY_QLS) ){
                Set<Id> prodCategProdCCEQLSSet = new Set<Id>();
                if (prodCategProdIdMap.containsKey(CCE_CATEGORY_QLS)){
                    prodCategProdCCEQLSSet = prodCategProdIdMap.get(CCE_CATEGORY_QLS);
                }

                // Get CCE Catalog & Standing Offer Arrangement Category
                ProductCategory prodCategCCEQLS = (ProductCategory) prodCategoryMap.get(CCE_CATEGORY_QLS);

                // Check if Product Id is not yet configured on Standing Offer Arrangement Category Product Category Product
                if (!prodCategProdCCEQLSSet.contains(assocProd.Product__c)) {
                    ProductCategoryProduct prodCategProdCCE = new ProductCategoryProduct();
                    prodCategProdCCE.ProductCategoryId = prodCategCCEQLS.Id;
                    prodCategProdCCE.ProductId = assocProd.Product__c;
                    insertProdCategProdList.add(prodCategProdCCE);
                }

            }

            //Corporate Bundle Category
            if(prod2PRRecType == PR_CORPBUNDLE_RECTYPEID && prodCategoryMap.containsKey(CCE_CATEGORY_CB)){
                Set<Id> prodCategProdCCECBSet = new Set<Id>();
                if(prodCategProdIdMap.containsKey(CCE_CATEGORY_CB)){
                    prodCategProdCCECBSet = prodCategProdIdMap.get(CCE_CATEGORY_CB);
                }

                //Get CCE Catalog & Corporate Bundle Category
                ProductCategory prodCategCCECB = (ProductCategory) prodCategoryMap.get(CCE_CATEGORY_CB);

                // Check if Product Id is not yet configured on Corporate Bundle Category Product Category Product
                if (!prodCategProdCCECBSet.contains(assocProd.Product__c)) {
                    ProductCategoryProduct prodCategProdCCE = new ProductCategoryProduct();
                    prodCategProdCCE.ProductCategoryId = prodCategCCECB.Id;
                    prodCategProdCCE.ProductId = assocProd.Product__c;
                    insertProdCategProdList.add(prodCategProdCCE);
                }
            }
                // Check if Product Id is not yet configured on CCE Product Entitlement Policy
            if (!prodCategProdCCESet.contains(assocProd.Product__c) && entPolicyCCE != null) {
                CommerceEntitlementProduct prodEntPolicyCCE = new CommerceEntitlementProduct();
                prodEntPolicyCCE.PolicyId = entPolicyCCE;
                prodEntPolicyCCE.ProductId = assocProd.Product__c;
                insertProdEntPolicyList.add(prodEntPolicyCCE);
            }
        }

        // Insert Product Category Product
        if (insertProdCategProdList.size() > 0) {
            insert insertProdCategProdList;
        }

        // Insert Product Entitlement Policy
        if (insertProdEntPolicyList.size() > 0) {
            insert insertProdEntPolicyList;
         }

        // Run Build Index
        B2BStoreSearchIndexHandler handler = new B2BStoreSearchIndexHandler();
        handler.buildSearchIndex();
    }
}
