/**
 * @description DynamicQueueableProcess testclass.
 * @see ../class/DynamicQueueableProcess
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                        |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------------------------|
 *    | roy.nino.s.regala              | Oct 4, 2023           | DEPP-6426              | Created file                                          |
 *    | johanna.a.gibas                | Nov 24, 2023          | DEPP-7143              | Removed references to Priority on International Tier  |
 */
@isTest
private class DynamicQueueableProcessTest {

    private static final String FIRSTNAME = 'TestfirstName';
    private static final String LASTNAME = 'Testlastname';
    private static final String EMAIL = 'testmail@mail.test';
    private static final String BIRTHDAY = '2000-06-28';
    private static Integer recordsCount = 20;
    
    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        TestDataFactoryUser.generateUserQUTESB();
        List<International_Tier__c> tierList = TestDataFactory.createInternationalTierRecords(new List<String>{'Wales','Australia'}, 'Tier 1',true);
        insert tierList;
        List<Case_Priority_Configuration__c> casePrioConfig = TestDataFactory.createCasePrioConfigRecords();
        insert casePrioConfig;
        Test.stopTest();
    }

    @isTest
    private static void testHandleAutoPriorityAssignedCase(){
        System.runAs(TestDataFactoryUser.selectUserQUTESB){
            List<Case> cases = new List<Case>();
            cases.add(
                new Case(  
                    Status = 'Created', 
                    Auto_Priority_Assignment__c = true,
                    SuppliedPhone = '090909',
                    Origin = CasesDAO.ORIGIN_WHATSAPP,
                    RecordTypeId = CasesDAO.INBOUND_ENQUIRY_RECTYPE_ID,
                    Case_Type__c = CasesDAO.CASE_TYPE_INTERNATIONAL
                )
            );
            Test.startTest();
            CasesDAO.newInstance().insertRecords(cases, false, AccessLevel.SYSTEM_MODE);
            System.assert(cases[0].Id != null, 'case insert was not successful');
            Test.stopTest();
            
        }
    }

    private static List<hed__Application__c> createTestApplicationStudyLinkRecords(Integer startAtCount, Integer endBeforeCount, String applicationStatus) {
        List<hed__Application__c> newApplications = new List<hed__Application__c>();
        for (Integer i = startAtCount; i < endBeforeCount; i++) {
            newApplications.add(
                new hed__Application__c(
                    FirstName__c = FIRSTNAME + i,
                    LastName__c = i + LASTNAME,
                    BirthDate__c = Date.valueOf(BIRTHDAY),
                    Email__c = 'work' + i + EMAIL,
                    Application_Status__c = applicationStatus,
                    RecordTypeId = ApplicationsDAO.STUDYLINK_RECTYPE_ID
                )
            );
        }
        return newApplications;
    }
}