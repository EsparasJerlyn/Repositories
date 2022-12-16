/**
 * @description Test Class for MarketingSegmentationTriggerHelper
 * @see ..MarketingSegmentationTriggerHelper
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------|
      | roy.nino.s.regala              | Oct 26, 2022          | DEPP-4327              | Created file                                   |

 */

@isTest
public without sharing class MarketingSegmentationTriggerHelperTest{

    @testSetup
    static void setupMethod() {
        Test.startTest();
        TestDataFactory.generateTestUsers();
        Test.stopTest();

        System.runAs(TestDataFactory.getISRStudentEnquiriesCommunicationOfficer()){
            List<Contact> contactList = TestDataFactory.createTestContactRecords(50);
            List<Lead> leadList =  TestDataFactory.createTestLeadRecords(50);
            insert contactList;
            insert leadList;
    
            List<Marketing_Segmentation__c> marketingSegmenationList =  new List<Marketing_Segmentation__c>();
            for(Contact contactRecord: contactList){
                marketingSegmenationList.add(new Marketing_Segmentation__c(Contact__c = contactRecord.Id));
            }
    
            for(Lead leadRecord: leadList){
                marketingSegmenationList.add(new Marketing_Segmentation__c(Lead__c = leadRecord.Id));
            }
    
            insert marketingSegmenationList;
        }
        

        System.assert(![SELECT Id FROM Lead WHERE Marketing_Segmentation__c != null].isEmpty(), 'Marketing Segmentation field on lead is not updated.');
        System.assert(![SELECT Id FROM Contact WHERE Marketing_Segmentation__c != null].isEmpty(), 'Marketing Segmentation field on contact is not updated.');
        
    }

    @isTest
    public static void updateMarketingSegmentationLeadTest(){
        System.runAs(TestDataFactory.getISRStudentEnquiriesCommunicationOfficer()){
            List<Marketing_Segmentation__c> marSegmentationWithoutLead = [
                SELECT Id, Lead__c 
                FROM Marketing_Segmentation__c
                WHERE Lead__c = null
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
        
        System.runAs(TestDataFactory.getISRStudentEnquiriesCommunicationOfficer()){
            List<Marketing_Segmentation__c> marSegmentationWithoutContact = [
                SELECT Id, Contact__C 
                FROM Marketing_Segmentation__c
                WHERE Contact__c = null
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


 }