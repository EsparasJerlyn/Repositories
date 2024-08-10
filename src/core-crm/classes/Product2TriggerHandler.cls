/**
 * @description TriggerHandler Class for Product2TriggerHandler
 * @see ..Product2TriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                          |
      |--------------------------------|-----------------------|------------------------|-----------------------------------------|
      | john.bo.a.pineda               | May 2, 2022           | DEPP-2403              | Created file                            |
      | john.bo.a.pineda               | May 13, 2022          | DEPP-2591              | Updated to load to Store                |
      | kathy.cornejo                  | July 1, 2022          | DEPP-3303,3367         | Updated decommission logic              |
      | eugene.andrew.abuan            | July 29, 2022         | DEPP-3534              | Added Do no show start date logic       |
      | eugene.andrew.abuan            | August 15, 2022       | DEPP-2665              | Updated IncludeProductToStore           |
      | eugene.andrew.abuan            | September 2, 2022     | DEPP-3762              | Updated validateDoNotShowStartDate      |
      | eugene.andrew.abuan            | September 5, 2022     | DEPP-4102              | Added Program without Pathway           |
      | roy.nino.s.regala              | March, 15, 2022       | DEPP-8210              | Isolate child products of donation cause|
      | eugene.andrew.abuan            | April 10, 2022        | DEPP-8400              | Changed donation cause to designation   |
      | marygrace.li                   | May 6, 2024           | DEPP-8420              | modified validateFacilContactImage      |
                                                                                          to update field to Designation__c       |


 */
public without sharing class Product2TriggerHandler implements Disableable, BeforeUpdate, AfterUpdate {
  public static final Id FACULTY_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName()
    .get('Faculty')
    .getRecordTypeId();
  public static final Id OPE_RECTYPEID = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName()
			.get('OPE')
			.getRecordTypeId();
	public static final Id CCE_RECTYPEID = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName()
			.get('CCE')
			.getRecordTypeId();
	public static final String OPE_ENTITLEMENT_POLICY = 'OPE Entitlement';
	public static final String OPE_CATALOG = 'Study Catalog';
	public static final String CCE_CATALOG = 'CCE Catalog';
	public static final String OPE_CATEGORY_PRODUCTS = 'Products';
	public static final String CCE_CATEGORY_TEE = 'Tailored Executive Education';
	//public static final String CCE_CATEGORY_CB = 'Corporate Bundle'; // on diff object trigger?
	public static final String CCE_CATEGORY_QLS = 'QUTeX Learning Solutions'; // on diff object trigger?
	public static final List<String> PROD2_CATALOGS = new List<String>{
			OPE_CATALOG,
			CCE_CATALOG
	};
	public static final List<String> PROD2_CATEGORIES = new List<String>{
			OPE_CATEGORY_PRODUCTS,
			CCE_CATEGORY_TEE,
			CCE_CATEGORY_QLS
	};
	public static final Id PR_PROGRAM_RECTYPEID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName()
			.get('Program')
			.getRecordTypeId();
	public static final Id PR_ACTIVITY_RECTYPEID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName()
			.get('Activity')
			.getRecordTypeId();
	public static final Id PR_MODULE_RECTYPEID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName()
			.get('Module')
			.getRecordTypeId();
	public static final Id PR_UNIT_RECTYPEID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName()
			.get('Unit')
			.getRecordTypeId();
	public static final Id PR_DIAGTOOL_RECTYPEID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName()
			.get('Diagnostic_Tool')
			.getRecordTypeId();
	public static final Id PR_INDIVCOACHING_RECTYPEID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName()
			.get('Individual_Coaching')
			.getRecordTypeId();
	public static final Id PR_GROUPCOACHING_RECTYPEID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName()
			.get('Group_Coaching')
			.getRecordTypeId();
	public static final Id PR_PROGRAMWITHOUTPATHWAY_RECTYPEID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName()
			.get('Program_Without_Pathway')
			.getRecordTypeId();

  /**
   * @description call method to validate related Facilitator Contacts if Image is uploaded on Contact Image
   * @param newItems - List of Product2.Trigger.new
   * @param oldItems - List of Product2.Trigger.old
   */
  public void beforeUpdate(
    Map<Id, SObject> newItems,
    Map<Id, SObject> oldItems
  ) {
    validateFacilContactImage(
      (List<Product2>) newItems.values(),
      (Map<Id, Product2>) oldItems
    );
    validateDoNotShowStartDate(
      (List<Product2>) newItems.values());
  }

  /**
   * @description call method to insert to OPE Policy & Category and run Store Build Search Index
   * @param newItems - List of Product2.Trigger.new
   * @param oldItems - List of Product2.Trigger.old
   */
  public void afterUpdate(
    Map<Id, SObject> newItems,
    Map<Id, SObject> oldItems
  ) {
    includeProductToStore(
      (Map<Id, Product2>) newItems,
      (Map<Id, Product2>) oldItems
    );
    updateCourseFields(
      (List<Product2>) newItems.values(),
      (Map<Id, Product2>) oldItems
    );
  }

  public void updateCourseFields(
    List<Product2> prod2New,
    Map<Id, Product2> prodOld
  ){
    Map<Id, hed__Program_Plan__c> programToUpdate = new Map<Id, hed__Program_Plan__c>();
    Map<Id, hed__Course__c> courseToUpdate = new Map<Id, hed__Course__c>();

    for(Product2 prod: prod2New){
      if(( prodOld.get(prod.Id).Decommission_Product__c !=
          prod.Decommission_Product__c || 
          prodOld.get(prod.Id).End_Date__c !=
          prod.End_Date__c) && prod.Decommission_Product__c == true && prod.End_Date__c != null){
          if(prod.Program_Plan__c != NULL){
            programToUpdate.put(prod.Program_Plan__c, new hed__Program_Plan__c(Id = prod.Program_Plan__c, hed__End_Date__c = prod.End_Date__c));
          }
          if(prod.Course__c != NULL){
            courseToUpdate.put(prod.Course__c, new hed__Course__c(Id = prod.Course__c, End_Date__c = prod.End_Date__c));
          }
        }
    }
    if(!programToUpdate.keySet().isEmpty()){
      update programToUpdate.values();
    }
    if(!courseToUpdate.keySet().isEmpty()){
      update courseToUpdate.values();
    }
  }

  /**
   * @description method to include Product to Store
   * @param prod2New - Map of Product2.Trigger.new
   * @param prodOld - Map of Product2.Trigger.old
   */
  public void includeProductToStore(
    Map<Id, Product2> prod2New,
    Map<Id, Product2> prodOld
  ) {
    // Get Products with Available to Cart updated to true
    Set<Id> prodIdSet = new Set<Id>();
    Set<Id> prodIdPublishingEnded = new Set<Id>();
    Map<Id,Product_Request__c> prodRequestToUpdateMap = new Map<Id,Product_Request__c>();
    List<Product2> productsWithPR = new List<Product2>();
    Product_Request__c newPr;

    List<Product2> prodRecTypeList = [
      SELECT
          Id,
          Course__c,
          Course__r.ProductRequestId__r.Product_Specification__r.RecordTypeId,
          Course__r.ProductRequestId__r.Product_Specification__r.Opportunity_Name__r.AccountId,
          Course__r.ProductRequestId__r.RecordTypeId,
          Program_Plan__c,
          Program_Plan__r.Product_Request__r.Product_Specification__r.RecordTypeId,
          Program_Plan__r.Product_Request__r.Product_Specification__r.Opportunity_Name__r.AccountId,
          Program_Plan__r.Product_Request__r.RecordTypeId,
          Product_Category__c
      FROM Product2
      WHERE Id IN :prod2New.keySet()
  ];


  // Convert Product List to Map
  Map<Id, Product2> prodRecTypeMap = new Map<Id, Product2>(prodRecTypeList);

  // Get Account Id Set
  Set<Id> prodAccIdSet = new Set<Id>();
  Map<Id, Id> productAccMap = new Map<Id,Id>();
  for (Product2 prodAcc : prodRecTypeList) {
      // If product is CCE
      if (
          prodAcc.Course__r.ProductRequestId__r.Product_Specification__r.RecordTypeId ==
          CCE_RECTYPEID ||
          prodAcc.Program_Plan__r.Product_Request__r.Product_Specification__r.RecordTypeId ==
          CCE_RECTYPEID
      ){
        // Add Course Account to Set and Map
        if (String.isNotBlank(prodAcc.Course__r.ProductRequestId__r.Product_Specification__r.Opportunity_Name__r.AccountId)){
            prodAccIdSet.add(prodAcc.Course__r.ProductRequestId__r.Product_Specification__r.Opportunity_Name__r.AccountId);
            productAccMap.put(prodAcc.Id, prodAcc.Course__r.ProductRequestId__r.Product_Specification__r.Opportunity_Name__r.AccountId);
        }

        // Add Program Plan Account to Set and Map
        if (String.isNotBlank(prodAcc.Program_Plan__r.Product_Request__r.Product_Specification__r.Opportunity_Name__r.AccountId)){
            prodAccIdSet.add(prodAcc.Program_Plan__r.Product_Request__r.Product_Specification__r.Opportunity_Name__r.AccountId);
            productAccMap.put(prodAcc.Id, prodAcc.Program_Plan__r.Product_Request__r.Product_Specification__r.Opportunity_Name__r.AccountId);
        }
    }
  }

  // Get Account Buyer Group Id Set
  Map<Id, Id> prodAccBGIdMap = new Map<Id, Id>();
  Map<Id, Set<Id>> accToBGMap = new Map<Id, Set<Id>>();
  Map<String, Set<Id>> buyerGroupDevNameMap = new Map <String, Set<Id>>();
  for (BuyerGroupMember prodAccBGM : [
                                        SELECT 
                                          BuyerGroupId, 
                                          BuyerId,
                                          BuyerGroup.Product_Request__r.RecordType.DeveloperName
                                        FROM BuyerGroupMember
                                        WHERE BuyerId IN :prodAccIdSet
  ]){
      prodAccBGIdMap.put(prodAccBGM.BuyerGroupId, prodAccBGM.BuyerId);

      //Populate Buyer Group based on the developer name
      if(String.isNotBlank(prodAccBGM.BuyerGroup.Product_Request__c)){
        if(!buyerGroupDevNameMap.containsKey(prodAccBGM.BuyerGroup.Product_Request__r.RecordType.DeveloperName)){
          buyerGroupDevNameMap.put(prodAccBGM.BuyerGroup.Product_Request__r.RecordType.DeveloperName , new Set<Id>());
        }
        buyerGroupDevNameMap.get(prodAccBGM.BuyerGroup.Product_Request__r.RecordType.DeveloperName).add(prodAccBGM.BuyerGroupId);
      }else{
        if(!buyerGroupDevNameMap.containsKey('Tailored')){
          buyerGroupDevNameMap.put('Tailored' , new Set<Id>());
        }
        buyerGroupDevNameMap.get('Tailored').add(prodAccBGM.BuyerGroupId);
      }

      //Populate Account to Buyer group 
      if(String.isNotBlank(prodAccBGM.BuyerId)){
        if(!accToBGMap.containsKey(prodAccBGM.BuyerId)){
          accToBGMap.put(prodAccBGM.BuyerId, new Set<Id>());
        }
        accToBGMap.get(prodAccBGM.BuyerId).add(prodAccBGM.BuyerGroupId);
      }
  }

  // Get List of Product2.Trigger.new
  List<Product2> prod2NewList = prod2New.values();

  for (Product2 prod : prod2NewList) {
      // Get Products with Available to Cart updated to true
    if(
      prod.Ready_for_publishing__c != prodOld.get(prod.Id).Ready_for_publishing__c ||
      prod.Publishing_Start_date__c != prodOld.get(prod.Id).Publishing_Start_date__c ||
      prod.Publishing_End_date__c != prodOld.get(prod.Id).Publishing_End_date__c
    ) {
      if (
        prod.Ready_for_publishing__c == 'Yes' &&
        prod.IsActive == true &&
        prod.Publishing_Start_date__c <= date.today() &&
        (prod.Publishing_End_date__c == null || 
        prod.Publishing_End_date__c > date.today())
      ) {
          prodIdSet.add(prod.Id);
      }
    }
    
    if (
        //make sure decomission product or publishing enddate is updated  DEPP-2820
        (prodOld.get(prod.Id).Decommission_Product__c !=
        prod.Decommission_Product__c ||
        prodOld.get(prod.Id).Publishing_End_date__c !=
        prod.Publishing_End_date__c) &&
        prod.Decommission_Product__c == true &&
        prod.Publishing_End_date__c <= date.today()
    ) {
        prodIdPublishingEnded.add(prod.Id);
    }
  }

  if (!prodIdPublishingEnded.isEmpty() || !prodIdSet.isEmpty()) 
  {
      productsWithPR = [
                        SELECT
                            Id,
                            Course__r.ProductRequestID__c,
                            Course__r.ProductRequestID__r.Product_Request_Status__c,
                            Program_Plan__r.Product_Request__r.Product_Request_Status__c,
                            Program_Plan__r.Product_Request__c
                        FROM Product2
                        WHERE Id IN :prodIdPublishingEnded OR Id IN :prodIdSet];
  }

  for (Product2 prod : productsWithPR) {
    if (
        prod.Course__c != null &&
        prod.Course__r.ProductRequestID__c != null &&
        prodIdPublishingEnded.contains(prod.Id)
    ) {
        newPr = new Product_Request__c(
            Id = prod.Course__r.ProductRequestID__c,
            Product_Request_Status__c = 'Completed'
        );
        prodRequestToUpdateMap.put(
            prod.Course__r.ProductRequestID__c,
            newPr
        );
    }
    if (
        prod.Program_Plan__c != null &&
        prod.Program_Plan__r.Product_Request__c != null &&
        prodIdPublishingEnded.contains(prod.Id)
    ) {
        newPr = new Product_Request__c(
            Id = prod.Program_Plan__r.Product_Request__c,
            Product_Request_Status__c = 'Completed'
        );
        prodRequestToUpdateMap.put(
            prod.Course__r.ProductRequestID__c,
            newPr
        );
    }

    if (
        prod.Course__c != null &&
        prod.Course__r.ProductRequestID__c != null &&
        prodIdSet.contains(prod.Id) &&
        prod.Course__r.ProductRequestID__r.Product_Request_Status__c ==
        'Release'
    ) {
        newPr = new Product_Request__c(
            Id = prod.Course__r.ProductRequestID__c,
            Product_Request_Status__c = 'Published'
        );
        prodRequestToUpdateMap.put(
            prod.Course__r.ProductRequestID__c,
            newPr
        );
    }

    if (
        prod.Program_Plan__c != null &&
        prod.Program_Plan__r.Product_Request__c != null &&
        prodIdSet.contains(prod.Id) &&
        prod.Program_Plan__r.Product_Request__r.Product_Request_Status__c ==
        'Release'
    ) {
        newPr = new Product_Request__c(
            Id = prod.Program_Plan__r.Product_Request__c,
            Product_Request_Status__c = 'Published'
        );
        prodRequestToUpdateMap.put(
            prod.Program_Plan__r.Product_Request__c,
            newPr
        );
    }
  }

  if (!prodRequestToUpdateMap.keySet().isEmpty()) {
      update prodRequestToUpdateMap.values();
  }

  if (prodIdSet.size() > 0) {
      // Get Product Categories & Catalogs
      Map<String, ProductCategory> prodCategoryMap = new Map<String, ProductCategory>();
      Set<Id> prodCategIdSet = new Set<Id>();
      Set<Id> prodCatalogIdSet = new Set<Id>();
      for (ProductCategory prodCategory : [
          SELECT Id, Name, CatalogId
          FROM ProductCategory
          WHERE
              Name IN :PROD2_CATEGORIES
              AND Catalog.Name IN :PROD2_CATALOGS
      ]) {
          prodCategoryMap.put(prodCategory.Name, prodCategory);
          prodCategIdSet.add(prodCategory.Id);
          prodCatalogIdSet.add(prodCategory.CatalogId);
      }

      // Get OPE Entitlement Policy
      Id entPolicyOPE = [
          SELECT Id
          FROM CommerceEntitlementPolicy
          WHERE Name = :OPE_ENTITLEMENT_POLICY
          LIMIT 1
      ]
      .Id;

      // Get CCE Entitlement Policy Map
      Map<Id, Id> entPolicyCCEMap = new Map<Id, Id>();
      for (CommerceEntitlementBuyerGroup commEntBG : [
                                                      SELECT BuyerGroupId, PolicyId
                                                      FROM CommerceEntitlementBuyerGroup
                                                      WHERE BuyerGroupId IN :prodAccBGIdMap.keySet()
                                                      AND PolicyId != NULL
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
                                                        AND ProductCategoryId IN :prodCategIdSet
                                                        AND ProductId IN :prodIdSet]) 
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

      // Get Existing Products on OPE Product Catalog Products
      Set<Id> prodEntPolicyOPESet = new Set<Id>();
      for (CommerceEntitlementProduct prodEntOPEPolicy : [
          SELECT ProductId
          FROM CommerceEntitlementProduct
          WHERE PolicyId = :entPolicyOPE AND ProductId IN :prodIdSet
      ]) {
          prodEntPolicyOPESet.add(prodEntOPEPolicy.ProductId);
      }

      // Get Existing Products on CCE Product Catalog Products
      Map<Id, Set<Id>> prodEntPolicyCCEMap = new Map<Id, Set<Id>>();
      for (CommerceEntitlementProduct prodEntCCEPolicy : [
          SELECT PolicyId, ProductId
          FROM CommerceEntitlementProduct
          WHERE
              PolicyId IN :entPolicyCCEMap.values()
              AND ProductId IN :prodIdSet
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

      // Process
      List<ProductCategoryProduct> insertProdCategProdList = new List<ProductCategoryProduct>();
      List<CommerceEntitlementProduct> insertProdEntPolicyList = new List<CommerceEntitlementProduct>();
      for (Id prodId : prodIdSet) {
          // Get Product Rec Type Map
          Id prod2PSRecType;
          Id prod2PRRecType;
          // Get Product Account Id
          Id prod2AccId;

          Product2 prodRecType = (Product2) prodRecTypeMap.get(prodId);

          if (String.isNotBlank(prodRecType.Course__c)) {
              prod2PSRecType = prodRecType.Course__r.ProductRequestId__r.Product_Specification__r.RecordTypeId;
              prod2PRRecType = prodRecType.Course__r.ProductRequestId__r.RecordTypeId;
              prod2AccId = prodRecType.Course__r.ProductRequestId__r.Product_Specification__r.Opportunity_Name__r.AccountId;
          } else if (String.isNotBlank(prodRecType.Program_Plan__c)) {
              prod2PSRecType = prodRecType.Program_Plan__r.Product_Request__r.Product_Specification__r.RecordTypeId;
              prod2PRRecType = prodRecType.Program_Plan__r.Product_Request__r.RecordTypeId;
              prod2AccId = prodRecType.Program_Plan__r.Product_Request__r.Product_Specification__r.Opportunity_Name__r.AccountId;
          }

          if (prod2PSRecType == OPE_RECTYPEID) {
              // Insert to OPE Product Store
              // Get Set of Ids that Exists in OPE Product Category Products
              Set<Id> prodCategProdOPESet = new Set<Id>();
              if (prodCategProdIdMap.containsKey(OPE_CATEGORY_PRODUCTS)) {
                  prodCategProdOPESet = prodCategProdIdMap.get(OPE_CATEGORY_PRODUCTS);
              }

              // Get OPE Catalog & Category Id
              ProductCategory prodCategOPE = (ProductCategory) prodCategoryMap.get(OPE_CATEGORY_PRODUCTS);

              // Check if Product Id is not yet configured on OPE Product Category Product
              if (!prodCategProdOPESet.contains(prodId)) {
                  ProductCategoryProduct prodCategProdOPE = new ProductCategoryProduct();
                  prodCategProdOPE.ProductCategoryId = prodCategOPE.Id;
                  prodCategProdOPE.ProductId = prodId;
                  insertProdCategProdList.add(prodCategProdOPE);
              }

              // Check if Product Id is not yet configured on OPE Product Entitlement Policy
              if (!prodEntPolicyOPESet.contains(prodId)) {
                  CommerceEntitlementProduct prodEntPolicyOPE = new CommerceEntitlementProduct();
                  prodEntPolicyOPE.PolicyId = entPolicyOPE;
                  prodEntPolicyOPE.ProductId = prodId;
                  insertProdEntPolicyList.add(prodEntPolicyOPE);
              }
          } else if (prod2PSRecType == CCE_RECTYPEID) {
              // Get Policy Id from Policy Map
              Id entPolicyCCE; 
              if(accToBGMap.containsKey(prod2AccId)){
                for(Id bg : accToBGMap.get(prod2AccId)){
                  if(prodRecType.Product_Category__c == 'QUTeX Learning Solutions' &&  
                  buyerGroupDevNameMap.containsKey('Standing_Offer_Arrangement') &&
                  buyerGroupDevNameMap.get('Standing_Offer_Arrangement').contains(bg))
                  {
                    entPolicyCCE = (Id) entPolicyCCEMap.get(bg);
                  }else if(prodRecType.Product_Category__c == 'Tailored Executive Program' &&
                  buyerGroupDevNameMap.containsKey('Tailored') &&
                  buyerGroupDevNameMap.get('Tailored').contains(bg)
                  ){
                    entPolicyCCE = (Id) entPolicyCCEMap.get(bg);
                  }
                }
              }

              // Get Set of Ids that Exists in CCE Product Category Products
              Set<Id> prodCategProdCCESet = new Set<Id>();
              if (prodEntPolicyCCEMap.containsKey(entPolicyCCE)) {
                  prodCategProdCCESet = prodEntPolicyCCEMap.get(entPolicyCCE);
              }

              // Insert to CCE Product Store
              if (
                  prod2PRRecType == PR_PROGRAM_RECTYPEID ||
                  prod2PRRecType == PR_PROGRAMWITHOUTPATHWAY_RECTYPEID ||
                  prod2PRRecType == PR_MODULE_RECTYPEID ||
                  prod2PRRecType == PR_UNIT_RECTYPEID ||
                  prod2PRRecType == PR_INDIVCOACHING_RECTYPEID ||
                  prod2PRRecType == PR_GROUPCOACHING_RECTYPEID ||
                  prod2PRRecType == PR_DIAGTOOL_RECTYPEID ||
                  prod2PRRecType == PR_ACTIVITY_RECTYPEID
              ) {
                  // Insert to Tailored Executive Education Category
                  if (prodRecType.Product_Category__c == 'Tailored Executive Program' && 
                      prodCategoryMap.containsKey(CCE_CATEGORY_TEE)  
                    ) {
                      // Get Set of Ids that Exists in CCE Product Category Products for Tailored Executive Education Category
                      Set<Id> prodCategProdCCETEESet = new Set<Id>();
                      if (prodCategProdIdMap.containsKey(CCE_CATEGORY_TEE)){
                          prodCategProdCCETEESet = prodCategProdIdMap.get(
                              CCE_CATEGORY_TEE
                          );
                      }

                      // Get CCE Catalog & Tailored Executive Education Category
                      ProductCategory prodCategCCETEE = (ProductCategory) prodCategoryMap.get(CCE_CATEGORY_TEE);

                      // Check if Product Id is not yet configured on Tailored Executive Education Category Product Category Product
                      if (!prodCategProdCCETEESet.contains(prodId)) {
                          ProductCategoryProduct prodCategProdCCE = new ProductCategoryProduct();
                          prodCategProdCCE.ProductCategoryId = prodCategCCETEE.Id;
                          prodCategProdCCE.ProductId = prodId;
                          insertProdCategProdList.add(prodCategProdCCE);
                      }
                  }

                  // Insert to Standing Offer Arrangement Category
                  if (prodRecType.Product_Category__c == 'QUTeX Learning Solutions' &&
                      prodCategoryMap.containsKey(CCE_CATEGORY_QLS)  
                  ) {
                      // Get Set of Ids that Exists in CCE Product Category Products for Standing Offer Arrangement Category

                      Set<Id> prodCategProdCCEQLSSet = new Set<Id>();
                      if (prodCategProdIdMap.containsKey(CCE_CATEGORY_QLS)){
                          prodCategProdCCEQLSSet = prodCategProdIdMap.get(CCE_CATEGORY_QLS);
                      }

                      // Get CCE Catalog & Standing Offer Arrangement Category
                      ProductCategory prodCategCCEQLS = (ProductCategory) prodCategoryMap.get(CCE_CATEGORY_QLS);

                      // Check if Product Id is not yet configured on Standing Offer Arrangement Category Product Category Product
                      if (!prodCategProdCCEQLSSet.contains(prodId)) {
                          ProductCategoryProduct prodCategProdCCE = new ProductCategoryProduct();
                          prodCategProdCCE.ProductCategoryId = prodCategCCEQLS.Id;
                          prodCategProdCCE.ProductId = prodId;
                          insertProdCategProdList.add(prodCategProdCCE);
                      }
                  }

                  // Check if Product Id is not yet configured on CCE Product Entitlement Policy
                  if (!prodCategProdCCESet.contains(prodId) && entPolicyCCE != null ) {
                      CommerceEntitlementProduct prodEntPolicyCCE = new CommerceEntitlementProduct();
                      prodEntPolicyCCE.PolicyId = entPolicyCCE;
                      prodEntPolicyCCE.ProductId = prodId;
                      insertProdEntPolicyList.add(prodEntPolicyCCE);
                  }
              }
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

  /**
   * @description validate related Facilitator Contacts if Image is uploaded on Contact Image
   * @param prod2New - List of Product2.Trigger.new
   * @param prod2Old - Map of Product2.Trigger.old
   */
  public void validateFacilContactImage(
    List<Product2> prod2New,
    Map<Id, Product2> prod2Old
  ) {
    // Get Course Id Set for Single Product Ready for Publishing updated to 'Yes'
    Set<Id> courseIdSet = new Set<Id>();
    for (Product2 prod : prod2New) {
      if (
        prod2Old.get(prod.Id).Ready_for_publishing__c !=
        prod.Ready_for_publishing__c &&
        prod.Ready_for_publishing__c == 'Yes' &&
        String.isBlank(prod.Program_Plan__c)
      ) {
        courseIdSet.add(prod.Course__c);
      }

      //copy over end date to publishing enddate if decomission product is true
      if(
        (prod2Old.get(prod.Id).Decommission_Product__c !=
          prod.Decommission_Product__c || 
          prod2Old.get(prod.Id).End_Date__c !=
          prod.End_Date__c) && prod.Decommission_Product__c == true && prod.End_Date__c != null){
            prod.Publishing_End_date__c = prod.End_Date__c;
      }

      // Update Available to Cart when condition is true else false
      if (
        prod.Ready_for_publishing__c == 'Yes' &&
        prod.IsActive == true &&
        prod.Publishing_Start_date__c <= date.today() &&
        (prod.Publishing_End_date__c == null || 
        prod.Publishing_End_date__c > date.today())
        && prod.Child_Of_Prescribed_Program__c == false //do not include child of prescribed program
      ) {
        prod.Available_on_Cart__c = true;
        //only set to false if not a child of donation cause (Designation) for now.
      } else if(prod.Designation__c == null){ 
        prod.Available_on_Cart__c = false;
      }

      if( //make sure decomission product or publishing enddate is updated is updated DEPP-2820
        (prod2Old.get(prod.Id).Decommission_Product__c !=
        prod.Decommission_Product__c || 
        prod2Old.get(prod.Id).Publishing_End_date__c !=
        prod.Publishing_End_date__c) && 
        prod.Decommission_Product__c == true && 
        prod.Publishing_End_date__c <= date.today() &&
        //only set deactivate if not a child of donation cause (Designation).
        prod.Designation__c == null
      ){
        prod.IsActive = false;
        prod.Available_on_Cart__c = false;
      }
    }

    if (courseIdSet.size() > 0) {
      // Get List of Course Connection Facilitators
      Map<Id, Map<Id, String>> noCourseConImageMap = new Map<Id, Map<Id, String>>();
      List<hed__Course_Offering__c> cOfferList = [
        SELECT
          Id,
          hed__Course__c,
          (
            SELECT
              Id,
              IsActive__c,
              hed__Contact__c,
              hed__Contact__r.Name,
              hed__Contact__r.Contact_Image__c
            FROM hed__Course_Enrollment__r
            WHERE RecordTypeId = :FACULTY_RECTYPEID AND IsActive__c = TRUE
          )
        FROM hed__Course_Offering__c
        WHERE IsActive__c = TRUE AND hed__Course__c IN :courseIdSet
      ];

      if (cOfferList.size() > 0) {
        // Validate Contact Image from Course Enrollment under Course Offering
        Map<Id, String> noConImageMap = new Map<Id, String>();
        for (hed__Course_Offering__c cOffer : cOfferList) {
          for (
            hed__Course_Enrollment__c cEnroll : cOffer.hed__Course_Enrollment__r
          ) {
            Integer imageCount = 0;
            if (String.isNotBlank(cEnroll.hed__Contact__r.Contact_Image__c)) {
              // Count Number of Images on cEnroll.hed__Contact__r.Contact_Image__c
              Matcher imgMatcher = Pattern.compile('<img(.+?)>')
                .matcher(cEnroll.hed__Contact__r.Contact_Image__c);
              while (imgMatcher.find()) {
                imageCount++;
                // Break While loop when Image File Found
                if (imageCount == 1) {
                  break;
                }
              }

              // If imageCount is 0, Add Contact Id & Name to noConImageMap
              if (imageCount == 0) {
                if (!noConImageMap.containsKey(cEnroll.hed__Contact__c)) {
                  noConImageMap.put(
                    cEnroll.hed__Contact__c,
                    cEnroll.hed__Contact__r.Name
                  );
                }
              }
            } else {
              // If Contact Image is empty, Add Contact Id & Name to noConImageMap
              if (!noConImageMap.containsKey(cEnroll.hed__Contact__c)) {
                noConImageMap.put(
                  cEnroll.hed__Contact__c,
                  cEnroll.hed__Contact__r.Name
                );
              }
            }
          }

          if (!noConImageMap.isEmpty()) {
            noCourseConImageMap.put(cOffer.hed__Course__c, noConImageMap);
          }
        }
      }

      // If there are Facilitator contacts with no Contact Image, add Error to Ready for Publishing
      if (!noCourseConImageMap.isEmpty()) {
        for (Product2 prodVal : prod2New) {
          if (noCourseConImageMap.containsKey(prodVal.Course__c)) {
            Map<Id, String> conMap = noCourseConImageMap.get(prodVal.Course__c);
            List<String> conList = conMap.values();
            prodVal.Ready_for_publishing__c.addError(
              Label.QUT_Product2_ContactImageError +
              ' ' +
              String.join(conList, ', ')
            );
          }
        }
      }
    }
  }

    /**
   * @description validate Do not Show Start Date if it is checked
   * @param prod2New - List of Product2.Trigger.new
   */
  public void validateDoNotShowStartDate(
    List<Product2> prod2New
  ) {
    Set<Id> courseIdSet = new Set<Id>();
    Set<Id> programIdSet = new Set<Id>();
    // Get Course Id / Program Id of the Product
    for (Product2 prod : prod2New) {
      if (
        prod.Do_not_Show_Start_Date__c == true 
        // prod.Do_not_Show_Start_Date__c != prod2Old.get(prod.Id).Do_not_Show_Start_Date__c
      ) {
        if(String.isNotBlank(prod.Course__c)){
          courseIdSet.add(prod.Course__c);
        }
        if(String.IsNotBlank(prod.Program_Plan__c)){
          programIdSet.add(prod.Program_Plan__c);
        }
      }
    }  

    //Single Product
    if (!courseIdSet.isEmpty()) {
      // Get Active Course Offering Count per Course
      Map<Id, Integer> cCounterMap = new Map<Id, Integer>();
      for (AggregateResult cOffCounter : [
          SELECT hed__Course__c, Count(Id) counter
          FROM hed__Course_Offering__c
          WHERE hed__Course__c IN :courseIdSet AND IsActive__c = TRUE
          GROUP BY hed__Course__c
      ]) {
          cCounterMap.put(
              (Id) cOffCounter.get('hed__Course__c'),
              (Integer) cOffCounter.get('counter')
          );
      }

      List<hed__Course_Offering__c> cOfferList = [
      SELECT
        Id,
        hed__Course__c,
        IsActive__c	
      FROM hed__Course_Offering__c
      WHERE IsActive__c = TRUE AND hed__Course__c IN :courseIdSet
      ];

      // Process
      for(Product2 p : prod2New){
        if(p.Do_not_Show_Start_Date__c == true){
          //Scenario 1 : Delivery is not Online Self Paced
          if(String.isEmpty(p.Delivery__c) ||
            p.Delivery__c.contains('Brisbane Classroom') || 
            p.Delivery__c.contains('Canberra Classroom') || 
            p.Delivery__c.contains('Cairns Classroom') ||
            p.Delivery__c.contains('NSW Classroom') ||
            p.Delivery__c.contains('Sydney Classroom') ||             
            p.Delivery__c.contains('Melbourne Classroom') || 
            p.Delivery__c.contains('Online Classroom')||
            !p.Delivery__c.contains('Online Self-paced')
          ){
            p.Do_not_Show_Start_Date__c.addError(
              'Please ensure you have one product offering active and the delivery is online self-paced'
            );
          }
          //Scenario 2: Delivery Online Self Paced but offering is greater than 1
          for (hed__Course_Offering__c cOffVal : cOfferList) {
            Integer cOffCount = (Integer) cCounterMap.get(cOffVal.hed__Course__c);
            if( cOffCount > 1){
              p.Do_not_Show_Start_Date__c.addError(
                'Please ensure you have one product offering active and the delivery is online self-paced'
              );
            }
          }
        }
      }  
    }

    //Program 
    if(!programIdSet.isEmpty()){
      // Get Active Program Offering Count per Program Plan
      Map<Id, Integer> pCounterMap = new Map<Id, Integer>();
      for (AggregateResult pOffCounter : [
          SELECT hed_Program_Plan__c, Count(Id) counter
          FROM Program_Offering__c
          WHERE hed_Program_Plan__c IN :programIdSet AND IsActive__c = TRUE
          GROUP BY hed_Program_Plan__c
      ]) {
          pCounterMap.put(
              (Id) pOffCounter.get('hed_Program_Plan__c'),
              (Integer) pOffCounter.get('counter')
          );
      }

      //Query the list of Program Offering based on the Program Plan
      List<Program_Offering__c> pOfferList = [
        SELECT
          Id,
          hed_Program_Plan__c,
          IsActive__c	
        FROM Program_Offering__c
        WHERE IsActive__c = TRUE AND hed_Program_Plan__c IN :programIdSet
        ];

        // Process
      for(Product2 p : prod2New){
        if(p.Do_not_Show_Start_Date__c == true){
          //Scenario 1 : Delivery is not Online Self Paced
          if(String.isEmpty(p.Delivery__c) ||
            p.Delivery__c.contains('Brisbane Classroom') || 
            p.Delivery__c.contains('Canberra Classroom') || 
            p.Delivery__c.contains('Cairns Classroom') ||
            p.Delivery__c.contains('NSW Classroom') ||
            p.Delivery__c.contains('Sydney Classroom') ||             
            p.Delivery__c.contains('Melbourne Classroom') || 
            p.Delivery__c.contains('Online Classroom')||
            !p.Delivery__c.contains('Online Self-paced')
          ){
            p.Do_not_Show_Start_Date__c.addError(
              'Please ensure you have one product offering active and the delivery is online self-paced'
            );
          }
          for (Program_Offering__c pOffVal : pOfferList) {
            Integer pOffCount = (Integer) pCounterMap.get(pOffVal.hed_Program_Plan__c);
            if(pOffCount > 1 ){
              p.Do_not_Show_Start_Date__c.addError(
               'Please ensure you have one product offering active and the delivery is online self-paced'
              );
            }
          } 
        }
      }
    }
  }

  /**
   * @description indicates it the trigger is disabled
   * @return disabled bypass
   */
  public Boolean isDisabled() {
    final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
    return bypass.isDisabled();
  }
}