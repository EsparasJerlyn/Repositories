/**
 * @description Tests the Distribution Management Modal Controller Class
 *
 * @see DistributionManagementModalCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | kathleen.mae.caceres           | April 14, 2024        | DEPP-8409 & DEPP-8456  | Created File                 |
*/

@isTest
private class DistributionManagementModalCtrlTest {

    @testSetup 
    static void setupMethod() {
        TestDataFactoryUser.generateUserAdvancementManager();
    }

    @isTest
    private static void insertDistributionManagementTest(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {

        Test.startTest();
        List<Designation__c> designationRecords = TestDataFactory.createDesignationRecords(
            1, DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID);

        DesignationsDAO.newInstance()
            .insertRecords(designationRecords, false, AccessLevel.USER_MODE);


        List<Distribution_Management__c> distributionManagementRecords = TestDataFactory.createDistributionManagementRecords(
            1, DistributionManagementsDAO.STATUS_DEFINE);
                distributionManagementRecords[0].Start_Date__c = System.today().addDays(5);
                distributionManagementRecords[0].Designation__c = designationRecords[0].Id;

        DistributionManagementsDAO.newInstance()
            .insertRecords(distributionManagementRecords, false, AccessLevel.USER_MODE);


        List<Finance_GL_Account__c> financeGLAccountRecords = TestDataFactory.createTestFinanceGLAccountRecords(1, true);

        FinanceGLAccountsDAO.newInstance()
            .insertRecords(financeGLAccountRecords, false, AccessLevel.USER_MODE);


        List<Distribution_Split__c> distributionSplitRecords = TestDataFactory.createTestDistributionSplitRecords(
            1, distributionManagementRecords[0].Id, financeGLAccountRecords[0].Id);


        Boolean insertDistributionManagementAndSplit = DistributionManagementModalCtrl.insertDistributionManagement(
            distributionManagementRecords[0], distributionSplitRecords);
        Test.stopTest();

        System.assert(insertDistributionManagementAndSplit, 'Error Creating Record');
        }
    }


    @isTest
    private static void upsertDistributionManagementTest(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager){

            Test.startTest();
            List<Designation__c> designation = TestDataFactory.createDesignationRecords(
                1, DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID);
                    designation[0].Stage__c = DesignationsDAO.DC_DEFINE;

            DesignationsDAO.newInstance()
                .insertRecords(designation, false, AccessLevel.USER_MODE);


            List<Distribution_Management__c> distributionManagement = TestDataFactory.createDistributionManagementRecords(
                1,DistributionManagementsDAO.STATUS_DEFINE);
                    distributionManagement[0].Start_Date__c = System.today().addDays(5);
                    distributionManagement[0].Designation__c = designation[0].Id;

            DistributionManagementsDAO.newInstance()
                .insertRecords(distributionManagement, false, AccessLevel.USER_MODE);


            List<Finance_GL_Account__c> financeGlAccount = TestDataFactory.createTestFinanceGLAccountRecords(1,true);

            FinanceGLAccountsDAO.newInstance()
                .insertRecords(financeGlAccount, false, AccessLevel.USER_MODE);


            List<Distribution_Split__c> distributionSplitRecords = TestDataFactory.createTestDistributionSplitRecords(
                1, distributionManagement[0].Id, financeGlAccount[0].Id);

            DistributionSplitsDAO.newInstance()
                .insertRecords(distributionSplitRecords, false, AccessLevel.USER_MODE);


            List<Distribution_Management__c> dbmanagement = DistributionManagementsDAO.newInstance().
                getDistributionManagementByDesignationId((new Map<Id, SObject>(designation)).keySet(),AccessLevel.USER_MODE);
            List<Distribution_Split__c> dbSplit  = DistributionSplitsDAO.newInstance().
                getDistributionSplitByDistributionManagement((new Map<Id, SObject>(dbmanagement)).keySet(),AccessLevel.USER_MODE);

            List<Distribution_Management__c> dbManagementToUpdate = new List<Distribution_Management__c> ();
            List<Distribution_Split__c> dbSplitToUpdate = new List<Distribution_Split__c> ();

            for(Distribution_Management__c dm : dbmanagement){
            dbManagementToUpdate.add(new Distribution_Management__c (
                Id = dm.Id,
                Start_Date__c = dm.Start_Date__c,
                End_Date__c = dm.End_Date__c,
                Status__c = 'Ready For Use',
                Designation__c = dm.Designation__c
            ));
            }

            for(Distribution_Split__c split : dbSplit){
            dbSplitToUpdate.add(new Distribution_Split__c (
                Id = split.Id,
                Distribution_Management__c = split.Distribution_Management__c,
                Finance_GL_Account__c = split.Finance_GL_Account__c,
                Participating_Group__c = split.Participating_Group__c,
                Percentage_Split__c = 100
            ));
            }

            Boolean upsertDistributionManagementAndSplit = DistributionManagementModalCtrl.updateDistributionManagement(
                dbManagementToUpdate[0], dbSplitToUpdate);
            Test.stopTest();

            System.assert(upsertDistributionManagementAndSplit, 'Error Upsert Record');
        }
    }
}