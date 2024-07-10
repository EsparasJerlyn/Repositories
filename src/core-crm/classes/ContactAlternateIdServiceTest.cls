/**
* @description Tests the ContactMatchingService
*
* @see ContactMatchingService
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
private class ContactAlternateIdServiceTest {
    
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void retrieveContactAlternateIdsBySystemKeyIdTest(){

        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactAlternateIdsDAOMock());

        List<Contact_Alternate_ID__c> contactAlternateIds = new List<Contact_Alternate_ID__c>();
        List<ContactMatchingService.MatchingAttributes> matchingRecords = new List<ContactMatchingService.MatchingAttributes>();
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
        
        Map<String,String> systemKeyTypeMap = new Map<String,String>{
            'QUT Employee ID' => 'qutEmployeeId',
            'QUT Student ID' => 'qutStudentId',
            'StudyLink Applicant ID' => 'studyLinkApplicantId',
            'QTAC Applicant ID' => 'qtacApplicantId'
        };

        for(Contact_Alternate_ID__c conAltId: contactAlternateIds){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                systemKeyTypeMap.get(conAltId.Alternate_Id_Type__c) => conAltId.Contact_Alternate_Id__c
            }));
        }

        system.assertEquals(80,ContactAlternateIdService.retrieveContactAlternateIdsBySystemKeyId(matchingRecords).size(),'Contact alternate id records count should be 80');
    }


    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void employeeIdKeyChangeTest(){
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactAlternateIdsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactMatchingConfigurationsDAOMock());
        List<ContactMatchingService.MatchingAttributes> matchingRecords = new List<ContactMatchingService.MatchingAttributes>();
        List<Contact> contactRecords = TestDataFactory.createTestContactRecords(0,100);
        ContactsDAO.newInstance().insertRecords(contactRecords,true,AccessLevel.SYSTEM_MODE);

        for(Integer i = 0; i < 20; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName,
                'lastName' => contactRecords[i].LastName + 'mismatch',
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email'=> contactRecords[i].Email,
                'qutEmployeeId' => 'employeeId' + i
            }));
        }

        for(Integer i = 20; i < 40; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName,
                'lastName' => contactRecords[i].LastName + 'mismatch',
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email' => contactRecords[i].QUT_Learner_Email__c,
                'qutEmployeeId' => 'employeeId' + i
            }));
        }

        for(Integer i = 40; i < 60; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName,
                'lastName' => contactRecords[i].LastName + 'mismatch',
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email' => contactRecords[i].QUT_Staff_Email__c,
                'qutEmployeeId' => 'employeeId' + i
            }));
        }

        for(Integer i = 60; i < 80; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName,
                'lastName' => contactRecords[i].LastName + 'mismatch',
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email' => contactRecords[i].Work_Email__c,
                'qutEmployeeId' => 'employeeId' + i
            }));
        }

        for(Integer i = 80; i < 100; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName,
                'lastName' => contactRecords[i].LastName + 'mismatch',
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'mobilePhone' => contactRecords[i].MobilePhone,
                'qutEmployeeId' => 'employeeId' + i
            }));
        }

        for(MatchingResult matchingResult: ContactMatchingService.processContactMatchingWithKeyChange(matchingRecords).values()){
            system.assertEquals(false,matchingResult.error,'there should be no error');
            system.assertEquals(1,matchingResult.contactIds.size(),'there should be a contact match');
            system.assertEquals('Maiden Name Matching',matchingResult.matchingType,'there should be a matching type');
        }

        Set<Id> contactIdSet = new Map<Id,Contact>(contactRecords).keySet();
        List<Contact_Alternate_ID__c> conAltIdList =  ContactAlternateIdsDAO.newInstance().getContactAlternateIdsByContactIdSet(contactIdSet,AccessLevel.SYSTEM_MODE);

        system.assert(conAltIdList.size() == 100, 'there should be a 100 new contact alternate ids');

        for(Contact_Alternate_ID__c conAltId: conAltIdList){
            system.assert(conAltId.Contact__r.QUT_Employee_ID__c.contains('employeeId'),'contacts employee id shouldve been updated');
            system.assertEquals('QUT Employee ID',conAltId.Alternate_Id_Type__c,'Alternate Id Type Should be QUT Employee ID');
            system.assertEquals('Active',conAltId.Alternate_Id_Status__c,'Alternate Id Status Should be Active');
        }
       
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void studentIdKeyChangeUpdateExistingCAITest(){
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactAlternateIdsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactMatchingConfigurationsDAOMock());
        List<ContactMatchingService.MatchingAttributes> matchingRecords = new List<ContactMatchingService.MatchingAttributes>();
        List<Contact> contactRecords = TestDataFactory.createTestContactRecords(0,20);
        List<Contact_Alternate_ID__c> contactAlternateIds = new List<Contact_Alternate_ID__c>();
        ContactsDAO.newInstance().insertRecords(contactRecords,true,AccessLevel.SYSTEM_MODE);

        for(Integer i = 0; i < 20; i ++){
            contactAlternateIds.add(TestDataFactory.createTestConAltIdRecordByContactAndType(contactRecords[i].Id,'QUT Student ID',contactRecords[i].Id));
        }

        ContactAlternateIdsDAO.newInstance().insertRecords(contactAlternateIds,true,AccessLevel.SYSTEM_MODE);

        for(Integer i = 0; i < 20; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName,
                'lastName' => contactRecords[i].LastName + 'mismatch',
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email'=> contactRecords[i].Email,
                'qutStudentId' => 'studentId' + i,
                'qtacApplicantId' => 'qtacApplicantId' + i
            }));
        }

        for(MatchingResult matchingResult: ContactMatchingService.processContactMatchingWithKeyChange(matchingRecords).values()){
            system.assertEquals(false,matchingResult.error,'there should be no error');
            system.assertEquals(1,matchingResult.contactIds.size(),'there should be a contact match');
            system.assertEquals('Maiden Name Matching',matchingResult.matchingType,'there should be a matching type');
        }

        Set<Id> contactIdSet = new Map<Id,Contact>(contactRecords).keySet();
        List<Contact_Alternate_ID__c> conAltIdList =  ContactAlternateIdsDAO.newInstance().getContactAlternateIdsByContactIdSet(contactIdSet,AccessLevel.SYSTEM_MODE);

        system.assertEquals(40,conAltIdList.size(), 'there should be 40 active contact alternate ids');

        for(Contact_Alternate_ID__c conAltId: conAltIdList){
            system.assert(conAltId.Contact__r.QUT_Student_ID__c.contains('studentId'),'contacts employee id shouldve been updated');
            system.assert(conAltId.Alternate_Id_Type__c == 'QUT Student ID' || conAltId.Alternate_Id_Type__c == 'QTAC Applicant ID',
                            'Alternate Id Type Should be QUT Student ID or QTAC Applicant ID');
            system.assertEquals('Active',conAltId.Alternate_Id_Status__c,'Alternate Id Status Should be Active');
        }
    }
}