/**
 * @description Test class for ELCEvaluatorTest
 * @ELCEvaluator
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum                 | May 07, 2024          | DEPP-8488              | Created file                 |
 */
@isTest
public with sharing class ELCEvaluatorTest {
    @TestSetup
    static void setupMethod(){
        TestDataFactoryUser.generateUserQUTESB();
    }
    
    @isTest
    static void populateContactValuesOnlyTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {        
            // Contact contact = new Contact();
            List<Contact> contactList = TestDataFactory.createTestContactRecords(3, '');          
            for(Contact con: contactList){
                con.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                con.QUT_Student__c = true;
            }         
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);
            
            Test.startTest();			            
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Citizenship_Status__c = null;
            engagementListCriteria.Academic_Status__c = null;
            engagementListCriteria.Category_Type__c = null;
            engagementListCriteria.Completed_Cadence__c = null;
            engagementListCriteria.Course_Grade__c = null;
            engagementListCriteria.Breach__c = null;
            engagementListCriteria.Failed_To_Submit_Assessment__c = null;
            engagementListCriteria.Assessment_Priority__c = null;
            engagementListCriteria.Is_On_Leave_of_Absence__c = null;
            engagementListCriteria.Key_Date__c = null;
            engagementListCriteria.Key_Date_Offset_Lower_Boundary__c = null;
            engagementListCriteria.Key_Date_Offset_Upper_Boundary__c = null;
            
            ELCParser elcParser = new ELCParser(engagementListCriteria, date.today());
            //get contact
            List<Contact> contacts = ContactsDAO.newInstance().findByCriteria(elcParser.getELCContactParser().getContactCriteria(), AccessLevel.SYSTEM_MODE); 
            //Contact Evaluator
            ELCEvaluator evaluator = new ELCEvaluator(elcParser);
            Map<Id, ELECandidateIngredient> evaluatorMap = evaluator.evaluate(contacts);
            Test.stopTest();
            
            System.assertEquals(!contacts.isEmpty(), true, 'Contact is empty');
            System.assertEquals(!evaluatorMap.isEmpty(), true, 'evaluatorMap is empty');
            for(Contact con: contacts){
                ELECandidateIngredient ingredient = evaluatorMap.get(con.Id);
                System.assertEquals(ingredient.getContact().Id, con.Id, 'Contact is not matched');  
            }       
        }
    }
    
    @isTest
    static void populateContactWithCompletedCadenceValuesTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            
            String citizenshipStatus = ContactsDAO.CITIZENSHIP_STATUS_DOMESTIC;
            String completedCadenceName = 'Domestic Accepted and Admitted';
            List<Contact> contactList = TestDataFactory.createTestContactRecords(3, '');
            
            for(Contact con: contactList){
                con.RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
                con.QUT_Student__c = true;
                con.hed__Citizenship_Status__c = citizenshipStatus;
            }
            
            ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);
            
            List<Nurture_Track_Configuration__c> nurtureListCon = new List<Nurture_Track_Configuration__c>();
            Nurture_Track_Configuration__c nurtureTrackConfig = new Nurture_Track_Configuration__c();
            nurtureTrackConfig.Cadence_Name__c = completedCadenceName;
            nurtureListCon.add(nurtureTrackConfig);
            NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureListCon, false, AccessLevel.SYSTEM_MODE);
                        
            List<Completed_Cadence__c> completedCadenceList = new List<Completed_Cadence__c>();
            
            for(Contact con: contactList){                
                completedCadenceList.add(TestDataFactory.createCompletedCadence(CompletedCadencesDAO.SUCCESSFUL_STATUS,nurtureListCon[0].Id,new Set<Id>{con.Id})[0]);
            }
            
            CompletedCadencesDAO.newInstance().insertRecords(completedCadenceList, false, AccessLevel.SYSTEM_MODE);
            
            Test.startTest();
			            
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Citizenship_Status__c = citizenshipStatus;
            engagementListCriteria.Academic_Status__c = null;
            engagementListCriteria.Category_Type__c = null;
            engagementListCriteria.Completed_Cadence__c = completedCadenceName;
            engagementListCriteria.Course_Grade__c = null;
            engagementListCriteria.Breach__c = null;
            engagementListCriteria.Failed_To_Submit_Assessment__c = null;
            engagementListCriteria.Assessment_Priority__c = null;
            engagementListCriteria.Is_On_Leave_of_Absence__c = null;
            engagementListCriteria.Key_Date__c = null;
            engagementListCriteria.Key_Date_Offset_Lower_Boundary__c = null;
            engagementListCriteria.Key_Date_Offset_Upper_Boundary__c = null;
            
            ELCParser elcParser = new ELCParser(engagementListCriteria, date.today());
            //get contact
            List<Contact> contacts = ContactsDAO.newInstance().findByCriteria(elcParser.getELCContactParser().getContactCriteria(), AccessLevel.SYSTEM_MODE); 
            //Contact Evaluator
            ELCEvaluator evaluator = new ELCEvaluator(elcParser);
            Map<Id, ELECandidateIngredient> evaluatorMap = evaluator.evaluate(contacts);
            Test.stopTest();
            
            System.assertEquals(!contacts.isEmpty(), true, 'Contact is empty');
            System.assertEquals(!evaluatorMap.isEmpty(), true, 'evaluatorMap is empty');
            for(Contact con: contacts){
                ELECandidateIngredient ingredient = evaluatorMap.get(con.Id);
                System.assertEquals(ingredient.getContact().Id, con.Id, 'Contact is not matched');
                System.assertEquals(!ingredient.getCompletedCadences().isEmpty(),true , 'Completed Cadences List is not empty');  
            }       
        }
    }
    
    @isTest
    static void populateNullValuesTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            
            Test.startTest();            
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Citizenship_Status__c = null;
            engagementListCriteria.Academic_Status__c = null;
            engagementListCriteria.Category_Type__c = null;
            engagementListCriteria.Completed_Cadence__c = null;
            engagementListCriteria.Course_Grade__c = null;
            engagementListCriteria.Breach__c = null;
            engagementListCriteria.Failed_To_Submit_Assessment__c = null;
            engagementListCriteria.Assessment_Priority__c = null;
            engagementListCriteria.Is_On_Leave_of_Absence__c = null;
            engagementListCriteria.Key_Date__c = null;
            engagementListCriteria.Key_Date_Offset_Lower_Boundary__c = null;
            engagementListCriteria.Key_Date_Offset_Upper_Boundary__c = null;
  
            ELCParser elcParser = new ELCParser(engagementListCriteria, date.today());
            //get contact
            List<Contact> contacts = ContactsDAO.newInstance().findByCriteria(elcParser.getELCContactParser().getContactCriteria(), AccessLevel.SYSTEM_MODE); 
            //Contact Evaluator
            ELCEvaluator evaluator = new ELCEvaluator(elcParser);
            Map<Id, ELECandidateIngredient> evaluate= evaluator.evaluate(contacts);
            Test.stopTest();           
            System.assertEquals(evaluate, null, 'Map is not empty');         
        }
    }

}
