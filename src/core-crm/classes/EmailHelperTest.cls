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
      | rhea.b.torres                  | October 2, 2022       | DEPP-3399              | Raised apex test coverage    |
      | alexander.cadalin              | March 23, 2023        | n/a                    | PMD - ExcessiveParameterList |
 */
@isTest
public with sharing class EmailHelperTest {

    @testSetup static void setupMethod() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    static void setBodyValuesTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            String body = 'Dear {LastName}, {FirstName}. Hello. Welcome. Thank you. Good bye, {FirstName}.';
            Map<String, String> params = new Map<String, String>{
                '{LastName}' => 'Smithers',
                '{FirstName}' => 'Dei'
            };
            Test.startTest();
            String htmlBody = EmailHelper.setBodyValues(body, params, true);
            Test.stopTest();
            String bodyHardCoded = 'Dear Smithers, Dei. Hello. Welcome. Thank you. Good bye, Dei.';
            String htmlBodyExpected = EmailHelper.addHeaderAndFooter(bodyHardCoded);
            System.assertEquals(htmlBodyExpected, htmlBody, 'The values set in the html body is incorrect.');
        }
    }

    @isTest
    static void setBodyValuesWithHeaderFooterTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            String emailBody = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ' +
                                'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure' +
                                ' dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non' + 
                                ' proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';
            Test.startTest();
            String result = EmailHelper.addHeaderAndFooter(emailBody);
            Test.stopTest();
            System.assert(result != null, 'result is null');
            System.assert(result.length() > 0, 'result is empty');
        }
    }
}