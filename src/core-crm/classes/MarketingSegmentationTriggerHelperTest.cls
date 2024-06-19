/**
 * @description Test Class for MarketingSegmentationTriggerHelper
 * @see ..MarketingSegmentationTriggerHelper
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
 *    | roy.nino.s.regala              | Oct 26, 2022          | DEPP-4327              | Created file                                   |
 *    | alexander.cadalin              | Aug 15, 2023          | DEPP-6124              | Added tests for new methods                    |
 */

@isTest
public without sharing class MarketingSegmentationTriggerHelperTest {
    @testSetup
    static void setupMethod() {
        Test.startTest();
        TestDataFactoryUser.generateUserSystemAdministrator();
        
            List<Contact> contactList = TestDataFactory.createTestContactRecords(50);
            List<Lead> leadList =  TestDataFactory.createTestLeadRecords(50);
            insert contactList;
            insert leadList;
     	
        Test.stopTest();
        
        System.assert(![SELECT Id FROM Lead WHERE Marketing_Segmentation__c != null].isEmpty(), 'Marketing Segmentation field on lead is not updated.');
        System.assert(![SELECT Id FROM Contact WHERE Marketing_Segmentation__c != null].isEmpty(), 'Marketing Segmentation field on contact is not updated.');
    }

    @isTest
    public static void updateMarketingSegmentationLeadTest(){
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator){
            List<Marketing_Segmentation__c> marSegmentationWithoutLead = [
                SELECT Id, Lead__c 
                FROM Marketing_Segmentation__c
                WHERE Lead__c = null
                LIMIT 50
            ];

            List<Lead> leadList = new List<Lead>([
                SELECT Id 
                FROM Lead
                LIMIT 50
            ]);
            
            for(Integer i = 0; i < marSegmentationWithoutLead.size(); i++){
                marSegmentationWithoutLead[i].Lead__c = leadList[i].Id;
            }
            Test.startTest();
            update marSegmentationWithoutLead;
            Test.stopTest();

            System.assert(![SELECT Id FROM Lead WHERE Marketing_Segmentation__c IN: marSegmentationWithoutLead].isEmpty(), 'Marketing Segmentation field on lead is not updated.');
        }  
    }

    @isTest
    public static void updateMarketingSegmentationContactTest(){
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator){
            List<Marketing_Segmentation__c> marSegmentationWithoutContact = [
                SELECT Id, Contact__C 
                FROM Marketing_Segmentation__c
                WHERE Contact__c = null
                LIMIT 50
            ];
    
            List<Contact> contactList = new List<Contact>([
                SELECT Id 
                FROM Contact
                LIMIT 50
            ]);
    
            for(Integer i = 0; i < marSegmentationWithoutContact.size(); i++){
                marSegmentationWithoutContact[i].Contact__C = contactList[i].Id;
            }
    
            Test.startTest();
            update marSegmentationWithoutContact;
            Test.stopTest();
            
            System.assert(![SELECT Id FROM Contact WHERE Marketing_Segmentation__c IN: marSegmentationWithoutContact].isEmpty(), 'Marketing Segmentation field on contact is not updated.');
        }
    }
    
    @isTest
    public static void testSetMovingToBrisbaneOnContactNewSegmentation() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            Test.startTest();
            Id contactId = [SELECT Id FROM Contact LIMIT 1].Id;
            Marketing_Segmentation__c marSeg = new Marketing_Segmentation__c(
                Contact__c = contactId,
                My_Moving_To_Brisbane__c = true
            );
            insert marSeg;
            Boolean contactMovingToBrisbane = [SELECT Id, Moving_To_Brisbane__c FROM Contact WHERE Id = :contactId LIMIT 1].Moving_To_Brisbane__c;
            Test.stopTest();
            System.assertEquals(true, contactMovingToBrisbane, 'The contact\'s Moving To Brisbane field was not updated successfully.');
        }
    }
    
    @isTest
    public static void testSetMovingToBrisaneOnContactUpdateSegmentation() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            Test.startTest();
            Marketing_Segmentation__c marSeg = [SELECT Id, Contact__c, My_Moving_To_Brisbane__c FROM Marketing_Segmentation__c WHERE Contact__c != null LIMIT 1];
            Id contactId = [SELECT Id FROM Contact WHERE Id != :marSeg.Contact__c LIMIT 1].Id;
            marSeg.My_Moving_To_Brisbane__c = true;
            marSeg.Contact__c = contactId;
            update marSeg;
            Boolean newContactMovingToBrisbane = [SELECT Id, Moving_To_Brisbane__c FROM Contact WHERE Id = :contactId LIMIT 1].Moving_To_Brisbane__c;
            Test.stopTest();
            System.assertEquals(true, newContactMovingToBrisbane, 'The contact\'s Moving To Brisbane field was not updated successfully.');
        }
    }
}