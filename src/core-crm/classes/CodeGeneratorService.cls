/**
 * @description Service class for various code generators.
 *
 * ON NAMING FUTURE METHODS IN THIS SERVICE:
 * Any future CodeGenerator method should try to follow the naming scheme:
 * 'generate<field>For<object>Records'
 * e.g., generateOpportunityCodeForOpportunityRecords
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                         |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------------------------------|
      | alexander.cadalin              | May 22, 2023          | DEPP-5594              | created file                                                           |
      | kenneth.f.alsay                | November 6, 2023      | DEPP-7000              | Updated generateCodeForOpportunityOutcomeRecords to exclude            |
      |                                |                       |                        | record types not in recordTypeToCodePartsMap                           |
      | neil.s.h.lesidan               | March 1, 2024         | DEPP-7896              | Add INDIVIDUAL_GIVING_RECTYPE_ID record types generate code            |
      |                                |                       |                        | Add ORGANISATION_GIVING_RECTYPE_ID record types generate code          |
      | vincent.ferrer                 | March 18, 2024        | DEPP-8200              | Add generateCodeForDonationCauseRecords method to generate code        |
      | eugene.andrew.abuan            | April 05, 2024        | DEPP-8390              | Added generateCodeForDesignationGivingToCauseRecords                   |
      | eugene.andrew.abuan            | April 17, 2024        | DEPP-8340              | Added generateCodeForDesignationEndowmentRecords                       |
      | marygrace.li                   | May 2, 2024           | DEPP-8390              | Deleted generateCodeForDonationCauseRecords method                     |

 */
public with sharing class CodeGeneratorService {
    /**
     * Generate code for Opportunity.Opportunity_Code__c following the format "AAA:00000"
     * The first three characters are based on the record type of the opportunity.
     */
	public static void generateOpportunityCodeForOpportunityRecords(List<Opportunity> newItems) {
        Opportunity_Code_Auto_Number__c opptyCodeAutoNum = OpportunityCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
        Map<Id, CodeParts> recordTypeToCodePartsMap = new Map<Id, CodeParts>();
        recordTypeToCodePartsMap.put(OpportunitiesDAO.INDIVIDUAL_GIVING_RECTYPE_ID, new CodeParts('ADVI', opptyCodeAutoNum.Individual_Giving__c));
        recordTypeToCodePartsMap.put(OpportunitiesDAO.ORGANISATION_GIVING_RECTYPE_ID, new CodeParts('ADVO', opptyCodeAutoNum.Organisation_Giving__c));
        recordTypeToCodePartsMap.put(OpportunitiesDAO.INTERNATIONALPROJECTSUNIT_RECTYPE_ID, new CodeParts('INPO', opptyCodeAutoNum.International_Projects_Unit__c));
        recordTypeToCodePartsMap.put(OpportunitiesDAO.COMMERCIALIZATION_RECTYPE_ID, new CodeParts('RCO', opptyCodeAutoNum.Commercialisation__c));
        recordTypeToCodePartsMap.put(OpportunitiesDAO.RESEARCHPARTNERSHIP_RECTYPE_ID, new CodeParts('RPO', opptyCodeAutoNum.Research_Partnership__c));
        for(Opportunity newItem : newItems) {
            if(recordTypeToCodePartsMap.containsKey(newItem.RecordTypeId)) {
                String codePrefix = recordTypeToCodePartsMap.get(newItem.RecordTypeId).prefix;
                Integer autoNumber = 0;

                if (recordTypeToCodePartsMap.get(newItem.RecordTypeId).autoNumber != null) {
                    autoNumber = Integer.valueOf(recordTypeToCodePartsMap.get(newItem.RecordTypeId).autoNumber);
                }

                String codeNumber = String.valueOf(autoNumber).leftPad(5, '0');
                newItem.Opportunity_Code__c = codePrefix + ':' + codeNumber;
                autoNumber++;
                recordTypeToCodePartsMap.put(newItem.RecordTypeId, new CodeParts(codePrefix, autoNumber));
            }
        }

        opptyCodeAutoNum.Individual_Giving__c = recordTypeToCodePartsMap.get(OpportunitiesDAO.INDIVIDUAL_GIVING_RECTYPE_ID).autoNumber;
        opptyCodeAutoNum.Organisation_Giving__c = recordTypeToCodePartsMap.get(OpportunitiesDAO.ORGANISATION_GIVING_RECTYPE_ID).autoNumber;
        opptyCodeAutoNum.International_Projects_Unit__c = recordTypeToCodePartsMap.get(OpportunitiesDAO.INTERNATIONALPROJECTSUNIT_RECTYPE_ID).autoNumber;
        opptyCodeAutoNum.Commercialisation__c = recordTypeToCodePartsMap.get(OpportunitiesDAO.COMMERCIALIZATION_RECTYPE_ID).autoNumber;
        opptyCodeAutoNum.Research_Partnership__c = recordTypeToCodePartsMap.get(OpportunitiesDAO.RESEARCHPARTNERSHIP_RECTYPE_ID).autoNumber;
        OpportunityCodeAutoNumbersDAO.newInstance().upsertRecords(
            new List<Opportunity_Code_Auto_Number__c>{opptyCodeAutoNum},
            false,
            AccessLevel.SYSTEM_MODE
            );
    }

    /**
     * Generate code for Opportunity_Outcome__c.Code__c following the format "AAA:00000"
     * The first three characters are based on the record type of the opportunity outcome record.
     */
    public static void generateCodeForOpportunityOutcomeRecords(List<Opportunity_Outcome__c> newItems) {
        Opportunity_Outcome_Code_Auto_Number__c opptyOutCodeAutoNum = OpportunityOutcomeCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
        Map<Id, CodeParts> recordTypeToCodePartsMap = new Map<Id, CodeParts>();
        recordTypeToCodePartsMap.put(OpportunityOutcomesDAO.RESEARCHPARTNERSHIPPROJECT_RECTYPE_ID, new CodeParts('RPP', opptyOutCodeAutoNum.Research_Partnership_Project__c));
        recordTypeToCodePartsMap.put(OpportunityOutcomesDAO.IPUPROJECT_RECTYPE_ID, new CodeParts('INP', opptyOutCodeAutoNum.IPU_Project__c));
        recordTypeToCodePartsMap.put(OpportunityOutcomesDAO.RESEARCHCOMMERCIALISATIONPROJECT_RECTYPE_ID, new CodeParts('RCP', opptyOutCodeAutoNum.Research_Commercialisation_Project__c));
        recordTypeToCodePartsMap.put(OpportunityOutcomesDAO.STARTUP_RECTYPE_ID, new CodeParts('RCC', opptyOutCodeAutoNum.Start_Up__c));
        for(Opportunity_Outcome__c newItem : newItems) {
            if(recordTypeToCodePartsMap.containsKey(newItem.RecordTypeId)) {
                String codePrefix = recordTypeToCodePartsMap.get(newItem.RecordTypeId).prefix;
                Integer autoNumber = Integer.valueOf(recordTypeToCodePartsMap.get(newItem.RecordTypeId).autoNumber);
                String codeNumber = String.valueOf(autoNumber).leftPad(5, '0');
                newItem.Code__c = codePrefix + ':' + codeNumber;
                autoNumber++;
                recordTypeToCodePartsMap.put(newItem.RecordTypeId, new CodeParts(codePrefix, autoNumber));
            }
        }
        opptyOutCodeAutoNum.Research_Partnership_Project__c = recordTypeToCodePartsMap.get(OpportunityOutcomesDAO.RESEARCHPARTNERSHIPPROJECT_RECTYPE_ID).autoNumber;
        opptyOutCodeAutoNum.IPU_Project__c = recordTypeToCodePartsMap.get(OpportunityOutcomesDAO.IPUPROJECT_RECTYPE_ID).autoNumber;
        opptyOutCodeAutoNum.Research_Commercialisation_Project__c = recordTypeToCodePartsMap.get(OpportunityOutcomesDAO.RESEARCHCOMMERCIALISATIONPROJECT_RECTYPE_ID).autoNumber;
        opptyOutCodeAutoNum.Start_Up__c = recordTypeToCodePartsMap.get(OpportunityOutcomesDAO.STARTUP_RECTYPE_ID).autoNumber;
        OpportunityOutcomeCodeAutoNumbersDAO.newInstance().upsertRecords(
            new List<Opportunity_Outcome_Code_Auto_Number__c>{opptyOutCodeAutoNum}, 
            false, 
            AccessLevel.SYSTEM_MODE
            );
    }
    
    /**
     * Generate code for Engagement__c.Engagement_Code__c following the format "AAA:00000"
     * The first three characters are based on the record type of the opportunity outcome record.
     */
    public static void generateEngagementCodeForEngagementRecords(List<Engagement__c> newItems) {
        Engagement_Code_Auto_Number__c engCodeAutoNum = EngagementCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
        Map<Id, CodeParts> recordTypeToCodePartsMap = new Map<Id, CodeParts>();
        recordTypeToCodePartsMap.put(EngagementsDAO.COMMERCIALISATION_RECTYPE_ID, new CodeParts('RCE', engCodeAutoNum.Commercialisation__c));
        recordTypeToCodePartsMap.put(EngagementsDAO.RESEARCHPARTNERSHIP_RECTYPE_ID, new CodeParts('RPE', engCodeAutoNum.Research_Partnership__c));
        for(Engagement__c newItem : newItems) {
            if(recordTypeToCodePartsMap.containsKey(newItem.RecordTypeId)) {
                String codePrefix = recordTypeToCodePartsMap.get(newItem.RecordTypeId).prefix;
                Integer autoNumber = Integer.valueOf(recordTypeToCodePartsMap.get(newItem.RecordTypeId).autoNumber);
                String codeNumber = String.valueOf(autoNumber).leftPad(5, '0');
                newItem.Engagement_Code__c = codePrefix + ':' + codeNumber;
                autoNumber++;
                recordTypeToCodePartsMap.put(newItem.RecordTypeId, new CodeParts(codePrefix, autoNumber));
            }
        }
        engCodeAutoNum.Commercialisation__c = recordTypeToCodePartsMap.get(EngagementsDAO.COMMERCIALISATION_RECTYPE_ID).autoNumber;
        engCodeAutoNum.Research_Partnership__c = recordTypeToCodePartsMap.get(EngagementsDAO.RESEARCHPARTNERSHIP_RECTYPE_ID).autoNumber;
        EngagementCodeAutoNumbersDAO.newInstance().upsertRecords(
            new List<Engagement_Code_Auto_Number__c>{engCodeAutoNum}, 
            false, 
            AccessLevel.SYSTEM_MODE
            );
    }
    /**
     * Generate code for Designation__c.Designation_Code__c following the format "ADVGC:00001"
     * The first three characters are based on the record type of the opportunity outcome record.
     */
    public static void generateCodeForDesignationGivingToCauseRecords(List<Designation__c> newItems) {
        Designation_Code_Auto_Number__c designationCodeAutoNum = DesignationCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
        Map<Id, CodeParts> recordTypeToCodePartsMap = new Map<Id, CodeParts>();
        recordTypeToCodePartsMap.put(DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID, new CodeParts('ADVGC', designationCodeAutoNum.Giving_To_Cause__c));

        
        if(designationCodeAutoNum.Giving_To_Cause__c != null){
            for(Designation__c newItem : newItems) {
                if(recordTypeToCodePartsMap.containsKey(newItem.RecordTypeId)) {
                    String codePrefix = recordTypeToCodePartsMap.get(newItem.RecordTypeId).prefix;
                    Integer autoNumber = Integer.valueOf(recordTypeToCodePartsMap.get(newItem.RecordTypeId).autoNumber);
                    String codeNumber = String.valueOf(autoNumber).leftPad(5, '0');
                    newItem.Designation_Code__c = codePrefix + ':' + codeNumber;
                    autoNumber++;
                    recordTypeToCodePartsMap.put(newItem.RecordTypeId, new CodeParts(codePrefix, autoNumber));
                }
            }
            designationCodeAutoNum.Giving_To_Cause__c = recordTypeToCodePartsMap.get(DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID).autoNumber;

            DesignationCodeAutoNumbersDAO.newInstance().upsertRecords(
                new List<Designation_Code_Auto_Number__c>{designationCodeAutoNum}, 
                false, 
                AccessLevel.SYSTEM_MODE
            );
        }
    }


        /**
     * Generate code for Designation__c.Designation_Code__c following the format "ADVEDW:00001"
     * The first three characters are based on the record type of the opportunity outcome record.
     */
    public static void generateCodeForDesignationEndowmentRecords(List<Designation__c> newItems) {
        Designation_Code_Auto_Number__c designationCodeAutoNum = DesignationCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
        Map<Id, CodeParts> recordTypeToCodePartsMap = new Map<Id, CodeParts>();
        recordTypeToCodePartsMap.put(DesignationsDAO.ENDOWNMENT_RECTYPE_ID, new CodeParts('ADVEDW', designationCodeAutoNum.Endowment__c));

        
        if(designationCodeAutoNum.Endowment__c != null){
            for(Designation__c newItem : newItems) {
                if(recordTypeToCodePartsMap.containsKey(newItem.RecordTypeId)) {
                    String codePrefix = recordTypeToCodePartsMap.get(newItem.RecordTypeId).prefix;
                    Integer autoNumber = Integer.valueOf(recordTypeToCodePartsMap.get(newItem.RecordTypeId).autoNumber);
                    String codeNumber = String.valueOf(autoNumber).leftPad(5, '0');
                    newItem.Designation_Code__c = codePrefix + ':' + codeNumber;
                    autoNumber++;
                    recordTypeToCodePartsMap.put(newItem.RecordTypeId, new CodeParts(codePrefix, autoNumber));
                }
            }
            designationCodeAutoNum.Endowment__c = recordTypeToCodePartsMap.get(DesignationsDAO.ENDOWNMENT_RECTYPE_ID).autoNumber;

            DesignationCodeAutoNumbersDAO.newInstance().upsertRecords(
                new List<Designation_Code_Auto_Number__c>{designationCodeAutoNum}, 
                false, 
                AccessLevel.SYSTEM_MODE
            );
        }
    }
    
    /** 
     * A class containing the basic parts of a code. The original parts is based on DEPP-5594, basically in the
     * form of "AAA:00000". The parts of the original CodeParts are the prefix and the number. For reusability's sake,
     * only the number itself without the padding zeroes is stored here.
     */
    private class CodeParts {
        public String prefix { get; set; }
        public Decimal autoNumber { get; set; }
        public CodeParts(String prefix, Decimal autoNumber) {
            this.prefix = prefix;
            this.autoNumber = autoNumber;
        }
    }
}