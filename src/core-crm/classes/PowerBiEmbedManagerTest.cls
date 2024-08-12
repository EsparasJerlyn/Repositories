/**
 * @description Test Class for PowerBiEmbedManager
 * 
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                      |
      |---------------------------|-----------------------|--------------|-----------------------------------------------------|
      | kenneth.f.alsay           | July 30, 2024         | DEPP-8279    | Created file                                        |
 */
@isTest
private class PowerBiEmbedManagerTest {	
    @testSetup
    static void testSetup() {
        Test.startTest();
    	TestDataFactoryUser.generateUserSysAdminIntegration();
        Test.stopTest();
    }
    
    @isTest
    static void testAlumniCorporateUserGetEmbeddingDataForReport() {
        System.runAs(TestDataFactoryUser.selectUserSysAdminIntegration){
            // Set mock callout class 
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        	PowerBiEmbedManager.getEmbeddingDataForReport('123456', '123456');
	        Test.stopTest();        
        }
    }
    
    @isTest
    static void testPowerBiReport(){
        System.runAs(TestDataFactoryUser.selectUserSysAdminIntegration){
            Test.startTest();
            PowerBiEmbedManager powerBiEmbedManager = new PowerBiEmbedManager();
            powerBiEmbedManager.PowerBiReport powerBiReport = new powerBiEmbedManager.PowerBiReport();
            powerBiReport.id = 'PowerBiReport';
            powerBiReport.reportType = 'PowerBiReport';
            powerBiReport.name = 'PowerBiReport';
            powerBiReport.webUrl = 'PowerBiReport';
            powerBiReport.isFromPbix = true;
            powerBiReport.isOwnedByMe = true;
            powerBiReport.datasetId = 'PowerBiReport';
	        Test.stopTest();        
        }
    }
    
    @isTest
    static void testPowerBiEmbedToken(){
        System.runAs(TestDataFactoryUser.selectUserSysAdminIntegration){
            Test.startTest();
            PowerBiEmbedManager powerBiEmbedManager = new PowerBiEmbedManager();
            powerBiEmbedManager.PowerBiEmbedToken powerBiEmbedToken = new powerBiEmbedManager.PowerBiEmbedToken();
            powerBiEmbedToken.token = 'PowerBiReport';
            powerBiEmbedToken.tokenId = 'PowerBiReport';
            powerBiEmbedToken.expiration = (DateTime) Date.Today();
	        Test.stopTest();        
        }
    }
}