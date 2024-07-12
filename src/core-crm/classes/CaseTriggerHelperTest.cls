/**
 * @description Test Class for CaseTriggerHelper
 *
 * @see CaseTriggerHelper
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                        |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------|
      | mark.j.mahilum                 | Sept 12, 2023         | DEPP-6421              | Created file                                          |
      | arsenio.jr.dayrit              | Sept 22,2023          | DEPP-6720              | added test method for updating case using WhatsApp    |
      | johanna.a.gibas                | Nov 24, 2023          | DEPP-7143              | Removed references to Priority on International Tier  |
      | eccarius.munoz                 | February 16, 2024     | DEPP-7714	            | Added test method of case prio with sub category      | 
      | eccarius.munoz                 | February 19, 2024     | DEPP-7867	            | Added test method of case prio with lead src category | 
      | eccarius.munoz                 | April 5, 2024         | DEPP-7533	            | Added test method for handleOutreachCasePriority      | 
      | gabriel.p.ventayen             | April 22, 2024        | DEPP-8544	            | change rectype to inbound enquiry and add case type   | 
 */
@isTest
private class CaseTriggerHelperTest {
    
    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTESB();
        TestDataFactoryUser.generateUserStudentSuccessOutreachManager();
        Test.stopTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB){
            List<International_Tier__c> tierList = TestDataFactory.createInternationalTierRecords(new List<String>{'Wales','Australia'}, 'Tier 1',true);
            International_Tier__c internationalTiersWithSubCateg = TestDataFactory.createInternationalTierRecords(new List<String>{ 'Yemen' }, 'Untiered',  true)[0];
            internationalTiersWithSubCateg.Tier_Subcategory__c = 'Restricted';
            tierList.add(internationalTiersWithSubCateg);
            
            InternationalTiersDAO.newInstance().insertRecords(tierList,false,AccessLevel.USER_MODE);
            List<Case_Priority_Configuration__c> casePrioConfig = TestDataFactory.createCasePrioConfigRecords();
            CasePriorityConfigurationsDAO.newInstance().insertRecords(casePrioConfig,false,AccessLevel.USER_MODE);
        }
        
        
    }
    
    @isTest
    private static void testCaseEmailMatchToContactEmail() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].Email = '1testmail@mail.test';
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);
            Test.startTest();
            List<Case> cases = new List<Case>();
            cases.add(
                new Case(  
                    Status = 'Created', 
                    Subject = 'Test Case',
                    SuppliedEmail = '1testmail@mail.test',
                    Description = 'Test Case Description',
                    Origin = 'Email',
                    Case_Type__c = CasesDAO.CASE_TYPE_INTERNATIONAL
                )
            );
            CasesDAO.newInstance().insertRecords(cases, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            
            List<Case> caseRecordList = [SELECT Id, ContactId FROM Case WHERE SuppliedEmail= '1testmail@mail.test' WITH USER_MODE LIMIT 1];
            System.assert(caseRecordList[0].ContactId !=null, 'case is not link to existing contact.');
        }
    }
    
    @isTest
    private static void testCaseEmailMatchToLeadEmail() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            
            List<Lead> leadList = TestDataFactory.createTestLeadRecords(0,1);
            leadList[0].Email = '1testmail@mail.test';
            LeadsDAO.newInstance().insertRecords(leadList, true, AccessLevel.USER_MODE);
            Test.startTest();
            List<Case> cases = new List<Case>();
            cases.add(
                new Case(  
                    Status = 'Created', 
                    Subject = 'Test Case',
                    SuppliedEmail = '1testmail@mail.test',
                    Description = 'Test Case Description',
                    Origin = 'Email',
                    Case_Type__c = CasesDAO.CASE_TYPE_INTERNATIONAL
                )
            );
            CasesDAO.newInstance().insertRecords(cases, true, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            
            List<Case> caseRecordList = [SELECT Id, ContactId,Lead__c FROM Case WHERE SuppliedEmail= '1testmail@mail.test' WITH USER_MODE LIMIT 1];
            System.assert(caseRecordList[0].Lead__c !=null, 'case is not link to existing lead.');
        }
    }
    
    @isTest
    private static void testCaseEmailNoMatchToExistingContactEmail() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].Email = '1testmail@mail.test';
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);
            Test.startTest();
            List<Case> cases = new List<Case>();
            cases.add(
                new Case(  
                    Status = 'Created', 
                    Subject = 'Test Case',
                    SuppliedEmail = '133testmail@mail.test',
                    Description = 'Test Case Description',
                    Origin = 'Email',
                    Case_Type__c = CasesDAO.CASE_TYPE_INTERNATIONAL
                )
            );
            CasesDAO.newInstance().insertRecords(cases, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            
            List<Case> caseRecordList = [SELECT Id, ContactId FROM Case WHERE SuppliedEmail= '133testmail@mail.test' WITH USER_MODE LIMIT 1];
            System.assert(caseRecordList[0].ContactId == null, 'case contactId is not null.');
        }
    }

    @isTest
    private static void testCaseRecordByContactMobileMatching() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            
            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].MobilePhone = '090909';
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);
            Test.startTest();
            List<Case> cases = new List<Case>();
            cases.add(
                new Case(  
                    Status = 'Created', 
                    SuppliedPhone = '090909',
                    Origin = CasesDAO.ORIGIN_WHATSAPP,
                    Case_Type__c = CasesDAO.CASE_TYPE_INTERNATIONAL
                )
            );
            CasesDAO.newInstance().insertRecords(cases, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            
            List<Case> caseRecordList = CasesDAO.newInstance().getCasesBySuppliedPhone(new Set<String>{cases[0].SuppliedPhone}, AccessLevel.USER_MODE);
            System.assert(caseRecordList[0].ContactId != null, 'case contactId is not null.');
        }
    }

    @isTest
    private static void testCaseRecordByLeadMobileMatching() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            
            List<Lead> leadList = TestDataFactory.createTestLeadRecords(0,1);
            leadList[0].MobilePhone = '090909';
            LeadsDAO.newInstance().insertRecords(leadList, false, AccessLevel.USER_MODE);
            Test.startTest();
            List<Case> cases = new List<Case>();
            cases.add(
                new Case(  
                    Status = 'Created', 
                    SuppliedPhone = '090909',
                    Origin = CasesDAO.ORIGIN_WHATSAPP,
                    Case_Type__c = CasesDAO.CASE_TYPE_INTERNATIONAL
                )
            );
            CasesDAO.newInstance().insertRecords(cases, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            
            List<Case> caseRecordList = CasesDAO.newInstance().getCasesBySuppliedPhone(new Set<String>{cases[0].SuppliedPhone}, AccessLevel.USER_MODE);
            System.assert(caseRecordList[0].Lead__c !=null, 'case is not link to existing lead.');
        }
    }

    @isTest
    private static void testHandleAutoPriorityAssignedCase(){
        
        System.runAs(TestDataFactoryUser.selectUserQUTESB){
            
            List<Case> cases = new List<Case>();
            cases.add(
                new Case(  
                    Status = 'Created', 
                    Auto_Priority_Assignment__c = true,
                    SuppliedPhone = '090909',
                    Origin = CasesDAO.ORIGIN_WHATSAPP,
                    RecordTypeId = CasesDAO.INBOUND_ENQUIRY_RECTYPE_ID,
                    Case_Type__c = CasesDAO.CASE_TYPE_INTERNATIONAL
                )
            );

            Test.startTest();
            CasesDAO.newInstance().insertRecords(cases, false, AccessLevel.SYSTEM_MODE);
            System.assert(cases[0].Id != null, 'case insert was not successful');
            Test.stopTest();
        }

        
    }

    @isTest
    private static void testHandleAutoPriorityAssignedCaseWithSubCateg(){
        
        System.runAs(TestDataFactoryUser.selectUserQUTESB){

            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].Citizenship_Country__c = 'Yemen';
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.USER_MODE);
            
            List<Case> cases = new List<Case>();
            cases.add(
                new Case(
                    Status = 'Created',
                    Auto_Priority_Assignment__c = true,
                    Category__c = 'Student life',
                    Origin = CasesDAO.ORIGIN_WHATSAPP,
                    Priority = 'Low',
                    ContactId = contactList[0].Id,
                    RecordTypeId = CasesDAO.INBOUND_ENQUIRY_RECTYPE_ID,
                    Case_Type__c = CasesDAO.CASE_TYPE_INTERNATIONAL
                )
            );

            Test.startTest();
            CasesDAO.newInstance().insertRecords(cases, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();

            List<Case> caseList = CasesDAO.newInstance().getCasesByIds(new Set<Id>{cases[0].Id}, AccessLevel.SYSTEM_MODE);
            System.assertEquals('High', caseList[0].Priority, 'Case priority should be set to high.');
        }
    }

    @isTest
    private static void testHandleAutoPriorityAssignedCaseWithLeadSourceCategory(){
        
        System.runAs(TestDataFactoryUser.selectUserQUTESB){

            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].Lead_Source_Category__c = 'Partner Sourced';
            ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.USER_MODE);
            
            List<Case> cases = new List<Case>();
            cases.add(
                new Case(
                    Status = 'Created',
                    Auto_Priority_Assignment__c = true,
                    Category__c = 'Student life',
                    Origin = CasesDAO.ORIGIN_WHATSAPP,
                    Priority = 'Low',
                    ContactId = contactList[0].Id,
                    RecordTypeId = CasesDAO.INBOUND_ENQUIRY_RECTYPE_ID,
                    Case_Type__c = CasesDAO.CASE_TYPE_INTERNATIONAL
                )
            );

            Test.startTest();
            CasesDAO.newInstance().insertRecords(cases, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();

            List<Case> caseList = CasesDAO.newInstance().getCasesByIds(new Set<Id>{cases[0].Id}, AccessLevel.SYSTEM_MODE);
            System.assertEquals('High', caseList[0].Priority, 'Case priority should be set to high.');
        }
    }

    @isTest
    private static void testHandleOutreachCasePriority(){
        System.runAs(TestDataFactoryUser.selectUserQUTESB){

            Integer numberOfContactsForHigh = 3;
            Integer numberOfContactsForMedium = 2;
            Integer numberOfContactsForLow = 1;

            List<Contact> contactList = new List<Contact>();

            //setup contact for high prio
            List<Contact> contactsForHighPriority = TestDataFactory.createTestContactRecords(numberOfContactsForHigh);
            for(Contact contact : contactsForHighPriority){
                contact.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                contact.ATSI_Code__c = ContactsDAO.ATSI_CODE_ABORIGINAL_ISLANDER;
            }

            //setup contact for medium prio
            List<Account> academicAccounts = TestDataFactory.createTestAccountRecordsWithRecordType(1, AccountsDAO.ACCT_ACADEMIC_PROGRAM_ID);
            academicAccounts[0].Is_Priority_Program__c = true;
            AccountsDAO.newInstance().insertRecords(academicAccounts, true, AccessLevel.SYSTEM_MODE);

            List<hed__Program_Plan__c> programPlanList = TestDataFactory.createTestProgramPlanRecords(1);
            programPlanList[0].Category_Type__c = 'Graduate Certificate';
            programPlanList[0].hed__Account__c = academicAccounts[0].Id;            
            ProgramPlansDAO.newInstance().insertRecords(programPlanList,true,AccessLevel.SYSTEM_MODE);

            List<Contact> contactsForMediumPriority = TestDataFactory.createTestContactRecords(numberOfContactsForMedium);
            for(Contact contact : contactsForMediumPriority){
                contact.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                contact.AccountId = academicAccounts[0].Id;
            }

            //setup contact for low prio
            List<Contact> contactsForLowPriority = TestDataFactory.createTestContactRecords(numberOfContactsForLow);
            for(Contact contact : contactsForLowPriority){
                contact.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            }

            contactList.addAll(contactsForHighPriority);
            contactList.addAll(contactsForMediumPriority);
            contactList.addAll(contactsForLowPriority);
            ContactsDAO.newInstance().insertRecords(contactList, true, AccessLevel.SYSTEM_MODE);

            List<hed__Program_Enrollment__c> programEnrollmentList = new List<hed__Program_Enrollment__c>();
            for(Contact contact : contactsForMediumPriority){
                hed__Program_Enrollment__c programEnrollment = new hed__Program_Enrollment__c();
                programEnrollment.Academic_Status__c = ProgramEnrollmentsDAO.ACADEMIC_STATUS_SHOW_CAUSE;
                programEnrollment.Enrollment_Stage__c = ProgramEnrollmentsDAO.ENROLLMENT_STAGE_ADMITTED;
                programEnrollment.Enrollment_Status__c = ProgramEnrollmentsDAO.ENROLLMENT_STATUS_ADMITTED;
                programEnrollment.hed__Contact__c = contact.Id;
                programEnrollment.hed__Program_Plan__c = programPlanList[0].Id;
                programEnrollmentList.add(programEnrollment);

            }
            ProgramEnrollmentsDAO.newInstance().insertRecords(programEnrollmentList,true,AccessLevel.SYSTEM_MODE);

            List<Engagement_List_Configuration__c> configs = new List<Engagement_List_Configuration__c>();
            Engagement_List_Configuration__c config = new Engagement_List_Configuration__c();
            config.Name = 'ELConfig Test';
            config.Engagement_List_Configuration_Status__c = 'Active';
            config.Start_Date__c = Date.today().addDays(-1);
            config.End_Date__c = Date.today().addDays(1);
            config.Qualtrics_Instrument_Id__c = 'test';
            config.Qualtrics_Instrument_Name__c = 'test';
            configs.add(config);
            EngagementListConfigurationsDAO.newInstance().insertRecords(configs, true, AccessLevel.SYSTEM_MODE);

            Test.startTest();
            Id studentRetentionId = GroupsDAO.newInstance().getQueueByName(GroupsDAO.STUDENT_RETENTION_QUEUE);
            List<Case> cases = TestDataFactory.createTestOutreachCaseRecords(configs[0], studentRetentionId, contactList);
            CasesDAO.newInstance().insertRecords(cases, true, AccessLevel.SYSTEM_MODE);
            Test.stopTest();

            Integer highPrioCase = 0;
            Integer mediumPrioCase = 0;
            Integer lowPrioCase = 0;

            Set<Id> caseIdSet = (new Map<Id, Case>(cases)).keySet();
            List<Case> caseList = CasesDAO.newInstance().getCasesByIds(caseIdSet, AccessLevel.SYSTEM_MODE);
            for(Case caseRecord : caseList){
                if(caseRecord.Priority == 'High'){
                    highPrioCase ++;
                }else if(caseRecord.Priority == 'Medium'){
                    mediumPrioCase ++;
                }else if (caseRecord.Priority == 'Low'){
                    lowPrioCase ++;
                }
            }

            System.assertEquals(numberOfContactsForHigh, highPrioCase, 'Case priority should be set to high.');
            System.assertEquals(numberOfContactsForMedium, mediumPrioCase, 'Case priority should be set to Medium.');
            System.assertEquals(numberOfContactsForLow, lowPrioCase, 'Case priority should be set to Low.');
        }
    }

    @isTest
    private static void testSetOutreachKeyForClosedCase(){
        
        System.runAs(TestDataFactoryUser.selectUserQUTESB){

            List<Engagement_List_Configuration__c> configs = new List<Engagement_List_Configuration__c>();
            Engagement_List_Configuration__c config = new Engagement_List_Configuration__c();
            config.Name = 'ELConfig Test';
            config.Engagement_List_Configuration_Status__c = 'Active';
            config.Start_Date__c = Date.today().addDays(-1);
            config.End_Date__c = Date.today().addDays(1);
            config.Qualtrics_Instrument_Id__c = 'test';
            config.Qualtrics_Instrument_Name__c = 'test';
            configs.add(config);
            EngagementListConfigurationsDAO.newInstance().insertRecords(configs, true, AccessLevel.SYSTEM_MODE);

            List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
            contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            contactList[0].QUT_Student__c = true;
            ContactsDAO.newInstance().insertRecords(contactList,true,AccessLevel.SYSTEM_MODE);

            Id studentRetentionId = GroupsDAO.newInstance().getQueueByName(GroupsDAO.STUDENT_RETENTION_QUEUE);
            List<Case> caseList = new List<Case>();
            Case outreachCase = TestDataFactory.createTestOutreachCaseRecord(configs[0], studentRetentionId, contactList[0].Id);
            caseList.add(outreachCase);
            CasesDAO.newInstance().insertRecords(caseList, true, AccessLevel.SYSTEM_MODE);

            Test.startTest();
            List<Case> caseListToUpdate = new List<Case>();
            for(Case caseRecord : caseList){
                caseListToUpdate.add(new Case(
                    Id = caseRecord.Id,
                    Closure_Code__c = 'Unsuccessful - Uncontactable',
                    Closure_Details__c = 'This is a test closure details',
                    Status = CasesDAO.STATUS_CLOSED
                ));
            }
            CasesDAO.newInstance().updateRecords(caseListToUpdate, true, AccessLevel.SYSTEM_MODE);
            Test.stopTest();

            String expectedOutreachKey = configs[0].Id + '_' + contactList[0].Id + '_' + caseListToUpdate[0].Id;
            List<Case> updatedCaseList = CasesDAO.newInstance().getCasesByIds(new Set<Id>{caseListToUpdate[0].Id}, AccessLevel.SYSTEM_MODE);
            System.assertEquals(expectedOutreachKey, updatedCaseList[0].Outreach_Key__c, 'Incorrect outreach key.');
        }
    }
}