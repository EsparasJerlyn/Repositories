/**
 * @description DAO Class for Group Object. Contains soql and constants related to the Group object.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
 *    | gabriel.p.ventayen             | May 7, 2024           | DEPP-8614              | Created file                                   |
 *    |                                |                       |                        |                                                |
 */
public inherited sharing class GroupsDAO extends DmlBase implements IGroupsDAO {

    public static final String STUDENT_RETENTION_QUEUE = 'Student Success - Student Retention';
    
    public static IGroupsDAO newInstance() {
        return (IGroupsDAO) ImplementationSelector.DAO.newInstance(
            Group.SObjectType
        );
    }
    public Schema.SObjectType getSObjectType() {
        return 	Group.SObjectType;
    }

    public Id getQueueByName(String groupName){
        if(String.isBlank(groupName)){
            return null;
        }

        Id queueId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name =: groupName WITH SYSTEM_MODE LIMIT 1]?.Id;
        return queueId;    
    }
}
