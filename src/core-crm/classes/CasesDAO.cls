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
 *    | gabriel.p.ventayen             | April 26, 2024        | DEPP-8544              | change case rectype map to inbound enquiry  |
 *    | gabriel.p.ventayen             | April 29, 2024        | DEPP-8614              | added some variables for Student Success    |
 *    | eccarius.munoz                 | May 16, 2024          | DEPP-8484              | added new method getCasesByStatusAndRecType |
 *    | gabriel.p.ventayen             | May 23, 2024          | DEPP-8833              | added getCasesByQualtricsSurveyIds          |
 */
public inherited sharing class CasesDAO extends DmlBase implements ICasesDAO {

    public static final String ORIGIN_WHATSAPP = 'WhatsApp';
    public static final String ORIGIN_ENGAGEMENT_LIST = 'Engagement List';
    public static final String ORIGIN_EMAIL = 'Email';
    public static final String STATUS_CREATED = 'Created';
    public static final String STATUS_CLOSED = 'Closed';
    public static final String DESCRIPTION_ENGAGEMENT_LIST = 'This case has been automatically generated as part of an Engagement List Configuration.';
    public static final String INITIAL_COMMUNICATION_STATUS_SENT = 'Sent';
    public static final String INITIAL_COMMUNICATION_STATUS_PENDING = 'Pending';

    public static final Id INBOUND_ENQUIRY_RECTYPE_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
        .get('Inbound_Enquiry')
        .getRecordTypeId();
    public static final Id OUTREACH_RECTYPE_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
        .get('Outreach')
        .getRecordTypeId();

    public static final Map<String, Id> CASE_RECTYPE_MAP = new Map<String, Id>{
        'Inbound Enquiry' => INBOUND_ENQUIRY_RECTYPE_ID
    };

    public static final String CASE_TYPE_DOMESTIC = 'Domestic Future Student Enquiry';
    public static final String CASE_TYPE_INTERNATIONAL = 'International Future Student Enquiry';
    public static final String CASE_TYPE_STUDENT_SUCCESS_RETENTION = 'Student Success - Retention';
    public static final String PRIORITY_HIGH = 'High';
    public static final String PRIORITY_MEDIUM = 'Medium';
    public static final String PRIORITY_LOW = 'Low';

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

    public List<Case> getCasesByEngagementListConfigurationIds(
        String configurationId,
        AccessLevel accessLevel
    ) {
        if(String.isBlank(configurationId)){
            return new List<Case>();
        }

        return Database.query(
            'SELECT  Id, CaseNumber, ContactId, Contact.Name, Status, Owner.Name, CreatedDate, Engagement_List_Configuration__c ' +
            'FROM Case ' +
            'WHERE Engagement_List_Configuration__c =: configurationId ',
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
            'SELECT Id, Category__c, Sub_Category__c, Last_Queue_Name__c, CreatedDate, Lead__c, ContactId, RecordType.Name, Lead__r.Marketing_Segmentation__r.My_Country_Of_Citizenship__c, ' + 
                'Contact.Lead_Source_Category__c, Lead__r.Lead_Source_Category__c, Contact.Citizenship_Country__c, Lead__r.Lead_Score__c, Contact.Lead_Score__c, ' +
                'Lead__r.Future_Student_Journey_Status__c, Contact.Future_Student_Journey_Status__c, Priority, Subject, Contact.Applicant_Onshore__c, Case_Type__c, Outreach_Key__c, ' +
                'Engagement_List_Configuration__r.Email_Template__c, Engagement_List_Configuration__r.Communication_Channel__c, Contact.QUT_Learner_Email__c, Engagement_List_Configuration__r.Qualtrics_Instrument_Id__c, Qualtrics_Survey__c, CaseNumber, Contact.Name, Status, Owner.Name ' +           
            'FROM Case ' +
            'WHERE Id IN :caseIds ',
            accessLevel
        ); 
    }

    public List<case> getCasesByIdsImported(
        Set<Id> caseIds,
        AccessLevel accessLevel
    ) {
        return Database.query(
            'SELECT Id, CaseNumber, Contact.Name, Status, Owner.Name, CreatedDate, ' +
            'Category__c, Sub_Category__c, ContactId, RecordType.Name, ' + 
            'Contact.Citizenship_Country__c, Contact.MobilePhone, Contact.QUT_Student_Id__c, ' +
            'Contact.Future_Student_Journey_Status__c, Priority, Subject, Contact.Applicant_Onshore__c, Case_Type__c, Outreach_Key__c, ' +
            'Engagement_List_Configuration__r.Email_Template__c, Engagement_List_Configuration__r.Communication_Channel__c, Contact.QUT_Learner_Email__c, Engagement_List_Configuration__r.Qualtrics_Instrument_Id__c, Qualtrics_Survey__c ' +
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

    public List<Case> getOpenOutreachCasesByConfigAndContactIds(
        Set<Id> contactIds,
        Id configId,
        AccessLevel accessLevel
    ) {
        return Database.query(
            'SELECT Id, ContactId ' +
              'FROM Case ' +
             'WHERE IsClosed != true ' +
               'AND RecordTypeId =: OUTREACH_RECTYPE_ID ' +
               'AND Engagement_List_Configuration__c =: configId ' +
               'AND ContactId IN : contactIds', 
            accessLevel
        );
    }

    public List<Case> getCasesByQualtricsSurveyIds(
        Set<Id> qualtricsSurveyIds,
        AccessLevel accessLevel
    ) {
        return Database.query(
            'SELECT Id, ContactId, Engagement_List_Configuration__r.Email_Template__c, Engagement_List_Configuration__r.Communication_Channel__c, Contact.QUT_Learner_Email__c, Qualtrics_Survey__c ' +
              'FROM Case ' +
             'WHERE Qualtrics_Survey__c IN :qualtricsSurveyIds ', 
            accessLevel
        );
    }
}