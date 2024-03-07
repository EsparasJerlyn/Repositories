/**
 * @description DAO Class for Profile Object. Contains soql and constants related to the Profile object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | June 26, 2023         | DEPP-5411              | Created file
 */
public inherited sharing class ProfilesDAO extends DmlBase implements IProfilesDAO{ 

	public static List<String> ADMIN_PROFILES = new List<String>{
		'QUT System Administrator',
		'System Administrator'
	};

	public static String FUTURE_STUDENT_ENGAGEMENT_PROFILE = 'Future Student Engagement';

    public Schema.SObjectType getSObjectType()
	{
		return Profile.SObjectType;
	}

    public static IProfilesDAO newInstance()
	{
		return (IProfilesDAO) ImplementationSelector.DAO.newInstance(Profile.SObjectType);
	}

	public List<Profile> getProfileRecordsBySetIds(Set<Id> profileIdSet){
		return [ //NOPMD
            SELECT Id, Name
            FROM Profile
			WHERE Id IN: profileIdSet 
			WITH SYSTEM_MODE
        ];
	}
}