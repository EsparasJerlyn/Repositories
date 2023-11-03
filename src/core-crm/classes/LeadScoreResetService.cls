/**
 * @description holds the common methods for reseting a lead score
 * @see ProgramEnrollmentTriggerHelper and ApplicationTriggerHelper
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala		       | November 03, 2023     | DEPP-7145              | Created file                 |
 */

public with sharing class LeadScoreResetService {
    
    public static void updateLeadScoreResetForMktgInt(Set<Id> contactLeadIdSet) {
        List<Marketing_Interaction__c> mktIntListToUpdate = new List<Marketing_Interaction__c>();
        if (!contactLeadIdSet.isEmpty()) {
            List<Marketing_Interaction__c> mktInList = MarketingInteractionsDAO.newInstance()
                .getMarketingInteractionsByContactOrLeadIds(
                    contactLeadIdSet,
                    AccessLevel.SYSTEM_MODE
                );
            for (Marketing_Interaction__c mktInt : mktInList) {
                mktInt.Lead_Score_Reset__c = true;
                mktIntListToUpdate.add(mktInt);
            }
        }

        if (!mktIntListToUpdate.isEmpty()) {
            MarketingInteractionsDAO.newInstance()
                .updateRecords(mktIntListToUpdate, false, AccessLevel.SYSTEM_MODE);
        }
    }

    public static void updateLeadScoreResetForIndivEmail(Set<Id> contactLeadIdSet) {
        List<et4ae5__IndividualEmailResult__c> indivEmailListToUpdate = new List<et4ae5__IndividualEmailResult__c>();
        if (!contactLeadIdSet.isEmpty()) {
            List<et4ae5__IndividualEmailResult__c> indivEmailList = IndividualEmailResultsDAO.newInstance()
                .getIndivEmailResultsByContactOrLeadIds(contactLeadIdSet, AccessLevel.SYSTEM_MODE);
            for (et4ae5__IndividualEmailResult__c indivEmail : indivEmailList) {
                indivEmail.Lead_Score_Reset__c = true;
                indivEmailListToUpdate.add(indivEmail);
            }
        }

        if (!indivEmailListToUpdate.isEmpty()) {
            IndividualEmailResultsDAO.newInstance()
                .updateRecords(indivEmailListToUpdate, false, AccessLevel.SYSTEM_MODE);
        }
    }

    public static void updateLeadScoreResetForCase(Set<Id> contactLeadIdSet) {
        List<Case> caseListToUpdate = new List<Case>();
        if (!contactLeadIdSet.isEmpty()) {
            List<Case> caseList = CasesDAO.newInstance()
                .getCasesByContactOrLeadIds(contactLeadIdSet, AccessLevel.SYSTEM_MODE);
            for (Case caseRec : caseList) {
                caseRec.Lead_Score_Reset__c = true;
                caseListToUpdate.add(caseRec);
            }
        }
        if (!caseListToUpdate.isEmpty()) {
            CasesDAO.newInstance().updateRecords(caseListToUpdate, false, AccessLevel.SYSTEM_MODE);
        }
    }

    public static void updateLeadScoreResetForProgEng(Set<Id> contactLeadIdSet) {
        List<hed__Program_Enrollment__c> progEngListToUpdate = new List<hed__Program_Enrollment__c>();
        if (!contactLeadIdSet.isEmpty()) {
            List<hed__Program_Enrollment__c> progEngList = ProgramEnrollmentsDAO.newInstance()
                .getAllProgramEnrollmentsByContactId(contactLeadIdSet, AccessLevel.SYSTEM_MODE);
            for (hed__Program_Enrollment__c progEng : progEngList) {
                progEng.Lead_Score_Reset__c = true;
                progEngListToUpdate.add(progEng);
            }
        }

        if (!progEngListToUpdate.isEmpty()) {
            ProgramEnrollmentsDAO.newInstance()
                .updateRecords(progEngListToUpdate, false, AccessLevel.SYSTEM_MODE);
        }
    }

    /**
     * Retrieves the lead score details by contact/lead and sets all categories to 0
     */
    public static List<Lead_Score_Detail__c> getLeadScoreDetailsToUpdate(Set<Id> contactLeadIdSet) {
        List<Lead_Score_Detail__c> leadScoreDetailsToUpdate = new List<Lead_Score_Detail__c>();
        if (!contactLeadIdSet.isEmpty()) {
            List<Lead_Score_Detail__c> leadScoreDetailsList = LeadScoreDetailsDAO.newInstance()
                .getLeadScoreDetailsByContactOrLeadId(contactLeadIdSet, AccessLevel.SYSTEM_MODE);
            for (Lead_Score_Detail__c detail : leadScoreDetailsList) {
                leadScoreDetailsToUpdate.add(
                    new Lead_Score_Detail__c(
                        Id = detail.Id,
                        Country_Tier__c = 0,
                        Course_Level__c = 0,
                        Download__c = 0,
                        Email_Interaction__c = 0,
                        Enquiries__c = 0,
                        Event_Registration_Attendance__c = 0,
                        Funding__c = 0,
                        Interested_In_Double_Degrees__c = 0,
                        Interested_In_English_Pathway_Programs__c = 0,
                        Manual_Assessment__c = 0,
                        Marketing_Consent__c = 0,
                        Match_My_Skills__c = 0,
                        Preferred_Intake__c = 0,
                        Primary_NSA__c = 0,
                        Primary_BSA__c = 0,
                        Program_Engagement__c = 0,
                        Residence__c = 0
                    )
                );
            }
        }

        return leadScoreDetailsToUpdate;
    }
}
