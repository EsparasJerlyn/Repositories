/**
 * @description Tests the Contact Information Validation Controller class 
 *
 * @see ContactInformationValidationCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA     | Change Summary                  |
      |---------------------------|-----------------------|----------|---------------------------------|
      | angelika.j.s.galang       | September 3, 2021     | DEP1-156 | Created file                    | 
      | angelika.j.s.galang       | September 8, 2021     | DEP1-157 | Added test methods for callouts | 
*/
@IsTest(SeeAllData = false)
private class ContactInformationValidationCtrlTest {
    
    private static final String ACCOUNT_API_NAME = Account.SObjectType.getDescribe().getLocalName();
	private static final String OPP_API_NAME = Opportunity.SObjectType.getDescribe().getLocalName();
    private static final String AURA_EX_MSG = 'Error while getting field mapping.';
    private static final String ACCOUNT_MAPPING = '{"label": "ABN","apiName":"ABN__c","statusValidationField":"AccountABNEntity_Validation__c","loqateRequest":"name","loqateResponse":"status"}';
    private static final String STR_QUTeX = 'QUTeX';
    private static final String STR_COMPANY_MAPPING = 'Company_Mapping__c';
    private static User currentUser = TestDataFactory.createUserRecords(1, STR_QUTeX).iterator().next();

    @IsTest
    private static void getMappingSuccessTest(){
        Test.startTest();
        System.runAs(currentUser){
            String mappingTest = ContactInformationValidationCtrl.getMapping(ACCOUNT_API_NAME,STR_COMPANY_MAPPING);
            System.assertEquals(ACCOUNT_MAPPING, mappingTest, 'Mapping did not match expected.');
        }
        Test.stopTest();
    }

    @IsTest
    private static void getMappingErrorTest(){
        Test.startTest();
        System.runAs(currentUser){
            try{
                String mappingTest = ContactInformationValidationCtrl.getMapping(OPP_API_NAME,STR_COMPANY_MAPPING);
            }catch(AuraHandledException ex){
                System.assert(ex.getMessage().contains(AURA_EX_MSG), 'Exception did not match expected.');
            }
        }
        Test.stopTest();
    }

    @IsTest
    private static void validatePhoneFieldsTest(){
        Test.startTest();
        System.runAs(currentUser){
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            String phoneValidateRequest = '[{"loqateRequest":"fullPhone","loqateResponse":"","locale":"AU","statusValidationField":"","value":"1234"}]';
            ContactInformationValidationCtrl.PayloadResponse phonePayloadResponse = getPayloadResponse(phoneValidateRequest);
            System.assertEquals('1234', phonePayloadResponse.fullPhone, 'phone doesnt match');
            System.assertEquals('AU', phonePayloadResponse.country, 'country doesnt match');
            System.assertEquals('connected|Network confirmed connection', phonePayloadResponse.phoneStatus, 'phoneStatus doesnt match');
        }
        Test.stopTest();
    }

    @IsTest
    private static void validateCompanyFieldsTest(){
        Test.startTest();
        System.runAs(currentUser){
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            String companyValidateRequest = '[{"loqateRequest":"name","loqateResponse":"","locale":null,"statusValidationField":"","value":"54321"}]';
            ContactInformationValidationCtrl.PayloadResponse companyPayloadResponse = getPayloadResponse(companyValidateRequest);
            System.assertEquals('54321', companyPayloadResponse.abn, 'abn doesnt match');
            System.assertEquals('testEntityName', companyPayloadResponse.name, 'entity name doesnt match');
        }
        Test.stopTest();
    }

    private static ContactInformationValidationCtrl.PayloadResponse getPayloadResponse(String validateRequest){
        String payloadResponseList = ContactInformationValidationCtrl.validateFields(validateRequest);
        List<ContactInformationValidationCtrl.PayloadResponse> payloadResponseListParsed = 
            (List<ContactInformationValidationCtrl.PayloadResponse>) JSON.deserialize(payloadResponseList, List<ContactInformationValidationCtrl.PayloadResponse>.class);

        return payloadResponseListParsed.iterator().next();
    }
}
