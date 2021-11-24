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
      | roy.nino.s.regala         | October  4,2021       | DEPP-40,42          | Added method for Product Request and Product Specification       | 
      | adrian.c.habasa           | October 18,2021       | DEPP-476,425,383    | Added method for Course, Products,Course Offerings and Terms     |
      | roy.nino.s.regala         | November 3, 2021      | DEPP-736            | Added nethod for Opportunity Contact Roles                       |
      | adrian.c.habasa           | November 11,2021      | DEPP-664            | Added method for Asset                                           |
*/
@IsTest
public class TestDataFactory {

    private static final String STR_QUALIFY = 'Qualify';
    private static final String STR_IN_PROGRESS = 'In Progress';

    /**
    * @description Method for creating test Account records
    * @param numAccts - number of Accounts to be created
    * @return accts - list of Accounts created
    */
    public static List<Account> createTestAccountRecords(Integer numAccts) {
        List<Account> accts = new List<Account>();
        
        for(Integer i=0;i<numAccts;i++) {
            accts.add(new Account(
                Name='TestAccount' + i)
            );
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
 
        for (Integer i=0;i<numContacts;i++) {
            cons.add(new Contact(
                FirstName='Test' + i,
                LastName = 'Contact' + i)
            );
        }

        return cons;
    }

    /**
    * @description Method for creating test Lead records
    * @param numLeads - number of Leads to be created
    * @return leads - list of Leads created
    */
    public static List<Lead> createTestLeadRecords(Integer numLeads){
        List<Lead> leads = new List<Lead>();
 
        for (Integer i=0;i<numLeads;i++) {
            leads.add(new Lead(
                FirstName='TestFirstNameLead' + i,
                LastName='TestLastNameLead' + i,
                Company='TestCompany'+ i,
                Phone='1234567' + i,
                City='TestCity' + i,
                MobilePhone='1234567' + i)
            );
        }

        return leads;
    }
    
    /**
    * @description Method for creating test Opportunity records
    * @param numOpps - number of Opportunities to be created
    * @param accId - Id of related Account
    * @param conId - Id of related Contact for roles
    * @return opps - list of Opportunities created
    */
    public static List<Opportunity> createTestOpportunityRecords(Integer numOpps, Id accId, Id conId){
        List<Opportunity> opps = new List<Opportunity>();
 
        for (Integer i=0;i<numOpps;i++) {
            opps.add(new Opportunity(
                Name='TestOpportunity' + i,
                AccountId=accId,
                Contact__c=conId,
                StageName=STR_QUALIFY,
                Status__c=STR_IN_PROGRESS,
                CloseDate=System.today()+30)
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
    public static List<hed__Address__c> createTestHedAddressRecords(Integer numAddresses, String addressType,String parentId, String lookupApiName){
        List<hed__Address__c> addresses = new List<hed__Address__c>();

        for (Integer i=0;i<numAddresses;i++) {
            hed__Address__c add = new hed__Address__c();
            add.put(lookupApiName,parentId);
            add.put('hed__Address_Type__c',addressType);
            addresses.add(add);
        }

        return addresses;
    }

    /**
    * @description Method for creating test Product Request records
    * @param numProductRequest number of product request
    * @param parentProdReqs list of parent product requests
    * @param prodSpecId list of product specification
    * @return prodRequest - list of product requests
    */
    public static List<Product_Request__c> createTestProductRequestRecords(Integer numProductRequest,List<Product_Request__c> parentProdReqs,Id prodSpecId){
        List<Product_Request__c> prodRequest = new List<Product_Request__c>();

        for (Integer i=0;i<numProductRequest;i++) {
            Product_Request__c pr = new Product_Request__c();
            pr.Product_Request_Name__c = 'TEST PR ' + i;
            pr.Parent_Product_Request__c = !parentProdReqs.isEmpty()?parentProdReqs[i].id:null;
            pr.Product_Specification__c =  prodSpecId;
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
    public static List<Product_Specification__c> createTestProductSpecsRecords(Integer numProductSpecs,List<Contact> contacts,List<Opportunity> ops){
        List<Product_Specification__c> productSpecifications = new List<Product_Specification__c>();

        for (Integer i=0;i<numProductSpecs;i++) {
            Product_Specification__c ps = new Product_Specification__c();
            ps.Program_Name__c = 'TEST PS ' + i;
            ps.Program_Lead__c = contacts[i].id;
            ps.Opportunity_Name__c = ops[i].id;
            ps.Status__c = 'Define';
            ps.Client_Review_Required__c = 'N/A';
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
    public static List<hed__Course__c> createTestCourseRecords(Integer numCourses, Id accId, Id prodReqId) {
        List<hed__Course__c> courses = new List<hed__Course__c>();
 
        for (Integer i=0;i<numCourses;i++) {
            courses.add(new hed__Course__c(
                Name='Test Course ' + i,
                hed__Account__c = accId,
                ProductRequestID__c = prodReqId)
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
    public static List<User> createUserRecords(Integer numUsers, String profileName){
        List<User> users = new List<User>();
        Id userProfileId = getProfileId(profileName);
        for (Integer i=0;i<numUsers;i++) {
            users.add(new User(
                Alias = 'tuser', 
                Email='testuser@mailinator.com',
                EmailEncodingKey='UTF-8',
                LastName='TestUser',
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_AU',
                ProfileId = userProfileId,
                TimeZoneSidKey='Australia/Sydney',
                UserName='TestUser.' + i + '@mailinator.com')
            );
        }

        return users;
    }

    /**
    * @description Method for getting the Profile ID
    * @param profileName - name of the profile
    * @return ID of the profile
    */
    private static Id getProfileId(String profileName){
        return [SELECT Id FROM Profile WHERE Name =: profileName LIMIT 1]?.Id;
    }
    
    
    /**
    * @description Method for getting the Account ID
    * @return ID of the Account
    */
    public static string getAccountId(){
         Account account = new Account();
         account.Name = 'TestAccount1';
        
         insert(account);
        
         return account.Id;
    }

    /**
    * @description Method for creating Product Record
    * @param numProd - number of products to be created
    * @param cour - courses to be related to product 
    * @return productRecord - List of Products Created
    */
    public static List<Product2> createTestProductRecords(Integer numProd,List<hed__Course__c> cour)
    {
        List<Product2> productRecord = new List<Product2>();
        for(Integer i=0; i<numProd; i++)
        {
            productRecord.add(new Product2(
                Name = 'Test Product' + i,
                Course__c = cour[i].id
            ));
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
    public static List<hed__Course_Offering__c> createTestCourseOfferingRecord(Integer nCourseOffering,List<hed__Course__c> cour,List<hed__Term__c> terms)
    {
        List<hed__Course_Offering__c> courseOfferingRecord = new List<hed__Course_Offering__c>();
        for(Integer i=0; i<nCourseOffering; i++)
        {
            courseOfferingRecord.add(new hed__Course_Offering__c(
                Name = 'CourseOffering ' + i,
                hed__Course__c = cour[i].id,
                hed__Term__c = terms[i].id
            ));
        }
        return courseOfferingRecord;
    }

    /**
    * @description Method for creating Product Request Record without Program Spec Relation
    * @param numProdcutRequest - number of Product Request to be created
    * @return prodRequest - List of Product Request Created
    */
    public static List<Product_Request__c> createTestProductRequestRecords(Integer numProdcutRequest)
    {
        List<Product_Request__c> prodRequest = new List<Product_Request__c>();
        for(Integer i=0; i<numProdcutRequest;i++)
        {
            prodRequest.add(new Product_Request__c(
                Product_Request_Status__c = 'Define',
                Product_Request_Name__c = 'Test '+i,
                Program_Type__c = 'Award Course',
                Program_Name__c = 'TestP ' +i,
                Activity_Name__c = 'Act Test ' + i,
                Professional_Advantage_Value__c = 10.0
            ));
        }
        return prodRequest;
    }

    /**
    * @description Method for creating Term Record
    * @param nTerm - number of Term to be created
    * @param accountId - List of accounts to be related to terms
    * @return term - List of Product Request Created
    */
    public static List<hed__Term__c> createTestTermRecords(Integer nTerm,Id accountId)
    {
        List<hed__Term__c> term = new List<hed__Term__c>();
        for(Integer i=0; i<nTerm;i++)
        {
            term.add(new hed__Term__c (
                Name = 'Test Term ' +i,
                hed__Account__c = accountId
            ));
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
    public static List<Asset> createTestAssetRecords(Integer nAsset, Id accountId, Id productRequestId)
    {
         List<Asset> asset = new List<Asset>();
         for(Integer i=0; i < nAsset; i++)
         {
             asset.add(new Asset(Name='Test Asset' + i,
                                AccountId = accountId,
                                Product_Request__c = productRequestId
            ));
         }
         return asset;
    }

    /**
    * @description Method for creating Term Record
    * @param contactId - contact ids
    * @param oppList - list of oppportunities
    * @return oppConRole - list of opportunity contact roles
    */
    public static List<OpportunityContactRole> createTestOpportunityContactRolesRecords(Id contactId,List<Opportunity> oppList){
        List<OpportunityContactRole> oppConRole = new List<OpportunityContactRole>();
        for(Integer i=0; i<oppList.size();i++){
            oppConRole.add(new OpportunityContactRole (
                ContactId = contactId,
                OpportunityId = oppList[i].Id
            ));
        }
        return oppConRole;
    }

    /**
    * @description Method for creating Term Record
    * @param oppList - list of opportunities
    * @param status - status of envelope
    * @return envelopeStatuses - list of envelope statuses
    */
    public static List<dfsle__EnvelopeStatus__c > createTestEnvelopeStatusRecords(List<Opportunity> oppList, String status){
        List<dfsle__EnvelopeStatus__c> envelopeStatuses = new List<dfsle__EnvelopeStatus__c>();
        for(Integer i=0; i<oppList.size();i++){
            envelopeStatuses.add(new dfsle__EnvelopeStatus__c (
                dfsle__SourceId__c = oppList[i].Id,
                dfsle__Status__c = status
            ));
        }
        return envelopeStatuses;
    }

     /**
    * @description Method for creating test ContentVersion records
    * @param contentVersionNumber - number of ContentVersion to be created
    * @return contentVersionList - list of ContentVersion created
    */
    public static List<ContentVersion> createTestContentVersionRecords(Integer contentVersionNumber){
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
 
        for(Integer i=0; i < contentVersionNumber; i++){
            contentVersionList.add(new ContentVersion (
                Title = 'Proposal - General With Content_ALPHA ZENITH PTY LTD-test opportunity that may e123123123samplesample' + i,
                PathOnClient = 'test' + i,
                versiondata = EncodingUtil.base64Decode('Unit Test Attachment Body')
            ));
        }

        return contentVersionList;
    }
    
}