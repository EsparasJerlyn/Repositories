@IsTest
public with sharing class InvalidateFieldValuesBatchTest {
    
    @IsTest
    public static void testContact(){
        InvalidateFieldValuesBatch invalidate = new InvalidateFieldValuesBatch();
        Contact cont = new Contact(LastName='Costa', FirstName='Marcelo', Email ='marsson@test.com.br');
        insert cont;

        Test.startTest();
        invalidate.invalidateFieldsForObject('Contact', new Set<String>{'Email','Personal_Email__c','Registered_Email__c','QUT_Staff_Email__c','QUT_Learner_Email__c', 'MobilePhone'}, false);
        Test.stopTest();

        Contact c =[Select Email,Personal_Email__c,Registered_Email__c,QUT_Staff_Email__c,QUT_Learner_Email__c, MobilePhone from Contact];
        System.assertEquals(c.Email, 'marsson@test.com.br.invalid', 'Email Not invalidated');
        
    } 
    @IsTest
    public static void testContactWithEmailANDPhone(){
        InvalidateFieldValuesBatch invalidate = new InvalidateFieldValuesBatch();
        Contact cont = new Contact(LastName='Costa', FirstName='Marcelo', Email ='marsson@test.com.br', MobilePhone='614136289374');
        insert cont;

        Test.startTest();
        invalidate.invalidateFieldsForObject('Contact', new Set<String>{'Email','Personal_Email__c','Registered_Email__c','QUT_Staff_Email__c','QUT_Learner_Email__c', 'MobilePhone'}, false);
        Test.stopTest();

        Contact c =[Select Email,Personal_Email__c,Registered_Email__c,QUT_Staff_Email__c,QUT_Learner_Email__c, MobilePhone from Contact];
        System.assertEquals(c.Email, 'marsson@test.com.br.invalid', 'Email Not invalidated');
        System.assertEquals(c.MobilePhone, '61491571266', 'Mobile Not invalidated');
        
    } 

    @IsTest
    public static void testContactWithEmailANDPhoneInvalidatingSync(){
        InvalidateFieldValuesBatch invalidate = new InvalidateFieldValuesBatch();
        Contact cont = new Contact(LastName='Costa', FirstName='Marcelo', Email ='marsson@test.com.br', MobilePhone='614136289374');
        insert cont;

        Test.startTest();
        invalidate.invalidateFieldsForObject('Contact', new Set<String>{'Email','Personal_Email__c','Registered_Email__c','QUT_Staff_Email__c','QUT_Learner_Email__c', 'MobilePhone'}, true);
        Test.stopTest();

        Contact c =[Select Email, Sync_to_MC__c, Personal_Email__c,Registered_Email__c,QUT_Staff_Email__c,QUT_Learner_Email__c, MobilePhone from Contact];
        System.assertEquals(c.Email, 'marsson@test.com.br.invalid', 'Email Not invalidated');
        System.assertEquals(c.MobilePhone, '61491571266', 'Mobile Not invalidated');
        System.assertEquals(c.Sync_to_MC__c, false, 'Sync has not been deactivated.');
        
    } 
}

                                                                                                                                                                                                                                                                                                            