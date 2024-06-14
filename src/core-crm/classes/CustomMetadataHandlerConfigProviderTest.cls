@isTest
private class CustomMetadataHandlerConfigProviderTest {

    @testSetup 
    static void setupMethod() {
        Test.startTest();
        TestDataFactoryUser.generateUserSystemAdministrator();
        Test.stopTest();
    }
    
    @isTest
    private static void shouldThrowAnExceptionForUnknownHandler() {
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        System.runAs(PORTAL_SYS_ADMIN) {
            final HandlerConfigProvider configProvider = new CustomMetadataHandlerConfigProvider();

            try {
                configProvider.loadConfigurationBySObjectType('non existing sObject');
            } catch (Exception ex) {
                System.assert(ex != null, 'Exception should have been thrown');
            }
        }
    }

    @isTest
    private static void buildShouldReturnTriggerHandlerConfig() {
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        System.runAs(PORTAL_SYS_ADMIN) {
            CustomMetadataHandlerConfigProvider configProvider = new CustomMetadataHandlerConfigProvider();

            TriggerHandler__mdt metadata = new TriggerHandler__mdt();
            metadata.MasterLabel = 'Test';
            metadata.HandlerClass__c = 'TestHandlerClass';
            metadata.HandlerDescription__c = 'TestHandlerClass';

            TriggerHandlerConfig config = configProvider.buildConfiguration(
                metadata
            );

            System.assert(config == null, 'No Config Should have Been Created');
        }
    }
}