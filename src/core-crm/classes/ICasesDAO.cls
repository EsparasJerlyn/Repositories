/**
 * @description Interface for Case DAO framework
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------|
      | arsenio.jr.dayrit              | September 11, 2023    | DEPP-5652              | Created File                                   |
 */
public interface ICasesDAO extends DmlInterface{ 
    List<Case> getCasesByContactIds(
        Set<Id> contactIds,
        AccessLevel accessLevel
    );

    List<Case> getCasesByLeadIds(
        Set<Id> leadIds,
        AccessLevel accessLevel
    );
    
    List<Case> getCasesByContactOrLeadIds(
        Set<Id> contactOrLeadIds,
        AccessLevel accessLevel
    );
}