/**
 * @description Test Class for ActionCadenceStepTrackerTriggerHelper 
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
private class ActionCadenceSTTriggerHelperTest {
    
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserSystemAdministrator();
    }
    
    @isTest static void testInsertCommunicationQueueCreation() {
        List<ActionCadenceStepTracker> acTracker = new List<ActionCadenceStepTracker>();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            ImplementationSelector.DAO.setMock(new ActionCadenceStepTrackersDAOMock());              
            acTracker = ActionCadenceStepTrackersDAO.newInstance().getActionCadenceStepTrackerForEmail(new List<String>(), AccessLevel.SYSTEM_MODE);                                                
        }
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
        createEvent.put('DueDateTime', System.now());
        createEvent.put('ActionCadenceName', 'Domestic');
        Test.startTest();      
        // Publish test event
        EventBus.publish(createEvent);      
        Test.stopTest();
             
        // validate if communication queue is created 
        System.assert(!acTracker.isEmpty() , 'ActionCadenceTrackers record is empty');       
    } 
    
    @isTest static void testInsertSMSCommunicationQueueCreation() {
        List<ActionCadenceStepTracker> acTracker = new List<ActionCadenceStepTracker>();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            ImplementationSelector.DAO.setMock(new ActionCadenceStepTrackersDAOMock());              
            acTracker = ActionCadenceStepTrackersDAO.newInstance().getActionCadenceStepTrackerForEmail(new List<String>(), AccessLevel.SYSTEM_MODE);   
            
            List<SMS_Template__c> smsTemplate = new List<SMS_Template__c>();
            smsTemplate.add(
                new SMS_Template__c(
                    Cadence_Step_Name__c = 'SendSMS',
                	IsActive__c = true,
                    Business_Process__c = 'Domestic Automated Cadence SMS',
                    Message_Content__c = 'Test SMS'
                )
            );

            SMSTemplatesDAO.newInstance().insertRecords(smsTemplate, false, AccessLevel.SYSTEM_MODE);
            
        }
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
        createEvent.put('StepTitle', 'SendSMS');  
        createEvent.put('DueDateTime', System.now());
        createEvent.put('ActionCadenceName', 'Domestic');
        Test.startTest();      
        // Publish test event
        EventBus.publish(createEvent);      
        Test.stopTest();          
        // validate if communication queue is created 
        System.assert(!acTracker.isEmpty() , 'ActionCadenceTrackers record is empty');      
    }
}