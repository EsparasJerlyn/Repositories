/**
 * @description Test Class for ActionCadenceStepTrackerTriggerHandler
 *
 * @see ActionCadenceStepTrackerTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                           |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------------------|
 *    | mark.j.mahilum                 | Sept 04, 2023         | DEPP-6138              | created file                               |
 *    | roy.nino.s.regala              | May 29, 2024          | DEPP-8722              | converted to unit test and mock the class  |
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

    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Helper class is mocked, user will never create/update records.
    // With this user access cannot be tested
    static void testIsDisabled() {
        System.assertEquals(
            false,
            (new ActionCadenceStepTrackerTriggerHandler()).isDisabled(),
            'Trigger should not be disabled'
        );
    }

    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Helper class is mocked, user will never create/update records.
    // With this user access cannot be tested
    static void testAfterInsert() {
        ImplementationSelector.DAO.setMock(new ActionCadenceStepTrackersDAOMock());
        ImplementationSelector.DAO.setMock(new CommunicationQueuesDAOMock());
        ImplementationSelector.DAO.setMock(new TasksDAOMock());
        ImplementationSelector.DAO.setMock(new SMSTemplatesDAOMock());
        ImplementationSelector.DAO.setMock(new OrgWideEmailAddressesDAOMock());
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new LeadsDAOMock());

        MockIdGenerator actionCadenceStepMock = new MockIdGenerator(ActionCadenceStep.sObjectType);
        Id acStepMockId = actionCadenceStepMock.getMockId();

        String acStepTrackerString =
            '{"attributes":{"type":"ActionCadenceStepTracker"},' +
            '"State":"InProgress",' +
            '"ActionCadenceName":"Domestic",' +
            '"ActionCadenceStepId":"' +
            acStepMockId +
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

        // Create mock CREATE change event
        EventBus.ChangeEventHeader createHeader = new EventBus.ChangeEventHeader();
        createHeader.recordIds = new List<String>{ acStepTracker.Id };
        createHeader.changeType = 'CREATE';
        createHeader.entityName = 'ActionCadence';
        createHeader.changeOrigin = 'user1-wsl';
        createHeader.transactionKey = 'key';
        createHeader.commitUser = 'user1';
        ActionCadenceStepTrackerChangeEvent createEvent = new ActionCadenceStepTrackerChangeEvent();
        createEvent.changeEventHeader = createHeader;
        createEvent.put('ActionCadenceStepId', acStepMockId);
        createEvent.put('State', 'InProgress');
        createEvent.put('StepType', 'SendAnEmail');
        createEvent.put('StepTitle', 'Email');
        createEvent.put('DueDateTime', System.now());
        createEvent.put('ActionCadenceName', 'Domestic');

        String taskString =
            '{"attributes":{"type":"Task"},' +
            '"ActionCadenceStepTrackerId":"' +
            acStepTracker.Id +
            '"}';

        TasksDAO.newInstance()
            .insertRecords(
                new List<Task>{ (Task) JSON.deserialize(taskString, Task.class) },
                true,
                AccessLevel.SYSTEM_MODE
            );

        SMSTemplatesDAO.newInstance()
            .insertRecords(
                new List<SMS_Template__c>{
                    new SMS_Template__c(IsActive__c = true, Cadence_Step_Name__c = 'SMS')
                },
                false,
                AccessLevel.SYSTEM_MODE
            );

        OrgWideEmailAddressesDAO.newInstance()
            .insertRecords(
                new List<OrgWideEmailAddress>{
                    new OrgWideEmailAddress(
                        DisplayName = 'Domestic Future Student Enquiries',
                        Address = 'Test@email.com'
                    )
                },
                false,
                AccessLevel.SYSTEM_MODE
            );

        Map<Id, SObject> mockEvent = new Map<Id, SObject>();
        mockEvent.put(acStepMockId, createEvent);
        (new ActionCadenceStepTrackerTriggerHandler()).afterInsert(mockEvent);

        System.assert(
            !CommunicationQueuesDAO.newInstance()
                .getComminicationQueueRecordsByStatus(
                    new Set<String>{ CommunicationQueuesDAO.STATUS_SCHEDULED },
                    AccessLevel.SYSTEM_MODE
                )
                .isEmpty(),
            'There should be a scheduled communication queue record'
        );
    }
}
