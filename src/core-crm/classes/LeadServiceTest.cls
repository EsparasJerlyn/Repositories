/**
 * @description Test Class for LeadService
 *
 * @see LeadService
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                          |
      |---------------------------|-----------------------|--------------|---------------------------------------------------------|
      | mark.j.mahilum            | June 13,2023          | DEPP-5798    | Created file                                            |
      | mark.j.mahilum            | July 28, 2023         | DEPP-6106    | Updated test class to cover can nurture logic           |
      | julie.jane.alegre         | Sept 07, 2023         | DEPP-5965    | Add test method testCreateLeadScoreDetail               |
      | julie.jane.alegre         | Sept 14, 2023         | DEPP-6679    | Added test class testCreateMarketingSegmentation        |
      | eccarius.munoz            | March 5, 2024         | DEPP-7699    | Added test method for lead source and lead source       |
      |                           |                       |              | category values when user profile is FSE.               |
      | arsenio.jr.dayrit         | March 7, 2024         | DEPP-8069    | Added test method for create Lead Can Nurture           |
*/
@isTest
private class LeadServiceTest {
    private static Integer recordsCount = 5;
    private static final String LASTNAME = 'Testlastname';
    private static final String EMAIL = 'testmail@mail.test';
    private static final String COMPANY = 'Testcompany';
    private static final String LEAD_TYPE = 'Learner';

    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        TestDataFactoryUser.generateUserFutureStudentAgentDomestic();
        TestDataFactoryUser.generateUserQUTESB();
        Test.stopTest();

        List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();
        Nurture_Track_Configuration__c nurtureConfig = new Nurture_Track_Configuration__c();
        nurtureConfig.Lead_Score_Threshold__c = 1;
        nurtureConfig.Status__c = 'Active';
        nurtureList.add(nurtureConfig);
        NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureList, false, AccessLevel.SYSTEM_MODE); 

        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            LeadsDAO.newInstance()
                .insertRecords(
                    TestDataFactory.createTestLeadRecords(0, recordsCount),
                    true,
                    AccessLevel.USER_MODE
                );
        }
    }

    @isTest
    private static void testLeadBatchInsertLeadScoreBelowFifty() {
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            setupLeadScoreConfig(10);

            List<Lead> ldList = LeadsDAO.newInstance().getLeadsWithLimit(recordsCount);
            List<Lead> leadsToUpdate = new List<Lead>();
            for (Integer i = 0; i < recordsCount; i++) {
                leadsToUpdate.add(
                    new Lead(
                        Id = ldList[i].Id,
                        Email = 'new' + i + EMAIL,
                        Work_Email__c = 'newwork' + i + EMAIL,
                        Email_Opt_In_DateTime__c = Date.today()
                    )
                );
            }

            Test.startTest();
            LeadsDAO.newInstance().updateRecords(leadsToUpdate, true, AccessLevel.SYSTEM_MODE);
            Test.stopTest();

            for (Lead lead : LeadsDAO.newInstance().getLeadsWithLimit(recordsCount)) {
                System.assertEquals('New', lead.Status, 'Lead Status did not match');
            }
        }
    }
    
    @isTest
    private static void testLeadBatchUpdateLeadScoreAboveFifty() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            setupLeadScoreConfig(60);

            List<Lead> ldList = LeadsDAO.newInstance().getLeadsWithLimit(recordsCount);
            List<Lead> leadsToUpdate = new List<Lead>();
            for (Integer i = 0; i < recordsCount; i++) {
                leadsToUpdate.add(
                    new Lead(
                        Id = ldList[i].Id,
                        Email = 'new' + i + EMAIL,
                        Work_Email__c = 'newwork' + i + EMAIL,
                        HasOptedOutOfEmail = true
                    )
                );
            }

            LeadsDAO.newInstance().updateRecords(leadsToUpdate, true, AccessLevel.SYSTEM_MODE);

            List<Lead> leadsToUpdate2 = new List<Lead>();
            for (Integer i = 0; i < recordsCount; i++) {
                leadsToUpdate2.add(
                    new Lead(
                        Id = ldList[i].Id,
                        Email = 'new' + i + EMAIL,
                        Work_Email__c = 'newwork' + i + EMAIL,
                        HasOptedOutOfEmail = false
                    )
                );
            }
            
            Test.startTest();
            MarketingConsentHelper.runSetOptOutAndInDates.clear();
            LeadsDAO.newInstance().updateRecords(leadsToUpdate2, true, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            
            for (Lead lead :LeadsDAO.newInstance().getLeadsWithLimit(recordsCount)) {  
                System.assertEquals('Engaging', lead.Status,'Lead Status did not match');
                System.assertEquals('Explore', lead.Future_Student_Journey_Status__c,'Lead Future_Student_Journey_Status__c did not match');
            }
        }
    }
    
    @isTest
    private static void testLeadBatchUpdateLeadScoreAboveOneHundred() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            setupLeadScoreConfig(200);

            List<Lead> ldList = LeadsDAO.newInstance().getLeadsWithLimit(recordsCount);
            List<Lead> leadsToUpdate = new List<Lead>();
            for (Integer i = 0; i < recordsCount; i++) {
                leadsToUpdate.add(
                    new Lead(
                        Id = ldList[i].Id,
                        Email = 'new' + i + EMAIL,
                        Work_Email__c = 'newwork' + i + EMAIL,
                        HasOptedOutOfEmail = true
                    )
                );
            }

            LeadsDAO.newInstance().updateRecords(leadsToUpdate, true, AccessLevel.SYSTEM_MODE);

            List<Lead> leadsToUpdate2 = new List<Lead>();
            for (Integer i = 0; i < recordsCount; i++) {
                leadsToUpdate2.add(
                    new Lead(
                        Id = ldList[i].Id,
                        Email = 'new' + i + EMAIL,
                        Work_Email__c = 'newwork' + i + EMAIL,
                        HasOptedOutOfEmail = false
                    )
                );
            }
            
            Test.startTest();
            MarketingConsentHelper.runSetOptOutAndInDates.clear();
            LeadsDAO.newInstance().updateRecords(leadsToUpdate2, true, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            
            for (Lead lead :LeadsDAO.newInstance().getLeadsWithLimit(recordsCount)) {  
                System.assertEquals('Nurturing', lead.Status,'Lead Status did not match');
                System.assertEquals('Explore', lead.Future_Student_Journey_Status__c,'Lead Future_Student_Journey_Status__c did not match');
            }
        }
    }

    @isTest
    private static void testLeadBatchUpdateCanNurtureIsCheck() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            setupLeadScoreConfig(2);
            
            List<Lead> ldList = LeadsDAO.newInstance().getLeadsWithLimit(recordsCount);
            List<Lead> leadsToUpdate = new List<Lead>();
            for (Integer i = 0; i < recordsCount; i++) {
                leadsToUpdate.add(
                    new Lead(
                        Id = ldList[i].Id,
                        Email = 'new' + i + EMAIL,
                        Work_Email__c = 'newwork' + i + EMAIL,
                        Email_Opt_In_DateTime__c = Date.today(),
                        Lead_Source_Category__c = 'Partner Sourced'
                    )
                );
            }
            
            Test.startTest();
            LeadsDAO.newInstance().updateRecords(leadsToUpdate, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            
            for (Lead lead :LeadsDAO.newInstance().getLeadsWithLimit(recordsCount)) {  
                System.assert(lead.Can_Nurture__c,'Can Nurture is not ticked');
            }
        }
    }

    @isTest
    private static void testGetLeadCalculatedCadence() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            
            List<Lead> ldList = LeadsDAO.newInstance().getLeadsWithLimit(recordsCount);
            List<Lead> leadsToUpdate = new List<Lead>();
            for (Integer i = 0; i < recordsCount; i++) {
                leadsToUpdate.add(
                    new Lead(
                        Id = ldList[i].Id,
                        Email = 'new' + i + EMAIL,
                        Work_Email__c = 'newwork' + i + EMAIL,
                        Calculated_Cadence__c = 'Test Cadences automated'
                    )
                );
            }
            Test.startTest();
            LeadsDAO.newInstance().updateRecords(leadsToUpdate, true, AccessLevel.SYSTEM_MODE);                
            Test.stopTest();
            System.assert(![SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'SalesCadenceCalloutService'].isEmpty() , 'SalesCadenceCalloutService Queueable Job was not executed');
        }
    }    
    @isTest
    private static void testCreateLeadScoreDetail() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            List<Account> accounts = TestDataFactory.createTestAccountRecords(recordsCount);     
            AccountsDAO.newInstance().insertRecords(accounts, false, AccessLevel.USER_MODE);     
            List<Lead> leads = TestDataFactory.createTestLeadRecords(recordsCount);
            for(Lead lead : leads){   
                lead.Company_Category__c = 'Corporate';
                lead.Description = 'Test Description';
                lead.Lead_Type__c = 'CCE Corporate Partner';
            }   
            LeadsDAO.newInstance().insertRecords(leads, false, AccessLevel.USER_MODE);
            Test.startTest();
            convertLead(leads);
            Test.stopTest();
            List<Lead_Score_Detail__c> lsdList = LeadScoreDetailsDAO.newInstance().getLeadScoreDetailWithLimit(recordsCount);
            System.assert(lsdList.size() > 0, 'No record created');
        }
    }

    @isTest
    private static void testCreateLeadCanNurture() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {   
            Test.startTest(); 
            List<Lead> leads = TestDataFactory.createTestLeadRecords(recordsCount);
            for(Lead lead : leads){   
                lead.Company_Category__c = 'Corporate';
                lead.Lead_Source_Category__c = 'Partner Sourced';
            }   
            LeadsDAO.newInstance().insertRecords(leads, false, AccessLevel.USER_MODE);
            Test.stopTest();
            List<Lead> leadList = [SELECT Id, Can_Nurture__c FROM Lead WHERE Lead_Source_Category__c = 'Partner Sourced'];
            For(Lead lead : leadList){
                System.assert(lead.Can_Nurture__c,'Can Nurture is not ticked');
            }
        }
    }

    private static void convertLead(List<Lead> leads){
        List<Database.LeadConvert> leadstoConvert = new List<Database.LeadConvert>(); 
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        for(Lead lead : leads) {
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lead.id);
            lc.setConvertedStatus(convertStatus.MasterLabel);
            leadstoConvert.add(lc);
        }
        Database.convertLead(leadstoConvert);  
    }    

    @isTest
    private static void testCreateMarketingSegmentationForLeads() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Account> accounts = TestDataFactory.createTestAccountRecords(recordsCount);     
            AccountsDAO.newInstance().insertRecords(accounts, false, AccessLevel.USER_MODE);     
            List<Lead> leads = TestDataFactory.createTestLeadRecords(recordsCount);
            for(Lead lead : leads){   
                lead.Company_Category__c = 'Corporate';
                lead.Description = 'Test Description';
                lead.Lead_Type__c = 'CCE Corporate Partner';
            }   
            Database.SaveResult[] srList = LeadsDAO.newInstance().insertRecords(leads, false, AccessLevel.USER_MODE);
            Test.startTest();
            
            Set<Id> leadIds = new Set<Id>();            
            for (Database.SaveResult sr : srList) {
                leadIds.add(sr.getId());
            }
            List<Marketing_Segmentation__c> marketingSegList = MarketingSegmentationsDAO.newInstance().getMarketingSegmentationByLeadIds(leadIds, AccessLevel.USER_MODE);
            
            for(Marketing_Segmentation__c marketingSeg : marketingSegList){
                System.assert(marketingSeg.Lead__c != null, 'No Marketing Segmentation record created for the lead');
            }
        }
    }

    @isTest
    private static void testSetLeadSourceAndLeadSourceCategoryFields() {
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            setupLeadScoreConfig(10);
            Test.startTest();
            String lastName = 'FSELead';
            List<Lead> leadListToInsert = TestDataFactory.createTestLeadRecords(0, recordsCount);
            for(Lead lead : leadListToInsert){
                lead.LastName = lastName;
                lead.Email = lastName + lead.Email;
                lead.Work_Email__c = lastName + lead.Work_Email__c;
            }

            LeadsDAO.newInstance().insertRecords(leadListToInsert, true, AccessLevel.USER_MODE);
            Test.stopTest();

            for (Lead lead : LeadsDAO.newInstance().getLeadsWithLimit(recordsCount)) {
                if(lead.LastName == lastName){
                    System.assertEquals('Manual Create', lead.LeadSource, 'Lead Source did not match');
                    System.assertEquals('Other', lead.Lead_Source_Category__c, 'Lead Source Category did not match');
                }
            }
        }
    }

    @isTest
    private static void testSetLeadSourceAndLeadSourceCategoryFieldsNonFSE() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            setupLeadScoreConfig(10);
            for (Lead lead : LeadsDAO.newInstance().getLeadsWithLimit(recordsCount)) {
                System.assertEquals(null, lead.LeadSource, 'Lead Source did not match');
                System.assertEquals(null, lead.Lead_Source_Category__c, 'Lead Source Category did not match');
            }
        }
    } 

    private static void setupLeadScoreConfig(Decimal maxScore){
        List<Lead_Score_Configuration__c> leadScoreParentConfigList = new List<Lead_Score_Configuration__c>();
        leadScoreParentConfigList.add(
            new Lead_Score_Configuration__c(
                Name = 'Total Max Score DUG',
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CONFIG,
                Domestic_International__c = 'Undetermined',
                Study_Level__c = 'Undetermined'
            )
        );

        LeadScoreConfigurationDAO.newInstance().insertRecords(leadScoreParentConfigList, true, AccessLevel.SYSTEM_MODE);

        List<Lead_Score_Configuration__c> leadScoreConfigList = new List<Lead_Score_Configuration__c>();

        leadScoreConfigList.add(
            new Lead_Score_Configuration__c(
                Name = 'Marketing Consent',
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
                Domestic_International__c = 'Undetermined',
                Study_Level__c = 'Undetermined',
                Description__c = '',
                Score_Allocation__c = null,
                Time_Limit_Months__c = null,
                Max_Score__c = maxScore,
                Parent_Category__c = leadScoreParentConfigList[0].Id
            )
        );

        LeadScoreConfigurationDAO.newInstance()
            .insertRecords(leadScoreConfigList, true, AccessLevel.SYSTEM_MODE);

        List<Lead_Score_Configuration__c> leadScoreConfigChildList = new List<Lead_Score_Configuration__c>();
        leadScoreConfigChildList.addAll(TestDataFactory.createUndAndUndeterminedSubCategory(
            leadScoreConfigList[0].Id,
            new List<String>{
                'Yes',
                'Is blank'
            },
            new List<Integer>{(Integer)maxScore,(Integer)maxScore}
        ));

        LeadScoreConfigurationDAO.newInstance()
            .insertRecords(leadScoreConfigChildList, true, AccessLevel.SYSTEM_MODE);
    }
    
} 