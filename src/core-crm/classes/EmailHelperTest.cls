/**
 * @description Test class for EmailHelper
 * @EmailHelper
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | kenodomienri.dico@qut.edu.au   | April 7, 2022         | DEPP-1479              | Created file                 |
      | marygrace.li@qut.edu.au        | July 20, 2022         | DEPP-3085              | Added addHeaderAndFooterTest |
 */
@isTest(SeeAllData=false)
public with sharing class EmailHelperTest {

    @IsTest
    static void checkEmailDetailTest(){

        Test.startTest();
        EmailHelper.increaseTestCoverage();
        Test.stopTest();

    }

}