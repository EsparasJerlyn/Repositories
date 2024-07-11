/**
 * @description Test class for CaseMarketingHelper
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | November 01, 2023     | DEPP-7060              | Created file                 |
      | sebastianne.k.trias            | June 17, 2024         | DEPP-8474              | Removed Marketing OptIn      |
 */
@isTest
public with sharing class CaseMarketingHelperTest {
    
    private static final String FIRSTNAME = 'TestfirstName';
    private static final String LASTNAME = 'Testlastname';
    private static final String EMAIL = 'testmail@mail.test';
    private static final String BIRTHDAY = '2000-06-28';
    private static Integer recordsCount = 20;
    
    @testSetup
    static void setupMethod() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTESB();
        Test.stopTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            
            List<Contact> contactList = TestDataFactory.createTestContactRecords(0,50);
            for(Integer i = 0; i < contactList.size(); i++){
                contactList[i].MobilePhone = '0909'+ i;
                contactList[i].HasOptedOutOfEmail = true;
            }
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);
            
            List<Lead> leadList = TestDataFactory.createTestLeadRecords(50);
            for(Integer i = 0; i < leadList.size(); i++){
                leadList[i].MobilePhone = '0908'+i;
                leadList[i].HasOptedOutOfEmail = true;
            }
            LeadsDAO.newInstance().insertRecords(leadList, false, AccessLevel.USER_MODE);
        }
        
    }

    @isTest
    static void insertCaseAndMapContactMarketingFields(){
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Case> cases = new List<Case>();
            for(Integer i = 0; i < 50; i++){
                cases.add(
                    new Case(  
                        Status = 'Created', 
                        SuppliedPhone = '0909'+i,
                        Description = 'Test Case Description' + i,
                        Origin = CasesDAO.ORIGIN_WHATSAPP,
                        My_Country_Of_Citizenship__c = 'Australia',
                        My_Citizenship_Status__c = 'Australian Citizen or Permanent Resident',
                        My_Country_Of_Residency__c = 'Australia',
                        My_Education_Level__c = 'In Year 8',
                        My_Primary_Study_Level__c = 'Undergraduate',
                        Case_Type__c = CasesDAO.CASE_TYPE_DOMESTIC,
                        RecordTypeId = CasesDAO.INBOUND_ENQUIRY_RECTYPE_ID
                    )
                );
            }
            
            CasesDAO.newInstance().insertRecords(cases, true, AccessLevel.SYSTEM_MODE);
            Test.stopTest();

            Set<Id> contactIds = new Set<Id>();
            for(Contact con:ContactsDAO.getPersonContactsWithLimit(50)){
                contactIds.add(con.Id);
            }

            for(Marketing_Segmentation__c marseg: MarketingSegmentationsDAO.newInstance().getMarketingSegmentationByContactOrLead(contactIds,new Set<Id>(),AccessLevel.SYSTEM_MODE)){
                System.assertEquals('Australia', marseg.My_Country_Of_Citizenship__c,'My_Country_Of_Citizenship__c did not match');
                System.assertEquals('Australian Citizen or Permanent Resident', marseg.My_Citizenship_Status__c,'My_Citizenship_Status__c did not match');
                System.assertEquals('Australia', marseg.My_Country_Of_Residency__c,'My_Country_Of_Residency__c did not match');
                System.assertEquals('In Year 8', marseg.My_Education_Level__c,'My_Education_Level__c did not match');
                System.assertEquals('Undergraduate', marseg.My_Primary_Study_Level__c,'My_Primary_Study_Level__c did not match');
            }
        }
    }

    @isTest
    static void insertCaseAndMapLeadMarketingFields(){
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            Test.startTest();
            List<Case> cases = new List<Case>();
            for(Integer i = 0; i < 50; i++){
                cases.add(
                    new Case(  
                        Status = 'Created', 
                        SuppliedPhone = '0908'+i,
                        Description = 'Test Case Description' + i,
                        Origin = CasesDAO.ORIGIN_WHATSAPP,
                        My_Country_Of_Citizenship__c = 'Australia',
                        My_Citizenship_Status__c = 'Australian Citizen or Permanent Resident',
                        My_Country_Of_Residency__c = 'Australia',
                        My_Education_Level__c = 'In Year 8',
                        My_Primary_Study_Level__c = 'Undergraduate',
                        Case_Type__c = CasesDAO.CASE_TYPE_DOMESTIC,
                        RecordTypeId = CasesDAO.INBOUND_ENQUIRY_RECTYPE_ID
                    )
                );
            }

            CasesDAO.newInstance().insertRecords(cases, true, AccessLevel.SYSTEM_MODE);
            Test.stopTest();

            Set<Id> leadIds = new Set<Id>();
            for(Lead leadRecord:LeadsDAO.getLeadsWithLimit(50)){
                leadIds.add(leadRecord.Id);
            }

            for(Marketing_Segmentation__c marseg: MarketingSegmentationsDAO.newInstance().getMarketingSegmentationByContactOrLead(new Set<Id>(),leadIds,AccessLevel.SYSTEM_MODE)){
                System.assertEquals('Australia', marseg.My_Country_Of_Citizenship__c,'My_Country_Of_Citizenship__c did not match');
                System.assertEquals('Australian Citizen or Permanent Resident', marseg.My_Citizenship_Status__c,'My_Citizenship_Status__c did not match');
                System.assertEquals('Australia', marseg.My_Country_Of_Residency__c,'My_Country_Of_Residency__c did not match');
                System.assertEquals('In Year 8', marseg.My_Education_Level__c,'My_Education_Level__c did not match');
                System.assertEquals('Undergraduate', marseg.My_Primary_Study_Level__c,'My_Primary_Study_Level__c did not match');
            }
        }
    }
    
    @isTest
    static void insertCaseAssociatedToContact(){
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
                        
            List<Contact> contactToUpdate = new List<Contact>();
            Map<String,Contact> contactMap = new Map<String,Contact>();          
            List<Contact> newContacts = createTestContactRecords(0, 50);  
            for(Contact con:newContacts){
                contactMap.put(con.Work_Email__c, con);
            }            
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
                        
            Test.startTest();
            Set<Id> contactIds = new Set<Id>();
            List<Case> cases = new List<Case>();
            for(Integer i = 0; i < 50; i++){
                cases.add(
                    new Case(  
                        Status = 'Created', 
                        SuppliedPhone = '0909'+i,
                        Web_Mobile_Locale__c = 'Australia (+61)',
                        Web_Mobile_No_Locale__c = '3333444445555',
                        ContactId = contactMap.get('work' + i + EMAIL)?.Id,
                        SuppliedEmail = 'con11223.Test@randomtest.com.'+i,
                        Description = 'Test Case Description' + i,
                        Origin = 'Email',
                        My_Country_Of_Citizenship__c = 'Australia',
                        My_Citizenship_Status__c = 'Australian Citizen or Permanent Resident',
                        My_Country_Of_Residency__c = 'Australia',
                        My_Education_Level__c = 'In Year 8',
                        My_Primary_Study_Level__c = 'Undergraduate',
                        Case_Type__c = CasesDAO.CASE_TYPE_DOMESTIC,
                        RecordTypeId = CasesDAO.INBOUND_ENQUIRY_RECTYPE_ID
                    )
                );
                contactIds.add(contactMap.get('work' + i + EMAIL)?.Id);
            }
            
            CasesDAO.newInstance().insertRecords(cases, true, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            
            Integer iterationCaseCount = 0;
            for(Contact con:ContactsDAO.newInstance().getPersonContactsBySetIds(contactIds,AccessLevel.SYSTEM_MODE)){
                iterationCaseCount++;
                System.assertEquals(false, con.HasOptedOutOfEmail,'HasOptedOutOfEmail did not match');
                System.assertEquals('con11223.Test@randomtest.com.'+iterationCaseCount, con.Email,'Primary Email did not match');
                System.assertEquals('Australia (+61)', con.ContactMobile_Locale__c,'ContactMobile_Locale__c did not match');
                System.assertEquals('3333444445555', con.Mobile_No_Locale__c,'Mobile_No_Locale__c did not match');
            }

        }
    }
    
    private static List<Contact> createTestContactRecords(
        Integer startAtCount,
        Integer endBeforeCount
    ) {
        List<Contact> newContacts = new List<Contact>();
        for (Integer i = startAtCount; i < endBeforeCount; i++) {
            newContacts.add(
                new Contact(
                    FirstName = FIRSTNAME + i,
                    LastName = i + LASTNAME,
                    BirthDate = Date.valueOf(BIRTHDAY),
                    QUT_Learner_Email__c = 'learner' + i + EMAIL,
                    QUT_Staff_Email__c = 'staff' + i + EMAIL,
                    Work_Email__c = 'work' + i + EMAIL,
                    hed__Preferred_Email__c = 'Alternate Email',
                    hed__AlternateEmail__c = i + EMAIL,
                    RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID 
                )
            );
        }
        return newContacts;
    }
}