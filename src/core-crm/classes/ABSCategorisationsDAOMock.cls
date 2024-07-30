/**
 * @description Mock DAO Class for ABS_Categorisation__c Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum          test        | May 29, 2024          | DEPP-8954              | Created file                 |
 */
@isTest
public inherited sharing class ABSCategorisationsDAOMock extends DmlBaseMock implements IABSCategorisationsDAO {
    public Map<Id, ABS_Categorisation__c> absCategorisationMap;

    public Schema.SObjectType getSObjectType() {
        return ABS_Categorisation__c.SObjectType;
    }

    public ABSCategorisationsDAOMock() {
        super(new Map<Id, ABS_Categorisation__c>(), Schema.ABS_Categorisation__c.SObjectType);
        this.absCategorisationMap = (Map<Id, ABS_Categorisation__c>) super.records;
    }
    
    public List<ABS_Categorisation__c> getLatestUpdatedActiveCategorisationRecord(String accessLevel){
        List<ABS_Categorisation__c> absCategorisation = new List<ABS_Categorisation__c>();              
        
        for(ABS_Categorisation__c abs: absCategorisationMap.values()){
            if(abs.Is_Active__c){
                absCategorisation.add(abs);
            } 
        }
        
        return absCategorisation;
    }
}