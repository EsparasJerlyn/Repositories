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
		TestDataFactory.generateTestUsers(new List<String>{ 'QUT_System_Administrator' });
	}

	@isTest
	static void evaluateTest() {
		System.runAs(TestDataFactory.getSystemAdminUser()) {         
			
			Breach__c breach = new Breach__c(
					Name = 'Breach Test 01'
			);
			insert breach;   
			
			Test.startTest();
			String citizenshipStatus = ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
			String academicStatus = 'Showcause';
			Date executionDate = Date.today();
			Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
			engagementListCriteria.Academic_Status__c = academicStatus;
			engagementListCriteria.Course_Grade__c = '100';
			engagementListCriteria.Failed_To_Submit_Assessment__c = 'Yes';
			engagementListCriteria.Breach__c = breach.Id;
			engagementListCriteria.Is_On_Leave_of_Absence__c = 'Yes';
			ELCProgramEnrollmentParser programEnrollmentParser = new ELCProgramEnrollmentParser(engagementListCriteria, executionDate);
			ELCLeaveOfAbsenceParser loaParser = new ELCLeaveOfAbsenceParser(engagementListCriteria, executionDate);
			ELCProgramEnrollmentBreachParser progEnrollmentBreachParser = new ELCProgramEnrollmentBreachParser(engagementListCriteria, executionDate);
			ELCCourseConnectionAssessmentParser courseConnectionAssesmentParser = new ELCCourseConnectionAssessmentParser(engagementListCriteria, executionDate);
			ELCCourseConnectionParser courseConnectionParser = new ELCCourseConnectionParser(engagementListCriteria, executionDate);

			ELCParser elcParser = new ELCParser(engagementListCriteria, executionDate);
			// Contact contact = new Contact();
			List<Contact> contactList = TestDataFactory.createTestContactRecords(3, citizenshipStatus);
			ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);

			Map<Id, Contact> contactMap = new Map<Id, Contact>();
			contactMap.put(contactList[0].Id, contactList[0]);

			ELCProgramEnrollmentEvaluator progEnrollment = new ELCProgramEnrollmentEvaluator(elcParser);
			progEnrollment.evaluate(contactMap);
			Test.stopTest();
			System.assertEquals(programEnrollmentParser.getProgramEnrollmentCriteria().getAcademicStatus(), academicStatus, 'Incorrect Academic Status');
			System.assertEquals(loaParser.getLeaveOfAbsencesCriteria().getIsOnLeave(), true, 'Is On Leave should not be false');
			System.assertEquals(progEnrollmentBreachParser.getProgramEnrollmentBreachCriteria().getBreach(), breach.Id, 'Incorrect Breach Id assigned');
			System.assertEquals(courseConnectionAssesmentParser.getCourseConnectionAssessmentCriteria().getAssessmentGrade(), null, 'Assessment grade should be null');
			System.assertEquals(courseConnectionAssesmentParser.getCourseConnectionAssessmentCriteria().getSubmissionDate(), null, 'Submission Date should be null');
			System.assertEquals(courseConnectionParser.getCourseConnectionCriteria().getCourseGrade(), '100', 'Incorrect Course Grade');
		}
	}

}