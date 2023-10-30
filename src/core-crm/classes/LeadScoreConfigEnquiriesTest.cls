/**
 * @description Test class for LeadScoreConfigEnquiries
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | October 06, 2023      | DEPP-5866              | Created file                 |
      |                                |                       |                        |                              |
 */
@isTest
private class LeadScoreConfigEnquiriesTest {
    @isTest
    private static void leadScoreConfigEnquiriesTest() {//NOPMD test class for getter setter, user not needed

        LeadScoreConfigEnquiries data = new LeadScoreConfigEnquiries();

        data.setApplyingForCourse(10);
        data.setCourseInformation(10);
        data.setEntryReqAndUnivStudy(10);
        data.setFeesCostScholarship(10);
        data.setMyApplicationAndOffer(10);
        data.setMyEnrollment(10);
        data.setStudentLife(10);

        System.assertEquals(10, data.getApplyingForCourse(), 'value did not match');
        System.assertEquals(10, data.getCourseInformation(), 'value did not match');
        System.assertEquals(10, data.getEntryReqAndUnivStudy(), 'value did not match');
        System.assertEquals(10, data.getFeesCostScholarship(), 'value did not match');
        System.assertEquals(10, data.getMyApplicationAndOffer(), 'value did not match');
        System.assertEquals(10, data.getMyEnrollment(), 'value did not match');
        System.assertEquals(10, data.getStudentLife(), 'value did not match');
    }
}
