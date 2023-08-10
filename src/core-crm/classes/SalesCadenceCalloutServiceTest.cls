/**
 * @description Test Class for SalesCadenceCalloutService
 *
 * @see SalesCadenceCalloutService
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | mark.j.mahilum            | July 18,2023          | DEPP-5799    | Created file                                |
*/
@isTest
private class SalesCadenceCalloutServiceTest {
    private static final String FIRSTNAME = 'TestfirstName';
    private static final String LASTNAME = 'Testlastname';
    private static final String EMAIL = 'testmail@mail.test';
    private static final String BIRTHDAY = '2000-06-28';
    private static Integer recordsCount = 20;
    
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
        List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();
        Nurture_Track_Configuration__c nurtureConfig = new Nurture_Track_Configuration__c();
        nurtureConfig.Cadence_Name__c = 'Test Cadences automated';
        nurtureConfig.Lead_Score_Threshold__c = 3;
        nurtureConfig.Status__c = 'Active';
        nurtureConfig.Criteria_Type__c = 'Entry';
        nurtureList.add(nurtureConfig);
        NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureList, false, AccessLevel.SYSTEM_MODE);  
    }
    
    @isTest
    private static void testQueueableCall() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(10);  
            newContacts[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            newContacts[0].Calculated_Cadence__c = 'Test Cadences automated';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            
            Map<String,String> assignCadenceMap = new Map<String,String>();
            
            for(Contact con: newContacts){
                assignCadenceMap.put(con.Id,con.Calculated_Cadence__c);
            } 
            
            Test.startTest();
            SalesCadenceCalloutService.processSaleCadences(assignCadenceMap,assignCadenceMap);
            Test.stopTest();
            
            System.assert(![SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'SalesCadenceCalloutService'].isEmpty() , 'SalesCadenceCalloutService Queueable Job was not executed');
        }
    }

    @isTest
    private static void testContactWithCalculatedCadencesAddValue() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(10);  
            newContacts[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;           
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            
            List<Contact> updateContactList = new List<Contact>();
            for(Contact con: newContacts){
                Contact conRec = new Contact();
                conRec.Id = con.Id;
                conRec.Calculated_Cadence__c = 'Test Cadences automated1';
                updateContactList.add(conRec);
            }            
            Database.SaveResult[] srList = ContactsDAO.newInstance().updateRecords(updateContactList, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not updated.');
            }
        }
    }
    
    @isTest
    private static void testContactWithCalculatedCadencesRemoveValue() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(10);  
            newContacts[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            newContacts[0].Calculated_Cadence__c = 'Test Cadences automated';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            
            List<Contact> updateContactList = new List<Contact>();
            for(Contact con: newContacts){
                Contact conRec = new Contact();
                conRec.Id = con.Id;
                conRec.Calculated_Cadence__c = '';
                updateContactList.add(conRec);
            }            
            Database.SaveResult[] srList = ContactsDAO.newInstance().updateRecords(updateContactList, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not updated.');
            }
            System.assert(![SELECT Id FROM Completed_Cadence__c].isEmpty() , 'Completed_Cadence__c record is not created');
        }
    }


}