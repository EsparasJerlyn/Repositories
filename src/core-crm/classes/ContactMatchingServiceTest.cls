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
private class ContactMatchingServiceTest {
    
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    // With this user access cannot be tested
    private static void systemKeyMatchingSuccessTest(){
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactAlternateIdsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactMatchingConfigurationsDAOMock());

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

        for(MatchingResult matchingResult: ContactMatchingService.processContactMatching(matchingRecords).values()){
            system.assertEquals(false,matchingResult.error,'there should be no error');
            system.assertEquals(1,matchingResult.contactIds.size(),'there should a contact match');
            system.assertEquals('System Key Matching',matchingResult.matchingType,'matching type should be System Key Matching');
        }

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void systemKeyMatchingFailTest(){
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactAlternateIdsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactMatchingConfigurationsDAOMock());

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
        
        //set the value to a wrong type
        Map<String,String> systemKeyTypeMap = new Map<String,String>{
            'QUT Employee ID' => 'qutStudentId',
            'QUT Student ID' => 'qutEmployeeId',
            'StudyLink Applicant ID' => 'qtacApplicantId',
            'QTAC Applicant ID' => 'studyLinkApplicantId'
        };

        for(Contact_Alternate_ID__c conAltId: contactAlternateIds){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                systemKeyTypeMap.get(conAltId.Alternate_Id_Type__c) => conAltId.Contact_Alternate_Id__c
            }));
        }

        for(MatchingResult matchingResult: ContactMatchingService.processContactMatching(matchingRecords).values()){
            system.assertEquals(false,matchingResult.error,'there should be no error');
            system.assertEquals(0,matchingResult.contactIds.size(),'there should no contact match');
            system.assertEquals('',matchingResult.matchingType,'there should be no match');
        }

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void systemKeyMatchingMultpleMatchTest(){
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactAlternateIdsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactMatchingConfigurationsDAOMock());

        List<Contact_Alternate_ID__c> contactAlternateIds = new List<Contact_Alternate_ID__c>();
        List<ContactMatchingService.MatchingAttributes> matchingRecords = new List<ContactMatchingService.MatchingAttributes>();
        List<Contact> contactRecords = TestDataFactory.createTestContactRecords(80);
        ContactsDAO.newInstance().insertRecords(contactRecords,true,AccessLevel.SYSTEM_MODE);

        for(Integer i = 0; i < 20; i ++){
            contactAlternateIds.add(TestDataFactory.createTestConAltIdRecordByContactAndType(contactRecords[i].Id,'QUT Employee ID','qutemployeeid'));
        }
        for(Integer i = 20; i < 40; i ++){
            contactAlternateIds.add(TestDataFactory.createTestConAltIdRecordByContactAndType(contactRecords[i].Id,'QUT Student ID','qutstudentid'));
        }
        for(Integer i = 40; i < 60; i ++){
            contactAlternateIds.add(TestDataFactory.createTestConAltIdRecordByContactAndType(contactRecords[i].Id,'StudyLink Applicant ID','studylinkapplicantid'));
        }
        for(Integer i = 60; i < 80; i ++){
            contactAlternateIds.add(TestDataFactory.createTestConAltIdRecordByContactAndType(contactRecords[i].Id,'QTAC Applicant ID','qtacapplicantid'));
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

        for(MatchingResult matchingResult: ContactMatchingService.processContactMatching(matchingRecords).values()){
            system.assertEquals(true,matchingResult.error,'there should be an error');
            system.assertNotEquals(1,matchingResult.contactIds.size(),'there should multiple match');
            system.assertEquals('System Key Matching',matchingResult.matchingType,'matching type should be System Key Matching');
        }

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void partialNaturalKeyMatchingSuccessTest(){
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactAlternateIdsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactMatchingConfigurationsDAOMock());
        List<ContactMatchingService.MatchingAttributes> matchingRecords = new List<ContactMatchingService.MatchingAttributes>();
        List<Contact> contactRecords = TestDataFactory.createTestContactRecords(0,100);
        ContactsDAO.newInstance().insertRecords(contactRecords,true,AccessLevel.SYSTEM_MODE);


        for(Integer i = 0; i < 20; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'lastName' => contactRecords[i].LastName,
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email'=> contactRecords[i].Email
            }));
        }

        for(Integer i = 20; i < 40; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'lastName' => contactRecords[i].LastName,
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email' => contactRecords[i].QUT_Learner_Email__c
            }));
        }

        for(Integer i = 40; i < 60; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'lastName' => contactRecords[i].LastName,
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email' => contactRecords[i].QUT_Staff_Email__c
            }));
        }

        for(Integer i = 60; i < 80; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'lastName' => contactRecords[i].LastName,
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email' => contactRecords[i].Work_Email__c
            }));
        }

        for(Integer i = 80; i < 100; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'lastName' => contactRecords[i].LastName,
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'mobilePhone' => contactRecords[i].MobilePhone
            }));
        }

        for(MatchingResult matchingResult: ContactMatchingService.processContactMatching(matchingRecords).values()){
            system.assertEquals(false,matchingResult.error,'there should be no error');
            system.assertEquals(1,matchingResult.contactIds.size(),'there should a contact match');
            system.assertEquals('Partial Natural Key Matching',matchingResult.matchingType,'matching type should be Partial Natural Key Matching');
        }

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void partialNaturalKeyMatchingFailTest(){
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactAlternateIdsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactMatchingConfigurationsDAOMock());
        List<ContactMatchingService.MatchingAttributes> matchingRecords = new List<ContactMatchingService.MatchingAttributes>();
        List<Contact> contactRecords = TestDataFactory.createTestContactRecords(0,100);
        ContactsDAO.newInstance().insertRecords(contactRecords,true,AccessLevel.SYSTEM_MODE);


        for(Integer i = 0; i < 20; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'lastName' => contactRecords[i].LastName + 'mismatch',
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email'=> contactRecords[i].Email
            }));
        }

        for(Integer i = 20; i < 40; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'lastName' => contactRecords[i].LastName + 'mismatch',
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email' => contactRecords[i].QUT_Learner_Email__c
            }));
        }

        for(Integer i = 40; i < 60; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'lastName' => contactRecords[i].LastName + 'mismatch',
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email' => contactRecords[i].QUT_Staff_Email__c
            }));
        }

        for(Integer i = 60; i < 80; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'lastName' => contactRecords[i].LastName + 'mismatch',
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email' => contactRecords[i].Work_Email__c
            }));
        }

        for(Integer i = 80; i < 100; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'lastName' => contactRecords[i].LastName + 'mismatch',
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'mobilePhone' => contactRecords[i].MobilePhone
            }));
        }

        for(MatchingResult matchingResult: ContactMatchingService.processContactMatching(matchingRecords).values()){
            system.assertEquals(false,matchingResult.error,'there should be no error');
            system.assertEquals(0,matchingResult.contactIds.size(),'there should no match');
            system.assertEquals('',matchingResult.matchingType,'there should be no matching type');
        }

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void partialNaturalKeyMatchingMultpleMatchTest(){
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactAlternateIdsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactMatchingConfigurationsDAOMock());
        List<ContactMatchingService.MatchingAttributes> matchingRecords = new List<ContactMatchingService.MatchingAttributes>();
        List<Contact> contactRecords = TestDataFactory.createTestContactRecords(0, 100);
        for(Contact contactRecord: contactRecords){
            contactRecord.LastName = 'dup';
            contactRecord.MobilePhone = '123456789';
            contactRecord.BirthDate = System.today().addYears(-17);

            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'lastName' => contactRecord.LastName,
                'birthDate' => String.valueOf(contactRecord.BirthDate),
                'mobilePhone'=> contactRecord.MobilePhone
            }));
        }
        ContactsDAO.newInstance().insertRecords(contactRecords,true,AccessLevel.SYSTEM_MODE);

        for(MatchingResult matchingResult: ContactMatchingService.processContactMatching(matchingRecords).values()){
            system.assertEquals(true,matchingResult.error,'there should be an error');
            system.assertNotEquals(1,matchingResult.contactIds.size(),'there should multiple match');
            system.assertEquals('Partial Natural Key Matching',matchingResult.matchingType,'there should be a matching type');
        }

    }
    
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void noDOBMatchingSuccessTest(){
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactAlternateIdsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactMatchingConfigurationsDAOMock());
        List<ContactMatchingService.MatchingAttributes> matchingRecords = new List<ContactMatchingService.MatchingAttributes>();
        List<Contact> contactRecords = TestDataFactory.createTestContactRecords(0,100);
        ContactsDAO.newInstance().insertRecords(contactRecords,true,AccessLevel.SYSTEM_MODE);


        for(Integer i = 0; i < 20; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName,
                'lastName' => contactRecords[i].LastName,
                'email'=> contactRecords[i].Email
            }));
        }

        for(Integer i = 20; i < 40; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName,
                'lastName' => contactRecords[i].LastName,
                'email' => contactRecords[i].QUT_Learner_Email__c
            }));
        }

        for(Integer i = 40; i < 60; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName,
                'lastName' => contactRecords[i].LastName,
                'email' => contactRecords[i].QUT_Staff_Email__c
            }));
        }

        for(Integer i = 60; i < 80; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName,
                'lastName' => contactRecords[i].LastName,
                'email' => contactRecords[i].Work_Email__c
            }));
        }

        for(Integer i = 80; i < 100; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName,
                'lastName' => contactRecords[i].LastName,
                'mobilePhone' => contactRecords[i].MobilePhone
            }));
        }
        
        for(MatchingResult matchingResult: ContactMatchingService.processContactMatching(matchingRecords).values()){
            system.assertEquals(false,matchingResult.error,'there should be no error');
            system.assertEquals(1,matchingResult.contactIds.size(),'there should a contact match');
            system.assertEquals('No DOB Matching',matchingResult.matchingType,'matching type should be No DOB Matching');
        }

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void noDOBMatchingFailTest(){
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactAlternateIdsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactMatchingConfigurationsDAOMock());
        List<ContactMatchingService.MatchingAttributes> matchingRecords = new List<ContactMatchingService.MatchingAttributes>();
        List<Contact> contactRecords = TestDataFactory.createTestContactRecords(0,100);
        ContactsDAO.newInstance().insertRecords(contactRecords,true,AccessLevel.SYSTEM_MODE);


        for(Integer i = 0; i < 20; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName + 'mismatch',
                'lastName' => contactRecords[i].LastName,
                'email'=> contactRecords[i].Email
            }));
        }

        for(Integer i = 20; i < 40; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName + 'mismatch',
                'lastName' => contactRecords[i].LastName,
                'email' => contactRecords[i].QUT_Learner_Email__c
            }));
        }

        for(Integer i = 40; i < 60; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName + 'mismatch',
                'lastName' => contactRecords[i].LastName,
                'email' => contactRecords[i].QUT_Staff_Email__c
            }));
        }

        for(Integer i = 60; i < 80; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName + 'mismatch',
                'lastName' => contactRecords[i].LastName,
                'email' => contactRecords[i].Work_Email__c
            }));
        }

        for(Integer i = 80; i < 100; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName + 'mismatch',
                'lastName' => contactRecords[i].LastName,
                'mobilePhone' => contactRecords[i].MobilePhone
            }));
        }

        for(MatchingResult matchingResult: ContactMatchingService.processContactMatching(matchingRecords).values()){
            system.assertEquals(false,matchingResult.error,'there should be no error');
            system.assertEquals(0,matchingResult.contactIds.size(),'there should no match');
            system.assertEquals('',matchingResult.matchingType,'there should be no matching type');
        }

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void noDOBMatchingMultpleMatchTest(){
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactAlternateIdsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactMatchingConfigurationsDAOMock());
        List<ContactMatchingService.MatchingAttributes> matchingRecords = new List<ContactMatchingService.MatchingAttributes>();
        List<Contact> contactRecords = TestDataFactory.createTestContactRecords(0, 100);
        for(Contact contactRecord: contactRecords){
            contactRecord.FirstName = 'dup';
            contactRecord.LastName = 'dup';
            contactRecord.MobilePhone = '123456789';

            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecord.FirstName,
                'lastName' => contactRecord.LastName,
                'mobilePhone'=> contactRecord.MobilePhone
            }));
        }
        ContactsDAO.newInstance().insertRecords(contactRecords,true,AccessLevel.SYSTEM_MODE);

        for(MatchingResult matchingResult: ContactMatchingService.processContactMatching(matchingRecords).values()){
            system.assertEquals(true,matchingResult.error,'there should be an error');
            system.assertNotEquals(1,matchingResult.contactIds.size(),'there should multiple match');
            system.assertEquals('No DOB Matching',matchingResult.matchingType,'there should be a matching type');
        }

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void naturalKeyMatchingSuccessTest(){
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactAlternateIdsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactMatchingConfigurationsDAOMock());
        List<ContactMatchingService.MatchingAttributes> matchingRecords = new List<ContactMatchingService.MatchingAttributes>();
        List<Contact> contactRecords = TestDataFactory.createTestContactRecords(0,120);
        ContactsDAO.newInstance().insertRecords(contactRecords,true,AccessLevel.SYSTEM_MODE);


        for(Integer i = 0; i < 20; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName,
                'lastName' => contactRecords[i].LastName,
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email'=> contactRecords[i].Email
            }));
        }

        for(Integer i = 20; i < 40; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName,
                'lastName' => contactRecords[i].LastName,
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email' => contactRecords[i].QUT_Learner_Email__c
            }));
        }

        for(Integer i = 40; i < 60; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName,
                'lastName' => contactRecords[i].LastName,
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email' => contactRecords[i].QUT_Staff_Email__c
            }));
        }

        for(Integer i = 60; i < 80; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName,
                'lastName' => contactRecords[i].LastName,
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email' => contactRecords[i].Work_Email__c
            }));
        }

        for(Integer i = 80; i < 100; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName,
                'lastName' => contactRecords[i].LastName,
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'mobilePhone' => contactRecords[i].MobilePhone
            }));
        }

        for(Integer i = 100; i < 120; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName,
                'lastName' => contactRecords[i].LastName,
                'birthDate' => String.valueOf(contactRecords[i].BirthDate)
            }));
        }

        for(MatchingResult matchingResult: ContactMatchingService.processContactMatching(matchingRecords).values()){
            system.assertEquals(false,matchingResult.error,'there should be no error');
            system.assertEquals(1,matchingResult.contactIds.size(),'there should a contact match');
            system.assertEquals('Natural Key Matching',matchingResult.matchingType,'matching type should be Natural Key Matching');
        }

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void naturalKeyMatchingFailTest(){
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactAlternateIdsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactMatchingConfigurationsDAOMock());
        List<ContactMatchingService.MatchingAttributes> matchingRecords = new List<ContactMatchingService.MatchingAttributes>();
        List<Contact> contactRecords = TestDataFactory.createTestContactRecords(0,120);
        ContactsDAO.newInstance().insertRecords(contactRecords,true,AccessLevel.SYSTEM_MODE);


        for(Integer i = 0; i < 20; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName + 'mismatch',
                'lastName' => contactRecords[i].LastName + 'mismatch',
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email'=> contactRecords[i].Email
            }));
        }

        for(Integer i = 20; i < 40; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName + 'mismatch',
                'lastName' => contactRecords[i].LastName + 'mismatch',
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email' => contactRecords[i].QUT_Learner_Email__c
            }));
        }

        for(Integer i = 40; i < 60; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName + 'mismatch',
                'lastName' => contactRecords[i].LastName + 'mismatch',
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email' => contactRecords[i].QUT_Staff_Email__c
            }));
        }

        for(Integer i = 60; i < 80; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName + 'mismatch',
                'lastName' => contactRecords[i].LastName + 'mismatch',
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email' => contactRecords[i].Work_Email__c
            }));
        }

        for(Integer i = 80; i < 100; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName + 'mismatch',
                'lastName' => contactRecords[i].LastName + 'mismatch',
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'mobilePhone' => contactRecords[i].MobilePhone
            }));
        }

        for(Integer i = 100; i < 120; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName + 'mismatch',
                'lastName' => contactRecords[i].LastName + 'mismatch',
                'birthDate' => String.valueOf(contactRecords[i].BirthDate)
            }));
        }

        for(MatchingResult matchingResult: ContactMatchingService.processContactMatching(matchingRecords).values()){
            system.assertEquals(false,matchingResult.error,'there should be no error');
            system.assertEquals(0,matchingResult.contactIds.size(),'there should no match');
            system.assertEquals('',matchingResult.matchingType,'there should be no matching type');
        }

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void naturalKeyMatchingMultpleMatchTest(){
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactAlternateIdsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactMatchingConfigurationsDAOMock());
        List<ContactMatchingService.MatchingAttributes> matchingRecords = new List<ContactMatchingService.MatchingAttributes>();
        List<Contact> contactRecords = TestDataFactory.createTestContactRecords(0, 100);
        for(Contact contactRecord: contactRecords){
            contactRecord.FirstName = 'dup';
            contactRecord.LastName = 'dup';
            contactRecord.BirthDate = System.today().addYears(-17);
            contactRecord.MobilePhone = '123456789';

            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecord.LastName,
                'lastName' => contactRecord.LastName,
                'birthDate' => String.valueOf(contactRecord.BirthDate),
                'mobilePhone'=> contactRecord.MobilePhone
            }));
        }
        ContactsDAO.newInstance().insertRecords(contactRecords,true,AccessLevel.SYSTEM_MODE);

        for(MatchingResult matchingResult: ContactMatchingService.processContactMatching(matchingRecords).values()){
            system.assertEquals(true,matchingResult.error,'there should be an error');
            system.assertNotEquals(1,matchingResult.contactIds.size(),'there should multiple match');
            system.assertEquals('Natural Key Matching',matchingResult.matchingType,'there should be a matching type');
        }

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void maidenNameMatchingSuccessTest(){
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactAlternateIdsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactMatchingConfigurationsDAOMock());
        List<ContactMatchingService.MatchingAttributes> matchingRecords = new List<ContactMatchingService.MatchingAttributes>();
        List<Contact> contactRecords = TestDataFactory.createTestContactRecords(0,100);
        ContactsDAO.newInstance().insertRecords(contactRecords,true,AccessLevel.SYSTEM_MODE);


        for(Integer i = 0; i < 20; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName,
                'lastName' => contactRecords[i].LastName +'mismatch',
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email'=> contactRecords[i].Email
            }));
        }

        for(Integer i = 20; i < 40; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName,
                'lastName' => contactRecords[i].LastName +'mismatch',
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email' => contactRecords[i].QUT_Learner_Email__c
            }));
        }

        for(Integer i = 40; i < 60; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName,
                'lastName' => contactRecords[i].LastName +'mismatch',
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email' => contactRecords[i].QUT_Staff_Email__c
            }));
        }

        for(Integer i = 60; i < 80; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName,
                'lastName' => contactRecords[i].LastName +'mismatch',
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email' => contactRecords[i].Work_Email__c
            }));
        }

        for(Integer i = 80; i < 100; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName,
                'lastName' => contactRecords[i].LastName +'mismatch',
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'mobilePhone' => contactRecords[i].MobilePhone
            }));
        }

        for(MatchingResult matchingResult: ContactMatchingService.processContactMatching(matchingRecords).values()){
            system.assertEquals(false,matchingResult.error,'there should be no error');
            system.assertEquals(1,matchingResult.contactIds.size(),'there should a contact match');
            system.assertEquals('Maiden Name Matching',matchingResult.matchingType,'matching type should be Maiden Name or First Name Stem Matching');
        }

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void maidenNameMatchingFailTest(){
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactAlternateIdsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactMatchingConfigurationsDAOMock());
        List<ContactMatchingService.MatchingAttributes> matchingRecords = new List<ContactMatchingService.MatchingAttributes>();
        List<Contact> contactRecords = TestDataFactory.createTestContactRecords(0,100);
        ContactsDAO.newInstance().insertRecords(contactRecords,true,AccessLevel.SYSTEM_MODE);


        for(Integer i = 0; i < 20; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName + 'mismatch',
                'lastName' => contactRecords[i].LastName + 'mismatch',
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email'=> contactRecords[i].Email
            }));
        }

        for(Integer i = 20; i < 40; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName + 'mismatch',
                'lastName' => contactRecords[i].LastName + 'mismatch',
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email' => contactRecords[i].QUT_Learner_Email__c
            }));
        }

        for(Integer i = 40; i < 60; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName + 'mismatch',
                'lastName' => contactRecords[i].LastName + 'mismatch',
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email' => contactRecords[i].QUT_Staff_Email__c
            }));
        }

        for(Integer i = 60; i < 80; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName + 'mismatch',
                'lastName' => contactRecords[i].LastName + 'mismatch',
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email' => contactRecords[i].Work_Email__c
            }));
        }

        for(Integer i = 80; i < 100; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName + 'mismatch',
                'lastName' => contactRecords[i].LastName + 'mismatch',
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'mobilePhone' => contactRecords[i].MobilePhone
            }));
        }

        for(MatchingResult matchingResult: ContactMatchingService.processContactMatching(matchingRecords).values()){
            system.assertEquals(false,matchingResult.error,'there should be no error');
            system.assertEquals(0,matchingResult.contactIds.size(),'there should no match');
            system.assertEquals('',matchingResult.matchingType,'there should be no matching type');
        }

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void maidenNameMatchingMultpleMatchTest(){
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactAlternateIdsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactMatchingConfigurationsDAOMock());
        List<ContactMatchingService.MatchingAttributes> matchingRecords = new List<ContactMatchingService.MatchingAttributes>();
        List<Contact> contactRecords = TestDataFactory.createTestContactRecords(0, 100);
        for(Contact contactRecord: contactRecords){
            contactRecord.FirstName = 'dup';
            contactRecord.LastName = 'dup';
            contactRecord.BirthDate = System.today().addYears(-17);
            contactRecord.MobilePhone = '123456789';

            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecord.LastName,
                'lastName' => contactRecord.LastName + 'mismatch',
                'birthDate' => String.valueOf(contactRecord.BirthDate),
                'mobilePhone'=> contactRecord.MobilePhone
            }));
        }
        ContactsDAO.newInstance().insertRecords(contactRecords,true,AccessLevel.SYSTEM_MODE);

        for(MatchingResult matchingResult: ContactMatchingService.processContactMatching(matchingRecords).values()){
            system.assertEquals(true,matchingResult.error,'there should be an error');
            system.assertNotEquals(1,matchingResult.contactIds.size(),'there should multiple match');
            system.assertEquals('Maiden Name Matching',matchingResult.matchingType,'there should be a matching type');
        }

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void firstNameStemMatchingSuccessTest(){
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactAlternateIdsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactMatchingConfigurationsDAOMock());
        List<ContactMatchingService.MatchingAttributes> matchingRecords = new List<ContactMatchingService.MatchingAttributes>();
        List<Contact> contactRecords = TestDataFactory.createTestContactRecords(0,100);
        ContactsDAO.newInstance().insertRecords(contactRecords,true,AccessLevel.SYSTEM_MODE);


        for(Integer i = 0; i < 20; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName + 'mismatch',
                'lastName' => contactRecords[i].LastName,
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email'=> contactRecords[i].Email
            }));
        }

        for(Integer i = 20; i < 40; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName + 'mismatch',
                'lastName' => contactRecords[i].LastName,
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email' => contactRecords[i].QUT_Learner_Email__c
            }));
        }

        for(Integer i = 40; i < 60; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName + 'mismatch',
                'lastName' => contactRecords[i].LastName,
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email' => contactRecords[i].QUT_Staff_Email__c
            }));
        }

        for(Integer i = 60; i < 80; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName + 'mismatch',
                'lastName' => contactRecords[i].LastName,
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email' => contactRecords[i].Work_Email__c
            }));
        }

        for(Integer i = 80; i < 100; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName + 'mismatch',
                'lastName' => contactRecords[i].LastName,
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'mobilePhone' => contactRecords[i].MobilePhone
            }));
        }

        for(MatchingResult matchingResult: ContactMatchingService.processContactMatching(matchingRecords).values()){
            system.assertEquals(false,matchingResult.error,'there should be no error');
            system.assertEquals(1,matchingResult.contactIds.size(),'there should a contact match');
            system.assertEquals('First Name Stem Matching',matchingResult.matchingType,'matching type should be Maiden Name or First Name Stem Matching');
        }

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void firstNameStemMatchingFailTest(){
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactAlternateIdsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactMatchingConfigurationsDAOMock());
        List<ContactMatchingService.MatchingAttributes> matchingRecords = new List<ContactMatchingService.MatchingAttributes>();
        List<Contact> contactRecords = TestDataFactory.createTestContactRecords(0,100);
        ContactsDAO.newInstance().insertRecords(contactRecords,true,AccessLevel.SYSTEM_MODE);


        for(Integer i = 0; i < 20; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName + 'mismatch',
                'lastName' => contactRecords[i].LastName + 'mismatch',
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email'=> contactRecords[i].Email
            }));
        }

        for(Integer i = 20; i < 40; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName + 'mismatch',
                'lastName' => contactRecords[i].LastName + 'mismatch',
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email' => contactRecords[i].QUT_Learner_Email__c
            }));
        }

        for(Integer i = 40; i < 60; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName + 'mismatch',
                'lastName' => contactRecords[i].LastName + 'mismatch',
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email' => contactRecords[i].QUT_Staff_Email__c
            }));
        }

        for(Integer i = 60; i < 80; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName + 'mismatch',
                'lastName' => contactRecords[i].LastName + 'mismatch',
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email' => contactRecords[i].Work_Email__c
            }));
        }

        for(Integer i = 80; i < 100; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName + 'mismatch',
                'lastName' => contactRecords[i].LastName + 'mismatch',
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'mobilePhone' => contactRecords[i].MobilePhone
            }));
        }

        for(MatchingResult matchingResult: ContactMatchingService.processContactMatching(matchingRecords).values()){
            system.assertEquals(false,matchingResult.error,'there should be no error');
            system.assertEquals(0,matchingResult.contactIds.size(),'there should no match');
            system.assertEquals('',matchingResult.matchingType,'there should be no matching type');
        }

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void firstNameStemMatchingMultpleMatchTest(){
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactAlternateIdsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactMatchingConfigurationsDAOMock());
        List<ContactMatchingService.MatchingAttributes> matchingRecords = new List<ContactMatchingService.MatchingAttributes>();
        List<Contact> contactRecords = TestDataFactory.createTestContactRecords(0, 100);
        for(Contact contactRecord: contactRecords){
            contactRecord.FirstName = 'dup';
            contactRecord.LastName = 'dup';
            contactRecord.BirthDate = System.today().addYears(-17);
            contactRecord.MobilePhone = '123456789';

            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecord.FirstName + 'mismatch',
                'lastName' => contactRecord.LastName,
                'birthDate' => String.valueOf(contactRecord.BirthDate),
                'mobilePhone'=> contactRecord.MobilePhone
            }));
        }
        ContactsDAO.newInstance().insertRecords(contactRecords,true,AccessLevel.SYSTEM_MODE);

        for(MatchingResult matchingResult: ContactMatchingService.processContactMatching(matchingRecords).values()){
            system.assertEquals(true,matchingResult.error,'there should be an error');
            system.assertNotEquals(1,matchingResult.contactIds.size(),'there should multiple match');
            system.assertEquals('First Name Stem Matching',matchingResult.matchingType,'there should be a matching type');
        }

    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void insufficientInfoToMatchTest(){
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactAlternateIdsDAOMock());
        ImplementationSelector.DAO.setMock(new ContactMatchingConfigurationsDAOMock());
        List<ContactMatchingService.MatchingAttributes> matchingRecords = new List<ContactMatchingService.MatchingAttributes>();
        List<Contact> contactRecords = TestDataFactory.createTestContactRecords(0, 100);
        for(Integer i = 0; i < 20; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName
            }));
        }

        for(Integer i = 20; i < 40; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'firstName' => contactRecords[i].FirstName,
                'lastName' => ''
            }));
        }

        for(Integer i = 40; i < 60; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'birthDate' => String.valueOf(contactRecords[i].BirthDate),
                'email' => contactRecords[i].QUT_Staff_Email__c
            }));
        }

        for(Integer i = 60; i < 80; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'email' => contactRecords[i].Work_Email__c
            }));
        }

        for(Integer i = 80; i < 100; i ++ ){
            matchingRecords.add(new ContactMatchingService.MatchingAttributes(new Map<String,String>{
                'mobilePhone' => contactRecords[i].MobilePhone
            }));
        }
        ContactsDAO.newInstance().insertRecords(contactRecords,true,AccessLevel.SYSTEM_MODE);

        for(MatchingResult matchingResult: ContactMatchingService.processContactMatching(matchingRecords).values()){
            system.assertEquals(true,matchingResult.error,'there should be an error');
            system.assertEquals(0,matchingResult.contactIds.size(),'there should no match');
            system.assertEquals('',matchingResult.matchingType,'there should be no matching');
        }

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
            system.assertEquals(1,matchingResult.contactIds.size(),'there should a contact match');
            system.assertEquals('Maiden Name Matching',matchingResult.matchingType,'there should be a matching type');
        }

        Set<Id> contactIdSet = new Map<Id,Contact>(contactRecords).keySet();
        List<Contact_Alternate_ID__c> conAltIdList =  ContactAlternateIdsDAO.newInstance().getContactAlternateIdsByContactIdSet(contactIdSet,AccessLevel.SYSTEM_MODE);

        system.assertEquals(100,conAltIdList.size(), 'there should be a 100 new contact alternate ids');

        for(Contact_Alternate_ID__c conAltId: conAltIdList){
            system.assert(conAltId.Contact__r.QUT_Employee_ID__c.contains('employeeId'),'contacts employee id shouldve been updated');
            system.assertEquals('QUT Employee ID',conAltId.Alternate_Id_Type__c,'Alternate Id Type Should be QUT Employee ID');
            system.assertEquals('Active',conAltId.Alternate_Id_Status__c,'Alternate Id Status Should be Active');
        }
       
    }

}