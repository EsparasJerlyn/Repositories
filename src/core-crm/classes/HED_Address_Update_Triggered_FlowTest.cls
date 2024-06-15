/**
 * @description Tests the HED Address Update Triggered Flow  
 *
 * @see HED_Address_Update_Triggered_Flow
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA     | Change Summary                  |
      |---------------------------|-----------------------|----------|---------------------------------|
      | roy.nino.s.regala         | November 02, 2021     | DEPP-737 | Created file                    | 
      |                           |                       |          |                                 |
*/
@isTest
private class HED_Address_Update_Triggered_FlowTest {
    
    private static final String STR_QUTEX = 'QUTeX';
    private static final String BILLING_TYPE = 'Billing';
    private static final String SHIPPING_TYPE = 'Shipping';
    private static final String OTHER_TYPE = 'Other';
    private static final String MAILING_TYPE = 'Mailing';
    private static final String LEAD_TYPE = 'Lead';


    @testSetup
    static void setupMethod() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        Test.stopTest();

        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            List<account> accs = new List<Account>();
            List<lead> leads = new List<lead>();
            List<contact> contacts = new List<contact>();
            List<hed__Address__c> hedAddresses = new List<hed__Address__c>();

            accs = TestDataFactory.createTestAccountRecords(1);
            leads = TestDataFactory.createTestLeadRecords(1);
            contacts = TestDataFactory.createTestContactRecords(1);


            insert accs;
            insert leads;
            insert contacts;

            hedAddresses.addAll(TestDataFactory.createTestHedAddressRecords(20,BILLING_TYPE,accs[0].id,'hed__Parent_Account__c'));
            hedAddresses.addAll(TestDataFactory.createTestHedAddressRecords(20,SHIPPING_TYPE,accs[0].id,'hed__Parent_Account__c'));
            hedAddresses.addAll(TestDataFactory.createTestHedAddressRecords(20,OTHER_TYPE,contacts[0].id,'hed__Parent_Contact__c'));
            hedAddresses.addAll(TestDataFactory.createTestHedAddressRecords(20,MAILING_TYPE,contacts[0].id,'hed__Parent_Contact__c'));
            hedAddresses.addAll(TestDataFactory.createTestHedAddressRecords(20,LEAD_TYPE,leads[0].id,'Parent_Lead__c'));

            insert hedAddresses;
        }

    }  

    @isTest
    private static void updateAccountShippingAddressTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            List<hed__Address__c> address = [SELECT id, hed__MailingCity__c from hed__Address__c Where hed__Address_Type__c =: SHIPPING_TYPE];
            for(hed__Address__c a : address){
                a.hed__MailingCity__c = 'NewCity';
            }

            Test.startTest();
            update(address);
            Test.stopTest();

            system.assert(![SELECT Id FROM Account Where ShippingCity = 'NewCity'].isEmpty(), 'Account Shipping City should be updated');
        }



    }

    @isTest
    private static void updateAccountBillingAddressTest(){

        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            List<hed__Address__c> address = [SELECT id, hed__MailingCity__c from hed__Address__c Where hed__Address_Type__c =: BILLING_TYPE];
            for(hed__Address__c a : address){
                a.hed__MailingCity__c = 'NewCity';
            }
            update(address);
        }

        Test.startTest();
        system.assert(![SELECT Id FROM Account Where BillingCity = 'NewCity'].isEmpty(), 'Account Billing City should be updated');
        Test.stopTest();


    }

    @isTest
    private static void updateContactMailingAddressTest(){

        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            List<hed__Address__c> address = [SELECT id, hed__MailingCity__c from hed__Address__c Where hed__Address_Type__c =: MAILING_TYPE];
            for(hed__Address__c a : address){
                a.hed__MailingCity__c = 'NewCity';
            }

            Test.startTest();
            update(address);
            Test.stopTest();

            system.assert(![SELECT Id FROM Contact Where MailingCity = 'NewCity'].isEmpty(), 'Contact Mailing City should be updated');
        }

    }

    @isTest
    private static void updateContactOtherAddressTest(){

        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            List<hed__Address__c> address = [SELECT id, hed__MailingCity__c from hed__Address__c Where hed__Address_Type__c =: OTHER_TYPE];
            for(hed__Address__c a : address){
                a.hed__MailingCity__c = 'NewCity';
            }
            Test.startTest();
            update(address);
            Test.stopTest();

            system.assert(![SELECT Id FROM Contact Where OtherCity = 'NewCity'].isEmpty(), 'Contact Other City should be updated');
        }

    }

    @isTest
    private static void updateLeadAddressTest(){

        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){

            List<hed__Address__c> address = [SELECT id, hed__MailingCity__c from hed__Address__c Where hed__Address_Type__c =: LEAD_TYPE];
            for(hed__Address__c a : address){
                a.hed__MailingCity__c = 'NewCity';
            }

            Test.startTest();
            update(address);
            Test.stopTest();

            system.assert(![SELECT Id FROM Lead Where City = 'NewCity'].isEmpty(), 'Lead City should be updated');
        }



    }

    @isTest
    private static void updateAllAddressesTest(){

        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            List<hed__Address__c> address = [SELECT id, hed__MailingCity__c from hed__Address__c];
            for(hed__Address__c a : address){
                a.hed__MailingCity__c = 'NewCity';
            }

            Test.startTest();
            update(address);
            Test.stopTest();

            system.assert(![SELECT Id FROM Account Where BillingCity = 'NewCity' AND ShippingCity = 'NewCity'].isEmpty(), 'Account Billing and Shipping City should be updated');
            system.assert(![SELECT Id FROM Contact Where OtherCity = 'NewCity' AND MailingCity = 'NewCity'].isEmpty(), 'Contact Other and Mailing City should be updated');
            system.assert(![SELECT Id FROM Lead Where City = 'NewCity'].isEmpty(), 'Lead City should be updated');
        }



    }



}
