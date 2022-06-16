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
      | marlon.vasquez            | May 04,2022           | DEPP-1531            | Added Questionnaire Form                   |
      | keno.domienri.dico        | April 29, 2022        | DEPP-2038            | Added Child products display               |
      | eugene.andrew.abuan       | May 10, 2022          | DEPP-1269            | Added isProgramFlex to match in prodCard   |
      | julie.jane.alegre         | May 24, 2022          | DEPP-2070            | Added logic for Group Booking              |
      | john.bo.a.pineda          | June 01, 2022         | DEPP-2853            | Updated Registration Dates Logic           |
      | john.bo.a.pineda          | June 16, 2022         | DEPP-3016            | Updated Logic for Prescribed Child Order   |
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
    List<childProduct> childProdWrapperList = new List<childProduct>();

    // Product
    Product2 productOnPage = [
      SELECT
        Id,
        Name,
        Description,
        StockKeepingUnit,
        Course__c,
        Course__r.ProductRequestID__c,
        Course__r.Minimum_Participants__c,
        Course__r.Maximum_Participants__c,
        Program_Plan__c,
        Program_Plan__r.Program_Delivery_Structure__c,
        Program_Plan__r.Minimum_Participants__c,
        Program_Plan__r.Maximum_Participants__c,
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
        ),
        Program_Plan__r.Product_Request__c
      FROM Product2
      WHERE Id = :productId
    ];

    //Modules under the program
    if (
      productOnPage.Program_Plan__r.Program_Delivery_Structure__c ==
      'Prescribed Program'
    ) {
      prodDetailsData.moduleWrapperList = getProgramModules(
        productOnPage.Program_Plan__c
      );
      prodDetailsData.programDeliveryAndOfferingMap = getProgramOfferings(
        productOnPage.Program_Plan__c
      );
    }

    // Pricebook Entries
    Map<String, PricebookEntry> pbEntryMap = new Map<String, PricebookEntry>();
    if (!productOnPage.PricebookEntries.isEmpty()) {
      for (PricebookEntry pricebookEntry : productOnPage.PricebookEntries) {
        pbEntryMap.put(pricebookEntry.Pricebook2.Name, pricebookEntry);
      }

      // If Free is configured, Only Free PriceBook will be displayed in Options
      if (pbEntryMap.containsKey('Free')) {
        pbEntryMap = new Map<String, PricebookEntry>{
          'Free' => (PricebookEntry) pbEntryMap.get('Free')
        };
      } else {
        // Remove Standard Price Book if Early Bird Price exists
        if (
          pbEntryMap.containsKey('Early Bird') &&
          pbEntryMap.containsKey('Standard Price Book')
        ) {
          pbEntryMap.remove('Standard Price Book');
        }
      }

      // Process PriceBookEntry Wrapper
      for (String pbEntryString : pbEntryMap.keySet()) {
        PricebookEntryWrapper pbEntryWrapper = new PricebookEntryWrapper();
        PricebookEntry pbEntry = pbEntryMap.get(pbEntryString);
        pbEntryWrapper.label = pbEntry.Pricebook2.Name;
        pbEntryWrapper.value = pbEntry.Id;
        pbEntryWrapper.meta = String.valueOf(pbEntry.UnitPrice);
        pbEntryWrapperList.add(pbEntryWrapper);
      }
    }

    // Set isNotFlexProgram to True
    prodDetailsData.isNotFlexProgram = true;

    // Single Product
    if (String.isBlank(productOnPage.Program_Plan__c)) {
      // Delivery Options
      if (String.isNotBlank(productOnPage.Delivery__c)) {
        // Course Offering counter for Delivery
        Map<String, Integer> deliveryCountMap = new Map<String, Integer>();
        List<AggregateResult> countList = [
          SELECT Count(Id) counter, Delivery_Type__c
          FROM hed__Course_Offering__c
          WHERE
            Registration_Start_Date__c <= TODAY
            AND (Registration_End_Date__c = NULL
            OR Registration_End_Date__c > TODAY)
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
    } else {
      // List Courses from Related Product Request
      Set<Id> courseIdSet = new Set<Id>();
      List<Related_Product_Request__c> relProdReqList = [
        SELECT Id, Name, Program__c, Course__c
        FROM Related_Product_Request__c
        WHERE Program__c = :productOnPage.Program_Plan__r.Product_Request__c
      ];
      for (Related_Product_Request__c relProdReq : relProdReqList) {
        courseIdSet.add(relProdReq.Course__c);
      }
      // Get Child Products
      List<Product2> childProdList = [
        SELECT
          Id,
          Name,
          Course__c,
          Duration__c,
          Delivery__c,
          Description,
          Professional_Level__c,
          (
            SELECT Id, Pricebook2.Name, UnitPrice
            FROM PricebookEntries
            WHERE IsActive = TRUE
            ORDER BY CreatedDate, Pricebook2.IsStandard DESC
          )
        FROM Product2
        WHERE Course__r.ProductRequestID__c IN :courseIdSet
      ];

      // Flexible-Program
      Map<Id, Date> cProdDateMap = new Map<Id, Date>();
      if (
        productOnPage.Program_Plan__r.Program_Delivery_Structure__c ==
        'Flexible Program'
      ) {
        // Set isNotFlexProgram to False
        prodDetailsData.isNotFlexProgram = false;

        // Map Child Product Earliest Course Offering Date
        List<AggregateResult> startDateList = [
          SELECT hed__Course__c, MIN(hed__Start_Date__c) startDate
          FROM hed__Course_Offering__c
          WHERE
            hed__Start_Date__c >= TODAY
            AND Registration_Start_Date__c <= TODAY
            AND (Registration_End_Date__c = NULL
            OR Registration_End_Date__c > TODAY)
            AND IsActive__c = TRUE
            AND Available_Seats__c > 0
            AND hed__Course__r.ProductRequestID__c IN :courseIdSet
          GROUP BY hed__Course__c
        ];
        for (AggregateResult startDate : startDateList) {
          cProdDateMap.put(
            (Id) startDate.get('hed__Course__c'),
            (Date) startDate.get('startDate')
          );
        }
      }

      // Process Child Products
      for (Product2 childProd : childProdList) {
        childProduct childProductWrapper = new childProduct();
        childProductWrapper.childProdId = childProd.Id;
        childProductWrapper.childProdName = childProd.Name;
        childProductWrapper.childProdProfLevel = childProd.Professional_Level__c;
        childProductWrapper.childProdDuration = childProd.Duration__c;
        childProductWrapper.childProdDescription = childProd.Description;
        childProductWrapper.isProgramFlex = false;
        if (
          productOnPage.Program_Plan__r.Program_Delivery_Structure__c ==
          'Flexible Program'
        ) {
          // Child Product Pricebook Entries
          Map<String, String> cProdPBEntryMap = new Map<String, String>();
          if (!childProd.PricebookEntries.isEmpty()) {
            for (
              PricebookEntry cProductPBookEntry : childProd.PricebookEntries
            ) {
              cProdPBEntryMap.put(
                cProductPBookEntry.Pricebook2.Name,
                String.valueOf(cProductPBookEntry.UnitPrice)
              );
            }
          }

          if (childProd.Delivery__c != null) {
            childProductWrapper.childProdDelivery = childProd.Delivery__c.replace(
              ';',
              ', '
            );
          }

          if (cProdDateMap.containsKey(childProd.Course__c)) {
            childProductWrapper.childProdOfferingDate = Datetime.newInstance(
                cProdDateMap.get(childProd.Course__c),
                Time.newInstance(0, 0, 0, 0)
              )
              .format('dd MMM yyyy');
          }

          if (cProdPBEntryMap.containsKey('Free')) {
            childProductWrapper.childProdPrice = cProdPBEntryMap.get('Free');
          } else {
            childProductWrapper.childProdPrice = cProdPBEntryMap.get(
              'Standard Price Book'
            );
            if (cProdPBEntryMap.containsKey('Early Bird')) {
              childProductWrapper.childProdPrice = cProdPBEntryMap.get(
                'Early Bird'
              );
            }
          }
        }
        childProdWrapperList.add(childProductWrapper);
      }
    }

    // Set values to wrapper
    prodDetailsData.productOnPage = productOnPage;
    prodDetailsData.pricebookWrapperList = pbEntryWrapperList;
    prodDetailsData.deliveryWrapperList = delivWrapperList;
    prodDetailsData.childProductList = childProdWrapperList;

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
          Registration_Start_Date__c <= TODAY
          AND (Registration_End_Date__c = NULL
          OR Registration_End_Date__c > TODAY)
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
    String programOfferingId,
    String pricebookEntryId,
    String userId
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
          AND OwnerId = :userId
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
      if (String.isNotBlank(courseOfferingId)) {
        cItem.Course_Offering__c = courseOfferingId;
      } else if (String.isNotBlank(programOfferingId)) {
        cItem.Program_Offering__c = programOfferingId;
      }
      cItem.Pricebook_Entry_ID__c = pricebookEntryId;
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

  /**
   * @description Inserts record to Expression of Intereset Object
   * @param userId - Current logged in User Id
   * @param productId - Product Id on productdetailpage
   */
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
   * @description
   * @param productRequestId -
   * @return qrList -
   */
  @AuraEnabled(cacheable=true)
  public static List<Related_Answer__c> getProductRequestWithQuestionnaire(
    String productRequestId
  ) {
    List<Related_Answer__c> qrList = [
      SELECT
        Id,
        Question__r.Type__c,
        Question__r.Label__c,
        Sequence__c,
        Questionnaire__r.Parent_Record_ID__c,
        Question__r.Acceptable_Response__c,
        Question__r.Message__c,
        Questionnaire__r.Questionnaire_Type__c,
        Question__r.Dropdown_Options__c
      FROM Related_Answer__c
      WHERE
        Questionnaire__r.Parent_Record_ID__c = :productRequestId
        AND Questionnaire__r.Questionnaire_Type__c = 'Application Questions'
      ORDER BY Questionnaire__r.Questionnaire_Type__c, Sequence__c
    ];
    return qrList;
  }

  /**
   * @description
   * @param productReqId -
   * @return relatedAnswersList -
   */

  @AuraEnabled(cacheable=true)
  public static List<Related_Answer__c> getQuestions(String productReqId) {
    List<Related_Answer__c> relatedAnswersList = new List<Related_Answer__c>(
      [
        SELECT
          Id,
          Question__r.Type__c,
          Question__r.Label__c,
          Sequence__c,
          Questionnaire__r.Parent_Record_ID__c,
          Question__r.Acceptable_Response__c,
          Question__r.Message__c,
          Questionnaire__r.Questionnaire_Type__c,
          Question__r.Dropdown_Options__c
        FROM Related_Answer__c
        WHERE
          Questionnaire__r.Parent_Record_ID__c = :productReqId
          AND Questionnaire__r.Questionnaire_Type__c = 'Application Questions'
        ORDER BY Questionnaire__r.Questionnaire_Type__c, Sequence__c
      ]
    );
    return relatedAnswersList;
  }

  /**
   * @description get list of contacts searched
   * @param contactRecord - contact to create
   * @param courseOfferingId - course offering id
   * @param relatedAnswerList - related answer records
   * @param answerList - answer records to be inserted
   * @param fileUpload - file to upload
   * @param forApplication - flag for checking if only for application
   */
  @AuraEnabled
  public static void addRegistration(
    Contact contactRecord,
    String courseOfferingId,
    List<Related_Answer__c> relatedAnswerList,
    List<Answer__c> answerList,
    String fileUpload,
    Boolean forApplication
  ) {
    List<FileUpload> parsedFileUpload = new List<FileUpload>();
    if (fileUpload != '') {
      parsedFileUpload = (List<FileUpload>) JSON.deserialize(
        fileUpload,
        List<FileUpload>.class
      );
    }

    List<Questionnaire_Response_Summary__c> questionnaireSummaryToInsert = new List<Questionnaire_Response_Summary__c>();
    Map<String, String> cvToRelatedAnswerMap = new Map<String, String>();
    List<ContentDocumentLink> contentDocLinkListToInsert = new List<ContentDocumentLink>();
    List<ContentVersion> cvListToInsertList = new List<ContentVersion>();
    Map<Id, Id> relatedAnswerToQuestionnaireMap = new Map<Id, Id>();
    Map<Id, Id> questionnaireToqResSummaryMap = new Map<Id, Id>();
    Map<Id, Id> relatedAnswerToAnswerMap = new Map<Id, Id>();
    Set<Id> questionnaireIds = new Set<Id>();

    List<Answer__c> answersToInsert = new List<Answer__c>();
    Map<Id, Answer__c> answersToUpdate = new Map<Id, Answer__c>();

    if (contactRecord.Id == null) {
      insert contactRecord;
    }

    for (Related_Answer__c relatedA : relatedAnswerList) {
      questionnaireIds.add(relatedA.Questionnaire__c);
      relatedAnswerToQuestionnaireMap.put(
        relatedA.Id,
        relatedA.Questionnaire__c
      );
    }

    Questionnaire_Response_Summary__c qResSummary;

    for (Id qId : questionnaireIds) {
      qResSummary = new Questionnaire_Response_Summary__c();
      qResSummary.Questionnaire__c = qId;
      qResSummary.Course_Offering__c = courseOfferingId;
      qResSummary.Contact__c = contactRecord.Id;
      if (forApplication == true) {
        qResSummary.Application_Status__c = 'Pending';
      }
      questionnaireSummaryToInsert.add(qResSummary);
    }

    if (!questionnaireSummaryToInsert.isEmpty()) {
      insert questionnaireSummaryToInsert;
    }

    for (
      Questionnaire_Response_Summary__c questionResSummary : questionnaireSummaryToInsert
    ) {
      questionnaireToqResSummaryMap.put(
        questionResSummary.Questionnaire__c,
        questionResSummary.Id
      );
    }

    if (!answerList.isEmpty()) {
      for (Answer__c a : answerList) {
        a.Questionnaire_Response_Summary__c = questionnaireToqResSummaryMap.get(
          relatedAnswerToQuestionnaireMap.get(a.Related_Answer__c)
        );
        answersToInsert.add(a);
      }
      insert answersToInsert;
    }

    for (Answer__c ans : answersToInsert) {
      relatedAnswerToAnswerMap.put(ans.Related_Answer__c, ans.Id);
    }

    for (FileUpload file : parsedFileUpload) {
      if (relatedAnswerToAnswerMap.containsKey(file.RelatedAnswerId)) {
        ContentVersion cv = createContentVersion(file.Base64, file.FileName);
        cvToRelatedAnswerMap.put(cv.Title, file.RelatedAnswerId);
        cvListToInsertList.add(cv);
      }
    }

    if (!cvListToInsertList.isEmpty()) {
      insert cvListToInsertList;
    }

    List<ContentVersion> newContentVersionList = new List<ContentVersion>(
      [
        SELECT ContentDocumentId, Title
        FROM ContentVersion
        WHERE Id IN :cvListToInsertList
      ]
    );

    if (!newContentVersionList.isEmpty()) {
      ContentDocumentLink cdl;
      Answer__c updateAnswer;
      for (ContentVersion cv : newContentVersionList) {
        String test = relatedAnswerToAnswerMap.get(
          cvToRelatedAnswerMap.get(cv.Title)
        );
        cdl = new ContentDocumentLink(
          ContentDocumentId = cv.ContentDocumentId,
          LinkedEntityId = relatedAnswerToAnswerMap.get(
            cvToRelatedAnswerMap.get(cv.Title)
          ),
          ShareType = 'V'
        );
        updateAnswer = new Answer__c(
          Id = cdl.LinkedEntityId,
          Response__c = cv.ContentDocumentId
        );
        answersToUpdate.put(updateAnswer.Id, updateAnswer);
        contentDocLinkListToInsert.add(cdl);
      }
    }

    if (!contentDocLinkListToInsert.isEmpty()) {
      insert contentDocLinkListToInsert;
    }

    if (!answersToUpdate.keySet().isEmpty()) {
      update answersToUpdate.values();
    }

    if (!forApplication) {
      hed__Course_Enrollment__c newCourseConnection = new hed__Course_Enrollment__c(
        hed__Course_Offering__c = courseOfferingId,
        hed__Contact__c = contactRecord.Id,
        RecordTypeId = STUDENT_RECTYPEID,
        hed__Status__c = 'Active'
      );
      insert newCourseConnection;
    }
  }

  @AuraEnabled
  public static void saveApplication(
    String contactId,
    String offeringId,
    List<Related_Answer__c> relatedAnswerList,
    List<Answer__c> answerList,
    String fileUpload,
    Boolean isPrescribed,
    String pricebookEntryId
  ) {
    List<FileUpload> parsedFileUpload = new List<FileUpload>();
    if (fileUpload != '') {
      parsedFileUpload = (List<FileUpload>) JSON.deserialize(
        fileUpload,
        List<FileUpload>.class
      );
    }

    List<Questionnaire_Response_Summary__c> questionnaireSummaryToInsert = new List<Questionnaire_Response_Summary__c>();
    Map<String, String> cvToRelatedAnswerMap = new Map<String, String>();
    List<ContentDocumentLink> contentDocLinkListToInsert = new List<ContentDocumentLink>();
    List<ContentVersion> cvListToInsertList = new List<ContentVersion>();
    Map<Id, Id> relatedAnswerToQuestionnaireMap = new Map<Id, Id>();
    Map<Id, Id> questionnaireToqResSummaryMap = new Map<Id, Id>();
    Map<Id, Id> relatedAnswerToAnswerMap = new Map<Id, Id>();
    Set<Id> questionnaireIds = new Set<Id>();

    List<Answer__c> answersToInsert = new List<Answer__c>();
    Map<Id, Answer__c> answersToUpdate = new Map<Id, Answer__c>();

    for (Related_Answer__c relatedA : relatedAnswerList) {
      questionnaireIds.add(relatedA.Questionnaire__c);
      relatedAnswerToQuestionnaireMap.put(
        relatedA.Id,
        relatedA.Questionnaire__c
      );
    }

    Questionnaire_Response_Summary__c qResSummary;

    for (Id qId : questionnaireIds) {
      qResSummary = new Questionnaire_Response_Summary__c();
      qResSummary.Questionnaire__c = qId;
      if (isPrescribed) {
        qResSummary.Program_Offering__c = offeringId;
      } else {
        qResSummary.Course_Offering__c = offeringId;
      }
      qResSummary.Contact__c = contactId;
      qResSummary.Application_Status__c = 'Pending';
      qResSummary.Pricebook_Entry_ID__c = pricebookEntryId;
      questionnaireSummaryToInsert.add(qResSummary);
    }

    if (!questionnaireSummaryToInsert.isEmpty()) {
      insert questionnaireSummaryToInsert;
    }

    for (
      Questionnaire_Response_Summary__c questionResSummary : questionnaireSummaryToInsert
    ) {
      questionnaireToqResSummaryMap.put(
        questionResSummary.Questionnaire__c,
        questionResSummary.Id
      );
    }

    if (!answerList.isEmpty()) {
      for (Answer__c a : answerList) {
        a.Questionnaire_Response_Summary__c = questionnaireToqResSummaryMap.get(
          relatedAnswerToQuestionnaireMap.get(a.Related_Answer__c)
        );
        answersToInsert.add(a);
      }
      insert answersToInsert;
    }

    for (Answer__c ans : answersToInsert) {
      relatedAnswerToAnswerMap.put(ans.Related_Answer__c, ans.Id);
    }

    for (FileUpload file : parsedFileUpload) {
      if (relatedAnswerToAnswerMap.containsKey(file.RelatedAnswerId)) {
        ContentVersion cv = createContentVersion(file.Base64, file.FileName);
        cvToRelatedAnswerMap.put(cv.Title, file.RelatedAnswerId);
        cvListToInsertList.add(cv);
      }
    }

    if (!cvListToInsertList.isEmpty()) {
      insert cvListToInsertList;
    }

    List<ContentVersion> newContentVersionList = new List<ContentVersion>(
      [
        SELECT ContentDocumentId, Title
        FROM ContentVersion
        WHERE Id IN :cvListToInsertList
      ]
    );

    if (!newContentVersionList.isEmpty()) {
      ContentDocumentLink cdl;
      Answer__c updateAnswer;
      for (ContentVersion cv : newContentVersionList) {
        String test = relatedAnswerToAnswerMap.get(
          cvToRelatedAnswerMap.get(cv.Title)
        );
        cdl = new ContentDocumentLink(
          ContentDocumentId = cv.ContentDocumentId,
          LinkedEntityId = relatedAnswerToAnswerMap.get(
            cvToRelatedAnswerMap.get(cv.Title)
          ),
          ShareType = 'V'
        );
        updateAnswer = new Answer__c(
          Id = cdl.LinkedEntityId,
          Response__c = cv.ContentDocumentId
        );
        answersToUpdate.put(updateAnswer.Id, updateAnswer);
        contentDocLinkListToInsert.add(cdl);
      }
    }

    if (!contentDocLinkListToInsert.isEmpty()) {
      insert contentDocLinkListToInsert;
    }

    if (!answersToUpdate.keySet().isEmpty()) {
      update answersToUpdate.values();
    }
  }
  /**
   * @description
   * @param base64 -
   * @param filename -
   * @return cv -
   */
  private static ContentVersion createContentVersion(
    String base64,
    String filename
  ) {
    ContentVersion cv = new ContentVersion();
    cv.VersionData = EncodingUtil.base64Decode(base64);
    cv.Title = filename;
    cv.PathOnClient = filename;
    return cv;
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
    @AuraEnabled
    public List<ModuleWrapper> moduleWrapperList;
    @AuraEnabled
    public Map<String, List<ProgramOfferingWrapper>> programDeliveryAndOfferingMap;
    @AuraEnabled
    public Boolean isNotFlexProgram;
    @AuraEnabled
    public List<childProduct> childProductList;
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
   * @description Wrapper class that holds the file uploaded by user
   */
  public class FileUpload {
    @AuraEnabled
    public String Base64;
    @AuraEnabled
    public String FileName;
    @AuraEnabled
    public String RelatedAnswerId;
  }

  /**
   * @description wrapper that contains the facilitator details
   */
  public class childProduct {
    @AuraEnabled
    public String childProdId { get; set; }
    @AuraEnabled
    public String childProdName { get; set; }
    @AuraEnabled
    public String childProdDescription { get; set; }
    @AuraEnabled
    public String childProdProfLevel { get; set; }
    @AuraEnabled
    public String childProdOfferingDate { get; set; }
    @AuraEnabled
    public String childProdDelivery { get; set; }
    @AuraEnabled
    public String childProdPrice { get; set; }
    @AuraEnabled
    public String childProdDuration { get; set; }
    @AuraEnabled
    public Boolean isProgramFlex { get; set; }
  }

  /**
   * @description wrapper that contains the additional data needed to insert records
   */
  public class WrapperClass {
    @AuraEnabled
    public String courseOfferingId { get; set; }
  }

  @AuraEnabled(cacheable=true)
  public static List<ModuleWrapper> getProgramModules(String programPlanId) {
    List<ModuleWrapper> modules = new List<ModuleWrapper>();
    try {
      List<hed__Plan_Requirement__c> programPlanRequirements = [
        SELECT Id, hed__Course__c, hed__Sequence__c
        FROM hed__Plan_Requirement__c
        WHERE hed__Program_Plan__c = :programPlanId
        ORDER BY hed__Sequence__c
      ];
      Map<Decimal, Id> coursesInPlanRequirements = new Map<Decimal, Id>();
      System.debug('programPlanRequirements: ' + programPlanRequirements);
      for (
        hed__Plan_Requirement__c programPlanRequirement : programPlanRequirements
      ) {
        coursesInPlanRequirements.put(
          programPlanRequirement.hed__Sequence__c,
          programPlanRequirement.hed__Course__c
        );
      }
      System.debug('coursesInPlanRequirements: ' + coursesInPlanRequirements);
      List<Product2> courseProducts = [
        SELECT
          Id,
          Name,
          Duration__c,
          Delivery__c,
          Overview__c,
          Professional_Level__c,
          Course__c,
          Evolve_with_QUTeX__c,
          Who_Should_Participate__c,
          Core_Concepts__c,
          More_Details__c
        FROM Product2
        WHERE Course__c IN :coursesInPlanRequirements.values()
      ];
      Map<Id, Product2> courseProductsMap = new Map<Id, Product2>();
      for (Product2 prod2 : courseProducts) {
        courseProductsMap.put(prod2.Course__c, prod2);
      }
      for (Decimal courseOrder : coursesInPlanRequirements.keySet()) {
        Id courseProductId = (Id) coursesInPlanRequirements.get(courseOrder);
        Product2 courseProduct = (Product2) courseProductsMap.get(
          courseProductId
        );
        ModuleWrapper moduleWrapper = new ModuleWrapper();
        moduleWrapper.id = courseProduct.Id;
        moduleWrapper.name = courseProduct.Name;
        moduleWrapper.duration = courseProduct.Duration__c;
        moduleWrapper.overview = courseProduct.Overview__c;
        moduleWrapper.professionalLevel = courseProduct.Professional_Level__c;
        moduleWrapper.evolveWithQUTeX = courseProduct.Evolve_with_QUTeX__c;
        moduleWrapper.whoShouldParticipate = courseProduct.Who_Should_Participate__c;
        moduleWrapper.coreConcepts = courseProduct.Core_Concepts__c;
        moduleWrapper.sequence = courseOrder;
        moduleWrapper.moreDetails = courseProduct.More_Details__c;
        modules.add(moduleWrapper);
      }
      System.debug('modules: ' + modules);
      return modules;
    } catch (Exception e) {
      system.debug(e);
      system.debug('Error on ProductDetailsCtrl.getProgramModules');
      AuraHandledException auraEx = new AuraHandledException(e.getMessage());
      throw auraEx;
    }
  }

  @AuraEnabled(cacheable=true)
  public static Map<String, List<ProgramOfferingWrapper>> getProgramOfferings(
    String programPlanId
  ) {
    Map<String, List<ProgramOfferingWrapper>> programDeliveryAndOfferingMap = new Map<String, List<ProgramOfferingWrapper>>();
    try {
      List<Program_Offering__c> programOfferings = [
        SELECT
          Id,
          Available_Seats__c,
          Delivery_Type__c,
          Start_Date__c,
          End_Date__c,
          IsActive__c
        FROM Program_Offering__c
        WHERE
          hed_Program_Plan__c = :programPlanId
          AND IsActive__c = TRUE
          AND Available_Seats__c > 0
          AND Registration_Start_Date__c <= TODAY
          AND (Registration_End_Date__c = NULL
          OR Registration_End_Date__c > TODAY)
      ];
      System.debug('programOfferings: ' + programOfferings);
      for (Program_Offering__c programOffering : programOfferings) {
        ProgramOfferingWrapper programOfferingWrapper = new ProgramOfferingWrapper();
        programOfferingWrapper.id = programOffering.Id;
        programOfferingWrapper.startDate = Datetime.newInstance(
            programOffering.Start_Date__c,
            Time.newInstance(0, 0, 0, 0)
          )
          .format('dd MMM yyyy');
        programOfferingWrapper.availableSeats = programOffering.Available_Seats__c;
        List<ProgramOfferingWrapper> programOfferingWrapperList = new List<ProgramOfferingWrapper>();
        if (
          programDeliveryAndOfferingMap.get(programOffering.Delivery_Type__c) !=
          null
        ) {
          programOfferingWrapperList = programDeliveryAndOfferingMap.get(
            programOffering.Delivery_Type__c
          );
        }
        programOfferingWrapperList.add(programOfferingWrapper);
        programDeliveryAndOfferingMap.put(
          programOffering.Delivery_Type__c,
          programOfferingWrapperList
        );
      }
      System.debug(
        'programDeliveryAndOfferingMap: ' + programDeliveryAndOfferingMap
      );
      return programDeliveryAndOfferingMap;
    } catch (Exception e) {
      system.debug(e);
      system.debug('Error on ProductDetailsCtrl.getProgramOfferings');
      AuraHandledException auraEx = new AuraHandledException(e.getMessage());
      throw auraEx;
    }
  }

  /**
   * @description wrapper that contains the details of a module
   */
  public class ModuleWrapper {
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String name { get; set; }
    @AuraEnabled
    public String duration { get; set; }
    @AuraEnabled
    public String overview { get; set; }
    @AuraEnabled
    public String professionalLevel { get; set; }
    @AuraEnabled
    public Decimal sequence { get; set; }
    @AuraEnabled
    public String evolveWithQUTeX { get; set; }
    @AuraEnabled
    public String whoShouldParticipate { get; set; }
    @AuraEnabled
    public String coreConcepts { get; set; }
    @AuraEnabled
    public String moreDetails { get; set; }
  }

  public class ProgramOfferingWrapper {
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String startDate { get; set; }
    @AuraEnabled
    public Decimal availableSeats { get; set; }
    @AuraEnabled
    public String label { get; set; }
    @AuraEnabled
    public String value { get; set; }
    @AuraEnabled
    public String meta { get; set; }
  }

  @AuraEnabled(cacheable=true)
  public static Map<String, Object> getProductDataRelatedToProductRequest(
    String productRequestId
  ) {
    System.debug('productRequestId: ' + productRequestId);
    Map<String, Object> returnMap = new Map<String, Object>();
    String productType = '';
    Id productId;
    List<Product2> products;
    ProductDetailsData prodDetailsData;
    List<hed__Program_Plan__c> programPlans = [
      SELECT Id, Name, Product_Request__c, Program_Delivery_Structure__c
      FROM hed__Program_Plan__c
      WHERE Product_Request__c = :productRequestId
    ];
    if (programPlans.size() > 0) {
      System.debug('Product is a program');
      products = [
        SELECT
          Id,
          Name,
          Program_Plan__c,
          Program_Plan__r.Program_Delivery_Structure__c
        FROM Product2
        WHERE Program_Plan__c = :programPlans[0].Id
      ];
      if (products.size() > 0) {
        if (
          programPlans[0].Program_Delivery_Structure__c == 'Prescribed Program'
        ) {
          productType = 'Prescribed Program';
          //Call getProductRelatedRecords(productId);
          prodDetailsData = getProductRelatedRecords(products[0].Id);
          System.debug('prodDetailsData: ' + prodDetailsData);
          returnMap.put('product', prodDetailsData);
        } else if (
          programPlans[0].Program_Delivery_Structure__c == 'Flexible Program'
        ) {
          productType = 'Flexible Program';
          //Call getProductRelatedRecords(productId);
          System.debug('productId: ' + productId);
          prodDetailsData = getProductRelatedRecords(products[0].Id);
          System.debug('prodDetailsData: ' + prodDetailsData);
          returnMap.put('product', prodDetailsData);
        }
      }
    } else {
      System.debug('Product is a Course');
      List<hed__Course__c> courses = [
        SELECT
          Id,
          Name,
          ProductRequestID__c,
          ProductRequestID__r.Child_of_Prescribed_Program__c
        FROM hed__Course__c
        WHERE ProductRequestID__c = :productRequestId
      ];
      if (courses.size() > 0) {
        products = [
          SELECT Id, Name
          FROM Product2
          WHERE Course__c = :courses[0].Id
        ];
        productId = products[0].Id;
        if (
          courses[0].ProductRequestID__r.Child_of_Prescribed_Program__c == true
        ) {
          productType = 'Prescribed Program Module';
          List<hed__Plan_Requirement__c> programPlanRequirements = [
            SELECT Id, hed__Course__c, hed__Sequence__c, hed__Program_Plan__c
            FROM hed__Plan_Requirement__c
            WHERE hed__Course__c = :courses[0].Id
          ];
          Id programPlanId = programPlanRequirements[0].hed__Program_Plan__c;
          Id parentProductId = [
            SELECT Id
            FROM Product2
            WHERE Program_Plan__c = :programPlanId
          ]
          .Id;
          System.debug('parentProductId: ' + parentProductId);
          //Call getProductRelatedRecords(productId);
          prodDetailsData = getProductRelatedRecords(parentProductId);
          List<ModuleWrapper> modules = prodDetailsData.moduleWrapperList;
          System.debug('modules: ' + modules);
          for (ModuleWrapper module : modules) {
            System.debug('module: ' + module);
            if (module.id == productId) {
              returnMap.put('product', module);
              break;
            }
          }
          System.debug('prodDetailsData: ' + prodDetailsData);
          returnMap.put('parent', prodDetailsData);
        } else {
          productType = 'Single Product';
          //Call getProductRelatedRecords(productId);
          prodDetailsData = getProductRelatedRecords(productId);
          System.debug('prodDetailsData: ' + prodDetailsData);
          returnMap.put('product', prodDetailsData);
        }
      }
    }
    returnMap.put('productType', productType);
    returnMap.put('productId', productId);
    System.debug('returnMap: ' + returnMap);
    return returnMap;
  }

  @AuraEnabled(cacheable=true)
  public static List<Related_Answer__c> getQuestionsForGroupBooking(
    String productReqId
  ) {
    List<Related_Answer__c> relatedAnswersList = new List<Related_Answer__c>(
      [
        SELECT
          Id,
          Question__r.Type__c,
          Question__r.Label__c,
          Sequence__c,
          Questionnaire__r.Parent_Record_ID__c,
          Question__r.Acceptable_Response__c,
          Question__r.Message__c,
          Questionnaire__r.Questionnaire_Type__c,
          Question__r.Dropdown_Options__c
        FROM Related_Answer__c
        WHERE
          Questionnaire__r.Parent_Record_ID__c = :productReqId
          AND Questionnaire__r.Questionnaire_Type__c = 'Registration Questions'
        ORDER BY Questionnaire__r.Questionnaire_Type__c, Sequence__c
      ]
    );
    return relatedAnswersList;
  }

  @AuraEnabled
  public static List<Contact> saveContactData(String contactDataString) {
    List<Contact> contactList = (List<Contact>) System.JSON.deserializeStrict(
      contactDataString,
      List<Contact>.class
    );
    Database.insert(contactList);
    return contactList;
  }
  @AuraEnabled
  public static List<Contact> getContactAccountId(Id connId) {
    return [
      SELECT Id, FirstName, LastName, Account.Name, Account.Id
      FROM Contact
      WHERE Id = :connId
    ];
  }
  @AuraEnabled
  public static List<Contact> getUserContactDetails(Id connId) {
    return [
      SELECT Id, FirstName, LastName, Email
      FROM Contact
      WHERE Id = :connId
    ];
  }

  @AuraEnabled
  public static WebCart getUserCartDetails(Id userId) {
    return [
      SELECT
        Id,
        OwnerId,
        Name,
        WebStoreId,
        AccountId,
        External_Id__c,
        Amount_Paid__c
      FROM WebCart
      WHERE OwnerId = :userId
      LIMIT 1
    ];
  }

  @AuraEnabled
  public static PricebookEntry getPricebookEntryPrice(Id pricebookId) {
    return [
      SELECT Id, Name, Pricebook2Id, Product2Id, UnitPrice
      FROM PricebookEntry
      WHERE Id = :pricebookId
      LIMIT 1
    ];
  }
}
