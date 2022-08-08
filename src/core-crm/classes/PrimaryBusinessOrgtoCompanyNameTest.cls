/**
 * @description Test Class for Primary Business Org to Company Name  Flow
 *
 * @see ../flows/PrimaryBusinessOrgtoCompanyName
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | adrian.c.habasa           | March 01, 2022        | DEPP-1481    | Created file                                |
      |                           |                       |              |                                             | 
      |                           |                       |              |                                             | 
*/
@isTest(SeeAllData = false)
public with sharing class PrimaryBusinessOrgtoCompanyNameTest {
    private static User currentUser = TestDataFactory.createUserRecords(1, 'QUTeX').iterator().next();

    @isTest
    private static void companyNameTest()
    {
        System.runAs(currentUser){      
            List<Contact> conList = TestDataFactory.createTestContactRecords(100);   
            Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next();
            insert acc;

            Test.startTest();
            for(Contact con : conList){
                con.hed__Primary_Organization__c = acc?.Id;
            }
            insert conList;
            Test.stopTest();
        }
        
        List<Contact> contactList = [SELECT Id FROM Contact WHERE Company_Name__c != Null];
    }
   
}
