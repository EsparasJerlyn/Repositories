/**
 * @description Selects which SObject DAO to implement
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                            |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------|
      | rhea.b.torres                  | April 25, 2023        | DEPP-5567              | Created file                              |
      | alexander.cadalin              | May 17, 2023          | DEPP-5594              | added sobjects                            |
      | mark.j.mahilum                 | June 01, 2023         | DEPP-5687              | Added Object mapping for Financial Split  |
      | roy.nino.s.regala              | June 13, 2023         | DEPP-5391              | Added Object mapping for UserAppInfo      |
      | kenneth.f.alsay                | June 16, 2023         | DEPP-5434, 5399        | Added Object mapping for Contextual Role  |
      | mark.j.mahilum                 | June 26, 2023         | DEPP-5846              | Added object mapping for Application      |
      | carl.alvin.cabiles             | June 28, 2023         | DEPP-5388              | Added Object mapping for ContentDocument  | 
      | eugene.andrew.abuan            | July 10, 2023         | DEPP-5483              | Added Object mapping for Document and     | 
      |                                |                       |                        | IP Management                             |               
              
 */
public class ImplementationSelector {
    // Configure and create the DAOFactory for this ImplementationSelector
    public static final DAOFactory DAO = new DAOFactory(
        new Map<SObjectType, Type>{
            Account.SObjectType => AccountsDAO.class,
            Action__c.SObjectType => ActionsDAO.class,
            AppDefinition.SObjectType => AppDefinitionsDAO.class,
            Asset.SObjectType => AssetsDAO.class,
            Associated_Products__c.SObjectType => AssociatedProductsDAO.class,
            Contact.SObjectType => ContactsDAO.class,
            ContentDocument.SObjectType => ContentDocumentsDAO.class,
            ContentDocumentLink.SObjectType => ContentDocumentLinksDAO.class,
            ContentVersion.SObjectType => ContentVersionsDAO.class,
            Contextual_Role__c.SObjectType => ContextualRolesDAO.class,
            Consultancy__c.SObjectType => ConsultanciesDAO.class,
            Document__c.SObjectType => DocumentsDAO.class,
            Engagement__c.SObjectType => EngagementsDAO.class,
            Engagement_Code_Auto_Number__c.SobjectType => EngagementCodeAutoNumbersDAO.class,
            Financial_Split__c.SObjectType => FinancialSplitsDAO.class,
            hed__Application__c.SObjectType => ApplicationsDAO.class,
            IP_Management__c.SObjectType => IPManagementsDAO.class,
            Lead.SObjectType => LeadsDAO.class,
            Milestone__c.SObjectType => MilestonesDAO.class,
            Opportunity.SObjectType => OpportunitiesDAO.class,
            Opportunity_Code_Auto_Number__c.SobjectType => OpportunityCodeAutoNumbersDAO.class,
            Opportunity_Outcome__c.SobjectType => OpportunityOutcomesDAO.class,
            Opportunity_Outcome_Code_Auto_Number__c.SobjectType => OpportunityOutcomeCodeAutoNumbersDAO.class,
            Product_Request__c.SObjectType => ProductRequestsDAO.class,
            Product2.SObjectType => ProductsDAO.class,
            Profile.SObjectType => ProfilesDAO.class,
            Pure_Project__c.SObjectType => PureProjectsDAO.class,
            UserAppInfo.SObjectType => UserAppInfosDAO.class
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
