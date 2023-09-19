/**
 * @description DAO class for OrgWideEmailAddress
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | August 31, 2023       | DEPP-6138              | Created file                 |
      |                                |                       |                        |                              |
 */
public with sharing class OrgWideEmailAddressesDAO extends DmlBase implements IOrgWideEmailAddressesDAO{
    
    public static final String ORG_WIDE_EMAIL_ADD_QUTEX = 'QUTeX';

    public Schema.SObjectType getSObjectType(){
		return OrgWideEmailAddress.SObjectType;
	}

    public static IOrgWideEmailAddressesDAO newInstance(){
		return (IOrgWideEmailAddressesDAO) ImplementationSelector.DAO.newInstance(OrgWideEmailAddress.SObjectType);
	}

    public OrgWideEmailAddress getOrgWideEmailAddressByDisplayName(
        String displayName,
		String accessLevel   
    ) {
        return Database.query(
            'SELECT Id, Address, DisplayName ' +
              'FROM OrgWideEmailAddress ' +
             'WHERE DisplayName =: displayName WITH ' +
             String.escapeSingleQuotes(accessLevel)
        );
    }

}