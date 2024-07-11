/**
* @description Tests the PartialNaturalKeyMatchingValidator
*
* @see PartialNaturalKeyMatchingValidator
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
private class PartialNaturalKeyMatchingValidatorTest {
    

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void isPartialNaturalKeyMatchTrueTest(){
        ContactMatchingService.MatchingAttributes matchingRecord = new ContactMatchingService.MatchingAttributes(new Map<String,String>{
            'lastName' => 'lastname',
            'birthDate' => '1996-09-29',
            'mobilePhone' => '12345'
        });

        Map<String, List<Contact>> partialNaturalKeyMatchingMap = new Map<String, List<Contact>>{
            'lastname1996-09-2912345' => new List<Contact>{
                new Contact(LastName = 'Test')
            }
        };

        system.assertEquals(true,PartialNaturalKeyMatchingValidator.isPartialNaturalKeyMatch(matchingRecord,partialNaturalKeyMatchingMap),'partial natural key match check should return true');

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void isPartialNaturalKeyMatchFalseTest(){
        ContactMatchingService.MatchingAttributes matchingRecord = new ContactMatchingService.MatchingAttributes(new Map<String,String>{
            'firstName' => 'firstname',
            'lastName' => 'lastname',
            'birthDate' => '1996-09-29',
            'email' => 'email@email.com'
        });

        Map<String, List<Contact>> partialNaturalKeyMatchingMap = new Map<String, List<Contact>>();

        system.assertEquals(false,PartialNaturalKeyMatchingValidator.isPartialNaturalKeyMatch(matchingRecord,partialNaturalKeyMatchingMap),'partial natural key should return false');

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void processPartialNaturalKeyMatchingSingleTest(){
        ContactMatchingService.MatchingAttributes matchingRecord = new ContactMatchingService.MatchingAttributes(new Map<String,String>{
            'lastName' => 'lastname',
            'birthDate' => '1996-09-29',
            'email' => 'email@email.com'
        });

        Map<String, List<Contact>> partialNaturalKeyMatchingMap = new Map<String, List<Contact>>{
            'lastname1996-09-29email@email.com' => new List<Contact>{
                new Contact(FirstName = 'Test')
            }
        };

        MatchingResult matchingResult = PartialNaturalKeyMatchingValidator.processPartialNaturalKeyMatching(matchingRecord,partialNaturalKeyMatchingMap);

        system.assertEquals(false,matchingResult.error,'there should be no error');
        system.assertEquals(1,matchingResult.contactIds.size(),'there should be 1 match');
        system.assertEquals('Partial Natural Key Matching',matchingResult.matchingType,'Partial Natural Key Matching should be the matching type');

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void processPartialNaturalKeyMatchingMultpleTest(){
        ContactMatchingService.MatchingAttributes matchingRecord = new ContactMatchingService.MatchingAttributes(new Map<String,String>{
            'lastName' => 'lastname',
            'birthDate' => '1996-09-29',
            'email' => 'email@email.com',
            'mobilePhone' => '12345'
        });

        MockIdGenerator mockIdGen = new MockIdGenerator(Contact.SObjectType);

        Map<String, List<Contact>> partialNaturalKeyMatchingMap = new Map<String, List<Contact>>{
            'lastname1996-09-29email@email.com' => new List<Contact>{
                new Contact(FirstName = 'Test', Id = mockIdGen.getMockId())
            },
            'lastname1996-09-2912345' => new List<Contact>{
                new Contact(FirstName = 'Test Y2', Id = mockIdGen.getMockId())
            }
        };

        MatchingResult matchingResult = PartialNaturalKeyMatchingValidator.processPartialNaturalKeyMatching(matchingRecord,partialNaturalKeyMatchingMap);

        system.assertEquals(true,matchingResult.error,'there should be an error');
        system.assertNotEquals(1,matchingResult.contactIds.size(),'there should multple match');
        system.assertEquals('Partial Natural Key Matching',matchingResult.matchingType,'Partial Natural Key Matching should be the matching type');

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void buildPartialNaturalKeyMatchingMapTest(){
        List<Contact> contactRecords = TestDataFactory.createTestContactRecords(0,80);
        Map<String, List<Contact>> partialNaturalKeyMatchingMap = new Map<String, List<Contact>>();
        
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
            newContact.BirthDate = record.BirthDate;
            newContact.Email = record.Email;
            newContact.QUT_Staff_Email__c = record.QUT_Staff_Email__c;
            newContact.QUT_Learner_Email__c = record.QUT_Learner_Email__c;
            newContact.Work_Email__c = record.Work_Email__c;
            newContact.MobilePhone = record.MobilePhone;

            PartialNaturalKeyMatchingValidator.buildPartialNaturalKeyMatchingMap(newContact,partialNaturalKeyMatchingMap);
        }

        system.assertEquals(399, partialNaturalKeyMatchingMap.keySet().size(), 'map should contain 399 contacts');
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void buildPartialNaturalKeyMatchingMapEmptyTest(){
        List<Contact> contactRecords = new List<Contact>{
            new Contact(LastName = 'test')
        };
        Map<String, List<Contact>> partialNaturalKeyMatchingMap = new Map<String, List<Contact>>();
        
        for(Contact record: contactRecords){
            PartialNaturalKeyMatchingValidator.buildPartialNaturalKeyMatchingMap(record,partialNaturalKeyMatchingMap);
        }

        system.assertEquals(0, partialNaturalKeyMatchingMap.keySet().size(), 'map should contain 0 contacts');
    }
}