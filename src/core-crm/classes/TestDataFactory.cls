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
      | kathy.cornejo             | June 3, 2022          | DEPP-2664           | Added method for Creating Pricebook2                             |
      | rhea.b.torres             | June 12, 2022         | DEPP-2734           | Implement proper testing persona                                 |
      | marlon.vasquez            | July 25, 2022         | DEPP-3538           | Added Required fields for creating Product Specification         |
      | william.a.cheng           | September 14, 2022    | DEPP-4266, 1977     | Add methodd to configure TDTM and affiliation mappings           |
      | rhea.b.torres             | November 10, 2022     | DEPP-4448           | Add methodd to create International_Tier__c records              |
      | rhea.b.torres             | February 2, 2023      | NA                  | Add new methods to handle creation of CCE Product Specification  |
*/

@isTest
public class TestDataFactory {
  private static final String STR_QUALIFY = 'Qualify';
  private static final String STR_IN_PROGRESS = 'In Progress';
  private static final String STR_QUESTIONNAIRE_TYPE = 'Registration Criteria';
  private static final String TEST_BUYER_GROUP = 'Test Buyer Group';
  private static final String TEST_BUYER_ACCT = 'Test Buyer Account';
  private static final String TEST_ACCOUNT_NAME = 'Test Account';
  private static final String TEST_PRICEBOOK2_NAME = 'Test Pricebook2';
  private static final TestUserGenerator TEST_USER_GENERATOR = new TestUserGenerator();

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
   * @description Method for creating test case records
   * @param numCases - number of case to be created
   * @param relatedLeads - related lead to case
   * @param relatedContacts - related contact to case
   * @return case - list of case created
   */
  public static List<Case> createTestCaseRecords(Integer numCases, List<Lead> relatedLeads, List<Contact> relatedContacts) {
    List<Case> cases = new List<Case>();

    for (Integer i = 0; i < numCases; i++) {
      cases.add(
        new case(
          Lead__c = relatedLeads != null && !relatedLeads.isEmpty()?relatedLeads[i].Id:null,
          ContactId = relatedContacts != null && !relatedContacts.isEmpty()?relatedContacts[i].Id:null
        )
      );
    }

    return cases;
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
   * @description Method for creating "Closed Won" Opportunity records
   * @param numOpps - number of Opportunities to be created
   * @param accId - Id of related Account
   * @param conId - Id of related Contact for roles
   * @return opps - list of Opportunities created
   */
  public static List<Opportunity> createClosedWonOpportunities(
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
          StageName = 'Closed Won',
          Status__c = 'Contract Signed',
          CloseDate = System.today() + 30
        )
      );
    }

    return opps;
  }

  /**
   * @description Method for retrieving CCE Product Specification records
   * A pre-requisite to this is to call createClosedWonOpportunities method
   * @param void
   * @return prodSpecList - returns all available CCE Product Specification records
   */
  public static List<Product_Specification__c> retrieveCCEProductSpecifications() {
    List<Product_Specification__c> prodSpecList = [SELECT Id, RecordTypeId FROM Product_Specification__c WHERE RecordType.DeveloperName = 'CCE'];
    return prodSpecList;
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
      ps.Status__c = 'Design';
      ps.Stage__c = 'Define';
      ps.Client_Review_Required__c = 'N/A';
      ps.Requestor_Name__c =  contacts[i].id;
      ps.Requires_Director_Endorsement__c = 'Yes';
      ps.Endorsed_by__c = contacts[i].id;
      ps.Existing_Product__c = 'Yes';
      ps.Financial_Viability__c = 'Yes';
      ps.Market_Need__c = 'Yes';
      ps.QUTeX_Capacity__c = 'Yes';
      ps.QUT_Faculty_Capacity__c = 'Yes';
	    ps.Supporting_Comments__c = 'Test';
      ps.Not_Proceeding_Comments__c = 'Test';
      ps.Product_Type__c = 'Short Course';
      productSpecifications.add(ps);
    }

    return productSpecifications;
  }

  /**
   * @description Create a product specification record without an opportunity attached to it yet
   * @param numProductSpecs number of product specification
   * @param contacts list of related contacts
   * @return productSpecifications - list of product specifications
   */
  public static List<Product_Specification__c> createTestProductSpecsRecords(
    Integer numProductSpecs,
    Id contact
  ) {
    List<Product_Specification__c> productSpecifications = new List<Product_Specification__c>();

    for (Integer i = 0; i < numProductSpecs; i++) {
      Product_Specification__c ps = new Product_Specification__c();
      ps.Program_Name__c = 'TEST PS ' + i;
      ps.Program_Lead__c = contact;
      ps.Status__c = 'Design';
      ps.Stage__c = 'Design';
      ps.Client_Review_Required__c = 'N/A';
      ps.Requestor_Name__c =  contact;
      ps.Requires_Director_Endorsement__c = 'Yes';
      ps.Endorsed_by__c = contact;
      ps.Existing_Product__c = 'Yes';
      ps.Financial_Viability__c = 'Yes';
      ps.Market_Need__c = 'Yes';
      ps.QUTeX_Capacity__c = 'Yes';
      ps.QUT_Faculty_Capacity__c = 'Yes';
	    ps.Supporting_Comments__c = 'Test';
      ps.Not_Proceeding_Comments__c = 'Test';
      ps.Product_Type__c = 'Short Course';
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

    public static hed__Course__c createTestCourseRecords(Map<String, String> courseFields) {
      hed__Course__c course = new hed__Course__c(
          Name = courseFields.get('Name'),
          ProductRequestID__c = courseFields.get('ProductRequestID__c'),
          hed__Account__c =  courseFields.get('hed__Account__c'),
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
          Owning_Faculty__c =  courseFields.get('Owning_Faculty__c')
      );
      return course;
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
    String firstName,
    String username
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
      username,
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
   * @description Method for creating Course Connection Record
   * @param nCourseConnection - number of Course Connection to be created
   * @param conId - Contact Id to be related to Course Connection
   * @param programOfferings - Program Offerings to be related to Course Connection
   * @return courseConnectionRecord - List of Course Connection Created
   */
  public static List<hed__Course_Enrollment__c> createTestCourseConnectionRecordProgram(
    Integer nCourseConnection,
    Id conId,
    List<Program_Offering__c> programOfferings
  ) {
    List<hed__Course_Enrollment__c> courseConnectionRecord = new List<hed__Course_Enrollment__c>();
    for (Integer i = 0; i < nCourseConnection; i++) {
      courseConnectionRecord.add(
        new hed__Course_Enrollment__c(
          hed__Contact__c = conId,
          Program_Offering__c = programOfferings[i].id
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
   * @description method to create test data for create Pricebook2
   * @param doInsert - boolean true/false
   * @return pb - Pricebook2
   */
  public static Pricebook2 createTestPricebook2(Boolean doInsert){
    Pricebook2 pb = new Pricebook2();
    pb.Name = TEST_PRICEBOOK2_NAME;

    if (doInsert) {
      insert pb;
    }
    return pb;
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

    public static Program_Offering__c createTestProgramOfferingRecords(Map<String, String> programOfferingFields) {
      Program_Offering__c programOfferingRecord = new Program_Offering__c(
          Name = programOfferingFields.get('Name'),
          hed_Program_Plan__c = programOfferingFields.get('hed_Program_Plan__c'),
          hed_Capacity__c = 30,
          Start_Date__c = system.today() + 1,
          Registration_Start_Date__c = system.today() + 1,
          IsActive__c = true,
          Visible_on_Website__c = true
      );
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

  /**
   * @description Method for creating test hed__Affiliation__c records
   * @param numContacts - number of Affliated Contact to be created
   * @param accountId - accountId
   * @return cons - list of hed__Affiliation__c created
   */
  public static List<hed__Affiliation__c> createTestAffliatedContactRecords(Integer numContacts, Id accountId) {
    List<hed__Affiliation__c> cons = new List<hed__Affiliation__c>();

    for (Integer i = 0; i < numContacts; i++) {
      cons.add(new hed__Affiliation__c(hed__Description__c = 'AF Test' + i, hed__Account__c= accountId));
    }

    return cons;
  }

  /**
   * @description Method for creating MC_Messaging_OTP_Setting__c custom setting
   * @param void
   * @return setting - the created MC_Messaging_OTP_Setting__c
   */
  public static MC_Messaging_OTP_Setting__c createOTPCustomSetting(){
    MC_Messaging_OTP_Setting__c setting = new MC_Messaging_OTP_Setting__c();
    setting.Access_Token_EndPoint_URL__c = 'https://accessToken';
    setting.Account_Id__c = '1234';
    setting.Attributes__c = 'Attr123';
    setting.Client_Id__c = '12344';
    setting.Client_Secret__c = '12987';
    setting.DefinitionKey__c = 'test';
    setting.GrantType__c = 'test';
    setting.Message__c = 'test';
    setting.SMS_EndPoint_URL__c = 'https://smsendpoint';
    return setting;
  }

  /**
   * @description Method for creating WebStoreCatalog
   * @param prodCatId - ProductCatalogId
   * @param salesStoreId - SalesStoreId
   * @return webStoreCatalog - the created WebStoreCatalog
   */
  public static WebStoreCatalog createWebStoreCatalog(Id prodCatId, Id salesStoreId){
    WebStoreCatalog webStoreCatalog = new WebStoreCatalog();
    webStoreCatalog.ProductCatalogId = prodCatId;
    webStoreCatalog.SalesStoreId = salesStoreId;
    return webStoreCatalog;
  }

  /**
   * @description Method for creating WebStoreCatalog
   * @return records - list of International_Tier__c records
   */
  public static List<International_Tier__c> createInternationalTierRecords(List<String> countryNames, String priority, String category, Boolean isActive){
    List<International_Tier__c> records = new List<International_Tier__c>();

    for(String country : countryNames){
      International_Tier__c tier = new International_Tier__c(IsActive__c=isActive, 
                                                              Country_Name__c=country,
                                                              Tier_Priority__c=priority,
                                                              Tier_Category__c=category);
      records.add(tier);
    }
    
    return records;
  }

  public static List<Case> createTestCaseRecords(Id recordTypeId, String subject, Integer numOfRecords) {
    List<Case> caseList = new List<Case>();

    for(Integer i=0; i<numOfRecords; i++){
      Case caseRecord = new Case();
      caseRecord.RecordTypeId = recordTypeId;
      caseRecord.Subject = subject + i;
      caseList.add(caseRecord);
    }

    return caseList;
  }

  public static List<EmailMessage> queryEmailMessageRecords(){
    Id courseConnectionId = [SELECT Id FROM hed__Course_Enrollment__c LIMIT 1]?.Id;
    List<EmailMessage> emailMessageList = [SELECT Id, RelatedToId 
                                            FROM EmailMessage
                                            WHERE RelatedToId=:courseConnectionId
                                            WITH SECURITY_ENFORCED];
    return emailMessageList;
  }

    /**
     * @description Method for generating test users
     * @param void
     * @return List<User> - all generated user records
     */
    public static List<User> generateTestUsers(){
        return TEST_USER_GENERATOR.generateTestUsers();
    }

    /**
     * @description Method for getting Program Administrator
     * @param void
     * @return portalSysAdmin - QUTeX Program Admin User
     */
    public static User getProgramAdminUser(){
        User progAdmin = [SELECT Id From User WHERE Username LIKE 'QUT_Program_Administrator%' LIMIT 1];
        return progAdmin;
    }

    /**
     * @description Method for getting Program Administrator
     * @param void
     * @return portalSysAdmin - QUTeX Program Admin User
     */
    public static User getMarketingCloudUser(){
      User marketingCloud = [SELECT Id From User WHERE Username LIKE 'QUT_Marketing_Cloud%' LIMIT 1];
      return marketingCloud;
  }

    /**
     * @description Method for creating Sys Admin Portal Owner
     * @param void
     * @return portalSysAdmin - Portal Sys Admin user
     */
    public static User getPortalSysAdminUser(){
        User portalSysAdmin = [SELECT Id FROM User WHERE Username LIKE 'QUT_Sys_Admin%' LIMIT 1];
        return portalSysAdmin;
    }

    /**
     * @description Method for creating Corporate Partner
     * @param void
     * @return coporateUser - Corporate Partner User
     */
    public static User getCorporatePartnerUser(){
        User coporateUser = [SELECT Id FROM User WHERE Username LIKE 'QUT_Corporate_Partner_User%' LIMIT 1];
        return coporateUser;
    }

    /**
     * @description Method for creating Partnership Manager
     * @param void
     * @return partnershipManager - Partnership Manager
     */
    public static User getPartnershipManager(){
      User partnershipManager = [SELECT Id FROM User WHERE Username LIKE 'QUT_Partnership_Manager%' LIMIT 1];
      return partnershipManager;
    }

    /**
     * @description Method for creating Learning Designer
     * @param void
     * @return learningDesigner - Learning Designer
     */
    public static User getLearningDesigner(){
      User learningDesigner = [SELECT Id FROM User WHERE Username LIKE 'QUT_Learning_Designer%' LIMIT 1];
      return learningDesigner;
    }

    /**
     * @description Method for getting integration website user
     * @param void
     * @return integWebSiteUser - Integration Website User
     */
    public static User getIntegrationWebsiteUser(){
      User integWebSiteUser = [SELECT Id FROM User WHERE Username LIKE 'QUT_Website_Integration_User%' LIMIT 1];
      return integWebSiteUser;
    }

    /**
     * @description Method for ISR Communications Manager
     * @param void
     * @return ISR Communications Manager
     */
    public static User getISRCommunicationsManager(){
      User communicationMgr = [SELECT Id FROM User WHERE Username LIKE 'QUT_ISR_Communications_Manager%' LIMIT 1];
      return communicationMgr;
    }

    /**
     * @description Method for ISR Student Enquiries Communications Officer
     * @param void
     * @return ISR Student Enquiries Communications Officer
     */
    public static User getISRStudentEnquiriesCommunicationOfficer(){
      User secoUser = [SELECT Id FROM User WHERE Username LIKE 'QUT_ISR_Student_Enquiries_Communications_Officer%' LIMIT 1];
      return secoUser;
    }

    /**
     * @description Method for ISR Student Adviser
     * @param void
     * @return ISR Student Adviser
     */
    public static User getISRStudentAdviser(){
      User studentAdviser = [SELECT Id FROM User WHERE Username LIKE 'QUT_ISR_Student_Adviser%' LIMIT 1];
      return studentAdviser;
    }

    class TestUserGenerator{
        public Map<String,Id> groupMap;
        public Map<String,Id> profileMap;
        public Map<String,Id> roleMap;
        public Map<String,Id> permSetMap;
        public List<User> addUsers = new list<User>{};
        public List<String> addPermSets = new List<String>{};
        public List<String> addGroups = new List<String>{};
        public Map<String,String> usermap;

        public void addPermissionAssignment(){
            // insert perm sets if not null
            if(addPermSets!=null && addPermSets.size()>0){
                list<PermissionSetAssignment> addPS = new List<PermissionSetAssignment>{};
                for(String i:addPermSets){
                    List<String> res = i.split('%%');
                    addPS.add(new PermissionSetAssignment(
                        PermissionSetId=permSetMap.get(res[1])
                        ,AssigneeId=usermap.get(res[0])
                    ));
                }
                insert addPS;
            }
        }

        public void addPublicGroupAssignment(){
            // insert Group if not null
            if(addGroups!=null && addGroups.size()>0){
                list<GroupMember> addPG = new List<GroupMember>{};
                for(String i:addGroups){
                    List<String> res = i.split('%%');
                    System.Debug(LoggingLevel.DEBUG, 'groupMap SPLIT res: '+res);//NOPMD
                    addPG.add(new GroupMember(
                        GroupId=groupMap.get(res[1])
                        ,UserOrGroupId=usermap.get(res[0])
                    ));
                }
                insert addPG;
            }
        }

        public void generateUsers(String userName,
                                    String profileName,
                                    String roleName,
                                    String permSets,
                                    String publicGroups,
                                    Boolean isServiceCloudUser,
                                    Boolean isFlowUser,
                                    Boolean isKnowledgeUser,
                                    Boolean isMarketingUser,
                                    Boolean isAppExchangeAdmin,
                                    Boolean isAppExchangeUser,
                                    Boolean isPortal,
                                    Id contactId,
                                    Integer noOfUsers){
            if(profileMap == null){
                profileMap = new Map<String,Id>{};
                list<Profile> profileList = [SELECT Id,Name FROM Profile];
                for(Profile i:profileList){profileMap.put(i.Name,i.Id);}
            }
            if(roleMap == null){
                roleMap = new Map<String,Id>{};
                list<UserRole> roleList = [SELECT Id,Name FROM UserRole];
                for(UserRole i:roleList){roleMap.put(i.Name,i.Id);}
            }
            if(permSetMap == null){
                permSetMap = new Map<String,Id>{};
                list<PermissionSet> pmList = [SELECT Id,Name FROM PermissionSet];
                for(PermissionSet i:pmList){permSetMap.put(i.Name,i.Id);}
            }
            if(groupMap == null){
                groupMap = new Map<String,Id>{};
                list<Group> pmList = [SELECT Id,Name FROM Group];
                for(Group i:pmList){groupMap.put(i.Name,i.Id);}
            }

            for(Integer i = 0; i<noOfUsers; i++){
                Blob b = Crypto.GenerateAESKey(128);
                String h = EncodingUtil.ConvertTohex(b);
                String uid = h.SubString(0,8);

                User u = new User();
                u.UserName=userName+String.valueOf(i)+uid+'@qut.com';
                u.FirstName='Test';
                u.LastName=userName;
                u.Email=userName+String.valueOf(i)+uid+'@qut.com';
                u.alias=uid;
                u.ProfileId = profileMap.get(profileName);
                u.UserRoleId=roleMap.get(roleName);
                u.LocaleSidKey = 'en_AU';
                u.EmailEncodingKey ='UTF-8';
                u.LanguageLocaleKey = 'en_US';
                u.TimeZoneSidKey = 'Australia/Brisbane';
                u.UserPermissionsInteractionUser = isServiceCloudUser;
                u.UserPermissionsSupportUser = isFlowUser;
                u.UserPermissionsKnowledgeUser = isKnowledgeUser;
                u.UserPermissionsMarketingUser = isMarketingUser;
                u.et4ae5__ExactTargetForAppExchangeAdmin__c = isAppExchangeAdmin;
                u.et4ae5__ExactTargetForAppExchangeUser__c = isAppExchangeUser;
                if(isPortal){
                    u.ContactId = contactId;
                }
                addUsers.add(u);

                // add permission sets
                if(permSets!=null && permSets!=''){
                    if(permSets.contains(',')){
                        // has multiple perm sets
                        List<String> res = permSets.split(',');
                        for(String r:res){
                            String permset = r.trim();
                            addPermSets.add(u.userName+'%%'+permset); 
                        }

                    }else{
                        // has single perm set
                        addPermSets.add(u.userName+'%%'+permSets.trim());
                    }
                }

                // add addGroups
                if(publicGroups!=null && publicGroups!=''){
                    if(publicGroups.contains(',')){
                        // has multiple queues
                        List<String> res = publicGroups.split(',');
                        for(String r:res){
                            addGroups.add(u.userName+'%%'+r.trim());
                        }
                    }else{
                        // has single queues
                        addGroups.add(u.userName+'%%'+publicGroups.trim());
                    }
                }
            }
        }

        public List<User> generateTestUsers(){
            final User PORTAL_SYS_ADMIN = [
                SELECT Id FROM User WHERE IsActive = true
                                        AND FirstName = 'Sys Admin'
                                        AND LastName = 'Integration User'
                                        AND (Profile.Name = 'QUT System Administrator' 
                                            OR Profile.Name = 'System Administrator') LIMIT 1];
            //add UserRole
            PORTAL_SYS_ADMIN.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'System Administrator' LIMIT 1]?.Id;
            update PORTAL_SYS_ADMIN;
            System.runAs(PORTAL_SYS_ADMIN){
                // users below match personas on the following page https://wiki.qut.edu.au/display/DEP/User+Onboarding+Guide
                /** START - Creation of  Development Users */
                //Create QUT System Administrator
                generateUsers(
                    'QUT_System_Administrator'
                    ,'QUT System Administrator'
                    ,'System Administrator'
                    ,'DocuSign_Administrator,DocuSign_Generator,DocuSign_Negotiator,DocuSign_User'
                    ,''
                    ,true
                    ,true
                    ,true
                    ,false
                    ,false
                    ,false
                    ,false
                    ,null
                    ,1
                );
                //Create Development User
                generateUsers(
                    'QUT_Developer'
                    ,'Development Team Base'
                    ,''
                    ,'	Development_Team'
                    ,''
                    ,true
                    ,true
                    ,true
                    ,false
                    ,false
                    ,false
                    ,false
                    ,null
                    ,1
                );
                //Create QUT ReadOnly
                generateUsers(
                    'QUT_Read_Only'
                    ,'QUT Read Only'
                    ,''
                    ,'Integration_Person'
                    ,''
                    ,true
                    ,true
                    ,true
                    ,false
                    ,false
                    ,false
                    ,false
                    ,null
                    ,1
                );
                /** END - Creation of  Development Users */

                /** START - Creation of Integration/System Users */
                //Create Sys Admin
                generateUsers(
                    'QUT_Sys_Admin'
                    ,'QUT System Administrator'
                    ,'System Administrator'
                    ,'System_Administrator'
                    ,''
                    ,true
                    ,true
                    ,true
                    ,false
                    ,false
                    ,false
                    ,false
                    ,null
                    ,1
                );
                //Create Form Builder
                generateUsers(
                    'QUT_Form_Builder'
                    ,'Integration Forms'
                    ,'None'
                    ,'Permission_API_Only_User,Integration_Forms'
                    ,''
                    ,true
                    ,true
                    ,false
                    ,false
                    ,false
                    ,false
                    ,false
                    ,null
                    ,1
                );
                //Create Website Integration User
                generateUsers(
                    'QUT_Website_Integration_User'
                    ,'Integration Website'
                    ,'None'
                    ,'Permission_API_Only_User,Permission_API_Enabled,Lead_Forms,Product_Catalogue_Read_Only,Website_Connected_App'
                    ,''
                    ,true
                    ,true
                    ,false
                    ,false
                    ,false
                    ,false
                    ,false
                    ,null
                    ,1
                );
                //Create Marketing Cloud
                generateUsers(
                    'QUT_Marketing_Cloud'
                    ,'Integration Marketing'
                    ,'None'
                    ,'Permission_API_Only_User,Integration_Marketing,Marketing_Cloud_Connected_App,' // Missing permSets: Marketing Cloud Connector,Marketing Cloud Connector Admin
                    ,''
                    ,true
                    ,true
                    ,false
                    ,true
                    ,true
                    ,true
                    ,false
                    ,null
                    ,1
                );
                //Create ESB (Dell Boomi)
                generateUsers(
                    'QUT_ESB'
                    ,'Integration'
                    ,'None'
                    ,'Permission_API_Only_User,Integration_Person,Integration_Webcart'
                    ,''
                    ,true
                    ,true
                    ,false
                    ,false
                    ,false
                    ,false
                    ,false
                    ,null
                    ,1
                );
                //Create Data Migration
                generateUsers(
                    'QUT_Data_Migration'
                    ,'Integration'
                    ,'None'
                    ,'Permission_API_Only_User,Integration_Person'
                    ,''
                    ,true
                    ,true
                    ,false
                    ,false
                    ,false
                    ,false
                    ,false
                    ,null
                    ,1
                );
                //Create Trailtracker
                /** Commented-out due to 'Integration Base' profile and 'Trailhead Admin' permset does not exist
                 * Uncomment code when profile and permSets are available */
                /*generateUsers(
                    'QUT_Trailtracker'
                    ,'Integration Base'
                    ,''
                    ,'Permission_API_Only_User,Permission_API_Enabled,Trailhead_Admin'
                    ,''
                    ,false
                    ,false
                    ,false
                    ,false
                    ,false
                    ,false
                    ,false
                    ,null
                    ,1
                );*/
                /** END - Creation of Integration/System Users */

                /** START - Creation of General Users */
                generateUsers(
                    'QUT_Chatter_Free'
                    ,'Chatter Free User'
                    ,''
                    ,''
                    ,''
                    ,false
                    ,false
                    ,false
                    ,false
                    ,false
                    ,false
                    ,false
                    ,null
                    ,1
                );
                /** END - Creation of General Users */

                /** START - Creation of QUTeX Users */
                //Create Executive Director
                generateUsers(
                    'QUT_Executive_Director'
                    ,'QUTeX'
                    ,'QUTeX Leadership'
                    ,'QUTeX_Base,QUTeX_CCE,QUTeX_Leader,Marketing,DocuSign_Generator,DocuSign_Negotiator,DocuSign_Sender,DocuSign_User,Permission_API_Enabled' //missing permset: QUTeX OPE
                    ,''
                    ,true
                    ,true
                    ,false
                    ,false
                    ,false
                    ,false
                    ,false
                    ,null
                    ,1
                );
                //Create Business Manager
                generateUsers(
                    'QUT_Business_Manager'
                    ,'QUTeX'
                    ,'QUTeX Leadership'
                    ,'QUTeX_Base,QUTeX_CCE,QUTeX_Leader,DocuSign_Generator,DocuSign_Negotiator,DocuSign_Sender,DocuSign_User,Permission_API_Enabled' //missing permset: QUTeX OPE
                    ,''
                    ,true
                    ,true
                    ,false
                    ,false
                    ,false
                    ,false
                    ,false
                    ,null
                    ,1
                );
                //Create Director of OPE
                generateUsers(
                    'QUT_OPE_Director'
                    ,'QUTeX'
                    ,'QUTeX Super User'
                    ,'QUTeX_Base,QUTeX_CCE,QUTeX_Leader,DocuSign_Generator,DocuSign_Negotiator,DocuSign_Sender,DocuSign_User,Permission_API_Enabled' //missing permset: QUTeX OPE
                    ,''
                    ,true
                    ,true
                    ,false
                    ,false
                    ,false
                    ,false
                    ,false
                    ,null
                    ,1
                );
                //Create Portfolio Co-Ordinator
                generateUsers(
                    'QUT_Portfolio_Coordinator'
                    ,'QUTeX'
                    ,'QUTeX Super User'
                    ,'QUTeX_Base,QUTeX_CCE,QUTeX_Leader' //missing permset: QUTeX OPE
                    ,''
                    ,true
                    ,true
                    ,false
                    ,false
                    ,false
                    ,false
                    ,false
                    ,null
                    ,1
                );
                //Create Product Administrator
                generateUsers(
                    'QUT_Product_Admin'
                    ,'QUTeX'
                    ,'QUTeX User'
                    ,'QUTeX_Base,QUTeX_CCE,QUTeX_Leader'  //missing permset: QUTeX OPE
                    ,''
                    ,true
                    ,true
                    ,false
                    ,false
                    ,false
                    ,false
                    ,false
                    ,null
                    ,1
                );
                //Create Learning Innovation Manager
                generateUsers(
                    'QUT_Learning_Innovation_Manager'
                    ,'QUTeX'
                    ,'QUTeX User'
                    ,'QUTeX_Base,QUTeX_CCE,QUTeX_Leader' //missing permset: QUTeX OPE
                    ,''
                    ,true
                    ,true
                    ,false
                    ,false
                    ,false
                    ,false
                    ,false
                    ,null
                    ,1
                );
                //Create Learning Designer
                generateUsers(
                    'QUT_Learning_Designer'
                    ,'QUTeX'
                    ,'QUTeX User'
                    ,'QUTeX_Base,QUTeX_CCE,QUTeX_Leader,Product_Administration'
                    ,''
                    ,true
                    ,true
                    ,false
                    ,false
                    ,false
                    ,false
                    ,false
                    ,null
                    ,1
                );
                //Create Partnership Manager
                generateUsers(
                    'QUT_Partnership_Manager'
                    ,'QUTeX'
                    ,'QUTeX Super User'
                    //TODO: Add Product_Administration permset when approved in Onboarding Guide
                    ,'QUTeX_Base,QUTeX_CCE,QUTeX_Leader,DocuSign_Generator,DocuSign_Negotiator,DocuSign_Sender,DocuSign_User,Permission_API_Enabled'
                    ,''
                    ,true
                    ,true
                    ,false
                    ,false
                    ,false
                    ,false
                    ,false
                    ,null
                    ,1
                );
                //Create Program Co-Ordinator
                generateUsers(
                    'QUT_Program_Coordinator'
                    ,'QUTeX'
                    ,'QUTeX User'
                    ,'QUTeX_Base,QUTeX_CCE'
                    ,''
                    ,true
                    ,true
                    ,false
                    ,false
                    ,false
                    ,false
                    ,false
                    ,null
                    ,1
                );
                //Create Program Administrator
                generateUsers(
                    'QUT_Program_Administrator'
                    ,'QUTeX'
                    ,'QUTeX Super User'
                    ,'QUTeX_Base,QUTeX_CCE,QUTeX_Leader,Product_Administration,DocuSign_Generator,DocuSign_Negotiator,DocuSign_Sender,DocuSign_User,Permission_API_Enabled'
                    ,'CCE Product Design,OPE Product Design'
                    ,true
                    ,true
                    ,false
                    ,false
                    ,false
                    ,false
                    ,false
                    ,null
                    ,1
                );
                /** END - Creation of QUTeX Users */

                /** START - Creation of  Marketing Users */
                //Create Marketing Manager
                generateUsers(
                    'QUT_Marketing_Manager'
                    ,'Digital Marketing'
                    ,'Marketing Super User'
                    ,'Marketing'
                    ,''
                    ,true
                    ,true
                    ,false
                    ,false
                    ,false
                    ,false
                    ,false
                    ,null
                    ,1
                );
                //Create Partnership Manager
                generateUsers(
                    'QUT_Partnership_Manager'
                    ,'QUTeX'
                    ,'Marketing Super User'
                    ,'QUTeX_Base,QUTeX_CCE,Marketing'
                    ,''
                    ,true
                    ,true
                    ,false
                    ,false
                    ,false
                    ,false
                    ,false
                    ,null
                    ,1
                );
                //Create Quality Assurance
                generateUsers(
                    'QUT_Quality_Assurance'
                    ,'QUTeX'
                    ,'Marketing User'
                    ,'QUTeX_Base,QUTeX_CCE,Marketing'
                    ,''
                    ,true
                    ,true
                    ,false
                    ,false
                    ,false
                    ,false
                    ,false
                    ,null
                    ,1
                );
                //Create Digital Marketing Officer
                generateUsers(
                    'QUT_Digital_Marketing_Officer'
                    ,'Digital Marketing'
                    ,'Marketing User'
                    ,'Marketing'
                    ,''
                    ,true
                    ,true
                    ,false
                    ,false
                    ,false
                    ,false
                    ,false
                    ,null
                    ,1
                );
                //Create Digital Communication Officer
                generateUsers(
                    'QUT_Digital_Communication_Officer'
                    ,'QUTeX'
                    ,'Marketing User'
                    ,'QUTeX_Base,QUTeX_CCE,Marketing'
                    ,''
                    ,true
                    ,true
                    ,false
                    ,false
                    ,false
                    ,false
                    ,false
                    ,null
                    ,1
                );

                /**Start of Creation of ISR - International Student Recruitment Users */
                //Create Digital Communication Officer
                generateUsers(
                    'QUT_ISR_Communications_Manager'
                    ,'International Student Recruitment'
                    ,'International Super User'
                    ,'Enquiry_Management_Base,Email_Template_Management,Manage_Reports_and_Dashboards,Live_Chat_Supervisor' //TODO: Add "Direct Nurture Base" once available
                    ,'' // International
                    ,true
                    ,true
                    ,false
                    ,false
                    ,false
                    ,false
                    ,false
                    ,null
                    ,1
                );

                generateUsers(
                    'QUT_ISR_Student_Enquiries_Communications_Officer'
                    ,'International Student Recruitment'
                    ,'International Super User'
                    ,'Enquiry_Management_Base,Email_Template_Management,Run_Reports_and_Dashboards,Live_Chat_Agent' //TODO: Add "Direct Nurture Base" when permset is available
                    ,'' // TODO: Add "International" when public group is available
                    ,true
                    ,true
                    ,false
                    ,false
                    ,false
                    ,false
                    ,false
                    ,null
                    ,1
                );

                generateUsers(
                    'QUT_ISR_Student_Adviser'
                    ,'International Student Recruitment'
                    ,'International User'
                    ,'Enquiry_Management_Base,Run_Reports_and_Dashboards,Live_Chat_Agent' //TODO: Add "Direct Nurture Base" when permset is available
                    ,'' // TODO: Add "International" when public group is available
                    ,true
                    ,true
                    ,false
                    ,false
                    ,false
                    ,false
                    ,false
                    ,null
                    ,1
                );
                /**End of ISR - International Student Recruitment User creation */

                /** END - Creation of Marketing Users */
                generatePortalUsers(PORTAL_SYS_ADMIN.Id);
                insert addUsers;

                // get users, map userName and id.
                usermap = new Map<String,String>{};
                for(User i:addUsers){
                    usermap.put(i.userName,i.Id);
                }

                addPermissionAssignment();
                addPublicGroupAssignment();
            }//End System.runAs

            return addUsers;
        }

        private void generatePortalUsers(Id portalSysAdminId){
            List<Contact> contactList = createTestContactRecords(3);
            //Create account
            List<Account> accountList = createTestAccountRecords(3);
            for(Integer i=0; i<3; i++){
                accountList[i].Name = 'PortalAccount' + String.valueOf(i);
            }
            insert accountList;

            //Update created contacts
            for(Integer i=0; i<3; i++){
                contactList[i].FirstName = 'PortalFirst' + String.valueOf(i);
                contactList[i].LastName = 'PortalLast' + String.valueOf(i);
                contactList[i].Email = System.now().millisecond() + '@qut.com';
                contactList[i].AccountId = accountList[i].Id;
            }
            insert contactList;

            /** START - Creation of Portal Users */
            //Create Corporate Partner Admin
            generateUsers(
                'QUT_Corporate_Partner_Admin'
                ,'Corporate Partner'
                ,''
                ,'Corporate_Partner'
                ,''
                ,false
                ,false
                ,false
                ,false
                ,false
                ,false
                ,true
                ,contactList[0].Id
                ,1
            );
            //Create Corporate Partner User
            generateUsers(
                'QUT_Corporate_Partner_User'
                ,'Corporate Partner'
                ,''
                ,'Corporate_Partner'
                ,''
                ,false
                ,false
                ,false
                ,false
                ,false
                ,false
                ,true
                ,contactList[1].Id
                ,1
            );
            //Create OPE Catalogue (Study Website User)
            generateUsers(
                'QUT_OPE_Catalogue'
                ,'OPE Catalogue'
                ,'OPECatalogueCustomerUser'
                ,'OPE_Catalogue'
                ,''
                ,false
                ,false
                ,false
                ,false
                ,false
                ,false
                ,true
                ,contactList[2].Id
                ,1
            );
            /** END - Creation of Portal Users */
        }
    }

    /**
      * @description If you use SeeAllData = false in your test class, in the test execution context, there will be no affiliation mapping configured. You have to insert recors to hed__Affl_Mappings__c according to the actual production config in order to do integration test for affiliation related features
     */
    public static void configureAffiliationMapping() {
      // Configuration setup
      // As we are setting SeeAllData = false, we have to add the affiliation mapping and table driven trigger management records in order for the test to execute correctly
      List<hed__Affl_Mappings__c> ams = new List<hed__Affl_Mappings__c>();
      ams.add(new hed__Affl_Mappings__c(hed__Account_Record_Type__c = 'Business_Organization', hed__Primary_Affl_Field__c = 'hed__Primary_Organization__c', Name = 'Business_Organization'));
      ams.add(new hed__Affl_Mappings__c(hed__Account_Record_Type__c = 'University_Department', hed__Primary_Affl_Field__c = 'Primary_Department__c', Name = 'University_Department'));
      insert ams;
    }

    /**
     * @description If you use SeeAllData = false in your test class, in the test execution context, there will be no TDTM confgiured. You have to insert recors to hed__Trigger_Handler__c according to the actual production config in order to do integration test for affiliation related features
     */
    public static void configureTDTMForCONPrimaryAfflsTDTM() {
      List<hed__Trigger_Handler__c> ths = new List<hed__Trigger_Handler__c>();
      ths.add(new hed__Trigger_Handler__c(hed__Class__c = 'CON_PrimaryAffls_TDTM', hed__Object__c = 'Contact', hed__Load_Order__c = 4, hed__Trigger_Action__c = 'AfterInsert;AfterUpdate', hed__Owned_by_Namespace__c = 'hed', hed__Active__c = true));
      insert ths;
    }

    /**
     * @description Method for loading EDA Triggers from static resource
     * @param void
     * @return triggerList - list of EDA Trigger that were inserted
     */
    public static List<hed__Trigger_Handler__c> loadEDATriggers(){
      List<hed__Trigger_Handler__c> triggerList = Test.loadData(hed__Trigger_Handler__c.sObjectType, 'edaTriggerHandler');
      return triggerList;
    }
}