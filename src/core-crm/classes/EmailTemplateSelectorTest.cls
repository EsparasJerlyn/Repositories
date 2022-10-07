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
@isTest
public with sharing class EmailTemplateSelectorTest {

    @isTest
     static void checkEmailSelectorEmpty(){
    
        Test.startTest();
        EmailTemplate coverTemplate = EmailTemplateSelector.getEmailTemplate('Send Certificate'); 
        Test.stopTest();
        System.assertNotEquals(null, coverTemplate, 'coverTemplate is null');

     }  

}