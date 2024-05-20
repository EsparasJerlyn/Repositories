/**
 * @description DAO Class for Qualtrics Survey Object. Contains soql and constants related to the Qualtrics Survey object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | arsenio.jr.dayrit              |  May 20, 2024         | DEPP-8821              | Created file                 |
 */

 public inherited sharing class QualtricsSurveysDAO extends DmlBase implements IQualtricsSurveysDAO {
    
    public Schema.SObjectType getSObjectType() {
        return Qualtrics_Survey__c.SObjectType;
    }

    public static IQualtricsSurveysDAO newInstance() {
        return (IQualtricsSurveysDAO) ImplementationSelector.DAO.newInstance(Qualtrics_Survey__c.SObjectType);
    }
    
}