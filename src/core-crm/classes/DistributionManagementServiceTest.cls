/**
 * @description Distribution Management object service class
 * @see ../classes/DistributionManagementService
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan	           | April 10, 2024        | DEPP-8401              | Created file                 |
 */
@isTest
private with sharing class DistributionManagementServiceTest {

    @testSetup
    static void setupDate() {
        Test.startTest();
        TestDataFactory.generateTestUsers(new List<String>{'QUT_IE_Partnership_Manager'});
        TestDataFactoryUser.generateUserAdvancementManager();
        Designation_Code_Auto_Number__c designationCodeAutoNum = DesignationCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
        designationCodeAutoNum.Giving_To_Cause__c = 1;
        DesignationCodeAutoNumbersDAO.newInstance().upsertRecords(
            new List<Designation_Code_Auto_Number__c>{designationCodeAutoNum}, 
            false, 
            AccessLevel.USER_MODE
        );
        
        Test.stopTest();
    }
    
    @isTest
    private static void getRelatedDistributionManagementOfDesignationGivingToCauseTest() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(
                100,
                DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID
            );

            for (Designation__c d : designationList) {
                d.Ready_For_Publishing__c = false;
                d.Activation_End_Date__c = System.Today() + 1;
            }

            DesignationsDAO.newInstance()
            .insertRecords(designationList, false, AccessLevel.USER_MODE);

            Test.startTest();
            List<Designation__c> designationListFromDistributionManagementService = 
                DistributionManagementService.getRelatedDistributionManagementOfDesignation(designationList);
            Test.stopTest();

            System.assertEquals(
                false,
                designationListFromDistributionManagementService.isEmpty(),
                'Distribution Management getRelatedDistributionManagementOfDesignation for Giving to Cause should not be empty'
            );
        }
    }

    @isTest
    private static void getRelatedDistributionManagementOfDesignationEndowmentWithActiveDM() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(
                100,
                DesignationsDAO.ENDOWNMENT_RECTYPE_ID
            );

            for (Designation__c d : designationList) {
                d.Endowment_Account_Type__c = DesignationsDAO.ENDOWMENT_ACCOUNT_TYPE_PERPETUAL;
                d.Ready_For_Publishing__c = false;
                d.Activation_End_Date__c = System.Today() + 1;
            }

            DesignationsDAO.newInstance()
            .insertRecords(designationList, false, AccessLevel.USER_MODE);

            List<Distribution_Management__c> distributionMgtList = TestDataFactory.createDistributionManagementRecords(
                100, 
                'Active');

            for(Integer i = 0; i<100; i++){
                distributionMgtList[i].Designation__c = designationList[i].Id;
            }
            DistributionManagementsDAO.newInstance().insertRecords(distributionMgtList, false, AccessLevel.USER_MODE);

            Test.startTest();
            List<Designation__c> designationListFromDistributionManagementService = 
                DistributionManagementService.getRelatedDistributionManagementOfDesignation(designationList);
            Test.stopTest();

            System.assertEquals(
                false,
                designationListFromDistributionManagementService.isEmpty(),
                'Distribution Management getRelatedDistributionManagementOfDesignation for Endowment should not be empty'
            );
        }
    }

    @isTest
    private static void getRelatedDistributionManagementOfDesignationEndowmentWithoutDM() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(
                100,
                DesignationsDAO.ENDOWNMENT_RECTYPE_ID
            );

            for (Designation__c d : designationList) {
                d.Ready_For_Publishing__c = false;
                d.Activation_End_Date__c = System.Today() + 1;
                d.Endowment_Account_Type__c = DesignationsDAO.ENDOWMENT_ACCOUNT_TYPE_PERPETUAL;
            }

            DesignationsDAO.newInstance()
            .insertRecords(designationList, false, AccessLevel.USER_MODE);

            Test.startTest();
            List<Designation__c> designationListFromDistributionManagementService = 
                DistributionManagementService.getRelatedDistributionManagementOfDesignation(designationList);
            Test.stopTest();

            System.assertEquals(
                true,
                designationListFromDistributionManagementService.isEmpty(),
                'Distribution Management getRelatedDistributionManagementOfDesignation for Endowment should be empty'
            );
        }
    }

    @isTest
    private static void getRelatedDistributionManagementOfDesignationExceptionTest (){
        try{
            System.runAs(TestDataFactory.getQUTIEPartnershipManager()){
                List<Designation__c> designationList = TestDataFactory.createDesignationRecords(
                    100,
                    DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID
                );
    
                for (Designation__c d : designationList) {
                    d.Ready_For_Publishing__c = false;
                    d.Activation_End_Date__c = System.Today() + 1;
                }
    
                DesignationsDAO.newInstance()
                .insertRecords(designationList, false, AccessLevel.USER_MODE);
    
                Test.startTest();
                List<Designation__c> designationListFromDistributionManagementService = 
                    DistributionManagementService.getRelatedDistributionManagementOfDesignation(designationList);
                Test.stopTest();
            }
        }catch(Exception e){
         	 System.assertEquals('Exception caught in method execute in Apex class Distribution Management Service.', 
                                 e.getMessage(), 'Exception caught in method execute in Apex class Distribution Management Service.');

        }
    }

}