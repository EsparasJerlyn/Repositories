/**
 * @description Tests Lead Before Insert/Update Triggered Flow
 *
 * @see Lead_Before_Insert_Update_Triggered_Flow
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA     | Change Summary                  |
      |---------------------------|-----------------------|----------|---------------------------------|
      | eccarius.karl.munoz       | November 04, 2021     | DEPP-738 | Created file                    | 
      |                           |                       |          |                                 | 
*/
@isTest
private class Lead_Before_Ins_Upd_Triggered_FlowTest {
    
    private static String validStr = 'Valid';
    private static String countryStr = 'Australia';
    private static String postalStr = '123';    
    private static String streetStr = 'TestStreet';
    private static String stateStr = 'TestState';
    private static String companyCategoryStr = 'Corporate';
    private static Integer numberOfRecords = 100;

    @TestSetup
    static void makeData(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }
      
    @isTest 
    private static void insertUpdateLeadRecordTest(){  
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Test.startTest(); 

            List<Lead> leads = TestDataFactory.createTestLeadRecords(numberOfRecords);  
            List<Account> accounts = TestDataFactory.createTestAccountRecords(numberOfRecords);                  
            
            Integer counter = 0;
            for(Lead lead : leads){      
                lead.Street = streetStr + counter;
                lead.State = stateStr + counter;
                lead.PostalCode = postalStr + counter;
                lead.Country = countryStr + counter;
                counter++;
            }    

            insert(accounts);
            insert(leads); 

            List<Lead> leadList = [SELECT Id FROM Lead LIMIT 100];

            Integer ctr = 0;
            for(Lead lead : leadList){                
                lead.Street = streetStr + ctr;
                lead.State = stateStr + ctr;
                lead.PostalCode = postalStr + ctr;
                lead.Country = countryStr;     
                lead.Company_Category__c = companyCategoryStr;
                lead.LeadMobile_Validation__c = validStr;
                lead.LeadPhone_Validation__c = validStr;
                lead.LeadPersonalMobile_Validation__c = validStr;
                lead.WorkPhone_Validation__c = validStr;           
                ctr++;
            }            
            update(leadList);            
            Test.stopTest(); 
        }                
        System.assert([SELECT Id FROM Lead WHERE FirstName = ''].isEmpty(), 'FirstName must be inputted.');
        System.assert([SELECT Id FROM Lead WHERE Company_Category__c  = ''].isEmpty(), 'Company_Category__c must be inputted.');
        System.assert([SELECT Id FROM Lead WHERE Street = ''].isEmpty(), 'Street must be inputted.');
        System.assert([SELECT Id FROM Lead WHERE City = ''].isEmpty(), 'City must be inputted.');
        System.assert([SELECT Id FROM Lead WHERE State = ''].isEmpty(), 'State must be inputted.');
        System.assert([SELECT Id FROM Lead WHERE PostalCode = ''].isEmpty(), 'PostalCode must be inputted.');
        System.assert([SELECT Id FROM Lead WHERE Country = ''].isEmpty(), 'Country must be inputted.');
        System.assert([SELECT Id FROM Lead WHERE Phone = ''].isEmpty(), 'Phone must be inputted.');
        System.assert([SELECT Id FROM Lead WHERE MobilePhone = ''].isEmpty(), 'MobilePhone must be inputted.');        
        System.assert([SELECT Id FROM Lead WHERE LeadPersonalMobile_Validation__c = 'Not Valid'].isEmpty(), 'LeadPersonalMobile_Validation__c must not be equal to Not Valid.');
        System.assert([SELECT Id FROM Lead WHERE WorkPhone_Validation__c = 'Not Valid'].isEmpty(), 'WorkPhone_Validation__c must not be equal to Not Valid.');
        System.assert(![SELECT Id FROM Lead WHERE LeadMobile_Validation__c = 'Valid'].isEmpty(), 'LeadMobile_Validation__c must be Valid.');
        System.assert(![SELECT Id FROM Lead WHERE LeadPhone_Validation__c = 'Valid'].isEmpty(), 'LeadPhone_Validation__c must be Valid.');
    } 
}