/**
 * @description Interface for Package Component DAO framework
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------|
      | arsenio.jr.dayrit              | August 15, 2023       | DEPP-6370              | Created File                               |
      | eccarius.munoz                 | August 21, 2023       |DEPP-6252               | Added getPackageComponentsByAppPrefIdSet   | 
 */
public interface IPackageComponentDAO extends DmlInterface{ 
     
     List<Package_Component__c> getPackageComponentsByAppPrefIdSet(Set<Id> applicationPreferenceIds, AccessLevel accessLevel);

}