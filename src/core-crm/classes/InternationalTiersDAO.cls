/**
 * @description DAO class for Internation Tier
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | October 5, 2023       | DEPP-6426              | Created file                 |
      | johanna.a.gibas                | November 24, 2023     | DEPP-7143              | Updated Tier Category        |
      | eccarius.karl                  | February 14, 2024     | DEPP-7714              | Added Tier_Subcategory__c in |
      |                                |                       |                        | getActiveInternationalTiers  |
 */
public with sharing class InternationalTiersDAO extends DmlBase implements IInternationalTiersDAO {

    public static String TIER_CATEGORY_1 = 'Tier 1'; 
    public static String TIER_CATEGORY_2 = 'Tier 2';
    public static String TIER_CATEGORY_3 = 'Tier 3';
    public static String DEVELOPED_NATIONS = 'Developed Nations';
    public static String UNTIERED_UNRESTRICTED = 'Untiered - Unrestricted';
    public static String UNTIERED_RESTRICTED = 'Untiered - Restricted';
    public static String UNTIERED = 'Untiered';
    public static String UNTIERED_SUBCATEGORY_RESTRICTED = 'Restricted';
    public static String UNTIERED_SUBCATEGORY_UNRESTRICTED = 'Unrestricted';

    public Schema.SObjectType getSObjectType() {
        return International_Tier__c.SObjectType;
    }

    public static IInternationalTiersDAO newInstance() {
        return (IInternationalTiersDAO) ImplementationSelector.DAO.newInstance(
            International_Tier__c.SObjectType
        );
    }

    public List<International_Tier__c> getActiveInternationalTiers(AccessLevel accessLevel) {
        return Database.query(
            'SELECT Country_Name__c, Tier_Category__c, Tier_Subcategory__c ' +
                'FROM International_Tier__c ' +
                'WHERE IsActive__c = TRUE ',
            accessLevel
        );
    }
}
