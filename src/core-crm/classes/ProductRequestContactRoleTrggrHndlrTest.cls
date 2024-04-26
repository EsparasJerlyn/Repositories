/**
 * @description Test Class for Product Request Contact Role Trigger Handler
 *
 * @see ProductRequestContactRoleTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | alexander.cadalin         | Nov 16, 2022          | DEPP-4099    | Created file                                |
*/
@isTest private class ProductRequestContactRoleTrggrHndlrTest {
    @testSetup static void setup() {
        Test.startTest();
        TestDataFactoryUser.generateUserIndustryPartnershipManager();
        Test.stopTest();
        User partnershipManagerUser = TestDataFactoryUser.selectUserIndustryPartnershipManager;
        List<Product_Request__c> testProdReqs = TestDataFactory.createTestProductRequestRecords(1);
        testProdReqs[0].OwnerId = partnershipManagerUser.Id;
        insert testProdReqs;
        List<Contact> testContacts = new List<Contact>();
        for(Integer i = 0; i < 100; i++) {
            testContacts.add(
                new Contact(
                    LastName = 'Test', 
                    FirstName = 'Contact' + i, 
                    OwnerId = partnershipManagerUser.Id
                )
            );
        }
        insert testContacts;
    }
    
    @isTest static void newFacultyLeadNoExisting() {
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            Contact con = [SELECT Id FROM Contact WITH SECURITY_ENFORCED LIMIT 1];
            Product_Request__c pr = [SELECT Id FROM Product_Request__c WITH SECURITY_ENFORCED LIMIT 1];
            Product_Request_Contact_Role__c prcr = new Product_Request_Contact_Role__c(
                Contact__c = con.Id, 
                Product_Request__c = pr.Id, 
                Role__c = 'Faculty Lead'
            );
            
            Test.startTest();
            Database.SaveResult sr = Database.insert(prcr);
            Test.stopTest();
            
            System.assert(sr.isSuccess(), 'The Product Request Contact Role was not created');
        }
    }
    
    @isTest static void newFacultyLeadWithExisting() {
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            List<Contact> cons = [SELECT Id FROM Contact WITH SECURITY_ENFORCED LIMIT 2];
            Product_Request__c pr = [SELECT Id FROM Product_Request__c WITH SECURITY_ENFORCED LIMIT 1];
            List<Product_Request_Contact_Role__c> prcrs = new List<Product_Request_Contact_Role__c>();
            for(Integer i = 0; i < cons.size(); i++) {
                prcrs.add(new Product_Request_Contact_Role__c(
                    Contact__c = cons[i].Id, 
                    Product_Request__c = pr.Id, 
                    Role__c = 'Faculty Lead')
                );
            }
            insert prcrs[0];
            
            Boolean dmlExceptionHit = false;
            try {
                Test.startTest();
            	insert prcrs[1];
                Test.stopTest();
            } catch(DmlException d) {
                dmlExceptionHit = true;
            }
            
            System.assert(dmlExceptionHit, 'The Product Request Contact Role was saved.');
        }
    }
    
    @isTest static void newMultipleFacultyBatch() {
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            List<Contact> cons = [SELECT Id FROM Contact WITH SECURITY_ENFORCED];
            Product_Request__c pr = [SELECT Id FROM Product_Request__c WITH SECURITY_ENFORCED LIMIT 1];
            List<Product_Request_Contact_Role__c> prcrs = new List<Product_Request_Contact_Role__c>();
            for(Integer i = 0; i < cons.size(); i++) {
                prcrs.add(new Product_Request_Contact_Role__c(
                    Contact__c = cons[i].Id, 
                    Product_Request__c = pr.Id, 
                    Role__c = 'Faculty Lead'
                ));
            }
            
            Boolean dmlExceptionHit = false;
            try {
                Test.startTest();
                insert prcrs;
                Test.stopTest();
            } catch(dmlException e) {
                dmlExceptionHit = true;
            }
            
            System.assert(dmlExceptionHit, 'A Product Request Contact Role was saved');
        }
    }
    
    @isTest static void updateToFacultyLeadWithoutExisting() {
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            List<Contact> cons = [SELECT Id FROM Contact WITH SECURITY_ENFORCED LIMIT 2];
            Product_Request__c pr = [SELECT Id FROM Product_Request__c WITH SECURITY_ENFORCED LIMIT 1];
            List<Product_Request_Contact_Role__c> prcrs = new List<Product_Request_Contact_Role__c>();
            for(Integer i = 0; i < cons.size(); i++) {
                prcrs.add(new Product_Request_Contact_Role__c(
                    Contact__c = cons[i].Id, 
                    Product_Request__c = pr.Id, 
                    Role__c = 'Facilitator'
                ));
            }
            insert prcrs;
            
            Test.startTest();
            prcrs[0].Role__c = 'Faculty Lead';
            Database.SaveResult sr = Database.update(prcrs[0]);
            Test.stopTest();
            
            System.assert(sr.isSuccess(), 'Failed to update the contact role\'s Role to Faculty Lead.');
        }
    }
    
    @isTest static void updateToFacultyLeadWithExisting() {
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            List<Contact> cons = [SELECT Id FROM Contact WITH SECURITY_ENFORCED LIMIT 2];
            Product_Request__c pr = [SELECT Id FROM Product_Request__c WITH SECURITY_ENFORCED LIMIT 1];
            List<Product_Request_Contact_Role__c> prcrs = new List<Product_Request_Contact_Role__c>();
            for(Integer i = 0; i < cons.size(); i++) {
                prcrs.add(new Product_Request_Contact_Role__c(
                    Contact__c = cons[i].Id, 
                    Product_Request__c = pr.Id, 
                    Role__c = 'Facilitator'
                ));
            }
            insert prcrs;
            
            prcrs[1].Role__c = 'Faculty Lead';
            update prcrs[1];
            
            Boolean dmlExceptionHit = false;
            try {
                Test.startTest();
                insert prcrs[0];
                Test.stopTest();
            } catch(DmlException d) {
                dmlExceptionHit = true;
            }
            
            System.assert(dmlExceptionHit, 'The update on the contact role\'s Role was saved.');
        }
    }
}