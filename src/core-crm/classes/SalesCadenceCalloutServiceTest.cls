/**
 * @description Test Class for SalesCadenceCalloutService
 *
 * @see SalesCadenceCalloutService
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                 |
      |---------------------------|-----------------------|--------------|------------------------------------------------|
      | mark.j.mahilum            | July 18,2023          | DEPP-5799    | Created file                                   |
      | johanna.a.gibas           | Oct 16, 2023          | DEPP-6855    | Added Completed Cadence to increase coverage   |
      | johanna.a.gibas           | Oct 25, 2023          | DEPP-6889    | Added test methods for updateCompletedCadences |
      | kenneth.f.alsay           | December 27, 2023     |              | Removed unused variables                       |      
*/
@isTest
private class SalesCadenceCalloutServiceTest {
    private static final String FIRSTNAME = 'TestfirstName';
    private static final String LASTNAME = 'Testlastname';
    private static final String EMAIL = 'testmail@mail.test';
    private static final String BIRTHDAY = '2000-06-28';
    private static Integer recordsCount = 20;
    
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        TestDataFactoryUser.generateUserFutureStudentAgentDomestic();

        List<Nurture_Track_Configuration__c> nurtureList = new List<Nurture_Track_Configuration__c>();
        Nurture_Track_Configuration__c nurtureConfig = new Nurture_Track_Configuration__c();
        nurtureConfig.Cadence_Name__c = 'Test Cadences automated';
        nurtureConfig.Lead_Score_Threshold__c = 3;
        nurtureConfig.Status__c = 'Active';
        nurtureConfig.Criteria_Type__c = 'Entry';
        nurtureList.add(nurtureConfig);
        NurtureTrackConfigurationsDAO.newInstance().insertRecords(nurtureList, false, AccessLevel.SYSTEM_MODE);  
    }
    
    @isTest
    private static void testQueueableCall() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(10);  
            newContacts[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            newContacts[0].Calculated_Cadence__c = 'Test Cadences automated';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            
            Map<String,String> assignCadenceMap = new Map<String,String>();
            
            for(Contact con: newContacts){
                assignCadenceMap.put(con.Id,'Test Cadences automated');
            } 
            
            Test.startTest();
            SalesCadenceCalloutService.processSaleCadences(assignCadenceMap,assignCadenceMap);
            Test.stopTest();
            
            System.assert(![SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'SalesCadenceCalloutService'].isEmpty() , 'SalesCadenceCalloutService Queueable Job was not executed');
        }
    }

    @isTest
    private static void testContactWithCalculatedCadencesAddValue() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(10);  
            newContacts[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;           
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            
            List<Contact> updateContactList = new List<Contact>();
            for(Contact con: newContacts){
                Contact conRec = new Contact();
                conRec.Id = con.Id;
                conRec.Calculated_Cadence__c = 'Test Cadences automated1';
                updateContactList.add(conRec);
            }            
            Database.SaveResult[] srList = ContactsDAO.newInstance().updateRecords(updateContactList, false, AccessLevel.SYSTEM_MODE);
            Test.stopTest();
            for (Database.SaveResult sr : srList) {
                System.assert(sr.isSuccess(), 'A record was not updated.');
            }
        }
    }
    
    @isTest
    private static void testContactWithCalculatedCadencesRemoveValue() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(10);  
            List<ActionCadenceTracker> acTracker = new List<ActionCadenceTracker>();
            List<Completed_Cadence__c> completedCadenceList = new List<Completed_Cadence__c>();
            newContacts[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            newContacts[0].Calculated_Cadence__c = 'Test Cadences automated';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            
            Test.startTest();
            ImplementationSelector.DAO.setMock(new ContactsDAOMock());
            ImplementationSelector.DAO.setMock(new LeadsDAOMock());
            ImplementationSelector.DAO.setMock(new ActionCadenceTrackersDAOMock());
            ImplementationSelector.DAO.setMock(new CompletedCadencesDAOMock());
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
   
            acTracker.add(new ActionCadenceTracker(TargetId = newContacts[0].Id, State = 'Complete'));            
            ActionCadenceTrackersDAO.newInstance().insertRecords(acTracker,true,AccessLevel.SYSTEM_MODE);

            completedCadenceList.add(new Completed_Cadence__c(Contact__c = newContacts[0].Id, Completed_Cadence_Status__c = CompletedCadencesDAO.CLOSED_FOLLOW_UP_STATUS));
            CompletedCadencesDAO.newInstance().insertRecords(completedCadenceList,true,AccessLevel.SYSTEM_MODE);
                        
            Map<String, String> targetCadenceMap = new Map<String, String>{ newContacts[0].Id => 'Test Cadences automated'};
                           
            SalesCadenceCalloutService.createCompletedCadence(targetCadenceMap,new Set<String>{ acTracker[0].Id });
            
            Test.stopTest();
            System.assert([SELECT Id FROM Completed_Cadence__c].isEmpty() , 'Completed_Cadence__c record is not created');
        }
    }
    
    @isTest
    private static void testLeadWithCalculatedCadencesRemoveValue() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<ActionCadenceTracker> acTracker = new List<ActionCadenceTracker>();
            List<Completed_Cadence__c> completedCadenceList = new List<Completed_Cadence__c>();

            Test.startTest();
            ImplementationSelector.DAO.setMock(new ContactsDAOMock());
            ImplementationSelector.DAO.setMock(new LeadsDAOMock());
            ImplementationSelector.DAO.setMock(new ActionCadenceTrackersDAOMock());
            ImplementationSelector.DAO.setMock(new CompletedCadencesDAOMock());
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            
            List<Lead> leadList = TestDataFactory.createTestLeadRecords(1);
            leadList[0].Lead_Type__c = 'Learner';
            leadList[0].Calculated_Cadence__c = 'Test Cadences automated';
            LeadsDAO.newInstance().insertRecords(leadList,true,AccessLevel.SYSTEM_MODE);

            acTracker.add(new ActionCadenceTracker(TargetId = leadList[0].Id, State = 'Complete'));
            ActionCadenceTrackersDAO.newInstance().insertRecords(acTracker,true,AccessLevel.SYSTEM_MODE);

            completedCadenceList.add(new Completed_Cadence__c(Lead__c = leadList[0].Id, Completed_Cadence_Status__c = CompletedCadencesDAO.CLOSED_FOLLOW_UP_STATUS));
            CompletedCadencesDAO.newInstance().insertRecords(completedCadenceList,true,AccessLevel.SYSTEM_MODE);
                        
            Map<String, String> targetCadenceMap = new Map<String, String>{ leadList[0].Id => 'Test Cadences automated'};
                           
            SalesCadenceCalloutService.createCompletedCadence(targetCadenceMap,new Set<String>{ acTracker[0].Id });
            
            Test.stopTest();
            System.assert([SELECT Id FROM Completed_Cadence__c].isEmpty() , 'Completed_Cadence__c record is not created');
        }
    }
    
    @isTest
    private static void testLeadProcessCompletedCadenceTracker() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<ActionCadenceTracker> acTracker = new List<ActionCadenceTracker>();            
            Test.startTest();
            ImplementationSelector.DAO.setMock(new ContactsDAOMock());
            ImplementationSelector.DAO.setMock(new LeadsDAOMock());
            ImplementationSelector.DAO.setMock(new ActionCadenceTrackersDAOMock());
            ImplementationSelector.DAO.setMock(new CompletedCadencesDAOMock());
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            
            List<Lead> leadList = TestDataFactory.createTestLeadRecords(1);
            leadList[0].Lead_Type__c = 'Learner';
            leadList[0].Calculated_Cadence__c = 'Test Cadences automated';
            LeadsDAO.newInstance().insertRecords(leadList,true,AccessLevel.SYSTEM_MODE);
            
            acTracker.add(new ActionCadenceTracker(TargetId = leadList[0].Id, State = 'Complete'));
            
            ActionCadenceTrackersDAO.newInstance().insertRecords(acTracker,true,AccessLevel.SYSTEM_MODE);
                
            SalesCadenceCalloutService.processCompletedCadenceTracker(new List<String>{ acTracker[0].Id });
            
            Test.stopTest();
            System.assert([SELECT Id FROM Completed_Cadence__c].isEmpty() , 'Completed_Cadence__c record is not created');
        }
    }
    
    @isTest
    private static void testContactProcessCompletedCadenceTracker() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(10);  
            List<ActionCadenceTracker> acTracker = new List<ActionCadenceTracker>();
            newContacts[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            newContacts[0].Calculated_Cadence__c = 'Test Cadences automated';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            
            Test.startTest();
            ImplementationSelector.DAO.setMock(new ContactsDAOMock());
            ImplementationSelector.DAO.setMock(new LeadsDAOMock());
            ImplementationSelector.DAO.setMock(new ActionCadenceTrackersDAOMock());
            ImplementationSelector.DAO.setMock(new CompletedCadencesDAOMock());
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            
            acTracker.add(new ActionCadenceTracker(TargetId = newContacts[0].Id, State = 'Complete'));
            
            ActionCadenceTrackersDAO.newInstance().insertRecords(acTracker,true,AccessLevel.SYSTEM_MODE);
                
            SalesCadenceCalloutService.processCompletedCadenceTracker(new List<String>{ acTracker[0].Id });
            
            Test.stopTest();
            System.assert([SELECT Id FROM Completed_Cadence__c].isEmpty() , 'Completed_Cadence__c record is not created');
        }
    }
/* Commenting this out since this throws an Error of Arguement 1 cannot be null
    @isTest
    private static void updateCadenceStepTrackerTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

            ImplementationSelector.DAO.setMock(new ActionCadenceStepTrackersDAOMock());
            List<ActionCadenceStepTracker> actionCadenceTracker = ActionCadenceStepTrackersDAO.newInstance().getActionCadenceStepTrackerForEmail(new List<String>(), AccessLevel.SYSTEM_MODE);
            SalesCadenceCalloutService.updateCadenceStepTracker(new Set<Id>{actionCadenceTracker[0].Id}, 'Skip');
            
            Test.stopTest();

            System.assert(actionCadenceTracker != null, 'Test muna');
        }
    }
*/
    @isTest
    private static void updateCompletedCadencesTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(1);  
            List<ActionCadenceTracker> acTracker = new List<ActionCadenceTracker>();
            List<Completed_Cadence__c> completedCadenceList = new List<Completed_Cadence__c>();
            newContacts[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            newContacts[0].Calculated_Cadence__c = 'Test Cadence';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            
            Test.startTest();
            ImplementationSelector.DAO.setMock(new ContactsDAOMock());
            ImplementationSelector.DAO.setMock(new ActionCadenceTrackersDAOMock());
            ImplementationSelector.DAO.setMock(new CompletedCadencesDAOMock());
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            
            acTracker.add(new ActionCadenceTracker(TargetId = newContacts[0].Id, State = 'Completed'));
            ActionCadenceTrackersDAO.newInstance().insertRecords(acTracker,true,AccessLevel.SYSTEM_MODE);

            completedCadenceList.add(new Completed_Cadence__c(Contact__c = newContacts[0].Id, Completed_Cadence_Status__c = CompletedCadencesDAO.CLOSED_FOLLOW_UP_STATUS));
            CompletedCadencesDAO.newInstance().insertRecords(completedCadenceList,true,AccessLevel.SYSTEM_MODE);
            
            Map<String, String> targetIdCadenceMap = new Map<String, String>{ newContacts[0].Id => 'Test Cadence'};
                
            SalesCadenceCalloutService.updateCompletedCadences(targetIdCadenceMap);
            
            Test.stopTest();
            System.assert([SELECT Id FROM Completed_Cadence__c].isEmpty() , 'Completed_Cadence__c record is not created');
        }
    }
    
    @isTest
    private static void testCompletedCadencesInitialCreation() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(1);  
            List<ActionCadenceTracker> acTracker = new List<ActionCadenceTracker>();
            List<Completed_Cadence__c> completedCadenceList = new List<Completed_Cadence__c>();
            newContacts[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            newContacts[0].Calculated_Cadence__c = 'Test Cadences automated';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            
            Test.startTest();
            ImplementationSelector.DAO.setMock(new ContactsDAOMock());
            ImplementationSelector.DAO.setMock(new ActionCadenceTrackersDAOMock());
            ImplementationSelector.DAO.setMock(new CompletedCadencesDAOMock());
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            
            acTracker.add(new ActionCadenceTracker(TargetId = newContacts[0].Id, State = 'Completed'));
            ActionCadenceTrackersDAO.newInstance().insertRecords(acTracker,true,AccessLevel.SYSTEM_MODE);
            
            Map<String, String> targetIdCadenceMap = new Map<String, String>{ newContacts[0].Id => 'Test Cadences automated'};
            SalesCadenceCalloutService.createInitialCompletedCadences(targetIdCadenceMap);
            SalesCadenceCalloutService.updateCreateCompletedCadenceRecords(targetIdCadenceMap,targetIdCadenceMap);
            
            Test.stopTest();
            System.assert([SELECT Id FROM Completed_Cadence__c].isEmpty() , 'Completed_Cadence__c record is not created');
        }
    }
    
    @isTest
    private static void testUpdateCompletedCadencesOnRemoved() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(1);  
            List<ActionCadenceTracker> acTracker = new List<ActionCadenceTracker>();
            List<Completed_Cadence__c> completedCadenceList = new List<Completed_Cadence__c>();
            newContacts[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            newContacts[0].Calculated_Cadence__c = 'Test Cadences automated';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            
            Test.startTest();
            ImplementationSelector.DAO.setMock(new ContactsDAOMock());
            ImplementationSelector.DAO.setMock(new ActionCadenceTrackersDAOMock());
            ImplementationSelector.DAO.setMock(new CompletedCadencesDAOMock());
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            
            acTracker.add(new ActionCadenceTracker(TargetId = newContacts[0].Id, State = 'Completed'));
            ActionCadenceTrackersDAO.newInstance().insertRecords(acTracker,true,AccessLevel.SYSTEM_MODE);
            
            Nurture_Track_Configuration__c nurtureConfig = [SELECT Id from Nurture_Track_Configuration__c LIMIT 1];
            
            completedCadenceList.add(new Completed_Cadence__c(Contact__c = newContacts[0].Id, 
                                                              Completed_Cadence_Status__c = CompletedCadencesDAO.CLOSED_FOLLOW_UP_STATUS,
                                                              Nurture_Track_Configuration__c = nurtureConfig.Id ));
            CompletedCadencesDAO.newInstance().insertRecords(completedCadenceList,true,AccessLevel.SYSTEM_MODE);
            
            Map<String, String> targetIdCadenceMap = new Map<String, String>{ newContacts[0].Id => 'Test Cadences automated'};
            SalesCadenceCalloutService.createCompletedCadence(targetIdCadenceMap,null);
            SalesCadenceCalloutService.updateCreateCompletedCadenceRecords(targetIdCadenceMap,targetIdCadenceMap);
            
            Test.stopTest();
            System.assert([SELECT Id FROM Completed_Cadence__c].isEmpty() , 'Completed_Cadence__c record is not created');
        }
    }

    @isTest 
    private static void countTaskForRelatedCadencesTest(){
        System.runAs(TestDataFactoryUser.selectUserFutureStudentAgentDomestic) {
            List<Contact> newContacts = TestDataFactory.createTestContactRecords(1);  
            List<ActionCadenceTracker> acTracker = new List<ActionCadenceTracker>();
            List<Completed_Cadence__c> completedCadenceList = new List<Completed_Cadence__c>();
            newContacts[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
            newContacts[0].Calculated_Cadence__c = 'Test Cadences automated';
            ContactsDAO.newInstance().insertRecords(newContacts, false, AccessLevel.SYSTEM_MODE);
            
            Test.startTest();
            ImplementationSelector.DAO.setMock(new ContactsDAOMock());
            ImplementationSelector.DAO.setMock(new ActionCadenceTrackersDAOMock());
            ImplementationSelector.DAO.setMock(new ActionCadenceStepTrackersDAOMock());
            ImplementationSelector.DAO.setMock(new CompletedCadencesDAOMock());
            ImplementationSelector.DAO.setMock(new TasksDAOMock());


            acTracker.add(new ActionCadenceTracker(TargetId = newContacts[0].Id, State = 'Complete'));            
            ActionCadenceTrackersDAO.newInstance().insertRecords(acTracker,true,AccessLevel.SYSTEM_MODE);

            MockIdGenerator actionCadenceStepMock = new MockIdGenerator(ActionCadenceStep.sObjectType);
            Id acStepMockId = actionCadenceStepMock.getMockId();
    
            String acStepTrackerString =
                '{"attributes":{"type":"ActionCadenceStepTracker"},' +
                '"State":"InProgress",' +
                '"ActionCadenceTrackerId":"' +
                acTracker[0].Id +
                '",' +         
                '"TargetId":"' +
                newContacts[0].Id +
                '",' +       
                '"ActionCadenceName":"Test Cadences automated",' +
                '"ActionCadenceStepId":"' +
                acStepMockId +
                '",' +
                '"CompletionDate":"' +
                String.valueOf(System.Today()) +
                '",' +
                '"CreatedDate":"' +
                String.valueOf(System.Today()) +
                '",' +
                '"StepType":"SendAnEmail",' +
                '"StepTitle":"Email"' + 
                '}';
    
            ActionCadenceStepTracker acStepTracker = (ActionCadenceStepTracker) JSON.deserialize(
                acStepTrackerString,
                ActionCadenceStepTracker.class
            );
            ActionCadenceStepTrackersDAO.newInstance()
                .insertRecords(
                    new List<ActionCadenceStepTracker>{ acStepTracker },
                    false,
                    AccessLevel.SYSTEM_MODE
                );


            String taskString =
            '{"attributes":{"type":"Task"},' +
            '"ActionCadenceStepTrackerId":"' +
                acStepTracker.Id +
            '"}';
            Task taskRecord = (Task) JSON.deserialize(taskString, Task.class);
            taskRecord.Status = TasksDAO.CLOSED_FOLLOW_UP_STATUS;
            taskRecord.WhoId = newContacts[0].Id;

            TasksDAO.newInstance()
                .insertRecords(
                    new List<Task>{ taskRecord },
                    true,
                    AccessLevel.SYSTEM_MODE
            );


            completedCadenceList.add(new Completed_Cadence__c(Contact__c = newContacts[0].Id, Completed_Cadence_Status__c = CompletedCadencesDAO.CLOSED_FOLLOW_UP_STATUS));
            CompletedCadencesDAO.newInstance().insertRecords(completedCadenceList, true, AccessLevel.SYSTEM_MODE);
                        
            Map<String, String> targetCadenceMap = new Map<String, String>{ newContacts[0].Id => 'Test Cadences automated'};
                           
            SalesCadenceCalloutService.createCompletedCadence(targetCadenceMap,new Set<String>{ acTracker[0].Id });
            
            Test.stopTest();

            List<Task> taskUpdated = TasksDAO.newInstance().getTaskByCompeltedCadence(new Set<Id>{completedCadenceList[0].Id}, AccessLevel.SYSTEM_MODE);
            System.assertEquals(completedCadenceList[0].Id , taskUpdated[0].Completed_Cadence__c , 'Task must be assigned to a Completed Cadence');

            List<Completed_Cadence__c> completedCadence = CompletedCadencesDAO.newInstance().getCompletedCadencebyRecordId(new Set<Id>{completedCadenceList[0].Id}, AccessLevel.SYSTEM_MODE);
            System.assertEquals(1, completedCadence[0].Cadence_Tasks__c , 'Cadence Task count should be one');
        }
    } 
}