/**
 * @description Tests Class for Lead_Update_Triggered_Flow
 * @see Lead_Update_Triggered_FlowTest
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | arsenio.dayrit@qut.edu.au      | November 04, 2021     | DEPP-744               | Created file                 | 
      |                                |                       |                        |                              | 
 */
@isTest(SeeAllData = false)
public class Lead_Update_Triggered_FlowTest {
    
    private static User  currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();


    @isTest
    private static void updateOpportunityStageToContract(){

        System.runAs(currentUser){
            Account acct = TestDataFactory.createTestAccountRecords(1).iterator().next();
            insert acct;
            
            List<Lead> createLead = TestDataFactory.createTestLeadRecords(100);
            for(Lead fieldValues : createLead){
                fieldValues.Work_Phone__c= '12345678';
                fieldValues.Personal_Mobile__c= '12345679';
                fieldValues.ABN__c= '123456710';
                fieldValues.LeadPhone_Locale__c= 'Australia (+61)';
                fieldValues.LeadMobile_Locale__c= 'Australia (+61)';
                fieldValues.WorkPhone_Locale__c= 'Australia (+61)';
                fieldValues.LeadPersonalMobile_Locale__c= 'Australia (+61)';
                fieldValues.LeadPhone_Validation__c='Valid';
                fieldValues.LeadABNEntity_Validation__c='Valid';
                fieldValues.LeadMobile_Validation__c='Valid';
                fieldValues.LeadPersonalMobile_Validation__c='Valid';
                fieldValues.WorkPhone_Validation__c='Valid';
            }
            insert createLead;
               

            Test.startTest();
            List<Lead> getLead = new List<Lead>();
            List<Lead> leadRec = new List<Lead>([SELECT Id, Phone, MobilePhone, Work_Phone__c, Personal_Mobile__c, ABN__c, LeadPhone_Locale__c, LeadMobile_Locale__c, WorkPhone_Locale__c, LeadPersonalMobile_Locale__c,
            LeadPhone_Validation__c, LeadABNEntity_Validation__c, LeadMobile_Validation__c, LeadPersonalMobile_Validation__c, WorkPhone_Validation__c FROM Lead LIMIT 100]);

            for(Lead leads : leadRec){
                leads.Phone = '123456';
                leads.MobilePhone= '12345678';
                leads.Phone = '1234563';
                leads.MobilePhone= '123453678';
                leads.Work_Phone__c= '123435678';
                leads.Personal_Mobile__c= '132345679';
                leads.ABN__c= '1234567103';
                leads.LeadPhone_Locale__c= 'Australia (+61)';
                leads.LeadMobile_Locale__c= 'Australia (+61)';
                leads.WorkPhone_Locale__c= 'Australia (+61)';
                leads.LeadPersonalMobile_Locale__c= 'Australia (+61)';
                


                getLead.add(leads);
            }
            update getLead;




        }
        Test.stopTest();
        List<Lead> updatedLeadList = [SELECT LeadPhone_Validation__c, LeadABNEntity_Validation__c, LeadMobile_Validation__c, LeadPersonalMobile_Validation__c, WorkPhone_Validation__c FROM Lead LIMIT 100];
        for(Lead checkLead : updatedLeadList){
            System.assertEquals('None', checkLead.LeadPhone_Validation__c,'the status did not match');
            System.assertEquals('None', checkLead.LeadABNEntity_Validation__c,'the status did not match');
            System.assertEquals('None', checkLead.LeadMobile_Validation__c,'the status did not match');
            System.assertEquals('None', checkLead.LeadPersonalMobile_Validation__c,'the status did not match');
            System.assertEquals('None', checkLead.WorkPhone_Validation__c,'the status did not match');
        }

    }
        
        
    }
