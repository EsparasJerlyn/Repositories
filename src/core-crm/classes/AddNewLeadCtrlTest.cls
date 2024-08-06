/**
 * @description Test Class for AddNewLeadCtrl
 * @see ../lwc/AddNewLead
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | gabriel.p.ventayen        | Aug 06, 2024          | DEPP-10224           | Created file                 | 
 */
@isTest
public with sharing class AddNewLeadCtrlTest {
    
    @testSetup
    static void setupMethod(){
        Test.startTest();
        TestDataFactoryUser.generateUserSystemAdministrator();
        Test.stopTest();

        VoiceCall newVoiceCall = new VoiceCall();
        newVoiceCall.VendorType = 'ContactCenter';
        newVoiceCall.CallCenterId = '04v9r0000005E3xAAE';
        newVoiceCall.CallStartDateTime = System.Today();
        newVoiceCall.CallEndDateTime = System.Today();
        newVoiceCall.FromPhoneNumber = '+61370000000';
        newVoiceCall.ToPhoneNumber = '+61370000000';
        newVoiceCall.CallType = 'Inbound';
        insert newVoiceCall;

        Lead newLead = new Lead();
        newLead.FirstName = 'FirstTest';
        newLead.LastName = 'LastTest';
        newLead.Company = 'TestCompany';
        insert newLead;

        List<Case> newCases = TestDataFactory.createTestCaseRecords(1,null,null);
        newCases[0].Case_Type__c = 'Public Enquiry';
        insert newCases;

        List<Contact> conList;
        conList = TestDataFactory.createTestContactRecords(1);
        insert conList;

        MessagingSession newMessagingSession = new MessagingSession();
        newMessagingSession.MessagingChannelId = '0Mj9r000000F1LZCA0'; 
        newMessagingSession.MessagingEndUserId = '0PA9r0000017FRZGA2';
        newMessagingSession.Status = 'Active';
        newMessagingSession.Messaging_Session_Wrap_Up_Code__c = 'New Enquiry'; 
        newMessagingSession.ConversationId = 
        newMessagingSession.Related_Case__c = newCases[0].Id;
        newMessagingSession.Related_Contact__c = conList[0].Id;
        insert newMessagingSession;

        
    }

    @isTest
    static void addNewLeadVCTest(){                
        String response;
        String recordLeadId;
        String recordVCId;
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator){
            recordVCId = [SELECT Id FROM VoiceCall LIMIT 1].Id;
            recordLeadId = [SELECT Id FROM Lead LIMIT 1].Id;
            response = AddNewLeadCtrl.updateVoiceCallRelatedLead(recordVCId, recordLeadId);
        }          
        Test.stopTest();
        System.assertEquals('Success', response, 'Failed to update VoiceCall Record.');        
    }
    @isTest
    static void addNewLeadMSTest(){                
        String response;
        String recordLeadId;
        String recordMSId;
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator){
            recordMSId = [SELECT Id FROM MessagingSession LIMIT 1].Id;
            recordLeadId = [SELECT Id FROM Lead LIMIT 1].Id;
            response = AddNewLeadCtrl.updateMessagingSessionRelatedLead(recordMSId, recordLeadId);
        }          
        Test.stopTest();
        System.assertEquals('Success', response, 'Failed to update VoiceCall Record.');        
    }
}