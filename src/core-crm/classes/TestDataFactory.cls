/**
 * @description Test class that contains reusable method for test data creation
 *
 * @author Accenture
 *
* @history
*     | Developer                 | Date                  | JIRA                | Change Summary                                                   |
      |---------------------------|-----------------------|---------------------|------------------------------------------------------------------|
      | roy.nino.s.regala         | September 3, 2021     | DEP1-169,170        | Created file                                                     |
      | angelika.j.s.galang       | September 3, 2021     | DEP1-156            | Added comments & method for creating user and getting profile id |
      | angelika.j.s.galang       | September 16, 2021    | DEP1-22             | Added method for creating Opportunity                            |
      | roy.nino.s.regala         | October 4,2021        | DEPP-40,42          | Added method for Product Request and Product Specification       |
      | adrian.c.habasa           | October 18,2021       | DEPP-476,425,383    | Added method for Course, Products,Course Offerings and Terms     |
      | roy.nino.s.regala         | November 3, 2021      | DEPP-736            | Added nethod for Opportunity Contact Roles                       |
      | adrian.c.habasa           | November 11,2021      | DEPP-664            | Added method for Asset                                           |
      | eccarius.karl.munoz       | November 25,2021      | DEPP-671            | Added method for creation of Products without related Course     |
      | eugene.andrew.abuan       | December 1,2021       | DEPP-771            | Added method for creation of Community User                      |
      | roy.nino.s.regala         | November 25,2021      | DEPP-362,38,37      | Added method for creation of Program Plan                        |
      | john.bo.a.pineda          | December 6, 2021      | DEPP-789            | Added method for creation of Course Connection                   |
      | eugene.andrew.abuan       | December 10, 2021     | DEPP-100            | Added method for Buyer Account                                   |
      | marygrace.li@qut.edu.au   | December 13, 2021     | DEPP-174            | Added method creation of Acct,Contact,ByrGrp,ByrGrpMber,Product2 |
      | roy.nino.s.regala         | December 15, 2021     | DEPP-116            | Added Start date on course offerings                             |
      | john.bo.a.pineda          | December 21, 2021     | DEPP-1150           | Added method for creation of Pending Registration                |
      | john.bo.a.pineda          | January 05, 2022      | DEPP-1382           | Added method for creation of Program Offering                    |
      | arsenio.dayrit@qut.edu.au | January 12, 2022      | DEPP-1359           | Added method for creation of Product Ledger                      |
      | adrian.c.habasa           | January 21, 2022      | DEPP-1463           | Added method for creation of Credential                          |
      | angelika.j.s.galang       | January 25, 2022      | DEPP-1396           | Added method for creation of Questionnaire, Question, and Answer |
      | roy.nino.s.regala         | February 03, 2022     | DEPP-213            | Added nethod for creation of Expression of Interest              |
      | john.bo.a.pineda          | February 03, 2022     | DEPP-1396           | Updated method for Answer to Related Answer                      |
      | arsenio.jr.dayrit         | February 14, 2022     | DEPP-1538           | Added method for creation of Questionnaire response summary      |
      | adrian.c.habasa           | February 14, 2022     | DEPP-1247           | Added method for Session and Attendance Event                    |
      | eugene.andrew.abuan       | February 16, 2022     | DEPP-1265           | Added method for Creating Courses                                |
      | keno.domienri.dico        | April 11, 2022        | DEPP-1543           | Added method for Creating Communication Schedule                 |
      |                           |                       |                     |                                                                  |
*/
@IsTest
public class TestDataFactory {
  private static final String STR_QUALIFY = 'Qualify';
  private static final String STR_IN_PROGRESS = 'In Progress';
  private static final String STR_QUESTIONNAIRE_TYPE = 'Registration Criteria';
  private static final String TEST_BUYER_GROUP = 'Test Buyer Group';
  private static final String TEST_BUYER_ACCT = 'Test Buyer Account';
  private static final String TEST_ACCOUNT_NAME = 'Test Account';

  /**
   * @description Method for creating test Account records
   * @param numAccts - number of Accounts to be created
   * @return accts - list of Accounts created
   */
  public static List<Account> createTestAccountRecords(Integer numAccts) {
    List<Account> accts = new List<Account>();

    for (Integer i = 0; i < numAccts; i++) {
      accts.add(new Account(Name = 'TestAccount' + i));
    }

    return accts;
  }

  /**
   * @description Method for creating test Contact records
   * @param numContacts - number of Contacts to be created
   * @return cons - list of Contacts created
   */
  public static List<Contact> createTestContactRecords(Integer numContacts) {
    List<Contact> cons = new List<Contact>();

    for (Integer i = 0; i < numContacts; i++) {
      cons.add(new Contact(FirstName = 'Test' + i, LastName = 'Contact' + i));
    }

    return cons;
  }

  /**
   * @description Method for creating test Lead records
   * @param numLeads - number of Leads to be created
   * @return leads - list of Leads created
   */
  public static List<Lead> createTestLeadRecords(Integer numLeads) {
    List<Lead> leads = new List<Lead>();

    for (Integer i = 0; i < numLeads; i++) {
      leads.add(
        new Lead(
          FirstName = 'TestFirstNameLead' + i,
          LastName = 'TestLastNameLead' + i,
          Company = 'TestCompany' + i,
          Phone = '1234567' + i,
          City = 'TestCity' + i,
          MobilePhone = '1234567' + i
        )
      );
    }

    return leads;
  }

    /**
   * @description Method for creating test Individual records
   * @param numIndividuals - number of Individuals to be created
   * @return individuals - list of Individuals created
   */
  public static List<Individual> createTestIndividualRecords(Integer numIndividuals) {
    List<Individual> individuals = new List<Individual>();

    for (Integer i = 0; i < numIndividuals; i++) {
      individuals.add(
        new Individual(
          LastName = 'TestLastName' + i
        )
      );
    }

    return individuals;
  }

  /**
   * @description Method for creating test Opportunity records
   * @param numOpps - number of Opportunities to be created
   * @param accId - Id of related Account
   * @param conId - Id of related Contact for roles
   * @return opps - list of Opportunities created
   */
  public static List<Opportunity> createTestOpportunityRecords(
    Integer numOpps,
    Id accId,
    Id conId
  ) {
    List<Opportunity> opps = new List<Opportunity>();

    for (Integer i = 0; i < numOpps; i++) {
      opps.add(
        new Opportunity(
          Name = 'TestOpportunity' + i,
          AccountId = accId,
          Contact__c = conId,
          StageName = STR_QUALIFY,
          Status__c = STR_IN_PROGRESS,
          CloseDate = System.today() + 30
        )
      );
    }

    return opps;
  }

  /**
   * @description Method for creating test Hed Address records
   * @param numAddresses - number of Hed Addresses to be created
   * @param addressType - type of address
   * @param parentId - id of parent address
   * @param lookupApiName - api name of object lookup
   * @return addresses - list of Hed Addresses created
   */
  public static List<hed__Address__c> createTestHedAddressRecords(
    Integer numAddresses,
    String addressType,
    String parentId,
    String lookupApiName
  ) {
    List<hed__Address__c> addresses = new List<hed__Address__c>();

    for (Integer i = 0; i < numAddresses; i++) {
      hed__Address__c add = new hed__Address__c();
      add.put(lookupApiName, parentId);
      add.put('hed__Address_Type__c', addressType);
      addresses.add(add);
    }

    return addresses;
  }

  /**
   * @description Method for creating test Product Request records
   * @param numProductRequest number of product request
   * @param prodSpecId list of product specification
   * @return prodRequest - list of product requests
   */
  public static List<Product_Request__c> createTestProductRequestRecords(
    Integer numProductRequest,
    Id prodSpecId
  ) {
    List<Product_Request__c> prodRequest = new List<Product_Request__c>();

    for (Integer i = 0; i < numProductRequest; i++) {
      Product_Request__c pr = new Product_Request__c();
      pr.Product_Request_Name__c = 'TEST PR ' + i;
      pr.Product_Specification__c = prodSpecId;
      prodRequest.add(pr);
    }

    return prodRequest;
  }

  /**
   * @description Method for creating test Product Specification records
   * @param numProductSpecs number of product specification
   * @param contacts list of related contacts
   * @param ops list of related opportunities
   * @return productSpecifications - list of product specifications
   */
  public static List<Product_Specification__c> createTestProductSpecsRecords(
    Integer numProductSpecs,
    List<Contact> contacts,
    List<Opportunity> ops
  ) {
    List<Product_Specification__c> productSpecifications = new List<Product_Specification__c>();

    for (Integer i = 0; i < numProductSpecs; i++) {
      Product_Specification__c ps = new Product_Specification__c();
      ps.Program_Name__c = 'TEST PS ' + i;
      ps.Program_Lead__c = contacts[i].id;
      ps.Opportunity_Name__c = ops[i].id;
      ps.Stage__c = 'Define';
      ps.Client_Review_Required__c = 'N/A';
      ps.Requestor_Name__c =  contacts[i].id;
      productSpecifications.add(ps);
    }

    return productSpecifications;
  }

  /**
   * @description Method for creating test Course records
   * @param numCourses - number of Courses to be created
   * @param accId - id of related account
   * @param prodReqId - id of related product request
   * @return courses - list of Courses created
   */
  public static List<hed__Course__c> createTestCourseRecords(
    Integer numCourses,
    Id accId,
    Id prodReqId
  ) {
    List<hed__Course__c> courses = new List<hed__Course__c>();

    for (Integer i = 0; i < numCourses; i++) {
      courses.add(
        new hed__Course__c(
          Name = 'Test Course ' + i,
          hed__Account__c = accId,
          ProductRequestID__c = prodReqId,
          Delivery_Type__c = 'Face to Face',
          Location_Details__c = 'test',
          Description__c = 'test',
          Certificate_Type__c = 'Certificate of Achievement',
          Collaboration_with_External_Organisation__c = 'Yes',
          External_Organisation__c = 'test',
          Content__c = 'test',
          Resource_Details__c = 'test',
          Minimum_Participants__c = 1,
          Maximum_Participants__c = 100,
          Delivery_Support_v2__c = 'Others',
          Delivery_Comments__c = 'test',
          Core_Conceptsv2__c = 'test',
          Overviewv2__c = 'test',
          Owning_Faculty__c = accId
        )
      );
    }

    return courses;
  }

  /**
   * @description Method for creating test User records
   * @param numUsers - number of Users to be created
   * @param profileName - profile name of Users to be created
   * @return users - list of Users created
   */
  public static List<User> createUserRecords(
    Integer numUsers,
    String profileName
  ) {
    List<User> users = new List<User>();
    Id userProfileId = getProfileId(profileName);
    for (Integer i = 0; i < numUsers; i++) {
      users.add(
        new User(
          Alias = 'tuser',
          Email = 'testuser@mailinator.com',
          EmailEncodingKey = 'UTF-8',
          LastName = 'TestUser',
          LanguageLocaleKey = 'en_US',
          LocaleSidKey = 'en_AU',
          ProfileId = userProfileId,
          TimeZoneSidKey = 'Australia/Sydney',
          UserName = 'TestUser.' + i + '@mailinator.com'
        )
      );
    }

    return users;
  }

  /**
   * @description Method for creating test User records
   * @param numUsers - number of Users to be created
   * @param profileName - profile name of Users to be created
   * @return users - list of Users created
   */
  public static List<User> createPortalUserRecords(
    Integer numUsers,
    String profileName,
    Id contactId
  ) {
    List<User> users = new List<User>();
    Id userProfileId = getProfileId(profileName);
    for (Integer i = 0; i < numUsers; i++) {
      users.add(
        new User(
          Alias = 'puser',
          Email = 'testPortaluser@mailinator.com',
          EmailEncodingKey = 'UTF-8',
          LastName = 'TestPortalUser',
          ContactId = contactId,
          LanguageLocaleKey = 'en_US',
          LocaleSidKey = 'en_AU',
          ProfileId = userProfileId,
          TimeZoneSidKey = 'Australia/Sydney',
          UserName = 'TestPortalUser.' + i + '@mailinator.com'
        )
      );
    }

    return users;
  }

  /**
   * @description Method for getting the Profile ID
   * @param profileName - name of the profile
   * @return ID of the profile
   */
  private static Id getProfileId(String profileName) {
    return [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1]?.Id;
  }

  /**
   * @description Method for getting the Account ID
   * @return ID of the Account
   */
  public static string getAccountId() {
    Account account = new Account();
    account.Name = 'TestAccount1';

    insert (account);

    return account.Id;
  }

  /**
   * @description Method for creating Product Record
   * @param numProd - number of products to be created
   * @param cour - courses to be related to product
   * @return productRecord - List of Products Created
   */
  public static List<Product2> createTestProductRecords(
    Integer numProd,
    List<hed__Course__c> cour
  ) {
    List<Product2> productRecord = new List<Product2>();
    for (Integer i = 0; i < numProd; i++) {
      productRecord.add(
        new Product2(Name = 'Test Product' + i, Course__c = cour[i].id)
      );
    }
    return productRecord;
  }

  /**
   * @description Method for creating Product Record without related course
   * @param numProd - number of products to be created
   * @return productRecord - List of Products Created
   */
  public static List<Product2> createTestProductRecords(Integer numProd) {
    List<Product2> productRecord = new List<Product2>();
    for (Integer i = 0; i < numProd; i++) {
      productRecord.add(new Product2(Name = 'Test Product' + i));
    }
    return productRecord;
  }

  /**
   * @description Method for creating Course Offering Record
   * @param nCourseOffering - number of Course Offerings to be created
   * @param cour - courses to be related to Course Offering
   * @param terms - terms to be related to Course Offering
   * @return courseOfferingRecord - List of Course Offering Created
   */
  public static List<hed__Course_Offering__c> createTestCourseOfferingRecord(
    Integer nCourseOffering,
    List<hed__Course__c> cour,
    List<hed__Term__c> terms
  ) {
    List<hed__Course_Offering__c> courseOfferingRecord = new List<hed__Course_Offering__c>();
    for (Integer i = 0; i < nCourseOffering; i++) {
      courseOfferingRecord.add(
        new hed__Course_Offering__c(
          Name = 'CourseOffering ' + i,
          hed__Course__c = cour[i].id,
          hed__Term__c = terms[i].id,
          hed__Start_Date__c = system.today() + 2,
          hed__Capacity__c = 10
        )
      );
    }
    return courseOfferingRecord;
  }

  /**
   * @description Method for creating Product Request Record without Program Spec Relation
   * @param numProdcutRequest - number of Product Request to be created
   * @return prodRequest - List of Product Request Created
   */
  public static List<Product_Request__c> createTestProductRequestRecords(
    Integer numProdcutRequest
  ) {
    List<Product_Request__c> prodRequest = new List<Product_Request__c>();
    for (Integer i = 0; i < numProdcutRequest; i++) {
      prodRequest.add(
        new Product_Request__c(
          Product_Request_Status__c = 'Define',
          Product_Request_Name__c = 'Test ' + i
        )
      );
    }
    return prodRequest;
  }

  /**
   * @description Method for creating Term Record
   * @param nTerm - number of Term to be created
   * @param accountId - List of accounts to be related to terms
   * @return term - List of Product Request Created
   */
  public static List<hed__Term__c> createTestTermRecords(
    Integer nTerm,
    Id accountId
  ) {
    List<hed__Term__c> term = new List<hed__Term__c>();
    for (Integer i = 0; i < nTerm; i++) {
      term.add(
        new hed__Term__c(Name = 'Test Term ' + i, hed__Account__c = accountId)
      );
    }
    return term;
  }

  /**
   * @description Method for creating Asset Record
   * @param nAsset - number of Term to be created
   * @param accountId - List of accounts to be related to terms
   * @param productRequestId - List of product request to be related to terms
   * @return asset - List of Asset Records Created
   */
  public static List<Asset> createTestAssetRecords(
    Integer nAsset,
    Id accountId,
    Id productRequestId
  ) {
    List<Asset> asset = new List<Asset>();
    for (Integer i = 0; i < nAsset; i++) {
      asset.add(
        new Asset(
          Name = 'Test Asset' + i,
          AccountId = accountId,
          Product_Request__c = productRequestId
        )
      );
    }
    return asset;
  }

  /**
   * @description Method for creating Term Record
   * @param contactId - contact ids
   * @param oppList - list of oppportunities
   * @return oppConRole - list of opportunity contact roles
   */
  public static List<OpportunityContactRole> createTestOpportunityContactRolesRecords(
    Id contactId,
    List<Opportunity> oppList
  ) {
    List<OpportunityContactRole> oppConRole = new List<OpportunityContactRole>();
    for (Integer i = 0; i < oppList.size(); i++) {
      oppConRole.add(
        new OpportunityContactRole(
          ContactId = contactId,
          OpportunityId = oppList[i].Id
        )
      );
    }
    return oppConRole;
  }

  /**
   * @description Method for creating Term Record
   * @param oppList - list of opportunities
   * @param status - status of envelope
   * @return envelopeStatuses - list of envelope statuses
   */
  public static List<dfsle__EnvelopeStatus__c> createTestEnvelopeStatusRecords(
    List<Opportunity> oppList,
    String status
  ) {
    List<dfsle__EnvelopeStatus__c> envelopeStatuses = new List<dfsle__EnvelopeStatus__c>();
    for (Integer i = 0; i < oppList.size(); i++) {
      envelopeStatuses.add(
        new dfsle__EnvelopeStatus__c(
          dfsle__SourceId__c = oppList[i].Id,
          dfsle__Status__c = status
        )
      );
    }
    return envelopeStatuses;
  }

  /**
   * @description Method for creating test ContentVersion records
   * @param contentVersionNumber - number of ContentVersion to be created
   * @return contentVersionList - list of ContentVersion created
   */
  public static List<ContentVersion> createTestContentVersionRecords(
    Integer contentVersionNumber
  ) {
    List<ContentVersion> contentVersionList = new List<ContentVersion>();

    for (Integer i = 0; i < contentVersionNumber; i++) {
      contentVersionList.add(
        new ContentVersion(
          Title = 'Proposal - General With Content_ALPHA ZENITH PTY LTD-test opportunity that may e123123123samplesample' +
            i,
          PathOnClient = 'test' + i,
          versiondata = EncodingUtil.base64Decode('Unit Test Attachment Body')
        )
      );
    }

    return contentVersionList;
  }

  /**
   * @description Method for creating test programplan records
   * @param programPlanNumber - number of ContentVersion to be created
   * @return contentVersionList - list of ContentVersion created
   */
  public static List<hed__Program_Plan__c> createTestProgramPlanRecords(
    Integer programPlanNumber
  ) {
    List<hed__Program_Plan__c> programPlanList = new List<hed__Program_Plan__c>();

    for (Integer i = 0; i < programPlanNumber; i++) {
      programPlanList.add(
        new hed__Program_Plan__c(Name = 'Test Program Plan' + i)
      );
    }

    return programPlanList;
  }

  /**
   * @description Method for creating test Product2 with isActive status
   * @param numProducts - number of Product2 to be created
   * @return products - list of Product2 created
   */
  public static List<Product2> createTestInActiveProductRecords(
    Integer numProducts
  ) {
    List<Product2> products = new List<Product2>();

    for (Integer i = 0; i < numProducts; i++) {
      products.add(
        new Product2(
          IsActive = false,
          Description = 'TestProductDesc' + i,
          Family = 'QUTeX CCE Elements',
          Name = 'TestProduct' + i
        )
      );
    }

    return products;
  }
  /**
   * @description Method to a create Community User
   *
   * @param email - email of authenticated user
   * @param lastName - last name of authenticated user
   * @param firstName - first name of authenticated user
   * @return Auth.UserData that looks like what we expect from LinkedIn
   **/
  public static Auth.UserData createCommunityUser(
    String email,
    String lastName,
    String firstName
  ) {
    Map<String, String> attributeMap = new Map<String, String>();
    String identifier = lastName + System.currentTimeMillis();
    String locale = 'en_US';
    return new Auth.UserData(
      identifier,
      firstName,
      lastName,
      '', // fullname
      email,
      '', // link
      '', // userName
      locale,
      '', // provider
      '', // siteLoginUrl
      attributeMap
    );
  }

  /**
   * @description Method for creating Course Connection Record
   * @param nCourseConnection - number of Course Connection to be created
   * @param conId - Contact Id to be related to Course Connection
   * @param courseOfferings - Course Offerings to be related to Course Connection
   * @return courseConnectionRecord - List of Course Connection Created
   */
  public static List<hed__Course_Enrollment__c> createTestCourseConnectionRecord(
    Integer nCourseConnection,
    Id conId,
    List<hed__Course_Offering__c> courseOfferings
  ) {
    List<hed__Course_Enrollment__c> courseConnectionRecord = new List<hed__Course_Enrollment__c>();
    for (Integer i = 0; i < nCourseConnection; i++) {
      courseConnectionRecord.add(
        new hed__Course_Enrollment__c(
          hed__Contact__c = conId,
          hed__Course_Offering__c = courseOfferings[i].id
        )
      );
    }
    return courseConnectionRecord;
  }

  /**
   * @description method to create test data for create Account
   * @param doInsert - boolean true/false
   * @return acc - account
   */
  public static Account createTestAccount(Boolean doInsert) {
    Account acc = new Account();
    acc.Name = TEST_ACCOUNT_NAME;

    if (doInsert) {
      insert acc;
    }
    return acc;
  }

  /**
   * @description method to create test data for create contact object
   * @param doInsert - boolean true/false
   * @param accId - account Id
   * @return con - Contact
   */
  public static Contact createTestContact(Boolean doInsert, Id accId) {
    Contact con = new Contact();
    con.AccountId = accId;
    con.FirstName = CommonUtils.randomString(10);
    con.LastName = CommonUtils.randomString(10);

    if (doInsert) {
      insert con;
    }
    return con;
  }

  /**
   * @description method to create test data for Buyer Account
   * @param doInsert - boolean true/false
   * @param accId - account Id
   * @return buyerAccount - BuyerAccount
   */
  public static BuyerAccount createTestBuyerAccount(
    Boolean doInsert,
    Id accId
  ) {
    BuyerAccount buyerAccount = new BuyerAccount();
    buyerAccount.BuyerId = accId;
    buyerAccount.Name = TEST_BUYER_ACCT;
    buyerAccount.IsActive = true;

    if (doInsert) {
      insert buyerAccount;
    }
    return buyerAccount;
  }

  /**
   * @description method to create test data for Buyer Group
   * @param doInsert - boolean true/false
   * @param accId - account Id
   * @return buyerGrp - BuyerGroup
   */
  public static BuyerGroup createTestBuyerGroup(Boolean doInsert) {
    BuyerGroup buyerGrp = new BuyerGroup(Name = TEST_BUYER_GROUP);

    if (doInsert) {
      insert buyerGrp;
    }
    return buyerGrp;
  }

  /**
   * @description method to create test data for Buyer Group Member
   * @param doInsert - boolean true/false
   * @param accId - account Id
   * @return buyerGrpMember - BuyerGroupMember
   */
  public static BuyerGroupMember createTestBuyerGroupMember(
    Boolean doInsert,
    Id accId,
    Id buyerGrpId
  ) {
    BuyerGroupMember buyerGrpMember = new BuyerGroupMember();
    buyerGrpMember.BuyerGroupId = buyerGrpId;
    buyerGrpMember.BuyerId = accId;

    if (doInsert) {
      insert buyerGrpMember;
    }
    return buyerGrpMember;
  }

  /**
   * @description method to create test data for Product2
   * @param doInsert - boolean true/false
   * @return prd - product2
   */
  public static Product2 createTestProduct2(Boolean doInsert) {
    Product2 prd = new Product2(
      Name = 'TestProduct',
      ProductCode = 'TEST_SKU',
      Family = 'TestFamily'
    );

    if (doInsert) {
      insert prd;
    }
    return prd;
  }

  /**
   * @description Method for creating test Account records
   * @param numAccts - number of Accounts to be created
   * @param accId - Id of the related account
   * @param accName - Name of the related account
   * @return baccts - list of BuyerAccounts created
   */
  public static List<BuyerAccount> createTestBuyerAccountRecords(
    Integer numAccts,
    Id accId,
    String accName
  ) {
    List<BuyerAccount> baccts = new List<BuyerAccount>();

    for (Integer i = 0; i < numAccts; i++) {
      baccts.add(new BuyerAccount(BuyerId = accId, Name = accName));
    }

    return baccts;
  }

  /**
   * @description Method for creating test Program Offering records
   * @param nProgramOffering - number of Program Offering to be created
   * @param programPlans - Program Plan to be related to Program Offering
   * @return programOfferingRecord - List of Pending Registration Created   */
   public static List<Program_Offering__c> createTestProgramOfferingRecords(
    Integer nProgramOffering,
    List<hed__Program_Plan__c> programPlans
  ) {
    List<Program_Offering__c> programOfferingRecord = new List<Program_Offering__c>();
    for (Integer i = 0; i < nProgramOffering; i++) {
      programOfferingRecord.add(
        new Program_Offering__c(
          Name = 'Test Program Offering' + i,
          hed_Program_Plan__c = programPlans[i].id,
          hed_Capacity__c = 10,
          Start_Date__c = system.today() + 1
        )
      );
    }
    return programOfferingRecord;
  }

  /**
   * @description Method for creating test Product Ledger records
   * @param numProductLedger number of product ledger
   * @param courseEnrollement Id of related course enrollment
   * @param assets Id of related Asset
   * @return productLedger - list of product ledger
   */
  public static List<Product_Ledger__c> createTestProductLedgerRecords(
    Integer numProductLedger,
    Id courseEnrollement,
    Id assets
  ) {
    List<Product_Ledger__c> productLedger = new List<Product_Ledger__c>();

    for (Integer i = 0; i < numProductLedger; i++) {
      productLedger.add(
        new Product_Ledger__c(
          Course_Connection__c = courseEnrollement,
          Asset__c = assets
        )
      );
    }

    return productLedger;
  }

  /**
   * @description Method for creating test Credential records
   * @param numOfCredential number of Credential
   * @return credential - list of Credential
   */
  public static List<Credential__c> createTestCredentialRecords(
    Integer numOfCredential
  ) {
    List<Credential__c> credential = new List<Credential__c>();
    for (Integer i = 0; i < numOfCredential; i++) {
      credential.add(new Credential__c(Name = 'Test Credential' + i));
    }
    return credential;
  }
  /**
   * @description Method for creating test Questionnaire records
   * @param numQuestionnaires number of questionnaires
   * @param parentRecord Id of parent record
   * @param objectType api name of object the questionnaire is attached to
   * @return questionnaires - list of questionnaires
   */
  public static List<Questionnaire__c> createTestQuestionnaireRecords(
    Integer numQuestionnaires,
    String parentRecord,
    String objectType
  ) {
    List<Questionnaire__c> questionnaires = new List<Questionnaire__c>();

    for (Integer i = 0; i < numQuestionnaires; i++) {
      questionnaires.add(
        new Questionnaire__c(
          Questionnaire_Type__c = STR_QUESTIONNAIRE_TYPE,
          Parent_Record_ID__c = parentRecord,
          Object_Type__c = objectType
        )
      );
    }

    return questionnaires;
  }

  /**
   * @description Method for creating test Question records
   * @param numQuestion number of questions
   * @return questions - list of questions
   */
  public static List<Question__c> createTestQuestionRecords(
    Integer numQuestions
  ) {
    List<Question__c> questions = new List<Question__c>();

    for (Integer i = 0; i < numQuestions; i++) {
      questions.add(new Question__c());
    }

    return questions;
  }

  /**
   * @description Method for creating test Related Answer records
   * @param numRelatedAnswers number of Related Answers
   * @param relatedQuestions Id of parent record
   * @param relatedQuestionnaire api name of object the questionnaire is attached to
   * @return questionnaires - list of Related Answers
   */
  public static List<Related_Answer__c> createTestRelatedAnswerRecords(
    Integer numRelatedAnswers,
    Id relatedQuestionnaire,
    List<Question__c> relatedQuestions
  ) {
    List<Related_Answer__c> relAnswers = new List<Related_Answer__c>();

    for (Integer i = 0; i < numRelatedAnswers; i++) {
      relAnswers.add(
        new Related_Answer__c(
          Questionnaire__c = relatedQuestionnaire,
          Question__c = relatedQuestions[i]?.Id
        )
      );
    }

    return relAnswers;
  }

  /**
   * @description Method for creating test Expression of Interest records
   * @param numInterests number of expression of interests
   * @param contact contact of user registered his interest
   * @param products list of products
   */
  public static List<Expression_of_Interest__c> createExpressionOfInterest(
    Integer numInterests,
    Contact contact,
    List<Product2> products
  ) {
    List<Expression_of_Interest__c> interests = new List<Expression_of_Interest__c>();

    for (Integer i = 0 ; i < numInterests ; i++) {
      interests.add(
        new Expression_of_Interest__c(
          Contact__c = contact.Id,
          Product__c = products[i].Id,
          Type__c = 'Register Interest',
          Status__c = 'Active'
        )
      );
    }

    return interests;
  }

    /**
   * @description Method for creating test  questionnaire response summary records
   * @param numQuestionnaireResponseSummary number of questionnaire response summary
   * @param contact contact to be relate in questionnaire response summary records
   * @param courseOff List of related course offering
   * @return questionnaireResponseSumm - list of questionnaire response summary
   */
  public static List<Questionnaire_Response_Summary__c> createTestQuestionnaireResponseSummaryRecords(
    Integer numQuestionnaireResponseSummary,
    List<hed__Course_Offering__c> courseOff,
    Contact contact
  ) {
    List<Questionnaire_Response_Summary__c> questionnaireResponseSumm = new List<Questionnaire_Response_Summary__c>();

    for (Integer i = 0; i < numQuestionnaireResponseSummary; i++) {
      questionnaireResponseSumm.add(
        new Questionnaire_Response_Summary__c(
          Contact__c = contact.Id,
          Course_Offering__c = courseOff[i].Id
        )
      );
    }

    return questionnaireResponseSumm;
  }

  /**
   * @description Method for creating test Session records
   * @param numSessions number of Session record
   */
  public static List<Session__c> createTestSessionRecords(Integer numSessions){
  List<Session__c> sessions = new List<Session__c>();

    for (Integer i = 0; i < numSessions; i++) {
      sessions.add(new Session__c(Name = 'Session Test' + i));
    }

    return sessions;
  }

   /**
   * @description Method for creating test Attendance Event records
   * @param numAttendance number of Attendance record
   * @param contId Id of contact to be related
   * @param courseEnrollment Id of Course Connection to be related
   * @param sessionId Id of Session to be related
   */
   public static List<hed__Attendance_Event__c> createTestAttendanceRecords(Integer numAttendance, Id contId, Id courseEnrollment, Id sessionId){
  List<hed__Attendance_Event__c> attendance = new List<hed__Attendance_Event__c>();

    for (Integer i = 0; i < numAttendance; i++) {
      attendance.add(new hed__Attendance_Event__c(hed__Contact__c = contId, hed__Course_Connection__c= courseEnrollment,Session__c = sessionId ));
    }

    return attendance;
  }

  /**
   * @description Method for creating test Financial Split records
   * @param numFinSplits number of financial splits
   * @param courseId id of related course
   * @return finSplits - list of financial splits
   */
  public static List<Financial_Split__c> createTestFinancialSplitRecords(
    Integer numFinSplits,
    Id courseId
  ) {
    List<Financial_Split__c> finSplits = new List<Financial_Split__c>();

    for (Integer i = 0 ; i < numFinSplits ; i++) {
      finSplits.add(
        new Financial_Split__c(
          Course__c = courseId
        )
      );
    }

    return finSplits;
  }


  /**
   * @description Method for creating test Related Product Requests
   * @param numRelatedPR number of records
   * @param courseProdReqId id of related course PR
   * @param programProdReqId id of related program PR
   * @return relatedPrList - list of related product requests
  */
  public static List<Related_Product_Request__c> createTestRelatedPRRecords(
    Integer numRelatedPR,
    List<Product_Request__c> courseProdReqId,
    List<Product_Request__c> programProdReqId
  ) {
    List<Related_Product_Request__c> relatedPrList = new List<Related_Product_Request__c>();
    for (Integer i = 0 ; i < numRelatedPR ; i++) {
      relatedPrList.add(
        new Related_Product_Request__c(
          Course__c = courseProdReqId[i].Id,
          Program__c = programProdReqId[i].Id
        )
      );
    }
    return relatedPrList;
  }

  /**
   * @description Method for creating test Adhoc Communication records
   * @param numAdhocComms number of records
   * @return adhocCommsList - list of adhoc communication records
  */
  public static List<Adhoc_Communication__c> createTestAdhocCommsRecords(
    Integer numAdhocComms
  ) {
    List<Adhoc_Communication__c> adhocCommsList = new List<Adhoc_Communication__c>();
    for (Integer i = 0 ; i < numAdhocComms ; i++) {
      adhocCommsList.add(
        new Adhoc_Communication__c()
      );
    }
    return adhocCommsList;
  }

  /**
   * @description Method for creating test Document records
   * @param numDocs number of records
   * @param docNames name of documents
   * @param folderName folder where document is placed
   * @return docsList - list of document records
  */
  public static List<Document> createTestDocumentRecords(
    Integer numDocs,
    List<String> docNames,
    String folderName
  ) {
    Id queriedFolderId = [Select Id From Folder Where Name =: folderName LIMIT 1]?.Id;
    List<Document> docsList = new List<Document>();
    for (Integer i = 0 ; i < numDocs ; i++) {
      docsList.add(
        new Document(
          Name = docNames[i],
          FolderId = queriedFolderId
        )
      );
    }
    return docsList;
  }

  /**
   * @description Method for creating Communication Schedule
   * @param nCommSched - number of Communication Schedule to be created
   * @param course - List of Course to be related to Communication Schedule
   * @param progPlan - List of Program Plan to be related to Communication Schedule
   * @return commSched - List of Communication Schedule Created
   */
  public static List<Communication_Schedule__c> createTestCommunicationScheduleRecords(
    Integer nCommSched,
    List<hed__Course__c> course,
    List<hed__Program_Plan__c> progPlan
  ) {
    List<Communication_Schedule__c> commSched = new List<Communication_Schedule__c>();
    for (Integer i = 0; i < nCommSched; i++) {
      commSched.add(
        new Communication_Schedule__c(
          Program_Plan__c = progPlan[i].Id,
          Course__c = course[i].Id
        )
      );
    }
    return commSched;
  }

  /**
   * @description Method for creating test Email Template records
   * @param numTemplates number of records
   * @param templateNameAndSubjectMap map containing name of template and its corresponding subject
   * @return templateList - list of email template records
  */
  public static List<EmailTemplate> createTestEmailTemplateRecords(
    Integer numTemplates,
    Map<String,String> templateNameAndSubjectMap
  ) {
    List<EmailTemplate> templateList = new List<EmailTemplate>();
    List<String> templateNames = new List<String>();
    templateNames.addAll(templateNameAndSubjectMap.keySet());
    for (Integer i = 0 ; i < numTemplates ; i++) {
      templateList.add(
        new EmailTemplate(
          IsActive = true,
          Name = templateNames[i],
          DeveloperName = generateRandomString('test_emailtemplate'),
          TemplateType = 'custom',
          HtmlValue = generateRandomString('test_emailtemplate'),
          FolderId = UserInfo.getUserId(),
          Subject = templateNameAndSubjectMap.get(templateNames[i])
        )
      );
    }
    return templateList;
  }

  /**
   * @description Method for generating random string for unique fields
   * @param identifier - additinal string to add as identifier
   * @return random string 
   */
  public static String generateRandomString(String identifier){
    return 
      identifier + 
      String.valueOf(System.today().month()) +
      String.valueOf(System.today().year()) + 
      String.valueOf(Integer.valueOf(Math.floor(100000 + Math.random() * 900000)));
  }

}