/**
 * @description DAO Class for Contact Matching Service Configuration Metadata. Contains soql and constants related to the Contact Matching Service Configuration Metadata.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | June 05, 2024         | DEPP-9210              | Created file
 */
public inherited sharing class ConMatchingServiceConfigurationsDAO extends DmlBase implements IConMatchingServiceConfigurationsDAO {

	public static final String STUDENT_SANCTION_BATCH = 'DuplicateSanctionBatch';
	public static final String CONTACT_MATCHING_STAGING_BATCH = 'ContactMatchingStagingBatch';
	public static final String APPLICATION_BATCH = 'ApplicationContactMatchingBatch';

    public Schema.SObjectType getSObjectType() {
        return Contact_Matching_Service_Configuration__mdt.SObjectType;
    }

    public static IConMatchingServiceConfigurationsDAO newInstance() {
        return (IConMatchingServiceConfigurationsDAO) ImplementationSelector.DAO.newInstance(
            Contact_Matching_Service_Configuration__mdt.SObjectType
        );
    }

    public Contact_Matching_Service_Configuration__mdt getInstanceByDeveloperName(
        String developerName
    ) {
        return Contact_Matching_Service_Configuration__mdt.getInstance(developerName);
    }
}
