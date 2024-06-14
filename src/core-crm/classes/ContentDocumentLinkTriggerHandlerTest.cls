/**
 * @description trigger handler for ContentDocumentLink
 * @see ContentDocumentLinkTrigger
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                     |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------------------------|
      | carl.alvin.cabiles             | June 28, 2023         | DEPP-5388              | Created file                                                       |
 */
@isTest
public class ContentDocumentLinkTriggerHandlerTest {
    @testSetup
    static void testSetup() {
        //setup for auto number
        Opportunity_Code_Auto_Number__c opptyCodeAutoNum = OpportunityCodeAutoNumbersDAO.newInstance()
            .getOrganizationalDefaults();
        opptyCodeAutoNum.Commercialisation__c = 1;
        opptyCodeAutoNum.International_Projects_Unit__c = 1;
        opptyCodeAutoNum.Research_Partnership__c = 1;
        OpportunityCodeAutoNumbersDAO.newInstance()
            .upsertRecords(
                new List<Opportunity_Code_Auto_Number__c>{ opptyCodeAutoNum },
                false,
                AccessLevel.USER_MODE
            );
        Test.startTest();
        TestDataFactoryUser.generateUserIndustryPartnershipManager();
        Test.stopTest();
    }

    @isTest
    private static void checkMemoStatusAndMemoPDFURL() {
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager){
            String baseUrl =
            SYSTEM.URL.getSalesforceBaseUrl()
                .toExternalForm()
                .removeEndIgnoreCase('.my.salesforce.com') +
            '.lightning.force.com/lightning/r/ContentDocument/';
            
            List<Opportunity> opportunityList = new List<Opportunity>();
            opportunityList = TestDataFactory.createOpportunityRecords(1, 'Opportunity', 'Development');
            OpportunitiesDAO.newInstance().insertRecords(opportunityList, false, AccessLevel.USER_MODE);
            List<ContentVersion> contentVersionRecords = TestDataFactory.createTestContentVersionRecordsWithMemoTitle(
                1
            );
            ContentVersionsDAO.newInstance()
                .insertRecords(contentVersionRecords, false, AccessLevel.USER_MODE);
             ContentVersion contentVersion = ContentVersionsDAO.newInstance()
                .getContentVersionByTitle(new Set<String>{ 'QUT MEMO_Opportunity0' })
                .iterator()
                .next();
            Id oppId = opportunityList.iterator().next()?.Id;
    
            Test.startTest();
            ContentDocumentLink contentDocumentLink = TestDataFactory.createTestContentDocumentLink(
                contentVersion.ContentDocumentId,
                oppId
            );
            ContentDocumentLinksDAO.newInstance()
                .insertRecords(
                    new List<ContentDocumentLink>{ contentDocumentLink },
                    false,
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            Opportunity opp = OpportunitiesDAO.newInstance()
                .getRecordsBySetIds(new Set<id>{ oppId })
                .iterator()
                .next();
            System.assertEquals(
                baseUrl + contentVersion.ContentDocumentId + '/view',
                opp.Memo_PDF_URL__c,
                'Not Equal'
            );
            System.assertEquals('Generated', opp.Memo_Status__c, 'Not Equal');
        }
    }
}