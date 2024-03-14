/**
 * @description DAO Class for Donation Cause Object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------|
      | roy.nino.s.regala              | March 14, 2024        | DEPP-8210              | Created file                                   |

*/

 public inherited sharing class DonationCausesDAO extends DmlBase implements IDonationCausesDAO {
    public Schema.SObjectType getSObjectType() {
        return Donation_Cause__c.SObjectType;
    }

    public static IDonationCausesDAO newInstance() {
        return (IDonationCausesDAO) ImplementationSelector.DAO.newInstance(
            Donation_Cause__c.SObjectType
        );
    }
}