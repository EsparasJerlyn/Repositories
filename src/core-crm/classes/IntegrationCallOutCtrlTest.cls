/**
 * @description Test class for IntegrationCallOutCtrl
 * @see classes/IntegrationCallOutCtrl
 * 
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | eccarius.munoz            | February 14, 2023     | DEPP-5040    | Created file                                | 
      |                           |                       |              |                                             | 
 */
@isTest
public with sharing class IntegrationCallOutCtrlTest {

    private static final String ENDPOINT_ESB_MDM_STUDENT = System.Label.ESBEndpointMDMStudent;

    @testSetup
    static void setupData(){
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        Test.stopTest();
    }

    @isTest 
    static void testCallout() {   
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            List<Contact> contacts = TestDataFactory.createTestContactRecords(2);
            String endpoint = 'callout:ESB' + ENDPOINT_ESB_MDM_STUDENT;
            String httpMethod = 'POST';
            String payloadRequest = JSON.serialize(contacts);
            HttpResponse res = IntegrationCallOutCtrl.doCallout(endpoint, httpMethod, payloadRequest);
            Test.stopTest();

            System.assert(res.getStatusCode() != null, 'Error in integration call out.');
        }   
    }

}