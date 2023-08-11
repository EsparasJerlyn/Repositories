/**
 * @description DAO Class for hed__Term__c Object. Contains soql and constants related to the hed__Term__c object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | eccarius.munoz                 | August 10, 2023       |DEPP-5760               | Created File                        |
 */
public inherited sharing class TermsDAO extends DmlBase implements ITermsDAO{
    public Schema.SObjectType getSObjectType(){
		return hed__Term__c.SObjectType;
	}

    public static ITermsDAO newInstance(){
		return (ITermsDAO) ImplementationSelector.DAO.newInstance(hed__Term__c.SObjectType);
	}
}