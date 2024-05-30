/**
 * @description Test Class for ActionCadenceStepTrackerTriggerHandler 
 *
 * @see ActionCadenceStepTrackerTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------------------|
 *    | mark.j.mahilum                 | Sept 04, 2023         | DEPP-6138              | created file                               |
 */
@isTest
private class ActionCadenceStepTrackerTriggerTest {

    @isTest static void testActionStepCadenceEvent() { //NOPMD class is mocked no need for running user        
        List<ActionCadenceStepTracker> acTracker = new List<ActionCadenceStepTracker>();       
        ImplementationSelector.DAO.setMock(new ActionCadenceStepTrackersDAOMock());              
        acTracker = ActionCadenceStepTrackersDAO.newInstance().getActionCadenceStepTrackerForEmail(new List<String>(), AccessLevel.SYSTEM_MODE);            
        System.assert(!acTracker.isEmpty() , 'ActionCadenceTrackers record is empty');
        
        Test.enableChangeDataCapture();
        // Create mock CREATE change event
        EventBus.ChangeEventHeader createHeader = new EventBus.ChangeEventHeader();
        createHeader.recordIds = new List<String>{ acTracker[0].Id};
        createHeader.changeType='CREATE';
        createHeader.entityName='ActionCadence';
        createHeader.changeOrigin='user1-wsl';
        createHeader.transactionKey = 'key';
        createHeader.commitUser = 'user1';
        ActionCadenceStepTrackerChangeEvent createEvent = new ActionCadenceStepTrackerChangeEvent();
        createEvent.changeEventHeader = createHeader;
        createEvent.put('ActionCadenceStepId', acTracker[0].ActionCadenceTrackerId);
        createEvent.put('State', 'InProgress');
        createEvent.put('StepType', 'SendAnEmail');
        createEvent.put('StepTitle', 'Email');  
        Test.startTest();      
        // Publish test event
        Database.SaveResult sr = EventBus.publish(createEvent);        
        Test.stopTest();
        
        // Verify SaveResult value
        System.assertEquals(true, sr.isSuccess(), 'Cadence step tracker event is not created.');
        Test.getEventBus().deliver();                 
    }
}