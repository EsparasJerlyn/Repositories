/**
 * @description Test Class for Update Latest Queue Name Field Flow
 *
 * @see ../flows/Update_Latest_Queue_Name_Field
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | rhea.b.torres             | October 26 , 2021     | DEPP-4528    | Created file                                | 
*/
@isTest
private class Update_Latest_Queue_Name_Field_FlowTest {
    
    @testSetup
    static void makeData(){
        // Test Users
        TestDataFactory.generateTestUsers();

        // Queue
        Group groupRec = new Group(Name='Dummy Queue', DeveloperName='Dummy_Queue', Type='Queue');
        insert groupRec;
        QueuesObject queueSObject = new QueueSObject(QueueID = groupRec.id, SobjectType = 'Case');
        insert queueSObject;
    }

    /**@description Created a Case record with Assignment Rule being executed. Update the OwnerId of the Case record to a Queue.
     * Expectation: Latest_Queue_Name__c should be equal to the Queue assigned
    */
    @isTest
    static void updateCaseOwnerToQueueTest(){
        Test.startTest();
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('International_Enquiry').getRecordTypeId();
        Group dummyQueue = [Select Id, Name, type FROM Group Where Type='Queue' AND DeveloperName='Dummy_Queue' LIMIT 1];
        System.runAs(TestDataFactory.getISRStudentEnquiriesCommunicationOfficer()){
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true;
            List<Case> caseList = TestDataFactory.createTestCaseRecords(recordTypeId, 'My Case - ', 10);
            for(Case caseRec : caseList){
                caseRec.setOptions(dmo);
            }
            insert caseList;

            List<Case> caseList2 = [SELECT Id, OwnerId, Owner.Name, Latest_Queue_Name__c, CaseNumber FROM Case];            
            for(Case caseRec : caseList2){
                caseRec.OwnerId = dummyQueue.Id;
            }
            update caseList2;
        }

        List<Case> resultList = [SELECT Id, Subject, Owner.Name, Latest_Queue_Name__c FROM Case];
        for(Case resultCase : resultList){
            System.assertEquals(dummyQueue.Name, resultCase.Latest_Queue_Name__c, 'Latest_Queue_Name__c not set to updated case owner queue');
        }
        Test.stopTest();
    }
    
    /**@description Created a Case record with Assignment Rule being executed. Update the OwnerId of the Case record to a any User.
     * Expectation: Latest_Queue_Name__c should still be equal to the Queue assigned by the Assignment Rule which is "International Enquiries"
    */
    @isTest
    static void updateCaseOwnerToUserTest(){
        Test.startTest();
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('International_Enquiry').getRecordTypeId();
        User secoUser = TestDataFactory.getISRStudentEnquiriesCommunicationOfficer();
        System.runAs(secoUser){
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true;
            List<Case> caseList = TestDataFactory.createTestCaseRecords(recordTypeId, 'My Case - ', 10);
            for(Case caseRec : caseList){
                caseRec.setOptions(dmo);
            }
            insert caseList;
            
            List<Case> caseList2 = [SELECT Id, OwnerId, Owner.Name, Latest_Queue_Name__c, CaseNumber FROM Case];
            
            for(Case caseRec : caseList2){
                caseRec.OwnerId = secoUser.Id;
            }
            update caseList2;
        }

        Group internationalEnqQueue = [Select Id, Name FROM Group Where Type='Queue' AND DeveloperName='International_Enquiries' LIMIT 1];
        List<Case> resultList = [SELECT Id, Subject, Owner.Name, Latest_Queue_Name__c FROM Case];
        for(Case resultCase : resultList){
            System.assertEquals(internationalEnqQueue.Name, resultCase.Latest_Queue_Name__c, 'Latest_Queue_Name__c was updated.');
        }
        Test.stopTest();
    }

    /**@description Created a Case record with Assignment Rule being executed. Update any fields of the Case record.
     * Expectation: Latest_Queue_Name__c should not changed
    */
    @isTest
    static void updateOtherFieldsTest(){
        Test.startTest();
        Group internationalEnqQueue = [Select Id, Name FROM Group Where Type='Queue' AND DeveloperName='International_Enquiries' LIMIT 1];
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('International_Enquiry').getRecordTypeId();
        User secoUser = TestDataFactory.getISRStudentEnquiriesCommunicationOfficer();
        System.runAs(secoUser){
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true;
            List<Case> caseList = TestDataFactory.createTestCaseRecords(recordTypeId, 'My Case - ', 10);
            for(Case caseRec : caseList){
                caseRec.setOptions(dmo);
            }
            insert caseList;
            
            List<Case> caseList2 = [SELECT Id, OwnerId, Owner.Name, Latest_Queue_Name__c, CaseNumber FROM Case];
            
            for(Case caseRec : caseList2){
                caseRec.Origin = 'Email';
            }
            update caseList2;
        }

        List<Case> resultList = [SELECT Id, Subject, Owner.Name, Latest_Queue_Name__c FROM Case];
        for(Case resultCase : resultList){
            System.assertEquals(internationalEnqQueue.Name, resultCase.Latest_Queue_Name__c, 'Latest_Queue_Name__c should not be changed');
        }
        Test.stopTest();
    }

    /**@description This scenario covers Case record creation not created from an active assignment rule
    */
    @isTest
    static void createCaseFromNonActiveAssignmentRule(){
        Test.startTest();
        Group internationalEnqQueue = [Select Id, Name FROM Group Where Type='Queue' AND DeveloperName='International_Enquiries' LIMIT 1];
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('International_Enquiry').getRecordTypeId();
        User secoUser = TestDataFactory.getISRStudentEnquiriesCommunicationOfficer();
        System.runAs(secoUser){
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= false;
            List<Case> caseList = TestDataFactory.createTestCaseRecords(recordTypeId, 'My Case - ', 10);
            for(Case caseRec : caseList){
                caseRec.setOptions(dmo);
            }
            insert caseList;
        }

        List<Case> resultList = [SELECT Id, Subject, Owner.Name, Latest_Queue_Name__c FROM Case];
        for(Case resultCase : resultList){
            System.assertEquals(internationalEnqQueue.Name, resultCase.Latest_Queue_Name__c, 'Latest_Queue_Name__c was updated.');
        }
        Test.stopTest();
    }
    
}