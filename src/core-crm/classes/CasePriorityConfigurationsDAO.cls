/**
 * @description DAO class for Case Priority Configuration
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | Octover 5, 2023       | DEPP-6426              | Created file                 |
      |                                |                       |                        |                              |
 */
public with sharing class CasePriorityConfigurationsDAO extends DmlBase implements ICasePriorityConfigurationsDAO {
    public Schema.SObjectType getSObjectType() {
        return Case_Priority_Configuration__c.SObjectType;
    }

    public static ICasePriorityConfigurationsDAO newInstance() {
        return (ICasePriorityConfigurationsDAO) ImplementationSelector.DAO.newInstance(
            Case_Priority_Configuration__c.SObjectType
        );
    }

    public List<Case_Priority_Configuration__c> getActiveCasePriorityConfigurations(
        AccessLevel accessLevel
    ) {
        return Database.query(
            'SELECT Name, Case_Record_Type__c, Case_Type__c, Country_Tier__c, Country_Tier_Subcategory__c, Enquiry_Category__c, Enquiry_Sub_Category__c, ' +
                'Lead_Score__c, Lead_Source_Category__c, Future_Student_Stage__c, Date_from__c, Date_to__c, Priority__c, Applicant_Onshore__c ' +
                'FROM Case_Priority_Configuration__c ' +
                'WHERE Is_Active__c = TRUE ',
            accessLevel
        );
    }
}