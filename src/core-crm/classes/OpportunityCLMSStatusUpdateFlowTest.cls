/**
* @description Test Class for Opportunity CLMS Status Update Flow
*
* @author Accenture
*
* @history
*
*    | Developer Email                | Date                  | JIRA                   | Change Summary               |
     |--------------------------------|-----------------------|------------------------|------------------------------|
     | kenneth.f.alsay                | November 14,2023      | DEPP-6940              | Created file                 |
*/
@isTest
public class OpportunityCLMSStatusUpdateFlowTest {

    @testSetup 
    static void setupMethod(){
        Test.startTest();
        TestDataFactoryUser.generateUserCorporatePartnershipsManager();
        Test.stopTest();

        Id corporateOppId = OpportunitiesDAO.CORPORATEPARTNERSHIP_RECTYPE_ID;
        System.RunAs(TestDataFactoryUser.selectUserCorporatePartnershipsManager){
            List<Opportunity> corpPartnershipOpp = TestDataFactory.createOpportunityRecords(200, 'Opportunity', 'Contract');
            for(Opportunity opp : corpPartnershipOpp){
            	opp.RecordTypeId = corporateOppId;
                opp.CLMS_Contract_ID__c = '';
                opp.CLMS_Contract_Status__c = '';
            }
            OpportunitiesDAO.newInstance().insertRecords(corpPartnershipOpp, false, AccessLevel.USER_MODE);
        }
    }
        
    @isTest
    static void testCLMSUpdate(){
        System.RunAs(TestDataFactoryUser.selectUserCorporatePartnershipsManager){
        	Test.startTest();
            List<Opportunity> oppList = [SELECT Id, CLMS_Contract_ID__c, CLMS_Contract_Status__c, StageName, Name FROM Opportunity];
            for(Opportunity opp : oppList){
                opp.CLMS_Contract_ID__c = 'TestCLMSContractID';
            }
            OpportunitiesDAO.newInstance().updateRecords(oppList, false, AccessLevel.USER_MODE);
            List<Opportunity> oppListResult = [SELECT Id, Name, CLMS_Contract_Status__c FROM Opportunity WHERE CLMS_Contract_Status__c = 'Negotiation'];
            System.assertEquals(200, oppListResult.size(), 'List must be 200');
            Test.stopTest();
        }
    }
}