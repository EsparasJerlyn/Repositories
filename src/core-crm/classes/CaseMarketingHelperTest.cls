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
      |                                |                       |                        |                              |
 */
@isTest
public with sharing class CaseMarketingHelperTest {

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
                        Marketing_Opt_In__c = true
                    )
                );
            }
            
            CasesDAO.newInstance().insertRecords(cases, true, AccessLevel.SYSTEM_MODE);
            Test.stopTest();

            Set<Id> contactIds = new Set<Id>();
            for(Contact con:ContactsDAO.getPersonContactsWithLimit(50)){
                contactIds.add(con.Id);
                System.assertEquals(false, con.HasOptedOutOfEmail,'HasOptedOutOfEmail did not match');
                System.assertEquals(System.today(), date.newinstance(con.Email_Opt_In_DateTime__c.year(), con.Email_Opt_In_DateTime__c.month(), con.Email_Opt_In_DateTime__c.day()),'Email_Opt_In_DateTime__c did not match');
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
                        Marketing_Opt_In__c = true
                    )
                );
            }

            CasesDAO.newInstance().insertRecords(cases, true, AccessLevel.SYSTEM_MODE);
            Test.stopTest();

            Set<Id> leadIds = new Set<Id>();
            for(Lead leadRecord:LeadsDAO.getLeadsWithLimit(50)){
                leadIds.add(leadRecord.Id);
                System.assertEquals(false, leadRecord.HasOptedOutOfEmail,'HasOptedOutOfEmail did not match');
                System.assertEquals(System.today(), date.newinstance(leadRecord.Email_Opt_In_DateTime__c.year(), leadRecord.Email_Opt_In_DateTime__c.month(), leadRecord.Email_Opt_In_DateTime__c.day()),'Email_Opt_In_DateTime__c did not match');
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
}