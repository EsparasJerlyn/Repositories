/**
 * @description Test class for ELECandidateIngredient
 * @ELECandidateIngredient
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum                 | May 07, 2024          | DEPP-8488              | Created file                 |
 */
@isTest
public with sharing class ELECandidateIngredientTest {
    @TestSetup
    static void setupMethod(){
        TestDataFactoryUser.generateUserQUTESB();
    }

    @isTest
    static void populateELECandidateIngredientValuesTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {                      
            Test.startTest();
            //create breach record
            Breach__c breach = new Breach__c(
                Name = 'Breach Test 01'
            );
            insert breach; 
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Citizenship_Status__c = ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;
            engagementListCriteria.Academic_Status__c = 'Showcause';
            engagementListCriteria.Category_Type__c = 'Graduate Certificate';
            engagementListCriteria.Completed_Cadence__c = 'Domestic Accepted and Admitted';
            engagementListCriteria.Course_Grade__c = '100';
            engagementListCriteria.Breach__c = breach.Id;
            engagementListCriteria.Failed_To_Submit_Assessment__c = 'Yes';
            engagementListCriteria.Assessment_Priority__c = 'High';
            engagementListCriteria.Is_On_Leave_of_Absence__c = 'Yes';
            engagementListCriteria.Key_Date__c = 'Leave Of Absence End Date';
            engagementListCriteria.Key_Date_Offset_Lower_Boundary__c = -10;
            engagementListCriteria.Key_Date_Offset_Upper_Boundary__c = 10;           
            ELCParser parser = new ELCParser(engagementListCriteria, Date.Today());
            
            ELECandidateIngredient eleIngredient = new ELECandidateIngredient();            
            // set setter value
            eleIngredient.setELCParser(parser);
            eleIngredient.setContact(new Contact());
            eleIngredient.setProgramEnrollments(new List<hed__Program_Enrollment__c>());
            eleIngredient.setCourseEnrollments(new List<hed__Course_Enrollment__c>());
            eleIngredient.setCourseConnectionAssessments(new List<Course_Connection_Assessment__c>()); 
            eleIngredient.setLeaveOfAbsences(new List<Leave_of_Absence__c>()); 
            eleIngredient.setCompletedCadences(new List<Completed_Cadence__c>()); 
            eleIngredient.setProgramEnrollmentBreaches(new List<Program_Enrollment_Breach__c>()); 
            Test.stopTest();
            // Test getter
            System.assertEquals(parser, eleIngredient.getELCParser(), 'Object ELCParser value is not match');
            System.assertEquals(new Contact(), eleIngredient.getContact(),'Object Contact value is not match');
            System.assertEquals(new List<hed__Program_Enrollment__c>(), eleIngredient.getProgramEnrollments(),'Object List<hed__Program_Enrollment__c> value is not match');
            System.assertEquals(new List<hed__Course_Enrollment__c>(), eleIngredient.getCourseEnrollments(),'Object List<hed__Course_Enrollment__c> value is not match');
            System.assertEquals(new List<Course_Connection_Assessment__c>(), eleIngredient.getCourseConnectionAssessments(),'Object List<Course_Connection_Assessment__c> value is not match');
            System.assertEquals(new List<Leave_of_Absence__c>(), eleIngredient.getLeaveOfAbsences(),'Object List<Leave_of_Absence__c> value is not match');
            System.assertEquals(new List<Completed_Cadence__c>(), eleIngredient.getCompletedCadences(),'Object List<Completed_Cadence__c> value is not match');
            System.assertEquals(new List<Program_Enrollment_Breach__c>(), eleIngredient.getProgramEnrollmentBreaches(),'Object List<Program_Enrollment_Breach__c> value is not match');
        }
    }

}