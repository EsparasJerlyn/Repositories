/**
 * @description DAO Class for hed__Program_Plan__c Object. Contains soql and constants related to the hed__Program_Plan__c object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | eccarius.munoz                 | August 10, 2023       |DEPP-5760               | Created File                        |
 */
public inherited sharing class ProgramPlansDAO extends DmlBase implements IProgramPlansDAO {
    public Schema.SObjectType getSObjectType(){
		return hed__Program_Plan__c.SObjectType;
	}

    public static IProgramPlansDAO newInstance(){
		return (IProgramPlansDAO) ImplementationSelector.DAO.newInstance(hed__Program_Plan__c.SObjectType);
	}
}