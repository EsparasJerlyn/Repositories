/**
 * @description TestClass for StudentIdValidator
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | May 13, 2024          | DEPP-8485              | Created file                 |
 */

@isTest
private with sharing class StudentIdValidatorTest {

    @TestSetup
    static void setupMethod(){
        TestDataFactoryUser.generateUserQUTESB();
    }

    @isTest
    static void validateTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            List<Contact> contactList = TestDataFactory.createTestContactRecords(4);
            List<String> studentIds = new List<String>{'12345' ,'67890', '54321' };

            //Contact with Valid QUT Student IDs
            Integer i = 0;
            for(String studentId : studentIds ){
                contactList[i].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                contactList[i].QUT_Student__c = true;
                contactList[i].QUT_Student_ID__c = studentId;
                i++;
            }

            //Contact with Duplicate QUT Student IDs
            contactList[3].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[3].QUT_Student__c = true;
            contactList[3].QUT_Student_ID__c = '54321';

            ContactsDAO.newInstance().insertRecords(contactList,true,AccessLevel.USER_MODE);


            Test.startTest();
            List<StudentIdValidator.ValidationResult> results = StudentIdValidator.validate(new List<String>{'12345', '67890', '54321', '00000'});
            Test.stopTest();

            // Validate the first student ID (valid)
            System.assertEquals('VALID', results[0].getResultCode(), 'Validator should return a Valid result');
            System.assertEquals('12345', results[0].getStudentId(), 'Student Id should Match');

            // Validate the second student ID (valid)
            System.assertEquals('VALID', results[1].getResultCode(), 'Validator should return a Valid result');
            System.assertEquals('67890', results[1].getStudentId() , 'Student Id should Match');

            // Validate the third student ID (duplicate)
            System.assertEquals('MULTIPLE_MATCH', results[2].getResultCode(), 'Validator should return a Duplicate result' );
            System.assertEquals('54321', results[2].getStudentId(), 'Student Id should Match');

            // Validate the fourth student ID (invalid)
            System.assertEquals('INVALID', results[3].getResultCode(), 'Validator should return an Invalid result');
            System.assertEquals('00000', results[3].getStudentId(), 'Student Id should Match');
        }
    }

}   