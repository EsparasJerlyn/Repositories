/**
 * @description Tests the Company Information Validation Controller class 
 *
 * @see CompanyInformationValidationCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA     | Change Summary                  |
      |---------------------------|-----------------------|----------|---------------------------------|
      | angelika.j.s.galang       | September 20, 2021    | DEP1-518 | Created file                    | 
      |                           |                       |          |                                 | 
*/
@isTest
private class CompanyInformationValidationCtrlTest {

    private static final String ACCOUNT_API_NAME = Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
    private static final String ACCOUNT_MAPPING = '{"label": "ABN","apiName":"ABN__c","statusValidationField":"AccountABNEntity_Validation__c","loqateRequest":"name","loqateResponse":"status"}';
    private static final String STR_QUTEX = 'QUTeX';
    private static final String STR_COMPANY_MAPPING = 'Company_Mapping__c';

    @TestSetup
    static void makeData(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    private static void getCompanyMappingTest(){
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            String mappingTest = CompanyInformationValidationCtrl.getMapping(ACCOUNT_API_NAME,STR_COMPANY_MAPPING);
            Loqate_Component__mdt loqate = (Loqate_Component__mdt) JSON.deserialize(mappingTest,Loqate_Component__mdt.class); 
            System.assertEquals(ACCOUNT_MAPPING, loqate.get(STR_COMPANY_MAPPING), 'Mapping did not match expected.');
        }
        Test.stopTest();
    }

    @isTest
    private static void validateCompanyTest(){
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            String companyValidateRequest = '[{"loqateRequest":"name","loqateResponse":"","locale":null,"statusValidationField":"","value":"54321"}]';
            String payloadResponseList = CompanyInformationValidationCtrl.validateCompany(companyValidateRequest);
            List<ContactInformationValidationCtrl.PayloadResponse> payloadResponseListParsed = 
                (List<ContactInformationValidationCtrl.PayloadResponse>) JSON.deserialize(payloadResponseList, List<ContactInformationValidationCtrl.PayloadResponse>.class);
            ContactInformationValidationCtrl.PayloadResponse companyPayloadResponse = payloadResponseListParsed.iterator().next();
            System.assertEquals('54321', companyPayloadResponse.abn, 'abn doesnt match');
            System.assertEquals('testEntityName', companyPayloadResponse.name, 'entity name doesnt match');
        }
        Test.stopTest();
    }

}