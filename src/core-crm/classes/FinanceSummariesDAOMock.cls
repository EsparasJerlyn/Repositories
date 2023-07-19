/**
 * @description Mock DAO Class for FinanceSummary Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | July 12, 2023         | DEPP-5473              | Created file
 */
@isTest
public inherited sharing class FinanceSummariesDAOMock extends DmlBaseMock implements IFinanceSummariesDAO {

	public Map<Id, Finance_Summary__c> financeSummariesMap;

    public Schema.SObjectType getSObjectType()
	{
		return Finance_Summary__c.SObjectType;
	}

	public FinanceSummariesDAOMock() {
		super(new Map<Id, Finance_Summary__c>(), Schema.Finance_Summary__c.SObjectType);
		this.financeSummariesMap = (Map<Id, Finance_Summary__c>) super.records;
	}
}