@isTest
public  class TestDataFactory {
    public static List<Account> createTestAccountRecords(Integer numAccts) {
        List<Account> accts = new List<Account>();
        
        for(Integer i=0;i<numAccts;i++) {
            accts.add(new Account(Name='TestAccount' + i));
        }
        return accts;
    }

    public static List<Contact> createTestContactRecords(Integer numContacts) {
        List<Contact> cons = new List<Contact>();

        for (Integer i=0;i<numContacts;i++) {
            cons.add(new Contact(FirstName='test' + i, LastName = 'test' + i));
        }
        return cons;
    }

    public static List<Lead> createTestLeadRecords(Integer numLeads){
        List<Lead> leads = new List<Lead>();

        for (Integer i=0;i<numLeads;i++) {
            leads.add(new Lead(FirstName='TestFirstNameLead' + i,LastName='TestLastNameLead' + i, Company='TestCompany'+ i, Phone='1234567' + i, City='testCity' + i, MobilePhone='1234567' + i));
        }
        return leads;
    }

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