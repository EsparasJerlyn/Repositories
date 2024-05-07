/**
 * @description Test class for ELCProgramEnrollmentEvaluator
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                              |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------|
      | kim.howard.capanas             | May 6, 2024           | DEPP-8488              | Created file                                                |
*/
@isTest
private class ELCProgramEnrollmentEvaluatorTest{

	@TestSetup
	static void setupMethod(){
		TestDataFactory.generateTestUsers(new List<String>{ 'QUT_ESB' });
	}

	@isTest
	static void evaluateTest() {
		System.runAs(TestDataFactory.getESBIntegrationUser()) {            
			
			Test.startTest();
			String citizenshipStatus = ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
			String academicStatus = 'Showcause';
			Date executionDate = Date.today();
			Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
			engagementListCriteria.Academic_Status__c = academicStatus;
			ELCProgramEnrollmentParser parser = new ELCProgramEnrollmentParser(engagementListCriteria, executionDate);

			ELCParser elcParser = new ELCParser(engagementListCriteria, executionDate);
			// Contact contact = new Contact();
			List<Contact> contactList = TestDataFactory.createTestContactRecords(3, citizenshipStatus);
			ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);

			Map<Id, Contact> contactMap = new Map<Id, Contact>();
			contactMap.put(contactList[0].Id, contactList[0]);

			ELCProgramEnrollmentEvaluator progEnrollment = new ELCProgramEnrollmentEvaluator(elcParser);
			progEnrollment.evaluate(contactMap);
			Test.stopTest();
			System.assertEquals(parser.getProgramEnrollmentCriteria().academicStatus, academicStatus, 'Incorrect Academic Status');
		}
	}

}