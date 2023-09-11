/**
 * @description Test Class for Case Clear Closure Fields Flow
 * @see ../flow/Case_Clear_Closure_Fields
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------|
      | eccarius.karl.munoz            | November 21, 2022     | DEPP-4676              | Created file                               |
 */
@isTest
public with sharing class Case_Clear_Closure_FieldsFlowTest {
    @testSetup
    static void makeData(){
        Test.startTest();
        TestDataFactory.generateTestUsers();

        List<Contact> relatedContacts = TestDataFactory.createTestContactRecords(1);
        insert relatedContacts;

        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('International_Enquiry').getRecordTypeId();
        List<Case> cases = TestDataFactory.createTestCaseRecords(recordTypeId, 'Test Case', 100);
        for(Case c : cases){
            c.ContactId = relatedContacts[0].Id;
            c.Origin = 'Email';
            c.Priority = 'Low';
            c.Student_LifeCycle_Status__c = 'Prospect';
            c.Category__c = 'Student life';
            c.Status = 'Pending Closure';
            c.Closure_Code__c = 'Response Given';
            c.Closure_Details__c = 'Test Closure Details with more than 20 characters.';
        }
        insert cases;
        Test.stopTest();
    }

    @IsTest
    static void clearClosureFieldsTest(){
        System.runAs(TestDataFactory.getISRStudentEnquiriesCommunicationOfficer()){            
            List<Case> cases = [SELECT Id, Status, Origin, Priority, Student_LifeCycle_Status__c, 
                                        Category__c, Lead__c, ContactId, Closure_Code__c, Closure_Details__c
                                  FROM Case WITH SECURITY_ENFORCED];
            for(Case c : cases){
                c.Status = 'New';
            }
            update cases;

            Test.startTest();
            List<Case> casesRetrieved = [SELECT Id, Status, Closure_Code__c, Closure_Details__c
                                  FROM Case WHERE Closure_Code__c != '' WITH SECURITY_ENFORCED];
            
            System.assert(casesRetrieved.isEmpty(), 'Closure Fields should be cleared.');
            Test.stopTest();
        }
    }
}
