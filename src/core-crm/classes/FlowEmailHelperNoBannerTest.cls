/**
 * @description Test class for FlowEmailHelperNoBanner
 *
 * @see FlowEmailHelperNoBanner
 * 
 * @author Accenture
 *      
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                  |
      |---------------------------|-----------------------|----------------------|---------------------------------|
      | w.li                      | July 28, 2022         | DEPP-3085 | Created file                    | 
*/
@isTest
private class FlowEmailHelperNoBannerTest {
    
    private static final String STR_EMAIL_TEMPLATE = 'Test Email Template';
    private static final String QUTEX = System.Label.QUTeX;
    private static User currentUser = TestDataFactory.createUserRecords(1, QUTEX).iterator().next(); 

    @isTest
    private static void sendCustomEmailTest(){
        System.runAs(currentUser){
            EmailTemplate template = TestDataFactory.createTestEmailTemplateRecords(1,new Map<String,String>{
                STR_EMAIL_TEMPLATE => 'Test Email Subject'
            }).iterator().next();
            insert template;

            FlowEmailMergeField mergeFields = new FlowEmailMergeField();
            mergeFields.mergeField = '{test}';
            mergeFields.mergeFieldValue = '123';
            
            FlowEmailHelperNoBanner.EmailParameters emailParams = new FlowEmailHelperNoBanner.EmailParameters();
            emailParams.recipientEmailAddresses= new List<String>{'test@test.com.invalid'};
            emailParams.emailTemplateName = STR_EMAIL_TEMPLATE;
            emailParams.mergeFields = new List<FlowEmailMergeField>{mergeFields};
            emailParams.emailSubject = '';
            emailParams.orgWideEmailAddressId = '';

            Test.startTest();
            FlowEmailHelperNoBanner.sendCustomEmail(new List<FlowEmailHelperNoBanner.EmailParameters>{emailParams});
            Test.stopTest();

            System.assertEquals(0, Limits.getEmailInvocations(),'Number of email invocations not as expected');
        }
    }
}