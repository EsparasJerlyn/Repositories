/**
 * @description Tests Controller Class for ActionCtrl
 * @see ActionCtrl
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.karl.munoz            | July 12, 2022         | DEPP-2035              | Created file                 | 
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Applied DAO framework        | 
 */
@isTest
public with sharing class ActionCtrlTest {
    @isTest
    // prettier-ignore
    static void getActionDetailsTest() {// NOPMD - test class is mocked
        List<Action__c> actionList;
        Test.startTest();

        ImplementationSelector.DAO.setMock(new ActionsDAOMock());
        ImplementationSelector.DAO.setMock(new ProductRequestsDAOMock());

        List<Product_Request__c> productRequestsList = TestDataFactory.createTestProductRequestRecordsByRecordType(
            1,
            ProductRequestsDAO.PR_EDUC_CONS_ID
        );
        ProductRequestsDAO.newInstance()
            .insertRecords(productRequestsList, false, AccessLevel.USER_MODE);

        actionList = ActionCtrl.getActionDetails(productRequestsList.iterator().next()?.Id);
        Test.stopTest();
        System.assert(!actionList.isEmpty(), 'was not able to get action records');
    }

    @isTest
    // prettier-ignore
    static void getActionDetailsErrorTest() {// NOPMD - test class is mocked
        Test.startTest();
        try {
            ImplementationSelector.DAO.setMock(new ActionsDAOMock());
            ActionCtrl.getActionDetails('error string');
        } catch (Exception e) {
            System.assert(e != null, 'no error');
        }
        Test.stopTest();
    }

    @isTest
    // prettier-ignore
    static void getInvestigationActionDetailsTest() {// NOPMD - test class is mocked
        List<Action__c> actionList;
        Test.startTest();

        ImplementationSelector.DAO.setMock(new ActionsDAOMock());
        ImplementationSelector.DAO.setMock(new ProductRequestsDAOMock());

        List<Product_Request__c> productRequestsList = TestDataFactory.createTestProductRequestRecordsByRecordType(
            1,
            ProductRequestsDAO.PR_EDUC_CONS_ID
        );
        ProductRequestsDAO.newInstance()
            .insertRecords(productRequestsList, false, AccessLevel.USER_MODE);

        actionList = ActionCtrl.getInvestigationActionDetails(
            productRequestsList.iterator().next()?.Id
        );
        System.assert(!actionList.isEmpty(), 'was not able to get action records');
        Test.stopTest();
    }

    @isTest
    // prettier-ignore
    static void getInvestigationActionDetailsErrorTest(){// NOPMD - test class is mocked
        Test.startTest();
        try{
            ImplementationSelector.DAO.setMock(new ActionsDAOMock());
            ActionCtrl.getInvestigationActionDetails('error string');
        }catch(Exception e){
            System.assert(e != null, 'no error');
        }
        Test.stopTest();
    }

    @isTest
    // prettier-ignore
    static void getActivitySectionDetailsTest() {// NOPMD - test class is mocked

        ActionCtrl.ActivitySectionDetails response = new ActionCtrl.ActivitySectionDetails();

        Test.startTest();

        ImplementationSelector.DAO.setMock(new ActionsDAOMock());
        ImplementationSelector.DAO.setMock(new ProductRequestsDAOMock());
        ImplementationSelector.DAO.setMock(new ConsultanciesDAOMock());

        List<Product_Request__c> productRequestsList = TestDataFactory.createTestProductRequestRecordsByRecordType(
            1,
            ProductRequestsDAO.PR_EDUC_CONS_ID
        );
        ProductRequestsDAO.newInstance()
            .insertRecords(productRequestsList, false, AccessLevel.USER_MODE);

        response = ActionCtrl.getActivitySectionDetails(productRequestsList.iterator().next()?.Id);

        Test.stopTest();

        System.assert(response != null, 'was not able to get action records');
    }

    @isTest
    // prettier-ignore
    static void getActivitySectionDetailsErrorTest(){// NOPMD - test class is mocked
        Test.startTest();
        try{
            ImplementationSelector.DAO.setMock(new ConsultanciesDAOMock());
            ActionCtrl.getActivitySectionDetails('error string');
        }catch(Exception e){
            System.assert(e != null, 'no error');
        }
        Test.stopTest();
    }

    @isTest
    // prettier-ignore
    static void getRelatedFilesByRecordIdTest() {//NOPMD - test class is mocked
        Map<Id, String> response = new Map<Id, String>();
        Test.startTest();

        ImplementationSelector.DAO.setMock(new ContentDocumentLinksDAOMock());
        ImplementationSelector.DAO.setMock(new ContentVersionsDAOMock());
        ImplementationSelector.DAO.setMock(new ProductRequestsDAOMock());
        ImplementationSelector.DAO.setMock(new ConsultanciesDAOMock());
        //Instantiate mockidgenerator for contentdocument object
        MockIdGenerator builder = new MockIdGenerator(ContentDocument.sObjectType);

        List<Product_Request__c> productRequestsList = TestDataFactory.createTestProductRequestRecordsByRecordType(
            1,
            ProductRequestsDAO.PR_EDUC_CONS_ID
        );

        ProductRequestsDAO.newInstance()
            .insertRecords(productRequestsList, false, AccessLevel.USER_MODE);

        List<Consultancy__c> consultancyList = new List<Consultancy__c>();
        consultancyList = TestDataFactory.createTestConsultancyRecords(
            1,
            productRequestsList.iterator().next()?.Id
        );
        ConsultanciesDAO.newInstance().insertRecords(consultancyList, false, AccessLevel.USER_MODE);
        //create content document link record with contentdocument mock id
        ContentDocumentLink contentDocumentLinkRecord = TestDataFactory.createTestContentDocumentLink(
            builder.getMockId(),
            consultancyList.iterator().next()?.Id
        );
        ContentDocumentLinksDAO.newInstance()
            .insertRecords(
                new List<ContentDocumentLink>{ contentDocumentLinkRecord },
                false,
                AccessLevel.USER_MODE
            );

        List<ContentVersion> contentVersionList = TestDataFactory.createTestContentVersionPDFRecords(
            1
        );
        for (ContentVersion conVersion : contentVersionList) {
            conVersion.ContentDocumentId = contentDocumentLinkRecord.ContentDocumentId;
        }

        ContentVersionsDAO.newInstance()
            .insertRecords(contentVersionList, false, AccessLevel.USER_MODE);

        response = ActionCtrl.getRelatedFilesByRecordId(consultancyList.iterator().next()?.Id);

        Test.stopTest();

        System.assert(!response.isEmpty(), 'No files uploaded');
    }

    @isTest
    // prettier-ignore
    static void getRelatedFilesByRecordIdErrorTest() {//NOPMD - test class is mocked
        Test.startTest();
        try {
            ImplementationSelector.DAO.setMock(new ContentDocumentLinksDAOMock());
            ActionCtrl.getRelatedFilesByRecordId('error string');
        } catch (Exception e) {
            System.assert(e != null, 'no error');
        }
        Test.stopTest();
    }
}
