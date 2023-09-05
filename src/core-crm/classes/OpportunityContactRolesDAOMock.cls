/**
 * @description Mock DAO Class for OpportunityContactRolesDAO 
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------|
      | mark.j.mahilum                 | Aug 31, 2023         | DEPP-6565               | Created File                               |
 */
@isTest
public inherited sharing class OpportunityContactRolesDAOMock extends DmlBaseMock implements IOpportunityContactRolesDAO {
    
    public Map<Id, OpportunityContactRole> ocrMap;

    public OpportunityContactRolesDAOMock() {
        super(new Map<Id, OpportunityContactRole>(), Schema.OpportunityContactRole.SObjectType);
        this.ocrMap = (Map<Id, OpportunityContactRole>) super.records;
    }

    public Schema.SObjectType getSObjectType() {
        return OpportunityContactRole.SObjectType;
    }
    
    public List<OpportunityContactRole> getOpportunityContactRoleByRoleContactIds(
        Set<Id> contactIds,
        Set<String> contactRoles,
        String accessLevel
    ) {
        List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
        
        for (OpportunityContactRole record : ocrMap.values()) {
            if (contactIds.contains(record.ContactId)) {
                ocrList.add(record);
            }
        }
        
        return ocrList;
    }
}