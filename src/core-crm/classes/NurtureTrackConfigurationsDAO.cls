/**
 * @description DAO Class for Nurturing Track Configuration Object. Contains soql and constants related to the custom object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                             |
      |--------------------------------|-----------------------|------------------------|----------------------------------------------------------------------------|
      | mark.j.mahilum                 | July 25, 2023         | DEPP-6106              | Created file                                                               |
      | roy.nino.s.regala              | Auh 09, 2023          | DEPP-5677              | Added  criteria type field                                                 |
      | arsenio.jr.dayrit              | September 08, 2023    | DEPP-5652              | Added fields in getNurtureTrackLeadScoreThreshold                          |
      | arsenio.jr.dayrit              | October 03, 2023      | DEPP-6816              | Added static variable for International Offer to Acceptance                |
      | arsenio.jr.dayrit              | October 04, 2023      | DEPP-6834              | Added static variable for Domestic Accepted not yet Enrolled               |
      | eccarius.munoz                 | October 16, 2023      | DEPP-6914              | Added static variable for Domestic and International Enrolment to Census   |
      | eccarius.munoz                 | October 16, 2023      | DEPP-6914              | Domestic First Offer to Acceptance (Automated)                             |
      | eccarius.munoz                 | February 29, 2024     | DEPP-7838              | Renamed International Offer to Acceptance (add - Direct) and created new   |
      |                                |                       |                        | nurture track named International Offer to Acceptance - Agent              |
 */
public inherited sharing class NurtureTrackConfigurationsDAO extends DmlBase implements INurtureTrackConfigurationsDAO {

    public static final String NURTURE_FIELDS = 'Id, Cadence_Name__c, Lead_Score_Threshold__c, Status__c,Key_Date_Offset_Days__c,Criteria_Type__c,Enquiry_Category_L1__c ';
    
    public static final String INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_MANUAL = 'International Strong Interest Pre-Application';
    public static final String INTERNATIONAL_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED = 'International Strong Interest Pre-Application (Automated)';
    public static final String DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_MANUAL = 'Domestic Strong Interest Pre-Application';
    public static final String DOMESTIC_STRONG_INTEREST_PRE_APPLICATION_AUTOMATED = 'Domestic Strong Interest Pre-Application (Automated)';
    public static final String INTERNATIONAL_OFFER_TO_ACCEPTANCE_DIRECT_AUTOMATED = 'International Offer to Acceptance - Direct (Automated)';
    public static final String INTERNATIONAL_OFFER_TO_ACCEPTANCE_MANUAL = 'International Offer to Acceptance - Direct';
    public static final String INTERNATIONAL_OFFER_TO_ACCEPTANCE_AGENT_AUTOMATED = 'International Offer to Acceptance - Agent (Automated)';
    public static final String DOMESTIC_ACCEPTED_NOT_YET_ENROLLED_AUTOMATED = 'Domestic Accepted not yet Enrolled (Automated)';
    public static final String DOMESTIC_ACCEPTED_NOT_YET_ENROLLED_MANUAL = 'Domestic Accepted not yet Enrolled';
    public static final String DOMESTIC_INTERNATIONAL_ENROLLMENT_CENSUS_CADENCE = 'Domestic and International Enrolment to Census';
    public static final String DOMESTIC_FIRST_OFFER_TO_ACCEPTANCE_MANUAL = 'Domestic First Offer to Acceptance';
    public static final String DOMESTIC_FIRST_OFFER_TO_ACCEPTANCE_AUTOMATED = 'Domestic First Offer to Acceptance (Automated)';
    public static final String INTERNATIONAL_APP_SUBMISSION_DIRECT_APPLICANT_MANUAL = 'International Application Submission - Direct Applicant';
    public static final String INTERNATIONAL_APP_SUBMISSION_DIRECT_APPLICANT_AUTOMATED = 'International Application Submission - Direct Applicant (Automated)';
    public static final String INTERNATIONAL_ACCEPTANCE_DEPOSIT_NOT_PAID_MANUAL = 'International Acceptance Deposit not Paid';
    public static final String DOMESTIC_DEFERRED_OFFER_TO_ACCEPTANCE_MANUAL = 'Domestic Deferred Offer to Acceptance';
    public static final String INTERNATIONAL_APPLICATION_TO_OFFER_MANUAL = 'International Application to Offer';
    public static final String DOMESTIC_ACCEPTED_AND_ADMITTED_MANUAL = 'Domestic Accepted and Admitted';
    public static final String DOMESTIC_OFFER_LAPSED_AUTOMATED = 'Domestic Offer Lapsed (Automated)';
    public static final String DOMESTIC_OFFER_LAPSED_MANUAL = 'Domestic Offer Lapsed';
    public static final String INTERNATIONAL_APPLICATION_TO_OFFER_DIRECT_AUTOMATED = 'International Application to Offer - Direct (Automated)';
    public static final String INTERNATIONAL_APPLICATION_TO_OFFER_AGENT_AUTOMATED = 'International Application to Offer - Agent (Automated)';
    public static final String INTERNATIONAL_PRE_APPLICATION_PARTNER_SOURCE_AUTOMATED = 'International Pre-Application - Partner Sourced (Automated)';
    public static final String INTERNATIONAL_PRE_APPLICATION_PARTNER_SOURCE_MANUAL = 'International Pre-Application - Partner Sourced';

    public static final Set<String> DOMESTIC_TRACK_SUCCEEDING_STRONG_INTEREST = new Set<String>{
        DOMESTIC_FIRST_OFFER_TO_ACCEPTANCE_AUTOMATED, //Domestic First Offer to Acceptance (Automated)
        DOMESTIC_DEFERRED_OFFER_TO_ACCEPTANCE_MANUAL, //Domestic Deferred Offer to Acceptance
        DOMESTIC_ACCEPTED_NOT_YET_ENROLLED_AUTOMATED, //Domestic Accepted not yet Enrolled (Automated)
        DOMESTIC_ACCEPTED_AND_ADMITTED_MANUAL, //Domestic Accepted and Admitted'
        DOMESTIC_INTERNATIONAL_ENROLLMENT_CENSUS_CADENCE, //Domestic and International Enrolment to Census
        DOMESTIC_OFFER_LAPSED_AUTOMATED//Domestic Offer Lapsed (Automated)
    };

    public static final Set<String> DOMESTIC_TRACK_SUCCEEDING_FIRST_OFFER = new Set<String>{
        DOMESTIC_DEFERRED_OFFER_TO_ACCEPTANCE_MANUAL, //Domestic Deferred Offer to Acceptance
        DOMESTIC_ACCEPTED_NOT_YET_ENROLLED_AUTOMATED, //Domestic Accepted not yet Enrolled (Automated)
        DOMESTIC_ACCEPTED_AND_ADMITTED_MANUAL, //Domestic Accepted and Admitted'
        DOMESTIC_INTERNATIONAL_ENROLLMENT_CENSUS_CADENCE, //Domestic and International Enrolment to Census
        DOMESTIC_OFFER_LAPSED_AUTOMATED//Domestic Offer Lapsed (Automated)
    };

    public static final Set<String> DOMESTIC_TRACK_SUCCEEDING_DEFFERED_OFFER = new Set<String>{
        DOMESTIC_ACCEPTED_NOT_YET_ENROLLED_AUTOMATED, //Domestic Accepted not yet Enrolled (Automated)
        DOMESTIC_ACCEPTED_AND_ADMITTED_MANUAL, //Domestic Accepted and Admitted'
        DOMESTIC_INTERNATIONAL_ENROLLMENT_CENSUS_CADENCE, //Domestic and International Enrolment to Census
        DOMESTIC_OFFER_LAPSED_AUTOMATED//Domestic Offer Lapsed (Automated)
    };
    public static final Set<String> DOMESTIC_TRACK_SUCCEEDING_NOT_YET_ENROLLED = new Set<String>{
        DOMESTIC_ACCEPTED_AND_ADMITTED_MANUAL, //Domestic Accepted and Admitted'
        DOMESTIC_INTERNATIONAL_ENROLLMENT_CENSUS_CADENCE, //Domestic and International Enrolment to Census
        DOMESTIC_OFFER_LAPSED_AUTOMATED//Domestic Offer Lapsed (Automated)
    };

    public static final Set<String> DOMESTIC_TRACK_SUCCEEDING_ACCEPTED_ADMITTED = new Set<String>{
        DOMESTIC_INTERNATIONAL_ENROLLMENT_CENSUS_CADENCE, //Domestic and International Enrolment to Census
        DOMESTIC_OFFER_LAPSED_AUTOMATED//Domestic Offer Lapsed (Automated)
    };

    public static final Set<String> DOMESTIC_TRACK_SUCCEEDING_CENSUS = new Set<String>{
        DOMESTIC_OFFER_LAPSED_AUTOMATED//Domestic Offer Lapsed (Automated)
    };

    public static final Set<String> INTERNATIONAL_TRACK_SUCCEEDING_STRONG_INTEREST = new Set<String>{
        INTERNATIONAL_PRE_APPLICATION_PARTNER_SOURCE_AUTOMATED, //International Pre-Application - Partner Sourced (Automated)
        INTERNATIONAL_APP_SUBMISSION_DIRECT_APPLICANT_AUTOMATED, //International Application Submission - Direct Applicant (Automated)
        INTERNATIONAL_APPLICATION_TO_OFFER_DIRECT_AUTOMATED, //International Application to Offer - Direct (Automated)
        INTERNATIONAL_APPLICATION_TO_OFFER_AGENT_AUTOMATED, //International Application to Offer - Agent (Automated)
        INTERNATIONAL_APPLICATION_TO_OFFER_MANUAL, //International Application to Offer
        INTERNATIONAL_OFFER_TO_ACCEPTANCE_DIRECT_AUTOMATED, //International Offer to Acceptance - Direct (Automated)
        INTERNATIONAL_OFFER_TO_ACCEPTANCE_AGENT_AUTOMATED, //International Offer to Acceptance - Agent (Automated)
        INTERNATIONAL_ACCEPTANCE_DEPOSIT_NOT_PAID_MANUAL, //International Acceptance Deposit not Paid
        DOMESTIC_INTERNATIONAL_ENROLLMENT_CENSUS_CADENCE //Domestic and International Enrolment to Census
    };

    public static final Set<String> INTERNATIONAL_TRACK_SUCCEEDING_PARTNER_SOURCED = new Set<String>{
        INTERNATIONAL_APP_SUBMISSION_DIRECT_APPLICANT_AUTOMATED, //International Application Submission - Direct Applicant (Automated)
        INTERNATIONAL_APPLICATION_TO_OFFER_DIRECT_AUTOMATED, //International Application to Offer - Direct (Automated)
        INTERNATIONAL_APPLICATION_TO_OFFER_AGENT_AUTOMATED, //International Application to Offer - Agent (Automated)
        INTERNATIONAL_APPLICATION_TO_OFFER_MANUAL, //International Application to Offer
        INTERNATIONAL_OFFER_TO_ACCEPTANCE_DIRECT_AUTOMATED, //International Offer to Acceptance - Direct (Automated)
        INTERNATIONAL_OFFER_TO_ACCEPTANCE_AGENT_AUTOMATED, //International Offer to Acceptance - Agent (Automated)
        INTERNATIONAL_ACCEPTANCE_DEPOSIT_NOT_PAID_MANUAL, //International Acceptance Deposit not Paid
        DOMESTIC_INTERNATIONAL_ENROLLMENT_CENSUS_CADENCE //Domestic and International Enrolment to Census
    };

    public static final Set<String> INTERNATIONAL_TRACK_SUCCEEDING_DIRECT_APPLICANT = new Set<String>{
        INTERNATIONAL_APPLICATION_TO_OFFER_DIRECT_AUTOMATED, //International Application to Offer - Direct (Automated)
        INTERNATIONAL_APPLICATION_TO_OFFER_AGENT_AUTOMATED, //International Application to Offer - Agent (Automated)
        INTERNATIONAL_APPLICATION_TO_OFFER_MANUAL, //International Application to Offer
        INTERNATIONAL_OFFER_TO_ACCEPTANCE_DIRECT_AUTOMATED, //International Offer to Acceptance - Direct (Automated)
        INTERNATIONAL_OFFER_TO_ACCEPTANCE_AGENT_AUTOMATED, //International Offer to Acceptance - Agent (Automated)
        INTERNATIONAL_ACCEPTANCE_DEPOSIT_NOT_PAID_MANUAL, //International Acceptance Deposit not Paid
        DOMESTIC_INTERNATIONAL_ENROLLMENT_CENSUS_CADENCE //Domestic and International Enrolment to Census
    };

    public static final Set<String> INTERNATIONAL_TRACK_SUCCEEDING_APPLICATION_TO_OFFER_AUTO = new Set<String>{
        INTERNATIONAL_APPLICATION_TO_OFFER_MANUAL, //International Application to Offer
        INTERNATIONAL_OFFER_TO_ACCEPTANCE_DIRECT_AUTOMATED, //International Offer to Acceptance - Direct (Automated)
        INTERNATIONAL_OFFER_TO_ACCEPTANCE_AGENT_AUTOMATED, //International Offer to Acceptance - Agent (Automated)
        INTERNATIONAL_ACCEPTANCE_DEPOSIT_NOT_PAID_MANUAL, //International Acceptance Deposit not Paid
        DOMESTIC_INTERNATIONAL_ENROLLMENT_CENSUS_CADENCE //Domestic and International Enrolment to Census
    };

    public static final Set<String> INTERNATIONAL_TRACK_SUCCEEDING_APP_TO_OFFER = new Set<String>{
        INTERNATIONAL_OFFER_TO_ACCEPTANCE_DIRECT_AUTOMATED, //International Offer to Acceptance - Direct (Automated)
        INTERNATIONAL_OFFER_TO_ACCEPTANCE_AGENT_AUTOMATED, //International Offer to Acceptance - Agent (Automated)
        INTERNATIONAL_ACCEPTANCE_DEPOSIT_NOT_PAID_MANUAL, //International Acceptance Deposit not Paid
        DOMESTIC_INTERNATIONAL_ENROLLMENT_CENSUS_CADENCE //Domestic and International Enrolment to Census
    };

    public static final Set<String> INTERNATIONAL_TRACK_SUCCEEDING_OFFER_TO_ACCEPTANCE = new Set<String>{
        INTERNATIONAL_ACCEPTANCE_DEPOSIT_NOT_PAID_MANUAL, //International Acceptance Deposit not Paid
        DOMESTIC_INTERNATIONAL_ENROLLMENT_CENSUS_CADENCE //Domestic and International Enrolment to Census
    };
    
    public static final Set<String> INTERNATIONAL_TRACK_SUCCEEDING_ACCEPTANCE_DEPOSIT_NOT_PAID = new Set<String>{
        DOMESTIC_INTERNATIONAL_ENROLLMENT_CENSUS_CADENCE //Domestic and International Enrolment to Census
    };

    public static final Set<String> INTERNATIONAL_PARTNER_SOURCED = new Set<String>{
       INTERNATIONAL_PRE_APPLICATION_PARTNER_SOURCE_AUTOMATED,
       INTERNATIONAL_PRE_APPLICATION_PARTNER_SOURCE_MANUAL
    };


    public static final String CRITERIA_TYPE_ENTRY = 'ENTRY';

    public static INurtureTrackConfigurationsDAO newInstance() {
        return (INurtureTrackConfigurationsDAO) ImplementationSelector.DAO.newInstance(Nurture_Track_Configuration__c.SObjectType);
    }

    public Schema.SObjectType getSObjectType() {
        return Nurture_Track_Configuration__c.SObjectType;
    }

    public List<Nurture_Track_Configuration__c> getNurtureTrackLeadScoreThreshold(
        String accessLevel
    ) {
        return Database.query(
            'SELECT  Id, Cadence_Name__c, Lead_Score_Threshold__c, Status__c,Key_Date_Offset_Days__c,Criteria_Type__c,Enquiry_Category_L1__c ' +
            'FROM Nurture_Track_Configuration__c ' +
            'WHERE Status__c = \'Active\' '+
            'AND Lead_Score_Threshold__c != NULL ' +
            'WITH ' +
            String.escapeSingleQuotes(accessLevel) +
            ' ORDER BY Lead_Score_Threshold__c '
        );
    }
    
    public List<Nurture_Track_Configuration__c> getNurtureTrackByCadenceNames(
        Set<String> cadenceNames,
        String accessLevel
    ) {
        return Database.query(
            'SELECT  Id, Cadence_Name__c, Lead_Score_Threshold__c, Status__c, Criteria_Type__c, Enquiry_Category_L1__c ' +
            'FROM Nurture_Track_Configuration__c ' +
            'WHERE Status__c = \'Active\' '+
            'AND Cadence_Name__c IN :cadenceNames ' +
            'WITH ' +
            String.escapeSingleQuotes(accessLevel)
        );
    }

    public List<Nurture_Track_Configuration__c> getNurtureTrack(
        String fieldsToQuery,
        String accessLevel
    ) {
        return Database.query(
            'SELECT ' +
             String.escapeSingleQuotes(fieldsToQuery) +
            'FROM Nurture_Track_Configuration__c ' +
            'WHERE Status__c = \'Active\' '+
            'WITH ' +
            String.escapeSingleQuotes(accessLevel)
        );
    } 
} 