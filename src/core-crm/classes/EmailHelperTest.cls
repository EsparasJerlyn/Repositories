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
 */
@isTest
public with sharing class EmailHelperTest {

    @isTest
    static void setBodyValuesWithHeaderFooterTest(){
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

    @isTest
    static void attachementBuilderTest(){
        Messaging.EmailFileAttachment result;
        String fileName = 'myAttachment';
        String emailHtml = '<body>Please see attachment.</body>';
        Map<String,String> emailContent = new Map<String, String>{'LastName' => 'Loreen','FirstName' => 'Red'};
        Test.startTest();
        result = EmailHelper.attachementBuilder(fileName,emailHtml,emailContent);
        Test.stopTest();
        System.assert(result != null, 'result is null');
    }

    @isTest
    static void emailBuilderTest(){
        Messaging.SingleEmailMessage mail;
        String subject = 'Welcome to ABC Corp';
        String email = 'Welcome Email';
        String emailHtml = '<body>Please see attachment.</body>';
        Map<String,String> emailContent = new Map<String, String>{'LastName' => 'Loreen','FirstName' => 'Red'};
        Test.startTest();
        mail = EmailHelper.emailBuilder(email,subject,emailHtml,emailContent);
        Test.stopTest();
        System.assert(mail != null, 'no mail is created');
    }

    @isTest
    static void emailBuilderWithOWEATest(){
        Messaging.SingleEmailMessage mail;
        List<String> emailAddresses = new List<String>{'testMail01@test.com', 'testMail02@test.com'};
        String subject = 'Welcome to ABC Corp';
        String email = 'Welcome Email';
        String emailHtml = '<body>Please see attachment.</body>';
        Map<String,String> emailContent = new Map<String, String>{'LastName' => 'Loreen','FirstName' => 'Red'};
        Test.startTest();
        Id owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'QUTeX' LIMIT 1]?.Id;
        mail = EmailHelper.emailBuilder(emailAddresses,subject,emailHtml,emailContent,String.valueOf(owea));
        Test.stopTest();
        System.assert(mail != null, 'no mail is created');
    }

    @isTest
    static void emailBuilderNoBannerTest(){
        Messaging.SingleEmailMessage mail;
        String subject = 'Welcome to ABC Corp';
        String email = 'Welcome Email';
        String emailHtml = '<body>Please see attachment.</body>';
        Map<String,String> emailContent = new Map<String, String>{'LastName' => 'Loreen','FirstName' => 'Red'};
        Test.startTest();
        mail = EmailHelper.emailBuilderNoBanner(email,subject,emailHtml,emailContent);
        Test.stopTest();
        System.assert(mail != null, 'no mail is created');
    }

    @isTest	
    static void emailBuilderNoBannerWithOWEATest(){
        Messaging.SingleEmailMessage mail;
        List<String> emailAddresses = new List<String>{'testMail01@test.com', 'testMail02@test.com'};
        String subject = 'Welcome to ABC Corp';
        String email = 'Welcome Email';
        String emailHtml = '<body>Please see attachment.</body>';
        Map<String,String> emailContent = new Map<String, String>{'LastName' => 'Loreen','FirstName' => 'Red'};
        Test.startTest();
        Id owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'QUTeX' LIMIT 1]?.Id;
        mail = EmailHelper.emailBuilderNoBanner(emailAddresses,subject,emailHtml,emailContent,String.valueOf(owea));
        Test.stopTest();
        System.assert(mail != null, 'no mail is created');
    }
}