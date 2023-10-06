/** @description Service Class for International Tier
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------|
 *    | roy.nino.s.regala              | October 05,2023       | DEPP-6426              | Created File                  |
 */
public inherited sharing class InternationalTierService {
    /**
     * @description: method to get country tier map
     * @param accessLevel
     * return map of country tier where key is country name and value is the tier category
     */
    public static Map<String, String> getCountryTierMap(AccessLevel accessLevel) {
        Map<String, String> countryTierMap = new Map<String, String>();

        for (
            International_Tier__c countryTier : InternationalTiersDAO.newInstance()
                .getActiveInternationalTiers(accessLevel)
        ) {
            countryTierMap.put(countryTier.Country_Name__c, countryTier.Tier_Category__c);
        }

        return countryTierMap;
    }
}
