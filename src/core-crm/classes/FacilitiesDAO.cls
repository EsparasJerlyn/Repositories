/**
 * @description DAO Class for hed__Facility__c Object. Contains soql and constants related to the hed__Facility__c object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | eccarius.munoz                 | August 10, 2023       |DEPP-5760               | Created File                        |
 */
public inherited sharing class FacilitiesDAO extends DmlBase implements IFacilitiesDAO{
    public Schema.SObjectType getSObjectType(){
		return hed__Facility__c.SObjectType;
	}

    public static IFacilitiesDAO newInstance(){
		return (IFacilitiesDAO) ImplementationSelector.DAO.newInstance(hed__Facility__c.SObjectType);
	}
}