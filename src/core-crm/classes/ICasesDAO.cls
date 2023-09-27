/**
 * @description Interface for Case DAO framework
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------|
      | arsenio.jr.dayrit              | September 11, 2023    | DEPP-5652              | Created File                                   |
      | arsenio.jr.dayrit              | September 26, 2023    | DEPP-6720              | added new method getCasesBySuppliedPhone       |
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

    List<Case> getCasesBySuppliedPhone(
        Set<String> suppliedPhone,
        AccessLevel accessLevel
    );
}