/**
 * @description Mock DAO Class for PricebookEntry Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | Sep 19, 2023          | DEPP-6714              | Created file
 *    | alexander.cadalin              | Jan 05 ,2024          | n/a                    | Added methods
 */
@isTest
public inherited sharing class PricebookEntriesDAOMock extends DmlBaseMock implements IPricebookEntriesDAO {
    public Map<Id, PricebookEntry> pricebookEntriesMap;

    public Schema.SObjectType getSObjectType() {
        return PricebookEntry.SObjectType;
    }

    public PricebookEntriesDAOMock() {
        super(new Map<Id, PricebookEntry>(), Schema.PricebookEntry.SObjectType);
        this.pricebookEntriesMap = (Map<Id, PricebookEntry>) super.records;
    }

    public List<PricebookEntry> getPricebookEntriesByRecordIdsAndPricebookNames(
        Set<String> recordIds,
        Set<String> priceBookNames,
        AccessLevel accessLevel
    ) {
        List<PricebookEntry> pricebookEntriesList = new List<PricebookEntry>();

        for (PricebookEntry record : pricebookEntriesMap.values()) {
            if (recordIds.contains(record.Id) && priceBookNames.contains(record.Pricebook2.Name)) {
                pricebookEntriesList.add(record);
            }
        }

        return pricebookEntriesList;
    }

    public List<PricebookEntry> getPricebookEntriesByIds(
        Set<Id> recordIds,
        AccessLevel accessLevel
    ) {
        List<PricebookEntry> pbEntries = new List<PricebookEntry>();
        for(PricebookEntry pb : pricebookEntriesMap.values()) {
            if(recordIds.contains(pb.Id)) {
                pbEntries.add(pb);
            }
        }
        return pbEntries;
    }
}
