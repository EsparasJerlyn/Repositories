/**
 * @description DAO Class for Pricebook Object. Contains SOQL and Constants related to the Pricebook object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | roy.nino.s.regala              | Sep 19, 2023          | DEPP-6714              | Created file                 |
 */
public inherited sharing class PricebooksDAO extends DmlBase implements IPricebooksDAO {

    public static final Set<String> PRICING_VALIDATION_NAMES = new Set<String>{
        'Alumni',
        'Current Learner',
        'Current Staff'
    };

    public Schema.SObjectType getSObjectType() {
        return Pricebook2.SObjectType;
    }

    public static IPricebooksDAO newInstance() {
        return (IPricebooksDAO) ImplementationSelector.DAO.newInstance(Pricebook2.sObjectType);
    }
}
