/**
 * @description Service Class for PackageComponentService class getting application preference Id
 * 
 * @see PackageComponentService
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                   |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------------------------|
 *    | arsenio.jr.dayrit              | August 15,2023        | DEPP-6370              | Created File                                     |
      | sebastianne.k.trias            | May 9, 2024           | DEPP-8382              | Changed logic in setting value of application    |
      |                                |                       |                        | calculated intake date field                     |
 */
public with sharing class PackageComponentService {

     /**
     * @description: get existing application preference Id from Package Component
     *
     * @param List<Package_Component__c> Package Component records to evaluate
     */
    public static Set<Id> getAllApplicationPreferenceIdInPackageComponent(List<Package_Component__c> packageComponentList) {
        Set<Id> appPreferenceIds = new Set<Id>();

        for(Package_Component__c packageComp : packageComponentList){
            if(packageComp.Application_Preference__c != null){
                appPreferenceIds.add(packageComp.Application_Preference__c);
            }
        }

        return appPreferenceIds;
    }
}