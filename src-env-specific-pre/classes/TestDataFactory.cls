/**
 * @description Test class that contains reusable method for test data creation
 *
 * @author Accenture
 *
* @history
*     | Developer                 | Date                  | JIRA         | Change Summary                                                   |
      |---------------------------|-----------------------|--------------|------------------------------------------------------------------|
      | roy.nino.s.regala         | September 3, 2021     | DEP1-169,170 | Created file                                                     |
      | angelika.j.s.galang       | September 3, 2021     | DEP1-156     | Added comments & method for creating user and getting profile id |
      | angelika.j.s.galang       | September 16, 2021    | DEP1-22      | Added method for creating Opportunity                            |
      | roy.nino.s.regala         | October  4,2021       | DEPP-40,42   | Added method for Product Request and Program Specification       | 
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
    * @return opps - list of Opportunities created
    */
    public static List<Opportunity> createTestOpportunityRecords(Integer numOpps, Id accId){
        List<Opportunity> opps = new List<Opportunity>();
 
        for (Integer i=0;i<numOpps;i++) {
            opps.add(new Opportunity(
                Name='TestOpportunity' + i,
                AccountId=accId,
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
    public static List<hed__Address__c> createTestHedAddressRecords(Integer numAddresses, String addressType, String parentId, String lookupApiName){
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
    * @description Method for creating test Hed Address records
    * @param numer of product request
    */
    public static List<Product_Request__c> createTestProductRequestRecords(Integer numProductRequest,List<Product_Request__c> prList,List<Program_Specification__c> psList){
        List<Product_Request__c> prodRequest = new List<Product_Request__c>();

        for (Integer i=0;i<numProductRequest;i++) {
            Product_Request__c pr = new Product_Request__c();
            pr.Product_Request_Name__c = 'TEST PR ' + i;
            pr.Parent_Product_Request__c = !prList.isEmpty()?prList[i].id:null;
            pr.Program_Specification__c =  !psList.isEmpty()?psList[0].id:null;
            prodRequest.add(pr);
        }

        return prodRequest;
    }

    /**
    * @description Method for creating test Hed Address records
    * @param numer of product request
    */
    public static List<Program_Specification__c> createTestProgramSpecsRecords(Integer numProgramSpecs,List<Contact> contacts,List<Opportunity> ops){
        List<Program_Specification__c> programSpecifications = new List<Program_Specification__c>();

        for (Integer i=0;i<numProgramSpecs;i++) {
            Program_Specification__c ps = new Program_Specification__c();
            ps.Program_Name__c = 'TEST PS ' + i;
            ps.Program_Lead__c = contacts[i].id;
            ps.Opportunity_Name__c = ops[i].id;
            ps.Status__c = 'Define';
            ps.Client_Review_Required__c = 'N/A';
            programSpecifications.add(ps);
        }

        return programSpecifications;
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

}