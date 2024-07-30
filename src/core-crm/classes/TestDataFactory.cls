/**
 * @description Test class that contains reusable method for test data creation
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                | Change Summary                                                          |
 *    |---------------------------|-----------------------|---------------------|-------------------------------------------------------------------------|
 *    | roy.nino.s.regala         | September 3, 2021     | DEP1-169,170        | Created file                                                            |
 *    | angelika.j.s.galang       | September 3, 2021     | DEP1-156            | Added comments & method for creating user and getting profile id        |
 *    | angelika.j.s.galang       | September 16, 2021    | DEP1-22             | Added method for creating Opportunity                                   |
 *    | roy.nino.s.regala         | October 4,2021        | DEPP-40,42          | Added method for Product Request and Product Specification              |
 *    | adrian.c.habasa           | October 18,2021       | DEPP-476,425,383    | Added method for Course, Products,Course Offerings and Terms            |
 *    | roy.nino.s.regala         | November 3, 2021      | DEPP-736            | Added nethod for Opportunity Contact Roles                              |
 *    | adrian.c.habasa           | November 11,2021      | DEPP-664            | Added method for Asset                                                  |
 *    | eccarius.karl.munoz       | November 25,2021      | DEPP-671            | Added method for creation of Products without related Course            |
 *    | eugene.andrew.abuan       | December 1,2021       | DEPP-771            | Added method for creation of Community User                             |
 *    | roy.nino.s.regala         | November 25,2021      | DEPP-362,38,37      | Added method for creation of Program Plan                               |
 *    | john.bo.a.pineda          | December 6, 2021      | DEPP-789            | Added method for creation of Course Connection                          |
 *    | eugene.andrew.abuan       | December 10, 2021     | DEPP-100            | Added method for Buyer Account                                          |
 *    | marygrace.li@qut.edu.au   | December 13, 2021     | DEPP-174            | Added method creation of Acct,Contact,ByrGrp,ByrGrpMber,Product2        |
 *    | roy.nino.s.regala         | December 15, 2021     | DEPP-116            | Added Start date on course offerings                                    |
 *    | john.bo.a.pineda          | December 21, 2021     | DEPP-1150           | Added method for creation of Pending Registration                       |
 *    | john.bo.a.pineda          | January 05, 2022      | DEPP-1382           | Added method for creation of Program Offering                           |
 *    | arsenio.dayrit@qut.edu.au | January 12, 2022      | DEPP-1359           | Added method for creation of Product Ledger                             |
 *    | adrian.c.habasa           | January 21, 2022      | DEPP-1463           | Added method for creation of Credential                                 |
 *    | angelika.j.s.galang       | January 25, 2022      | DEPP-1396           | Added method for creation of Questionnaire, Question, and Answer        |
 *    | roy.nino.s.regala         | February 03, 2022     | DEPP-213            | Added nethod for creation of Expression of Interest                     |
 *    | john.bo.a.pineda          | February 03, 2022     | DEPP-1396           | Updated method for Answer to Related Answer                             |
 *    | arsenio.jr.dayrit         | February 14, 2022     | DEPP-1538           | Added method for creation of Questionnaire response summary             |
 *    | adrian.c.habasa           | February 14, 2022     | DEPP-1247           | Added method for Session and Attendance Event                           |
 *    | eugene.andrew.abuan       | February 16, 2022     | DEPP-1265           | Added method for Creating Courses                                       |
 *    | keno.domienri.dico        | April 11, 2022        | DEPP-1543           | Added method for Creating Communication Schedule                        |
 *    | kathy.cornejo             | June 3, 2022          | DEPP-2664           | Added method for Creating Pricebook2                                    |
 *    | rhea.b.torres             | June 12, 2022         | DEPP-2734           | Implement proper testing persona                                        |
 *    | marlon.vasquez            | July 25, 2022         | DEPP-3538           | Added Required fields for creating Product Specification                |
 *    | william.a.cheng           | September 14, 2022    | DEPP-4266, 1977     | Add methodd to configure TDTM and affiliation mappings                  |
 *    | rhea.b.torres             | November 10, 2022     | DEPP-4448           | Add methodd to create International_Tier__c records                     |
 *    | rhea.b.torres             | February 2, 2023      | NA                  | Add new methods to handle creation of CCE Product Specification         |
 *    | carl.alvin.cabiles        | May 23, 2023          | DEPP-5410           | Add new to create Opportunity Outcome                                   |
 *    | kenneth.f.alsay           | June 16, 2023         | DEPP-5434, 5399     | Added method to create Opportunity, Financial Split and Contextual Role |
 *    | ryan.j.a.dela.cruz        | July 03, 2023         | DEPP-5390           | Added method for creation of Pure_Project__c record                     |
 *    | eugene.andrew.abuan       | July 11, 2023         | DEPP-5483           | Added method for creation of IP Management and Document  record         |
 *    | roy.nino.s.regala         | July 13, 2023         | DEPP-5459           | Added percentage split default value                                    |
 *    | ryan.j.a.dela.cruz        | July 18, 2023         | DEPP-5468           | Added method for creation of IPManagementRelationships records          |
 *    | eugene.andrew.abuan       | August 01, 2023       | DEPP-6141           | Added method for creation of Relationship Manager w/ Account Lookup     |
 *    | marygrace.li@qut.edu.au   | August 7, 2023        | DEPP-6275           | Updated to Pure_Project_ID1__c before deleting the field                |     
 *    | roy.nino.s.regala         | August 09, 2023       | DEPP-5677           | Added method for creation of Task                                       |
 *    | roy.nino.s.regala         | August 09, 2023       | DEPP-5677           | Added method for creation of Competed Cadence                           |
 *    | roy.nino.s.regala         | August 09, 2023       | DEPP-5677           | Added method for creation of ActionCadenceTracker                       |
 *    | eccarius.munoz            | August 08, 2023       | DEPP-5760           | Added method for creation of Program Enrollment records                 |
 *    | eccarius.munoz            | August 10, 2023       | DEPP-5760           | Added method for creation of Nurture Track Config records               |
 *    | marygrace.li@qut.edu.au   | August 7, 2023        | DEPP-6275           | Updated to Pure_Project_ID__c field                                     |
 *    | kenneth.f.alsay           | August 14, 2023       | DEPP-6275-6208      | Removed Pure_Project_ID__c param from createTestOpportunityWithStageRecords
 *    | julie.jane.alegre         | August 21, 2023       | DEPP-6252           | Added createApplicationRecords, createApplicationPreferenceRecords and  |
 *    |                           |                       |                     | createPackageComponentRecords                                           |
 *    | carl.alvin.cabiles        | August 22, 2023       | DEPP-6410           | Added method for creation of Expense                                    |
 *    | roy.nino.s.regala         | August 22, 2023       | DEPP-5704           | Added method for creation of contact,lead,application                   |
 *    | eccarius.munoz            | August 31, 2023       | DEPP-6138           | Added method for creation of Communication Queue                        |
 *    | marygrace.li@qut.edu.au   | September 11, 2023    | DEPP-6473           | Updated permsets name to Office_of_Industry_Engagement_Base             |
 *    | roy.nino.s.regala         | September 13, 2023    |                     | removed role update to sys admin user if has a role already             |
 *    | carl.alvin.cabiles        | September 18, 2023    | DEPP-6510           | Added method for List and List Member creation                          | 
 *    | julie.jane.alegre         | September 19, 2023    | DEPP-6667           | Added method createMarketingInteractionRecords                          |
 *    | kenneth.f.alsay           | September 22, 2023    | DEPP-6629           | Added method createTestCourseConnectionRecordsByStatus                  |
 *    | alexander.cadalin         | September 29, 2023    | DEPP-6769           | Added method createTestSprinklrCaseRecords                              |
 *    | roy.nino.s.regala         | October 4, 2023       | DEPP-6426           | Added creation of case priority configuration                           |
 *    | eugene.andrew.abuan       | October 10, 2023      | DEPP-6612           | Updated Adhoc Communication creation of records                         |
 *    | nicole.genon              | November 23, 2021     | DEPP-7259           | Added method for creation of Work Type and Service Appointment records  |                     
 *    | johanna.a.gibas           | November 24, 2023     | DEPP-7143           | Removed references to Priority on International Tier                    |
 *    | nicole.genon              | December 19, 2023     | DEPP-6949           | Added method for creation of QUT_Alumni_Engagement_Manager,             |
                                                                                  QUT_Corporate_Engagement_Manager users and Engagement Opportunity records
 *    | kenneth.f.alsay           | December 27, 2023     |                     | Removed unused variables                                                |
 *    | gabriel.p.ventayen        | April 29, 2024        | DEPP-8614           | added method createTestEngagementListConfiguration                      |
 *    | gabriel.p.ventayen        | May 3, 2024           | DEPP-7528           | add createTestCourseConnectionAssessmentRecord                          |
 *    | gabriel.p.ventayen        | May 3, 2024           | DEPP-7528           | add createLeaveOfAbsenceRecord                                          |
 *    | gabriel.p.ventayen        | May 3, 2024           | DEPP-7528           | add createTestProgramEnrollmentBreachRecords                            |
 *    | eugene.andrew.abuan       | May 07, 2024          | DEPP-8487           | Added Student Success Outreach Manager & Assesment Records              |
 *    | arsenio.jr.dayrit         | May 09, 2024          | DEPP-8487           | added createTestBreachRecords                                           |
 *    | eugene.andrew.abuan       | May 24, 2024          | DEPP-8822           | Added method for Qualtrics Survey record creation                       |
 *    | kenneth.f.alsay           | February 29, 2024     | DEPP-7883           | Added method createPlanActivityRecords                                  |
 *    | nicole.genon              | March 6, 2024         | DEPP-7922           | Added QUT_Donor_Engagement_Manager user                                 |
 *    | kenneth.f.alsay           | April 8, 2024         | DEPP-8399           | Added method createDistributionManagementRecords                        |
 *    | eugene.andrew.abuan       | April 10, 2023        | DEPP-8390           | Added Create Designation with Recordtype                                |
 *    | nicole.genon              | April 11, 2024        | DEPP-8452           | Added method createDistributionManagementRecordsWithDesignation         |
 *    | neil.s.h.lesidan          | April 11, 2024        | DEPP-8392           | Added method createTestFinanceGLAccountRecords                          |
 *    |                           |                       |                     | Added method createTestDistributionSplitRecords                         |
 *    | nicole.genon              | April 23, 2024        | DEPP-8498           | Added method createDonationAssetRecords                                 |
 *    | kenneth.f.alsay           | April 23, 2024        | DEPP-8528           | Added method createDonationRecordsWithRecordType                        |
 **/
    
@isTest
public class TestDataFactory {
    private static final String STR_QUALIFY = 'Qualify';
    private static final String STR_IN_PROGRESS = 'In Progress';
    private static final String STR_QUESTIONNAIRE_TYPE = 'Registration Criteria';
    private static final String TEST_BUYER_GROUP = 'Test Buyer Group';
    private static final String TEST_BUYER_ACCT = 'Test Buyer Account';
    private static final String TEST_ACCOUNT_NAME = 'Test Account';
    private static final String TEST_PRICEBOOK2_NAME = 'Test Pricebook2';
    private static final TestUserGenerator TEST_USER_GENERATOR = new TestUserGenerator();
    private static final List<String> USER_ATTRIB_LIST = new List<String>{
        'QUT_System_Administrator',
        'QUT_Developer',
        'QUT_Read_Only',
        'QUT_Sys_Admin',
        'QUT_Form_Builder',
        'QUT_Website_Integration_User',
        'QUT_Marketing_Cloud',
        'QUT_ESB',
        'QUT_Data_Migration',
        'QUT_Chatter_Free',
        'QUT_Executive_Director',
        'QUT_Business_Manager',
        'QUT_OPE_Director',
        'QUT_Portfolio_Coordinator',
        'QUT_Product_Admin',
        'QUT_Learning_Innovation_Manager',
        'QUT_Learning_Designer',
        'QUT_Partnership_Manager',
        'QUT_Program_Coordinator',
        'QUT_Program_Administrator',
        'QUT_Marketing_Manager',
        'QUT_Quality_Assurance',
        'QUT_Digital_Marketing_Officer',
        'QUT_Digital_Communication_Officer',
        'QUT_IE_Partnership_Manager',
        'QUT_Operations_Manager',
        'QUT_Domestic_Future_Student_Agent',
        'QUT_Corporate_Partnership_Manager',
        'Alumni_Engagement_Manager',
        'QUT_Alumni_Engagement_Manager',
        'QUT_Corporate_Engagement_Manager',
        'QUT_International_Future_Student_Agent',
        'QUT_Advancement_Manager',
        'QUT_Donor_Engagement_Manager',
        'QUT_Student_Success_Outreach_Manager'
    };
    private static final List<String> PORTAL_USERS_SET = new List<String>{
        'QUT_Corporate_Partner_Admin',
        'QUT_Corporate_Partner_User',
        'QUT_OPE_Catalogue'
    };
    private static User portalSysAdmin;

    /**
     * @description Method for creating test Account records
     * @param numAccts - number of Accounts to be created
     * @return accts - list of Accounts created
     */
    public static List<Account> createTestAccountRecords(Integer numAccts) {
        List<Account> accts = new List<Account>();

        for (Integer i = 0; i < numAccts; i++) {
            accts.add(new Account(Name = 'TestAccount' + i));
        }

        return accts;
    }

    /**
     * @description Method for creating test Account records with ABN
     * @param numAccts - number of Accounts to be created
     * @return accts - list of Accounts created
     */
    public static List<Account> createTestAccountWithABNRecords(Integer numAccts) {
        List<Account> accts = new List<Account>();

        for (Integer i = 0; i < numAccts; i++) {
            accts.add(new Account(Name = 'TestAccount' + i, ABN__c = 'ABN' + i));
        }

        return accts;
    }

    /**
     * @description Method for creating test Account records
     * @param numAccts - number of Accounts to be created
     * @param recordTypeId - account record type id
     * @return accts - list of Accounts created
     */
    public static List<Account> createTestAccountRecordsWithRecordType(
        Integer numAccts,
        String recordTypeId
    ) {
        List<Account> accts = new List<Account>();

        for (Integer i = 0; i < numAccts; i++) {
            accts.add(new Account(Name = 'TestAccount' + i, RecordTypeId = recordTypeId));
        }

        return accts;
    }

    /**
     * @description Method for creating test Contact records
     * @param numContacts - number of Contacts to be created
     * @return cons - list of Contacts created
     */
    public static List<Contact> createTestContactRecords(Integer numContacts) {
        List<Contact> cons = new List<Contact>();

        for (Integer i = 0; i < numContacts; i++) {
            cons.add(new Contact(FirstName = 'Test' + i, LastName = 'Contact' + i));
        }

        return cons;
    }

     /**
     * @description Method for creating test Contact records
     * @param numContacts - number of Contacts to be created
     * @param citizenship - citizenship of contact
     * @return contactList - list of Contacts created
     */
    public static List<Contact> createTestContactRecords(Integer numContacts, String citizenship) {
        List<Contact> contactList = new List<Contact>();

        for (Integer i = 0; i < numContacts; i++) {
            contactList.add(new Contact(
                FirstName = 'Test' + i,
                LastName = 'Contact' + i,
                hed__Citizenship_Status__c = citizenship,
                RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID
            ));
        }

        return contactList;
    }

    /**
     * @description Method for creating test Contact records
     * @param startAtCount - starting count of contact creation
     * @param endBeforeCount - end count of contact creation
     * @return cons - list of Contacts created
     */
    public static List<Contact> createTestContactRecords(
        Integer startAtCount,
        Integer endBeforeCount
    ) {
        List<Contact> newContacts = new List<Contact>();
        for (Integer i = startAtCount; i < endBeforeCount; i++) {
            newContacts.add(
                new Contact(
                    FirstName = 'TestFirstName' + i,
                    LastName = i + 'TestLastName',
                    Email = i + 'testmail@mail.test',
                    Birthdate = System.Today().addYears(-17).addDays(i),
                    QUT_Learner_Email__c = 'learner' + i + 'testmail@mail.test',
                    QUT_Staff_Email__c = 'staff' + i + 'testmail@mail.test',
                    Work_Email__c = 'work' + i + 'testmail@mail.test',
                    hed__Preferred_Email__c = 'Alternate Email',
                    hed__AlternateEmail__c = i + 'testmail@mail.test',
                    Mobilephone = '1234567890' + i,
                    RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID 
                )
            );
        }
        return newContacts;
    }

     /**
     * @description Method for creating test Application records
     * @param conList - contact records
     * @param recordTypeId - recordTypeId
     * @return newApplications - list of Application records created
     */
    public static List<hed__Application__c> createTestApplicationRecordsWithContact(List<Contact> conList, Id recordTypeId) {
        List<hed__Application__c> newApplications = new List<hed__Application__c>();
        for (Contact con: conList) {
            newApplications.add(
                new hed__Application__c(
                    FirstName__c = 'Test First' + 'TestFirstName',
                    LastName__c = 'Test Last' + 'TestLastName',
                    Email__c = 'workTest' + 'testmail@mail.test',
                    hed__Applicant__c = con.Id,
                    RecordTypeId = recordTypeId,
                    Calculated_Intake_Date__c = System.Today()
                )
            );
        }
        return newApplications;
    }  

    /**
     * @description Method for creating test Lead records
     * @param numLeads - number of Leads to be created
     * @return leads - list of Leads created
     */
    public static List<Lead> createTestLeadRecords(Integer numLeads) {
        List<Lead> leads = new List<Lead>();

        for (Integer i = 0; i < numLeads; i++) {
            leads.add(
                new Lead(
                    FirstName = 'TestFirstNameLead' + i,
                    LastName = 'TestLastNameLead' + i,
                    Company = 'TestCompany' + i,
                    Phone = '1234567' + i,
                    City = 'TestCity' + i,
                    MobilePhone = '1234567' + i
                )
            );
        }

        return leads;
    }

    /**
     * @description Method for creating test Lead records with starting count and end count
     * @param startAtCount - start count of the lead loop
     * @param endBeforeCount  - end count of the lead loop
     * @return leads - list of Leads created
     */
    public static List<Lead> createTestLeadRecords(Integer startAtCount, Integer endBeforeCount) {
        List<Lead> newLeads = new List<Lead>();
        for (Integer i = startAtCount; i < endBeforeCount; i++) {
            newLeads.add(
                new Lead(
                    LastName = 'Testlastname' + i,
                    Email = i + 'testmail@mail.test',
                    Work_Email__c = 'work' + i + 'testmail@mail.test',
                    Company = 'Testcompany' + i,
                    Lead_Type__c = LeadsDAO.LEARNER_LEAD_TYPE
                )
            );
        }
        return newLeads;
    }

    public static List<Lead> createLeadRecordsByLeadType(
        Integer numberOfRecords,
        String leadType,
        Boolean isConverted
    ) {
        final String EMAIL = 'testmail@mail.test';
        List<Lead> newLeads = new List<Lead>();

        for (Integer i = 0; i < numberOfRecords; i++) {
            newLeads.add(
                new Lead(
                    FirstName = 'TestFirstNameLead' + i,
                    LastName = 'TestLastNameLead' + i,
                    Email = i + EMAIL,
                    Work_Email__c = 'work' + i + EMAIL,
                    Company = 'Testcompany' + i,
                    Lead_Type__c = leadType,
                    IsConverted = isConverted
                )
            );
        }
        return newLeads;
    }

    /**
     * @description Method for creating Leave Of Absences Record
     * @param nLeaveOfAbsence - number of Course Connection to be created
     * @return leaveOfAbsenceRecord - List of Course Connection Created
     */
    public static List<Leave_of_Absence__c> createLeaveOfAbsenceRecord(
        Integer nLeaveOfAbsence
    ) {
        List<Leave_of_Absence__c> leaveOfAbsenceRecord = new List<Leave_of_Absence__c>();
        for (Integer i = 0; i < nLeaveOfAbsence; i++) {
            leaveOfAbsenceRecord.add(
                new Leave_of_Absence__c()
            );
        }
        return leaveOfAbsenceRecord;
    }

    /**
     * @description Method for creating test action records
     * @param numActions - number of actions to be created
     * @return actions - list of Leads created
     */
    public static List<Action__c> createTestActionRecords(
        Integer numActions,
        Id recordTypeId,
        Id consultancyId
    ) {
        List<Action__c> actions = new List<Action__c>();

        for (Integer i = 0; i < numActions; i++) {
            actions.add(
                new Action__c(
                    Activity_Name__c = 'Test Activity Name ' + i + recordTypeId,
                    Activity_Type__c = 'Meeting',
                    Consultancy__c = consultancyId,
                    RecordTypeId = recordTypeId,
                    Summary__c = 'TestCityTestCityTestCityTestCityTestCityTestCityTestCityTestCity' +
                        i
                )
            );
        }
        return actions;
    }

    /**
     * @description Method for creating test consultancy records
     * @param numConsultancies - number of consultancy to be created
     * @return consultancies - list of consultancy created
     */
    public static List<Consultancy__c> createTestConsultancyRecords(
        Integer numConsultancies,
        Id productRequestId
    ) {
        List<Consultancy__c> consultancies = new List<Consultancy__c>();

        for (Integer i = 0; i < numConsultancies; i++) {
            consultancies.add(
                new Consultancy__c(
                    Name = 'Test Consultancy Name ' + i,
                    Product_Request__c = productRequestId,
                    Investigation_Summary__c = 'Preparing investigation summary',
                    Definition_of_Problem__c = 'Preparing problem definition'
                )
            );
        }
        return consultancies;
    }

    /**
     * @description Method for creating test consultancy records
     * @param numConsultancies - number of consultancy to be created
     * @return consultancies - list of consultancy created
     */
    public static List<ContentVersion> createTestContentVersionPDFRecords(
        Integer numContentVersionRecords
    ) {
        List<ContentVersion> contentVersions = new List<ContentVersion>();

        for (Integer i = 0; i < numContentVersionRecords; i++) {
            contentVersions.add(
                new ContentVersion(
                    Title = 'Test Document ' + i,
                    PathOnClient = 'test' + i,
                    VersionData = Blob.valueOf('Test Document Content' + i)
                )
            );
        }
        return contentVersions;
    }

    /**
     * @description Method for creating test case records
     * @param numCases - number of case to be created
     * @param relatedLeads - related lead to case
     * @param relatedContacts - related contact to case
     * @return case - list of case created
     */
    public static List<Case> createTestCaseRecords(
        Integer numCases,
        List<Lead> relatedLeads,
        List<Contact> relatedContacts
    ) {
        List<Case> cases = new List<Case>();

        for (Integer i = 0; i < numCases; i++) {
            cases.add(
                new case(
                    Lead__c = relatedLeads != null && !relatedLeads.isEmpty()
                        ? relatedLeads[i].Id
                        : null,
                    ContactId = relatedContacts != null && !relatedContacts.isEmpty()
                        ? relatedContacts[i].Id
                        : null
                )
            );
        }

        return cases;
    }

    /**
     * @description Method for creating test Individual records
     * @param numIndividuals - number of Individuals to be created
     * @return individuals - list of Individuals created
     */
    public static List<Individual> createTestIndividualRecords(Integer numIndividuals) {
        List<Individual> individuals = new List<Individual>();

        for (Integer i = 0; i < numIndividuals; i++) {
            individuals.add(new Individual(LastName = 'TestLastName' + i));
        }

        return individuals;
    }

    /**
     * @description Method for creating test Opportunity records
     * @param numOpps - number of Opportunities to be created
     * @param accId - Id of related Account
     * @param conId - Id of related Contact for roles
     * @return opps - list of Opportunities created
     */
    public static List<Opportunity> createTestOpportunityRecords(
        Integer numOpps,
        Id accId,
        Id conId
    ) {
        List<Opportunity> opps = new List<Opportunity>();

        for (Integer i = 0; i < numOpps; i++) {
            opps.add(
                new Opportunity(
                    Name = 'TestOpportunity' + i,
                    AccountId = accId,
                    Contact__c = conId,
                    StageName = STR_QUALIFY,
                    Status__c = STR_IN_PROGRESS,
                    CloseDate = System.today() + 30
                )
            );
        }

        return opps;
    }

    /**
     * Generate a list of opportunity records based on the amount of records needed,
     * the general name to be used, and the record type.
     */
    public static List<Opportunity> createTestOpportunityRecords(
        Integer size,
        String name,
        Id recordTypeId
    ) {
        List<Opportunity> oppties = new List<Opportunity>();
        for (Integer i = 1; i <= size; i++) {
            oppties.add(
                new Opportunity(
                    Name = name + ' ' + String.valueOf(i),
                    StageName = 'Qualify',
                    CloseDate = System.today() + 50,
                    RecordTypeId = recordTypeId
                )
            );
        }
        return oppties;
    }

    /**
     * Generate a list of Pure Project records based on the amount of records needed,
     * the general name to be used and contract status.
     */
    public static List<Pure_Project__c> createTestPureProjectRecords(
        Integer size,
        String name,
        String status
    ) {
        List<Pure_Project__c> pureProjectList = new List<Pure_Project__c>();
        for (Integer i = 1; i <= size; i++) {
            pureProjectList.add(
                new Pure_Project__c(
                    Pure_Project_Name__c = name + ' ' + String.valueOf(i),
                    Pure_CLMS_Contract_Id__c = name + ' ' + String.valueOf(i),
                    Pure_CLMS_Contract_Status__c = status
                )
            );
        }
        return pureProjectList;
    }

    /**
     * Generate a list of opportunity records based on the amount of records needed,
     * the general name to be used, the stage name and the record type.
     */
    public static List<Opportunity> createTestOpportunityWithStageRecords(
        Integer size,
        String name,
        Id recordTypeId,
        String stage,
        Id account,
        String description
    ) {
        List<Opportunity> oppties = new List<Opportunity>();
        for (Integer i = 1; i <= size; i++) {
            oppties.add(
                new Opportunity(
                    Name = name + ' ' + String.valueOf(i),
                    StageName = stage,
                    CloseDate = System.today() + 50,
                    RecordTypeId = recordTypeId,
                    AccountId = account,
                    Description = description
                )
            );
        }
        return oppties;
    }

    /**
     * Generate a list of opportunity outcome records based on the amount of records needed,
     * the general name to be used, and record type
     */
    public static List<Opportunity_Outcome__c> createTestOpportunityOutcomeRecords(
        Integer size,
        String name,
        Id recordTypeId
    ) {
        List<Opportunity> oppty = new List<Opportunity>();
        oppty.add(
            new Opportunity(
                Name = 'Sample Opportunity ' + System.now(),
                StageName = 'Qualify',
                CloseDate = System.today() + 50
            )
        );

        OpportunitiesDAO.newInstance().insertRecords(oppty, false, AccessLevel.USER_MODE);
        List<Opportunity_Outcome__c> oppOutcomes = new List<Opportunity_Outcome__c>();
        for (Integer i = 1; i <= size; i++) {
            oppOutcomes.add(
                new Opportunity_Outcome__c(
                    Company_Name__c = 'Sample Company',
                    Opportunity__c = oppty[0].Id,
                    Project_Name__c = oppty[0].Name,
                    RecordTypeId = recordTypeId
                )
            );
        }
        return oppOutcomes;
    }

    /**
     * Generate a list of engagement records based on the amount of records needed, summary, and record type
     */
    public static List<Engagement__c> createTestEngagementRecords(
        Integer size,
        String summary,
        Id recordTypeId
    ) {
        List<Engagement__c> engs = new List<Engagement__c>();
        for (Integer i = 1; i <= size; i++) {
            engs.add(
                new Engagement__c(Engagement_Summary__c = summary + i, RecordTypeId = recordTypeId)
            );
        }
        return engs;
    }

    /**
     * @description Method for creating "Closed Won" Opportunity records
     * @param numOpps - number of Opportunities to be created
     * @param accId - Id of related Account
     * @param conId - Id of related Contact for roles
     * @return opps - list of Opportunities created
     */
    public static List<Opportunity> createClosedWonOpportunities(
        Integer numOpps,
        Id accId,
        Id conId
    ) {
        List<Opportunity> opps = new List<Opportunity>();

        for (Integer i = 0; i < numOpps; i++) {
            opps.add(
                new Opportunity(
                    Name = 'TestOpportunity' + i,
                    AccountId = accId,
                    Contact__c = conId,
                    StageName = 'Closed Won',
                    Status__c = 'Contract Signed',
                    CloseDate = System.today() + 30
                )
            );
        }

        return opps;
    }

    /**
     * @description Method for retrieving CCE Product Specification records
     * A pre-requisite to this is to call createClosedWonOpportunities method
     * @param void
     * @return prodSpecList - returns all available CCE Product Specification records
     */
    public static List<Product_Specification__c> retrieveCCEProductSpecifications() {
        List<Product_Specification__c> prodSpecList = [
            SELECT Id, RecordTypeId, Program_Name__c, Product_Specification_Name__c
            FROM Product_Specification__c
            WHERE RecordType.DeveloperName = 'CCE'
        ];
        return prodSpecList;
    }

    /**
     * @description Method for creating test Hed Address records
     * @param numAddresses - number of Hed Addresses to be created
     * @param addressType - type of address
     * @param parentId - id of parent address
     * @param lookupApiName - api name of object lookup
     * @return addresses - list of Hed Addresses created
     */
    public static List<hed__Address__c> createTestHedAddressRecords(
        Integer numAddresses,
        String addressType,
        String parentId,
        String lookupApiName
    ) {
        List<hed__Address__c> addresses = new List<hed__Address__c>();

        for (Integer i = 0; i < numAddresses; i++) {
            hed__Address__c add = new hed__Address__c();
            add.put(lookupApiName, parentId);
            add.put('hed__Address_Type__c', addressType);
            addresses.add(add);
        }

        return addresses;
    }

    /**
     * @description Method for creating test Product Request records
     * @param numProductRequest number of product request
     * @param prodSpecId list of product specification
     * @return prodRequest - list of product requests
     */
    public static List<Product_Request__c> createTestProductRequestRecords(
        Integer numProductRequest,
        Id prodSpecId
    ) {
        List<Product_Request__c> prodRequest = new List<Product_Request__c>();

        for (Integer i = 0; i < numProductRequest; i++) {
            Product_Request__c pr = new Product_Request__c();
            pr.Product_Request_Name__c = 'TEST PR ' + i;
            pr.Product_Specification__c = prodSpecId;
            prodRequest.add(pr);
        }

        return prodRequest;
    }

    /**
     * @description Method for creating test Product Specification records
     * @param numProductSpecs number of product specification
     * @param contacts list of related contacts
     * @param ops list of related opportunities
     * @return productSpecifications - list of product specifications
     */
    public static List<Product_Specification__c> createTestProductSpecsRecords(
        Integer numProductSpecs,
        List<Contact> contacts,
        List<Opportunity> ops
    ) {
        List<Product_Specification__c> productSpecifications = new List<Product_Specification__c>();

        for (Integer i = 0; i < numProductSpecs; i++) {
            Product_Specification__c ps = new Product_Specification__c();
            ps.Program_Name__c = 'TEST PS ' + i;
            ps.Program_Lead__c = contacts[i].id;
            ps.Opportunity_Name__c = ops[i].id;
            ps.Status__c = 'Design';
            ps.Stage__c = 'Define';
            ps.Client_Review_Required__c = 'N/A';
            ps.Requestor_Name__c = contacts[i].id;
            ps.Requires_Director_Endorsement__c = 'Yes';
            ps.Endorsed_by__c = contacts[i].id;
            ps.Existing_Product__c = 'Yes';
            ps.Financial_Viability__c = 'Yes';
            ps.Market_Need__c = 'Yes';
            ps.QUTeX_Capacity__c = 'Yes';
            ps.QUT_Faculty_Capacity__c = 'Yes';
            ps.Supporting_Comments__c = 'Test';
            ps.Not_Proceeding_Comments__c = 'Test';
            ps.Product_Type__c = 'Short Course';
            productSpecifications.add(ps);
        }

        return productSpecifications;
    }

    /**
     * @description Create a product specification record without an opportunity attached to it yet
     * @param numProductSpecs number of product specification
     * @param contacts list of related contacts
     * @return productSpecifications - list of product specifications
     */
    public static List<Product_Specification__c> createTestProductSpecsRecords(
        Integer numProductSpecs,
        Id contact
    ) {
        List<Product_Specification__c> productSpecifications = new List<Product_Specification__c>();

        for (Integer i = 0; i < numProductSpecs; i++) {
            Product_Specification__c ps = new Product_Specification__c();
            ps.Program_Name__c = 'TEST PS ' + i;
            ps.Program_Lead__c = contact;
            ps.Status__c = 'Design';
            ps.Stage__c = 'Design';
            ps.Client_Review_Required__c = 'N/A';
            ps.Requestor_Name__c = contact;
            ps.Requires_Director_Endorsement__c = 'Yes';
            ps.Endorsed_by__c = contact;
            ps.Existing_Product__c = 'Yes';
            ps.Financial_Viability__c = 'Yes';
            ps.Market_Need__c = 'Yes';
            ps.QUTeX_Capacity__c = 'Yes';
            ps.QUT_Faculty_Capacity__c = 'Yes';
            ps.Supporting_Comments__c = 'Test';
            ps.Not_Proceeding_Comments__c = 'Test';
            ps.Product_Type__c = 'Short Course';
            productSpecifications.add(ps);
        }

        return productSpecifications;
    }

    /**
     * @description Method for creating test Course records
     * @param numCourses - number of Courses to be created
     * @param accId - id of related account
     * @param prodReqId - id of related product request
     * @return courses - list of Courses created
     */
    public static List<hed__Course__c> createTestCourseRecords(
        Integer numCourses,
        Id accId,
        Id prodReqId
    ) {
        List<hed__Course__c> courses = new List<hed__Course__c>();

        for (Integer i = 0; i < numCourses; i++) {
            courses.add(
                new hed__Course__c(
                    Name = 'Test Course ' + i,
                    hed__Account__c = accId,
                    ProductRequestID__c = prodReqId,
                    Delivery_Type__c = 'Face to Face',
                    Location_Details__c = 'test',
                    Description__c = 'test',
                    Certificate_Type__c = 'Certificate of Achievement',
                    Collaboration_with_External_Organisation__c = 'Yes',
                    External_Organisation__c = 'test',
                    Content__c = 'test',
                    Resource_Details__c = 'test',
                    Minimum_Participants__c = 1,
                    Maximum_Participants__c = 100,
                    Delivery_Support_v2__c = 'Others',
                    Delivery_Comments__c = 'test',
                    Core_Conceptsv2__c = 'test',
                    Overviewv2__c = 'test',
                    Owning_Faculty__c = accId
                )
            );
        }

        return courses;
    }

    public static hed__Course__c createTestCourseRecords(Map<String, String> courseFields) {
        hed__Course__c course = new hed__Course__c(
            Name = courseFields.get('Name'),
            ProductRequestID__c = courseFields.get('ProductRequestID__c'),
            hed__Account__c = courseFields.get('hed__Account__c'),
            Delivery_Type__c = 'Face to Face',
            Location_Details__c = 'test',
            Description__c = 'test',
            Certificate_Type__c = 'Certificate of Achievement',
            Collaboration_with_External_Organisation__c = 'Yes',
            External_Organisation__c = 'test',
            Content__c = 'test',
            Resource_Details__c = 'test',
            Minimum_Participants__c = 1,
            Maximum_Participants__c = 100,
            Delivery_Support_v2__c = 'Others',
            Delivery_Comments__c = 'test',
            Core_Conceptsv2__c = 'test',
            Overviewv2__c = 'test',
            Owning_Faculty__c = courseFields.get('Owning_Faculty__c')
        );
        return course;
    }

    /**
     * @description Method for creating test User records
     * @param numUsers - number of Users to be created
     * @param profileName - profile name of Users to be created
     * @return users - list of Users created
     */
    public static List<User> createUserRecords(Integer numUsers, String profileName) {
        List<User> users = new List<User>();
        Id userProfileId = getProfileId(profileName);
        for (Integer i = 0; i < numUsers; i++) {
            users.add(
                new User(
                    Alias = 'tuser',
                    Email = 'testuser@mailinator.com',
                    EmailEncodingKey = 'UTF-8',
                    LastName = 'TestUser',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_AU',
                    ProfileId = userProfileId,
                    TimeZoneSidKey = 'Australia/Sydney',
                    UserName = 'TestUser.' + i + '@mailinator.com'
                )
            );
        }

        return users;
    }

    /**
     * @description Method for creating test User records
     * @param numUsers - number of Users to be created
     * @param profileName - profile name of Users to be created
     * @return users - list of Users created
     */
    public static List<User> createPortalUserRecords(
        Integer numUsers,
        String profileName,
        Id contactId
    ) {
        List<User> users = new List<User>();
        Id userProfileId = getProfileId(profileName);
        for (Integer i = 0; i < numUsers; i++) {
            users.add(
                new User(
                    Alias = 'puser',
                    Email = 'testPortaluser@mailinator.com',
                    EmailEncodingKey = 'UTF-8',
                    LastName = 'TestPortalUser',
                    ContactId = contactId,
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_AU',
                    ProfileId = userProfileId,
                    TimeZoneSidKey = 'Australia/Sydney',
                    UserName = 'TestPortalUser.' + i + '@mailinator.com'
                )
            );
        }

        return users;
    }

    /**
     * @description Method for getting the Profile ID
     * @param profileName - name of the profile
     * @return ID of the profile
     */
    private static Id getProfileId(String profileName) {
        return [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1]?.Id;
    }

    /**
     * @description Method for getting the Account ID
     * @return ID of the Account
     */
    public static string getAccountId() {
        Account account = new Account();
        account.Name = 'TestAccount1';

        insert (account);

        return account.Id;
    }

    /**
     * @description Method for creating Product Record
     * @param numProd - number of products to be created
     * @param cour - courses to be related to product
     * @return productRecord - List of Products Created
     */
    public static List<Product2> createTestProductRecords(
        Integer numProd,
        List<hed__Course__c> cour
    ) {
        List<Product2> productRecord = new List<Product2>();
        for (Integer i = 0; i < numProd; i++) {
            productRecord.add(new Product2(Name = 'Test Product' + i, Course__c = cour[i].id));
        }
        return productRecord;
    }

    /**
     * @description Method for creating Product Record without related course
     * @param numProd - number of products to be created
     * @return productRecord - List of Products Created
     */
    public static List<Product2> createTestProductRecords(Integer numProd) {
        List<Product2> productRecord = new List<Product2>();
        for (Integer i = 0; i < numProd; i++) {
            productRecord.add(new Product2(Name = 'Test Product' + i));
        }
        return productRecord;
    }

    /**
     * @description Method for creating Course Offering Record
     * @param nCourseOffering - number of Course Offerings to be created
     * @param cour - courses to be related to Course Offering
     * @param terms - terms to be related to Course Offering
     * @return courseOfferingRecord - List of Course Offering Created
     */
    public static List<hed__Course_Offering__c> createTestCourseOfferingRecord(
        Integer nCourseOffering,
        List<hed__Course__c> cour,
        List<hed__Term__c> terms
    ) {
        List<hed__Course_Offering__c> courseOfferingRecord = new List<hed__Course_Offering__c>();
        for (Integer i = 0; i < nCourseOffering; i++) {
            courseOfferingRecord.add(
                new hed__Course_Offering__c(
                    Name = 'CourseOffering ' + i,
                    hed__Course__c = cour[i].id,
                    hed__Term__c = terms[i].id,
                    hed__Start_Date__c = system.today() + 2,
                    hed__Capacity__c = 10,
                    IsActive__c = TRUE,
                    LMS_Creation_Date__c = System.today() + 30
                )
            );
        }
        return courseOfferingRecord;
    }

    /**
     * @description Method for creating Product Request Record without Program Spec Relation
     * @param numProdcutRequest - number of Product Request to be created
     * @return prodRequest - List of Product Request Created
     */
    public static List<Product_Request__c> createTestProductRequestRecords(
        Integer numProdcutRequest
    ) {
        List<Product_Request__c> prodRequest = new List<Product_Request__c>();
        for (Integer i = 0; i < numProdcutRequest; i++) {
            prodRequest.add(
                new Product_Request__c(
                    Product_Request_Status__c = 'Define',
                    Product_Request_Name__c = 'Test ' + i
                )
            );
        }
        return prodRequest;
    }

    /**
     * @description Method for creating Product Request Record without Program Spec Relation
     * @param numProdcutRequest - number of Product Request to be created
     * @param recordtype of product request to be created
     * @return prodRequest - List of Product Request Created
     */
    public static List<Product_Request__c> createTestProductRequestRecordsByRecordType(
        Integer numProductRequest,
        Id recordTypeId
    ) {
        List<Product_Request__c> prodRequest = new List<Product_Request__c>();
        for (Integer i = 0; i < numProductRequest; i++) {
            prodRequest.add(
                new Product_Request__c(
                    Product_Request_Status__c = 'Define',
                    Product_Request_Name__c = 'Test ' + i + recordTypeId,
                    RecordTypeId = recordTypeId
                )
            );
        }
        return prodRequest;
    }

    /**
     * @description Method for creating Term Record
     * @param nTerm - number of Term to be created
     * @param accountId - List of accounts to be related to terms
     * @return term - List of Product Request Created
     */
    public static List<hed__Term__c> createTestTermRecords(Integer nTerm, Id accountId) {
        List<hed__Term__c> term = new List<hed__Term__c>();
        for (Integer i = 0; i < nTerm; i++) {
            term.add(new hed__Term__c(Name = 'Test Term ' + i, hed__Account__c = accountId));
        }
        return term;
    }

    /**
     * @description Method for creating Asset Record
     * @param nAsset - number of Term to be created
     * @param accountId - List of accounts to be related to terms
     * @param productRequestId - List of product request to be related to terms
     * @return asset - List of Asset Records Created
     */
    public static List<Asset> createTestAssetRecords(
        Integer nAsset,
        Id accountId,
        Id productRequestId
    ) {
        List<Asset> asset = new List<Asset>();
        for (Integer i = 0; i < nAsset; i++) {
            asset.add(
                new Asset(
                    Name = 'Test Asset' + i,
                    AccountId = accountId,
                    Product_Request__c = productRequestId
                )
            );
        }
        return asset;
    }


    /**
     * @description Method for creating Task Record
     * @param nTask - number of Task to be created
     * @param paramsMap - parameter map that contains fields and values for the task
     * @return Task - List of Task Records Created
     */
    public static List<Task> createTaskRecords(
        Integer nTask,
        Map<String,String> paramsMap
    ) {
        List<Task> tasks = new List<Task>();
        for (Integer i = 0; i < nTask; i++) {
            tasks.add(
                new Task(
                    Subject = paramsMap.get('Subject') + i,
                    OwnerId = paramsMap.get('OwnerId'),
                    Status = paramsMap.get('Status'),
                    WhoId = paramsMap.get('WhoId'),
                    Description = paramsMap.get('Description') + i
                )
            );
        }
        return tasks;
    }

    /**
     * @description Method for creating ActionCadenceTracker Record
     * @param state - state of the action tracker cadence e.g running
     * @param targetIds - target id of the actioncadence
     * @return acTracker - List of ActionCadenceTracker Records Created
     */
    public static List<ActionCadenceTracker> createActionCadenceTrackers(
        String state,
        Set<Id> targetIds
    ) {
        List<ActionCadenceTracker> acTracker = new List<ActionCadenceTracker>();
        for (Id  targetId:targetIds) {
            acTracker.add(
                new ActionCadenceTracker(
                    State = state,
                    TargetId = targetId
                )
            );
        }
        return acTracker;
    }

    /**
     * @description Method for creating Completed_Cadence__c Record
     * @param status - satatus of the completed cadence
     * @param nurtureTrackId - state of the action tracker cadence e.g running
     * @param targetIds - target id of the Completed_Cadence__c
     * @return completedCadences - List of Completed_Cadence__c Records Created
     */
    public static List<Completed_Cadence__c> createCompletedCadence(
        String status,
        Id nurtureTrackId,
        Set<Id> targetIds
    ) {
        List<Completed_Cadence__c> completedCadences = new List<Completed_Cadence__c>();
        for (Id  targetId:targetIds) {
            String targetIdString = (String)targetId;

            // CreatedDate field is a readonly field and cannot be set directly, a workaround is to create the sObject by deserializing from JSON
            String completedCadenceJSON = '{"CreatedDate":"2023-11-23T20:34:56.000z"}';
            Completed_Cadence__c c = (Completed_Cadence__c) JSON.deserialize(completedCadenceJSON, Completed_Cadence__c.class );
            c.Completed_Cadence_Status__c = status;
            if (ContactService.isContact(targetIdString)) {
                c.Contact__c = targetId;
            } else {
                c.Lead__c = targetId;
            }
            c.Nurture_Track_Configuration__c = nurtureTrackId;

            completedCadences.add(c);
        }
        return completedCadences;
    }

    /**
     * @description Method for creating Term Record
     * @param contactId - contact ids
     * @param oppList - list of oppportunities
     * @return oppConRole - list of opportunity contact roles
     */
    public static List<OpportunityContactRole> createTestOpportunityContactRolesRecords(
        Id contactId,
        List<Opportunity> oppList
    ) {
        List<OpportunityContactRole> oppConRole = new List<OpportunityContactRole>();
        for (Integer i = 0; i < oppList.size(); i++) {
            oppConRole.add(
                new OpportunityContactRole(ContactId = contactId, OpportunityId = oppList[i].Id)
            );
        }
        return oppConRole;
    }

    /**
     * @description Method for creating Term Record
     * @param oppList - list of opportunities
     * @param status - status of envelope
     * @return envelopeStatuses - list of envelope statuses
     */
    public static List<dfsle__EnvelopeStatus__c> createTestEnvelopeStatusRecords(
        List<Opportunity> oppList,
        String status
    ) {
        List<dfsle__EnvelopeStatus__c> envelopeStatuses = new List<dfsle__EnvelopeStatus__c>();
        for (Integer i = 0; i < oppList.size(); i++) {
            envelopeStatuses.add(
                new dfsle__EnvelopeStatus__c(
                    dfsle__SourceId__c = oppList[i].Id,
                    dfsle__Status__c = status
                )
            );
        }
        return envelopeStatuses;
    }

    /**
     * @description Method for creating test ContentVersion records
     * @param contentVersionNumber - number of ContentVersion to be created
     * @return contentVersionList - list of ContentVersion created
     */
    public static List<ContentVersion> createTestContentVersionRecords(
        Integer contentVersionNumber
    ) {
        List<ContentVersion> contentVersionList = new List<ContentVersion>();

        for (Integer i = 0; i < contentVersionNumber; i++) {
            contentVersionList.add(
                new ContentVersion(
                    Title = 'Proposal - General With Content_ALPHA ZENITH PTY LTD-test opportunity that may e123123123samplesample' +
                        i,
                    PathOnClient = 'test' + i,
                    versiondata = EncodingUtil.base64Decode('Unit Test Attachment Body')
                )
            );
        }

        return contentVersionList;
    }

    /**
     * @description Method for creating test ContentVersion records
     * @param contentVersionNumber - number of ContentVersion to be created
     * @return contentVersionList - list of ContentVersion created
     */
    public static List<ContentVersion> createTestContentVersionRecordsWithMemoTitle(
        Integer contentVersionNumber
    ) {
        List<ContentVersion> contentVersionList = new List<ContentVersion>();

        for (Integer i = 0; i < contentVersionNumber; i++) {
            contentVersionList.add(
                new ContentVersion(
                    Title = 'QUT MEMO_Opportunity' + i,
                    PathOnClient = 'test' + i,
                    versiondata = EncodingUtil.base64Decode('Unit Test Attachment Body')
                )
            );
        }

        return contentVersionList;
    }

    public static ContentDocumentLink createTestContentDocumentLink(
        Id contentDocumentId,
        Id linkedEntityId
    ) {
        return new ContentDocumentLink(
            ContentDocumentId = contentDocumentId,
            LinkedEntityId = linkedEntityId,
            ShareType = 'I',
            Visibility = 'AllUsers'
        );
    }

    /**
     * @description Method for creating test programplan records
     * @param programPlanNumber - number of ContentVersion to be created
     * @return contentVersionList - list of ContentVersion created
     */
    public static List<hed__Program_Plan__c> createTestProgramPlanRecords(
        Integer programPlanNumber
    ) {
        List<hed__Program_Plan__c> programPlanList = new List<hed__Program_Plan__c>();

        for (Integer i = 0; i < programPlanNumber; i++) {
            programPlanList.add(new hed__Program_Plan__c(Name = 'Test Program Plan' + i));
        }

        return programPlanList;
    }

    /**
     * @description Method for creating test hed__Program_Enrollment__c records
     * @param numberOfRecordsToCreate - number of hed__Program_Enrollment__c records to be created
     * @return programEnrollmentList - list of hed__Program_Enrollment__c created
     */
    public static List<hed__Program_Enrollment__c> createTestProgramEnrollmentRecords(
        Integer numberOfRecordsToCreate
    ) {
        List<hed__Program_Enrollment__c> programEnrollmentList = new List<hed__Program_Enrollment__c>();

        for (Integer i = 0; i < numberOfRecordsToCreate; i++) {
            programEnrollmentList.add(new hed__Program_Enrollment__c());
        }

        return programEnrollmentList;
    }

    /**
     * @description Method for creating test Program_Enrollment_Breach__c records
     * @param numberOfRecordsToCreate - number of hed__Program_Enrollment__c records to be created
     * @return programEnrollmentBreachList - list of Program_Enrollment_Breach__c created
     */
    public static List<Program_Enrollment_Breach__c> createTestProgramEnrollmentBreachRecords(
        Integer numberOfRecordsToCreate
    ) {
        List<Program_Enrollment_Breach__c> programEnrollmentBreachList = new List<Program_Enrollment_Breach__c>();

        for (Integer i = 0; i < numberOfRecordsToCreate; i++) {
            programEnrollmentBreachList.add(new Program_Enrollment_Breach__c());
        }

        return programEnrollmentBreachList;
    }

    /**
     * @description Method for creating test Breach__c records
     * @param numberOfRecordsToCreate - number of Breach__c records to be created
     * @return BreachList - list of Breach__c created
     */
    public static List<Breach__c> createTestBreachRecords(
        Integer numberOfRecordsToCreate
    ) {
        List<Breach__c> BreachList = new List<Breach__c>();

        for (Integer i = 0; i < numberOfRecordsToCreate; i++) {
            BreachList.add(new Breach__c());
        }

        return BreachList;
    }

    /**
     * @description Method for creating test Product2 with isActive status
     * @param numProducts - number of Product2 to be created
     * @return products - list of Product2 created
     */
    public static List<Product2> createTestInActiveProductRecords(Integer numProducts) {
        List<Product2> products = new List<Product2>();

        for (Integer i = 0; i < numProducts; i++) {
            products.add(
                new Product2(
                    IsActive = false,
                    Description = 'TestProductDesc' + i,
                    Family = 'QUTeX CCE Elements',
                    Name = 'TestProduct' + i
                )
            );
        }

        return products;
    }
    /**
     * @description Method to a create Community User
     *
     * @param email - email of authenticated user
     * @param lastName - last name of authenticated user
     * @param firstName - first name of authenticated user
     * @return Auth.UserData that looks like what we expect from LinkedIn
     **/
    public static Auth.UserData createCommunityUser(
        String email,
        String lastName,
        String firstName,
        String username
    ) {
        Map<String, String> attributeMap = new Map<String, String>();
        String identifier = lastName + System.currentTimeMillis();
        String locale = 'en_US';
        return new Auth.UserData(
            identifier,
            firstName,
            lastName,
            '', // fullname
            email,
            '', // link
            username,
            locale,
            '', // provider
            '', // siteLoginUrl
            attributeMap
        );
    }

    /**
     * @description Method for creating Course Connection Record
     * @param nCourseConnection - number of Course Connection to be created
     * @param conId - Contact Id to be related to Course Connection
     * @param courseOfferings - Course Offerings to be related to Course Connection
     * @return courseConnectionRecord - List of Course Connection Created
     */
    public static List<hed__Course_Enrollment__c> createTestCourseConnectionRecord(
        Integer nCourseConnection,
        Id conId,
        List<hed__Course_Offering__c> courseOfferings
    ) {
        List<hed__Course_Enrollment__c> courseConnectionRecord = new List<hed__Course_Enrollment__c>();
        for (Integer i = 0; i < nCourseConnection; i++) {
            courseConnectionRecord.add(
                new hed__Course_Enrollment__c(
                    hed__Contact__c = conId,
                    hed__Course_Offering__c = courseOfferings[i].id
                )
            );
        }
        return courseConnectionRecord;
    }

    /**
     * @description Method for creating Course Connection Record
     * @param nCourseConnection - number of Course Connection to be created
     * @param conId - Contact Id to be related to Course Connection
     * @param programOfferings - Program Offerings to be related to Course Connection
     * @return courseConnectionRecord - List of Course Connection Created
     */
    public static List<hed__Course_Enrollment__c> createTestCourseConnectionRecordProgram(
        Integer nCourseConnection,
        Id conId,
        List<Program_Offering__c> programOfferings
    ) {
        List<hed__Course_Enrollment__c> courseConnectionRecord = new List<hed__Course_Enrollment__c>();
        for (Integer i = 0; i < nCourseConnection; i++) {
            courseConnectionRecord.add(
                new hed__Course_Enrollment__c(
                    hed__Contact__c = conId,
                    Program_Offering__c = programOfferings[i].id
                )
            );
        }
        return courseConnectionRecord;
    }

        /**
     * @description Method for creating Course Connection Record
     * @param nCourseConnection - number of Course Connection to be created
     * @param status - hed__Status__c picklist value
     * @param lmsIntegrationStatus - LMS_Integration_Status__c picklist value
     * @return courseConnectionRecord - List of Course Connection Created
     */
    public static List<hed__Course_Enrollment__c> createTestCourseConnectionRecordsByStatus(
        Integer nCourseConnection,
        String status,
        String lmsIntegrationStatus
    ) {
        List<hed__Course_Enrollment__c> courseConnectionRecord = new List<hed__Course_Enrollment__c>();
        for (Integer i = 0; i < nCourseConnection; i++) {
            courseConnectionRecord.add(
                new hed__Course_Enrollment__c(
                    hed__status__c = status,
                    LMS_Integration_Status__c = lmsIntegrationStatus
                )
            );
        }
        return courseConnectionRecord;
    }

    /**
     * @description Method for creating Course Connection Assessment Record
     * @param nCourseConnectionAssessment - number of Course Connection to be created
     * @param courseConnectionId - Course Connection Id to be related to Course Connection Assessment
     * @return courseConnectionAssessmentRecord - List of Course Connection Created
     */
    public static List<Course_Connection_Assessment__c> createTestCourseConnectionAssessmentRecord(
        Integer nCourseConnectionAssessment,
        Id courseConnectionId
    ) {
        List<Course_Connection_Assessment__c> courseConnectionAssessmentRecord = new List<Course_Connection_Assessment__c>();
        for (Integer i = 0; i < nCourseConnectionAssessment; i++) {
            courseConnectionAssessmentRecord.add(
                new Course_Connection_Assessment__c(
                    Course_Connection__c = courseConnectionId
                )
            );
        }
        return courseConnectionAssessmentRecord;
    }


    /**
     * @description method to create test data for create Account
     * @param doInsert - boolean true/false
     * @return acc - account
     */
    public static Account createTestAccount(Boolean doInsert) {
        Account acc = new Account();
        acc.Name = TEST_ACCOUNT_NAME;

        if (doInsert) {
            insert acc;
        }
        return acc;
    }

    /**
     * @description method to create test data for create Pricebook2
     * @param doInsert - boolean true/false
     * @return pb - Pricebook2
     */
    public static Pricebook2 createTestPricebook2(Boolean doInsert) {
        Pricebook2 pb = new Pricebook2();
        pb.Name = TEST_PRICEBOOK2_NAME;

        if (doInsert) {
            insert pb;
        }
        return pb;
    }
    /**
     * @description method to create test data for create contact object
     * @param doInsert - boolean true/false
     * @param accId - account Id
     * @return con - Contact
     */
    public static Contact createTestContact(Boolean doInsert, Id accId) {
        Contact con = new Contact();
        con.AccountId = accId;
        con.FirstName = CommonUtils.randomString(10);
        con.LastName = CommonUtils.randomString(10);

        if (doInsert) {
            insert con;
        }
        return con;
    }

    /**
     * @description method to create test data for Buyer Account
     * @param doInsert - boolean true/false
     * @param accId - account Id
     * @return buyerAccount - BuyerAccount
     */
    public static BuyerAccount createTestBuyerAccount(Boolean doInsert, Id accId) {
        BuyerAccount buyerAccount = new BuyerAccount();
        buyerAccount.BuyerId = accId;
        buyerAccount.Name = TEST_BUYER_ACCT;
        buyerAccount.IsActive = true;

        if (doInsert) {
            insert buyerAccount;
        }
        return buyerAccount;
    }

    /**
     * @description method to create test data for Buyer Group
     * @param doInsert - boolean true/false
     * @param accId - account Id
     * @return buyerGrp - BuyerGroup
     */
    public static BuyerGroup createTestBuyerGroup(Boolean doInsert) {
        BuyerGroup buyerGrp = new BuyerGroup(Name = TEST_BUYER_GROUP);

        if (doInsert) {
            insert buyerGrp;
        }
        return buyerGrp;
    }

    /**
     * @description method to create test data for Buyer Group Member
     * @param doInsert - boolean true/false
     * @param accId - account Id
     * @return buyerGrpMember - BuyerGroupMember
     */
    public static BuyerGroupMember createTestBuyerGroupMember(
        Boolean doInsert,
        Id accId,
        Id buyerGrpId
    ) {
        BuyerGroupMember buyerGrpMember = new BuyerGroupMember();
        buyerGrpMember.BuyerGroupId = buyerGrpId;
        buyerGrpMember.BuyerId = accId;

        if (doInsert) {
            insert buyerGrpMember;
        }
        return buyerGrpMember;
    }

    /**
     * @description method to create test data for Product2
     * @param doInsert - boolean true/false
     * @return prd - product2
     */
    public static Product2 createTestProduct2(Boolean doInsert) {
        Product2 prd = new Product2(
            Name = 'TestProduct',
            ProductCode = 'TEST_SKU',
            Family = 'TestFamily'
        );

        if (doInsert) {
            insert prd;
        }
        return prd;
    }

    /**
     * @description Method for creating test Account records
     * @param numAccts - number of Accounts to be created
     * @param accId - Id of the related account
     * @param accName - Name of the related account
     * @return baccts - list of BuyerAccounts created
     */
    public static List<BuyerAccount> createTestBuyerAccountRecords(
        Integer numAccts,
        Id accId,
        String accName
    ) {
        List<BuyerAccount> baccts = new List<BuyerAccount>();

        for (Integer i = 0; i < numAccts; i++) {
            baccts.add(new BuyerAccount(BuyerId = accId, Name = accName));
        }

        return baccts;
    }

    /**
     * @description Method for creating test Program Offering records
     * @param nProgramOffering - number of Program Offering to be created
     * @param programPlans - Program Plan to be related to Program Offering
     * @return programOfferingRecord - List of Pending Registration Created   */
    public static List<Program_Offering__c> createTestProgramOfferingRecords(
        Integer nProgramOffering,
        List<hed__Program_Plan__c> programPlans
    ) {
        List<Program_Offering__c> programOfferingRecord = new List<Program_Offering__c>();
        for (Integer i = 0; i < nProgramOffering; i++) {
            programOfferingRecord.add(
                new Program_Offering__c(
                    Name = 'Test Program Offering' + i,
                    hed_Program_Plan__c = programPlans[i].id,
                    hed_Capacity__c = 10,
                    Start_Date__c = system.today() + 1
                )
            );
        }
        return programOfferingRecord;
    }

    public static Program_Offering__c createTestProgramOfferingRecords(
        Map<String, String> programOfferingFields
    ) {
        Program_Offering__c programOfferingRecord = new Program_Offering__c(
            Name = programOfferingFields.get('Name'),
            hed_Program_Plan__c = programOfferingFields.get('hed_Program_Plan__c'),
            hed_Capacity__c = 30,
            Start_Date__c = system.today() + 1,
            Registration_Start_Date__c = system.today() + 1,
            IsActive__c = true,
            Visible_on_Website__c = true
        );
        return programOfferingRecord;
    }

    /**
     * @description Method for creating test Product Ledger records
     * @param numProductLedger number of product ledger
     * @param courseEnrollement Id of related course enrollment
     * @param assets Id of related Asset
     * @return productLedger - list of product ledger
     */
    public static List<Product_Ledger__c> createTestProductLedgerRecords(
        Integer numProductLedger,
        Id courseEnrollement,
        Id assets
    ) {
        List<Product_Ledger__c> productLedger = new List<Product_Ledger__c>();

        for (Integer i = 0; i < numProductLedger; i++) {
            productLedger.add(
                new Product_Ledger__c(Course_Connection__c = courseEnrollement, Asset__c = assets)
            );
        }

        return productLedger;
    }

    /**
     * @description Method for creating test Credential records
     * @param numOfCredential number of Credential
     * @return credential - list of Credential
     */
    public static List<Credential__c> createTestCredentialRecords(Integer numOfCredential) {
        List<Credential__c> credential = new List<Credential__c>();
        for (Integer i = 0; i < numOfCredential; i++) {
            credential.add(new Credential__c(Name = 'Test Credential' + i));
        }
        return credential;
    }
    /**
     * @description Method for creating test Questionnaire records
     * @param numQuestionnaires number of questionnaires
     * @param parentRecord Id of parent record
     * @param objectType api name of object the questionnaire is attached to
     * @return questionnaires - list of questionnaires
     */
    public static List<Questionnaire__c> createTestQuestionnaireRecords(
        Integer numQuestionnaires,
        String parentRecord,
        String objectType
    ) {
        List<Questionnaire__c> questionnaires = new List<Questionnaire__c>();

        for (Integer i = 0; i < numQuestionnaires; i++) {
            questionnaires.add(
                new Questionnaire__c(
                    Questionnaire_Type__c = STR_QUESTIONNAIRE_TYPE,
                    Parent_Record_ID__c = parentRecord,
                    Object_Type__c = objectType
                )
            );
        }

        return questionnaires;
    }

    /**
     * @description Method for creating test Question records
     * @param numQuestion number of questions
     * @return questions - list of questions
     */
    public static List<Question__c> createTestQuestionRecords(Integer numQuestions) {
        List<Question__c> questions = new List<Question__c>();

        for (Integer i = 0; i < numQuestions; i++) {
            questions.add(new Question__c());
        }

        return questions;
    }

    /**
     * @description Method for creating test Related Answer records
     * @param numRelatedAnswers number of Related Answers
     * @param relatedQuestions Id of parent record
     * @param relatedQuestionnaire api name of object the questionnaire is attached to
     * @return questionnaires - list of Related Answers
     */
    public static List<Related_Answer__c> createTestRelatedAnswerRecords(
        Integer numRelatedAnswers,
        Id relatedQuestionnaire,
        List<Question__c> relatedQuestions
    ) {
        List<Related_Answer__c> relAnswers = new List<Related_Answer__c>();

        for (Integer i = 0; i < numRelatedAnswers; i++) {
            relAnswers.add(
                new Related_Answer__c(
                    Questionnaire__c = relatedQuestionnaire,
                    Question__c = relatedQuestions[i]?.Id
                )
            );
        }

        return relAnswers;
    }

    /**
     * @description Method for creating test Expression of Interest records
     * @param numInterests number of expression of interests
     * @param contact contact of user registered his interest
     * @param products list of products
     */
    public static List<Expression_of_Interest__c> createExpressionOfInterest(
        Integer numInterests,
        Contact contact,
        List<Product2> products
    ) {
        List<Expression_of_Interest__c> interests = new List<Expression_of_Interest__c>();

        for (Integer i = 0; i < numInterests; i++) {
            interests.add(
                new Expression_of_Interest__c(
                    Contact__c = contact.Id,
                    Product__c = products[i].Id,
                    Type__c = 'Register Interest',
                    Status__c = 'Active'
                )
            );
        }

        return interests;
    }

    /**
     * @description Method for creating test  questionnaire response summary records
     * @param numQuestionnaireResponseSummary number of questionnaire response summary
     * @param contact contact to be relate in questionnaire response summary records
     * @param courseOff List of related course offering
     * @return questionnaireResponseSumm - list of questionnaire response summary
     */
    public static List<Questionnaire_Response_Summary__c> createTestQuestionnaireResponseSummaryRecords(
        Integer numQuestionnaireResponseSummary,
        List<hed__Course_Offering__c> courseOff,
        Contact contact
    ) {
        List<Questionnaire_Response_Summary__c> questionnaireResponseSumm = new List<Questionnaire_Response_Summary__c>();

        for (Integer i = 0; i < numQuestionnaireResponseSummary; i++) {
            questionnaireResponseSumm.add(
                new Questionnaire_Response_Summary__c(
                    Contact__c = contact.Id,
                    Course_Offering__c = courseOff[i].Id
                )
            );
        }

        return questionnaireResponseSumm;
    }

    /**
     * @description Method for creating test Session records
     * @param numSessions number of Session record
     */
    public static List<Session__c> createTestSessionRecords(Integer numSessions) {
        List<Session__c> sessions = new List<Session__c>();

        for (Integer i = 0; i < numSessions; i++) {
            sessions.add(new Session__c(Name = 'Session Test' + i));
        }

        return sessions;
    }

    /**
     * @description Method for creating test Attendance Event records
     * @param numAttendance number of Attendance record
     * @param contId Id of contact to be related
     * @param courseEnrollment Id of Course Connection to be related
     * @param sessionId Id of Session to be related
     */
    public static List<hed__Attendance_Event__c> createTestAttendanceRecords(
        Integer numAttendance,
        Id contId,
        Id courseEnrollment,
        Id sessionId
    ) {
        List<hed__Attendance_Event__c> attendance = new List<hed__Attendance_Event__c>();

        for (Integer i = 0; i < numAttendance; i++) {
            attendance.add(
                new hed__Attendance_Event__c(
                    hed__Contact__c = contId,
                    hed__Course_Connection__c = courseEnrollment,
                    Session__c = sessionId
                )
            );
        }

        return attendance;
    }

    /**
     * @description Method for creating test Financial Split records
     * @param numFinSplits number of financial splits
     * @param courseId id of related course
     * @return finSplits - list of financial splits
     */
    public static List<Financial_Split__c> createTestFinancialSplitRecords(
        Integer numFinSplits,
        Id courseId
    ) {
        List<Financial_Split__c> finSplits = new List<Financial_Split__c>();

        for (Integer i = 0; i < numFinSplits; i++) {
            finSplits.add(new Financial_Split__c(Course__c = courseId));
        }

        return finSplits;
    }

    /**
     * @description Method for creating test Financial Split records
     * @param numFinSplits number of financial splits
     * @param courseId id of related course
     * @param optty id of related opportunity
     * @return finSplits - list of financial splits
     */
    public static List<Financial_Split__c> createTestFinancialSplitRecordsForOpportunity(
        Integer numFinSplits,
        Id oppty,
        Id accountId
    ) {
        List<Financial_Split__c> finSplits = new List<Financial_Split__c>();

        for (Integer i = 0; i < numFinSplits; i++) {
            finSplits.add(
                new Financial_Split__c(
                    Opportunity__c = oppty,
                    Funding_Body__c = accountId,
                    RecordTypeId = FinancialSplitsDAO.OPPORTUNITY_FUNDING_BODY_RECORDTYPEID,
                    Percentage_split__c = 20
                )
            );
        }

        return finSplits;
    }

    /**
     * @description Method for creating test Related Product Requests
     * @param numRelatedPR number of records
     * @param courseProdReqId id of related course PR
     * @param programProdReqId id of related program PR
     * @return relatedPrList - list of related product requests
     */
    public static List<Related_Product_Request__c> createTestRelatedPRRecords(
        Integer numRelatedPR,
        List<Product_Request__c> courseProdReqId,
        List<Product_Request__c> programProdReqId
    ) {
        List<Related_Product_Request__c> relatedPrList = new List<Related_Product_Request__c>();
        for (Integer i = 0; i < numRelatedPR; i++) {
            relatedPrList.add(
                new Related_Product_Request__c(
                    Course__c = courseProdReqId[i].Id,
                    Program__c = programProdReqId[i].Id
                )
            );
        }
        return relatedPrList;
    }

    /**
     * @description Method for creating test Adhoc Communication records
     * @param numAdhocComms number of records
     * @return adhocCommsList - list of adhoc communication records
     */
    public static List<Adhoc_Communication__c> createTestAdhocCommsRecords(Integer numAdhocComms) {
        List<Adhoc_Communication__c> adhocCommsList = new List<Adhoc_Communication__c>();
        for (Integer i = 0; i < numAdhocComms; i++) {
            adhocCommsList.add(new Adhoc_Communication__c(
                IsSent__c = false,
                Send_Date__c = System.today(),
                Subject__c = 'test subject' + i,
                Email_Content__c = 'test email content'
            ));
        }
        return adhocCommsList;
    }

    /**
     * @description Method for creating test Document records
     * @param numDocs number of records
     * @param docNames name of documents
     * @param folderName folder where document is placed
     * @return docsList - list of document records
     */
    public static List<Document> createTestDocumentRecords(
        Integer numDocs,
        List<String> docNames,
        String folderName
    ) {
        Id queriedFolderId = [SELECT Id FROM Folder WHERE Name = :folderName LIMIT 1]?.Id;
        List<Document> docsList = new List<Document>();
        for (Integer i = 0; i < numDocs; i++) {
            docsList.add(new Document(Name = docNames[i], FolderId = queriedFolderId));
        }
        return docsList;
    }
    /**
     * @description Method for creating test List records
     * @return listRecords - Lists created
     */
    public static List<List__c> createListRecords(
        Integer numOfList
    ) {
        List<List__c> listRecords = new List<List__c>();

        for (Integer i = 0; i < numOfList; i++) {
            listRecords.add(
                new List__c(
                   List_Name__c = 'New List ' + i,
                   Stage__c = 'New'
                )
            );
        }
        return listRecords;
    }
    
    /**
     * @description Method for creating test List Contributor records
     * @return listContributorRecords - Lists created
     */
    public static List<List_Contributor__c> createListContributorRecords(
        Integer numOfList,
        Id listParentId
    ) {
        List<List_Contributor__c> listContributors = new List<List_Contributor__c>();

        for (Integer i = 0; i < numOfList; i++) {
            listContributors.add(
                new List_Contributor__c(
                   List__c = listParentId,
                   Task_Status__c = 'Assigned'
                )
            );
        }
        return listContributors;
    }
    /**
     * @description Method for creating test List Member records
     * @return listMemberRecords - List Members created
     */
    public static List<List_Member__c> createListMemberRecords(
        Integer numOfList,
        Id listId,
        Id listMemberId
    ) {
        List<List_Member__c> listMemberRecords = new List<List_Member__c>();

        for (Integer i = 0; i < numOfList; i++) {
            listMemberRecords.add(
                new List_Member__c(
                   List__c = listId,
                   Activity_Status__c = ListMembersDAO.ACCEPTED_ACTIVITY_STATUS,
                   List_Member__c = listMemberId 
                )
            );
        }
        return listMemberRecords;
    }
    /**
     * @description Method for creating test List Member records
     * with multiple list records
     * @return listMemberRecords - List Members created
     */
    public static List<List_Member__c> createListMemberBatchRecords(
        Integer numOfList,
        List<List__c> listrecords,
        Id listMemberId
    ) {
        List<List_Member__c> listMemberRecords = new List<List_Member__c>();

        for (Integer i = 0; i < numOfList; i++) {
            listMemberRecords.add(
                new List_Member__c(
                   List__c = listrecords[i].Id,
                   Activity_Status__c = ListMembersDAO.ACCEPTED_ACTIVITY_STATUS,
                   List_Member__c = listMemberId 
                )
            );
        }
        return listMemberRecords;
    } 
    /**
     * @description Method for creating Communication Schedule
     * @param nCommSched - number of Communication Schedule to be created
     * @param course - List of Course to be related to Communication Schedule
     * @param progPlan - List of Program Plan to be related to Communication Schedule
     * @return commSched - List of Communication Schedule Created
     */
    public static List<Communication_Schedule__c> createTestCommunicationScheduleRecords(
        Integer nCommSched,
        List<hed__Course__c> course,
        List<hed__Program_Plan__c> progPlan
    ) {
        List<Communication_Schedule__c> commSched = new List<Communication_Schedule__c>();
        for (Integer i = 0; i < nCommSched; i++) {
            commSched.add(
                new Communication_Schedule__c(
                    Program_Plan__c = progPlan[i].Id,
                    Course__c = course[i].Id
                )
            );
        }
        return commSched;
    }

    /**
     * @description Method for creating test Email Template records
     * @param numTemplates number of records
     * @param templateNameAndSubjectMap map containing name of template and its corresponding subject
     * @return templateList - list of email template records
     */
    public static List<EmailTemplate> createTestEmailTemplateRecords(
        Integer numTemplates,
        Map<String, String> templateNameAndSubjectMap
    ) {
        List<EmailTemplate> templateList = new List<EmailTemplate>();
        List<String> templateNames = new List<String>();
        templateNames.addAll(templateNameAndSubjectMap.keySet());
        for (Integer i = 0; i < numTemplates; i++) {
            templateList.add(
                new EmailTemplate(
                    IsActive = true,
                    Name = templateNames[i],
                    DeveloperName = generateRandomString('test_emailtemplate'),
                    TemplateType = 'custom',
                    HtmlValue = generateRandomString('test_emailtemplate'),
                    FolderId = UserInfo.getUserId(),
                    Subject = templateNameAndSubjectMap.get(templateNames[i])
                )
            );
        }
        return templateList;
    }

    /**
     * @description Method for generating random string for unique fields
     * @param identifier - additinal string to add as identifier
     * @return random string
     */
    public static String generateRandomString(String identifier) {
        return identifier +
            String.valueOf(System.today().month()) +
            String.valueOf(System.today().year()) +
            String.valueOf(Integer.valueOf(Math.floor(100000 + Math.random() * 900000)));
    }

    /**
     * @description Method for creating test hed__Affiliation__c records
     * @param numContacts - number of Affliated Contact to be created
     * @param accountId - accountId
     * @return cons - list of hed__Affiliation__c created
     */
    public static List<hed__Affiliation__c> createTestAffliatedContactRecords(
        Integer numContacts,
        Id accountId
    ) {
        List<hed__Affiliation__c> cons = new List<hed__Affiliation__c>();

        for (Integer i = 0; i < numContacts; i++) {
            cons.add(
                new hed__Affiliation__c(
                    hed__Description__c = 'AF Test' + i,
                    hed__Account__c = accountId
                )
            );
        }

        return cons;
    }

    /**
     * @description Method for creating MC_Messaging_OTP_Setting__c custom setting
     * @param void
     * @return setting - the created MC_Messaging_OTP_Setting__c
     */
    public static MC_Messaging_OTP_Setting__c createOTPCustomSetting() {
        MC_Messaging_OTP_Setting__c setting = new MC_Messaging_OTP_Setting__c();
        setting.Access_Token_EndPoint_URL__c = 'https://accessToken';
        setting.Account_Id__c = '1234';
        setting.Attributes__c = 'Attr123';
        setting.Client_Id__c = '12344';
        setting.Client_Secret__c = '12987';
        setting.DefinitionKey__c = 'test';
        setting.GrantType__c = 'test';
        setting.Message__c = 'test';
        setting.SMS_EndPoint_URL__c = 'https://smsendpoint';
        return setting;
    }

    /**
     * @description Method for creating WebStoreCatalog
     * @param prodCatId - ProductCatalogId
     * @param salesStoreId - SalesStoreId
     * @return webStoreCatalog - the created WebStoreCatalog
     */
    public static WebStoreCatalog createWebStoreCatalog(Id prodCatId, Id salesStoreId) {
        WebStoreCatalog webStoreCatalog = new WebStoreCatalog();
        webStoreCatalog.ProductCatalogId = prodCatId;
        webStoreCatalog.SalesStoreId = salesStoreId;
        return webStoreCatalog;
    }

    /**
     * @description Method for creating WebCart
     * @param accountId - portal account id
     * @param ownerId - owner id
     * @param webstoreId - webstore id
     * @return WebCart - to be created WebCart
     */
    public static WebCart createWebCart(Id accountId, Id ownerId, Id webstoreId) {
        return new WebCart(
            Name = 'Cart',
            AccountId = accountId,
            Status = 'Active',
            Status__c = 'Active',
            WebStoreId = webstoreId,
            OwnerId = ownerId
        );
    }

    /**
     * @description Method for creating WebStoreCatalog
     * @return records - list of International_Tier__c records
     */
    public static List<International_Tier__c> createInternationalTierRecords(
        List<String> countryNames,
        String category,
        Boolean isActive
    ) {
        List<International_Tier__c> records = new List<International_Tier__c>();

        for (String country : countryNames) {
            International_Tier__c tier = new International_Tier__c(
                IsActive__c = isActive,
                Country_Name__c = country,
                Tier_Category__c = category
            );
            records.add(tier);
        }

        return records;
    }

    public static List<Case> createTestCaseRecords(
        Id recordTypeId,
        String subject,
        Integer numOfRecords
    ) {
        List<Case> caseList = new List<Case>();

        for (Integer i = 0; i < numOfRecords; i++) {
            Case caseRecord = new Case();
            caseRecord.RecordTypeId = recordTypeId;
            caseRecord.Subject = subject + i;
            caseList.add(caseRecord);
        }

        return caseList;
    }

    /**
     * @description Method for creating Communication_Queue__c object
     * @param Set<Id> recordIds - Contact/Lead record Ids to be set as Who Id
     * @param String status 
     * @return records - list of Communication_Queue__c records
     */
    public static List<Communication_Queue__c> createCommunicationQueuePerContactOrLead(Set<Id> recordIds, String status, Id emailTemplateId){
        List<Communication_Queue__c> communicationQueueList = new List<Communication_Queue__c> ();
        for(Id recordId : recordIds){
            communicationQueueList.add(
                new Communication_Queue__c(
                    WhoId__c = recordId,
                    Status__c = status,
                    Template_Id__c = emailTemplateId,
                    Due_Date__c = System.today()
                )
            );
        }
        return communicationQueueList;
    }

    public static List<EmailMessage> queryEmailMessageRecords() {
        Id courseConnectionId = [SELECT Id FROM hed__Course_Enrollment__c LIMIT 1]?.Id;
        List<EmailMessage> emailMessageList = [
            SELECT Id, RelatedToId
            FROM EmailMessage
            WHERE RelatedToId = :courseConnectionId
            WITH SECURITY_ENFORCED
        ];
        return emailMessageList;
    }

    /**
     * @description Method for generating test users
     * @param void
     * @return List<User> - all generated user records
     */
    public static List<User> generateTestUsers() {
        return TEST_USER_GENERATOR.generateTestUsers();
    }

    /**
     * @description Method for generating test users
     * @param userNames - userNames
     * @return List<User> - all generated user records
     */
    public static List<User> generateTestUsers(List<String> userNames) {
        return TEST_USER_GENERATOR.generateTestUsers(userNames);
    }

    /**
     * @description Method for getting Program Administrator
     * @param void
     * @return portalSysAdmin - QUTeX Program Admin User
     */
    public static User getProgramAdminUser() {
        User progAdmin = [
            SELECT Id
            FROM User
            WHERE Username LIKE 'QUT_Program_Administrator%'
            LIMIT 1
        ];
        return progAdmin;
    }

    /**
     * @description Method for getting ESB Integration User
     * @param void
     * @return esbIntegUser - ESB Integration User
     */
    public static User getESBIntegrationUser() {
        User esbIntegUser = [
            SELECT Id
            FROM User
            WHERE Username LIKE 'QUT_ESB%'
            LIMIT 1
        ];
        return esbIntegUser;
    }

    /**
     * @description Method for getting Program Administrator
     * @param void
     * @return portalSysAdmin - QUTeX Program Admin User
     */
    public static User getMarketingCloudUser() {
        User marketingCloud = [
            SELECT Id
            FROM User
            WHERE Username LIKE 'QUT_Marketing_Cloud%'
            LIMIT 1
        ];
        return marketingCloud;
    }

    /**
     * @description Method for creating Sys Admin Portal Owner
     * @param void
     * @return portalSysAdmin - Portal Sys Admin user
     */
    public static User getPortalSysAdminUser() {
        User portalSysAdmin = [SELECT Id FROM User WHERE Username LIKE 'QUT_Sys_Admin%' LIMIT 1];
        return portalSysAdmin;
    }

    /**
     * @description Method for creating Corporate Partner
     * @param void
     * @return coporateUser - Corporate Partner User
     */
    public static User getCorporatePartnerUser() {
        User coporateUser = [
            SELECT Id, AccountId, ContactId
            FROM User
            WHERE Username LIKE 'QUT_Corporate_Partner_User%'
            LIMIT 1
        ];
        return coporateUser;
    }

    /**
     * @description Method for creating Partnership Manager
     * @param void
     * @return partnershipManager - Partnership Manager
     */
    public static User getPartnershipManager() {
        User partnershipManager = [
            SELECT Id
            FROM User
            WHERE Username LIKE 'QUT_Partnership_Manager%'
            LIMIT 1
        ];
        return partnershipManager;
    }

    /**
     * @description Method for creating Partnership Manager
     * @param void
     * @return operationsManager - Operations Manager
     */
    public static User getOperationsManager() {
        User operationsManager = [
            SELECT Id
            FROM User
            WHERE Username LIKE 'QUT_Operations_Manager%'
            LIMIT 1
        ];
        return operationsManager;
    }

    /**
     * @description Method for creating Domestic Future Student Agent
     * @param void
     * @return futureStudentAgent - Domestic Future Student Agent
     */
    public static User getDomesticFutureStudentAgent() {
        User futureStudentAgent = [
            SELECT Id
            FROM User
            WHERE Username LIKE 'QUT_Domestic_Future_Student_Agent%'
            LIMIT 1
        ];
        return futureStudentAgent;
    }

    /**
     * @description Method for creating International Future Student Agent
     * @param void
     * @return futureStudentAgent - International Future Student Agent
     */
    public static User getInternationalFutureStudentAgent() {
        User futureStudentAgent = [
            SELECT Id
            FROM User
            WHERE Username LIKE 'QUT_International_Future_Student_Agent%'
            LIMIT 1
        ];
        return futureStudentAgent;
    }

    /**
     * @description Method for creating Advancement Manager
     * @param void
     * @return advancementManager - Advancement Manager
     */
    public static User getAdvancementManager() {
        User advancementManager = [
            SELECT Id
            FROM User
            WHERE Username LIKE 'QUT_Advancement_Manager%'
            LIMIT 1
        ];
        return advancementManager;
    }

    /**
     * @description Method for creating Donor Engagement Manager
     * @param void
     * @return DonorEngagementManager - Donor Engagement Manager
     */
    public static User getDonorEngagementManager() {
        User advancementManager = [
            SELECT Id
            FROM User
            WHERE Username LIKE 'QUT_Donor_Engagement_Manager%'
            LIMIT 1
        ];
        return advancementManager;
    }

    /**
     * @description Method for creating Learning Designer
     * @param void
     * @return learningDesigner - Learning Designer
     */
    public static User getLearningDesigner() {
        User learningDesigner = [
            SELECT Id
            FROM User
            WHERE Username LIKE 'QUT_Learning_Designer%'
            LIMIT 1
        ];
        return learningDesigner;
    }

    /**
     * @description Method for getting integration website user
     * @param void
     * @return integWebSiteUser - Integration Website User
     */
    public static User getIntegrationWebsiteUser() {
        User integWebSiteUser = [
            SELECT Id
            FROM User
            WHERE Username LIKE 'QUT_Website_Integration_User%'
            LIMIT 1
        ];
        return integWebSiteUser;
    }

    /**
     * @description Method for QUT Industry Engagement Partnership Manager
     * @param void
     * @return IE Partnership Manager
     */
    public static User getQUTIEPartnershipManager() {
        User pm = [
            SELECT Id
            FROM User
            WHERE Username LIKE 'QUT_IE_Partnership_Manager%'
            LIMIT 1
        ];
        return pm;
    }
    /**
     * @description Method for getting System Administrator
     * @param void
     * @return sysAdmin - QUTeX System Admin User
     */
    public static User getSystemAdminUser() {
        User sysAdmin = [
            SELECT Id
            FROM User
            WHERE Username LIKE 'QUT_System_Administrator%'
            LIMIT 1
        ];
        return sysAdmin;
    }    
    /**
    * @description Method for getting Corporate Partnerships Manager
    * @param void
    * @return Corporate Partnerships Manager
    */
   public static User getCorporatePartnershipsManager() {
       User sysAdmin = [
           SELECT Id
           FROM User
           WHERE Username LIKE 'QUT_Corporate_Partnership_Manager%'
           LIMIT 1
       ];
       return sysAdmin;
   }

   /**
    * @description Method for getting Corporate Partnerships Manager
    * @param void
    * @return Corporate Partnerships Manager
    */
    public static User getAlumniEngagementManager() {
        User sysUser = [
            SELECT Id
            FROM User
            WHERE Username LIKE 'Alumni_Engagement_Manager%'
            LIMIT 1
        ];
        return sysUser;
    }

    /**
    * @description Method for creating Alumni Engagement Manager
    * @param void
    * @return alumniEngagementManager - Alumni Engagement Manager
    */
   public static User getQUTAlumniEngagementManager() {
       User alumniEngagementManager = [
           SELECT Id
           FROM User
           WHERE Username LIKE 'QUT_Alumni_Engagement_Manager%'
           LIMIT 1
       ];
       return alumniEngagementManager;
   }

   /**
    * @description Method for creating Corporate Engagement Manager
    * @param void
    * @return corporateEngagementManager - Corporate Engagement Manager
    */
   public static User getCorporateEngagementManager() {
       User corporateEngagementManager = [
           SELECT Id
           FROM User
           WHERE Username LIKE 'QUT_Corporate_Engagement_Manager%'
           LIMIT 1
       ];
       return corporateEngagementManager;
   }
    /**
     * @description Method for creating Student Success Outreach Manager
     * @param void
     * @return studentSuccessOutreachManager - Student Success Outreach Manager User
     */
    public static User getStudentSuccessOutreachManager() {
        User studentSuccessOutreachManager = [
            SELECT Id
            FROM User
            WHERE Username LIKE 'QUT_Student_Success_Outreach_Manager%'
            LIMIT 1
        ];
        return studentSuccessOutreachManager;
    }

    class TestUserGenerator {
        private Map<String, Id> groupMap;
        private Map<String, Id> profileMap;
        private Map<String, Id> roleMap;
        private Map<String, Id> permSetMap;
        private List<User> addUsers = new List<User>{};
        private List<String> addPermSets = new List<String>{};
        private List<String> addGroups = new List<String>{};
        private Map<String, String> usermap;

        private List<User> generateTestUsers(List<String> userNames) {
            //instantiate list of users to be inserted
            addUsers = new List<User>();
            //instantiate list of permission set assignments
            addPermSets = new List<String>();
            //instantitate list of group assignments
            addGroups = new List<String>();
            List<String> listPortalUserNames = new List<String>();

            //get portal sys admin user as running user for creating new users
            getPortalSysAdminUser();
            System.runAs(portalSysAdmin) {
                for (String userName : userNames) {
                    if (USER_ATTRIB_LIST.contains(userName)) {
                        generateUsers(new UserAttributeClass(userName));
                    } else if (PORTAL_USERS_SET.contains(userName)) {
                        listPortalUserNames.add(userName);
                    }
                }
                if (!listPortalUserNames.isEmpty()) {
                    generatePortalUsers(listPortalUserNames);
                }
                insert addUsers;

                // get users, map userName and id.
                usermap = new Map<String, String>{};
                for (User i : addUsers) {
                    usermap.put(i.userName, i.Id);
                }

                addPermissionAssignment();
                addPublicGroupAssignment();
            }

            return addUsers;
        }

        private List<User> generateTestUsers() {
            //instantiate list of users to be inserted
            addUsers = new List<User>();
            //instantiate list of permission set assignments
            addPermSets = new List<String>();
            //instantitate list of group assignments
            addGroups = new List<String>();
            //get portal sys admin user as running user for creating new users
            getPortalSysAdminUser();
            System.runAs(portalSysAdmin) {
                for (String personaName : USER_ATTRIB_LIST) {
                    generateUsers(new UserAttributeClass(personaName));
                }

                generatePortalUsers(PORTAL_USERS_SET);
                insert addUsers;

                // get users, map userName and id.
                usermap = new Map<String, String>{};
                for (User i : addUsers) {
                    usermap.put(i.userName, i.Id);
                }

                addPermissionAssignment();
                addPublicGroupAssignment();
            }
            //End System.runAs
            return addUsers;
        }

        private void generatePortalUsers(List<String> portalUserNames) {
            //create contacts
            List<Contact> contactList = createTestContactRecords(portalUserNames.size());
            //Create account
            List<Account> accountList = createTestAccountRecords(portalUserNames.size());
            for (Integer i = 0; i < portalUserNames.size(); i++) {
                accountList[i].Name = 'PortalAccount' + String.valueOf(i);
            }
            insert accountList;

            //Update created contacts
            for (Integer i = 0; i < portalUserNames.size(); i++) {
                contactList[i].FirstName = 'PortalFirst' + String.valueOf(i);
                contactList[i].LastName = 'PortalLast' + String.valueOf(i);
                contactList[i].Email = System.now().millisecond() + i + '@qut.com';
                contactList[i].AccountId = accountList[i].Id;
            }
            insert contactList;

            for (Integer i = 0; i < portalUserNames.size(); i++) {
                generateUsers(new UserAttributeClass(portalUserNames[i], contactList[i].Id));
            }
            /** END - Creation of Portal Users */
        }

        private void generateUsers(UserAttributeClass userClass) {
            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            String uid = h.SubString(0, 8);

            populatePersonaGroupingsMap();

            User u = new User();
            u.UserName = userClass.userName + uid + '@qut.com';
            u.FirstName = 'Test';
            u.LastName = userClass.userName;
            u.Email = userClass.userName + uid + '@qut.com';
            u.alias = uid;
            u.ProfileId = profileMap.get(userClass.profileName);
            u.UserRoleId = roleMap.get(userClass.roleName);
            u.LocaleSidKey = 'en_AU';
            u.EmailEncodingKey = 'UTF-8';
            u.LanguageLocaleKey = 'en_US';
            u.TimeZoneSidKey = 'Australia/Brisbane';
            u.UserPermissionsInteractionUser = userClass.isServiceCloudUser;
            u.UserPermissionsSupportUser = userClass.isFlowUser;
            u.UserPermissionsKnowledgeUser = userClass.isKnowledgeUser;
            u.UserPermissionsMarketingUser = userClass.isMarketingUser;
            u.et4ae5__ExactTargetForAppExchangeAdmin__c = userClass.isAppExchangeAdmin;
            u.et4ae5__ExactTargetForAppExchangeUser__c = userClass.isAppExchangeUser;
            if (userClass.isPortal) {
                u.ContactId = userClass.contactId;
            }
            addUsers.add(u);

            // add permission sets
            collectPermissionSetAssignment(userClass.permSets, u);
            // add addGroups
            collectPublicGroupAssignment(userClass.publicGroups, u);
        }

        private void collectPermissionSetAssignment(String permSets, User u) {
            // add permission sets
            if (permSets != null && permSets != '') {
                if (permSets.contains(',')) {
                    // has multiple perm sets
                    List<String> res = permSets.split(',');
                    for (String r : res) {
                        String permset = r.trim();
                        addPermSets.add(u.UserName + '%%' + permset);
                    }
                } else {
                    // has single perm set
                    addPermSets.add(u.UserName + '%%' + permSets.trim());
                }
            }
        }

        private void collectPublicGroupAssignment(String publicGroups, User u) {
            // add addGroups
            if (publicGroups != null && publicGroups != '') {
                if (publicGroups.contains(',')) {
                    // has multiple queues
                    List<String> res = publicGroups.split(',');
                    for (String r : res) {
                        addGroups.add(u.UserName + '%%' + r.trim());
                    }
                } else {
                    // has single queues
                    addGroups.add(u.UserName + '%%' + publicGroups.trim());
                }
            }
        }

        private void addPermissionAssignment() {
            // insert perm sets if not null
            if (addPermSets != null && addPermSets.size() > 0) {
                list<PermissionSetAssignment> addPS = new List<PermissionSetAssignment>{};
                for (String i : addPermSets) {
                    List<String> res = i.split('%%');
                    addPS.add(
                        new PermissionSetAssignment(
                            PermissionSetId = permSetMap.get(res[1]),
                            AssigneeId = usermap.get(res[0])
                        )
                    );
                }
                insert addPS;
            }
        }

        private void addPublicGroupAssignment() {
            // insert Group if not null
            if (addGroups != null && addGroups.size() > 0) {
                list<GroupMember> addPG = new List<GroupMember>{};
                for (String i : addGroups) {
                    List<String> res = i.split('%%');
                    addPG.add(
                        new GroupMember(
                            GroupId = groupMap.get(res[1]),
                            UserOrGroupId = usermap.get(res[0])
                        )
                    );
                }
                insert addPG;
            }
        }

        private void populatePersonaGroupingsMap() {
            if (profileMap == null) {
                profileMap = new Map<String, Id>{};
                list<Profile> profileList = [SELECT Id, Name FROM Profile];
                for (Profile i : profileList) {
                    profileMap.put(i.Name, i.Id);
                }
            }
            if (roleMap == null) {
                roleMap = new Map<String, Id>{};
                list<UserRole> roleList = [SELECT Id, Name FROM UserRole];
                for (UserRole i : roleList) {
                    roleMap.put(i.Name, i.Id);
                }
            }
            if (permSetMap == null) {
                permSetMap = new Map<String, Id>{};
                list<PermissionSet> pmList = [SELECT Id, Name FROM PermissionSet];
                for (PermissionSet i : pmList) {
                    permSetMap.put(i.Name, i.Id);
                }
            }
            if (groupMap == null) {
                groupMap = new Map<String, Id>{};
                list<Group> pmList = [SELECT Id, Name FROM Group];
                for (Group i : pmList) {
                    groupMap.put(i.Name, i.Id);
                }
            }
        }

        private void getPortalSysAdminUser() {
            portalSysAdmin = [
                SELECT Id, UserRoleId
                FROM User
                WHERE
                    IsActive = TRUE
                    AND FirstName = 'Sys Admin'
                    AND LastName = 'Integration User'
                    AND (Profile.Name = 'QUT System Administrator'
                    OR Profile.Name = 'System Administrator')
                LIMIT 1
            ];

            if(String.isBlank(portalSysAdmin.UserRoleId)){
                //add UserRole
                portalSysAdmin.UserRoleId = [
                    SELECT Id
                    FROM UserRole
                    WHERE Name = 'System Administrator'
                    LIMIT 1
                ]
                ?.Id;
                update portalSysAdmin;
            }
            
        }
    }

    /**
     * @description If you use SeeAllData = false in your test class, in the test execution context, there will be no affiliation mapping configured. You have to insert recors to hed__Affl_Mappings__c according to the actual production config in order to do integration test for affiliation related features
     */
    public static void configureAffiliationMapping() {
        // Configuration setup
        // As we are setting SeeAllData = false, we have to add the affiliation mapping and table driven trigger management records in order for the test to execute correctly
        List<hed__Affl_Mappings__c> ams = new List<hed__Affl_Mappings__c>();
        ams.add(
            new hed__Affl_Mappings__c(
                hed__Account_Record_Type__c = 'Business_Organization',
                hed__Primary_Affl_Field__c = 'hed__Primary_Organization__c',
                Name = 'Business_Organization'
            )
        );
        ams.add(
            new hed__Affl_Mappings__c(
                hed__Account_Record_Type__c = 'University_Department',
                hed__Primary_Affl_Field__c = 'Primary_Department__c',
                Name = 'University_Department'
            )
        );
        insert ams;
    }

    /**
     * @description If you use SeeAllData = false in your test class, in the test execution context, there will be no TDTM confgiured. You have to insert recors to hed__Trigger_Handler__c according to the actual production config in order to do integration test for affiliation related features
     */
    public static void configureTDTMForCONPrimaryAfflsTDTM() {
        List<hed__Trigger_Handler__c> ths = new List<hed__Trigger_Handler__c>();
        ths.add(
            new hed__Trigger_Handler__c(
                hed__Class__c = 'CON_PrimaryAffls_TDTM',
                hed__Object__c = 'Contact',
                hed__Load_Order__c = 4,
                hed__Trigger_Action__c = 'AfterInsert;AfterUpdate',
                hed__Owned_by_Namespace__c = 'hed',
                hed__Active__c = true
            )
        );
        insert ths;
    }

    /**
     * @description Method for loading EDA Triggers from static resource
     * @param void
     * @return triggerList - list of EDA Trigger that were inserted
     */
    public static List<hed__Trigger_Handler__c> loadEDATriggers() {
        List<hed__Trigger_Handler__c> triggerList = Test.loadData(
            hed__Trigger_Handler__c.sObjectType,
            'edaTriggerHandler'
        );
        return triggerList;
    }

    private class UserAttributeClass {
        private String userName { get; set; }
        private String profileName { get; set; }
        private String roleName { get; set; }
        private String permSets { get; set; }
        private String publicGroups { get; set; }
        private Boolean isServiceCloudUser { get; set; }
        private Boolean isFlowUser { get; set; }
        private Boolean isKnowledgeUser { get; set; }
        private Boolean isMarketingUser { get; set; }
        private Boolean isAppExchangeAdmin { get; set; }
        private Boolean isAppExchangeUser { get; set; }
        private Boolean isPortal { get; set; }
        private Id contactId { get; set; }

        //move to metadata if persona is finalized
        private UserAttributeClass(String name) {
            // users below match personas on the following page https://wiki.qut.edu.au/display/DEP/User+Onboarding+Guide
            /** START - Creation of Integration/System Users */
            if (name == 'QUT_Developer') {
                userName = 'QUT_Developer';
                profileName = 'Development Team Base';
                roleName = '';
                permSets = 'Development_Team';
                publicGroups = '';
                isServiceCloudUser = true;
                isFlowUser = true;
                isKnowledgeUser = true;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            } else if (name == 'QUT_Read_Only') {
                userName = 'QUT_Read_Only';
                profileName = 'QUT Read Only';
                roleName = '';
                permSets = 'Integration_Person';
                publicGroups = '';
                isServiceCloudUser = true;
                isFlowUser = true;
                isKnowledgeUser = true;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            } else if (name == 'QUT_System_Administrator') {
                userName = 'QUT_System_Administrator';
                profileName = 'QUT System Administrator';
                roleName = 'System Administrator';
                permSets = 'DocuSign_Administrator,DocuSign_Generator,DocuSign_Negotiator,DocuSign_User,System_Administrator,Permission_All_Object_and_FLAs_View_Create_Update_Delete';
                publicGroups = '';
                isServiceCloudUser = true;
                isFlowUser = true;
                isKnowledgeUser = true;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            } else if (name == 'QUT_Sys_Admin') {
                userName = 'QUT_Sys_Admin';
                profileName = 'QUT System Administrator';
                roleName = 'System Administrator';
                permSets = 'System_Administrator,Permission_All_Object_and_FLAs_View_Create_Update_Delete';
                publicGroups = '';
                isServiceCloudUser = true;
                isFlowUser = true;
                isKnowledgeUser = true;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            } else if (name == 'QUT_Form_Builder') {
                userName = 'QUT_Form_Builder';
                profileName = 'Integration Forms';
                roleName = 'None';
                permSets = 'Permission_API_Only_User,Integration_Forms';
                publicGroups = '';
                isServiceCloudUser = true;
                isFlowUser = true;
                isKnowledgeUser = false;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            } else if (name == 'QUT_Website_Integration_User') {
                userName = 'QUT_Website_Integration_User';
                profileName = 'Integration Website';
                roleName = 'None';
                permSets = 'Permission_API_Only_User,Permission_API_Enabled,Lead_Forms,Product_Catalogue_Read_Only,Website_Connected_App';
                publicGroups = '';
                isServiceCloudUser = true;
                isFlowUser = true;
                isKnowledgeUser = false;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            } else if (name == 'QUT_Marketing_Cloud') {
                userName = 'QUT_Marketing_Cloud';
                profileName = 'Integration Marketing';
                roleName = 'None';
                permSets = 'Permission_API_Only_User,Integration_Marketing,Marketing_Cloud_Connected_App';
                publicGroups = '';
                isServiceCloudUser = true;
                isFlowUser = true;
                isKnowledgeUser = false;
                isMarketingUser = true;
                isAppExchangeAdmin = true;
                isAppExchangeUser = true;
                isPortal = false;
                contactId = null;
            } else if (name == 'QUT_ESB') {
                userName = 'QUT_ESB';
                profileName = 'Integration';
                roleName = 'None';
                permSets = 'Permission_API_Only_User,Integration_Person,Integration_Webcart';
                publicGroups = '';
                isServiceCloudUser = true;
                isFlowUser = true;
                isKnowledgeUser = false;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            } else if (name == 'QUT_Data_Migration') {
                userName = 'QUT_Data_Migration';
                profileName = 'Integration';
                roleName = 'None';
                permSets = 'Permission_API_Only_User,Integration_Person';
                publicGroups = '';
                isServiceCloudUser = true;
                isFlowUser = true;
                isKnowledgeUser = false;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            }
            /** START - Creation of General Users */
            else if (name == 'QUT_Chatter_Free') {
                userName = 'QUT_Chatter_Free';
                profileName = 'Chatter Free User';
                roleName = '';
                permSets = '';
                publicGroups = '';
                isServiceCloudUser = false;
                isFlowUser = false;
                isKnowledgeUser = false;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            }
            /** START - Creation of QUTeX Users */
            else if (name == 'QUT_Executive_Director') {
                userName = 'QUT_Executive_Director';
                profileName = 'QUTeX';
                roleName = 'QUTeX Leadership';
                permSets = 'QUTeX_Base,QUTeX_CCE,QUTeX_Leader,Marketing,DocuSign_Generator,DocuSign_Negotiator,DocuSign_Sender,DocuSign_User,Permission_API_Enabled';
                publicGroups = '';
                isServiceCloudUser = true;
                isFlowUser = true;
                isKnowledgeUser = false;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            } else if (name == 'QUT_Business_Manager') {
                userName = 'QUT_Business_Manager';
                profileName = 'QUTeX';
                roleName = 'QUTeX Leadership';
                permSets = 'QUTeX_Base,QUTeX_CCE,QUTeX_Leader,DocuSign_Generator,DocuSign_Negotiator,DocuSign_Sender,DocuSign_User,Permission_API_Enabled';
                publicGroups = '';
                isServiceCloudUser = true;
                isFlowUser = true;
                isKnowledgeUser = false;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            } else if (name == 'QUT_OPE_Director') {
                userName = 'QUT_OPE_Director';
                profileName = 'QUTeX';
                roleName = 'QUTeX Super User';
                permSets = 'QUTeX_Base,QUTeX_CCE,QUTeX_Leader,DocuSign_Generator,DocuSign_Negotiator,DocuSign_Sender,DocuSign_User,Permission_API_Enabled';
                publicGroups = '';
                isServiceCloudUser = true;
                isFlowUser = true;
                isKnowledgeUser = false;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            } else if (name == 'QUT_Portfolio_Coordinator') {
                userName = 'QUT_Portfolio_Coordinator';
                profileName = 'QUTeX';
                roleName = 'QUTeX Super User';
                permSets = 'QUTeX_Base,QUTeX_CCE,QUTeX_Leader';
                publicGroups = '';
                isServiceCloudUser = true;
                isFlowUser = true;
                isKnowledgeUser = false;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            } else if (name == 'QUT_Product_Admin') {
                userName = 'QUT_Product_Admin';
                profileName = 'QUTeX';
                roleName = 'QUTeX User';
                permSets = 'QUTeX_Base,QUTeX_CCE,QUTeX_Leader';
                publicGroups = '';
                isServiceCloudUser = true;
                isFlowUser = true;
                isKnowledgeUser = false;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            } else if (name == 'QUT_Learning_Innovation_Manager') {
                userName = 'QUT_Learning_Innovation_Manager';
                profileName = 'QUTeX';
                roleName = 'QUTeX User';
                permSets = 'QUTeX_Base,QUTeX_CCE,QUTeX_Leader';
                publicGroups = '';
                isServiceCloudUser = true;
                isFlowUser = true;
                isKnowledgeUser = false;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            } else if (name == 'QUT_Learning_Designer') {
                userName = 'QUT_Learning_Designer';
                profileName = 'QUTeX';
                roleName = 'QUTeX User';
                permSets = 'QUTeX_Base,QUTeX_CCE,QUTeX_Leader,Product_Administration';
                publicGroups = '';
                isServiceCloudUser = true;
                isFlowUser = true;
                isKnowledgeUser = false;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            } else if (name == 'QUT_Partnership_Manager') {
                userName = 'QUT_Partnership_Manager';
                profileName = 'QUTeX';
                roleName = 'QUTeX Super User';
                //TODO: Add Product_Administration permset when approved in Onboarding Guide
                permSets = 'QUTeX_Base,QUTeX_CCE,QUTeX_Leader,DocuSign_Generator,DocuSign_Negotiator,DocuSign_Sender,DocuSign_User,Permission_API_Enabled';
                publicGroups = '';
                isServiceCloudUser = true;
                isFlowUser = true;
                isKnowledgeUser = false;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            } else if (name == 'QUT_Program_Coordinator') {
                userName = 'QUT_Program_Coordinator';
                profileName = 'QUTeX';
                roleName = 'QUTeX User';
                permSets = 'QUTeX_Base,QUTeX_CCE';
                publicGroups = '';
                isServiceCloudUser = true;
                isFlowUser = true;
                isKnowledgeUser = false;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            } else if (name == 'QUT_Program_Administrator') {
                userName = 'QUT_Program_Administrator';
                profileName = 'QUTeX';
                roleName = 'QUTeX Super User';
                permSets = 'QUTeX_Base,QUTeX_CCE,QUTeX_Leader,Product_Administration,DocuSign_Generator,DocuSign_Negotiator,DocuSign_Sender,DocuSign_User,Permission_API_Enabled';
                publicGroups = 'CCE Product Design,OPE Product Design';
                isServiceCloudUser = true;
                isFlowUser = true;
                isKnowledgeUser = false;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            } else if (name == 'QUT_IE_Partnership_Manager') {
                userName = 'QUT_IE_Partnership_Manager';
                profileName = 'Industry Engagement';
                roleName = 'Partnership Manager';
                permSets = 'Office_of_Industry_Engagement_Base';
                publicGroups = 'Research Partnership Manager,IPU Partnership Manager,Commercialisation Partnership Manager';
                isServiceCloudUser = true;
                isFlowUser = true;
                isKnowledgeUser = false;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            } else if (name == 'QUT_Operations_Manager') {
                userName = 'QUT_Operations_Manager';
                profileName = 'Industry Engagement';
                roleName = 'Operations Manager';
                permSets = 'Office_of_Industry_Engagement_Base';
                publicGroups = 'Research Operations Manager,IPU Operations Manager,Commercialisation Operations Manager';
                isServiceCloudUser = true;
                isFlowUser = true;
                isKnowledgeUser = false;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            } else if (name == 'QUT_Domestic_Future_Student_Agent') {
                userName = 'QUT_Domestic_Future_Student_Agent';
                profileName = 'Future Student Engagement';
                roleName = 'Future Student Agent - Domestic';
                permSets = 'Future_Student_Engagement,Run_Reports_and_Dashboards,Lightning_Scheduler_Administrator_V2,Lightning_Scheduler_User_V2,Future_Student_Domestic_Email_Access';
                publicGroups = 'Future Students - Domestic';
                isServiceCloudUser = true;
                isFlowUser = true;
                isKnowledgeUser = true;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            }else if (name == 'QUT_International_Future_Student_Agent') {
                userName = 'QUT_International_Future_Student_Agent';
                profileName = 'Future Student Engagement';
                roleName = 'Future Student Agent - International';
                permSets = 'Future_Student_Engagement,Run_Reports_and_Dashboards,Lightning_Scheduler_Administrator_V2,Lightning_Scheduler_User_V2,Future_Student_International_Email_Access,                Einstein_Service_AI_User,Google_Integration_User,Internal_User_Base,Knowledge_User';
                //,force__CopilotSalesforceUser,force__EinsteinAgent,force__EinsteinGPTPromptTemplateUser,force__HighVelocitySalesUserIncluded,spr_sf__Sprinklr_User
                publicGroups = 'Future Students - International';
                isServiceCloudUser = true;
                isFlowUser = true;
                isKnowledgeUser = true;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            }else if(name == 'QUT_Advancement_Manager'){
                userName = 'QUT_Advancement_Manager';
                profileName = 'Advancement';
                roleName = 'Advancement Manager';
                permSets = 'Advancement_Base';
                publicGroups = 'Advancement Manager';
                isServiceCloudUser = false;
                isFlowUser = true;
                isKnowledgeUser = false;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            }else if(name == 'QUT_Donor_Engagement_Manager'){
                userName = 'QUT_Donor_Engagement_Manager';
                profileName = 'Advancement';
                roleName = 'Donor Engagement Manager';
                permSets = 'Advancement_Base';
                publicGroups = 'Donor Engagement Manager';
                isServiceCloudUser = false;
                isFlowUser = true;
                isKnowledgeUser = false;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            }
            /** START - Creation of  Alumni and Corporate Engagement Manager Users */
            else if (name == 'QUT_Alumni_Engagement_Manager') {
                userName = 'QUT_Alumni_Engagement_Manager';
                profileName = 'Alumni & Corporate Partnerships';
                roleName = 'Alumni Engagement';
                permSets = 'Alumni_Corporate_Partnership_Base';
                isServiceCloudUser = true;
                isFlowUser = true;
                isKnowledgeUser = true;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            }else if (name == 'QUT_Corporate_Engagement_Manager') {
                userName = 'QUT_Corporate_Engagement_Manager';
                profileName = 'Alumni & Corporate Partnerships';
                roleName = 'Corporate Engagement';
                permSets = 'Alumni_Corporate_Partnership_Base';
                isServiceCloudUser = true;
                isFlowUser = true;
                isKnowledgeUser = true;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            }
            /** START - Creation of  Marketing Users */
            else if (name == 'QUT_Marketing_Manager') {
                userName = 'QUT_Marketing_Manager';
                profileName = 'Digital Marketing';
                roleName = 'Marketing Super User';
                permSets = 'Marketing';
                publicGroups = '';
                isServiceCloudUser = true;
                isFlowUser = true;
                isKnowledgeUser = false;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            } else if (name == 'QUT_Quality_Assurance') {
                userName = 'QUT_Quality_Assurance';
                profileName = 'QUTeX';
                roleName = 'Marketing User';
                permSets = 'QUTeX_Base,QUTeX_CCE,Marketing';
                publicGroups = '';
                isServiceCloudUser = true;
                isFlowUser = true;
                isKnowledgeUser = false;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            } else if (name == 'QUT_Digital_Marketing_Officer') {
                userName = 'QUT_Digital_Marketing_Officer';
                profileName = 'Digital Marketing';
                roleName = 'Marketing User';
                permSets = 'Marketing';
                publicGroups = '';
                isServiceCloudUser = true;
                isFlowUser = true;
                isKnowledgeUser = false;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            } else if (name == 'QUT_Digital_Communication_Officer') {
                userName = 'QUT_Digital_Communication_Officer';
                profileName = 'QUTeX';
                roleName = 'Marketing User';
                permSets = 'QUTeX_Base,QUTeX_CCE,Marketing';
                publicGroups = '';
                isServiceCloudUser = true;
                isFlowUser = true;
                isKnowledgeUser = false;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            }
            /**Start of Creation of ISR - International Student Recruitment Users */
            else if (name == 'QUT_ISR_Communications_Manager') {
                userName = 'QUT_ISR_Communications_Manager';
                profileName = 'International Student Recruitment';
                roleName = 'International Super User';
                permSets = 'Enquiry_Management_Base,Email_Template_Management,Manage_Reports_and_Dashboards,Live_Chat_Supervisor';
                publicGroups = '';
                isServiceCloudUser = true;
                isFlowUser = true;
                isKnowledgeUser = false;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            } else if (name == 'QUT_ISR_Student_Enquiries_Communications_Officer') {
                userName = 'QUT_ISR_Student_Enquiries_Communications_Officer';
                profileName = 'International Student Recruitment';
                roleName = 'International Super User';
                permSets = 'Enquiry_Management_Base,Email_Template_Management,Run_Reports_and_Dashboards,Live_Chat_Agent';
                publicGroups = '';
                isServiceCloudUser = true;
                isFlowUser = true;
                isKnowledgeUser = false;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            } else if (name == 'QUT_ISR_Student_Adviser') {
                userName = 'QUT_ISR_Student_Adviser';
                profileName = 'International Student Recruitment';
                roleName = 'International User';
                permSets = 'Enquiry_Management_Base,Run_Reports_and_Dashboards,Live_Chat_Agent';
                publicGroups = '';
                isServiceCloudUser = true;
                isFlowUser = true;
                isKnowledgeUser = false;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            }
            else if (name == 'QUT_Corporate_Partnership_Manager') {
                userName = 'QUT_Corporate_Partnership_Manager';
                profileName = 'Alumni & Corporate Partnerships';
                roleName = 'Corporate Partnerships';
                permSets = 'Alumni_Corporate_Partnership_Base';
                publicGroups = '';
                isServiceCloudUser = true;
                isFlowUser = true;
                isKnowledgeUser = false;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            }
            else if (name == 'Alumni_Engagement_Manager') {
                userName = 'Alumni_Engagement_Manager';
                profileName = 'Alumni & Corporate Partnerships';
                roleName = 'Corporate Partnerships';
                permSets = 'Alumni_Corporate_Partnership_Base';
                publicGroups = '';
                isServiceCloudUser = true;
                isFlowUser = true;
                isKnowledgeUser = false;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            }
            /** START - Creation of  Student Success Users : DEPP-8078 (Persona Guide for IT4) */
            else if (name == 'QUT_Student_Success_Outreach_Manager') {
                userName = 'QUT_Student_Success_Outreach_Manager';
                profileName = 'Student Success';
                roleName = 'Student Success Outreach Manager';
                permSets = 'Student_Success_Base,Student_Success_Super_User';
                publicGroups = 'Student Success Outreach Manager';
                isServiceCloudUser = true;
                isFlowUser = true;
                isKnowledgeUser = true;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = false;
                contactId = null;
            }
        }

        private UserAttributeClass(String name, Id conId) {
            if (name == 'QUT_Corporate_Partner_Admin') {
                userName = 'QUT_Corporate_Partner_Admin';
                profileName = 'Corporate Partner';
                roleName = '';
                permSets = 'Corporate_Partner';
                publicGroups = '';
                isServiceCloudUser = false;
                isFlowUser = false;
                isKnowledgeUser = false;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = true;
                contactId = conId;
            } else if (name == 'QUT_Corporate_Partner_User') {
                userName = 'QUT_Corporate_Partner_User';
                profileName = 'Corporate Partner';
                roleName = '';
                permSets = 'Corporate_Partner';
                publicGroups = '';
                isServiceCloudUser = false;
                isFlowUser = false;
                isKnowledgeUser = false;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = true;
                contactId = conId;
            } else if (name == 'QUT_OPE_Catalogue') {
                userName = 'QUT_OPE_Catalogue';
                profileName = 'OPE Catalogue';
                roleName = 'OPECatalogueCustomerUser';
                permSets = 'OPE_Catalogue';
                publicGroups = '';
                isServiceCloudUser = false;
                isFlowUser = false;
                isKnowledgeUser = false;
                isMarketingUser = false;
                isAppExchangeAdmin = false;
                isAppExchangeUser = false;
                isPortal = true;
                contactId = conId;
            }
        }
    }

    /**
     * @description Method for creating test Opportunity records
     * @return opp - Opportunity created
     */
    public static List<Opportunity> createOpportunityRecords(
        Integer numOfRecords,
        String name,
        String stage
    ) {
        List<Opportunity> opportunityList = new List<Opportunity>();
        for (Integer i = 0; i < numOfRecords; i++) {
            opportunityList.add(
                new Opportunity(
                    Name = name + '  ' + i,
                    StageName = stage,
                    CloseDate = System.today() + 30
                )
            );
        }
        return opportunityList;
    }
    /**
     * @description Method for creating test Opportunity Outcome records
     * @return oppOutcomes - List of Opportunity Outcomes created
     */
    public static List<Opportunity_Outcome__c> createOpportunityOutcome(
        Integer numOfOppOutcome,
        Id recordTypeId,
        Id opportunityID
    ) {
        String companyName = 'Test Company';
        String code = 'OO';
        String projectName = 'Test Project';
        List<Opportunity_Outcome__c> oppOutcomes = new List<Opportunity_Outcome__c>();

        for (Integer i = 0; i < numOfOppOutcome; i++) {
            oppOutcomes.add(
                new Opportunity_Outcome__c(
                    Company_Name__c = companyName + '  ' + i,
                    Code__c = code,
                    Opportunity__c = opportunityID,
                    Project_Name__c = projectName + ' ' + i,
                    Stage_Name__c = 'New',
                    Start_Date__c = System.today() + 10,
                    End_Date__c = System.today() + 60,
                    RecordTypeId = recordTypeId
                )
            );
        }
        return oppOutcomes;
    }


    /**
     * Generate a list of milestone records based on the amount of records needed,
     * the general name to be used, and record type
     */
    public static List<Milestone__c> createTestMileStoneRecords(
        Integer size,
        Id opportunityOutcome,
        String milestoneType
    ) {
        List<Milestone__c> milestones = new List<Milestone__c>();
        for (Integer i = 1; i <= size; i++) {
            milestones.add(
                new milestone__c(
                    Milestone_Type__c = milestoneType,
                    Start_Date__c = System.today(),
                    End_Date__c = System.today() + 5,
                    Opportunity_Outcome__c = opportunityOutcome
                )
            );
        }
        return milestones;
    }

    /**
     * Generate a list of risk records based on the amount of records needed,
     * the general name to be used, and record type
     */
    public static List<Risk__c> createTestRiskRecords(
        Integer size,
        Id opportunityOutcome,
        String riskType
    ) {
        List<Risk__c> risks = new List<Risk__c>();
        for (Integer i = 1; i <= size; i++) {
            risks.add(
                new Risk__c(
                    Risk_Title__c = 'Sample Risk ' + i,
                    Risk_Description__c = 'Sample Risk Description ' + i,
                    Risk_Type__c = riskType,
                    Risk_Status__c = 'Active',
                    Severity__c = 'Medium',
                    Mitigated__c = 'Yes',
                    Opportunity_Outcome__c = opportunityOutcome
                )
            );
        }
        return risks;
    }

    /**
     * Generate a list of expense records based on the amount of records needed,
     * the general name to be used, opportunity outcome and expense type
     */
    public static List<Expense__c> createTestExpenseRecords(
        Integer size,
        Id opportunityOutcome,
        String expenseType
    ) {
        List<Expense__c> expenses = new List<Expense__c>();
        for (Integer i = 1; i <= size; i++) {
            expenses.add(
                new Expense__c(
                    Expense_Amount__c = i + 100,
                    Expense_Type__c = expenseType,
                    Opportunity_Outcome__c = opportunityOutcome
                )
            );
        }
        return expenses;
    }

    /**
     * @description Method for creating test Contextual Role records related to
     * provided opportunity
     * @return conRoles - List of Contextual Roles created
     */
    public static List<Contextual_Role__c> createContextualRolesForOpportunity(
        Integer numOfConRoles,
        Id recordTypeId,
        Id opportunityId,
        Id accountId,
        String conRoleGroup
    ) {
        List<Contextual_Role__c> conRoles = new List<Contextual_Role__c>();

        for (Integer i = 0; i < numOfConRoles; i++) {
            conRoles.add(
                new Contextual_Role__c(
                    RecordTypeId = recordTypeId,
                    Opportunity__c = opportunityId,
                    Account__c = accountId,
                    Contextual_Role_Group__c = conRoleGroup
                )
            );
        }
        return conRoles;
    }

     /**
     * @description Method for creating test IP Management Record
     * @return ipManagements - List of IP Management created
     */
    public static List<IP_Management__c> createIPManagement(
        Integer numOfIPManagement,
        Id recordTypeId
    ) {
        List<IP_Management__c> ipManagements = new List<IP_Management__c>();

        for (Integer i = 0; i < numOfIPManagement; i++) {
            ipManagements.add(
                new IP_Management__c(
                    IP_Name__c = 'testIpManagement' ,
                    IP_Description__c ='test IP Desc',
                    Stage_Name__c = 'Prosecution',
                    Granted_Date__c =  System.today(),
                    Lapsed_Date__c = System.today() + 5,
                    Rejected_Date__c = System.today() + 10,
                    RecordTypeId = recordTypeId
                )
            );
        }
        return ipManagements;
    }

    /**
     * @description Method for creating IP Management Relationship records
     * @param numRelationships Number of IP Management Relationship records to create
     * @param opptyId ID of the related Opportunity
     * @param ipManagementId ID of the related IP Management
     * @param recordTypeId ID of the Record Type for IP Management Relationship
     * @return relationships List of IP Management Relationship records
     */
    public static List<IP_Management_Relationship__c> createIPManagementRelationships(
        Integer numRelationships,
        Id opptyId,
        Id ipManagementId,
        Id recordTypeId
    ) {
        List<IP_Management_Relationship__c> relationships = new List<IP_Management_Relationship__c>();

        for (Integer i = 0; i < numRelationships; i++) {
            relationships.add(
                new IP_Management_Relationship__c(
                    Opportunity__c = opptyId,
                    IP_Management__c = ipManagementId,
                    RecordTypeId = recordTypeId,
                    Is_Active__c = true
                )
            );
        }

        return relationships;
    }

    /**
     * @description Method for creating IP Management Relationship records for Opportunity Outcome
     * @param numRelationships Number of IP Management Relationship records to create
     * @param opptyOutomeId ID of the related Opportunity
     * @param ipManagementId ID of the related IP Management
     * @param recordTypeId ID of the Record Type for IP Management Relationship
     * @return relationships List of IP Management Relationship records
     */
    public static List<IP_Management_Relationship__c> createIPManagementRelationshipsForOpportunityOutcome(
        Integer numRelationships,
        Id opptyOutomeId,
        Id ipManagementId,
        Id recordTypeId
    ) {
        List<IP_Management_Relationship__c> relationships = new List<IP_Management_Relationship__c>();
        for (Integer i = 0; i < numRelationships; i++) {
            relationships.add(
                new IP_Management_Relationship__c(
                    Opportunity_Outcome__c = opptyOutomeId,
                    IP_Management__c = ipManagementId,
                    RecordTypeId = recordTypeId,
                    Is_Active__c = true
                )
            );
        }
        return relationships;
    }

    /**
     * @description Method for creating Document Record for IP Management
     * @return documents - List of Documents Created
     */
    public static List<Document__c> createDocumentsForIPManagement(
        Integer numOfDocuments,
        Id ipManagementId,
        Id recordTypeId
    ) {
        List<Document__c> documents = new List<Document__c>();

        for (Integer i = 0; i < numOfDocuments; i++) {
            documents.add(
                new Document__c(
                    Document_Title__c = 'test Document Title' ,
                    Document_Type__c = 'Subscription',
                    Document_Status__c = 'Complete',
                    Document_URL__c = 'https://www.test.com',
                    IP_Management__c = ipManagementId,
                    RecordTypeId = recordTypeId
                )
            );
        }
        return documents;
    }

    /**
     * @description Method for creating test Financeial Summary records
     * @return finSummaries - List of Finance Summaries created
     */
    public static List<Finance_Summary__c> createFinanceSummaryRecords(
        Integer numOfFinanceSummaries,
        Id recordTypeId,
        Id oppOutcomeId
    ) {
        List<Finance_Summary__c> finSummaries = new List<Finance_Summary__c>();

        for (Integer i = 0; i < numOfFinanceSummaries; i++) {
            finSummaries.add(
                new Finance_Summary__c(
                    RecordTypeId = recordTypeId,
                    Opportunity_Outcome__c = oppOutcomeId,
                    Year__c = String.valueOf(System.Today().year()),
                    Valuation_Amount__c = 123
                )
            );
        }
        return finSummaries;
    }

    /**
     * @description Method for creating test Financeial GL Account records
     * @return financeGlAccts - List of Finance GL Account created
     */
    public static List<Finance_GL_Account__c> createTestFinanceGLAccountRecords(
        Integer numFinanceGlAccts,
        Boolean isActive
    ) {
        List<Finance_GL_Account__c> financeGlAccts = new List<Finance_GL_Account__c>();

        for (Integer i = 0; i < numFinanceGlAccts; i++) {
            financeGlAccts.add(
                new Finance_GL_Account__c(
                    Name = 'Test' + i,
                    Account_Code__c = 1230 + i,
                    Activity_Code__c = 10 + i,
                    Campus_Code__c = 1 + i,
                    Entity_Code__c = 1 + i,
                    GL_Account_Code__c = String.valueOf(123450 + i),
                    Project_Code__c = 1230 + i,
                    Responsibility_Centre_Code__c =  123450 + i,
                    Type_Code__c = 1 + i,
                    Is_Active__c = isActive
                )
            );
        }
        return financeGlAccts;
    }

    /**
     * @description Method for creating test Distribution Split records
     * @return distributionSplits - List of Finance GL Account created
     */
    public static List<Distribution_Split__c> createTestDistributionSplitRecords(
        Integer numDistributionSplits,
        Id distributionManagementId,
        Id financeGlAcct
    ) {
        List<Distribution_Split__c> distributionSplits = new List<Distribution_Split__c>();

        for (Integer i = 0; i < numDistributionSplits; i++) {
            distributionSplits.add(
                new Distribution_Split__c(
                    Distribution_Management__c = distributionManagementId,
                    Finance_GL_Account__c = financeGlAcct,
                    Participating_Group__c = 'Test' + i,
                    Percentage_Split__c = 10 + i
                )
            );
        }
        return distributionSplits;
    }

    /**
     * @description Method for creating test Relationship Manager records
     * @return relationshipManagers - List of  Relationship Managers created
     */
    public static List<Relationship_Manager__c> createRelationshipManagerWithAccountLookup(
        Integer numOfRelationshipManagers,
        Id recordTypeId,
        Id accountBusinessOrgId,
        Id userId
    ) {
        List<Relationship_Manager__c> relationshipManagers = new List<Relationship_Manager__c>();

        for (Integer i = 0; i < numOfRelationshipManagers; i++) {
            relationshipManagers.add(
                new Relationship_Manager__c(
                    RecordTypeId = recordTypeId,
                    Account__c = accountBusinessOrgId,
                    Relationship_Manager_Type__c = 'Advancement',
                    Primary_QUT_Contact__c = userId,
                    Is_Active__c = true
                )
            );
        }
        return relationshipManagers;
    }

    /**
     * @description Method for creating AccountShare
     * @param accountsToShare - List of Account records to share
     * @param shareToUserOrGroupId - The user or group you want to share the Account records to
     * @param accountAccessLevel - The access level for the Account records to be shared (Edit, Read)
     * @return accShares - List of AccountShares created
     */
    public static List<AccountShare> createAccountShareRecords(
        List<Account> accountsToShare,
        Id shareToUserOrGroupId,
        String accountAccessLevel
    ){
        List<AccountShare> accShares = new List<AccountShare>();

        for (Account acc : accountsToShare){
            AccountShare share = new AccountShare();
            share.AccountId = acc.Id;
            share.UserOrGroupId = shareToUserOrGroupId;
            share.AccountAccessLevel = accountAccessLevel;
            share.OpportunityAccessLevel = 'Read';
            accShares.add(share);
        }
        
        return accShares;
    }

    /**
     * @description Method for creating test Nurture Track Config records
     * @return List<Nurture_Track_Configuration__c> nurtureList - List of Nurture Track Config
     */
    public static List<Nurture_Track_Configuration__c> createNurtureTrackConfigRecords(Integer numberOfRecordsToCreate) {
        List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();

        for (Integer i=0; i<numberOfRecordsToCreate; i++) {
            nurtureList.add(new Nurture_Track_Configuration__c(Status__c = 'Active'));
        }

        return nurtureList;
    }

     /**
     * @description Method for creating test Application records
     * @return List<hed__Application__c> applicationList - List of Application Records
     */
    public static List<hed__Application__c> createApplicationRecords(Id contactId, Id recordTypeId, Integer numberOfRecordsToCreate) {
        List<hed__Application__c> applicationList = new List<hed__Application__c>();
        for (Integer i=0; i<numberOfRecordsToCreate; i++) {
            applicationList.add(new hed__Application__c(
                hed__Applicant__c = contactId,
                RecordTypeId = recordTypeId,
                Is_Active__c = true,
                Intake_Year__c = String.valueOf(System.Today().year())
            ));
        }
        return applicationList;
    }
    /**
     * @description Method for creating test Application Preference records
     * @return List<Application_Preference__c> applicationList - List of Application Records
     */
    public static List<Application_Preference__c> createApplicationPreferenceRecords(Id applicationId, Id recordTypeId, Integer numberOfRecordsToCreate) {
        List<Application_Preference__c> applicationPreferenceList = new List<Application_Preference__c>();
        Integer randomNumber = Integer.valueof((Math.random() * 11));   // Generate random number for months
        for (Integer i= 0; i < numberOfRecordsToCreate; i++) {
            applicationPreferenceList.add(new Application_Preference__c(
                Program_Name__c = 'App Pref ' + (i + 1),
                Application__c = applicationId,
                RecordTypeId = recordTypeId,
                Preference_Number__c = i + 1,
                Starting_Month__c = randomNumber + 1
            ));
        }
        return applicationPreferenceList;
    }
    /**
     * @description Method for creating test Package Component records
     * @return List<Package_Component__c> packageComponentList - List of Package Component Records
     */
    public static List<Package_Component__c> createPackageComponentRecords(Id applicationPrefId, Date startDate, Integer numberOfRecordsToCreate) {
        List<Package_Component__c> packageComponentList = new List<Package_Component__c>();
        for (Integer i= 0; i < numberOfRecordsToCreate; i++) {
            packageComponentList.add(new Package_Component__c(
                Application_Preference__c  = applicationPrefId,
                Package_Component_No__c = i + 1,
                Start_Date__c = startDate
            ));
        }
        return packageComponentList;
    }

    
    /**
     * @description Method for creating test Plan Activity records
     * @params
     * numOfPlanActivites - number of records to create
     * oppOd - Id of the Opportunity the Plan Activity record will be related to
     * @return planActivities - List of Plan Activity records created
     */
    public static List<Plan_Activity__c> createPlanActivityRecords(
        Integer numOfPlanActivities,
        Id opptyId
    ) {
        List<Plan_Activity__c> planActivities = new List<Plan_Activity__c>();
        for (Integer i = 0; i < numOfPlanActivities; i++) {
            planActivities.add(
                new Plan_Activity__c(
                    Status__c = 'Pending',
                    Outcome__c = 'Test Outcome',
                    Contact_Channel__c = 'Email',
                    Description__c = 'Test Description'
                )
            );
        }
        return planActivities;
    }

    /**
     * @description Method for creating test Plan Activity records
     * @params
     * numOfPlanActivites - number of records to create
     * stewardshipId - Id of the stewardship the Plan Activity record will be related to
     * @return planActivities - List of Plan Activity records created
     */
    public static List<Plan_Activity__c> createPlanActivityRecordsWithStewardship(
        Integer numOfPlanActivities,
        Id stewardshipId
    ) {
        List<Plan_Activity__c> planActivities = new List<Plan_Activity__c>();
        for (Integer i = 0; i < numOfPlanActivities; i++) {
            planActivities.add(
                new Plan_Activity__c(
                    Status__c = 'Pending',
                    Outcome__c = 'Test Outcome ' + i,
                    Contact_Channel__c = 'Email',
                    Description__c = 'Test Description',
                    Stewardship__c = stewardshipId
                )
            );
        }
        return planActivities;
    }

    /**
     * @description Method for creating test Lead Score Configuration records
     * @return List<Lead_Score_Configuration__c> leadScoreConfigurationList - List of Lead Score Configuration Records
     */
    public static List<Lead_Score_Configuration__c> createLeadScoreConfigurationRecords(Id parentCategoryId, Id recordTypeId, Integer numberOfRecordsToCreate) {
        List<Lead_Score_Configuration__c> leadScoreConfigurationList = new List<Lead_Score_Configuration__c>();
        for (Integer i= 0; i < numberOfRecordsToCreate; i++) {
            leadScoreConfigurationList.add(new Lead_Score_Configuration__c(
                Name = 'Test LSC ' + (i + 1),
                Parent_Category__c  = parentCategoryId,
                RecordTypeId = recordTypeId,
                Max_Score__c = i + 1
            ));
        }
        return leadScoreConfigurationList;
    }
    /**
     * @description Method for creating test Marketing Interaction records
     * @return List<Marketing_Interaction__c> leadScoreConfigurationList - List of Lead Score Configuration Records
     */
    public static List<Marketing_Interaction__c> createMarketingInteractionRecords(Id contactId, Integer numberOfRecordsToCreate, String leadSource) {
        List<Marketing_Interaction__c> marketingInteractionList = new List<Marketing_Interaction__c>();
        for(Integer i= 0; i < numberOfRecordsToCreate; i++) {
            marketingInteractionList.add(new Marketing_Interaction__c(
                Contact__c = contactId, 
                Lead_Source__c = leadSource
            ));
        }
        return marketingInteractionList;
    }

    public static List<Lead_Score_Configuration__c> createCategoryLeadScoreConfigurations(){
        List<Lead_Score_Configuration__c> leadScoreConfigList = new List<Lead_Score_Configuration__c>();

        leadScoreConfigList.add(new Lead_Score_Configuration__c(
            Name = 'Event Registration and Attendance',
            RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
            Domestic_International__c = 'Domestic',
            Study_Level__c = 'Undergraduate',
            Description__c = '',
            Score_Allocation__c = null,
            Time_Limit_Months__c = 18,
            Max_Score__c = 30
        ));
        leadScoreConfigList.add(new Lead_Score_Configuration__c(
            Name = 'Event Registration and Attendance',
            RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
            Domestic_International__c = 'Domestic',
            Study_Level__c = 'Postgraduate',
            Description__c = '',
            Score_Allocation__c = null,
            Time_Limit_Months__c = 18,
            Max_Score__c = 30
        ));
        leadScoreConfigList.add(new Lead_Score_Configuration__c(
            Name = 'Event Registration and Attendance',
            RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
            Domestic_International__c = 'International',
            Study_Level__c = 'Postgraduate',
            Description__c = '',
            Score_Allocation__c = null,
            Time_Limit_Months__c = 36,
            Max_Score__c = 30
        ));
        leadScoreConfigList.add(new Lead_Score_Configuration__c(
            Name = 'Event Registration and Attendance',
            RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
            Domestic_International__c = 'International',
            Study_Level__c = 'Undergraduate',
            Description__c = '',
            Score_Allocation__c = null,
            Time_Limit_Months__c = 36,
            Max_Score__c = 30
        ));
        leadScoreConfigList.add(new Lead_Score_Configuration__c(
            Name = 'Event Registration and Attendance',
            RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
            Domestic_International__c = 'Undetermined',
            Study_Level__c = 'Undetermined',
            Description__c = '',
            Score_Allocation__c = null,
            Time_Limit_Months__c = 36,
            Max_Score__c = 30
        ));
        leadScoreConfigList.add(new Lead_Score_Configuration__c(
            Name = 'Event Registration and Attendance',
            RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
            Domestic_International__c = 'Domestic',
            Study_Level__c = 'Undetermined',
            Description__c = '',
            Score_Allocation__c = null,
            Time_Limit_Months__c = 36,
            Max_Score__c = 30
        ));
        leadScoreConfigList.add(new Lead_Score_Configuration__c(
            Name = 'Event Registration and Attendance',
            RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
            Domestic_International__c = 'International',
            Study_Level__c = 'Undetermined',
            Description__c = '',
            Score_Allocation__c = null,
            Time_Limit_Months__c = 36,
            Max_Score__c = 30
        ));
        leadScoreConfigList.add(new Lead_Score_Configuration__c(
            Name = 'Residence',
            RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
            Domestic_International__c = 'International',
            Study_Level__c = 'Postgraduate',
            Description__c = '',
            Score_Allocation__c = null,
            Time_Limit_Months__c = null,
            Max_Score__c = 10
        ));
        leadScoreConfigList.add(new Lead_Score_Configuration__c(
            Name = 'Residence',
            RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
            Domestic_International__c = 'International',
            Study_Level__c = 'Undergraduate',
            Description__c = '',
            Score_Allocation__c = null,
            Time_Limit_Months__c = null,
            Max_Score__c = 10
        ));
        leadScoreConfigList.add(new Lead_Score_Configuration__c(
            Name = 'Residence',
            RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
            Domestic_International__c = 'Undetermined',
            Study_Level__c = 'Undetermined',
            Description__c = '',
            Score_Allocation__c = null,
            Time_Limit_Months__c = null,
            Max_Score__c = 10
        ));
        leadScoreConfigList.add(new Lead_Score_Configuration__c(
            Name = 'Residence',
            RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY,
            Domestic_International__c = 'International',
            Study_Level__c = 'Undetermined',
            Description__c = '',
            Score_Allocation__c = null,
            Time_Limit_Months__c = null,
            Max_Score__c = 10
        ));
        return leadScoreConfigList;
    }


    public static List<Lead_Score_Configuration__c> createInlAndPostGradSubCategory(Id parentCategory, List<String> categoryNamesList, List<Integer> scoreAllocationsList ){

        List<Lead_Score_Configuration__c> leadScoreConfigList = new List<Lead_Score_Configuration__c>();

        for(Integer i = 0;i<categoryNamesList.size();i++){
            leadScoreConfigList.add(new Lead_Score_Configuration__c(
                Name = categoryNamesList[i],
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY,
                Domestic_International__c = 'International',
                Study_Level__c = 'Postgraduate',
                Score_Allocation__c = scoreAllocationsList[i],
                Time_Limit_Months__c = null,
                Max_Score__c = null,
                Parent_Category__c = parentCategory
            ));
        }

        return leadScoreConfigList;
    }

    public static List<Lead_Score_Configuration__c> createDomstcAndPostGradSubCategory(Id parentCategory, List<String> categoryNamesList, List<Integer> scoreAllocationsList ){

        List<Lead_Score_Configuration__c> leadScoreConfigList = new List<Lead_Score_Configuration__c>();

        for(Integer i = 0;i<categoryNamesList.size();i++){
            leadScoreConfigList.add(new Lead_Score_Configuration__c(
                Name = categoryNamesList[i],
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY,
                Domestic_International__c = 'Domestic',
                Study_Level__c = 'Postgraduate',
                Score_Allocation__c = scoreAllocationsList[i],
                Time_Limit_Months__c = null,
                Max_Score__c = null,
                Parent_Category__c = parentCategory
            ));
        }

        return leadScoreConfigList;
    }

    public static List<Lead_Score_Configuration__c> createDomstcAndUnderGradSubCategory(Id parentCategory, List<String> categoryNamesList, List<Integer> scoreAllocationsList ){

        List<Lead_Score_Configuration__c> leadScoreConfigList = new List<Lead_Score_Configuration__c>();

        for(Integer i = 0;i<categoryNamesList.size();i++){
            leadScoreConfigList.add(new Lead_Score_Configuration__c(
                Name = categoryNamesList[i],
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY,
                Domestic_International__c = 'Domestic',
                Study_Level__c = 'Undergraduate',
                Score_Allocation__c = scoreAllocationsList[i],
                Time_Limit_Months__c = null,
                Max_Score__c = null,
                Parent_Category__c = parentCategory
            ));
        }

        return leadScoreConfigList;
    }

    public static List<Lead_Score_Configuration__c> createIntlAndUnderGradSubCategory(Id parentCategory, List<String> categoryNamesList, List<Integer> scoreAllocationsList ){

        List<Lead_Score_Configuration__c> leadScoreConfigList = new List<Lead_Score_Configuration__c>();

        for(Integer i = 0;i<categoryNamesList.size();i++){
            leadScoreConfigList.add(new Lead_Score_Configuration__c(
                Name = categoryNamesList[i],
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY,
                Domestic_International__c = 'International',
                Study_Level__c = 'Undergraduate',
                Score_Allocation__c = scoreAllocationsList[i],
                Time_Limit_Months__c = null,
                Max_Score__c = null,
                Parent_Category__c = parentCategory
            ));
        }

        return leadScoreConfigList;
    }

    public static List<Lead_Score_Configuration__c> createDomestcAndUndeterminedSubCategory(Id parentCategory, List<String> categoryNamesList, List<Integer> scoreAllocationsList ){

        List<Lead_Score_Configuration__c> leadScoreConfigList = new List<Lead_Score_Configuration__c>();

        for(Integer i = 0;i<categoryNamesList.size();i++){
            leadScoreConfigList.add(new Lead_Score_Configuration__c(
                Name = categoryNamesList[i],
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY,
                Domestic_International__c = 'Domestic',
                Study_Level__c = 'Undetermined',
                Score_Allocation__c = scoreAllocationsList[i],
                Time_Limit_Months__c = null,
                Max_Score__c = null,
                Parent_Category__c = parentCategory
            ));
        }

        return leadScoreConfigList;
    }

    public static List<Lead_Score_Configuration__c> createIntlAndUndeterminedSubCategory(Id parentCategory, List<String> categoryNamesList, List<Integer> scoreAllocationsList ){

        List<Lead_Score_Configuration__c> leadScoreConfigList = new List<Lead_Score_Configuration__c>();

        for(Integer i = 0;i<categoryNamesList.size();i++){
            leadScoreConfigList.add(new Lead_Score_Configuration__c(
                Name = categoryNamesList[i],
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY,
                Domestic_International__c = 'International',
                Study_Level__c = 'Undetermined',
                Score_Allocation__c = scoreAllocationsList[i],
                Time_Limit_Months__c = null,
                Max_Score__c = null,
                Parent_Category__c = parentCategory
            ));
        }

        return leadScoreConfigList;
    }

    public static List<Lead_Score_Configuration__c> createUndAndUndeterminedSubCategory(Id parentCategory, List<String> categoryNamesList, List<Integer> scoreAllocationsList ){

        List<Lead_Score_Configuration__c> leadScoreConfigList = new List<Lead_Score_Configuration__c>();

        for(Integer i = 0;i<categoryNamesList.size();i++){
            leadScoreConfigList.add(new Lead_Score_Configuration__c(
                Name = categoryNamesList[i],
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY,
                Domestic_International__c = 'Undetermined',
                Study_Level__c = 'Undetermined',
                Score_Allocation__c = scoreAllocationsList[i],
                Time_Limit_Months__c = null,
                Max_Score__c = null,
                Parent_Category__c = parentCategory
            ));
        }

        return leadScoreConfigList;
    }

    public static List<Lead_Score_Configuration__c> createIntlAndPostgradSubCategory(Id parentCategory, List<String> categoryNamesList, List<Integer> scoreAllocationsList ){

        List<Lead_Score_Configuration__c> leadScoreConfigList = new List<Lead_Score_Configuration__c>();

        for(Integer i = 0;i<categoryNamesList.size();i++){
            leadScoreConfigList.add(new Lead_Score_Configuration__c(
                Name = categoryNamesList[i],
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY,
                Domestic_International__c = 'International',
                Study_Level__c = 'Postgraduate',
                Score_Allocation__c = scoreAllocationsList[i],
                Time_Limit_Months__c = null,
                Max_Score__c = null,
                Parent_Category__c = parentCategory
            ));
        }

        return leadScoreConfigList;
    }

    public static List<Lead_Score_Configuration__c> createDomestcAndPostgradSubCategory(Id parentCategory, List<String> categoryNamesList, List<Integer> scoreAllocationsList ){

        List<Lead_Score_Configuration__c> leadScoreConfigList = new List<Lead_Score_Configuration__c>();

        for(Integer i = 0;i<categoryNamesList.size();i++){
            leadScoreConfigList.add(new Lead_Score_Configuration__c(
                Name = categoryNamesList[i],
                RecordTypeId = LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY,
                Domestic_International__c = 'Domestic',
                Study_Level__c = 'Postgraduate',
                Score_Allocation__c = scoreAllocationsList[i],
                Time_Limit_Months__c = null,
                Max_Score__c = null,
                Parent_Category__c = parentCategory
            ));
        }

        return leadScoreConfigList;
    }

    public static List<Case_Priority_Configuration__c> createCasePrioConfigRecords(){
        List<Case_Priority_Configuration__c> casePrioConfigList = new List<Case_Priority_Configuration__c>();
        casePrioConfigList.add(new Case_Priority_Configuration__c(
            Case_Record_Type__c = 'Inbound Enquiry',
            Future_Student_Stage__c = 'Apply',
            Lead_Source_Category__c = 'Partner Sourced',
            Is_Active__c = true,
            Priority__c = 'High',
            Case_Type__c = CasesDAO.CASE_TYPE_INTERNATIONAL
        ));
        casePrioConfigList.add(new Case_Priority_Configuration__c(
            Case_Record_Type__c = 'Inbound Enquiry',
            Enquiry_Category__c = 'Preparing to Study',
            Future_Student_Stage__c = 'Apply',
            Lead_Source_Category__c = 'Partner Sourced',
            Is_Active__c = true,
            Priority__c = 'High',
            Case_Type__c = CasesDAO.CASE_TYPE_INTERNATIONAL
        ));
        casePrioConfigList.add(new Case_Priority_Configuration__c(
            Case_Record_Type__c = 'Inbound Enquiry',
            Country_Tier__c = 'Tier 1',
            Is_Active__c = true,
            Lead_Score__c = 120,
            Priority__c = 'High',
            Case_Type__c = CasesDAO.CASE_TYPE_INTERNATIONAL
        ));
        casePrioConfigList.add(new Case_Priority_Configuration__c(
            Case_Record_Type__c = 'Inbound Enquiry',
            Country_Tier__c = 'Tier 2',
            Is_Active__c = true,
            Priority__c = 'Medium',
            Case_Type__c = CasesDAO.CASE_TYPE_INTERNATIONAL
        ));
        casePrioConfigList.add(new Case_Priority_Configuration__c(
            Case_Record_Type__c = 'Inbound Enquiry',
            Country_Tier__c = 'Tier 3',
            Is_Active__c = true,
            Priority__c = 'Medium',
            Case_Type__c = CasesDAO.CASE_TYPE_INTERNATIONAL
        ));
        casePrioConfigList.add(new Case_Priority_Configuration__c(
            Case_Record_Type__c = 'Inbound Enquiry',
            Future_Student_Stage__c = 'Offer',
            Lead_Source_Category__c = 'Partner Sourced',
            Is_Active__c = true,
            Priority__c = 'High',
            Case_Type__c = CasesDAO.CASE_TYPE_INTERNATIONAL
        ));
        casePrioConfigList.add(new Case_Priority_Configuration__c(
            Case_Record_Type__c = 'Inbound Enquiry',
            Enquiry_Sub_Category__c = 'Student support;Welcome and orientation events',
            Is_Active__c = true,
            Priority__c = 'Medium',
            Case_Type__c = CasesDAO.CASE_TYPE_INTERNATIONAL
        ));
        casePrioConfigList.add(new Case_Priority_Configuration__c(//this test data is always within range
            Case_Record_Type__c = 'Inbound Enquiry',
            Date_From__c =  Date.newInstance(2023, 01, 01),
            Date_To__c = System.today().addDays(1),
            Is_Active__c = true,
            Priority__c = 'High',
            Case_Type__c = CasesDAO.CASE_TYPE_INTERNATIONAL
        ));
        casePrioConfigList.add(new Case_Priority_Configuration__c(
            Case_Record_Type__c = 'Inbound Enquiry',
            Country_Tier__c = 'Untiered',
            Country_Tier_Subcategory__c = 'Restricted',
            Is_Active__c = true,
            Priority__c = 'High',
            Enquiry_Category__c = 'Student Life',
            Case_Type__c = CasesDAO.CASE_TYPE_INTERNATIONAL
        ));
        casePrioConfigList.add(new Case_Priority_Configuration__c(
            Case_Record_Type__c = 'Inbound Enquiry',
            Is_Active__c = true,
            Priority__c = 'High',
            Enquiry_Category__c = 'Student Life',
            Lead_Source_Category__c = 'Partner Sourced',
            Case_Type__c = CasesDAO.CASE_TYPE_INTERNATIONAL
        ));
        return casePrioConfigList;
    }

    /**
     * @description Method for creating test Sprinklr case records. (Basically case records with Sprinklr case numbers.)
     * @param Id contactId - Contact id to associate the cases to.
     * @param Integer count - The amount of case records to create.
     * @return List<Case>
     */
    public static List<Case> createTestSprinklrCaseRecords(Integer count, Id contactId) {
        List<Case> sprinklrCases = new List<Case>();
        for(Integer i = 0; i < count; i++) {
            sprinklrCases.add(new Case(
                ContactId = contactId,
                spr_sf__Sprinklr_Case_Number__c = i
            ));
        }
        return sprinklrCases;
    }

    /**
     * @description Method for creating test Service Appointment records
     * @param numServiceAppointment - number of Service Appointment to be created
     * @return serviceApp - list of Service Appointment created
     */
    public static List<ServiceAppointment> createTestServiceAppointmentRecords(Integer numServiceAppointment, Id accountId) {
        List<ServiceAppointment> serviceApp = new List<ServiceAppointment>();

        for (Integer i = 0; i < numServiceAppointment; i++) {
            serviceApp.add(new ServiceAppointment(EarliestStartTime = System.Now(), DueDate = System.Now().addDays(10), ParentRecordId = accountId));
        }

        return serviceApp;
    }

    /** @description Method for creating test WorkType records
     * @return workTypes - list of WorkTypes created
     */
    public static List<WorkType> createTestWorkTypeRecords() {
        List<WorkType> newWorkTypes = new List<WorkType>();
        for (Integer i = 0; i < 2; i++) {
            newWorkTypes.add(
                new WorkType(
                    Name = 'Team',
                    EstimatedDuration = 5
                )
            );
        }
        newWorkTypes.get(0).Name = 'International Phone Calls';
        newWorkTypes.get(1).Name = 'Domestic Phone Calls';
        return newWorkTypes;
    }

    /**
     * @description Method for creating test Engagement Opportunity records
     * @param numEngagementOpp - number of Engagement Opportunity to be created
     * @return engagementOpp - list of Engagement Opportunity created
     */
    public static List<Engagement_Opportunity__c> createTestEngagementOpportunityRecords(Integer numEngagementOpp) {
        List<Engagement_Opportunity__c> engagementOpp = new List<Engagement_Opportunity__c>();

        for (Integer i = 0; i < numEngagementOpp; i++) {
            engagementOpp.add(new Engagement_Opportunity__c(Engagement_Opportunity_Type__c = 'Event', Score_Category__c = 'Research', Engagement_Opportunity_Name__c = i + 'Test Engagement Opp', Score_Subcategory__c = 'Adjunct Professors', Stage__c = 'New'));
        }

        return engagementOpp;
    }

    /**
     * @description Method for creating test Stewardship records
     * @params
     * numOfRecords - number of records to create
     * @return stewardshipList - List of Stewardship records created
     */
    public static List<Stewardship__c> createStewardshipRecords(
        Id recordTypeId,
        Integer numOfRecords
    ) {
        List<Stewardship__c> stewardshipList = new List<Stewardship__c>();
        for (Integer i = 0; i < numOfRecords; i++) {
            stewardshipList.add(
                new Stewardship__c(
                    Stage__c = 'Active',
                    Start_Date__c = System.today() + 30,
                    Completion_Summary__c = 'Test',
                    RecordTypeId = recordTypeId
                )
            );
        }
        return stewardshipList;
    }

    /**
     * @description Method for creating test Distribution Management records
     * @params
     * numOfRecords - number of records to create
     * status - status of the records to create
     * @return distributionManagementList - List of Distribution Management records created
     */
    public static List<Distribution_Management__c> createDistributionManagementRecords(
        Integer numOfRecords,
        String status
    ) {
        List<Distribution_Management__c> distributionManagementList = new List<Distribution_Management__c>();
        for (Integer i = 0; i < numOfRecords; i++) {
            distributionManagementList.add(
                new Distribution_Management__c(
                    Status__c = status,
                    Start_Date__c = System.Today()
                )
            );
        }
        return distributionManagementList;
    }

    /**
     * @description Method for creating test Donation records
     * @params
     * numOfRecords - number of records to create
     * recordTypeId - recordTypeId of the records to create
     * @return donationList - List of Donation records created
     */
    public static List<Donation__c> createDonationRecordsWithRecordType (
        Integer numOfRecords,
        Id recordTypeId
    ) {
        List<Donation__c> donationList = new List<Donation__c>();
        for (Integer i = 0; i < numOfRecords; i++) {
            donationList.add(
                new Donation__c(
                    RecordTypeId = recordTypeId,
                    Stage__c = 'Proposed',
                    Donation_Type__c = 'Influenced Revenue',
                    Donation_Comment__c = 'Test Donation'
                )
            );
        }
        return donationList;
    }

    /**
     * @description Method for creating test Donation Causes records
     * @params
     * numOfRecords - number of records to create
     * @return donationCauseList - List of Donation Cause records created
     */
    public static List<Donation_Cause__c> createDonationCauseRecords(
        Integer numOfRecords
    ) {
        List<Donation_Cause__c> donationCauseList = new List<Donation_Cause__c>();
        for (Integer i = 0; i < numOfRecords; i++) {
            donationCauseList.add(
                new Donation_Cause__c(
                    Activation_Start_Date__c = System.Today(),
                    Name = 'Test Donation' + i,
                    Donation_Cause_Description__c = 'Test'
                )
            );
        }
        return donationCauseList;
    }

    /**
     * @description Method for creating test Designation records
     * @params
     * numOfRecords - number of records to create
     * @return designationList - List of Designation records created
     */
    public static List<Designation__c> createDesignationRecords(
        Integer numOfRecords,
        Id recordTypeId
    ) {
        List<Designation__c> designationList = new List<Designation__c>();
        for (Integer i = 0; i < numOfRecords; i++) {
            designationList.add(
                new Designation__c(
                    Activation_Start_Date__c = System.Today(),
                    Name = 'Test Designation ' + i,
                    Description__c = 'Test',
                    RecordTypeId = recordTypeId
                )
            );
        }
        return designationList;
    }

    /**
     * @description Method for creating test Donation records
     * @params
     * numOfRecords - number of records to create
     * @return donationList - List of Donation records created
     */
    public static List<Donation__c> createDonationRecordsWithOpportunity (
        Integer numOfRecords,
        Id opportunityId
    ) {
        List<Donation__c> donationCauseList = new List<Donation__c>();
        for (Integer i = 0; i < numOfRecords; i++) {
            donationCauseList.add(
                new Donation__c(
                    Donation_Type__c = 'Influenced Revenue',
                    Stage__c = 'Proposed',
                    Opportunity__c = opportunityId
                )
            );
        }
        return donationCauseList;
    }

    /**
     * @description Method for creating test Distribution Management records
     * @params
     * numOfRecords - number of records to create
     * @return dMList - List of Distribution Management records created
     */
    public static List<Distribution_Management__c> createDistributionManagementRecordsWithDesignation(
        Integer numOfRecords,
        Id designationId
    ) {
        List<Distribution_Management__c> dMList = new List<Distribution_Management__c>();
        for (Integer i = 0; i < numOfRecords; i++) {
            dMList.add(
                new Distribution_Management__c(
                    Designation__c = designationId,
                    Start_Date__c = System.Today(),
                    Status__c = 'Ready For Use'
                )
            );
        }
        return dMList;
    }

    /**
     * @description Method for creating test Donation Asset records
     * @params
     * numOfRecords - number of records to create
     * @return donationAssetList - List of Donation Assets records created
     */
    public static List<Donation_Asset__c> createDonationAssetRecords(
        Integer numOfRecords
    ) {
        List<Donation_Asset__c> donationAssetList = new List<Donation_Asset__c>();
        for (Integer i = 0; i < numOfRecords; i++) {
            donationAssetList.add(
                new Donation_Asset__c(
                    Asset_Name_Title__c = 'Test Donation',
                    Asset_Type__c = 'Art'
                )
            );
        }
        return donationAssetList;
    }
    /** @description Method for Assessment Records
     * @param numberOfAssesmentRecords - number of Assessment Records to be created
     * @return assessmentRecords - list of assessment records created
     */
    public static List<Assessment__c> createTestAssessmentRecords(Integer numberOfAssesmentRecords) {
        List<Assessment__c> assessmentRecords = new List<Assessment__c>();
        for (Integer i = 0; i < numberOfAssesmentRecords; i++) {
            assessmentRecords.add(
                new Assessment__c(
                    Name = 'Test' + i,
                    Assessment_Priority__c = 'High'
                )
            );
        }
        return assessmentRecords;
    }

    /** @description Method for creating test Contact Alternate Id record
     * @return Contact Alternate Id record
     */
    public static Contact_Alternate_ID__c createTestConAltIdRecordByContactAndType(Id contactId, String idType, String contactAltId) {
        return new Contact_Alternate_ID__c(
            Contact__c = contactId,
            Contact_Alternate_Id__c = contactAltId,
            Alternate_Id_Status__c = 'Active',
            Alternate_Id_Type__c = idType
        );
    }

    /** 
     * @description Method for creating contact required for Application record
     * @param Integer startAtCount - number of record to start 
     * @param Integer endBeforeCount - number of record to end
     * @return List<Contact> - list of contact record to insert
     */    
    public static List<Contact> createTestApplicationContactRecords(
        Integer startAtCount,
        Integer endBeforeCount
    ) {
        String email = 'testmail@mail.test';
        List<Contact> newContacts = new List<Contact>();
        for (Integer i = startAtCount; i < endBeforeCount; i++) {
            newContacts.add(
                new Contact(
                    FirstName = 'TestfirstName' + i,
                    LastName = i + 'Testlastname',
                    BirthDate = System.Today().addYears(-17).addDays(i),
                    Email = i + EMAIL,
                    QUT_Learner_Email__c = 'learner' + i + email,
                    QUT_Staff_Email__c = 'staff' + i + email,
                    Work_Email__c = 'work' + i + email,
                    hed__Preferred_Email__c = 'Alternate Email',
                    hed__AlternateEmail__c = i + email,
                    RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID 
                )
            );
        }
        return newContacts;
    }
    /** 
     * @description Method for creating studylink application record
     * @param Integer startAtCount - number of record to start 
     * @param Integer endBeforeCount - number of record to end
     * @param String applicationStatus - status of the studylink application
     * @return List<hed__application__c> - list of application record to insert
     */      
    public static List<hed__Application__c> createTestApplicationStudyLinkRecords(Integer startAtCount, Integer endBeforeCount, String applicationStatus) {
        List<hed__Application__c> newApplications = new List<hed__Application__c>();
        for (Integer i = startAtCount; i < endBeforeCount; i++) {
            String email = 'testmail@mail.test';
            newApplications.add(
                new hed__Application__c(
                    FirstName__c = 'TestfirstName' + i,
                    LastName__c = i + 'Testlastname',
                    BirthDate__c = System.Today().addYears(-17).addDays(i),
                    Email__c = 'work' + i + email,
                    Application_Status__c = applicationStatus,
                    RecordTypeId = ApplicationsDAO.STUDYLINK_RECTYPE_ID,
                    Indigenous_Status__c = 'Aboriginal',
                    Citizenship_Country__c = 'Australia',
                    Mobile__c = '0400000000' + i,
                    Citizenship_Status__c = 'Domestic'
                )
            );
        }
        return newApplications;
    }  
    /** 
     * @description Method for creating lead required for Application record
     * @param Integer startAtCount - number of record to start 
     * @param Integer endBeforeCount - number of record to end
     * @return List<Lead> - list of lead record to insert
     */     
    public static List<Lead> createTestLeadRecordForApplication(Integer startAtCount, Integer endBeforeCount) {
        List<Lead> newLeads = new List<Lead>();
        String email = 'testmail@mail.test';
        for (Integer i = startAtCount; i < endBeforeCount; i++) {
            newLeads.add(
                new Lead(
                    FirstName = 'TestfirstName',
                    LastName = 'Testlastname' + i,
                    Email = i + email,
                    Work_Email__c = 'work' + i + email,
                    Company = 'Learner' + i
                )
            );
        }
        return newLeads;
    }
    /** @description Method for creating test student sanction records
     * @return Student_Sanction__c record
     */
    public static List<Student_Sanction__c> createStudentSanctionRecords(Integer count) {
        List<Student_Sanction__c> studentSanctionList = new List<Student_Sanction__c>();

        for(Integer i = 0; i< count; i++){
            studentSanctionList.add( 
                new Student_Sanction__c(
                    Sanction_Code__c = 'DUP',
                    QUT_Student_ID__c = String.valueOf(i)
                )
            );
        }
        return studentSanctionList;
    }

    /** @description Method for creating test Engagement List Configuration records
     * @return listNewEngagementListConfiguration - list of Engagement List Configuration created
     */
    public static List<Engagement_List_Configuration__c> createTestEngagementListConfiguration() {
        List<Engagement_List_Configuration__c> listNewEngagementListConfiguration = new List<Engagement_List_Configuration__c>();
        for (Integer i = 0; i < 2; i++) {
            listNewEngagementListConfiguration.add(
                new Engagement_List_Configuration__c(
                    Name = 'Test ELC 0' + i + ''
                )
            );
        }
        insert listNewEngagementListConfiguration;
        return listNewEngagementListConfiguration;
    }

    /** @description Method for creating test contact matching staging records
     * @return Contact_Matching_Staging__c record
     */
    public static List<Contact_Matching_Staging__c> createContactMatchingStagings(Integer count) {
        List<Contact_Matching_Staging__c> contactMatchingStagingList = new List<Contact_Matching_Staging__c>();

        for(Integer i = 0; i< count; i++){
            contactMatchingStagingList.add( 
                new Contact_Matching_Staging__c(
                    LastName__c = 'Test'+i
                )
            );
        }

        return contactMatchingStagingList;
    }

    public static Case createTestOutreachCaseRecord(
        Engagement_List_Configuration__c elConfig,
        Id ownerId,
        Id contactId
    ) {

        Case caseRecord = new Case();
        caseRecord.RecordTypeId = CasesDAO.OUTREACH_RECTYPE_ID;
        caseRecord.Engagement_List_Configuration__c = elConfig.Id;
        caseRecord.Subject = elConfig.Name;
        caseRecord.ContactId = contactId;
        caseRecord.OwnerId = ownerId;
        caseRecord.Case_Type__c = CasesDAO.CASE_TYPE_STUDENT_SUCCESS_RETENTION;
        caseRecord.Origin = CasesDAO.ORIGIN_ENGAGEMENT_LIST;
        caseRecord.Description = CasesDAO.DESCRIPTION_ENGAGEMENT_LIST;
        caseRecord.Status = CasesDAO.STATUS_CREATED;
        caseRecord.Priority = CasesDAO.PRIORITY_LOW;
        return caseRecord;
    }

    public static List<Case> createTestOutreachCaseRecords(
        Engagement_List_Configuration__c elConfig,
        Id ownerId,
        List<Contact> contacts
    ) {
        List<Case> caseList = new List<Case>();
        for(Contact contact : contacts){
            Case caseRecord = new Case();
            caseRecord.RecordTypeId = CasesDAO.OUTREACH_RECTYPE_ID;
            caseRecord.Engagement_List_Configuration__c = elConfig.Id;
            caseRecord.Subject = elConfig.Name;
            caseRecord.ContactId = contact.Id;
            caseRecord.OwnerId = ownerId;
            caseRecord.Case_Type__c = CasesDAO.CASE_TYPE_STUDENT_SUCCESS_RETENTION;
            caseRecord.Origin = CasesDAO.ORIGIN_ENGAGEMENT_LIST;
            caseRecord.Description = CasesDAO.DESCRIPTION_ENGAGEMENT_LIST;
            caseRecord.Status = CasesDAO.STATUS_CREATED;
            caseRecord.Priority = CasesDAO.PRIORITY_LOW;
            caseList.add(caseRecord);
        }
        
        return caseList;
    }

    /** @description Method for creating serialized records with nonwritable fields
     * @return String serialized object
     */
    public static String getSObjectJSONString(SObjectJSONStringParam param) {
        return '{"attributes":{"type":"' +
        param.objectApiName +
        '","url":"/services/data/v56.0/sobjects/' +
        param.objectApiName +
        '/' +
        param.recordId +
        '"},' +
        '"Id":"' +
        param.recordId +
        '","Name":"' +
        param.name +
        '","CreatedDate":"' +
        String.valueOf(param.createdDate) +
        '","LastModifiedDate":"' +
        String.valueOf(param.lastModifiedDate) +
        '"}';
    }

    public class SObjectJSONStringParam{
        public String objectApiName { get; set; }
        public String recordId { get; set; }
        public String name { get; set; }
        public Date createdDate { get; set; }
        public Date lastModifiedDate { get; set; }
    }

    /** @description Method for creating Qualtrics Survey Record
     * @param numberOfQSRecords - number of Qualtrics Survey Record to be created
     * @return qualtricsRecords - list of Qualtrics Survey Record created
     */
    public static List<Qualtrics_Survey__c> createQualtricsSurveyRecord(integer numberOfQSRecords) {
        List<Qualtrics_Survey__c> qualtricsRecords = new List<Qualtrics_Survey__c>();
        for (Integer i = 0; i < numberOfQSRecords; i++) {
            qualtricsRecords.add(
                new Qualtrics_Survey__c()
            );
        }
        return qualtricsRecords;
    }
}