@isTest(SeeAllData=false)

public with sharing class CommonUtilsTest {

    @IsTest
    static void addTestClass(){
        Test.startTest();
		CommonUtils.randomString(10);
        Test.stopTest();
    }   
}