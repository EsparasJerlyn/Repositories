/**
 * @description test class for Designation_Create_Child_Product Flow
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | kathleen.mae.caceres           | March, 20, 2024       | DEPP-8201              | Created file                 |
      | eugene.andrew.abuan            | April 10, 2024        | DEPP-8390              | Added Designation Recordtype |

 */
@isTest
private class Designation_Create_Child_Product_Test {
    @testSetup
    static void setupData() {
        Test.startTest();
        TestDataFactoryUser.generateUserAdvancementManager();
        Test.stopTest();

        Designation_Code_Auto_Number__c designationCodeAutoNum = DesignationCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
        designationCodeAutoNum.Giving_To_Cause__c = 1;
        DesignationCodeAutoNumbersDAO.newInstance().upsertRecords(
            new List<Designation_Code_Auto_Number__c>{designationCodeAutoNum}, 
            false, 
            AccessLevel.USER_MODE
        );
    }
    
    @isTest
    private static void createProductOnDesignationInsert (){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(
                100,
                DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID
            );
            
            Test.startTest();
            DesignationsDAO.newInstance()
                .insertRecords(designationList, true, AccessLevel.USER_MODE);
            Test.stopTest();
            
            for (
                Designation__c eachDC : DesignationsDAO.newInstance()
                    .getDesignationsBySetRecordIds(
                        (new Map <Id, Designation__c>(designationList)).keySet(),
                         AccessLevel.USER_MODE
                )
             ) {
                system.assert(!eachDC.Products__r.isEmpty(), 'Products should be created');   
            }
        }
    }
}