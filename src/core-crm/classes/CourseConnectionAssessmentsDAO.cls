/**
 * @description DAO Class for Course_Connection_Assessment__c Object. Contains soql and constants related to the Course Connection Assessment object.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
 *    | julie.jane.alegre              | April 29, 2024        | DEPP-8041              | Created file                                   |
 *    |                                |                       |                        |                                                |
 */
public inherited sharing class CourseConnectionAssessmentsDAO extends DmlBase implements ICourseConnectionAssessmentsDAO{
    
    public static ICourseConnectionAssessmentsDAO newInstance() {
        return (ICourseConnectionAssessmentsDAO) ImplementationSelector.DAO.newInstance(
            Course_Connection_Assessment__c.SObjectType
        );
    }

    public Schema.SObjectType getSObjectType() {
        return 	Course_Connection_Assessment__c.SObjectType;
    }


}
