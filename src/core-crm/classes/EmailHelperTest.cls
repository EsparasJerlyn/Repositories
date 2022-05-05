/**
 * @description Test class for EmailHelper
 * @EmailHelper
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | kenodomienri.dico@qut.edu.au   | April 7, 2022         | DEPP-1479              | Created file                 |
      |                                |                       |                        |                              |
 */
@isTest(SeeAllData=false)
public with sharing class EmailHelperTest {

    @IsTest
    static void checkEmailDetailTest(){
        EmailTemplate coverTemplate = [SELECT Id, Name, Subject, HtmlValue, Body FROM EmailTemplate LIMIT 1]; 
    
        String courseName = 'Test_Course1';
        String contactFullName = 'Test_FullName';
        String contactEmail = 'Test_Contact@email.com';

        String mailSubject = 'QUTeX - ' + courseName;
        Map<String, String> coverEmailParams = new Map<String, String> {
            '{coursename}' => courseName,  
            '{name}' => contactFullName,
            '{contactemail}' => contactEmail
        };
          
       Test.startTest();
       Messaging.SingleEmailMessage emailBuilderTest = EmailHelper.emailBuilder(contactEmail, mailSubject, coverTemplate.HtmlValue,coverEmailParams);
       Messaging.EmailFileAttachment attachementBuilderTest = EmailHelper.attachementBuilder(coverTemplate.Name, coverTemplate.HtmlValue,coverEmailParams);
       Test.stopTest();
       System.assertNotEquals(null, emailBuilderTest);
       System.assertNotEquals(null, attachementBuilderTest);

    }   

}