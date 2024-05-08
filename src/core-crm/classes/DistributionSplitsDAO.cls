/**
 * @description Mock DAO Class for Distribution Split Object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------|
      | neil.s.h.lesidan               | April 12, 2024        | DEPP-8392              | Created file                                   |
*/
public inherited sharing class DistributionSplitsDAO extends DmlBase implements IDistributionSplitsDAO {
    public static IDistributionSplitsDAO newInstance() {
        return (IDistributionSplitsDAO) ImplementationSelector.DAO.newInstance(
            Distribution_Split__c.SObjectType
        );
    }

    public Schema.SObjectType getSObjectType() {
        return Distribution_Split__c.SObjectType;
    }

    public List<Distribution_Split__c> getDistributionSplitByDistributionManagement(
        Set<Id> ids,
        AccessLevel accessLevel
    ){
        if(ids.isEmpty()){
            return new List<Distribution_Split__c>();
        }

        return Database.query(
            'SELECT Id, Name, GL_Account_Code__c, Participating_Group__c, Percentage_Split__c, Distribution_Management__r.Name, Finance_GL_Account__r.Name, Is_Soft_Deleted__c ' +
            'FROM Distribution_Split__c ' +
            'WHERE Distribution_Management__c IN :ids ',
            accessLevel
        );
    }
}