/**
 * @description Service class for User Info functionalities
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | June 14, 2023         | DEPP-5391              | Created                      | 
 */

public with sharing class UserInfoService {
    /**
     * Gets the navigation type of the logged in user.
     * @return - String navigation type 'console' or 'standard'
     */
    @AuraEnabled(cacheable=true)
    public static String getCurrentUserNavigationType() {
        List<UserAppInfo> userAppInfoList = new List<UserAppInfo>();
        List<AppDefinition> appDefinitionList = new List<AppDefinition>();

        userAppInfoList = UserAppInfosDAO.newInstance()
            .getUserAppInfoRecordByUserIds(new Set<String>{ UserInfo.getUserId() });

        String appDefinitionIdString = !userAppInfoList.isEmpty()
            ? (String) userAppInfoList.iterator().next().AppDefinitionId
            : '';

        appDefinitionList = AppDefinitionsDAO.newInstance()
            .getAppDefinitionRecordsByDurableIdSet(new Set<String>{ appDefinitionIdString });

        String navType = !appDefinitionList.isEmpty()
            ? appDefinitionList.iterator().next().navType
            : 'Console';

        return navType;
    }
}
