/** @description Service Class for International Tier
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                     |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------|
 *    | roy.nino.s.regala              | October 05,2023       | DEPP-6426              | Created File                       |
 *    | eccarius.munoz                 | February 15, 2024     | DEPP-7714              | Updated return type from           |
 *    |                                |                       |                        | Map<String, String> to             |
 *    |                                |                       |                        | Map<String, International_Tier__c> |
 */
public inherited sharing class InternationalTierService {
    /**
     * @description: method to get country tier map
     * @param accessLevel
     * return map of country tier where key is country name and value is the tier category
     */
    public static Map<String, International_Tier__c> getCountryTierMap(AccessLevel accessLevel) {
        Map<String, International_Tier__c> countryTierMap = new Map<String, International_Tier__c>();

        for (
            International_Tier__c countryTier : InternationalTiersDAO.newInstance()
                .getActiveInternationalTiers(accessLevel)
        ) {
            countryTierMap.put(countryTier.Country_Name__c, countryTier);
        }

        return countryTierMap;
    }
}
