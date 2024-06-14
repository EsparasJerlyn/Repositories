/**
 * @description Test class for MobileLoqateValidationService
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | nicole.genon                   | September 21, 2023    | DEPP-6540              | Created file                 |
      |                                |                       |                        |                              |
 */
@isTest
public with sharing class MobileLoqateValidationServiceTest {

    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTESB();
    }
    
    @isTest
    private static void validateLeadMobileTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            List<Lead> leadList = TestDataFactory.createTestLeadRecords(1,2);
            for(Lead lead : leadList){
                lead.Mobile_No_Locale__c = '12345678';
                lead.LeadMobile_Locale__c = 'New Zealand (+64)';
            }
            LeadsDAO.newInstance().insertRecords(leadList, true, AccessLevel.USER_MODE);

            MobileLoqateValidationService.ValidateRequestList validateRequest = new MobileLoqateValidationService.ValidateRequestList();
            validateRequest.leadId = leadList[0].Id;
            validateRequest.apiName = 'MobilePhone';
            validateRequest.loqateRequest = 'fullPhone';
            validateRequest.statusValidationField = 'LeadMobile_Validation__c';
            validateRequest.locale = 'AU';
            validateRequest.value = leadList[0].Mobile_No_Locale__c;
            validateRequest.localePicklistValue = leadList[0].LeadMobile_Locale__c;

            List<MobileLoqateValidationService.ValidateRequestList> validateRequestList = new List<MobileLoqateValidationService.ValidateRequestList>();
            validateRequestList.add(validateRequest);

            Test.startTest();
            MobileLoqateValidationService.validateLeadMobile(validateRequestList);
            Test.stopTest();
            
            List<String> fields = new List<String>{'MobilePhone', 'LeadMobile_Validation__c'};
            List<Lead> updatedLeadList =  
                (List<Lead>) DynamicQueryService.getRecordsWithFieldsByIdSet(
                    new DynamicQueryService.FilterWrapper(new Set<Id>{leadList[0].Id}, Lead.getSObjectType(), fields), 
                    AccessLevel.USER_MODE
                );
            
            System.assert(updatedLeadList[0].MobilePhone !=null, 'Mobile Phone must be updated.');
            System.assert(updatedLeadList[0].LeadMobile_Validation__c !=null, 'Validation must be updated.');
        }
    }

    @isTest
    private static void validateLeadMobileFailTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            List<Lead> leadList = TestDataFactory.createTestLeadRecords(1,2);
            LeadsDAO.newInstance().insertRecords(leadList, true, AccessLevel.USER_MODE);

            MobileLoqateValidationService.ValidateRequestList validateRequest = new MobileLoqateValidationService.ValidateRequestList();
            validateRequest.leadId = leadList[0].Id;
            validateRequest.apiName = 'MobilePhone';
            validateRequest.loqateRequest = 'fullPhone';
            validateRequest.statusValidationField = 'LeadMobile_Validation__c';
            validateRequest.locale = 'AU';
            validateRequest.value = leadList[0].Mobile_No_Locale__c;
            validateRequest.localePicklistValue = leadList[0].LeadMobile_Locale__c;

            List<MobileLoqateValidationService.ValidateRequestList> validateRequestList = new List<MobileLoqateValidationService.ValidateRequestList>();
            validateRequestList.add(validateRequest);

            Test.startTest();
            MobileLoqateValidationService.validateLeadMobile(validateRequestList);
            Test.stopTest();
            
            List<String> fields = new List<String>{'LeadMobile_Validation__c'};
            List<Lead> updatedLeadList =  
                (List<Lead>) DynamicQueryService.getRecordsWithFieldsByIdSet(
                    new DynamicQueryService.FilterWrapper(new Set<Id>{leadList[0].Id}, Lead.getSObjectType(), fields), 
                    AccessLevel.USER_MODE
                );
            
            System.assert(updatedLeadList[0].LeadMobile_Validation__c !=null, 'Validation must be updated.');
        }
    }
}