/**
 * @description Mock DAO Class for Expense Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | carl.alvin.cabiles             | August 22, 2023       | DEPP-6410	            | Created file                 |                                                     |
 */
@isTest
public inherited sharing class ExpensesDAOMock extends DmlBaseMock implements IExpensesDAO {

	public Map<Id, Expense__c> ExpenseMap;

    public Schema.SObjectType getSObjectType()
	{
		return Expense__c.SObjectType;
	}

	public ExpensesDAOMock() {
		super(new Map<Id, Expense__c>(), Schema.Expense__c.SObjectType);
		this.ExpenseMap = (Map<Id, Expense__c>) super.records;
	}
}