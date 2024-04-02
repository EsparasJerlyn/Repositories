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
 */
@isTest
private class Designation_Create_Child_Product_Test {
    public static final String DC_PUBLICGIVING = 'Yes';
    
    @testSetup
    static void setupData() {
        Test.startTest();
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Donor_Engagement_Manager' });
        Test.stopTest();

        Designation_Code_Auto_Number__c designationCodeAutoNum = DesignationCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
        designationCodeAutoNum.Designation__c = 1;
        DesignationCodeAutoNumbersDAO.newInstance().upsertRecords(
            new List<Designation_Code_Auto_Number__c>{designationCodeAutoNum}, 
            false, 
            AccessLevel.USER_MODE
        );
    }

    @isTest
    private static void forPublicGivingOnUpdate() {
        System.runAs(TestDataFactory.getDonorEngagementManager()) {
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(
                100
            );

            DesignationsDAO.newInstance()
                .insertRecords(designationList, false, AccessLevel.USER_MODE);

            for (Designation__c updateDC : designationList) {
                updateDC.Is_For_Public_Giving__c = DC_PUBLICGIVING;
            }

            Test.startTest();
            DesignationsDAO.newInstance()
                .updateRecords(designationList, false, AccessLevel.USER_MODE);
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
    
    @isTest
    private static void forPublicGivingOnInsert (){
        System.runAs(TestDataFactory.getDonorEngagementManager()) {
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(
                100
            );
	
            List<Designation__c> insertDC = new List <Designation__c> ();
            for (integer i = 0; i < designationList.size(); i++)  {
			insertDC.add(
                new Designation__c(
                    Name = 'Test' + i,
                    Is_For_Public_Giving__c = 'Yes',
                    Designation_Description__c = 'Test_Desc' + i,
                    Activation_Start_Date__c = System.today()
                )
            );
            } 
            
            Test.startTest();
            DesignationsDAO.newInstance()
                .insertRecords(insertDC, false, AccessLevel.USER_MODE);
            Test.stopTest();
            
            for (
                Designation__c eachDC : DesignationsDAO.newInstance()
                    .getDesignationsBySetRecordIds(
                        (new Map <Id, Designation__c>(insertDC)).keySet(),
                         AccessLevel.USER_MODE
                )
             ) {
                system.assert(!eachDC.Products__r.isEmpty(), 'Products should be created');   
            }
    }
    }
}