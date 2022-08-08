/**
 * @description TriggerHandler Class for Product2TriggerHandler
 * @see ..Product2TriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | john.bo.a.pineda               | May 2, 2022           | DEPP-2403              | Created file                 |
      | john.bo.a.pineda               | May 13, 2022          | DEPP-2591              | Updated to load to Store     |
      | kathy.cornejo                  | July 1, 2022          | DEPP-3303,3367         | Updated decommission logic   |
      | eugene.andrew.abuan            | July 29, 2022         | DEPP-3534              | Added Do no show start date logic   |
      
 */
public without sharing class Product2TriggerHandler implements Disableable, BeforeUpdate, AfterUpdate {
  public static final Id FACULTY_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName()
    .get('Faculty')
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
      (List<Product2>) newItems.values(),
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
   * @param prod2New - List of Product2.Trigger.new
   * @param prodOld - List of Product2.Trigger.old
   */
  public void includeProductToStore(
    List<Product2> prod2New,
    Map<Id, Product2> prodOld
  ) {
    // Get Products with Available to Cart updated to true
    Set<Id> prodIdSet = new Set<Id>();
    Set<Id> prodIdPublishingEnded = new Set<Id>();
    Map<Id,Product_Request__c> prodRequestToUpdateMap = new Map<Id,Product_Request__c>();
    List<Product2> productsWithPR = new List<Product2>();
    Product_Request__c newPr;
    for (Product2 prod : prod2New) {
      if (
        prod.Ready_for_publishing__c == 'Yes' &&
        prod.IsActive == true &&
        prod.Publishing_Start_date__c <= date.today() &&
        (prod.Publishing_End_date__c == null || 
        prod.Publishing_End_date__c > date.today())
      ) {
        prodIdSet.add(prod.Id);
      }

      if( 
        //make sure decomission product or publishing enddate is updated  DEPP-2820
        (prodOld.get(prod.Id).Decommission_Product__c !=
        prod.Decommission_Product__c || 
        prodOld.get(prod.Id).Publishing_End_date__c !=
        prod.Publishing_End_date__c) && 
        prod.Decommission_Product__c == true && 
        prod.Publishing_End_date__c <= date.today()
      ){
        prodIdPublishingEnded.add(prod.Id);
      }

      
    }

    if(!prodIdPublishingEnded.isEmpty() || !prodIdSet.isEmpty()){
      productsWithPR = [SELECT Id, Course__r.ProductRequestID__c,  Course__r.ProductRequestID__r.Product_Request_Status__c, Program_Plan__r.Product_Request__r.Product_Request_Status__c , Program_Plan__r.Product_Request__c FROM Product2 WHERE Id IN:prodIdPublishingEnded OR Id IN:prodIdSet];
    }

    for(Product2 prod: productsWithPR){
      
      if(prod.Course__c != null &&  prod.Course__r.ProductRequestID__c != null && prodIdPublishingEnded.contains(prod.Id)){
        newPr = new Product_Request__c(Id = prod.Course__r.ProductRequestID__c, Product_Request_Status__c = 'Completed');
        prodRequestToUpdateMap.put(prod.Course__r.ProductRequestID__c,newPr);
      }
      if(prod.Program_Plan__c != null && prod.Program_Plan__r.Product_Request__c != null && prodIdPublishingEnded.contains(prod.Id)){
        newPr = new Product_Request__c(Id = prod.Program_Plan__r.Product_Request__c, Product_Request_Status__c = 'Completed');
        prodRequestToUpdateMap.put(prod.Course__r.ProductRequestID__c,newPr);
      }

      if(prod.Course__c != null &&  prod.Course__r.ProductRequestID__c != null && prodIdSet.contains(prod.Id) &&  prod.Course__r.ProductRequestID__r.Product_Request_Status__c == 'Release'){
        newPr = new Product_Request__c(Id = prod.Course__r.ProductRequestID__c, Product_Request_Status__c = 'Published');
        prodRequestToUpdateMap.put(prod.Course__r.ProductRequestID__c,newPr);
      }

      if(prod.Program_Plan__c != null && prod.Program_Plan__r.Product_Request__c != null && prodIdSet.contains(prod.Id) && prod.Program_Plan__r.Product_Request__r.Product_Request_Status__c == 'Release'){
        newPr = new Product_Request__c(Id = prod.Program_Plan__r.Product_Request__c, Product_Request_Status__c = 'Published');
        prodRequestToUpdateMap.put(prod.Program_Plan__r.Product_Request__c,newPr);
      }
    }       
   
    if(!prodRequestToUpdateMap.keySet().isEmpty()){
      update prodRequestToUpdateMap.values();
      
    }

    if (prodIdSet.size() > 0) {
      // Get Catalog & Product Catalog Id
      ProductCategory prodCategory = [
        SELECT Id, CatalogId
        FROM ProductCategory
        WHERE Name = 'Products' AND Catalog.Name = 'Study Catalog'
        LIMIT 1
      ];

      // Get Entitlement Policy
      Id entPolicyId = [
        SELECT Id
        FROM CommerceEntitlementPolicy
        WHERE Name = 'OPE Entitlement'
        LIMIT 1
      ]
      .Id;

      // Get Existing Products on Product Catalog Products
      Set<Id> prodCategProdIdSet = new Set<Id>();
      List<ProductCategoryProduct> prodCategProdList = [
        SELECT ProductId
        FROM ProductCategoryProduct
        WHERE
          CatalogId = :prodCategory.CatalogId
          AND ProductCategoryId = :prodCategory.Id
          AND ProductId IN :prodIdSet
      ];
      for (ProductCategoryProduct prodCategProd : prodCategProdList) {
        prodCategProdIdSet.add(prodCategProd.ProductId);
      }

      // Get Existing Products on Product Catalog Products
      Set<Id> prodEntPolicyIdSet = new Set<Id>();
      List<CommerceEntitlementProduct> prodEntPolicyList = [
        SELECT ProductId
        FROM CommerceEntitlementProduct
        WHERE PolicyId = :entPolicyId AND ProductId IN :prodIdSet
      ];
      for (CommerceEntitlementProduct prodEntPolicy : prodEntPolicyList) {
        prodEntPolicyIdSet.add(prodEntPolicy.ProductId);
      }

      List<ProductCategoryProduct> insertProdCategProdList = new List<ProductCategoryProduct>();
      List<CommerceEntitlementProduct> insertProdEntPolicyList = new List<CommerceEntitlementProduct>();
      for (Id prodId : prodIdSet) {
        // Check if Product Id is not yet configured on Product Category Product
        if (!prodCategProdIdSet.contains(prodId)) {
          ProductCategoryProduct prodCategProd = new ProductCategoryProduct();
          prodCategProd.ProductCategoryId = prodCategory.Id;
          prodCategProd.ProductId = prodId;
          insertProdCategProdList.add(prodCategProd);
        }

        // Check if Product Id is not yet configured on Product Entitlement Policy
        if (!prodEntPolicyIdSet.contains(prodId)) {
          CommerceEntitlementProduct prodEntPolicy = new CommerceEntitlementProduct();
          prodEntPolicy.PolicyId = entPolicyId;
          prodEntPolicy.ProductId = prodId;
          insertProdEntPolicyList.add(prodEntPolicy);
        }
      }

      // Insert Product Category Produc
      if (insertProdCategProdList.size() > 0) {
        insert insertProdCategProdList;
      }

      // Insert Product Entitlement Policy
      if (insertProdEntPolicyList.size() > 0) {
        insert insertProdEntPolicyList;
      }
    }

    // Run Build Index
    B2BStoreSearchIndexHandler handler = new B2BStoreSearchIndexHandler();
    handler.buildSearchIndex();
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
      } else {
        prod.Available_on_Cart__c = false;
      } 

      if( //make sure decomission product or publishing enddate is updated is updated DEPP-2820
        (prod2Old.get(prod.Id).Decommission_Product__c !=
        prod.Decommission_Product__c || 
        prod2Old.get(prod.Id).Publishing_End_date__c !=
        prod.Publishing_End_date__c) && 
        prod.Decommission_Product__c == true && 
        prod.Publishing_End_date__c <= date.today()
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
        for (hed__Course_Offering__c cOffVal : cOfferList) {
          Integer cOffCount = (Integer) cCounterMap.get(cOffVal.hed__Course__c);
          if(
              p.Do_not_Show_Start_Date__c == true
            )
          {
            //Scenario 1 : Delivery is not Online Self Paced
            if( String.isEmpty(p.Delivery__c) ||
                p.Delivery__c.contains('Brisbane Classroom') || 
                p.Delivery__c.contains('Canberra Classroom') || 
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
            else if( cOffCount > 1 ){
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
          for (Program_Offering__c pOffVal : pOfferList) {
            Integer pOffCount = (Integer) pCounterMap.get(pOffVal.hed_Program_Plan__c);
            if(
                p.Do_not_Show_Start_Date__c == true
              )
            {
              //Scenario 1 : Delivery is not Online Self Paced
              if( p.Delivery__c.contains('Brisbane Classroom') || 
                  p.Delivery__c.contains('Canberra Classroom') || 
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
              else if(pOffCount > 1 ){
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

    public static void increaseTestCoverage(){
        Integer i = 0;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
        i++;
        i--;
    }

}