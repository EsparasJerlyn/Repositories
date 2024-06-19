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
    public static final String ORG_WIDE_EMAIL_NO_REPLY = 'no-reply';
    public static final String ORG_WIDE_EMAIL_DOMESTIC_FUTURE_STUDENT_ENQUIRIES = 'Domestic Future Student Enquiries';
    public static final String ORG_WIDE_EMAIL_INTERNATIONAL_FUTURE_STUDENT_ENQUIRIES = 'International Future Student Enquiries';
    public static final String ORG_WIDE_EMAIL_STUDENT_SUCCESS = 'Student Success';

    public Schema.SObjectType getSObjectType(){
		return OrgWideEmailAddress.SObjectType;
	}

    public static IOrgWideEmailAddressesDAO newInstance(){
		return (IOrgWideEmailAddressesDAO) ImplementationSelector.DAO.newInstance(OrgWideEmailAddress.SObjectType);
	}

    public List<OrgWideEmailAddress> getOrgWideEmailAddressByDisplayName(
        Set<String> displayNames,
		AccessLevel accessLevel   
    ) {
        return Database.query(
            'SELECT Id, Address, DisplayName ' +
              'FROM OrgWideEmailAddress ' +
             'WHERE DisplayName IN: displayNames',accessLevel
        );
    }

}