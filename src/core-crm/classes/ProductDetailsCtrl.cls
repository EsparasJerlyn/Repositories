/**
 * @description Controller Class for productDetails and productDetailsDisplay LWC
 * @see ../lwc/productDetails
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                             |
      |---------------------------|-----------------------|----------------------|--------------------------------------------|
      | roy.nino.s.regala         | December 03, 2021     | DEPP-116             | Created file                               |
      | roy.nino.s.regala         | February 04, 2022     | DEPP-213             | Added insertion of Expression of Interest  |
      | roy.nino.s.regala         | March 04, 2022        | DEPP-1985            | Bug fix added recordtype                   |
      | john.bo.a.pineda          | April 11, 2022        | DEPP-1211            | Updated logic for new UI                   |
 */
public without sharing class ProductDetailsCtrl {
  public static final Id STUDENT_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName()
    .get('Student')
    .getRecordTypeId();
  public static final Id FACULTY_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName()
    .get('Faculty')
    .getRecordTypeId();

  /**
   * @description fetches course offerings and pricebooks related to the product
   * @param productId - Product Id on productdetailpage
   * @return prodDetailsData - Product Details & Pricebook Entries for Price picklist
   */
  @AuraEnabled(cacheable=true)
  public static ProductDetailsData getProductRelatedRecords(Id productId) {
    ProductDetailsData prodDetailsData = new ProductDetailsData();
    List<PricebookEntryWrapper> pbEntryWrapperList = new List<PricebookEntryWrapper>();
    List<DeliveryWrapper> delivWrapperList = new List<DeliveryWrapper>();

    // Product
    Product2 productOnPage = [
      SELECT
        Id,
        Name,
        StockKeepingUnit,
        Course__c,
        Program_Plan__c,
        Duration__c,
        Delivery__c,
        Register_Interest_Available__c,
        Overview__c,
        Evolve_with_QUTeX__c,
        Who_Should_Participate__c,
        Core_Concepts__c,
        More_Details__c,
        (
          SELECT Id, Pricebook2.Name, UnitPrice
          FROM PricebookEntries
          WHERE IsActive = TRUE
          ORDER BY CreatedDate, Pricebook2.IsStandard DESC
        )
      FROM Product2
      WHERE Id = :productId
    ];

    // Pricebook Entries
    if (!productOnPage.PricebookEntries.isEmpty()) {
      for (PricebookEntry pricebookEntry : productOnPage.PricebookEntries) {
        PricebookEntryWrapper pbEntryWrapper = new PricebookEntryWrapper();
        pbEntryWrapper.label = pricebookEntry.Pricebook2.Name;
        pbEntryWrapper.value = pricebookEntry.Id;
        pbEntryWrapper.meta = String.valueOf(pricebookEntry.UnitPrice);
        pbEntryWrapperList.add(pbEntryWrapper);
      }
    }

    // Delivery Options
    if (String.isNotBlank(productOnPage.Delivery__c)) {
      // Course Offering counter for Delivery
      Map<String, Integer> deliveryCountMap = new Map<String, Integer>();
      List<AggregateResult> countList = [
        SELECT Count(Id) counter, Delivery_Type__c
        FROM hed__Course_Offering__c
        WHERE
          Registration_Start_Date__c >= TODAY
          AND IsActive__c = TRUE
          AND Available_Seats__c > 0
          AND hed__Course__c = :productOnPage.Course__c
        GROUP BY Delivery_Type__c
      ];
      for (AggregateResult count : countList) {
        deliveryCountMap.put(
          (String) count.get('Delivery_Type__c'),
          (Integer) count.get('counter')
        );
      }

      // Display Delivery Options w/ Course Offerings
      List<String> delivList = productOnPage.Delivery__c.split(';');
      for (String deliv : delivList) {
        if (deliveryCountMap.get(deliv) > 0) {
          DeliveryWrapper delivWrapper = new DeliveryWrapper();
          delivWrapper.label = deliv;
          delivWrapper.value = deliv;
          delivWrapperList.add(delivWrapper);
        }
      }
    }

    // Set values to wrapper
    prodDetailsData.productOnPage = productOnPage;
    prodDetailsData.pricebookWrapperList = pbEntryWrapperList;
    prodDetailsData.deliveryWrapperList = delivWrapperList;

    return prodDetailsData;
  }

  /**
   * @description fetches related course offerings to the product
   * @param courseId - Product Id on productdetailpage
   * @param deliveryParam - Delivery Parameter selected on productdetailpage
   * @return cOfferList - Product Details & Pricebook Entries for Price picklist
   */
  @AuraEnabled(cacheable=true)
  public static List<CourseOfferingWrapper> getCourseOfferingRelatedRecords(
    Id courseId,
    List<String> deliveryParam
  ) {
    List<CourseOfferingWrapper> cOfferWrapperList = new List<CourseOfferingWrapper>();

    if (deliveryParam.size() > 0) {
      // Get Course Offering from selected Delivery Options
      List<hed__Course_Offering__c> cOfferList = [
        SELECT
          Id,
          hed__Start_Date__c,
          Available_Seats__c,
          hed__Facility__r.Display_Name__c,
          (
            SELECT
              Id,
              hed__Contact__c,
              hed__Contact__r.Name,
              Facilitator_Bio__r.Professional_Bio__c,
              hed__Contact__r.Contact_Image__c
            FROM hed__Course_Enrollment__r
            WHERE RecordTypeId = :FACULTY_RECTYPEID
          )
        FROM hed__Course_Offering__c
        WHERE
          Registration_Start_Date__c >= TODAY
          AND IsActive__c = TRUE
          AND Available_Seats__c > 0
          AND hed__Course__c = :courseId
          AND Delivery_Type__c IN :deliveryParam
        ORDER BY hed__Start_Date__c ASC
      ];

      if (cOfferList.size() > 0) {
        // Get Set of Contact Ids
        Set<Id> conIdSet = new Set<Id>();
        for (hed__Course_Offering__c cOfferConId : cOfferList) {
          for (
            hed__Course_Enrollment__c cEnrollConId : cOfferConId.hed__Course_Enrollment__r
          ) {
            conIdSet.add(cEnrollConId.hed__Contact__c);
          }
        }

        // Get ContentDocumentLink for Contacts
        Map<Id, Id> conContentDocuIdMap = new Map<Id, Id>();
        Map<Id, ContentVersion> conContentVersionMap = new Map<Id, ContentVersion>();
        Map<Id, ContentDistribution> conContentDistributionMap = new Map<Id, ContentDistribution>();
        if (conIdSet.size() > 0) {
          List<ContentDocumentLink> conContentDocuLinkList = [
            SELECT Id, ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :conIdSet
          ];
          for (
            ContentDocumentLink conContentDocuLink : conContentDocuLinkList
          ) {
            conContentDocuIdMap.put(
              conContentDocuLink.ContentDocumentId,
              conContentDocuLink.LinkedEntityId
            );
          }

          // Get Contact Version
          List<ContentVersion> conContentVersionList = [
            SELECT Id, ContentDocumentId, ContentBodyId, FileType
            FROM ContentVersion
            WHERE
              Title = 'ContactImage.jpg'
              AND ContentDocumentId IN :conContentDocuIdMap.keySet()
          ];
          for (ContentVersion conContentVersion : conContentVersionList) {
            conContentVersionMap.put(
              conContentDocuIdMap.get(conContentVersion.ContentDocumentId),
              conContentVersion
            );
          }

          // Get Content Distribution
          List<ContentDistribution> conContentDistributionList = [
            SELECT Id, ContentDocumentId, DistributionPublicUrl
            FROM ContentDistribution
            WHERE
              Name = 'ContactImage.jpg'
              AND ContentDocumentId IN :conContentDocuIdMap.keySet()
          ];
          for (
            ContentDistribution conContentDistribution : conContentDistributionList
          ) {
            conContentDistributionMap.put(
              conContentDocuIdMap.get(conContentDistribution.ContentDocumentId),
              conContentDistribution
            );
          }
        }

        // Set Available Start Date Wrapper
        for (hed__Course_Offering__c cOffer : cOfferList) {
          CourseOfferingWrapper cOfferWrapper = new CourseOfferingWrapper();
          // label
          cOfferWrapper.label = Datetime.newInstance(
              cOffer.hed__Start_Date__c,
              Time.newInstance(0, 0, 0, 0)
            )
            .format('dd MMM yyyy');
          // value
          cOfferWrapper.value = cOffer.Id;
          // meta
          if (cOffer.Available_Seats__c <= 10) {
            if (cOffer.Available_Seats__c == 1) {
              cOfferWrapper.meta =
                cOffer.Available_Seats__c +
                ' ' +
                Label.QUT_ProductDetail_CourseSeatLeft;
            } else {
              cOfferWrapper.meta =
                cOffer.Available_Seats__c +
                ' ' +
                Label.QUT_ProductDetail_CourseSeatsLeft;
            }
          }
          // location
          cOfferWrapper.location = cOffer.hed__Facility__r.Display_Name__c;
          // facilitator
          List<facilitatorWrapper> facilWrapperList = new List<facilitatorWrapper>();
          for (
            hed__Course_Enrollment__c cEnroll : cOffer.hed__Course_Enrollment__r
          ) {
            facilitatorWrapper facilWrapper = new facilitatorWrapper();
            // Facilitator Name
            facilWrapper.facilitatorName = cEnroll.hed__Contact__r.Name;
            // Facilitator Bio
            facilWrapper.facilitatorBio = cEnroll.Facilitator_Bio__r.Professional_Bio__c;
            // Facilitator Image
            if (conContentVersionMap.containsKey(cEnroll.hed__Contact__c)) {
              ContentVersion cv = conContentVersionMap.get(
                cEnroll.hed__Contact__c
              );
              ContentDistribution cDis = conContentDistributionMap.get(
                cEnroll.hed__Contact__c
              );

              // Construct Public URL for Contact Image
              String fileType = cv.FileType.toLowerCase().capitalize();
              String cVersionId = cv.Id;
              String cBodyId = cv.ContentBodyId;
              String originalUrl = String.valueOf(cDis.DistributionPublicUrl);
              String cDistParam = originalUrl.substring(
                originalUrl.indexOf('/a/')
              );
              String orgId = UserInfo.getOrganizationId();
              String baseDomain = Url.getOrgDomainUrl().toExternalForm();
              baseDomain =
                baseDomain.substringBefore('.') + '--c.documentforce.com';
              String theUrl =
                baseDomain +
                '/sfc/dist/version/renditionDownload?rendition=ORIGINAL_' +
                fileType +
                '&versionId=' +
                cVersionId +
                '&operationContext=DELIVERY&contentId=' +
                cBodyId +
                '&page=0&d=' +
                cDistParam +
                '&oid=' +
                orgId +
                '&dpt=null&viewId=';
              facilWrapper.facilitatorImage = theUrl;
            }
            facilWrapperList.add(facilWrapper);
          }

          // Set values to wrapper
          cOfferWrapper.facilitator = facilWrapperList;
          cOfferWrapperList.add(cOfferWrapper);
        }
      }
    }

    return cOfferWrapperList;
  }

  /**
   * @description Custom Add to Cart process
   * @param communityId The Id of the community from which the call originated
   * @param productId The Id of the product
   * @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
   * @param productName The Product Name.
   * @param courseOfferingId The Course Offering Id of the selected Available Start Date on UI.
   * @param pricebookEntryId The Pricebook Entry Id of the selected Price on UI.
   */
  @AuraEnabled
  public static void addToCartItem(
    String communityId,
    String productId,
    String effectiveAccountId,
    String productName,
    String courseOfferingId,
    String pricebookEntryId
  ) {
    try {
      // Lookup the webstore ID associated with the community
      String webstoreId;
      if (Test.isRunningTest()) {
        webstoreId = [SELECT Id FROM WebStore LIMIT 1].Id;
      } else {
        webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
      }

      // Get Current User Active Cart
      Id cartId = [
        SELECT Id, Name, WebStoreId, AccountId, Status, Type
        FROM WebCart
        WHERE
          Status = 'Active'
          AND AccountId = :effectiveAccountId
          AND WebStoreId = :webstoreId
        LIMIT 1
      ]
      .Id;

      // Get Current User Active Cart Delivery Group
      Id cartDeliveryGroupId = [
        SELECT Id, Name, CreatedDate, LastModifiedDate, CartId
        FROM CartDeliveryGroup
        WHERE CartId = :cartId
      ]
      .Id;

      // Set Cart Item to be inserted
      CartItem cItem = new CartItem();
      cItem.CartId = cartId;
      cItem.CartDeliveryGroupId = cartDeliveryGroupId;
      cItem.Name = productName;
      cItem.Product2Id = productId;
      cItem.Course_Offering__c = courseOfferingId;
      cItem.Pricebook_Entry_ID__c = pricebookEntryId;
      //cItem.Program_Offering__c = '';
      cItem.Quantity = 1;
      cItem.Type = 'Product';

      insert cItem;
    } catch (Exception e) {
      system.debug(e);
      system.debug('Error on ProductDetailsCtrl.addToCartItem');
      AuraHandledException auraEx = new AuraHandledException(e.getMessage());
      throw auraEx;
    }
  }

  /**
   * @description inserts new contacts and course connections with link to selected offering
   * @param learnerInfoList - ids of contact records
   * @param wrappedData - data aside from contact (course offering ID)
   */
  /* @AuraEnabled
  public static void insertLearnerInfo(
    List<Contact> learnerInfoList,
    WrapperClass wrappedData
  ) {
    try {
      List<hed__Course_Enrollment__c> courseConnectionList = new List<hed__Course_Enrollment__c>();

      insert (learnerInfoList);
      for (Contact con : learnerInfoList) {
        courseConnectionList.add(
          new hed__Course_Enrollment__c(
            RecordTypeId = STUDENT_RECTYPEID,
            hed__Contact__c = con.Id,
            hed__Course_Offering__c = Id.valueOf(wrappedData.courseOfferingId),
            hed__Status__c = 'Current'
          )
        );
      }
      insert (courseConnectionList);
    } catch (Exception e) {
      system.debug(e);
      system.debug('error on ProductDetailsCtrl.insertLearnerInfo');
      AuraHandledException auraEx = new AuraHandledException(e.getMessage());
      throw auraEx;
    }
  } */

  @AuraEnabled
  public static void insertExpressionOfInterest(Id userId, Id productId) {
    User loggedInUser = [SELECT Id, Contact.Id FROM User WHERE Id = :userId];
    List<Expression_of_Interest__c> existingInterest = new List<Expression_of_Interest__c>(
      [
        SELECT Id
        FROM Expression_of_Interest__c
        WHERE
          Contact__c = :loggedInUser.Contact.Id
          AND Product__c = :productId
          AND Type__c = 'Register Interest'
          AND Status__c = 'Active'
      ]
    );

    if (!existingInterest.isEmpty()) {
      AuraHandledException auraEx = new AuraHandledException(
        'Register Interest Exists'
      );
      throw auraEx;
    } else {
      Expression_of_Interest__c expressionOfInterest = new Expression_of_Interest__c(
        Contact__c = loggedInUser.Contact.Id,
        Product__c = productId,
        Type__c = 'Register Interest',
        Status__c = 'Active'
      );

      insert (expressionOfInterest);
    }
  }

  /**
   * @description wrapper that contains Product Details & Pricebook entries
   */
  public class ProductDetailsData {
    @AuraEnabled
    public Product2 productOnPage;
    @AuraEnabled
    public List<PricebookEntryWrapper> pricebookWrapperList;
    @AuraEnabled
    public List<DeliveryWrapper> deliveryWrapperList;
  }

  /**
   * @description wrapper that contains list of pricebook entries
   */
  public class PricebookEntryWrapper {
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String value;
    @AuraEnabled
    public String meta;
  }

  /**
   * @description wrapper that contains list of delivery options
   */
  public class DeliveryWrapper {
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String value;
  }

  /**
   * @description wrapper that contains list of Course Offerings
   */
  public class CourseOfferingWrapper {
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String value;
    @AuraEnabled
    public String meta;
    @AuraEnabled
    public String location;
    @AuraEnabled
    public List<facilitatorWrapper> facilitator;
  }

  /**
   * @description wrapper that contains the facilitator details
   */
  public class facilitatorWrapper {
    @AuraEnabled
    public String facilitatorName { get; set; }
    @AuraEnabled
    public String facilitatorBio { get; set; }
    @AuraEnabled
    public String facilitatorImage { get; set; }
  }

  /**
   * @description wrapper that contains the additional data needed to insert records
   */
  public class WrapperClass {
    @AuraEnabled
    public String courseOfferingId { get; set; }
  }
}
