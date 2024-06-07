/**
 * @description Test Class for MarketingConsentHelper
 * @see ..
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | Feb 8, 2023           | DEPP-4866              | Created file                 |
      | sebastianne.k.trias            | June 6, 2024          | DEPP-8474              | Added OptIn/Out Leads        |
 */

 @isTest
 public with sharing class MarketingConsentHelperTest {


	@testSetup
    static void setupMethod() {
        
        TestDataFactory.generateTestUsers();
		
		System.runAs(TestDataFactory.getProgramAdminUser()){
			List<Contact> contactList = TestDataFactory.createTestContactRecords(100);
			for(integer i = 0; i < 49; i++){
				contactList[i].Consent_Source_Category__c = 'Study Application';
				contactList[i].HasOptedOutOfEmail = true;
				contactList[i].Registered_Email__c = 'testregisteredEmail@email.com' + i;
			}
			for(integer i = 50; i < 100; i++){
				contactList[i].Consent_Source_Category__c = 'Study Application';
				contactList[i].HasOptedOutOfEmail = false;
				contactList[i].Registered_Email__c = 'testregisteredEmail@email.com' + i;
			}
	
			insert contactlist;
		}
		
	}
 
	 @isTest
	 public static void optInToOptOutTest() {
		System.runAs(TestDataFactory.getProgramAdminUser()){
			List<Contact> contactList = new List<Contact>([
				SELECT Id, HasOptedOutOfEmail
				FROM Contact
				WHERE HasOptedOutOfEmail = false
			]);

			for(Contact con: contactList){
				con.HasOptedOutOfEmail = true;
			}

			update contactList;

			System.assert(![	SELECT Id 
								FROM Contact 
								WHERE Marketing_Segmentation__r.My_Primary_Study_Level__c = null 
								AND HasOptedOutOfEmail = true
								AND Email_Opt_Out_DateTime__c != null].isEmpty(),
								'related marketing segmentation My_Primary_Study_Level__c not nullified');
		}
	 }

	 @isTest
	 public static void optInToOptInNullPrimaryTest() {
		System.runAs(TestDataFactory.getProgramAdminUser()){

			List<Contact> contactList = new List<Contact>([
				SELECT Id, HasOptedOutOfEmail, Email_Opt_In_DateTime__c, Marketing_Segmentation__c
				FROM Contact
				WHERE HasOptedOutOfEmail = false
				AND Marketing_Segmentation__c != null
			]);
			
			List<Marketing_Segmentation__c> marketingSegList = new List<Marketing_Segmentation__c>();

			for(Contact con: contactList){
				con.Email_Opt_In_DateTime__c = System.now() + 1;
				marketingSegList.add(new Marketing_Segmentation__c(Id = con.Marketing_Segmentation__c, My_Primary_Study_Level__c = ''));
			}

			update marketingSegList;
			update contactList;

			System.assert(![	SELECT Id 
								FROM Contact 
								WHERE Marketing_Segmentation__r.My_Primary_Study_Level__c = 'Short Courses and Professional Development' 
								AND HasOptedOutOfEmail = false
								AND Email_Opt_In_DateTime__c != null].isEmpty(),
								'related marketing segmentation My_Primary_Study_Level__c not equal to Short Courses and Professional Development');
		}
		
	 }

	 @isTest
	 public static void optInToOptInTest() {
		System.runAs(TestDataFactory.getProgramAdminUser()){

			List<Contact> contactList = new List<Contact>([
				SELECT Id, HasOptedOutOfEmail, Email_Opt_In_DateTime__c, Marketing_Segmentation__c
				FROM Contact
				WHERE HasOptedOutOfEmail = false
				AND Marketing_Segmentation__c != null
			]);
		
			List<Marketing_Segmentation__c> marketingSegList = new List<Marketing_Segmentation__c>();

			for(Contact con: contactList){
				con.Email_Opt_In_DateTime__c = System.now() + 1;
				marketingSegList.add(new Marketing_Segmentation__c(Id = con.Marketing_Segmentation__c, My_Primary_Study_Level__c = 'Postgraduate'));
			}

			update marketingSegList;
			update contactList;

			System.assert(![	SELECT Id 
								FROM Contact 
								WHERE Marketing_Segmentation__r.My_Secondary_Study_Level__c = 'Short Courses and Professional Development' 
								AND HasOptedOutOfEmail = false
								AND Email_Opt_In_DateTime__c != null].isEmpty(),
								'related marketing segmentation My_Secondary_Study_Level__c not equal to Short Courses and Professional Development');
		}
		
	 }


	 @isTest
	 static void optOutLeadsTest(){
		System.runAs(TestDataFactory.getProgramAdminUser()) {
			List<Account> accList = TestDataFactory.createTestAccountRecords(1);
			insert accList;
			Test.StartTest();
				List<Lead> leadList = TestDataFactory.createTestLeadRecords(1);
				insert leadList;
				for(Lead lead: leadList){
					lead.HasOptedOutOfEmail = true;
				}
				update leadList;
			Test.StopTest();
			system.assertEquals(false, [SELECT Id, Email_Opt_Out_DateTime__c FROM Lead WHERE Email_Opt_Out_DateTime__c != null].isEmpty(), 'All leads should have Email_Opt_Out_DateTime__c Value');
		}
	 }

	 @isTest
	 static void optInLeadsTest(){
		System.runAs(TestDataFactory.getProgramAdminUser()) {
			List<Account> accList = TestDataFactory.createTestAccountRecords(1);
			insert accList;
			
			
			Test.StartTest();
				List<Lead> leadList = TestDataFactory.createTestLeadRecords(1);
				insert leadList;

				for(Lead lead: leadList){
					lead.HasOptedOutOfEmail = true;
				}
				update leadList;
				List<Lead> leadUpdatedList = [SELECT Id, HasOptedOutOfEmail FROM Lead];
				for(Lead lead: leadUpdatedList){
					lead.HasOptedOutOfEmail = false;
				}
				update leadUpdatedList;
			Test.StopTest();
			system.assertEquals(false, [SELECT Id, Email_Opt_In_DateTime__c FROM Lead WHERE Email_Opt_In_DateTime__c != null].isEmpty(), 'All leads should have Email_Opt_In_DateTime__c Value');
		}
	 }
 
 
  }