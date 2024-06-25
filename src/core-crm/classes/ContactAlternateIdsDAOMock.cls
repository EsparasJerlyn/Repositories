/**
 * @description Mock DAO Class for Contact Alternate Id Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
 */
@isTest
public inherited sharing class ContactAlternateIdsDAOMock extends DmlBaseMock implements IContactAlternateIdsDAO {

	public Map<Id, Contact_Alternate_ID__c> conAltIdsMap;

    public Schema.SObjectType getSObjectType()
	{
		return Contact_Alternate_ID__c.SObjectType;
	}

	public ContactAlternateIdsDAOMock() {
		super(new Map<Id, Contact_Alternate_ID__c>(), Schema.Contact_Alternate_ID__c.SObjectType);
		this.conAltIdsMap = (Map<Id, Contact_Alternate_ID__c>) super.records;
	}

	public List<Contact_Alternate_ID__c> getContactAlternateIdsBySystemKeyIdSet(Set<String> systemKeyIdsSet, AccessLevel accessLevel){
		List<Contact_Alternate_ID__c> conaltIdList = new List<Contact_Alternate_ID__c>();
		Set<Id> contactIdSet = new Set<Id>();

        for(Contact_Alternate_ID__c conAltId: conAltIdsMap.values()){
			
			if(	systemKeyIdsSet.contains(conAltId.Contact_Alternate_Id__c) && 
				conAltId.Contact__c != null && 
				conAltId.Alternate_Id_Status__c == ContactAlternateIdsDAO.ACTIVE_STATUS){
					contactIdSet.add(conAltId.Contact__c);
			}
		}

		Map<Id,Contact> contactsMap = new Map<Id,Contact>(ContactsDAO.newInstance().getPersonContactsBySetIds(contactIdSet, accessLevel));

		for(Contact_Alternate_ID__c conAltId: conAltIdsMap.values()){
			if(	systemKeyIdsSet.contains(conAltId.Contact_Alternate_Id__c) && 
				conAltId.Contact__c != null && 
				conAltId.Alternate_Id_Status__c == ContactAlternateIdsDAO.ACTIVE_STATUS){

					conAltId = (Contact_Alternate_ID__c) JSON.deserialize(
						'{"attributes":{"type":"Contact_Alternate_ID__c"},"Id":"' +
						conAltId.Id +
						'","Contact__c":"' +
						conAltId.Contact__c +
						'","Alternate_Id_Status__c":"' +
						conAltId.Alternate_Id_Status__c +
						'","Alternate_Id_Type__c":"' +
						conAltId.Alternate_Id_Type__c +
						'","Contact_Alternate_Id__c":"' +
						conAltId.Contact_Alternate_Id__c +
						'","Contact__r":' +
						JSON.serialize(contactsMap.get(conAltId.Contact__c))+
						'}',
						Contact_Alternate_ID__c.class
					);

					conaltIdList.add(conAltId);
			}
		}

		return conaltIdList;
    }

	public List<Contact_Alternate_ID__c> getContactAlternateIdsByContactIdSet(Set<Id> contactIdSet, AccessLevel accessLevel){

        List<Contact_Alternate_ID__c> conaltIdList = new List<Contact_Alternate_ID__c>();
		Map<Id,Contact> contactsMap = new Map<Id,Contact>(ContactsDAO.newInstance().getPersonContactsBySetIds(contactIdSet, accessLevel));

		for(Contact_Alternate_ID__c conAltId: conAltIdsMap.values()){
			if(	contactIdSet.contains(conAltId.Contact__c) && 
				conAltId.Contact__c != null && 
				conAltId.Alternate_Id_Status__c == ContactAlternateIdsDAO.ACTIVE_STATUS){

					conAltId = (Contact_Alternate_ID__c) JSON.deserialize(
						'{"attributes":{"type":"Contact_Alternate_ID__c"},"Id":"' +
						conAltId.Id +
						'","Contact__c":"' +
						conAltId.Contact__c +
						'","Alternate_Id_Status__c":"' +
						conAltId.Alternate_Id_Status__c +
						'","Alternate_Id_Type__c":"' +
						conAltId.Alternate_Id_Type__c +
						'","Contact_Alternate_Id__c":"' +
						conAltId.Contact_Alternate_Id__c +
						'","Contact__r":' +
						JSON.serialize(contactsMap.get(conAltId.Contact__c))+
						'}',
						Contact_Alternate_ID__c.class
					);

					conaltIdList.add(conAltId);
			}
		}

		return conaltIdList;
    }

	public List<Contact_Alternate_ID__c> getContactAlternateIdsByContactIdSetAndStatus(Set<Id> contactIdSet, Set<String> alternateIdStatusSet, AccessLevel accessLevel){

        List<Contact_Alternate_ID__c> conaltIdList = new List<Contact_Alternate_ID__c>();
		Map<Id,Contact> contactsMap = new Map<Id,Contact>(ContactsDAO.newInstance().getPersonContactsBySetIds(contactIdSet, accessLevel));

		for(Contact_Alternate_ID__c conAltId: conAltIdsMap.values()){
			if(	contactIdSet.contains(conAltId.Contact__c) && 
				conAltId.Contact__c != null && 
				alternateIdStatusSet.contains(conAltId.Alternate_Id_Status__c)){

					conAltId = (Contact_Alternate_ID__c) JSON.deserialize(
						'{"attributes":{"type":"Contact_Alternate_ID__c"},"Id":"' +
						conAltId.Id +
						'","Contact__c":"' +
						conAltId.Contact__c +
						'","Alternate_Id_Status__c":"' +
						conAltId.Alternate_Id_Status__c +
						'","Alternate_Id_Type__c":"' +
						conAltId.Alternate_Id_Type__c +
						'","Contact_Alternate_Id__c":"' +
						conAltId.Contact_Alternate_Id__c +
						'","Contact__r":' +
						JSON.serialize(contactsMap.get(conAltId.Contact__c))+
						'}',
						Contact_Alternate_ID__c.class
					);

					conaltIdList.add(conAltId);
			}
		}

		return conaltIdList;
    }

	public List<Contact_Alternate_ID__c> getStudentAlternateIdsByStudentIds(Set<String> qutStudentIds, AccessLevel accessLevel){

		List<Contact_Alternate_ID__c> conaltIdList = new List<Contact_Alternate_ID__c>();

		//TO DO: Add inner query
		for(Contact_Alternate_ID__c conAltId: conAltIdsMap.values()){
			if(	conAltId.Alternate_Id_Status__c == ContactAlternateIdsDAO.SUPERSEDED_STATUS &&
				conAltId.Alternate_Id_Type__c == ContactAlternateIdsDAO.STUDENT_ID_TYPE &&
				qutStudentIds.contains(conAltId.Contact_Alternate_Id__c)){
					conaltIdList.add(conAltId);
			}
		}

		return conaltIdList;
    }

}