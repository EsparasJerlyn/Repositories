/**
* @description Tests the NoDOBMatchingValidator
*
* @see NoDOBMatchingValidator
*
* @author Accenture
*
* @history
*    | Developer Email           | Date                  | JIRA       | Change Summary                  |
     |---------------------------|-----------------------|------------|---------------------------------|
     | roy.nino.s.regala         | April 06, 2024        | DEPP-7986  | Created file                    |  
*/
@SuppressWarnings('PMD.CognitiveComplexity,PMD.CyclomaticComplexity')
// Cognitive Complexity is bypassed because this Test Class is expected to have many methods for different scenarios
// Note: Test methods complexity should not be bypassed
@isTest
private class NoDOBMatchingValidatorTest {
    
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void isNoDOBMatchTrueTest(){
        
        ContactMatchingService.MatchingAttributes matchingRecord = new ContactMatchingService.MatchingAttributes(new Map<String,String>{
            'firstName' => 'firstname',
            'lastName' => 'lastname',
            'mobilePhone' => '12345'
        });

        Map<String, List<Contact>> noDOBMatchingMap = new Map<String, List<Contact>>{
            'firstnamelastname12345' => new List<Contact>{
                new Contact(LastName = 'Test')
            }
        };

        system.assertEquals(true,NoDOBMatchingValidator.isNoDOBMatch(matchingRecord,noDOBMatchingMap),'no DOB match check should return true');

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void isNoDOBMatchFalseTest(){
        ContactMatchingService.MatchingAttributes matchingRecord = new ContactMatchingService.MatchingAttributes(new Map<String,String>{
            'firstName' => 'firstname',
            'lastName' => 'lastname',
            'birthDate' => '1996-09-29',
            'email' => 'email@email.com'
        });

        Map<String, List<Contact>> noDOBMatchingMap = new Map<String, List<Contact>>();

        system.assertEquals(false,NoDOBMatchingValidator.isNoDOBMatch(matchingRecord,noDOBMatchingMap),'no DOB match check should return false');

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void processNoDOBMatchingSingleTest(){
        ContactMatchingService.MatchingAttributes matchingRecord = new ContactMatchingService.MatchingAttributes(new Map<String,String>{
            'firstName' => 'firstname',
            'lastName' => 'lastname',
            'email' => 'email@email.com'
        });

        Map<String, List<Contact>> noDOBMatchingMap = new Map<String, List<Contact>>{
            'firstnamelastnameemail@email.com' => new List<Contact>{
                new Contact(FirstName = 'Test')
            }
        };

        MatchingResult matchingResult = NoDOBMatchingValidator.processNoDOBMatching(matchingRecord,noDOBMatchingMap);

        system.assertEquals(false,matchingResult.error,'there should be no error');
        system.assertEquals(1,matchingResult.contactIds.size(),'There should be 1 match');
        system.assertEquals('No DOB Matching',matchingResult.matchingType,'No DOB Matching should be the matching type');

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void processNoDOBMatchingMultpleTest(){
        ContactMatchingService.MatchingAttributes matchingRecord = new ContactMatchingService.MatchingAttributes(new Map<String,String>{
            'firstName' => 'firstname',
            'lastName' => 'lastname',
            'email' => 'email@email.com',
            'mobilePhone' => '12345'
        });

        MockIdGenerator mockIdGen = new MockIdGenerator(Contact.SObjectType);

        Map<String, List<Contact>> noDOBMatchingMap = new Map<String, List<Contact>>{
            'firstnamelastnameemail@email.com' => new List<Contact>{
                new Contact(FirstName = 'Test', Id = mockIdGen.getMockId())
            },
            'firstnamelastname12345' => new List<Contact>{
                new Contact(FirstName = 'Test 2sdf', Id = mockIdGen.getMockId())
            }
        };

        MatchingResult matchingResult = NoDOBMatchingValidator.processNoDOBMatching(matchingRecord,noDOBMatchingMap);

        system.assertEquals(true,matchingResult.error,'there should be an error');
        system.assertNotEquals(1,matchingResult.contactIds.size(),'there should multple match');
        system.assertEquals('No DOB Matching',matchingResult.matchingType,'No DOB Matching should be the matching type');

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void buildNoDOBMatchingMapTest(){
        List<Contact> contactRecords = TestDataFactory.createTestContactRecords(0,80);
        Map<String, List<Contact>> noDOBMatchingMap = new Map<String, List<Contact>>();
        contactRecords[0].Email = null;

        for(Contact record: contactRecords){
            Contact newContact;
            newContact = (Contact) JSON.deserialize(
                '{"attributes":{"type":"Contact"},"Id":"' +
                record.Id +
                '","Matching_Firstname__c":"' +
                record.FirstName +
                '","Matching_Lastname__c":"' +
                record.LastName +
                '"}',
                Contact.class
            );

            newContact.FirstName = record.FirstName;
            newContact.LastName = record.LastName;
            newContact.Email = record.Email;
            newContact.QUT_Staff_Email__c = record.QUT_Staff_Email__c;
            newContact.QUT_Learner_Email__c = record.QUT_Learner_Email__c;
            newContact.Work_Email__c = record.Work_Email__c;
            newContact.MobilePhone = record.MobilePhone;
            NoDOBMatchingValidator.buildNoDOBMatchingMap(newContact,noDOBMatchingMap);
        }

        system.assertEquals(399, noDOBMatchingMap.keySet().size(), 'map should contain 399 contacts');
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void buildNoDOBMatchingMapEmptyTest(){
        List<Contact> contactRecords = new List<Contact>{
            new Contact(LastName = 'test')
        };
        Map<String, List<Contact>> noDOBMatchingMap = new Map<String, List<Contact>>();

        for(Contact con: contactRecords){
            NoDOBMatchingValidator.buildNoDOBMatchingMap(con,noDOBMatchingMap);
        }

        system.assertEquals(0, noDOBMatchingMap.keySet().size(), 'map should contain 0 contacts');
    }
}