/**
 * @description Mock DAO class for OrgWideEmailAddress
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
@isTest
public inherited sharing class OrgWideEmailAddressesDAOMock extends DmlBaseMock implements IOrgWideEmailAddressesDAO{
    public Map<Id, OrgWideEmailAddress> orgwideEmailAddMap;

    public OrgWideEmailAddressesDAOMock() {
        super(new Map<Id, OrgWideEmailAddress>(), Schema.OrgWideEmailAddress.SObjectType);
        this.orgwideEmailAddMap = (Map<Id, OrgWideEmailAddress>) super.records;
    }

    public Schema.SObjectType getSObjectType() {
        return OrgWideEmailAddress.SObjectType;
    }

    public List<OrgWideEmailAddress> getOrgWideEmailAddressByDisplayName(
        Set<String> displayName,
		AccessLevel accessLevel 
    ) {
        List<OrgWideEmailAddress> orgWideEmailAddress = new List<OrgWideEmailAddress>();

        for (OrgWideEmailAddress record : orgwideEmailAddMap.values()) {
            if(displayName.contains(record.DisplayName)){
                orgWideEmailAddress.add(record);
            }
        }

        return orgWideEmailAddress;
    }

}