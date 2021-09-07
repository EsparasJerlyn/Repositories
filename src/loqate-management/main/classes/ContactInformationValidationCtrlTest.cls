/**
 * @description Tests the Contact Information Validation Controller class 
 *
 * @see ContactInformationValidationCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA     | Change Summary               |
      |---------------------------|-----------------------|----------|------------------------------|
      | angelika.j.s.galang       | September 3, 2021     | DEP1-156 | Created file                 | 
      |                           |                       |          |                              | 
*/
@IsTest(SeeAllData = false)
private class ContactInformationValidationCtrlTest {
    
    private static final String ACCOUNT_API_NAME = Account.SObjectType.getDescribe().getLocalName();
	private static final String OPP_API_NAME = Opportunity.SObjectType.getDescribe().getLocalName();
    private static final String AURA_EX_MSG = 'Error while getting field mapping.';
    private static final String ACCOUNT_FIELD_MAPPING = '[{"label": "ABN","apiName":"ABN__c","statusValidationField":"AccountABNEntity_Validation__c","loqateRequest":"name","loqateResponse":"status"}]';
    private static final String STR_QUTeX = 'QUTeX';
    private static User currentUser = TestDataFactory.createUserRecords(1, STR_QUTeX).iterator().next();

    @IsTest
    private static void getFieldMappingSuccessTest(){
        Test.startTest();
        System.runAs(currentUser){
            String fieldMappingTest = ContactInformationValidationCtrl.getFieldMapping(ACCOUNT_API_NAME);
            System.assertEquals(ACCOUNT_FIELD_MAPPING, fieldMappingTest, 'Field mapping did not match expected.');
        }
        Test.stopTest();
    }

    @IsTest
    private static void getFieldMappingErrorTest(){
        Test.startTest();
        System.runAs(currentUser){
            try{
                String fieldMappingTest = ContactInformationValidationCtrl.getFieldMapping(OPP_API_NAME);
            }catch(AuraHandledException ex){
                System.assert(ex.getMessage().contains(AURA_EX_MSG), 'Exception did not match expected.');
            }
        }
        Test.stopTest();
    }
}
