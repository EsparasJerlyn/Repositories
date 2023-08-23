/**
* @description TriggerHandler Class for IP Management Relationnship Trigger
* @see ..IPManagementRelationshipTrigger
*
* @author Accenture
*
* @history
*
    | Developer Email                | Date                  | JIRA                   | Change Summary                                                                |
    |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------------------------|
    | eugene.andrew.abuan            | August 14, 2023       | DEPP-6331              | Created file                                                                  |

*/
@isTest
public with sharing class IPManagementRelationTriggerHandlerTest {
    @testSetup
    static void setup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Operations_Manager' });
        Opportunity_Outcome_Code_Auto_Number__c oppOutcomeCodeAutoNum = OpportunityOutcomeCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
        oppOutcomeCodeAutoNum.Start_Up__c = 1;
        OpportunityOutcomeCodeAutoNumbersDAO.newInstance()
        .insertRecords(
            new List<Opportunity_Outcome_Code_Auto_Number__c>{ oppOutcomeCodeAutoNum },
            false,
            AccessLevel.USER_MODE
        );
    }

    @isTest
    private static void testPlatformEventInsertAndUpdate() {
        System.runAs(testDataFactory.getOperationsManager()) {
            // Create Opportunity Outcome Records
            List<Opportunity_Outcome__c> opportunityOutcomeRecords = TestDataFactory.createTestOpportunityOutcomeRecords(
                1, 
                'RPP', 
                OpportunityOutcomesDAO.RESEARCHPARTNERSHIPPROJECT_RECTYPE_ID);
            
            OpportunityOutcomesDAO.newInstance().
                insertRecords(opportunityOutcomeRecords, false,AccessLevel.USER_MODE);

            //Create IP Management Record
            List <IP_Management__c> ipManagementRecords = TestDataFactory.createIPManagement(
                1,
                IPManagementsDAO.PATENT_RECTYPE_ID
            );

            IPManagementsDAO.newInstance()
                .insertRecords(ipManagementRecords, false, AccessLevel.USER_MODE);

            Test.startTest();
            //Create IP Management Relationship for Opportunity Outcome 
            List<IP_Management_Relationship__c> newIPManagementRelationshipRecords = TestDataFactory.createIPManagementRelationshipsForOpportunityOutcome(
                100,
                opportunityOutcomeRecords[0].Id,
                ipManagementRecords[0].Id,
                IPManagementRelationshipsDAO.IP_OPPORTUNITY_OUTCOME_RELATIONSHIP_RECTYPE_ID
            );

            System.assert(
                IPManagementRelationshipsDAO.newInstance()
                        .insertRecords(newIPManagementRelationshipRecords, false, AccessLevel.USER_MODE)[0]
                    .isSuccess(),
                'IP Management Relationship is not created'
            );
            
            for(IP_Management_Relationship__c ipManagementRecordToUpdate :newIPManagementRelationshipRecords){
                ipManagementRecordToUpdate.Is_Active__c = false;
            }

            System.assert(
                IPManagementRelationshipsDAO.newInstance()
                        .updateRecords(newIPManagementRelationshipRecords, false, AccessLevel.SYSTEM_MODE)[0]
                    .isSuccess(),
                'IP Management Relationship is not updated'
            );
        }
    }
}