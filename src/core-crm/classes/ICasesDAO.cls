/**
 * @description Interface for Case DAO framework
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                          |
      |--------------------------------|-----------------------|------------------------|---------------------------------------------------------|
      | arsenio.jr.dayrit              | September 11, 2023    | DEPP-5652              | Created File                                            |
      | neil.s.h.lesidan               | September 20, 2023    | DEPP-6478              | Added getCaseBySuppliedEmail                            |
      | arsenio.jr.dayrit              | September 26, 2023    | DEPP-6720              | added new method getCasesBySuppliedPhone                |
      | eccarius.munoz                 | May 16, 2024          | DEPP-8484              | added method getOpenOutreachCasesByConfigAndContactIds  |
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
    List<Case> getCaseBySuppliedEmail(
        String suppliedEmail,
        AccessLevel accessLevel
    );
    List<Case> getCasesBySuppliedPhone(
        Set<String> suppliedPhone,
        AccessLevel accessLevel
    );

    List<Case> getCasesByIds(
        Set<Id> caseIds,
        AccessLevel accessLevel
    );

    List<Case> getCasesByEngagementListConfigurationIds(
        String configurationId,
        AccessLevel accessLevel
    );
    
    Database.QueryLocator queryLocatorGetCasesByContactOrLeadIds(
        Set<Id> recordIds
    );

    List<Case> getOpenOutreachCasesByConfigAndContactIds(
        Set<Id> contactIds,
        Id configId,
        AccessLevel accessLevel
    );

    List<Case> getCasesByQualtricsSurveyIds(
        Set<Id> qualtricsSurveyIds,
        AccessLevel accessLevel
    );

    List<case> getCasesByIdsImported(
        Set<Id> caseIds,
        AccessLevel accessLevel
    );
}