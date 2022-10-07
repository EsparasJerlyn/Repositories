@isTest
public with sharing class CommonUtilsTest {

    @isTest
    static void addTestClass(){

        Test.startTest();
		CommonUtils.randomString(10);
        Test.stopTest();

    }   

}