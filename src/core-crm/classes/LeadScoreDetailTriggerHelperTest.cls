/**
 * @description Test class for LeadScoreDetailTriggerHelper
 * @see LeadScoreDetailTriggerHelper
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                   |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------|
      | julie.jane.alegre              | Sept 07, 2023         | DEPP-5965              | Created file                                     |
 */
@isTest
private class LeadScoreDetailTriggerHelperTest {
    private static Integer numberOfRecords = 50;

    @testSetup
    static void setupMethod(){  
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        TestDataFactoryUser.generateUserFutureStudentAgentDomestic();
        TestDataFactoryUser.generateUserQUTESB();
        Test.stopTest();
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
                    Name = 'Marketing consent',
                    RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
                    Domestic_International__c = 'Undetermined',
                    Study_Level__c = 'Undetermined',
                    Description__c = '',
                    Score_Allocation__c = null,
                    Time_Limit_Months__c = null,
                    Max_Score__c = 200,
                    Parent_Category__c = leadScoreParentConfigList[0].Id
                )
            );

        LeadScoreConfigurationDAO.newInstance()
            .insertRecords(leadScoreConfigList, true, AccessLevel.USER_MODE);

        List<Lead_Score_Configuration__c> leadScoreConfigChildList = new List<Lead_Score_Configuration__c>();
        
        leadScoreConfigChildList.addAll(TestDataFactory.createUndAndUndeterminedSubCategory(
            leadScoreConfigList[0].Id,
            new List<String>{
                'Yes',
                'is blank'
            },
            new List<Integer>{ 200,200}
        ));

        LeadScoreConfigurationDAO.newInstance().insertRecords(leadScoreConfigChildList, true, AccessLevel.SYSTEM_MODE);

        List<Nurture_Track_Configuration__c> configsList = new List<Nurture_Track_Configuration__c>();
        // Alex-offshore: This was in the setup already... o- o?
        configsList.add(new Nurture_Track_Configuration__c(
            Cadence_Name__c = NurtureTrackConfigurationsDAO.INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_MANUAL,
            Lead_Score_Threshold__c = -1,
            Status__c = 'Active'
        ));

        NurtureTrackConfigurationsDAO.newInstance().insertRecords(configsList, true, AccessLevel.SYSTEM_MODE);

        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){ 
            List<Account> accounts = TestDataFactory.createTestAccountRecords(numberOfRecords);     
            AccountsDAO.newInstance().insertRecords(accounts, false, AccessLevel.USER_MODE);     
            List<Lead> leads = TestDataFactory.createTestLeadRecords(numberOfRecords);
            for(Lead lead : leads){   
                lead.Company_Category__c = 'Corporate';
                lead.Description = 'Test Description';
                lead.Lead_Type__c = 'Learner';
                lead.Email_Opt_In_Datetime__c = System.Today();
                lead.Lead_Source_Category__c = '';
            }   
            LeadsDAO.newInstance().insertRecords(leads, false, AccessLevel.USER_MODE);
        }  
        List<Contact> newContact = TestDataFactory.createTestContactRecords(0, 1);
        newContact[0].FirstName = 'Test Contact Flag';
        ContactsDAO.newInstance().insertRecords(newContact, true, AccessLevel.SYSTEM_MODE);

    }
    @isTest 
    private static void linkLeadScoreDetailToContactTest(){ 
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){ 
            List<Lead> leads = LeadsDAO.newInstance().getLeadsWithLimit(numberOfRecords);
            Test.startTest();
            convertLead(leads);
            Test.stopTest();
            List<Contact> updatedContact = ContactsDAO.newInstance().getPersonContactsWithLimit(numberOfRecords);
            for(Contact contact: updatedContact){
                System.assert(contact.Lead_Score_Detail__c != null, 'No contact is updated');
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
    private static void setLeadFlagsTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTESB){ 
            Test.startTest();
            
            Set<Id> leadIdSet = new Set<Id>();
            for (Lead record : LeadsDAO.newInstance().getLeadsWithLimit(numberOfRecords)) { 
                leadIdSet.add(record.Id);
            }

            List<Marketing_Segmentation__c> mktgSegList = MarketingSegmentationsDAO.newInstance().getMarketingSegmentationByContactOrLead(new Set<Id>(), leadIdSet, AccessLevel.SYSTEM_MODE);
            List<Marketing_Segmentation__c> mktgSegListToUpdate = new List<Marketing_Segmentation__c>();
            for (Marketing_Segmentation__c record : mktgSegList) { 
                record.My_Expected_Admission_Year__c = System.today().year();
                record.My_Citizenship_Status__c = 'International Student';
                mktgSegListToUpdate.add(record);
            }
            MarketingSegmentationsDAO.newInstance().updateRecords(mktgSegListToUpdate, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
    
            for(Lead lead: LeadsDAO.newInstance().getLeadsWithLimit(numberOfRecords)){
                System.assertEquals('Explore', lead.Future_Student_Journey_Status__c, 'future student journey status should match');
                System.assertEquals(true, lead.Can_Nurture__c, 'Can_Nurture__c should match');
                System.assertEquals('Nurturing', lead.Status, 'Status should match');
            }
        }
    }

    @isTest
    private static void setContactFlagsTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTESB){ 
            Test.startTest();
            List<Contact> contactList = ContactsDAO.newInstance().getPersonContactsWithLimit(10);
            List<Contact> contactListToUpdate = new List<Contact>();
            for (Contact record : contactList) { 
                if(record.FirstName == 'Test Contact Flag') {
                    record.Email_Opt_In_DateTime__c = Date.today();
                    record.hed__Citizenship_Status__c = 'International';
                    contactListToUpdate.add(record);
                }
            }
            ContactsDAO.newInstance().updateRecords(contactListToUpdate, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();

            for(Contact con: ContactsDAO.newInstance().getPersonContactsBySetIds(new Set<Id>{contactListToUpdate[0].Id}, AccessLevel.SYSTEM_MODE)){
                System.assertEquals(false, con.QUT_Lead__c, 'QUT Lead should match');
                System.assertEquals(true, con.Can_Nurture__c, 'Can_Nurture__c should match');
            }
        }
    }

}
