/**
  * @description Test class for IndividualEmailLeadScoreHelper
  * @see ..IndividualEmailLeadScoreHelper
  *
  * @author Accenture 
  *
  * @history
  *
  *    | Developer                      | Date                  | JIRA                   | Change Summary             |
  *    |--------------------------------|-----------------------|------------------------|----------------------------|
  *    | eccarius.munoz                 | October 26, 2023      | DEPP-5866              | Created file               |
  *    |                                |                       |                        |                            |
  */

@isTest
public with sharing class IndividualEmailLeadScoreHelperTest {
    @TestSetup
    static void makeData(){
        TestDataFactoryUser.generateUserQUTESB();

        Test.startTest();
        setupLeadScoreConfig();

        List<Contact> contactList = TestDataFactory.createTestContactRecords(2, ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC);
        ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.SYSTEM_MODE);    

        List<Lead> leadList = TestDataFactory.createTestLeadRecords(1,2);
        LeadsDAO.newInstance().insertRecords(leadList, true, AccessLevel.SYSTEM_MODE);    
        Test.stopTest();
        
        List<Marketing_Segmentation__c> mktgSegToUpdate = new List<Marketing_Segmentation__c>();
        List<Marketing_Segmentation__c> marketingSegmentationList = MarketingSegmentationsDAO.newInstance().getMarketingSegmentationByContactOrLead(
            new Set<Id>{contactList[0].Id, contactList[1].Id}, 
            new Set<Id>{leadList[0].Id}, 
            AccessLevel.SYSTEM_MODE
        );

        for(Marketing_Segmentation__c mktgSeg : marketingSegmentationList){
            mktgSeg.My_Primary_Study_Level__c = 'Postgraduate';
            mktgSeg.My_Citizenship_Status__c = MarketingSegmentationsDAO.CITIZENSHIP_STATUS_DOMESTIC_AU;
            if(mktgSeg.Contact__c != null){
                mktgSeg.My_Primary_Study_Level__c = 'Undergraduate';
            }
            mktgSegToUpdate.add(mktgSeg);
        }
        MarketingSegmentationsDAO.newInstance().updateRecords(mktgSegToUpdate, true, AccessLevel.SYSTEM_MODE);

        
    }

    @isTest
    public static void processIndividualEmailInsertTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            Test.startTest();

            List<Contact> contactList = ContactsDAO.newInstance().getPersonContactsWithLimit(2);
            List<Lead> leadList = LeadsDAO.newInstance().getLeadsWithLimit(1);

            et4ae5__Automated_Send__c automatedSend = new et4ae5__Automated_Send__c( Name = 'Test Automated Send' );
            insert automatedSend;

            List<et4ae5__IndividualEmailResult__c> indivEmailListToAdd = new List<et4ae5__IndividualEmailResult__c>();
            indivEmailListToAdd.add(
                new et4ae5__IndividualEmailResult__c(
                    et4ae5__TriggeredSendDefinition__c = automatedSend.Id,
                    et4ae5__Lead__c = leadList[0].Id, 
                    et4ae5__Opened__c = true,
                    et4ae5__NumberOfUniqueClicks__c	= 2,
                    et4ae5__DateOpened__c = System.Today()
                )
            );
            indivEmailListToAdd.add(
                new et4ae5__IndividualEmailResult__c(
                    et4ae5__TriggeredSendDefinition__c = automatedSend.Id,
                    et4ae5__Contact__c = contactList[0].Id, 
                    et4ae5__Opened__c = true,
                    et4ae5__NumberOfUniqueClicks__c	= 2,
                    et4ae5__DateOpened__c = System.Today()
                )
            );
            indivEmailListToAdd.add(
                new et4ae5__IndividualEmailResult__c(
                    et4ae5__TriggeredSendDefinition__c = automatedSend.Id,
                    et4ae5__Contact__c = contactList[1].Id, 
                    et4ae5__Opened__c = true,
                    et4ae5__NumberOfUniqueClicks__c	= 2,
                    et4ae5__DateOpened__c = System.Today()
                )
            );
            
            IndividualEmailResultsDAO.newInstance().insertRecords(indivEmailListToAdd, true, AccessLevel.SYSTEM_MODE); 

            Test.stopTest();
           
            List<Lead_Score_Detail__c> leadScoreDetails = LeadScoreDetailsDAO.newInstance().getLeadScoreDetailsByContactOrLeadId(new Set<Id>{contactList[0].Id, contactList[1].Id, leadList[0].Id}, AccessLevel.SYSTEM_MODE);
            System.assertEquals(10, leadScoreDetails[0].Total_Lead_Score__c, 'Incorrect Total Lead Score.');
            System.assertEquals(10, leadScoreDetails[1].Total_Lead_Score__c, 'Incorrect Total Lead Score.');
            System.assertEquals(10, leadScoreDetails[2].Total_Lead_Score__c, 'Incorrect Total Lead Score.');
        }        
    }

    @isTest
    public static void processIndividualEmailUpdateTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            List<Contact> contactList = ContactsDAO.newInstance().getPersonContactsWithLimit(2);

            et4ae5__Automated_Send__c automatedSend = new et4ae5__Automated_Send__c( Name = 'Test Automated Send' );
            insert automatedSend;

            List<et4ae5__IndividualEmailResult__c> indivEmailListToAdd = new List<et4ae5__IndividualEmailResult__c>();
            indivEmailListToAdd.add(
                new et4ae5__IndividualEmailResult__c(
                    et4ae5__TriggeredSendDefinition__c = automatedSend.Id,
                    et4ae5__Contact__c = contactList[0].Id, 
                    et4ae5__NumberOfUniqueClicks__c	= 2,
                    et4ae5__DateOpened__c = System.Today()
                )
            );
            
            IndividualEmailResultsDAO.newInstance().insertRecords(indivEmailListToAdd, true, AccessLevel.SYSTEM_MODE); 

            Test.startTest();
            
            List<et4ae5__IndividualEmailResult__c> indivEmailListToUpdate = new List<et4ae5__IndividualEmailResult__c>();
            for(et4ae5__IndividualEmailResult__c indivEmail : indivEmailListToAdd){
                indivEmail.et4ae5__Opened__c = true;
                indivEmailListToUpdate.add(indivEmail);
            }
            IndividualEmailResultsDAO.newInstance().updateRecords(indivEmailListToUpdate, true, AccessLevel.SYSTEM_MODE); 

            Test.stopTest();
           
            List<Lead_Score_Detail__c> leadScoreDetails = LeadScoreDetailsDAO.newInstance().getLeadScoreDetailsByContactOrLeadId(new Set<Id>{contactList[0].Id}, AccessLevel.SYSTEM_MODE);
            System.assertEquals(10, leadScoreDetails[0].Total_Lead_Score__c, 'Incorrect Total Lead Score.');
        }        
    }

    private static void setupLeadScoreConfig(){

        List<Lead_Score_Configuration__c> leadScoreParentConfigList = new List<Lead_Score_Configuration__c>();
        leadScoreParentConfigList.add(
            new Lead_Score_Configuration__c(
                Name = 'Total Max Score DUG',
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CONFIG,
                Domestic_International__c = LeadScoreConfigurationDAO.DOMESTIC,
                Study_Level__c = LeadScoreConfigurationDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD
            )
        );
        LeadScoreConfigurationDAO.newInstance().insertRecords(leadScoreParentConfigList, true, AccessLevel.SYSTEM_MODE);

        List<Lead_Score_Configuration__c> categList = new List<Lead_Score_Configuration__c>();
        categList.add(setUpCategory(
            LeadScoreConfigurationDAO.DOMESTIC, 
            LeadScoreConfigurationDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD, 
            leadScoreParentConfigList[0].Id
        ));
        categList.add(setUpCategory(
            LeadScoreConfigurationDAO.INTERNATIONAL, 
            LeadScoreConfigurationDAO.PRIMARY_STUDY_LEVEL_POSTGRAD,
            leadScoreParentConfigList[0].Id
        ));
        categList.add(setUpCategory(
            LeadScoreConfigurationDAO.DOMESTIC, 
            LeadScoreConfigurationDAO.PRIMARY_STUDY_LEVEL_POSTGRAD,
            leadScoreParentConfigList[0].Id
        ));
        LeadScoreConfigurationDAO.newInstance().insertRecords(categList, true, AccessLevel.SYSTEM_MODE);

        List<Lead_Score_Configuration__c> subCategList = new List<Lead_Score_Configuration__c>();
        for(Lead_Score_Configuration__c conf : categList){
            if(conf.Domestic_International__c == 'Domestic' && conf.Study_Level__c == 'Undergraduate'){
                subCategList.add(setUpSubCategory('Domestic', 'Undergraduate', conf.Id));
            }
            else if(conf.Domestic_International__c == 'International' && conf.Study_Level__c == 'Postgraduate'){
                subCategList.add(setUpSubCategory('International', 'Postgraduate', conf.Id));
            }
            else if(conf.Domestic_International__c == 'Domestic' && conf.Study_Level__c == 'Postgraduate'){
                subCategList.add(setUpSubCategory('Domestic', 'Postgraduate', conf.Id));
            }
        }
        LeadScoreConfigurationDAO.newInstance().insertRecords(subCategList, true, AccessLevel.SYSTEM_MODE);
    }


    private static Lead_Score_Configuration__c setUpSubCategory(String citizenship, String studyLevel, Id parentCategId){
        Lead_Score_Configuration__c leadScoreConfig = new Lead_Score_Configuration__c(
            Parent_Category__c = parentCategId,
            Name = 'Has Clicked Email',
            RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY,
            Domestic_International__c = citizenship,
            Study_Level__c = studyLevel,
            Description__c = '',
            Score_Allocation__c = 10
        );

        return leadScoreConfig;
    }

    private static Lead_Score_Configuration__c setUpCategory(String citizenship, String studyLevel, Id parentCategId){
        Lead_Score_Configuration__c leadScoreConfig = new Lead_Score_Configuration__c(
            Parent_Category__c = parentCategId,
            Name = 'Email Interaction',
            RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
            Domestic_International__c = citizenship,
            Study_Level__c = studyLevel,
            Description__c = '',
            Score_Allocation__c = null,
            Time_Limit_Months__c = 3,
            Max_Score__c = 30
        );

        return leadScoreConfig;
    }
}