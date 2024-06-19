/**
 * @description test class for ProgramEnrollmentTriggerHelper
 * @see ProgramEnrollmentTriggerHelper
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala		       | November 03, 2023     | DEPP-7145              | Created file                 |
 */
@isTest
public with sharing class ProgramEnrollmentTriggerHelperTest {
    @TestSetup
    static void makeData(){
        Test.startTest();
        TestDataFactoryUser.generateUserQUTESB();
        Test.stopTest();
        
        System.runAs(TestDataFactoryUser.selectUserQUTESB){
            setupLeadScoreConfig(
                LeadScoreConfigurationDAO.DOMESTIC, 
                LeadScoreConfigurationDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD
            );          
            
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1, ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC);
            contactList[0].QUT_Student__c = false;
            ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.SYSTEM_MODE);    

            List<Account> accountList = TestDataFactory.createTestAccountRecordsWithRecordType(1, AccountsDAO.ACCT_ACADEMIC_PROGRAM_ID);
            accountList[0].Name = 'Start QUT';
            accountList[0].Program_Code__c = 'QC19';
            AccountsDAO.newInstance().insertRecords(accountList, true, AccessLevel.SYSTEM_MODE);
            
            List<hed__Program_Enrollment__c> programEnListToInsert = new List<hed__Program_Enrollment__c>();
            List<hed__Program_Enrollment__c> programEnListWithContact = TestDataFactory.createTestProgramEnrollmentRecords(1); 
            for(hed__Program_Enrollment__c prog: programEnListWithContact){                           
                prog.hed__Contact__c = contactList[0].Id;
                prog.hed__Account__c = accountList[0].Id;
                prog.Enrollment_Status__c = '';
            }
            programEnListToInsert.addAll(programEnListWithContact);
            List<hed__Program_Enrollment__c> programEnList = TestDataFactory.createTestProgramEnrollmentRecords(1); 
            for(hed__Program_Enrollment__c prog: programEnList){                           
                prog.hed__Contact__c = contactList[0].Id;
            }
            programEnListToInsert.addAll(programEnList);
            ProgramEnrollmentsDAO.newInstance().insertRecords(programEnListToInsert, true, AccessLevel.SYSTEM_MODE);
            
            List<Marketing_Segmentation__c> marketingSegmentationConList = MarketingSegmentationsDAO.newInstance().getMarketingSegmentationByContactIds(new Set<Id>{contactList[0].Id}, AccessLevel.SYSTEM_MODE);
            List<Marketing_Segmentation__c> mktgSegConToUpdate = new List<Marketing_Segmentation__c>();
            for(Marketing_Segmentation__c mktgSeg : marketingSegmentationConList){
                mktgSeg.My_Primary_Study_Level__c = 'Undergraduate';
                mktgSegConToUpdate.add(mktgSeg);
            }
            MarketingSegmentationsDAO.newInstance().updateRecords(mktgSegConToUpdate, true, AccessLevel.SYSTEM_MODE);
        }
        
    }

    @isTest
    public static void resetLeadScoreTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            Test.startTest();

            List<Contact> contactList = ContactsDAO.newInstance().getPersonContactsWithLimit(1);

            List<hed__Program_Enrollment__c> programEnList = ProgramEnrollmentsDAO.newInstance()
            .getAllProgramEnrollmentsByContactId(new Set<Id>{contactList[0].Id}, AccessLevel.SYSTEM_MODE);
            for(hed__Program_Enrollment__c prog: programEnList){ 
                if(prog.hed__Account__c!=null){
                    prog.Enrollment_Status__c = 'Admitted';
                }                          
            }
            ProgramEnrollmentsDAO.newInstance().updateRecords(programEnList, true, AccessLevel.SYSTEM_MODE);
            Test.stopTest();

            List<Lead_Score_Detail__c> leadScoreDetailsUpdated = LeadScoreDetailsDAO.newInstance().getLeadScoreDetailsByContactOrLeadId(new Set<Id>{contactList[0].Id}, AccessLevel.SYSTEM_MODE);
            System.assert(leadScoreDetailsUpdated[0].Total_Lead_Score__c == 0, 'Incorrect Total Lead Score.');
        }        
    }
    
    @isTest
    public static void programEnrollmentAddressValidationTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            Test.startTest();
            
            List<ABS_Categorisation__c> absCategorisation = new List<ABS_Categorisation__c>();
            absCategorisation.add(
                new ABS_Categorisation__c(
                    Name = 'Categorisation 1',
                    Is_Active__c = true,
                    Low_SES_Lower_Boundary__c = 0,
                    Low_SES_Upper_Boundary__c = 80,
                    Remoteness_Inner_Regional__c = true,
                    Remoteness_Outer_Regional__c = true,
                    Remoteness_Remote__c = true,
                    Remoteness_Very_Remote__c = true
                )
            );
            
            ABSCategorisationsDAO.newInstance().insertRecords(absCategorisation, false, AccessLevel.USER_MODE);
            
            Test.setMock(HTTPCalloutMock.class, new GenericHttpCalloutMock(200, 'Ok', ''));

            List<Contact> contactList = ContactsDAO.newInstance().getPersonContactsWithLimit(1);
            
            List<hed__Address__c> addresses = new List<hed__Address__c>();
            
            for (Integer i = 0; i < contactList.size(); i++) {
                hed__Address__c add = new hed__Address__c();
                add.hed__Parent_Contact__c = contactList[i].Id;
                add.hed__Address_Type__c = AddressesDAO.OTHER_ADDRESS;
                add.Validated__c = AddressesDAO.NOT_VALID_ADDRESS;
                add.hed__MailingCountry__c = 'Australia';
                add.hed__MailingState__c = 'QLD';
                add.hed__MailingCity__c = 'DALLARNIL';
                add.hed__MailingPostalCode__c = '12345';
                add.hed__MailingStreet__c = '1234 Test St';
                add.hed__MailingStreet2__c = '4321 Tester Street';
                addresses.add(add);
            }
			AddressesDAO.newInstance().insertRecords(addresses, false, AccessLevel.USER_MODE);
            
            List<hed__Program_Enrollment__c> programEnList = ProgramEnrollmentsDAO.newInstance()
            .getAllProgramEnrollmentsByContactId(new Set<Id>{contactList[0].Id}, AccessLevel.SYSTEM_MODE);
            for(hed__Program_Enrollment__c prog: programEnList){ 
                if(prog.hed__Account__c!=null){
                    prog.Enrollment_Status__c = 'Admitted';
                }                          
            }
            ProgramEnrollmentsDAO.newInstance().updateRecords(programEnList, true, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            
            //Other Address
            for(hed__Address__c address: AddressesDAO.newInstance().getAddressesByContactIdsAndAddressType(new Map<Id,Contact>(contactList).keySet(),new Set<String>{AddressesDAO.OTHER_ADDRESS},'USER_MODE')){
                System.Assert.areEqual(true, address.Is_First_Admission_Address__c , 'First Admission must set be true');                
            }

        }        
    }

    private static void setupLeadScoreConfig(String citizenship, String studyLevel){
        List<Lead_Score_Configuration__c> leadScoreParentConfigList = new List<Lead_Score_Configuration__c>();
        leadScoreParentConfigList.add(
            new Lead_Score_Configuration__c(
                Name = 'Total Max Score DUG',
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CONFIG,
                Domestic_International__c = citizenship,
                Study_Level__c = studyLevel
            )
        );

        LeadScoreConfigurationDAO.newInstance().insertRecords(leadScoreParentConfigList, true, AccessLevel.SYSTEM_MODE);

        List<Lead_Score_Configuration__c> leadScoreCategoryList = new List<Lead_Score_Configuration__c>();
        leadScoreCategoryList.add(
            new Lead_Score_Configuration__c(
                Parent_Category__c = leadScoreParentConfigList[0].Id,
                Name = 'Program Engagement',
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
                Domestic_International__c = citizenship,
                Study_Level__c = studyLevel,
                Description__c = '',
                Time_Limit_Months__c = 0,
                Max_Score__c = 30
            )
        );

        LeadScoreConfigurationDAO.newInstance().insertRecords(leadScoreCategoryList, true, AccessLevel.SYSTEM_MODE);

        Id categoryId = leadScoreCategoryList[0].Id;

        List<Lead_Score_Configuration__c> leadScoreSubCategoryList = new List<Lead_Score_Configuration__c>();
        leadScoreSubCategoryList.addALl(createDomUGCategoryRecords(citizenship, studyLevel, categoryId));    
        leadScoreSubCategoryList.addALl(createDomPGCategoryRecords(citizenship, studyLevel, categoryId));   
        leadScoreSubCategoryList.addALl(createIntPGCategoryRecords(citizenship, studyLevel, categoryId));   
        LeadScoreConfigurationDAO.newInstance().insertRecords(leadScoreSubCategoryList, true, AccessLevel.SYSTEM_MODE);
    }

    private static List<Lead_Score_Configuration__c> createDomUGCategoryRecords(String citizenship, String studyLevel, Id categoryId){
        List<Lead_Score_Configuration__c> response = new List<Lead_Score_Configuration__c>();
        if(citizenship == 'Domestic' && studylevel == 'Undergraduate'){
            response.addAll(
                TestDataFactory.createDomstcAndUnderGradSubCategory(
                    categoryId,
                    getCategoryList(),
                    getScoreAllocList()
                )
            );
        }
        return response;
    }

    private static List<Lead_Score_Configuration__c> createDomPGCategoryRecords(String citizenship, String studyLevel, Id categoryId){
        List<Lead_Score_Configuration__c> response = new List<Lead_Score_Configuration__c>();
        if(citizenship == 'Domestic' && studylevel == 'Postgraduate'){
            response.addAll(
                TestDataFactory.createDomstcAndPostGradSubCategory(
                    categoryId,
                    getCategoryList(),
                    getScoreAllocList()
                )
            );
        }
        return response;
    }

    private static List<Lead_Score_Configuration__c> createIntPGCategoryRecords(String citizenship, String studyLevel, Id categoryId){
        List<Lead_Score_Configuration__c> response = new List<Lead_Score_Configuration__c>();
        if(citizenship == 'International' && studylevel == 'Postgraduate'){
            response.addAll(
                TestDataFactory.createInlAndPostGradSubCategory(
                    categoryId,
                    getCategoryList(),
                    getScoreAllocList()
                )
            );
        }
        return response;
    }

    private static List<String> getCategoryList(){
        return new List<String>{
            'Program Engagement attendance'
        };
    }

    private static List<Integer> getScoreAllocList(){
        return new List<Integer>{ 30 };
    }
    
}