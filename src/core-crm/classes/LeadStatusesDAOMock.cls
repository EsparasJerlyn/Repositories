/**
 * @description Mock DAO Class for LeadStatus Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | Jan 03, 2024          | n/a                    | Created file
 */
@isTest
public inherited sharing class LeadStatusesDAOMock extends DmlBaseMock implements ILeadStatusesDAO {

	public Map<Id, LeadStatus> leadStatusesMap;

    public Schema.SObjectType getSObjectType()
	{
		return LeadStatus.SObjectType;
	} 

	public LeadStatusesDAOMock() {
		super(new Map<Id, LeadStatus>(), Schema.LeadStatus.SObjectType);
		this.leadStatusesMap = (Map<Id, LeadStatus>) super.records;
	}

	public LeadStatus getConvertedLeadStatus(AccessLevel accessLevel) {
		if(accessLevel == null) { 
			return null; 
		} else {
			for(LeadStatus ls : leadStatusesMap.values()) {
				if(ls.IsConverted == true) {
					return ls;
				}
			}
			return null;
		}
	}
}