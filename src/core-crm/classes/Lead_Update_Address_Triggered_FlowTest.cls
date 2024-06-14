/**
 * @description Tests the Lead Upsert Address Triggered Triggered Flow  
 *
 * @see Lead_Update_Address_Triggered_Flow
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA      | Change Summary                  |
      |---------------------------|-----------------------|-----------|---------------------------------|
      | adrian.c.habasa           | November 02, 2021     | DEPP-741  | Created file                    | 
      | roy.nino.s.regala         | December 10, 2021     | DEPP=1340 | Bug fix                         |
      | eccarius.munoz            | October 10, 2023      | DEPP-5866 | Added testsetup                 |
*/
@isTest
public with sharing class Lead_Update_Address_Triggered_FlowTest {
    private static User  currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();
    private static final String LEAD_TYPE = 'Lead';
    private static final String BILLING_TYPE = 'Billing';

    @TestSetup
    static void makeData(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    static void upsertLeadAddressTest()
        {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator)
            {
                List<Account> accs = new List<Account>();
                List<lead> tLeads = new List<lead>();
                List<lead> leads = new List<lead>();
                List<hed__Address__c> hedAddresses = new List<hed__Address__c>();

                accs = TestDataFactory.createTestAccountRecords(1);
                tLeads= TestDataFactory.createTestLeadRecords(50);
                leads= TestDataFactory.createTestLeadRecords(50);
                
                insert(accs);
				hedAddresses.addAll(TestDataFactory.createTestHedAddressRecords(1,BILLING_TYPE,accs[0].Id,'hed__Parent_Account__c'));
                
                Integer ctr = 0;
                for(Lead tempLeads : leads)
                {   
                    tempLeads.Street='TestStreet'+ctr;
                    tempLeads.Country='TestCountry'+ctr;
                    tempLeads.State='TestState'+ctr;
                    tempLeads.PostalCode ='1000'+ctr;
                    ctr++;
                }

                for(Lead nLeads : tLeads)
                {
                    nLeads.Company_Category__c = 'Corporate';
                }

                Test.startTest();
                    insert(hedAddresses);
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