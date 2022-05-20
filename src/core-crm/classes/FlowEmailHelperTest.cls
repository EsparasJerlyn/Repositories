/**
 * @description Test class for FlowEmailHelper 
 *
 * @see FlowEmailHelper
 * 
 * @author Accenture
 *      
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                  |
      |---------------------------|-----------------------|----------------------|---------------------------------|
      | angelika.j.s.galang       | April 27, 2022        | DEPP-2156            | Created file                    | 
*/
@IsTest(SeeAllData = false)
private class FlowEmailHelperTest {
    
    private static final String STR_EMAIL_TEMPLATE = 'Test Email Template';
    private static final String QUTEX = System.Label.QUTeX;
    private static User currentUser = TestDataFactory.createUserRecords(1, QUTEX).iterator().next(); 

    @IsTest
    private static void sendCustomEmailTest(){
        System.runAs(currentUser){
            EmailTemplate template = TestDataFactory.createTestEmailTemplateRecords(1,new Map<String,String>{
                STR_EMAIL_TEMPLATE => 'Test Email Subject'
            }).iterator().next();
            insert template;

            FlowEmailMergeField mergeFields = new FlowEmailMergeField();
            mergeFields.mergeField = '{test}';
            mergeFields.mergeFieldValue = '123';
            
            FlowEmailHelper.EmailParameters emailParams = new FlowEmailHelper.EmailParameters();
            emailParams.recipientEmailAddresses= new List<String>{'test@test.com.invalid'};
            emailParams.emailTemplateName = STR_EMAIL_TEMPLATE;
            emailParams.mergeFields = new List<FlowEmailMergeField>{mergeFields};
            emailParams.emailSubject = '';
            emailParams.orgWideEmailAddressId = '';

            Test.startTest();
            FlowEmailHelper.sendCustomEmail(new List<FlowEmailHelper.EmailParameters>{emailParams});
            Test.stopTest();

            System.assertEquals(0, Limits.getEmailInvocations(),'Number of email invocations not as expected');
        }
    }
}
