/**
 * @description Mock DAO Class for Progam Offering Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               		|
      |--------------------------------|-----------------------|------------------------|-----------------------------------|
      | julie.jane.alegre              | January 02, 2024      | ApexCRUDViolationFix   | Created file                      |
 */
@isTest
public inherited sharing class ProgramOfferingsDAOMock extends DmlBaseMock implements IProgramOfferingsDAO {

	public Map<Id, Program_Offering__c> programOfferingsMap;

    public Schema.SObjectType getSObjectType()
	{
		return Program_Offering__c.SObjectType;
	} 
 
	public ProgramOfferingsDAOMock() {
		super(new Map<Id, Program_Offering__c>(), Schema.Program_Offering__c.SObjectType);
		this.programOfferingsMap = (Map<Id, Program_Offering__c>) super.records;
	}
	
	public List<Program_Offering__c> getProgramOfferingByRecordIds(
    	Set<Id> programOfferIdSet,
        AccessLevel accessLevel
    ) {
		List<Program_Offering__c> programOfferingList = new List<Program_Offering__c>();

        for (Program_Offering__c record : programOfferingsMap.values()) {
            if (programOfferIdSet.contains(record.Id)) {
                programOfferingList.add(record);
            }
        }

		return programOfferingList;
    }
}
