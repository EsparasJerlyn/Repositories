/**
 * @description Interface for Financial Split DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                            |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------|
      | mark.j.mahilum                 | June 01, 2023         | DEPP-5687              | Created IFinancialSplitsDAO cls           |
 */
public interface IFinancialSplitsDAO extends DmlInterface{
   List<Financial_Split__c> getFinancialSplitsRecords(String relatedParentField,Id relatedParentId);
}