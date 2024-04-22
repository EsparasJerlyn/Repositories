/**
 * @description DAO Class for Case Object. Contains soql and constants related to the Case object.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                              |
 *    |--------------------------------|-----------------------|------------------------|---------------------------------------------|
 *    | arsenio.jr.dayrit              | September 11, 2023    | DEPP-5652              | created file                                |
 *    | neil.s.h.lesidan               | September 20, 2023    | DEPP-6478              | Added getCaseBySuppliedEmail                |
 *    | arsenio.jr.dayrit              | September 26, 2023    | DEPP-6720              | added new method getCasesBySuppliedPhone    |
 */
public inherited sharing class CasesDAO extends DmlBase implements ICasesDAO {

    public static final String ORIGIN_WHATSAPP = 'WhatsApp';

    public static final Id DOMESTICFS_RECTYPE_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
        .get('Domestic_Future_Student_Enquiry')
        .getRecordTypeId();
    public static final Id INTERNATIONALFS_RECTYPE_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
        .get('International_Future_Student_Enquiry')
        .getRecordTypeId();

    public static final Map<String, Id> CASE_RECTYPE_MAP = new Map<String, Id>{
        'Domestic Future Student Enquiry' => DOMESTICFS_RECTYPE_ID,
        'International Future Student Enquiry' => INTERNATIONALFS_RECTYPE_ID
    };

    public static final Map<String, Integer> PRIORITY_ORDER = new Map<String, Integer>{
        'High' => 3,
        'Medium' => 2,
        'Low' => 1,
        '' => 0,
        null => 0
    };

    public static ICasesDAO newInstance() {
        return (ICasesDAO) ImplementationSelector.DAO.newInstance(
            Case.SObjectType
        );
    }

    public Schema.SObjectType getSObjectType() {
        return Case.SObjectType;
    }

    public List<Case> getCasesByContactIds(
        Set<Id> contactIds,
        AccessLevel accessLevel
    ) {
        return Database.query(
            'SELECT  Id, Category__c, CreatedDate, ContactId, Subject ' +
            'FROM Case ' +
            'WHERE ContactId IN :contactIds ',
            accessLevel
        );
    }

    public List<Case> getCasesByLeadIds(
        Set<Id> leadIds,
        AccessLevel accessLevel
    ) {
        return Database.query(
            'SELECT  Id, Category__c, CreatedDate, Lead__c, Subject ' +
            'FROM Case ' +
            'WHERE Lead__c IN :leadIds ',
            accessLevel
        );
    }

    public List<Case> getCaseBySuppliedEmail(
        String suppliedEmail,
        AccessLevel accessLevel
    ) {
        return Database.query(
            'SELECT  Id, Web_First_Name__c, Web_Last_Name__c, SuppliedEmail, ContactId, Lead__c ' +
                'FROM Case ' +
                'WHERE SuppliedEmail =: suppliedEmail ',
                accessLevel
        );
    }

    public List<Case> getCasesByContactOrLeadIds(
        Set<Id> contactOrLeadIds,
        AccessLevel accessLevel
    ) {
        return Database.query(
            'SELECT Id, Category__c, CreatedDate, Lead__c, ContactId, Subject, Lead_Score_Reset__c ' +
            'FROM Case ' +
            'WHERE Lead__c IN :contactOrLeadIds ' +
            'OR ContactId IN :contactOrLeadIds ',
            accessLevel
        );
    }

    public List<Case> getCasesBySuppliedPhone(
        Set<String> suppliedPhone,
        AccessLevel accessLevel
    ) {
        return Database.query(
            'SELECT Id, SuppliedPhone, ContactId, Lead__c ' +
            'FROM Case ' +
            'WHERE SuppliedPhone != NULL ' +
            'AND suppliedPhone IN :SuppliedPhone ', 
            accessLevel
        );
    }


    public List<Case> getCasesByIds(
        Set<Id> caseIds,
        AccessLevel accessLevel
    ) {
        return Database.query(
            'SELECT Id, Category__c, Sub_Category__c, CreatedDate, Lead__c, ContactId, RecordType.Name, Lead__r.Marketing_Segmentation__r.My_Country_Of_Citizenship__c, ' + 
                'Contact.Lead_Source_Category__c, Lead__r.Lead_Source_Category__c, Contact.Citizenship_Country__c, Lead__r.Lead_Score__c, Contact.Lead_Score__c, ' +
                'Lead__r.Future_Student_Journey_Status__c, Contact.Future_Student_Journey_Status__c, Priority, Subject, Contact.Applicant_Onshore__c ' +
            'FROM Case ' +
            'WHERE Id IN :caseIds ',
            accessLevel
        ); 
    }

    public Database.QueryLocator queryLocatorGetCasesByContactOrLeadIds(
        Set<Id> recordIds
    ){
        String query =
            'SELECT Id, Category__c, CreatedDate, Lead__c, ContactId, Subject, Lead_Score_Reset__c ' +
              'FROM Case ' +
             'WHERE Lead__c IN :recordIds ' +
                'OR ContactId IN :recordIds ';
        return Database.getQueryLocator(query);
    }
}