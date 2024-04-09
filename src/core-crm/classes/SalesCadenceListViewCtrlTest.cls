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
      | roy.nino.s.regala         | Sep 22, 2023          | DEPP-6365    | remove unused method                        |
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
    static void assignToCadenceTest() {// NOPMD - test class is mocked

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
        
        SalesCadenceListViewCtrl.assignToCadence((List<Object>)targetsToEnroll,JSON.serialize(targetsToChange));

        Test.stopTest();

        System.assert(!SalesCadenceListViewCtrl.getTableDataWrapper('test cadence').isEmpty(), 'was not able to get table wrapper');
    }

    @isTest
    // prettier-ignore
    static void validateTargetsToAssignTest() {// NOPMD - test class is mocked
        List<Contact> contactList;
        List<Lead> leadList;
        List<Completed_Cadence__c> completedCadenceList;

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

        completedCadenceList = TestDataFactory.createCompletedCadence('Unsuccessful',null,new Set<Id>{contactList[0].Id});
        CompletedCadencesDAO.newInstance().insertRecords(completedCadenceList,true,AccessLevel.USER_MODE);

        System.assertEquals(
            2,
            SalesCadenceListViewCtrl.validateTargetsToAssign(new List<Id>{contactList[0].Id,leadList[0].Id},'test cadence').size(),
            'should get the right number of target ids after validation'
        );
    }

    @isTest
    // prettier-ignore
    static void validateTargetsToAssignWithCompletedCadenceTest() {// NOPMD - test class is mocked
        List<Contact> contactList;
        List<Lead> leadList;
        List<Completed_Cadence__c> completedCadenceList;

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

        completedCadenceList = TestDataFactory.createCompletedCadence('Successful',null,new Set<Id>{contactList[0].Id});
        CompletedCadencesDAO.newInstance().insertRecords(completedCadenceList,true,AccessLevel.USER_MODE);

        System.assertEquals(
            1,
            SalesCadenceListViewCtrl.validateTargetsToAssign(new List<Id>{contactList[0].Id,leadList[0].Id},'test cadence').size(),
            'should get the right number of target ids after validation'
        );
    }

    @isTest
    private static void testConvertDateTime() {
        TestDataFactory.generateTestUsers(new List<String>{'Future_Student_Agent_Domestic'});

        Datetime actualDatetime;

        // 2023-11-23 15:00:00 in GMT, which is 2023-11-24 01:00:00 in BNE time
        Datetime rawDateTime = Datetime.newInstanceGmt(2023, 11, 23, 15, 0, 0);

        System.runAs(TestDataFactory.getDomesticFutureStudentAgent()) {
            Test.startTest();
            actualDatetime = SalesCadenceListViewCtrl.convertDatetime(rawDateTime);
            Test.stopTest();
        }
        
        /*
            This rely on that fact that the TestDataFactory.TestUserGenerator.generateUsers() is setting the TimeZoneSidKey as 'Australia/Brisbane'
            If the timezone setting of the test user is changed, this test may break

        */
        Assert.areEqual(24, actualDatetime.day(), 'Day of month should be 24 in BNE timezone');
    }


    @istest
    private static void getRecentlyViewedTest(){
        TestDataFactory.generateTestUsers(new List<String>{'Future_Student_Agent_Domestic'});

        System.runAs(TestDataFactory.getDomesticFutureStudentAgent()){
            Test.startTest();
            System.assertEquals(0, SalesCadenceListViewCtrl.getRecentlyViewed('Domestic').size(), 'recentlyviewed should be empty');
            Test.stopTest();
        }
    }

    @istest
    private static void checkUserRoleTest(){
        TestDataFactory.generateTestUsers(new List<String>{'Future_Student_Agent_Domestic'});

        System.runAs(TestDataFactory.getDomesticFutureStudentAgent()){
            Test.startTest();
            System.assertEquals(false, SalesCadenceListViewCtrl.checkUserRole(), 'Return should be false');
            Test.stopTest();
        }
    }

    @istest
    private static void getSearchedUsersTest(){
        TestDataFactory.generateTestUsers(new List<String>{'Future_Student_Agent_Domestic','QUT_ESB'});

        System.runAs(TestDataFactory.getESBIntegrationUser()){
            Test.startTest();
            System.assertEquals(1, SalesCadenceListViewCtrl.getSearchedUsers('QUT','Domestic').size(), 'there should be 1 user queried');
            Test.stopTest();
        }
    }
    
}
