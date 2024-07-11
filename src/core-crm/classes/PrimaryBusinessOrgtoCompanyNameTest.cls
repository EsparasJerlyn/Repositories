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
@isTest
public with sharing class PrimaryBusinessOrgtoCompanyNameTest {

    @TestSetup
    static void makeData(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    private static void companyNameTest()
    {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){      
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
        System.assert(contactList.size() == 100,'Company Name is not Populated');
    }
   
}
