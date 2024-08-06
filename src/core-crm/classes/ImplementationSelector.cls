/**
 * @description Selects which SObject DAO to implement
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                |
 *    |--------------------------------|-----------------------|------------------------|---------------------------------------------------------------|
 *    | rhea.b.torres                  | April 25, 2023        | DEPP-5567              | Created file                                                  |
 *    | alexander.cadalin              | May 17, 2023          | DEPP-5594              | added sobjects                                                |
 *    | mark.j.mahilum                 | June 01, 2023         | DEPP-5687              | Added Object mapping for Financial Split                      |
 *    | roy.nino.s.regala              | June 13, 2023         | DEPP-5391              | Added Object mapping for UserAppInfo                          |
 *    | kenneth.f.alsay                | June 16, 2023         | DEPP-5434, 5399        | Added Object mapping for Contextual Role                      |
 *    | mark.j.mahilum                 | June 26, 2023         | DEPP-5846              | Added object mapping for Application                          |
 *    | eugene.andrew.abuan            | July 10, 2023         | DEPP-5483              | Added Object mapping for Document                             |
 *    | carl.alvin.cabiles             | June 28, 2023         | DEPP-5388              | Added Object mapping for ContentDocument and IP Management    |
 *    | ryan.j.a.dela.cruz             | June 17, 2023         | DEPP-5468              | Added Object mapping for IPManagement Relationship            |
 *    | roy.nino.s.regala              | July 14, 2023         | DEPP-5473              | Added Object mapping for Finance Summary                      |
 *    | mark.j.mahilum                 | July 21, 2023         | DEPP-5799              | Added Object mapping for Affiliation and Course Enrollment    |
 *    | mark.j.mahilum                 | July 25, 2023         | DEPP-6106              | Added nurture config object                                   |
 *    | eugene.andrew.abuan            | August 01, 2023       | DEPP-6140              | Added Object mapping for Relationsip Manager Object           |
 *    | roy.nino.s.regala              | August 09, 2023       | DEPP-5677              | Added Object mapping for Task and ActionCadenceTracker Objects|
 *    | eccarius.munoz                 | August 08, 2023       | DEPP-5760              | Added Object mapping for hed__Program_Enrollment__c Object    |
 *    | eccarius.munoz                 | August 10, 2023       | DEPP-5760              | Added Object mapping for hed__Term__c and hed__Facility__c obj|
 *    | arsenio.jr.dayrit              | August 15, 2023       | DEPP-6370              | Added Object mapping for Package_Component__c obj             |
 *    | julie.jane.alegre              | August 31, 2023       | DEPP-5965              | Added Object mapping for Lead_Score_Detail__c obj             |
 *    | mark.j.mahilum                 | August 31, 2023       | DEPP-6565              | Added Object mapping for OpportunityContactRole obj           |
 *    | neil.s.h.lesidan               | August 31, 2023       | DEPP-5835              | Added Object mapping for Lead_Score_Configuration__c obj      |
 *    | arsenio.jr.dayrit              | September 11, 2023    | DEPP-5652              | Added Object mapping for Case obj                             |
 *    | julie.jane.alegre              | September 14, 2023    | DEPP-6679              | Added Object mapping for Marketing_Segmentation__c obj        |
 *    | eugene.andrew.abuan            | September 18, 2023    | DEPP-6592              | Added Object mapping for Course Offering, term, & course obj  |
 *    | julie.jane.alegre              | September 18, 2023    | DEPP-6667              | Added Object mapping for Marketing_Interaction__c obj         |
 *    | roy.nino.s.regala              | Sep 20, 2023          | DEPP-6714              | Added mapping for cartdeliverygroup,webstore,webcart,cartitem,|
 *    |                                |                       |                        | pricebook and pricebookentry                                  |
 *    | alexander.cadalin              | Sep 22, 2023          | DEPP-6652,6653,6654    | Added object mapping for Address                              |
 *    | eugene.andrew.abuan            | October 10, 2023      | DEPP-6612              | Added object mapping for Adhoc Communication Object           |
 *    | mark.j.mahilum                 | October 25, 2023      | DEPP-6985              | Added object mapping for SMS Template Object                  |
 *    | arsenio.jr.dayrit              | November 22, 2023     | DEPP-7264              | Added Object mapping for Service Appointment object           |
 *    | nicole.genon                   | November 22, 2023     | DEPP-7259              | Added object mapping for WorkType Object                      |
 *    | nicole.genon                   | November 24, 2023     | DEPP-7259              | Added object mapping for ServiceAppointment Object            |
 *    | julie.jane.alegre              | January 02, 2024      | ApexCRUDViolationFix   | Added Object mapping for Program_Offering__c obj              |
 *    | arsenio.jr.dayrit              | January 02, 2024      |  ApexCRUDViolationFix  | Added object mapping for BuyerGroups,                         |
 *    |                                |                       |                        | Commerce Entitlement Buyer Group, Commerce Entitlement Product|
 *    |                                |                       |                        | Product Category, Product Category Product Object             |
 *    | julie.jane.alegre              | April 29, 2024        | DEPP-8041              | Added Object mapping for Course_Connection_Assessment__c obj  |
 *    |                                |                       |                        | Added Object mapping for Program_Enrollment_Breach__c obj     |
 *    | eugene.andrew.abuan            | May 08, 2024          | DEPP-8487              | Added object mapping for Assessment__c                        |
 *    | arsenio.jr.dayrit              | May 13, 2024          | DEPP-8743              | Added object mapping for AsyncApexJob and Attachemnt obj      |
 *    | eccarius.munoz                 | May 14, 2024          | DEPP-8484              | Added object mapping for Engagement List Event                |
 *    | eccarius.munoz                 | May 16, 2024          | DEPP-8484              | Added object mapping for Engagement List Config               |
 *    | john.aldric.s.seril            | July 26, 2024         | DEPP-9834              | Added object mapping for OperatingHours                       |
 */
public class ImplementationSelector { 

    // Configure and create the DAOFactory for this ImplementationSelector
    public static final DAOFactory DAO = new DAOFactory(
        new Map<SObjectType, Type>{
            ABS_Categorisation__c.SObjectType => ABSCategorisationsDAO.class,
            Account.SObjectType => AccountsDAO.class,
            Action__c.SObjectType => ActionsDAO.class,
            ActionCadenceTracker.SObjectType => ActionCadenceTrackersDAO.class,
            ActionCadenceStepTracker.SObjectType => ActionCadenceStepTrackersDAO.class,
            Adhoc_Communication__c.SObjectType => AdhocCommunicationsDAO.class,
            AppDefinition.SObjectType => AppDefinitionsDAO.class,
            Application_Preference__c.SObjectType => ApplicationPreferencesDAO.class, 
            Asset.SObjectType => AssetsDAO.class,
            Assessment__c.SObjectType => AssessmentsDAO.class,
            Associated_Products__c.SObjectType => AssociatedProductsDAO.class,
            AsyncApexJob.SObjectType => AsyncApexJobsDAO.class,
            Attachment.SObjectType => AttachmentsDAO.class,
            Breach__c.SObjectType => BreachesDAO.class,
            BuyerGroup.SObjectType => BuyerGroupsDAO.class,
            BuyerGroupPriceBook.SObjectType => BuyerGroupPriceBooksDAO.class,
            CommerceEntitlementProduct.SObjectType => CommerceEntitlementProductsDAO.class,
            Communication_Queue__c.SObjectType => CommunicationQueuesDAO.class,
            CartDeliveryGroup.SObjectType => CartDeliveryGroupsDAO.class,
            CartItem.SObjectType => CartItemsDAO.class,
            Case.SObjectType => CasesDAO.class,
            Case_Priority_Configuration__c.SObjectType => CasePriorityConfigurationsDAO.class,
            CommerceEntitlementBuyerGroup.SObjectType => CommerceEntitlementBuyerGroupsDAO.class,
            Completed_Cadence__c.SObjectType => CompletedCadencesDAO.class,
            Contact.SObjectType => ContactsDAO.class,
            Contact_Alternate_ID__c.SObjectType => ContactAlternateIdsDAO.class,
            Contact_Matching_Configuration__c.SObjectType => ContactMatchingConfigurationsDAO.class,
            Contact_Matching_Service_Configuration__mdt.SObjectType => ConMatchingServiceConfigurationsDAO.class,
            Contact_Matching_Staging__c.SObjectType => ContactMatchingStagingsDAO.class,
            ContentDocument.SObjectType => ContentDocumentsDAO.class,
            ContentDocumentLink.SObjectType => ContentDocumentLinksDAO.class,
            ContentVersion.SObjectType => ContentVersionsDAO.class,
            Contextual_Role__c.SObjectType => ContextualRolesDAO.class,
            Consultancy__c.SObjectType => ConsultanciesDAO.class,
            Course_Connection_Assessment__c.SObjectType => CourseConnectionAssessmentsDAO.class,
            Document__c.SObjectType => DocumentsDAO.class,
            EmailTemplate.SObjectType => EmailTemplatesDAO.class,
            Engagement__c.SObjectType => EngagementsDAO.class,
            Engagement_Code_Auto_Number__c.SobjectType => EngagementCodeAutoNumbersDAO.class,
            Engagement_List_Configuration__c.SobjectType => EngagementListConfigurationsDAO.class,
            Engagement_List_Criteria__c.SobjectType => EngagementListCriteriasDAO.class,
            Engagement_List_Event__c.SobjectType => EngagementListEventsDAO.class,
            et4ae5__IndividualEmailResult__c.SobjectType => IndividualEmailResultsDAO.class,
            Finance_Summary__c.SObjectType => FinanceSummariesDAO.class,
            Financial_Split__c.SObjectType => FinancialSplitsDAO.class,
            Group.SObjectType => GroupsDAO.class, 
            hed__Address__c.SObjectType => AddressesDAO.class,
            hed__Affiliation__c.SObjectType => AffiliationsDAO.class,
            hed__Application__c.SObjectType => ApplicationsDAO.class,
            hed__Course__c.SObjectType => CoursesDAO.class,
            hed__Course_Enrollment__c.SObjectType => CourseConnectionsDAO.class,
            hed__Course_Offering__c.SObjectType => CourseOfferingsDAO.class,
            hed__Facility__c.SObjectType => FacilitiesDAO.class,
            hed__Program_Enrollment__c.SObjectType => ProgramEnrollmentsDAO.class,
            hed__Program_Plan__c.SObjectType => ProgramPlansDAO.class,
            hed__Term__c.SObjectType => TermsDAO.class,
            International_Tier__c.SObjectType => InternationalTiersDAO.class,
            IP_Management__c.SObjectType => IPManagementsDAO.class,
            IP_Management_Relationship__c.SObjectType => IPManagementRelationshipsDAO.class,
            Lead.SObjectType => LeadsDAO.class,
            Lead_Score_Detail__c.SObjectType => LeadScoreDetailsDAO.class, 
            Lead_Score_Configuration__c.SObjectType => LeadScoreConfigurationDAO.class,
            LeadStatus.SObjectType => LeadStatusesDAO.class,
            Leave_of_Absence__c.SObjectType => LeaveOfAbsencesDAO.class,
            LogEntry__c.SObjectType => LogEntriesDAO.class,
            Marketing_Course_Application__c.SObjectType => MarketingCourseApplicationsDAO.class,
            Marketing_Interaction__c.SObjectType => MarketingInteractionsDAO.class,
            Marketing_Segmentation__c.SObjectType => MarketingSegmentationsDAO.class,
            Milestone__c.SObjectType => MilestonesDAO.class,
            Nurture_Track_Configuration__c.SObjectType => NurtureTrackConfigurationsDAO.class,
            OperatingHours.SObjectType => OperatingHoursDAO.class,    
            Opportunity.SObjectType => OpportunitiesDAO.class,
            Opportunity_Code_Auto_Number__c.SobjectType => OpportunityCodeAutoNumbersDAO.class,
            OpportunityContactRole.SobjectType => OpportunityContactRolesDAO.class,
            Opportunity_Outcome__c.SobjectType => OpportunityOutcomesDAO.class,
            Opportunity_Outcome_Code_Auto_Number__c.SobjectType => OpportunityOutcomeCodeAutoNumbersDAO.class,
            OrgWideEmailAddress.SobjectType => OrgWideEmailAddressesDAO.class,
            Product_Request__c.SObjectType => ProductRequestsDAO.class,
            Package_Component__c.SObjectType => PackageComponentDAO.class,
            Pricebook2.SObjectType => PricebooksDAO.class,
            PricebookEntry.SObjectType => PricebookEntriesDAO.class,
            Product2.SObjectType => ProductsDAO.class,
            Profile.SObjectType => ProfilesDAO.class,           
            ProductCategory.SObjectType => ProductCategoriesDAO.class,
            ProductCategoryProduct.SObjectType => ProductCategoryProductsDAO.class,
            Product_Ledger__c.SObjectType => ProductLedgersDAO.class,
            Profile.SObjectType => ProfilesDAO.class,   
            Program_Enrollment_Breach__c.SObjectType => ProgramEnrollmentBreachesDAO.class,            
            Program_Offering__c.SObjectType => ProgramOfferingsDAO.class,           
            Pure_Project__c.SObjectType => PureProjectsDAO.class,
            Qualtrics_Survey__c.SObjectType => QualtricsSurveysDAO.class,
            Relationship_Manager__c.SObjectType => RelationshipManagersDAO.class,
            Risk__c.SObjectType => RisksDAO.class,
            ServiceAppointment.SObjectType => ServiceAppointmentsDAO.class,
            SMS_Template__c.SObjectType => SMSTemplatesDAO.class,
            Student_Sanction__c.SObjectType => StudentSanctionsDAO.class,
            Task.SObjectType => TasksDAO.class,
            User.SObjectType => UsersDAO.class,
            UserAppInfo.SObjectType => UserAppInfosDAO.class,
            UserRecordAccess.SObjectType => UserRecordAccessesDAO.class,
            Expense__c.SObjectType => ExpensesDAO.class,
            WebCart.SObjectType => WebCartsDAO.class,
            WebStore.SOBjectType => WebStoresDAO.class,
            WorkType.SOBjectType => WorkTypesDAO.class
        }
    );  

    /**
     * Class implements a DAO class factory
     **/
    public class DAOFactory implements DAOFactoryInterface {
        protected Map<SObjectType, Type> sObjectByDaoType;
        protected Map<SObjectType, DmlInterface> sObjectByDaoMock;

        /**
         * Constructs a simple DAO Factory
         **/
        // prettier-ignore
        public DAOFactory() {} //NOPMD
        /**
         * Consturcts a DAO Factory linking SObjectType's with Apex Classes implement the DmlInterface interface
         *   Note that the factory does not check the given Apex Classes implement the interface
         *     currently this is not possible in Apex.
         *
         * @Param sObjectByDAOType Map of SObjectType's to DAO Apex Classes
         **/
        public DAOFactory(Map<SObjectType, Type> sObjectByDAOType) {
            this.sObjectByDaoType = sObjectByDAOType;
            this.sObjectByDaoMock = new Map<SObjectType, DmlInterface>();
        }

        /**
         * Creates a new instance of the associated Apex Class implementing DmlInterface
         *   for the given SObjectType, or if provided via setMock returns the Mock implementation
         *
         * @param sObjectType An SObjectType token, e.g. Account.SObjectType
         **/
        public virtual DmlInterface newInstance(SObjectType sObjectType) {
            // Mock implementation?
            if (sObjectByDaoMock.containsKey(sObjectType)) {
                return sObjectByDaoMock.get(sObjectType);
            }

            // Determine Apex class for DAO class
            Type daoClass = this.sObjectByDaoType.get(sObjectType);
            if (daoClass == null) {
                throw new DeveloperException('DAO class not found for SObjectType ' + sObjectType);
            }

            // Construct DAO class and query by Id for the records
            return (DmlInterface) daoClass.newInstance();
        }

        @TestVisible
        public void setMock(DmlInterface daoInstance) {
            sObjectByDaoMock.put(daoInstance.sObjectType(), daoInstance);
        }
    }

    /**
     * Exception representing a developer coding error, not intended for end user eyes 
     **/
    public class DeveloperException extends Exception {
    }
}