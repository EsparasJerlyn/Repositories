/**
 * @description Service Class for CaseService class getting case related record
 *
 * @see CaseService
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------------------|
 *    | arsenio.jr.dayrit              | September 27,2023     | DEPP-6720	            | Created File                               |
 *    | roy.nino.s.regala              | October 05,2023       | DEPP-6426	            | Added new methods                          |
 *    | roy.nino.s.regala              | October 05,2023       | DEPP-6426	            | updateCases                                |
 *    | roy.nino.s.regala              | October 05,2023       | DEPP-6426	            | getInnerFieldsOfListCases                  |
 *    | gabriel.p.ventayen             | April 29,2023         | DEPP-8614	            | insertEngagementListConfigurationCases     |
 */
public inherited sharing class CaseService {
    /**
     * @description Check map contact to it's existing case records
     * @param caseSuppliedPhone
     */
    public static Map<String, List<Contact>> mapExistingContactMatchToCase(
        Set<String> caseSuppliedPhone
    ) {
        Map<String, List<Contact>> contactsMatchFromCaseMobileMap = new Map<String, List<Contact>>();
        List<Contact> contactList = new List<Contact>();

        if (!caseSuppliedPhone.isEmpty()) {
            contactList = ContactsDAO.newInstance()
                .getContactByCaseMobile(caseSuppliedPhone, AccessLevel.SYSTEM_MODE);
        }

        for (Contact contact : contactList) {
            if (
                !contactsMatchFromCaseMobileMap.containsKey(contact.MobilePhone) &&
                contact.MobilePhone != null
            ) {
                contactsMatchFromCaseMobileMap.put(contact.MobilePhone, new List<Contact>());
            }
            contactsMatchFromCaseMobileMap.get(contact.MobilePhone).add(contact);
        }
        return contactsMatchFromCaseMobileMap;
    }

    /**
     * @description Check map lead to it's existing case records
     * @param caseSuppliedPhone
     */
    public static Map<String, List<Lead>> mapExistingLeadMatchToCase(
        Set<String> caseSuppliedPhone
    ) {
        Map<String, List<Lead>> leadMatchFromCaseMobileMap = new Map<String, List<Lead>>();
        List<Lead> leadList = new List<Lead>();

        if (!caseSuppliedPhone.isEmpty()) {
            leadList = leadsDAO.newInstance()
                .getLeadsByCaseMobile(caseSuppliedPhone, AccessLevel.USER_MODE);
        }

        for (Lead lead : leadList) {
            if (
                !leadMatchFromCaseMobileMap.containsKey(lead.MobilePhone) &&
                lead.MobilePhone != null
            ) {
                leadMatchFromCaseMobileMap.put(lead.MobilePhone, new List<Lead>());
            }
            leadMatchFromCaseMobileMap.get(lead.MobilePhone).add(lead);
        }
        return leadMatchFromCaseMobileMap;
    }

    /**
     * @description update cases
     * @param listCase - list of case to be updated
     * @param accessLevel - access level of dml operation
     */
    public static void updateCases(List<Case> listCase, AccessLevel accessLevel) {
        if (!listCase.isEmpty()) {
            CasesDAO.newInstance().updateRecords(listCase, false, accessLevel);
        }
    }

    /**
     * @description update cases
     * @param cases - list of cases that needs inner fields
     * @param accessLevel - access level of soql operation
     * return list of cases with inner fields
     */
    public static List<Case> getInnerFieldsOfListCases(List<Case> cases, AccessLevel accessLevel) {
        Set<Id> caseIds = new Set<Id>();
        for (Case item : cases) {
            caseIds.add(item.Id);
        }

        return CasesDAO.newInstance().getCasesByIds(caseIds, accessLevel);
    }

    /**
     * @description: queueable method to set case priorities
     * @param newItems - List of case record
     */
    public static void enqueueCasesToPrioritize(
        List<Case> autoPriorityAssignedCases,
        AccessLevel accessLevel
    ) {
        try {
            Map<Id, Case> prioritizedCases = new Map<Id, Case>();
            Map<String, Integer> priortyOrder = CasesDAO.PRIORITY_ORDER;

            List<Case> completeFieldCases = getInnerFieldsOfListCases(
                autoPriorityAssignedCases,
                accessLevel
            );

            Map<String, International_Tier__c> countryTierMap = InternationalTierService.getCountryTierMap(
                accessLevel
            );

            for (
                Case_Priority_Configuration__c config : CasePriorityConfigurationsDAO.newInstance()
                    .getActiveCasePriorityConfigurations(accessLevel)
            ) {
                for (Case item : completeFieldCases) {
                    boolean isCaseForUpdate =
                        item.Priority != 'High' &&
                        priortyOrder.get(config.Priority__c) > priortyOrder.get(item.Priority) &&
                        CasePriorityConfigurationService.matchConfigToCaseBase(item, config) &&
                        CasePriorityConfigurationService.matchCountryTier(
                            item,
                            config,
                            countryTierMap
                        ) &&
                        CasePriorityConfigurationService.matchCategoryAndSubCategory(
                            item,
                            config
                        ) &&
                        DateService.isDateWithinRange(
                            config.Date_from__c,
                            config.Date_to__c,
                            date.newinstance(
                                item.CreatedDate.year(),
                                item.CreatedDate.month(),
                                item.CreatedDate.day()
                            )
                        );

                    if (isCaseForUpdate) {
                        item.Priority = config.Priority__c;
                        prioritizedCases.put(item.Id, item);
                    }
                }
            }

            updateCases(prioritizedCases.values(), accessLevel);

        } catch (Exception e) {
            Logger.error(
                    'Exception caught in method enqueueCasesToPrioritize in class CaseService.'
                )
                .setExceptionDetails(e);
        } finally {
            if (Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }

    /**  
     * @description insert cases from Engagement List Configuration.
     * @param listEngagementListConfiguration - list of case to be from EngagementListConfiguration
     * @param accessLevel - access level of dml operation
     */
    public static List<Database.SaveResult> insertEngagementListConfigurationCases(List<Engagement_List_Configuration__c> listEngagementListConfiguration, AccessLevel accessLevel) {
        String groupName = 'Student Success - Student Retention';
        Id studentRetentionQueue = GroupsDAO.newInstance().getQueueByName(groupName);
        List<Case> toInsertCaseFromEngagementListConfiguration  = new List<Case>();
        List<Database.SaveResult> saveRecords = new List<Database.SaveResult>();
        try {
            for (Engagement_List_Configuration__c item : listEngagementListConfiguration) {
                Case toInsertCase = new Case(); 
                toInsertCase.RecordTypeId = CasesDAO.OUTREACH_RECTYPE_ID;
                toInsertCase.Case_Type__c = CasesDAO.CASE_TYPE_STUDENT_SUCCESS_RETENTION;
                toInsertCase.Origin = CasesDAO.ORIGIN_ENGAGEMENT_LIST;
                toInsertCase.Subject = item.Name;
                toInsertCase.OwnerId = studentRetentionQueue;
                toInsertCase.Description = CasesDAO.DESCRIPTION_ENGAGEMENT_LIST;
                toInsertCase.Engagement_List_Configuration__c = item.Id;
                toInsertCase.Status = CasesDAO.STATUS_CREATED;
                toInsertCase.Priority = CasesDAO.PRIORITY_LOW;

                toInsertCaseFromEngagementListConfiguration.add(toInsertCase);
            }
            
            saveRecords = CasesDAO.newInstance().insertRecords(toInsertCaseFromEngagementListConfiguration, true, accessLevel);
            
        } catch (Exception e) {
            Logger.error(
                    'Exception caught in method insertEngagementListConfigurationCases in class CaseService.'
                )
                .setExceptionDetails(e);
        } finally {
            if (Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
        return saveRecords;
    }
}
