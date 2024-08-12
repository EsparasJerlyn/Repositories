/**
 * @description ObjectDetailsSideComponentCtrl Test Class
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                            |
      |--------------------------------|-----------------------|------------------------|-----------------------------------------------------------|
      | eccarius.munoz                 | August 07, 2024       | DEPP-10058             | Created File                                              |
 */

@isTest
public with sharing class ObjectDetailsSideComponentCtrlTest {

    @TestSetup
    static void makeData(){
        Test.startTest();
        TestDataFactoryUser.generateUserQUTESB();
        Test.stopTest();
    }

    @isTest
    private static void getObjectDetailsMappingTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].QUT_Employee_ID__c = '123';
            ContactsDAO.newInstance().insertRecords(contactList,true,AccessLevel.SYSTEM_MODE);

            List<Case> caseList = TestDataFactory.createTestCaseRecords(CasesDAO.INBOUND_ENQUIRY_RECTYPE_ID, 'Test', 1);
            caseList[0].ContactId = contactList[0].Id;
            caseList[0].Case_Type__c = CasesDAO.CASE_TYPE_DOMESTIC;
            CasesDAO.newInstance().insertRecords(caseList,true,AccessLevel.SYSTEM_MODE);

            Map<String, String> params = new Map<String, String>{
                'parentRecordId' => caseList[0].Id,
                'parentRecord' => 'Case',
                'relatedField' => 'ContactId',
                'relatedRecord' => 'Contact',
                'relatedRecordHeader' => 'Contact.Name',
                'relatedRecordFields' => '["QUT_Employee_ID__c"]'
            };
            Test.startTest();
            String result = ObjectDetailsSideComponentCtrl.getObjectDetailsMapping(params);
            Test.stopTest();

            ObjectDetailsSideComponentCtrl.ObjectDetailsSideComponentWrapper parsedResult = (ObjectDetailsSideComponentCtrl.ObjectDetailsSideComponentWrapper) JSON.deserialize(result, ObjectDetailsSideComponentCtrl.ObjectDetailsSideComponentWrapper.class);
            System.Assert.areEqual(contactList[0].Id, parsedResult.relatedRecordId, 'Incorrect related record Id.');
            System.Assert.isNotNull(parsedResult.relatedRecordFields, 'Related Fields must not be null.');
        
        }
    }
}