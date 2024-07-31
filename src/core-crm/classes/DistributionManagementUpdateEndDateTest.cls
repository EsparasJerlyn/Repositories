/**
* @description Test Class for Distribution Management Update End Date flow
*
* @see ../flows/Distribution Management Update End Date
*
* @author Accenture
*
* @history
*    | Developer                 | Date                  | JIRA              | Change Summary                                                   |
*    |---------------------------|-----------------------|-------------------|------------------------------------------------------------------|
*    | kathleen.mae.caceres      | April 10, 2024        | DEPP-8409         | Created file                                                     |
*/

@isTest
private class DistributionManagementUpdateEndDateTest {

    @TestSetup
    static void setupData(){
        TestDataFactoryUser.generateUserAdvancementManager();
    }

    @isTest
    private static void checkOnCreateActiveDistribManagementEndDate() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {

            Test.startTest();
            List<Distribution_Management__c> distribManagementRecord = TestDataFactory.createDistributionManagementRecords(
                100, DistributionManagementsDAO.DM_ACTIVE);
            List<Designation__c> designationRecord = TestDataFactory.createDesignationRecords(
                1,DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID);
            DesignationsDAO.newInstance()
                .insertRecords(designationRecord, false, AccessLevel.USER_MODE);

            for (Distribution_Management__c rec : distribManagementRecord){
                rec.Designation__c  = designationRecord[0].Id;
                rec.Start_Date__c = System.today().addDays(5);
            }

            distribManagementRecord[0].Status__c = DistributionManagementsDAO.DM_READY_FOR_USE;
            DistributionManagementsDAO.newInstance()
                .insertRecords(distribManagementRecord, false, AccessLevel.USER_MODE);
            Test.stopTest();

            List<Distribution_Management__c>  dbManagement = DistributionManagementsDAO.newInstance().getDistributionManagementByDesignationId(
                new Set<Id>{designationRecord[0].Id}, AccessLevel.USER_MODE);

            for(Distribution_Management__c db : dbManagement) {
                if(db.Status__c == DistributionManagementsDAO.DM_ACTIVE) {
                  System.assertEquals((System.today().addDays(5))-1,db.End_Date__c, 'End Date has not been updated');
                }
                if(db.Status__c == DistributionManagementsDAO.DM_READY_FOR_USE) {
                    System.assertEquals(null, db.End_Date__c, 'End Date has been updated');
                }
            }
        }
    }

    @isTest
    private static void checkOnUpdateActiveDistribManagementEndDate() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {

            Test.startTest();
            List<Distribution_Management__c> distribManagementRecord = TestDataFactory.createDistributionManagementRecords(
                100, DistributionManagementsDAO.DM_ACTIVE);
            List<Designation__c> designationRecord = TestDataFactory.createDesignationRecords(
                1,DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID);
            DesignationsDAO.newInstance()
                .insertRecords(designationRecord, false, AccessLevel.USER_MODE);

            for (Distribution_Management__c rec : distribManagementRecord){
                rec.Designation__c  = designationRecord[0].Id;
                rec.Start_Date__c = System.today().addDays(5);
            }

            DistributionManagementsDAO.newInstance()
                .insertRecords(distribManagementRecord, false, AccessLevel.USER_MODE);

            List<Distribution_Management__c> distribManagementRecords = DistributionManagementsDAO.newInstance().
                 getDistributionManagementByDesignationId(
                     (new Map <Id, Designation__c>(designationRecord)).keySet(),
                     AccessLevel.USER_MODE);

            List<Distribution_Management__c> distribListForUpdate = new List<Distribution_Management__c>();
             distribListForUpdate.add(new Distribution_Management__c (
                 	Id = distribManagementRecords[0].Id,
                 	Designation__c = distribManagementRecords[0].Designation__c,
                 	Start_Date__c = distribManagementRecords[0].Start_Date__c,
                    Status__c = DistributionManagementsDAO.DM_READY_FOR_USE
                    ));

            DistributionManagementsDAO.newInstance()
                .updateRecords(distribListForUpdate, false, AccessLevel.USER_MODE);
            Test.stopTest();

            List<Distribution_Management__c>  dbManagement = DistributionManagementsDAO.newInstance().getDistributionManagementByDesignationId(
                new Set<Id>{designationRecord[0].Id}, AccessLevel.USER_MODE);

            for(Distribution_Management__c db : dbManagement) {

                if(db.Status__c == DistributionManagementsDAO.DM_ACTIVE) {
                  System.assertEquals((System.today().addDays(5))-1,db.End_Date__c, 'End Date has not been updated');
                }

                if(db.Status__c == DistributionManagementsDAO.DM_READY_FOR_USE) {
                    System.assertEquals(null, db.End_Date__c, 'End Date has been updated');
                }
            }
        }
    }

}