/**
 * @description DAO Class for hed__Application__c Object. Contains soql and constants related to the Application object.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------------------|
 *    | mark.j.mahilum                 | June 19, 2023         | DEPP-5846              | created file                               |
 *    | mark.j.mahilum                 | July 03, 2023         | DEPP-5961              | Added getApplicationsByLeadIds             |
 *    | mark.j.mahilum                 | July 14, 2023         | DEPP-5799              | Added method getApplicationsByContactIds   |
 *    | eccarius.munoz                 | August 08, 2023       | DEPP-5760              | Added Program_Enrollment__c in SOQL under  |
 *    |                                |                       |                        | getApplicationsByContactIds method         |
 */
public inherited sharing class ApplicationsDAO extends DmlBase implements IApplicationsDAO {
    public static final Id QTAC_RECTYPE_ID = Schema.SObjectType.hed__Application__c.getRecordTypeInfosByDeveloperName()
        .get('QTAC')
        .getRecordTypeId();
    public static final Id SAMS_LEGACY_RECTYPE_ID = Schema.SObjectType.hed__Application__c.getRecordTypeInfosByDeveloperName()
        .get('SAMS_Legacy')
        .getRecordTypeId();
    public static final Id SAMS_CIANYWHERE_RECTYPE_ID = Schema.SObjectType.hed__Application__c.getRecordTypeInfosByDeveloperName()
        .get('SAMS_CIAnywhere')
        .getRecordTypeId();
    public static final Id STUDYLINK_RECTYPE_ID = Schema.SObjectType.hed__Application__c.getRecordTypeInfosByDeveloperName()
        .get('StudyLink')
        .getRecordTypeId();

    public static final Set<String> studyLinkStatuses = new Set<String>{
        'Accepted',
        'Application Archived',
        'Closed',
        'Withdrawn',
        'Unsuccessful',
        'Declined by Applicant'
    };

    public static final Set<String> OFFER_BY_OFFER_STATUSES = new Set<String>{
        'No Response'
    };

    public static final Set<String> OFFER_BY_APPLICATION_STATUSES_FOR_STUDYLINK = new Set<String>{
        'Conditional Offer',
        'Unconditional Offer'
    };

    public static final Set<String> DECLINED_OFFER_BY_APPLICATION_STATUSES_FOR_STUDYLINK = new Set<String>{
        'Deferral Requested',
        'Accepted Deferral'
    };

    public static final Set<String> ACCEPTED_OFFER_BY_APPLICATION_STATUSES_FOR_STUDYLINK = new Set<String>{
        'Acceptance - No Payment Required',
        'Acceptance - Payment Received',
        'Acceptance - Pending More Information',
        'Acceptance - Pending Payment',
        'Acceptance - Part Payment Received',
        'Acceptance - Review',
        'Acceptance - Processing'
    };

    public static final Set<String> OFFER_BY_APPLICATION_STATUSES_FOR_SAMS = new Set<String>{
        'Offered'
    };

    public static final Set<String> OFFER_BY_OFFER_STATUSES_FOR_SAMS = new Set<String>{ 'Offered' };

    public static final Set<String> DECLINED_OFFER_BY_OFFER_STATUSES_FOR_SAMS = new Set<String>{
        'Deferred'
    };

    public static final Set<String> ACCEPTED_OFFER_BY_OFFER_STATUSES_FOR_SAMS = new Set<String>{
        'Accepted'
    };

    public static final Set<String> samsStatuses = new Set<String>{
        'Admitted',
        'Not Qualified',
        'Withdrawn',
        'Unsuccessful'
    };

    public static final Set<String> DECLINED_OFFER_BY_OFFER_STATUSES_FOR_QTAC = new Set<String>{
        'Deferment granted, wants considered higher prefs',
        'Deferment granted',
        'Deferment granted, superseded by other offer',
        'Deferment retained, made offer in future semester'
    };

    public static final Set<String> ACCEPTED_OFFER_BY_OFFER_STATUSES_FOR_QTAC = new Set<String>{
        'Accepted unconditionally',
        'Accepted retained, made offer in future semester',
        'Accepted, superseded by other offer',
        'Accepted, wants to be considered for higher prefs'
    };

    public static IApplicationsDAO newInstance() {
        return (IApplicationsDAO) ImplementationSelector.DAO.newInstance(
            hed__Application__c.SObjectType
        );
    }

    public Schema.SObjectType getSObjectType() {
        return hed__Application__c.SObjectType;
    }

    public List<hed__Application__c> getApplicationsBySetIds(
        Set<Id> applicationIds,
        String accessLevel
    ) {
        return Database.query(
            'SELECT Id, Name, Calculated_Intake_Date__c, Intake_Year__c, RecordTypeId, Applied_Intake_Study_Period__r.hed__Start_Date__c ' +
            'FROM hed__Application__c ' +
            'WHERE Id IN :applicationIds ' + 
            'WITH ' +
            String.escapeSingleQuotes(accessLevel)
        );
    }

    public List<hed__Application__c> getApplicationsByLeadIds(Set<Id> leadIds, String accessLevel) {
        return Database.query(
            'SELECT Id, hed__Applicant__c, Lead__c, Application_Status__c,RecordTypeId, ' +
                'Applied_Intake_Study_Period__c, Applied_Intake_Study_Period__r.hed__Start_Date__c, ' +
                'Is_Agent_Assisted__c ' +
                'FROM hed__Application__c ' +
                'WHERE Lead__c IN :leadIds ' +
                'WITH ' +
                String.escapeSingleQuotes(accessLevel)
        );
    }

    public List<hed__Application__c> getApplicationsByContactIds(
        Set<Id> contactIds,
        String accessLevel
    ) {
        return Database.query(
            'SELECT Id,Name,Program_Enrollment__c,hed__Applicant__c,Application_Status__c,Offer_Status__c,Offered_Program_Plan__c, ' +
                'Offered_Program_Plan__r.Availability_Start_Date__c, RecordTypeId,Admission_Process__c, QTAC_ApplicantID__c, ' +
                'Applied_Intake_Study_Period__c,Applied_Intake_Study_Period__r.hed__Start_Date__c,Offer_Lapse_Date__c, ' +
                'Is_Agent_Assisted__c, hed__Application_Date__c, Offer_Start_Date__c, hed__Applicant__r.Calculated_Cadence__c, hed__Applicant__r.QUT_Applicant__c, ' +
                'hed__Applicant__r.Future_Student_Journey_Status__c, Offer_Status_Date__c, hed__Applicant__r.QUT_Student__c, Calculated_Intake_Date__c, hed__Applicant__r.Lead_Score__c ' +
                'FROM hed__Application__c ' +
                'WHERE hed__Applicant__c IN :contactIds '+
                'WITH ' +
                String.escapeSingleQuotes(accessLevel)
        );
    }

    public List<hed__Application__c> getQtacApplicationsWithQtacApplicantId(
        List<String> qtacApplicantId,
        String accessLevel
    ) {
        return Database.query(
            'SELECT Id,hed__Applicant__c,Application_Status__c,Offer_Status__c,Offered_Program_Plan__c, '+
            'Offered_Program_Plan__r.Availability_Start_Date__c, RecordTypeId,Admission_Process__c, QTAC_ApplicantID__c, ' +
            'Applied_Intake_Study_Period__c, Intake_Year__c,Applied_Intake_Study_Period__r.hed__Start_Date__c,Offer_Lapse_Date__c '+
            'FROM hed__Application__c ' +
            'WHERE Id IN: qtacApplicantId '+
            'AND RecordTypeId =: QTAC_RECTYPE_ID ' +  
            'WITH ' +
            String.escapeSingleQuotes(accessLevel)
        );
    }
}
