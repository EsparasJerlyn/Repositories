/**
* @description Tests the MaidenFirstNameStemMatchingValidator
*
* @see MaidenFirstNameStemMatchingValidator
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
private class MaidenFirstNameStemMatchingValidatorTest {
    
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void isMaidenMatchTrueTest(){
        
        ContactMatchingService.MatchingAttributes matchingRecord = new ContactMatchingService.MatchingAttributes(new Map<String,String>{
            'firstName' => 'firstname',
            'lastName' => 'lastName',
            'birthDate' => '1996-09-29',
            'mobilePhone' => '12345'
        });

        Map<String, List<Contact>> maidenOrFirstNameStemMatchingMap = new Map<String, List<Contact>>{
            'firstname1996-09-2912345' => new List<Contact>{
                new Contact(LastName = 'Test')
            }
        };

        system.assertEquals(
            true,
            MaidenFirstNameStemMatchingValidator.isMaidenOrFirstNameStemMatch(
                matchingRecord,
                maidenOrFirstNameStemMatchingMap
            ),
            'Maiden Name or First Name Stem Match check should return true'
        );

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void isFirstNameStemMatchTrueTest(){
        
        ContactMatchingService.MatchingAttributes matchingRecord = new ContactMatchingService.MatchingAttributes(new Map<String,String>{
            'firstName' => 'firstname',
            'lastName' => 'lastname',
            'birthDate' => '1996-09-29',
            'mobilePhone' => '12345'
        });

        Map<String, List<Contact>> maidenOrFirstNameStemMatchingMap = new Map<String, List<Contact>>{
            'firlastname1996-09-2912345' => new List<Contact>{
                new Contact(LastName = 'Test')
            }
        };

        system.assertEquals(
            true,
            MaidenFirstNameStemMatchingValidator.isMaidenOrFirstNameStemMatch(
                matchingRecord,
                maidenOrFirstNameStemMatchingMap
            ),
            'Maiden Name or First Name Stem Match check should return true'
        );

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void isMaidenOrFirstNameStemMatchFalseTest(){
        ContactMatchingService.MatchingAttributes matchingRecord = new ContactMatchingService.MatchingAttributes(new Map<String,String>{
            'firstName' => 'firstname',
            'lastName' => 'lastname',
            'birthDate' => '1996-09-29',
            'email' => 'email@email.com'
        });

        Map<String, List<Contact>> maidenOrFirstNameStemMatchingMap = new Map<String, List<Contact>>();

        system.assertEquals(
            false,
            MaidenFirstNameStemMatchingValidator.isMaidenOrFirstNameStemMatch(
                matchingRecord,
                maidenOrFirstNameStemMatchingMap
            ),
            'Maiden Name or FirstName Stem match  should return false'
        );
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void processMaidenNameMatchingSingleTest(){
        ContactMatchingService.MatchingAttributes matchingRecord = new ContactMatchingService.MatchingAttributes(new Map<String,String>{
            'firstName' => 'firstname',
            'birthDate' => '1996-09-29',
            'mobilePhone' => '12345'
        });

        Map<String, List<Contact>> maidenOrFirstNameStemMatchingMap = new Map<String, List<Contact>>{
            'firstname1996-09-2912345' => new List<Contact>{
                new Contact(FirstName = 'Test')
            }
        };

        MatchingResult matchingResult = MaidenFirstNameStemMatchingValidator.processMaidenOrFirstNameStemMatching(matchingRecord,maidenOrFirstNameStemMatchingMap);

        system.assertEquals(false,matchingResult.error,'there should be no error');
        system.assertEquals(1,matchingResult.contactIds.size(),'there should only be 1 contact');
        system.assertEquals('Maiden Name Matching',matchingResult.matchingType,'Maiden Name Matching should be the matching type');

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void processFirstNameStemMatchingSingleTest(){
        ContactMatchingService.MatchingAttributes matchingRecord = new ContactMatchingService.MatchingAttributes(new Map<String,String>{
            'firstName' => 'firstname',
            'lastName' => 'lastname',
            'birthDate' => '1996-09-29',
            'mobilePhone' => '12345'
        });

        Map<String, List<Contact>> maidenOrFirstNameStemMatchingMap = new Map<String, List<Contact>>{
            'firlastname1996-09-2912345' => new List<Contact>{
                new Contact(FirstName = 'Test')
            }
        };

        MatchingResult matchingResult = MaidenFirstNameStemMatchingValidator.processMaidenOrFirstNameStemMatching(matchingRecord,maidenOrFirstNameStemMatchingMap);

        system.assertEquals(false,matchingResult.error,'there should be no error');
        system.assertEquals(1,matchingResult.contactIds.size(),'there should be 1 match');
        system.assertEquals('First Name Stem Matching',matchingResult.matchingType,'First Name Stem Matching should be the matching type');

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void processMaidenOrFirstNameStemMatchingMultipleTest(){
        ContactMatchingService.MatchingAttributes matchingRecord = new ContactMatchingService.MatchingAttributes(new Map<String,String>{
            'firstName' => 'firstname',
            'lastName' => 'lastname',
            'birthDate' => '1996-09-29',
            'mobilePhone' => '12345'
        });

        MockIdGenerator mockIdGen = new MockIdGenerator(Contact.SObjectType);

        Map<String, List<Contact>> maidenOrFirstNameStemMatchingMap = new Map<String, List<Contact>>{
            'firstname1996-09-2912345' => new List<Contact>{
                new Contact(FirstName = 'Test', Id = mockIdGen.getMockId())
            },
            'firlastname1996-09-2912345' => new List<Contact>{
                new Contact(FirstName = 'Test 2', Id = mockIdGen.getMockId())
            }
        };

        MatchingResult matchingResult = MaidenFirstNameStemMatchingValidator.processMaidenOrFirstNameStemMatching(matchingRecord,maidenOrFirstNameStemMatchingMap);

        system.assertEquals(true,matchingResult.error,'there should be an error');
        system.assertNotEquals(1,matchingResult.contactIds.size(),'there should multple match');
        system.assertEquals('First Name Stem Matching',matchingResult.matchingType,'First Name Stem Matching should be the matching type');

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void buildMaidenOrFirstNameStemMatchingMapTest(){
        List<Contact> contactRecords = TestDataFactory.createTestContactRecords(0,80);
        Map<String, List<Contact>> maidenOrFirstNameStemMatchingMap = new Map<String, List<Contact>>();
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
            MaidenFirstNameStemMatchingValidator.buildMaidenOrFirstNameStemMatchingMap(newContact,maidenOrFirstNameStemMatchingMap);
        }

        system.assertEquals(798, maidenOrFirstNameStemMatchingMap.keySet().size(), 'map should contain 798 contacts');
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void buildMaidenOrFirstNameStemMatchingMapEmptyTest(){
        List<Contact> contactRecords = new List<Contact>{
            new Contact(LastName = 'test')
        };

        Map<String, List<Contact>> maidenOrFirstNameStemMatchingMap = new Map<String, List<Contact>>();
        
        for(Contact con: contactRecords){
            MaidenFirstNameStemMatchingValidator.buildMaidenOrFirstNameStemMatchingMap(con,maidenOrFirstNameStemMatchingMap);
        }

        system.assertEquals(0, maidenOrFirstNameStemMatchingMap.keySet().size(), 'map should contain 0 contacts');
    }
}