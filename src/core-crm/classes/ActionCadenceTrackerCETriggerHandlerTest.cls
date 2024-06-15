/**
 * @description Test Class for ActionCadenceTrackerCETriggerHandler
 * @see ActionCadenceTrackerCETriggerHandler
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | mark.j.mahilum            | Aug 18,2023           | DEPP-6215    | Created file                                |
*/
@isTest
private  class ActionCadenceTrackerCETriggerHandlerTest {

    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTESB();
    }
    
    @isTest static void testActionCadenceEvent() {
        
        List<ActionCadenceTracker> acTracker = new List<ActionCadenceTracker>();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {    
            Test.enableChangeDataCapture(); 
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
        }
        System.assert(!acTracker.isEmpty() , 'ActionCadenceTrackers record is not created');
        
        Test.enableChangeDataCapture();      
        // Create mock CREATE change event
        EventBus.ChangeEventHeader createHeader = new EventBus.ChangeEventHeader();
        createHeader.recordIds = new List<String>{ acTracker[0].Id };
        createHeader.changeType='CREATE';
        createHeader.entityName='ActionCadenceTracker';
        createHeader.changeOrigin='user1-wsl';
        createHeader.transactionKey = 'key';
        createHeader.commitUser = 'user1';
        ActionCadenceTrackerChangeEvent createEvent = new ActionCadenceTrackerChangeEvent();
        createEvent.changeEventHeader = createHeader;
        createEvent.put('State', 'Complete');
        createEvent.put('CompletionReason', 'AutomaticallyExited');
        EventBus.publish(createEvent);
        Test.getEventBus().deliver();
    }   

    // Ideally we should mock the SalesCadenceCalloutService and assert that we have called the method processCompletedCadenceTracker of the mock.
    // Hoever as the method processCompletedCadenceTracker is a static method, it is not doable unless we refactor the code.
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    @IsTest
    static void testAfterInsert() {
        // prepare data
        List<ActionCadenceTrackerChangeEvent> events = new List<ActionCadenceTrackerChangeEvent>();

        EventBus.ChangeEventHeader eventHeader = new EventBus.ChangeEventHeader();
        eventHeader.recordIds = new List<String>{ ActionCadenceTracker.getSObjectType().getDescribe().getKeyPrefix() + '000000000001'};
        eventHeader.changeType='CREATE';
        eventHeader.entityName='ActionCadenceTracker';
        eventHeader.changeOrigin='user1-wsl';
        eventHeader.transactionKey = 'key';
        eventHeader.commitUser = 'user1';

        ActionCadenceTrackerChangeEvent event = new ActionCadenceTrackerChangeEvent();
        event.changeEventHeader = eventHeader;
        event.put('State', 'Complete');
        event.put('CompletionReason', 'AutomaticallyExited');

        events.add(event);

        // test
        Map<Id, SObject> m = new Map<Id, SObject>();
        Id eventId = ActionCadenceTracker.getSObjectType().getDescribe().getKeyPrefix() + '000000000001'; // This is not a valid id of ActionCadenceTrackerChangeEvent, but our logic don't really use the id
        m.put(eventId, event);
        (new ActionCadenceTrackerCETriggerHandler()).afterInsert(m);

        ActionCadenceTrackerCETriggerHandler.processCompletedCadenceTracker(events);
    }

    @IsTest
    static void testIsDisabled() {
        Assert.areEqual(false, (new ActionCadenceTrackerCETriggerHandler()).isDisabled(), 'Trigger should not be disabled');
    }
}