/**
 * @description DAO Class for hed__Application__c Object. Contains soql and constants related to the Application object.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                                |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------------------------|
 *    | mark.j.mahilum                 | June 19, 2023         | DEPP-5846              | created file                                                                  |
 *    | mark.j.mahilum                 | July 03, 2023         | DEPP-5961              | Added getApplicationsByLeadIds                                                |
 *    | mark.j.mahilum                 | July 14, 2023         | DEPP-5799              | Added method getApplicationsByContactIds                                      |
 *    | eccarius.munoz                 | August 08, 2023       | DEPP-5760              | Added Program_Enrollment__c in SOQL under                                     |
 *    |                                |                       |                        | getApplicationsByContactIds method                                            |
 *    | mark.j.mahilum                 | August 31, 2023       | DEPP-6455              | Added getApplicationsActiveApplicants method                                  |
 *    |                                |                       |                        | to get active applicants                                                      |
 *    | arsenio.jr.dayrit              | September 08, 2023    | DEPP-5652              | Added fields in getApplicationsByLeadIds and                                  |
 *    |                                |                       |                        | getApplicationsByContactIds                                                   |
 *    | alexander.cadalin              | Oct 10, 2023          | DEPP-6814              | Added Initial Creation Date field to methods                                  |
 *    | arsenio.jr.dayrit              | October 06, 2023      | DEPP-6853              | Added CreatedDate and is Active field in  getApplicationsByLeadIds and        |
 *    |                                |                       |                        | getApplicationsByContactIds                                                   |
 *    | arsenio.jr.dayrit              | November 20, 2023     | DEPP-7268              | Added Offered_Program_Plan__r.Program_Level__c field in                       |         
 *    |                                |                       |                        | getAppsWithLatestCalculatedIntakeDateByApplicantIds                           |
 *    | eccarius.munoz                 | February 29, 2024     | DEPP-7838              | Added static values for application status                                    |
 *    | sebastianne.k.trias            | March 28, 2024        | DEPP-8382              | Added queryApplicationsByPastIntakeDateAndActiveApplicants method             |
 *    | mark.j.mahilum                 | April 30, 2024        | DEPP-7987              | Added new queryLocatorGetApplicationsByBatchProcess for application batchjob  |
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

    //Application Status
    public static final String STATUS_DECLINED_BY_APP = 'Declined by applicant';
    public static final String STATUS_WITHDRAWN = 'Withdrawn';
    public static final String STATUS_DECLINED = 'Declined';
    public static final String STATUS_OFFERED = 'Offered';
    public static final String STATUS_ACCEPTED = 'Accepted';
    public static final String STATUS_DECLINED_BY_APPLICANT = 'Declined by Applicant';
    public static final String STATUS_DEFERRAL_REQUESTED = 'Deferral Requested';
    public static final String STATUS_ACCEPTANCE_PAYMENT_RECEIVED = 'Acceptance - Payment Received';
    public static final String STATUS_ACCEPTANCE_NO_PAYMENT_REQUIRED = 'Acceptance - No Payment Required';
    public static final String STATUS_ACCEPTANCE_PENDING_MORE_INFO = 'Acceptance - Pending More Information';
    public static final String STATUS_ACCEPTANCE_PENDING_PAYMENT = 'Acceptance - Pending Payment';
    public static final String STATUS_CONDITIONAL_ACCEPTANCE = 'Conditional Acceptance';
    public static final String STATUS_CONDITIONAL_OFFER = 'Conditional Offer';
    public static final String STATUS_UNCONDITIONAL_OFFER = 'Unconditional Offer';
    public static final String STATUS_SUBMITTED = 'Submitted';

    public static final String ADMISSION_PROCESS_RTN_DEFER = 'RTN_DEFER';
    public static final String ADMISSION_PROCESS_RTN_QTAC = 'RTN_QTAC';

    public static final Set<String> INVALID_ADMISSION_PROCESSES = new Set<String>{
        ADMISSION_PROCESS_RTN_DEFER,
        ADMISSION_PROCESS_RTN_QTAC
    };

    public static final Set<String> CONTACT_UPDATE_BLOCK_STUDYLINK_STATUS = new Set<String>{
        'Acceptance - Payment Received',
        'Acceptance - Pending More Information',
        'Acceptance - Pending Payment',
        'Acceptance – Pending Payment',
        'Acceptance Processing',
        'Accepted',
        'Accepted Deferral',
        'EOI Successful'
    };

    public static final Set<String> studyLinkStatuses = new Set<String>{
        'Accepted',
        'Application Archived',
        'Closed',
        'Withdrawn',
        'Unsuccessful',
        'Declined by Applicant'
    };

    // TODO: confirm relationship between this list to above.
    // From developer notes in DEPP-5743
    public static final Set<String> STUDYLINK_TERMINAL_STATUSES = new Set<String>{
        'Accepted',
        'Application Archived',
        'Application Closed',
        'Incomplete withdrawn',
        'Unsuccessful',
        'Withdrawn',
        'Declined by applicant'
    };

    public static final Set<String> OFFER_BY_OFFER_STATUSES = new Set<String>{
        'No Response'
    };

    public static final Set<String> OFFER_BY_APPLICATION_STATUSES_FOR_STUDYLINK = new Set<String>{
        'Conditional Offer',
        'Unconditional Offer'
    };

    public static final Set<String> INTERNATIONAL_OFFER_TO_ACCEPTANCE_FOR_STUDYLINK = new Set<String>{
        STATUS_CONDITIONAL_OFFER,
        STATUS_UNCONDITIONAL_OFFER
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
        'Accepted','Admitted'
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

    public static final Set<String> INTL_ENTRY_APPLICATION_TO_OFFER_STATUSES_FOR_STUDYLINK = new Set<String>{
        'Submitted',
        'Under Assessment',
        'Under Assessment - Hold',
        'Under Assessment - Review'
    };

    public static final Set<String> INTL_EXIT_APPLICATION_TO_OFFER_STATUSES_FOR_STUDYLINK = new Set<String>{
        'New',
        'Unsubmitted',
        'Submitted',
        'Under Assessment',
        'Under Assessment - Hold',
        'Under Assessment - Review'
    };

    public static final Set<String> EXIT_STATUSES_INTERNATIONAL_APPLICATION_TO_OFFER_DIRECT_AUTO = new Set<String>{
        'Conditional Offer',
        'Unconditional Offer',
        'Withdrawn',
        'More Information Required',
        'Unsuccessful',
        'With Faculty',
        'With Faculty - Academic'
    };

    public static final Set<String> STATUS_SET_ACCEPTS_DECLINES_DEFERS_OFFER = new Set<String>{
        STATUS_ACCEPTANCE_NO_PAYMENT_REQUIRED,
        STATUS_ACCEPTANCE_PAYMENT_RECEIVED,
        STATUS_ACCEPTANCE_PENDING_MORE_INFO,
        STATUS_ACCEPTANCE_PENDING_PAYMENT,
        STATUS_ACCEPTED,
        STATUS_DECLINED_BY_APPLICANT,
        STATUS_DEFERRAL_REQUESTED,
        STATUS_CONDITIONAL_ACCEPTANCE,
        STATUS_WITHDRAWN
    };

    public static final Map<String,Set<String>> ADDRESS_FIELDS = new Map<String, Set<String>>{
        'Other' => new Set<String>{
            'Residential_Address_Line1__c', 'Residential_Address_Line2__c', 'Residential_Address_Line3__c',
            'Residential_Country__c', 'Residential_Postcode__c', 'Residential_State__c', 'Residential_Town__c'
        },
        'Mailing' => new Set<String>{
            'Postal_Address_Line1__c', 'Postal_Address_Line2__c', 'Postal_Address_Line3__c',
            'Postal_Country__c', 'Postal_Postcode__c', 'Postal_State__c', 'Postal_Town__c'
        }
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
        AccessLevel accessLevel
    ) {
        return Database.query(
            'SELECT Id, Calculated_Intake_Date__c, Intake_Year__c, RecordTypeId, Applied_Intake_Study_Period__r.hed__Start_Date__c ' +
            'FROM hed__Application__c ' +
            'WHERE Id IN :applicationIds ',
            accessLevel
        );
    }

    public List<hed__Application__c> getApplicationsByLeadIds(Set<Id> leadIds, String accessLevel) {
        return Database.query(
            'SELECT Id, hed__Applicant__c,Program_Enrollment__c,Program_Enrollment__r.Enrollment_Status__c, Lead__c,hed__Application_Date__c,Lead__r.Lead_Score__c, Application_Status__c,RecordTypeId,CreatedDate,Is_Active__c, ' +
                'Applied_Intake_Study_Period__c, Offer_Status__c, Calculated_Intake_Date__c, Applied_Intake_Study_Period__r.hed__Start_Date__c, ' +
                'Is_Agent_Assisted__c, hed__Initial_Creation_Date__c ' +
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
            'SELECT Id,Program_Enrollment__c,Program_Enrollment__r.Enrollment_Status__c,hed__Applicant__c,Application_Status__c,Offer_Status__c,Offered_Program_Plan__c,CreatedDate, ' +
                'Offered_Program_Plan__r.Availability_Start_Date__c, RecordTypeId,Admission_Process__c, QTAC_ApplicantID__c, Related_QTAC_Application__c,Related_QTAC_Application__r.Offer_Status__c, ' +
                'Applied_Intake_Study_Period__c, hed__Application_Status__c, Applied_Intake_Study_Period__r.hed__Start_Date__c,Offer_Lapse_Date__c, ' +
                'Is_Active__c, Is_Agent_Assisted__c, hed__Application_Date__c, Offer_Start_Date__c, hed__Applicant__r.Calculated_Cadence__c, ' +
                'hed__Applicant__r.QUT_Applicant__c, hed__Applicant__r.Future_Student_Journey_Status__c, Offer_Status_Date__c, ' +
                'hed__Applicant__r.QUT_Student__c, Calculated_Intake_Date__c, hed__Applicant__r.Lead_Score__c, hed__Initial_Creation_Date__c ' +
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
            'Offered_Program_Plan__r.Availability_Start_Date__c, RecordTypeId,Admission_Process__c, Related_QTAC_Application__c, ' +
            'Applied_Intake_Study_Period__c, Intake_Year__c,Applied_Intake_Study_Period__r.hed__Start_Date__c,Offer_Lapse_Date__c '+
            'FROM hed__Application__c ' +
            'WHERE Id IN: qtacApplicantId '+
            'AND RecordTypeId =: QTAC_RECTYPE_ID ' +  
            'WITH ' +
            String.escapeSingleQuotes(accessLevel)
        );
    }

    public List<hed__Application__c> getApplicationsActiveApplicants(
        Set<Id> contactIds,
        String accessLevel
    ) {
        return Database.query(
            'SELECT Id,Program_Enrollment__c,hed__Applicant__c,Application_Status__c,Offer_Status__c,Offered_Program_Plan__c, ' +
            'Offered_Program_Plan__r.Availability_Start_Date__c, RecordTypeId,Admission_Process__c, QTAC_ApplicantID__c, ' +
            'Applied_Intake_Study_Period__c,Applied_Intake_Study_Period__r.hed__Start_Date__c,Offer_Lapse_Date__c, ' +
            'Is_Active__c, Is_Agent_Assisted__c, hed__Application_Date__c, Offer_Start_Date__c, hed__Applicant__r.Calculated_Cadence__c, hed__Applicant__r.QUT_Applicant__c, ' +
            'hed__Applicant__r.Future_Student_Journey_Status__c, Offer_Status_Date__c, hed__Applicant__r.QUT_Student__c, Calculated_Intake_Date__c, hed__Applicant__r.Lead_Score__c ' +
            'FROM hed__Application__c ' +
            'WHERE hed__Applicant__c IN :contactIds ' +
            'AND Calculated_Intake_Date__c >= TODAY ' +
            'AND ((RecordType.DeveloperName = \'QTAC\' AND Is_Active__c = TRUE) ' +
            'OR (RecordType.DeveloperName = \'StudyLink\' AND Application_Status__c NOT IN: studyLinkStatuses) ' +
            'OR ((RecordType.DeveloperName = \'SAMS_Legacy\' OR RecordType.DeveloperName = \'SAMS_CIAnywhere\') ' +
            'AND Application_Status__c NOT IN: samsStatuses)) ' +
            'WITH ' +
            String.escapeSingleQuotes(accessLevel)
        );
    }

    public List<hed__Application__c> getApplicationsByLeadOrContactIds(Set<String> recordIds,Set<String> cadencesName, String accessLevel) {
        return Database.query(
            'SELECT Id, hed__Applicant__c,Program_Enrollment__c,Program_Enrollment__r.Enrollment_Status__c, Lead__c,hed__Application_Date__c,Lead__r.Lead_Score__c, Application_Status__c,RecordTypeId, ' +
            'Applied_Intake_Study_Period__c, Offer_Status__c, Calculated_Intake_Date__c, Applied_Intake_Study_Period__r.hed__Start_Date__c, ' +
            'Is_Agent_Assisted__c ' +
            'FROM hed__Application__c ' +
            'WHERE (Lead__c IN :recordIds OR hed__Applicant__c IN :recordIds) ' +
            'AND (Lead__r.Calculated_Cadence__c IN:cadencesName OR hed__Applicant__r.Calculated_Cadence__c IN:cadencesName) ' +            
            'WITH ' +
            String.escapeSingleQuotes(accessLevel) +
            ' ORDER by Calculated_Intake_Date__c DESC NULLS LAST'
        );
    }

    public List<hed__Application__c> getAppsWithLatestCalculatedIntakeDateByApplicantIds(
        Set<Id> recordIds,
        String accessLevel
    ) {
        return Database.query(
            'SELECT Id,Program_Enrollment__c,Program_Enrollment__r.Enrollment_Status__c,Program_Enrollment__r.Enrollment_Status_Date__c,Program_Enrollment__r.hed__Admission_Date__c, hed__Applicant__c,Application_Status__c,Offer_Status__c,Offered_Program_Plan__c,CreatedDate, ' +
                'Offered_Program_Plan__r.Availability_Start_Date__c,Offered_Program_Plan__r.Program_Level__c,hed__Applicant__r.Lead_Source_Category__c,Lead__r.Lead_Source_Category__c, RecordTypeId,Admission_Process__c, QTAC_ApplicantID__c, Related_QTAC_Application__c,Related_QTAC_Application__r.Offer_Status__c,Related_QTAC_Application__r.Is_Active__c, ' +
                'Applied_Intake_Study_Period__c, hed__Application_Status__c, Applied_Intake_Study_Period__r.hed__Start_Date__c, Lead__r.Calculated_Cadence__c,Offer_Lapse_Date__c, ' +
                'Is_Active__c, Is_Agent_Assisted__c, hed__Application_Date__c, Offer_Start_Date__c, hed__Applicant__r.Calculated_Cadence__c, ' +
                'hed__Applicant__r.QUT_Applicant__c, hed__Applicant__r.Future_Student_Journey_Status__c, Offer_Status_Date__c, Lead__c, ' +
                'hed__Applicant__r.QUT_Student__c, Calculated_Intake_Date__c, hed__Applicant__r.Lead_Score__c, hed__Initial_Creation_Date__c, Applied_Intake_Study_Period__r.Last_Admission_Date__c ' +
                'FROM hed__Application__c ' +
                'WHERE (hed__Applicant__c IN :recordIds  OR Lead__c IN: recordIds) '+
                'AND Calculated_Intake_Date__c >= TODAY ' +
                'AND ( RecordType.DeveloperName = \'StudyLink\' '+
                'OR RecordType.DeveloperName = \'SAMS_Legacy\' '+ 
                'OR RecordType.DeveloperName = \'SAMS_CIAnywhere\') ' +
                'WITH ' +
                String.escapeSingleQuotes(accessLevel) +
                ' ORDER BY Calculated_Intake_Date__c DESC'
        );
    }

    public List<hed__Application__c> getApplicationsByLeadIdOrContactId(Set<String> recordIds, String accessLevel) {
        return Database.query(
            'SELECT Id, hed__Applicant__c,Program_Enrollment__c,Program_Enrollment__r.Enrollment_Status__c, Lead__c,hed__Application_Date__c,Lead__r.Lead_Score__c, Application_Status__c,RecordTypeId, ' +
            'Applied_Intake_Study_Period__c, Offer_Status__c, Calculated_Intake_Date__c, Applied_Intake_Study_Period__r.hed__Start_Date__c, ' +
            'Is_Agent_Assisted__c ' +
            'FROM hed__Application__c ' +
            'WHERE (Lead__c IN :recordIds OR hed__Applicant__c IN :recordIds) ' +
            'WITH ' +
            String.escapeSingleQuotes(accessLevel)
        );
    }

    
    public Database.QueryLocator queryApplicationsByPastIntakeDateAndActiveApplicants(
        String accessLevel
    ) {
        String query =
            'SELECT Id, hed__Applicant__c, hed__Applicant__r.QUT_Applicant__c ' +
            'FROM hed__Application__c ' +
            'WHERE hed__Applicant__r.QUT_Applicant__c = true ' +
            'AND Calculated_Intake_Date__c < TODAY ' +
            'WITH ' +
            String.escapeSingleQuotes(accessLevel);
        return Database.getQueryLocator(query);
    }

    public Database.QueryLocator queryLocatorGetApplicationsByBatchProcess(Set<String> batchProcessSet, AccessLevel accessLevel){
        String query =
            ' SELECT Id,RecordType.DeveloperName,Batch_Process__c,Application_Status__c,FirstName__c,LastName__c,Email__c,BirthDate__c,QUT_Student_ID__c,Name, ' +
            ' StudyLink_ApplicantID__c,QTAC_ApplicantID__c,Mobile__c,Indigenous_Status__c,Citizenship_Status__c,Citizenship_Country__c,MiddleName__c,Lead__c ' +
            ' FROM hed__Application__c ' +
            ' WHERE Batch_Process__c IN: batchProcessSet ';
        return Database.getQueryLocator(query,accessLevel);
    }
    
    public List<hed__Application__c> getApplicationsByBatchProcess(Set<String> batchProcessSet, AccessLevel accessLevel){
        String query =
            ' SELECT Id,RecordType.DeveloperName,Batch_Process__c,Application_Status__c,FirstName__c,LastName__c,Email__c,BirthDate__c,QUT_Student_ID__c,Name, ' +
            ' StudyLink_ApplicantID__c,QTAC_ApplicantID__c,Mobile__c,Indigenous_Status__c,Citizenship_Status__c,Citizenship_Country__c,MiddleName__c,Lead__c ' +
            ' FROM hed__Application__c ' +
            ' WHERE Batch_Process__c IN: batchProcessSet ' +
            ' LIMIT 1 ';
        return Database.query(query,accessLevel);
    }
}