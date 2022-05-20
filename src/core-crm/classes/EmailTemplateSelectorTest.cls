/**
 * @description Test class for EmailTemplateSelector
 * @EmailTemplateSelector
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | kenodomienri.dico@qut.edu.au   | April 7, 2022         | DEPP-1479              | Created file                 |
      |                                |                       |                        |                              |
 */
@isTest(SeeAllData=false)
public with sharing class EmailTemplateSelectorTest {

    @IsTest
     static void checkEmailSelectorEmpty(){
    
        Test.startTest();
        EmailTemplate coverTemplate = EmailTemplateSelector.getEmailTemplate('Send Certificate'); 
        Test.stopTest();
        System.assertNotEquals(null, coverTemplate, 'coverTemplate is null');

     }  

}