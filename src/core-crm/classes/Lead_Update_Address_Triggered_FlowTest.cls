/**
 * @description Tests the Lead Upsert Address Triggered Triggered Flow  
 *
 * @see Lead_Update_Address_Triggered_Flow
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA     | Change Summary                  |
      |---------------------------|-----------------------|----------|---------------------------------|
      | adrian.c.habasa           | November 02, 2021     | DEPP-741 | Created file                    | 
      |                           |                       |          |                                 |
*/
@isTest(SeeAllData = false)
public with sharing class Lead_Update_Address_Triggered_FlowTest {
    private static User  currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();
    private static final String LEAD_TYPE = 'Lead';
    private static final String BILLING_TYPE = 'Billing';
    @isTest
    static void upsertLeadAddressTest()
        {
        System.runAs(currentUser)
            {
                List<lead> leads = new List<lead>();
                List<Account> accs = new List<Account>();
                List<lead> tLeads = new List<lead>();

                accs = TestDataFactory.createTestAccountRecords(100);
                leads = TestDataFactory.createTestLeadRecords(100);
                tLeads= TestDataFactory.createTestLeadRecords(100);


                for(Lead tempLeads : leads)
                {   
                    tempLeads.Street='TestStreet';
                    tempLeads.Country='TestCountry';
                    tempLeads.State='TestState';
                    tempLeads.PostalCode ='1000';
                }

                for(Lead nLeads : tLeads)
                {
                    nLeads.Company_Category__c = 'Corporate';
                }

                Test.startTest();
                    insert(accs);
                    insert(leads);
                    insert(tLeads);

                    List<Database.LeadConvert> leadstoConvert = new List<Database.LeadConvert>();    
                    LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
                    for(Lead conLead : tLeads)
                    {
                        Database.LeadConvert lc = new Database.LeadConvert();
                        lc.setLeadId(conLead.id);
                        lc.setConvertedStatus(convertStatus.MasterLabel);
                        leadstoConvert.add(lc);
                    }
                    Database.convertLead(leadstoConvert);

                    List<hed__Address__c> address = [SELECT id, hed__MailingCity__c from hed__Address__c Where hed__Address_Type__c =: LEAD_TYPE LIMIT 100];
                    for(hed__Address__c add : address)
                    {
                        add.hed__MailingCity__c = 'NewCity';
                    }
            
                    update(address);

                Test.stopTest(); 
                
                system.assert(![SELECT Id  FROM hed__Address__c WHERE hed__Address_Type__c =:BILLING_TYPE].isEmpty(),'No Billing Address Record was created');
                system.assert(![SELECT Parent_Lead__c FROM hed__Address__c WHERE Parent_Lead__c IN :leads].isEmpty(),'No Lead Address Record was created');
                system.assert(![SELECT Id FROM Lead Where City = 'NewCity'].isEmpty(), 'Lead City should be updated');

            }
        }
    
}
