/**
 * @description Test Class for SalesCadenceListViewCtrl
 *
 * @see SalesCadenceListViewCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | roy.nino.s.regala         | Aug 09,2023           | DEPP-5677    | Created file                                |
*/
@isTest
public with sharing class SalesCadenceListViewCtrlTest {
    @isTest
    // prettier-ignore
    static void getTableDataWrapperTest() {// NOPMD - test class is mocked
        List<Contact> contactList;
        List<Lead> leadList;
        Test.startTest();

        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new LeadsDAOMock());
        ImplementationSelector.DAO.setMock(new ActionCadenceTrackersDAOMock());
        ImplementationSelector.DAO.setMock(new CompletedCadencesDAOMock());

        contactList = TestDataFactory.createTestContactRecords(1);
        contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
        contactList[0].Calculated_Cadence__c = 'test cadence';
        ContactsDAO.newInstance().insertRecords(contactList,true,AccessLevel.USER_MODE);
        

        leadList = TestDataFactory.createTestLeadRecords(1);
        leadList[0].Lead_Type__c = 'Learner';
        leadList[0].Calculated_Cadence__c = 'test cadence';
        LeadsDAO.newInstance().insertRecords(leadList,true,AccessLevel.USER_MODE);
        Test.stopTest();
        System.assert(!SalesCadenceListViewCtrl.getTableDataWrapper('test cadence').isEmpty(), 'was not able to get table wrapper');
    }

    @isTest
    // prettier-ignore
    static void getTableDataWrapperWithActionCadenceTrackerTest() {// NOPMD - test class is mocked
        List<Contact> contactList;
        List<Lead> leadList;
        List<ActionCadenceTracker> acTracker = new List<ActionCadenceTracker>();
        Test.startTest();

        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new LeadsDAOMock());
        ImplementationSelector.DAO.setMock(new ActionCadenceTrackersDAOMock());
        ImplementationSelector.DAO.setMock(new CompletedCadencesDAOMock());

        contactList = TestDataFactory.createTestContactRecords(1);
        contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
        contactList[0].Calculated_Cadence__c = 'test cadence';
        ContactsDAO.newInstance().insertRecords(contactList,true,AccessLevel.USER_MODE);
        

        leadList = TestDataFactory.createTestLeadRecords(1);
        leadList[0].Lead_Type__c = 'Learner';
        leadList[0].Calculated_Cadence__c = 'test cadence';
        LeadsDAO.newInstance().insertRecords(leadList,true,AccessLevel.USER_MODE);

        acTracker.add(new ActionCadenceTracker(TargetId = contactList[0].Id, State = 'Running'));
        acTracker.add(new ActionCadenceTracker(TargetId = leadList[0].Id, State = 'Running'));

        ActionCadenceTrackersDAO.newInstance().insertRecords(acTracker,true,AccessLevel.USER_MODE);

        Test.stopTest();
        System.assert(SalesCadenceListViewCtrl.getTableDataWrapper('test cadence').isEmpty(), 'was able to get table wrapper');
    }

    @isTest
    // prettier-ignore
    static void getTableDataWrapperWithCompletedCadenceTest() {// NOPMD - test class is mocked
        List<Contact> contactList;
        List<Lead> leadList;
        List<Completed_Cadence__c> completedCadences = new List<Completed_Cadence__c>();
        Test.startTest();

        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new LeadsDAOMock());
        ImplementationSelector.DAO.setMock(new ActionCadenceTrackersDAOMock());
        ImplementationSelector.DAO.setMock(new CompletedCadencesDAOMock());

        MockIdGenerator builder = new MockIdGenerator(Nurture_Track_Configuration__c.sObjectType);

        contactList = TestDataFactory.createTestContactRecords(1);
        contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
        contactList[0].Calculated_Cadence__c = 'test cadence';
        ContactsDAO.newInstance().insertRecords(contactList,true,AccessLevel.USER_MODE);
        

        leadList = TestDataFactory.createTestLeadRecords(1);
        leadList[0].Lead_Type__c = 'Learner';
        leadList[0].Calculated_Cadence__c = 'test cadence';
        LeadsDAO.newInstance().insertRecords(leadList,true,AccessLevel.USER_MODE);

        completedCadences = TestDataFactory.createCompletedCadence('Unsuccessful', builder.getMockId(), new Set<Id>{leadList[0].Id, contactList[0].Id});

        CompletedCadencesDAO.newInstance().insertRecords(completedCadences,true,AccessLevel.USER_MODE);

        Test.stopTest();
        System.assert(SalesCadenceListViewCtrl.getTableDataWrapper('test cadence')[0].completedCadenceStatus == 'Unsuccessful', 'completed cadence is not successful');
    }

    @isTest
    // prettier-ignore
    static void updateCalculatedCadenceTest() {// NOPMD - test class is mocked
        List<Contact> contactList;
        List<Lead> leadList;
        

        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new LeadsDAOMock());
        ImplementationSelector.DAO.setMock(new ActionCadenceTrackersDAOMock());
        ImplementationSelector.DAO.setMock(new CompletedCadencesDAOMock());

        contactList = TestDataFactory.createTestContactRecords(1);
        contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
        contactList[0].Calculated_Cadence__c = 'test cadence';
        ContactsDAO.newInstance().insertRecords(contactList,true,AccessLevel.USER_MODE);
        

        leadList = TestDataFactory.createTestLeadRecords(1);
        leadList[0].Lead_Type__c = 'Learner';
        leadList[0].Calculated_Cadence__c = 'test cadence';
        LeadsDAO.newInstance().insertRecords(leadList,true,AccessLevel.USER_MODE);

        List<Map<String,String>> targetsToRemove = new List<Map<String,String>>();
        Test.startTest();
        targetsToRemove.add(new Map<String,String>{
            'targetId' => contactList[0].Id,
            'salesCadenceNameOrId' => ''
        });
        targetsToRemove.add(new Map<String,String>{
            'targetId' => leadList[0].Id,
            'salesCadenceNameOrId' => ''
        });
        SalesCadenceListViewCtrl.updateCalculatedCadence(JSON.serialize(targetsToRemove));
        Test.stopTest();
        System.assert(SalesCadenceListViewCtrl.getTableDataWrapper('test cadenc').isEmpty(), 'was able to get table wrapper');
    }

    @isTest
    // prettier-ignore
    static void createCompletedTaskTest() {// NOPMD - test class is mocked

        ImplementationSelector.DAO.setMock(new TasksDAOMock());
        ImplementationSelector.DAO.setMock(new ContactsDAOMock());

        List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
        contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
        contactList[0].Calculated_Cadence__c = 'test cadence';
        ContactsDAO.newInstance().insertRecords(contactList,true,AccessLevel.USER_MODE);

        List<Task> taskRecordsToInsert = TestDataFactory.createTaskRecords(1, new Map<String,String>{
            'Subject'=>'Removed from Cadence',
            'OwnerId'=>UserInfo.getUserId(),
            'Status'=>'Completed',
            'Priority'=>'Normal',
            'WhoId'=>contactList[0].Id,
            'Description'=>'test cadence'
        });

        Boolean creationSuccessful = true;

        Test.startTest();
        try{
            SalesCadenceListViewCtrl.createCompletedTask(taskRecordsToInsert);
        }catch(Exception e){
            creationSuccessful = false;
        }
        Test.stopTest();
        
        System.assert(creationSuccessful,'creation of task unnsuccessful');
    }

    @isTest
    // prettier-ignore
    static void assignToMeTest() {// NOPMD - test class is mocked

        List<Contact> contactList;
        List<Lead> leadList;

        ImplementationSelector.DAO.setMock(new ContactsDAOMock());
        ImplementationSelector.DAO.setMock(new LeadsDAOMock());
        ImplementationSelector.DAO.setMock(new ActionCadenceTrackersDAOMock());
        ImplementationSelector.DAO.setMock(new CompletedCadencesDAOMock());

        contactList = TestDataFactory.createTestContactRecords(1);
        contactList[0].RecordTypeId = ContactsDAO.PERSON_RECORDTYPE_ID;
        contactList[0].Calculated_Cadence__c = 'test cadence';
        ContactsDAO.newInstance().insertRecords(contactList,true,AccessLevel.USER_MODE);
        

        leadList = TestDataFactory.createTestLeadRecords(1);
        leadList[0].Lead_Type__c = 'Learner';
        leadList[0].Calculated_Cadence__c = 'test cadence';
        LeadsDAO.newInstance().insertRecords(leadList,true,AccessLevel.USER_MODE);

        List<Map<String,String>> targetsToEnroll = new List<Map<String,String>>();
        List<Map<String,String>> targetsToChange = new List<Map<String,String>>();
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        targetsToEnroll.add(new Map<String,String>{
            'targetId' => contactList[0].Id,
            'salesCadenceNameOrId' => 'test cadence',
            'userId' => UserInfo.getUserId()
        });
        targetsToEnroll.add(new Map<String,String>{
            'targetId' => leadList[0].Id,
            'salesCadenceNameOrId' => 'test cadence',
            'userId' => UserInfo.getUserId()
        });

        targetsToChange.add(new Map<String,String>{
            'targetId' => contactList[0].Id,
            'salesCadenceNameOrId' => 'test cadence edit'
        });
        targetsToChange.add(new Map<String,String>{
            'targetId' => leadList[0].Id,
            'salesCadenceNameOrId' => 'test cadence edit'
        });
        
        SalesCadenceListViewCtrl.assignToMe((List<Object>)targetsToEnroll,JSON.serialize(targetsToChange));

        Test.stopTest();

        System.assert(!SalesCadenceListViewCtrl.getTableDataWrapper('test cadence').isEmpty(), 'was not able to get table wrapper');
    }
}
