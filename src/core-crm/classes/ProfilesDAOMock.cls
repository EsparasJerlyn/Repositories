/**
 * @description Mock DAO Class for Profile Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | June 26, 2023         | DEPP-5411              | Created file
 */
@isTest
public inherited sharing class ProfilesDAOMock extends DmlBaseMock implements IProfilesDAO {

	public Map<Id, Profile> profilesMap;

    public Schema.SObjectType getSObjectType()
	{
		return Profile.SObjectType;
	}

	public ProfilesDAOMock() {
		super(new Map<Id, Profile>(), Schema.Profile.SObjectType);
		this.profilesMap = (Map<Id, Profile>) super.records;
	}

	public List<Profile> getProfileRecordsBySetIds(Set<Id> profileIdSet) {
        List<Profile> profileList = new List<Profile>();

        for (Profile record : profilesMap.values()) {
            if (profileIdSet.contains(record.Id)) {
                profileList.add(record);
            }
        }

        return profileList;
    }
}