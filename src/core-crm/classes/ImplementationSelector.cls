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
 *    | carl.alvin.cabiles             | September 15, 2023    | DEPP-6510              | Added Object mapping for List and List Member obj             |
 *    | julie.jane.alegre              | September 14, 2023    | DEPP-6679              | Added Object mapping for Marketing_Segmentation__c obj        |
 *    | eugene.andrew.abuan            | September 18, 2023    | DEPP-6592              | Added Object mapping for Course Offering, term, & course obj  |
 *    | julie.jane.alegre              | September 18, 2023    | DEPP-6667              | Added Object mapping for Marketing_Interaction__c obj         |
 *    | roy.nino.s.regala              | Sep 20, 2023          | DEPP-6714              | Added mapping for cartdeliverygroup,webstore,webcart,cartitem,|
 *    |                                |                       |                        | pricebook and pricebookentry                                  |
 *    | alexander.cadalin              | Sep 22, 2023          | DEPP-6652,6653,6654    | Added object mapping for Address                              |
 *    | eugene.andrew.abuan            | October 10, 2023      | DEPP-6612              | Added object mapping for Adhoc Communication Object           |
 *    | mark.j.mahilum                 | October 25, 2023      | DEPP-6985              | Added object mapping for SMS Template Object                  |
 *    | arsenio.jr.dayrit              | November 22, 2023     | DEPP-7264              | Added Object mapping for Service Appointment object           |
 *    | carl.alvin.cabiles             | December 13, 2023     | DEPP-7186              | Added Object mapping for List Contributor object              |
 *    | nicole.genon                   | November 22, 2023     | DEPP-7259              | Added object mapping for WorkType Object                      |
 *    | nicole.genon                   | November 24, 2023     | DEPP-7259              | Added object mapping for ServiceAppointment Object            |
 *    | julie.jane.alegre              | January 02, 2024      | ApexCRUDViolationFix   | Added Object mapping for Program_Offering__c obj              |
 *    | arsenio.jr.dayrit              | January 02, 2024      |  ApexCRUDViolationFix  | Added object mapping for BuyerGroups,                         |
 *    |                                |                       |                        | Commerce Entitlement Buyer Group, Commerce Entitlement Product|
 *    |                                |                       |                        | Product Category, Product Category Product Object             |
 *    | kenneth.f.alsay                | February 29, 2024     | DEPP-7883              | Added object mapping for Plan_Activity object                 |
 *    | nicole.genon                   | March 7, 2023         | DEPP-7922              | Added object mapping for Stewardship__c Object                | 
 *    | vincent.ferrer                 | March 18, 2024        | DEPP-8200              | Added object mapping for Donation_Cause_Code_Auto_Number__c Object               | 
 */
public class ImplementationSelector { 

    // Configure and create the DAOFactory for this ImplementationSelector
    public static final DAOFactory DAO = new DAOFactory(
        new Map<SObjectType, Type>{
            Account.SObjectType => AccountsDAO.class,
            Action__c.SObjectType => ActionsDAO.class,
            ActionCadenceTracker.SObjectType => ActionCadenceTrackersDAO.class,
            ActionCadenceStepTracker.SObjectType => ActionCadenceStepTrackersDAO.class,
            Adhoc_Communication__c.SObjectType => AdhocCommunicationsDAO.class,
            AppDefinition.SObjectType => AppDefinitionsDAO.class,
            Application_Preference__c.SObjectType => ApplicationPreferencesDAO.class, 
            Asset.SObjectType => AssetsDAO.class,
            Associated_Products__c.SObjectType => AssociatedProductsDAO.class,
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
            ContentDocument.SObjectType => ContentDocumentsDAO.class,
            ContentDocumentLink.SObjectType => ContentDocumentLinksDAO.class,
            ContentVersion.SObjectType => ContentVersionsDAO.class,
            Contextual_Role__c.SObjectType => ContextualRolesDAO.class,
            Consultancy__c.SObjectType => ConsultanciesDAO.class,
            Document__c.SObjectType => DocumentsDAO.class,
            Donation__c.SObjectType => DonationsDAO.class,
            Donation_Cause_Code_Auto_Number__c.SObjectType => DonationCauseCodeAutoNumbersDAO.class,
            Donation_Cause__c.SObjectType => DonationCausesDAO.class,
            Designation__c.SObjectType => DesignationsDAO.class,
            EmailTemplate.SObjectType => EmailTemplatesDAO.class,
            Engagement__c.SObjectType => EngagementsDAO.class,
            Engagement_Code_Auto_Number__c.SobjectType => EngagementCodeAutoNumbersDAO.class,
            Engagement_Opportunity__c.SObjectType => EngagementOpportunitiesDAO.class,
            et4ae5__IndividualEmailResult__c.SobjectType => IndividualEmailResultsDAO.class,
            Finance_Summary__c.SObjectType => FinanceSummariesDAO.class,
            Financial_Split__c.SObjectType => FinancialSplitsDAO.class,
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
            Marketing_Course_Application__c.SObjectType => MarketingCourseApplicationsDAO.class,
            Marketing_Interaction__c.SObjectType => MarketingInteractionsDAO.class,
            Marketing_Segmentation__c.SObjectType => MarketingSegmentationsDAO.class,
            Milestone__c.SObjectType => MilestonesDAO.class,
            Nurture_Track_Configuration__c.SObjectType => NurtureTrackConfigurationsDAO.class,
            Opportunity.SObjectType => OpportunitiesDAO.class,
            Opportunity_Code_Auto_Number__c.SobjectType => OpportunityCodeAutoNumbersDAO.class,
            OpportunityContactRole.SobjectType => OpportunityContactRolesDAO.class,
            Opportunity_Outcome__c.SobjectType => OpportunityOutcomesDAO.class,
            Opportunity_Outcome_Code_Auto_Number__c.SobjectType => OpportunityOutcomeCodeAutoNumbersDAO.class,
            OrgWideEmailAddress.SobjectType => OrgWideEmailAddressesDAO.class,
            Product_Request__c.SObjectType => ProductRequestsDAO.class,
            Package_Component__c.SObjectType => PackageComponentDAO.class,
            Plan_Activity__c.SObjectType => PlanActivitiesDAO.class,
            Pricebook2.SObjectType => PricebooksDAO.class,
            PricebookEntry.SObjectType => PricebookEntriesDAO.class,
            Product2.SObjectType => ProductsDAO.class,
            Profile.SObjectType => ProfilesDAO.class,           
            ProductCategory.SObjectType => ProductCategoriesDAO.class,
            ProductCategoryProduct.SObjectType => ProductCategoryProductsDAO.class,
            Product_Ledger__c.SObjectType => ProductLedgersDAO.class,
            Profile.SObjectType => ProfilesDAO.class,            
            Program_Offering__c.SObjectType => ProgramOfferingsDAO.class,           
            Pure_Project__c.SObjectType => PureProjectsDAO.class,
            Relationship_Manager__c.SObjectType => RelationshipManagersDAO.class,
            Risk__c.SObjectType => RisksDAO.class,
            ServiceAppointment.SObjectType => ServiceAppointmentsDAO.class,
            SMS_Template__c.SObjectType => SMSTemplatesDAO.class,
            Stewardship__c.SObjectType => StewardshipsDAO.class,
            Task.SObjectType => TasksDAO.class,
            User.SObjectType => UsersDAO.class,
            UserAppInfo.SObjectType => UserAppInfosDAO.class,
            UserRecordAccess.SObjectType => UserRecordAccessesDAO.class,
            Expense__c.SObjectType => ExpensesDAO.class,
            List_Member__c.SObjectType => ListMembersDAO.class,
            List__c.SObjectType => ListsDAO.class,
            WebCart.SObjectType => WebCartsDAO.class,
            WebStore.SOBjectType => WebStoresDAO.class,
            List_Contributor__c.SObjectType => ListContributorsDAO.class,
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

