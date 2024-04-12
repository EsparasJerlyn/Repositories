/**
 * @description Test Class for WorkTypesDAO
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | nicole.genon                   | November 27, 2023     |DEPP-7259               | Created File                        |
 */
@isTest
public with sharing class WorkTypesDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Domestic_Future_Student_Agent' });
    }

    @isTest
    static void getWorkTypesBySetIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getDomesticFutureStudentAgent()) {
            List<WorkType> workTypeList = WorkTypesDAO.newInstance()
                .getWorkTypesBySetIds(new Set<Id>(), AccessLevel.SYSTEM_MODE);
            System.assert(workTypeList.isEmpty(), 'workTypeList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getWorkTypesBySetNamesTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getDomesticFutureStudentAgent()) {
            List<WorkType> workTypeList = WorkTypesDAO.newInstance()
                .getWorkTypesBySetNames(new Set<String>(), AccessLevel.SYSTEM_MODE);
            System.assert(workTypeList.isEmpty(), 'workTypeList is not empty');
        }
        Test.stopTest();
    }
}