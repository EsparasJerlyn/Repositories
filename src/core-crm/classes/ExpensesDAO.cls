/**
 * @description DAO Class for Expense Object
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | carl.alvin.cabiles             | August 21, 2023       | DEPP-6410              | Created file                 |
 */
public inherited sharing class ExpensesDAO extends DmlBase implements IExpensesDAO{

    public Schema.SObjectType getSObjectType()
	{
		return Expense__c.SObjectType;
	}

    public static IExpensesDAO newInstance()
	{
		return (IExpensesDAO) ImplementationSelector.DAO.newInstance(Expense__c.SObjectType);
	}
}