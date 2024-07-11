/**
 * @description DAO Mock Class for Group Object. 
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
@isTest
public inherited sharing class GroupsDAOMock extends DmlBaseMock implements IGroupsDAO {

    public Map<Id, Group> groupMap;

    public GroupsDAOMock() {
        super(new Map<Id, Group>(), Schema.Group.SObjectType);
        this.groupMap = (Map<Id, Group>) super.records;
    }

    public Schema.SObjectType getSObjectType() {
        return Group.SObjectType;
    }

    public Id getQueueByName(String groupName){

        Id studentRetentionQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name =: groupName LIMIT 1]?.Id;
        return studentRetentionQueue;    
    }
}