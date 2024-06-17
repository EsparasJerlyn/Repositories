/**
* @description Tests the NaturalKeyMatchingValidator
*
* @see NaturalKeyMatchingValidator
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
private class NaturalKeyMatchingValidatorTest {

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void isNaturalKeyMatchTrueTest(){
        ContactMatchingService.MatchingAttributes matchingRecord = new ContactMatchingService.MatchingAttributes(new Map<String,String>{
            'firstName' => 'firstname',
            'lastName' => 'lastname',
            'birthDate' => '1996-09-29'
        });

        Map<String, List<Contact>> naturalKeyMatchingMap = new Map<String, List<Contact>>{
            'firstnamelastname1996-09-29' => new List<Contact>{
                new Contact(LastName = 'Test')
            }
        };

        system.assertEquals(true,NaturalKeyMatchingValidator.isNaturalKeyMatch(matchingRecord,naturalKeyMatchingMap),'natural key match check should return true');

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void isNaturalKeyMatchFalseTest(){
        ContactMatchingService.MatchingAttributes matchingRecord = new ContactMatchingService.MatchingAttributes(new Map<String,String>{
            'firstName' => 'firstname',
            'lastName' => 'lastname'
        });

        Map<String, List<Contact>> naturalKeyMatchingMap = new Map<String, List<Contact>>{
            'firstnamelastname' => new List<Contact>{
                new Contact(LastName = 'Test')
            }
        };

        system.assertEquals(false,NaturalKeyMatchingValidator.isNaturalKeyMatch(matchingRecord,naturalKeyMatchingMap),'natural key match check should return false');

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void processNaturalKeyMatchingSingleTest(){
        ContactMatchingService.MatchingAttributes matchingRecord = new ContactMatchingService.MatchingAttributes(new Map<String,String>{
            'firstName' => 'firstname',
            'lastName' => 'lastname',
            'birthDate' => '1996-09-29',
            'email' => 'email@email.com'
        });

        Map<String, List<Contact>> naturalKeyMatchingMap = new Map<String, List<Contact>>{
            'firstnamelastname1996-09-29' => new List<Contact>{
                new Contact(FirstName = 'Test')
            }   
        };

        MatchingResult matchingResult = NaturalKeyMatchingValidator.processNaturalKeyMatching(matchingRecord,naturalKeyMatchingMap);

        system.assertEquals(false,matchingResult.error,'there should be no error');
        system.assertEquals(1,matchingResult.contactIds.size(),'there should be 1 match');
        system.assertEquals('Natural Key Matching',matchingResult.matchingType,'Natural Key Matching should be the matching type');

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void processNaturalKeyMatchingWithNoEmailAndMobileTest(){
        ContactMatchingService.MatchingAttributes matchingRecord = new ContactMatchingService.MatchingAttributes(new Map<String,String>{
            'firstName' => 'firstname',
            'lastName' => 'lastname',
            'birthDate' => '1996-09-29'
        });

        Map<String, List<Contact>> naturalKeyMatchingMap = new Map<String, List<Contact>>{
            'firstnamelastname1996-09-29' => new List<Contact>{
                new Contact(FirstName = 'Test')
            }
        };

        MatchingResult matchingResult = NaturalKeyMatchingValidator.processNaturalKeyMatching(matchingRecord,naturalKeyMatchingMap);

        system.assertEquals(false,matchingResult.error,'there should be no error');
        system.assertEquals(1,matchingResult.contactIds.size(),'there should be 1 match');
        system.assertEquals('Natural Key Matching',matchingResult.matchingType,'Natural Key Matching should be the matching type');

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void processNaturalKeyMatchingWithEmailOrMobileFailTest(){
        ContactMatchingService.MatchingAttributes matchingRecord = new ContactMatchingService.MatchingAttributes(new Map<String,String>{
            'firstName' => 'firstname',
            'lastName' => 'lastname',
            'birthDate' => '1996-09-29',
            'email' => 'mismatch@email.com'
        });

        Map<String, List<Contact>> naturalKeyMatchingMap = new Map<String, List<Contact>>{
            'firstnamelastname1996-09-29' => new List<Contact>{
                new Contact(FirstName = 'Test',Email = 'mismatch2@email.com')
            }
        };

        MatchingResult matchingResult = NaturalKeyMatchingValidator.processNaturalKeyMatching(matchingRecord,naturalKeyMatchingMap);

        system.assertEquals(true,matchingResult.error,'there should be no error');
        system.assertEquals(0,matchingResult.contactIds.size(),'there should be no match');
        system.assertEquals('Natural Key Matching',matchingResult.matchingType,'Natural Key Matching should be the matching type');

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void processNaturalKeyMatchingMultpleTest(){
        ContactMatchingService.MatchingAttributes matchingRecord = new ContactMatchingService.MatchingAttributes(new Map<String,String>{
            'firstName' => 'firstname',
            'lastName' => 'lastname',
            'birthDate' => '1996-09-29',
            'email' => 'email@email.com',
            'mobilePhone' => '12345'
        });

        MockIdGenerator mockIdGen = new MockIdGenerator(Contact.SObjectType);

        Map<String, List<Contact>> naturalKeyMatchingMap = new Map<String, List<Contact>>{
            'firstnamelastname1996-09-29email@email.com' => new List<Contact>{
                new Contact(FirstName = 'Test', Id = mockIdGen.getMockId(), Email = 'email@email.com')
            },
            'firstnamelastname1996-09-2912345' => new List<Contact>{
                new Contact(FirstName = 'Test 2', Id = mockIdGen.getMockId(), MobilePhone = '12345')
            }
        };

        MatchingResult matchingResult = NaturalKeyMatchingValidator.processNaturalKeyMatching(matchingRecord,naturalKeyMatchingMap);

        system.assertEquals(true,matchingResult.error,'there should be an error');
        system.assertNotEquals(1,matchingResult.contactIds.size(),'there should multple match');
        system.assertEquals('Natural Key Matching',matchingResult.matchingType,'Natural Key Matching should be the matching type');

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void confirmationRuleBlankEmailMobileTest(){
        ContactMatchingService.MatchingAttributes matchingRecord = new ContactMatchingService.MatchingAttributes(new Map<String,String>{
            'firstName' => 'firstname',
            'lastName' => 'lastname',
            'birthDate' => '1996-09-29',
            'email' => 'email@email.com',
            'mobilePhone' => '12345'
        });

        MockIdGenerator mockIdGen = new MockIdGenerator(Contact.SObjectType);

        Map<String, List<Contact>> naturalKeyMatchingMap = new Map<String, List<Contact>>{
            'firstnamelastname1996-09-29' => new List<Contact>{
                new Contact(
                    FirstName = 'Test', 
                    Id = mockIdGen.getMockId(), 
                    Email = null, 
                    QUT_Learner_Email__c = null, 
                    QUT_Staff_Email__c = null, 
                    Work_Email__c = null, 
                    MobilePhone = null
                )
            }
        };

        MatchingResult matchingResult = NaturalKeyMatchingValidator.processNaturalKeyMatching(matchingRecord,naturalKeyMatchingMap);

        system.assertEquals(false,matchingResult.error,'there should be no error');
        system.assertEquals(1,matchingResult.contactIds.size(),'there should 1 match');
        system.assertEquals('Natural Key Matching',matchingResult.matchingType,'Natural Key Matching should be the matching type');

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void confirmationRuleWithEmailTest(){
        ContactMatchingService.MatchingAttributes matchingRecord = new ContactMatchingService.MatchingAttributes(new Map<String,String>{
            'firstName' => 'firstname',
            'lastName' => 'lastname',
            'birthDate' => '1996-09-29',
            'email' => 'email@email.com'
        });

        MockIdGenerator mockIdGen = new MockIdGenerator(Contact.SObjectType);

        Map<String, List<Contact>> naturalKeyMatchingMap = new Map<String, List<Contact>>{
            'firstnamelastname1996-09-29' => new List<Contact>{
                new Contact(
                    FirstName = 'Test', 
                    Id = mockIdGen.getMockId(), 
                    Email = 'mismatch@Email.com', 
                    QUT_Learner_Email__c = null, 
                    QUT_Staff_Email__c = null, 
                    Work_Email__c = null, 
                    MobilePhone = null
                )
            }
        };

        MatchingResult matchingResult = NaturalKeyMatchingValidator.processNaturalKeyMatching(matchingRecord,naturalKeyMatchingMap);

        system.assertEquals(true,matchingResult.error,'there should be no error');
        system.assertEquals('Contact Record does not match email and/or mobile provided',matchingResult.errorMessage,'there should be an error message');
        system.assertEquals(0,matchingResult.contactIds.size(),'there should no match');
        system.assertEquals('Natural Key Matching',matchingResult.matchingType,'Natural Key Matching should be the matching type');

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void confirmationRuleWithMobileTest(){
        ContactMatchingService.MatchingAttributes matchingRecord = new ContactMatchingService.MatchingAttributes(new Map<String,String>{
            'firstName' => 'firstname',
            'lastName' => 'lastname',
            'birthDate' => '1996-09-29',
            'email' => 'email@email.com',
            'mobilePhone'=> '123456789'
        });

        MockIdGenerator mockIdGen = new MockIdGenerator(Contact.SObjectType);

        Map<String, List<Contact>> naturalKeyMatchingMap = new Map<String, List<Contact>>{
            'firstnamelastname1996-09-29' => new List<Contact>{
                new Contact(
                    FirstName = 'Test', 
                    Id = mockIdGen.getMockId(), 
                    Email = null, 
                    QUT_Learner_Email__c = null, 
                    QUT_Staff_Email__c = null, 
                    Work_Email__c = null, 
                    MobilePhone = '123456780'
                )
            }
        };

        MatchingResult matchingResult = NaturalKeyMatchingValidator.processNaturalKeyMatching(matchingRecord,naturalKeyMatchingMap);

        system.assertEquals(true,matchingResult.error,'there should be no error');
        system.assertEquals('Contact Record does not match email and/or mobile provided',matchingResult.errorMessage,'there should be an error message');
        system.assertEquals(0,matchingResult.contactIds.size(),'there should no match');
        system.assertEquals('Natural Key Matching',matchingResult.matchingType,'Natural Key Matching should be the matching type');

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void buildNaturalKeyMatchingMapTest(){
        List<Contact> contactRecords = TestDataFactory.createTestContactRecords(0,80);
        Map<String, List<Contact>> naturalKeyMatchingMap = new Map<String, List<Contact>>();
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
            newContact.MobilePhone = record.MobilePhone;

            NaturalKeyMatchingValidator.buildNaturalKeyMatchingMap(newContact,naturalKeyMatchingMap);
        }

        system.assertEquals(239, naturalKeyMatchingMap.keySet().size(), 'map should contain 239 contacts');
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void buildNaturalKeyMatchingMapEmptyTest(){
        List<Contact> contactRecords = new List<Contact>{
            new Contact(LastName = 'test')
        };
        Map<String, List<Contact>> naturalKeyMatchingMap = new Map<String, List<Contact>>();

        for(Contact con: contactRecords){
            NaturalKeyMatchingValidator.buildNaturalKeyMatchingMap(con,naturalKeyMatchingMap);
        }

        system.assertEquals(0, naturalKeyMatchingMap.keySet().size(), 'map should contain 0 contacts');
    }
}