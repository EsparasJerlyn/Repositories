@isTest
private class AddressInformationValidationCtrlTest {

    @testSetup static void setupMethod() {
        TestDataFactoryUser.generateUserQUTeXProductAdministrator();
        List<account> accs = new List<Account>();
        List<lead> leads = new List<lead>();
        List<contact> contacts = new List<contact>();
        List<hed__Address__c> hedAddresses = new List<hed__Address__c>();

        accs = TestDataFactory.createTestAccountRecords(2);
        leads = TestDataFactory.createTestLeadRecords(2);
        contacts = TestDataFactory.createTestContactRecords(2);

        Test.startTest();
        
        insert(accs);
        insert(leads);
        insert(contacts);
        hedAddresses.addAll(TestDataFactory.createTestHedAddressRecords(1,'Billing',accs[0].id,'hed__Parent_Account__c'));
        hedAddresses.addAll(TestDataFactory.createTestHedAddressRecords(1,'Other',contacts[0].id,'hed__Parent_Contact__c'));
        hedAddresses.addAll(TestDataFactory.createTestHedAddressRecords(1,'Lead',leads[0].id,'Parent_Lead__c'));
        insert(hedAddresses);
        
        Test.stopTest();
        
    }   

    @isTest
    static void testGetLoqateMetaData() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProductAdministrator){
            AddressInformationValidationCtrl.AddressMetadata addMetadata  = new AddressInformationValidationCtrl.AddressMetadata();
            addMetadata = AddressInformationValidationCtrl.getLoqateMetaData('Account');
            system.assertEquals('hed__Parent_Account__c', addMetadata.addressLookup, 'unable to get account metadata for account');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetLoqateMetaDataError() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProductAdministrator){
            AddressInformationValidationCtrl.AddressMetadata addMetadata  = new AddressInformationValidationCtrl.AddressMetadata();
            try{
                addMetadata = AddressInformationValidationCtrl.getLoqateMetaData('Test');
            }catch (Exception e) {
                System.assert(e != null, 'Exception should have been thrown');
            }
        }
        Test.stopTest();
    }

    @isTest
    static void testUpserHedAddress() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProductAdministrator){
            List<hed__Address__c> hedAddress = new List<hed__Address__c>([SELECT Id, hed__Address_Type__c FROM hed__Address__c WHERE hed__Address_Type__c = 'Billing']);
            hed__Address__c hedAddressToUpdate = new hed__Address__c(id=hedAddress[0].id,hed__Address_Type__c='Shipping');
            AddressInformationValidationCtrl.upsertHedAddress(hedAddressToUpdate);
            System.assertEquals('Shipping', [SELECT hed__Address_Type__c FROM hed__Address__c WHERE id =: hedAddress[0].id].hed__Address_Type__c, 'hed address not successfully updated');   
        }
        Test.stopTest();
    }
    
    @isTest
    static void testUpserHedAddressError() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProductAdministrator){
            hed__Address__c hedAddressToUpdate = new hed__Address__c();
            hedAddressToUpdate.put('id','1234');
            hedAddressToUpdate.put('hed__Address_Type__c','test');
            try{
                AddressInformationValidationCtrl.upsertHedAddress(hedAddressToUpdate);
            }catch (Exception e){
                System.assert(e != null, 'Exception should have been thrown');
            }
        }
        Test.stopTest();
    }

    @isTest
    static void testGetHedAddress() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProductAdministrator){
            List<hed__Address__c> hedAddress = new List<hed__Address__c>([SELECT Id, hed__Address_Type__c, Parent_Lead__c FROM hed__Address__c WHERE hed__Address_Type__c = 'Lead']);
            system.assert(!AddressInformationValidationCtrl.getHedAddress(hedAddress[0].Parent_Lead__c, 'Parent_Lead__c').isEmpty(), 'no hed address found');
        }
        Test.stopTest();
    }

    @isTest
	static void testGetHedAddressError() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProductAdministrator){
            try{
                AddressInformationValidationCtrl.getHedAddress('errorid', 'Error Field');
            }catch(Exception e){
                System.assert(e != null, 'Exception should have been thrown');
            }
        }
        Test.stopTest();
    }
    
    @isTest
    static void testSearchAddress() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProductAdministrator){
            // Set mock callout class 
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            List<AddressInformationValidationCtrl.AddressObject> addressObj = new List<AddressInformationValidationCtrl.AddressObject>();
            addressObj = AddressInformationValidationCtrl.searchAddress('test','AU');
            system.assertEquals('testAddress', addressObj[0].fullAddress, 'address doesnt match');
            system.assertEquals('testCountry', addressObj[0].country, 'country doesnt match');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetDetails() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProductAdministrator){
            // Set mock callout class 
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            AddressInformationValidationCtrl.AddressObject addressObj = new AddressInformationValidationCtrl.AddressObject();
            addressObj = AddressInformationValidationCtrl.getDetails('test','AU');
            system.assertEquals('testAddress', addressObj.fullAddress, 'address doesnt match');
            system.assertEquals('testCountry', addressObj.country, 'country doesnt match');
        }
        Test.stopTest();
    
    }

}