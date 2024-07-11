/**
* @description Tests the SystemKeyMatchingValidator
*
* @see SystemKeyMatchingValidator
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
private class SystemKeyMatchingValidatorTest {
    
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void buildSystemKeyMatchingMapTest(){
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactAlternateIdsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactMatchingConfigurationsDAOMock());

        List<Contact_Alternate_ID__c> contactAlternateIds = new List<Contact_Alternate_ID__c>();
        List<Contact> contactRecords = TestDataFactory.createTestContactRecords(80);
        ContactsDAO.newInstance().insertRecords(contactRecords,true,AccessLevel.SYSTEM_MODE);

        for(Integer i = 0; i < 20; i ++){
            contactAlternateIds.add(TestDataFactory.createTestConAltIdRecordByContactAndType(contactRecords[i].Id,'QUT Employee ID',contactRecords[i].Id));
        }
        for(Integer i = 20; i < 40; i ++){
            contactAlternateIds.add(TestDataFactory.createTestConAltIdRecordByContactAndType(contactRecords[i].Id,'QUT Student ID',contactRecords[i].Id));
        }
        for(Integer i = 40; i < 60; i ++){
            contactAlternateIds.add(TestDataFactory.createTestConAltIdRecordByContactAndType(contactRecords[i].Id,'StudyLink Applicant ID',contactRecords[i].Id));
        }
        for(Integer i = 60; i < 80; i ++){
            contactAlternateIds.add(TestDataFactory.createTestConAltIdRecordByContactAndType(contactRecords[i].Id,'QTAC Applicant ID',contactRecords[i].Id));
        }

        ContactAlternateIdsDAO.newInstance().insertRecords(contactAlternateIds,true,AccessLevel.SYSTEM_MODE);
        Set<Id> contactIdSet = new Map<Id,Contact>(contactRecords).keySet();
        Map<String,List<Contact>> conAltIdMapToContact = SystemKeyMatchingValidator.buildSystemKeyMatchingMap(ContactAlternateIdsDAO.newInstance().getContactAlternateIdsByContactIdSet(contactIdSet,AccessLevel.SYSTEM_MODE));

        for(String key: conAltIdMapToContact.keySet()){
            List<Contact> contactList = conAltIdMapToContact.get(key);
            system.assert(contactList.size() == 1,'there should be 1 contact related to the contact alternate id');
        }

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void isSystemKeyMatchTrueTest(){
        ContactMatchingService.MatchingAttributes matchingRecord = new ContactMatchingService.MatchingAttributes(new Map<String,String>{
            'qutEmployeeId' => 'employeeId'
        });

        Map<String, List<Contact>> systemKeyMatchingMap = new Map<String, List<Contact>>{
            'employeeIdQUT Employee ID' => new List<Contact>{
                new Contact(FirstName = 'Test')
            }
        };

        system.assertEquals(true,SystemKeyMatchingValidator.isSystemKeyMatch(matchingRecord,systemKeyMatchingMap),'system key match check should return true');

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void isSystemKeyMatchFalseTest(){
        ContactMatchingService.MatchingAttributes matchingRecord = new ContactMatchingService.MatchingAttributes(new Map<String,String>{
            'qutEmployeeId' => 'employeeId'
        });

        Map<String, List<Contact>> systemKeyMatchingMap = new Map<String, List<Contact>>();

        system.assertEquals(false,SystemKeyMatchingValidator.isSystemKeyMatch(matchingRecord,systemKeyMatchingMap),'system key match check should return true');

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void processSystemKeyMatchingSingleTest(){
        ContactMatchingService.MatchingAttributes matchingRecord = new ContactMatchingService.MatchingAttributes(new Map<String,String>{
            'qutEmployeeId' => 'employeeId'
        });

        Map<String, List<Contact>> systemKeyMatchingMap = new Map<String, List<Contact>>{
            'employeeIdQUT Employee ID' => new List<Contact>{
                new Contact(FirstName = 'Test')
            }
        };

        MatchingResult matchingResult = SystemKeyMatchingValidator.processSystemKeyMatching(matchingRecord,systemKeyMatchingMap);

        system.assertEquals(false,matchingResult.error,'there should be no error');
        system.assertEquals(1,matchingResult.contactIds.size(),'there should be 1 match');
        system.assertEquals('System Key Matching',matchingResult.matchingType,'System Key Matching should be the matching type');

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void processSystemKeyMatchingMultipleTest(){
        ContactMatchingService.MatchingAttributes matchingRecord = new ContactMatchingService.MatchingAttributes(new Map<String,String>{
            'qutEmployeeId' => 'employeeId'
        });

        MockIdGenerator mockIdGen = new MockIdGenerator(Contact.SObjectType);

        Map<String, List<Contact>> systemKeyMatchingMap = new Map<String, List<Contact>>{
            'employeeIdQUT Employee ID' => new List<Contact>{
                new Contact(FirstName = 'Test', Id = mockIdGen.getMockId()),
                new Contact(FirstName = 'Test 2' , Id = mockIdGen.getMockId())
            }
        };

        MatchingResult matchingResult = SystemKeyMatchingValidator.processSystemKeyMatching(matchingRecord,systemKeyMatchingMap);

        system.assertEquals(true,matchingResult.error,'there should be an error');
        system.assertNotEquals(1,matchingResult.contactIds.size(),'there should multple match');
        system.assertEquals('System Key Matching',matchingResult.matchingType,'System Key Matching should be the matching type');

    }
}