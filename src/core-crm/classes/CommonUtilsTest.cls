@isTest
public with sharing class CommonUtilsTest {

    @testSetup static void setupMethod() {
        TestDataFactory.generateTestUsers();
    }

    @isTest
    static void addTestClass(){
    final User PORTAL_SYS_ADMIN = TestDataFactory.getPortalSysAdminUser();
        String retVal;
        System.runAs(PORTAL_SYS_ADMIN) {
            Test.startTest();
            retVal = CommonUtils.randomString(10);
            Test.stopTest();
        }

        System.assert(retVal != null, 'return value is null');
    }   

}