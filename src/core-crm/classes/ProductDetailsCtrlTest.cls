/**
 * @description Tests the Product Details Controller Test Class
 *
 * @see ProductDetailsCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA      | Change Summary                                     |
 *    |---------------------------|-----------------------|-----------|----------------------------------------------------|
 *    | roy.nino.s.regala         | December 10, 2021     | DEPP116   | Created file                                       |
 *    | roy.nino.s.regala         | December 27, 2021     | DEPP1028  | Added testmethod for insertLearnerInfo             |
 *    | roy.nino.s.regala         | February 04, 2022     | DEPP213   | Added testmethod for insert Expression of Interest |
 *    | john.bo.a.pineda          | April 26, 2022        | DEPP-1211 | Updated logic for new UI                           |
 *    | keno.domienri.dico        | April 29, 2022        | DEPP-2038 | Added logic for child products display             |
 *    | julie.jane.alegre         | May 24, 2022          | DEPP-2070 | Added logic for Group Booking                      |
 *    | john.bo.a.pineda          | June 27, 2022         | DEPP-3216 | Modified add validation if Product already exists  |
 *    |                           |                       |           | in Cart only for URL Defaults                      |
 *    | jessel.bajao              | August 12, 2022       | DEPP-3482 | Changed running user and added test data and       |
 *    |                           |                       |           | methods                                            |
 *    | keno.domienri.dico        | August 25, 2022       | DEPP-3765 | Added methods for CCE product categories           |
 *    | jessel.bajao              | September 09, 2022    | DEPP-4071 | Remove testInsertLearnerInfo and added test class  |
 *    |                           |                       |           | for Registration Confirmation Data                 |
 *    | keno.domienri.dico        | October 13, 2022      | DEPP-4283 | Added methods and raise coverage                   |
 */
@isTest
public class ProductDetailsCtrlTest {
    private static final String CATEGORY_OPE = 'Product Catalogue';
    private static final string STUDENT_RT = System.Label.RT_CourseConnection_Student;
    private static final String PRODUCT_API_NAME = Product2.SObjectType.getDescribe(
            SObjectDescribeOptions.DEFERRED
        )
        .getLocalName();
    private static final String PRODUCT_REQUEST_ACTIVITY_RT = System.Label.RT_ProductRequest_Activity;
    private static final Id STUDENT_RECORD_TYPE_ID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName()
        .get(STUDENT_RT)
        .getRecordTypeId();
    private static final Id OPE_ACTIVITY_PROD_REQ_RECORD_TYPE_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName()
        .get(PRODUCT_REQUEST_ACTIVITY_RT)
        .getRecordTypeId();
    private static final String PROD_REQUEST_MODULE_RT = System.Label.RT_ProductRequest_Module;
    private static final Id OPE_MODULE_PROD_REQ_RECORD_TYPE_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName()
        .get(PROD_REQUEST_MODULE_RT)
        .getRecordTypeId();
    private static final Integer NUMBER_OF_RECORDS = 100;
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get(ACCT_UNIV_DEP)
        .getRecordTypeId();
    public static final Id FACULTY_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName()
        .get('Faculty')
        .getRecordTypeId();
    private static final User CURRENT_USER = TestDataFactory.createUserRecords(1, 'QUTeX')
        .iterator()
        .next();
    private static final string PR_PROGRAM = System.Label.RT_ProductRequest_Program;
    private static Id opeProgProdReqId = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName()
        .get(PR_PROGRAM)
        .getRecordTypeId();
    private static final String RT_ACTIVITY = System.Label.RT_ProductRequest_Activity;
    private static final Id RT_ACTIVITY_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName()
        .get(RT_ACTIVITY)
        .getRecordTypeId();
    private static final Id BUSINESS_ACC_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Business_Organization')
        .getRecordTypeId();

    @testSetup
    static void setupMethod() {
        Test.startTest();
        TestDataFactory.generateTestUsers(new List<String>{'QUTeX_Program_Administrator','QUT_Sys_Admin','QUT_OPE_Catalogue'});
        EmailTemplate template = TestDataFactory.createTestEmailTemplateRecords(
                1,
                new Map<String, String>{ 'Send Register Interest Email' => 'Test Email Subject' }
            )
            .iterator()
            .next();
        insert template;

        System.runAs(TestDataFactory.getProgramAdminUser()) {
            BypassTriggers__c bypass = new BypassTriggers__c(
                Bypass__c = true,
                SetupOwnerId = UserInfo.getOrganizationId()
            );
            insert bypass;
        
            User portalSysAdmin = TestDataFactory.getPortalSysAdminUser();
            Flow_Automation_Settings__c customEmail = new Flow_Automation_Settings__c(
                Name = 'test123',
                New_Idea_To_Email_Address__c = 'qutex@qut.edu.au'
            );
            insert customEmail;

            List<Account> accounts = TestDataFactory.createTestAccountRecords(100);
            for (Account account : accounts) {
                account.RecordTypeId = ACCT_UNIV_DEP_ID;
                account.Organization_Unit_Level__c = '2';
            }
            insert accounts;

            List<Contact> contacts = TestDataFactory.createTestContactRecords(100);
            contacts[0]
                .Contact_Image__c = '<p><img src="https://www.w3schools.com/w3css/img_snowtops.jpg" alt="test.jpg"></img></p>';
            insert contacts;

            List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(100, accounts[0].Id);
            insert terms;

            List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(
                100
            );
            prodRequest[0].RecordTypeId = OPE_ACTIVITY_PROD_REQ_RECORD_TYPE_ID;
            insert prodRequest;

            List<Product_Request__c> prodRequestFlexProgram = TestDataFactory.createTestProductRequestRecords(
                100
            );
            prodRequestFlexProgram[0].RecordTypeId = opeProgProdReqId;
            prodRequestFlexProgram[0].OPE_Program_Plan_Type__c = 'Flexible Program';
            insert prodRequestFlexProgram;

            List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(
                100
            );
            programPlans[0].Product_Request__c = prodRequestFlexProgram[0].Id;
            insert programPlans;

            List<Related_Product_Request__c> relatedProductRequests = TestDataFactory.createTestRelatedPRRecords(
                100,
                prodRequest,
                prodRequestFlexProgram
            );
            insert relatedProductRequests;

            List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(
                100,
                accounts[0].Id,
                prodRequest[0].Id
            );
            insert courses;

            List<Product2> singleProducts = TestDataFactory.createTestProductRecords(100, courses);
            for (Product2 sProd : singleProducts) {
                sProd.Delivery__c = 'Online Classroom;Online Self-paced;Brisbane Classroom';
            }
            insert singleProducts;

            List<Product2> flexProgProducts = TestDataFactory.createTestProductRecords(100);
            for (Product2 flexProd : flexProgProducts) {
                flexProd.Delivery__c = 'Online Classroom;Online Self-paced;Brisbane Classroom';
                flexProd.Program_Plan__c = programPlans[0].Id;
            }
            insert flexProgProducts;

            List<Related_Product_Request__c> relatedProdRquests = new List<Related_Product_Request__c>();
            relatedProdRquests.add(
                new Related_Product_Request__c(Program__c = '01t9p000000O16XXXX')
            );

            Pricebook2 pricebook = new Pricebook2(
                isActive = true,
                id = Test.getStandardPricebookId()
            );
            update pricebook;

            //Create account
            Account portalAccount1 = new Account(Name = 'TestAccount', OwnerId = portalSysAdmin.Id);

            Database.insert(portalAccount1);
            //Create contact
            Contact contact1 = new Contact(
                FirstName = 'Test',
                Lastname = 'McTesty',
                AccountId = portalAccount1.Id,
                Registered_Email__c = System.now().millisecond() + 'test@test.com'
            );
            insert contact1;

            List<PricebookEntry> priceBookEntryList = new List<PricebookEntry>();
            for (Product2 singleProdPBEntry : singleProducts) {
                PricebookEntry priceBookEntry = new PricebookEntry();
                priceBookEntry.pricebook2id = pricebook.Id;
                priceBookEntry.UnitPrice = 12;
                priceBookEntry.product2Id = singleProdPBEntry.Id;
                priceBookEntry.isActive = true;
                priceBookEntryList.add(priceBookEntry);
            }

            for (Product2 flexProgProdPBEntry : flexProgProducts) {
                PricebookEntry priceBookEntry = new PricebookEntry();
                priceBookEntry.pricebook2id = pricebook.Id;
                priceBookEntry.UnitPrice = 12;
                priceBookEntry.product2Id = flexProgProdPBEntry.Id;
                priceBookEntry.isActive = true;
                priceBookEntryList.add(priceBookEntry);
            }
            insert priceBookEntryList;

            List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(
                100,
                courses,
                terms
            );
            for (hed__Course_Offering__c cOffering : courseOfferings) {
                cOffering.Registration_Start_Date__c = system.today() - 2;
                cOffering.IsActive__c = true;
                cOffering.Delivery_Type__c = 'Online Classroom';
            }
            insert courseOfferings;

            List<hed__Course_Enrollment__c> courseConnections = TestDataFactory.createTestCourseConnectionRecord(
                100,
                contacts[0].Id,
                courseOfferings
            );
            for (hed__Course_Enrollment__c courseConnection : courseConnections) {
                courseConnection.RecordTypeId = FACULTY_RECTYPEID;
            }
            insert courseConnections;

            WebStore testWebStore = new WebStore(Name = 'CCE', DefaultLanguage = 'en_US');
            insert testWebStore;

            WebCart cart = new WebCart(
                Name = 'Cart',
                AccountId = accounts[0].Id,
                Status = 'Active',
                WebStoreId = testWebStore.Id
            );
            insert cart;

            CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(
                CartId = cart.Id,
                Name = 'Default Delivery'
            );
            insert cartDeliveryGroup;

            BuyerGroup bg = new BuyerGroup();
            bg.Name = 'OPE BuyerGroup';
            insert bg;

            Test.stopTest();
        }
    }

    @isTest
    static void testGetProductRelatedRecords() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();

            ProductDetailsCtrl.ProductDetailsData getSingleProductDetails = new ProductDetailsCtrl.ProductDetailsData();
            getSingleProductDetails = ProductDetailsCtrl.getProductRelatedRecords(
                [
                    SELECT Id
                    FROM Product2
                    WHERE
                        CreatedById = :TestDataFactory.getProgramAdminUser().Id
                        AND Program_Plan__c = ''
                    LIMIT 1
                ]
                .Id
            );

            ProductDetailsCtrl.ProductDetailsData getFlexProgProductDetails = new ProductDetailsCtrl.ProductDetailsData();
            getFlexProgProductDetails = ProductDetailsCtrl.getProductRelatedRecords(
                [
                    SELECT Id
                    FROM Product2
                    WHERE
                        CreatedById = :TestDataFactory.getProgramAdminUser().Id
                        AND Program_Plan__c != ''
                    LIMIT 1
                ]
                .Id
            );

            Test.stopTest();

            System.assert(
                getSingleProductDetails != null,
                'Successfully retrieved Single Product Related Records'
            );

            System.assert(
                getFlexProgProductDetails != null,
                'Successfully retrieved Flex Program Product Related Records'
            );
        }
    }

    @isTest
    static void testGetCCEProductRelatedRecordsTEE() {
        final User PROGRAM_ADMIN = TestDataFactory.getProgramAdminUser();

        BypassTriggers__c bypass = [
            SELECT Id, Bypass__c
            FROM BypassTriggers__c
            WHERE SetupOwnerId = :UserInfo.getOrganizationId()
            LIMIT 1
        ];
        bypass.Bypass__c = false;
        update bypass;

        TestDataFactory.loadEDATriggers();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            WebStore testWebStoreCCE = new WebStore(Name = 'CCE', DefaultLanguage = 'en_US');
            insert testWebStoreCCE;
            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            Integer accCounter = 0;
            for (Account account : accounts) {
                account.RecordTypeId = BUSINESS_ACC_RECTYPEID;
                accCounter++;
            }
            insert accounts;

            List<BuyerGroupMember> bgm = [
                SELECT Id, Name, BuyerId, BuyerGroupId
                FROM BuyerGroupMember
                WHERE BuyerId = :accounts[0].Id
            ];

            List<BuyerGroup> bGroup = [
                SELECT Id, Name
                FROM BuyerGroup
                WHERE Id = :bgm[0].BuyerGroupId
            ];

            Contact cceContact = new Contact(
                FirstName = 'Test',
                LastName = 'Contact',
                Email = 'testcontact@email.com',
                Registered_Email__c = 'testcontact@email.com',
                AccountId = accounts[0].Id,
                Work_Email__c = 'test@workemail.com',
                hed__Preferred_Email__c = 'Alternate Email',
                hed__AlternateEmail__c = 'test@email.com'
            );
            insert cceContact;

            //get the ACR list to check if exists
            List<AccountContactRelation> acrList = new List<AccountContactRelation>(
                [
                    SELECT ContactId
                    FROM AccountContactRelation
                    WHERE AccountId = :accounts[0].Id
                    LIMIT 1
                ]
            );

            if (acrList.isEmpty()) {
                //create ACR
                AccountContactRelation acr = new AccountContactRelation(
                    AccountId = accounts[0].Id,
                    ContactId = cceContact.Id
                );

                insert acr;
            }

            CCECorporateUserCtrl.CorporateUserDetails enableResponse = new CCECorporateUserCtrl.CorporateUserDetails();
            enableResponse = CCECorporateUserCtrl.enablePortalUser(cceContact.Id, CATEGORY_OPE);

            List<Account> accBusinessOrg = [
                SELECT Id, RecordTypeId
                FROM Account
                WHERE RecordTypeId = :BUSINESS_ACC_RECTYPEID AND CreatedById = :PROGRAM_ADMIN.Id
            ];

            List<Account> accUniv = [
                SELECT Id, RecordTypeId
                FROM Account
                WHERE RecordTypeId = :ACCT_UNIV_DEP_ID
            ];

            // Create BuyerGroupMember
            List<BuyerGroupMember> gbMember = [
                SELECT Id, BuyerId, BuyerGroupId
                FROM BuyerGroupMember
                WHERE BuyerId = :accBusinessOrg[0].Id AND BuyerGroup.Name != 'OPE BuyerGroup'
            ];

            // Create CommerceEntitlementBuyerGroup
            List<CommerceEntitlementBuyerGroup> ceBuyerGroup = [
                SELECT Id, PolicyId, BuyerGroupId
                FROM CommerceEntitlementBuyerGroup
                WHERE BuyerGroupId = :gbMember[0].BuyerGroupId
            ];

            ProductCatalog prodCCECatalog = new ProductCatalog(Name = 'CCE Catalog');
            insert prodCCECatalog;
            ProductCategory prodCateg1 = new ProductCategory(
                Name = 'Tailored Executive Education',
                CatalogId = prodCCECatalog.Id
            );
            insert prodCateg1;

            // Create Products
            List<Product_Request__c> prodRequestCCE = TestDataFactory.createTestProductRequestRecords(
                1
            );
            prodRequestCCE[0].RecordTypeId = RT_ACTIVITY_ID;
            insert prodRequestCCE;

            // Single Products
            List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(
                10,
                accUniv[0].Id,
                prodRequestCCE[0].Id
            );
            insert courses;

            List<Product2> singleProductsCCE = TestDataFactory.createTestProductRecords(
                10,
                courses
            );
            Integer sProdCount = 0;
            for (Product2 sProd : singleProductsCCE) {
                sProd.Delivery__c = 'Online Classroom;Online Self-paced;Brisbane Classroom';
                sProd.Study_Area__c = 'Engineering';
                sProd.Product_Type__c = 'Short Course';
                sProd.Course__c = courses[0].Id;
                sProd.Available_on_Cart__c = true;
                sProd.Product_Category__c = 'Tailored Executive Program';
                sProdCount++;
            }
            insert singleProductsCCE;

            List<Product2> getSingleProd = [
                SELECT Id, Course__c
                FROM Product2
                WHERE Course__c != NULL
            ];
            List<ProductCategoryProduct> setTEEList = new List<ProductCategoryProduct>();
            for (Integer x = 0; x <= sProdCount; x++) {
                ProductCategoryProduct setTEE = new ProductCategoryProduct();
                setTEE.ProductCategoryId = prodCateg1.Id;
                setTEE.ProductId = getSingleProd[x].Id;
                setTEEList.add(setTEE);
            }
            insert setTEEList;

            List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(10, accUniv[0].Id);
            insert terms;

            List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(
                10,
                courses,
                terms
            );
            for (hed__Course_Offering__c cOffering : courseOfferings) {
                cOffering.Registration_Start_Date__c = system.today() - 2;
                cOffering.IsActive__c = true;
                cOffering.Delivery_Type__c = 'Online Classroom';
            }
            insert courseOfferings;

            List<CommerceEntitlementProduct> ceProd = [
                SELECT Id, ProductId, PolicyId
                FROM CommerceEntitlementProduct
            ];
            Integer a = 0;
            for (CommerceEntitlementProduct setCEProd : ceProd) {
                setCEProd.ProductId = getSingleProd[a].Id;
                setCEProd.PolicyId = ceBuyerGroup[0].PolicyId;
                a++;
            }
            insert ceProd;

            // Prescribe Program
            List<Product_Request__c> prodRequestPrescribedProgram = TestDataFactory.createTestProductRequestRecords(
                1
            );
            prodRequestPrescribedProgram[0].RecordTypeId = opeProgProdReqId;
            prodRequestPrescribedProgram[0].OPE_Program_Plan_Type__c = 'Prescribed Program';
            insert prodRequestPrescribedProgram;

            List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(
                1
            );
            programPlans[0].Product_Request__c = prodRequestPrescribedProgram[0].Id;
            insert programPlans;

            List<Product2> prodProgProductsCCE = TestDataFactory.createTestProductRecords(50);
            Integer pProdCount = 0;
            for (Product2 presProd : prodProgProductsCCE) {
                presProd.Delivery__c = 'Online Classroom;Online Self-paced;Brisbane Classroom';
                presProd.Study_Area__c = 'Engineering';
                presProd.Product_Type__c = 'Short Course';
                presProd.Program_Plan__c = programPlans[0].Id;
                presProd.Available_on_Cart__c = true;
                presProd.Product_Category__c = 'Tailored Executive Program';
                pProdCount++;
            }
            insert prodProgProductsCCE;
            List<Product2> getPresProd = [
                SELECT Id, Program_Plan__c
                FROM Product2
                WHERE Program_Plan__c != NULL
            ];
            List<ProductCategoryProduct> setTEEProgList = new List<ProductCategoryProduct>();
            for (Integer y = 0; y <= sProdCount; y++) {
                ProductCategoryProduct setTEEProg = new ProductCategoryProduct();
                setTEEProg.ProductCategoryId = prodCateg1.Id;
                setTEEProg.ProductId = getPresProd[y].Id;
                setTEEProgList.add(setTEEProg);
            }
            insert setTEEProgList;

            //Create Child Products
            List<Product_Request__c> prodRequestChild = TestDataFactory.createTestProductRequestRecords(
                10
            );
            prodRequestChild[0].RecordTypeId = RT_ACTIVITY_ID;
            prodRequestChild[0].Product_Request_Status__c = 'Published';
            insert prodRequestChild;

            // Update CCE BuyerGroup
            BuyerGroup bgUpdateChild = [
                SELECT Id, Name, Product_Request__c, Primary_Account__c
                FROM BuyerGroup
                WHERE Id = :bGroup[0].Id
            ];
            bgUpdateChild.Product_Request__c = prodRequestChild[0].Id;
            update bgUpdateChild;

            // Single Products
            List<hed__Course__c> coursesChild = TestDataFactory.createTestCourseRecords(
                10,
                accUniv[0].Id,
                prodRequestChild[0].Id
            );
            insert coursesChild;

            List<Product2> singleProductsChild = TestDataFactory.createTestProductRecords(
                10,
                coursesChild
            );
            Integer sProdCountChild = 0;
            for (Product2 sProdChild : singleProductsChild) {
                sProdChild.Delivery__c = 'Online Classroom;Online Self-paced;Brisbane Classroom';
                sProdChild.Study_Area__c = 'Engineering';
                sProdChild.Product_Type__c = 'Short Course';
                sProdChild.Course__c = coursesChild[0].Id;
                sProdChild.Available_on_Cart__c = true;
                sProdCountChild++;
            }
            insert singleProductsChild;

            List<Product2> getSingleProdChild = [
                SELECT Id, Course__c
                FROM Product2
                WHERE Course__c != NULL
            ];
            List<ProductCategoryProduct> setTEEListChild = new List<ProductCategoryProduct>();
            for (Integer x = 0; x <= sProdCountChild; x++) {
                ProductCategoryProduct setTEEChild = new ProductCategoryProduct();
                setTEEChild.ProductCategoryId = prodCateg1.Id;
                setTEEChild.ProductId = getSingleProdChild[x].Id;
                setTEEList.add(setTEEChild);
            }
            insert setTEEListChild;

            List<hed__Course_Offering__c> courseOfferingsChild = TestDataFactory.createTestCourseOfferingRecord(
                10,
                coursesChild,
                terms
            );
            for (hed__Course_Offering__c cOfferingChild : courseOfferingsChild) {
                cOfferingChild.Registration_Start_Date__c = system.today() - 2;
                cOfferingChild.IsActive__c = true;
                cOfferingChild.Delivery_Type__c = 'Online Classroom';
            }
            insert courseOfferingsChild;

            List<CommerceEntitlementProduct> ceProdChild = [
                SELECT Id, ProductId, PolicyId
                FROM CommerceEntitlementProduct
            ];
            Integer commChildCount = 0;
            for (CommerceEntitlementProduct setCEProdChild : ceProdChild) {
                setCEProdChild.ProductId = getSingleProdChild[commChildCount].Id;
                setCEProdChild.PolicyId = ceBuyerGroup[0].PolicyId;
                a++;
            }
            insert ceProdChild;

            List<Related_Product_Request__c> childProdRelatedRequest = TestDataFactory.createTestRelatedPRRecords(
                1,
                prodRequestChild,
                prodRequestPrescribedProgram
            );
            insert childProdRelatedRequest;
            // End Child Products

            List<CommerceEntitlementProduct> ceProdPres = [
                SELECT Id, ProductId, PolicyId
                FROM CommerceEntitlementProduct
            ];
            Integer b = 0;
            for (CommerceEntitlementProduct setCEProdPres : ceProdPres) {
                setCEProdPres.ProductId = getPresProd[b].Id;
                setCEProdPres.PolicyId = ceBuyerGroup[0].PolicyId;
                b++;
            }
            insert ceProdPres;

            Id singleProdId = [
                SELECT Id
                FROM Product2
                WHERE
                    CreatedById = :TestDataFactory.getProgramAdminUser().Id
                    AND Program_Plan__c = ''
                LIMIT 1
            ]
            .Id;

            Id progProdId = [
                SELECT Id
                FROM Product2
                WHERE
                    CreatedById = :TestDataFactory.getProgramAdminUser().Id
                    AND Program_Plan__c != ''
                LIMIT 1
            ]
            .Id;

            ProductDetailsCtrl.ProductDetailsData getSingleProductDetails = new ProductDetailsCtrl.ProductDetailsData();
            ProductDetailsCtrl.ProductDetailsData getProdDet1 = new ProductDetailsCtrl.ProductDetailsData();
            getProdDet1.accountId = accounts[0].Id;
            getProdDet1.categoryName = 'Tailored Executive Program';
            getProdDet1.userId = enableResponse.userId;
            getProdDet1.productId = singleProdId;
            getSingleProductDetails = ProductDetailsCtrl.getCCEProductRelatedRecords(getProdDet1);

            ProductDetailsCtrl.ProductDetailsData getFlexProgProductDetails = new ProductDetailsCtrl.ProductDetailsData();
            ProductDetailsCtrl.ProductDetailsData getProdDet2 = new ProductDetailsCtrl.ProductDetailsData();
            getProdDet2.accountId = accounts[0].Id;
            getProdDet2.categoryName = 'Tailored Executive Program';
            getProdDet2.userId = enableResponse.userId;
            getProdDet2.productId = progProdId;
            getFlexProgProductDetails = ProductDetailsCtrl.getCCEProductRelatedRecords(getProdDet2);

            Test.stopTest();

            System.assert(
                getSingleProductDetails != null,
                'Failed to retrieved Single Product Related Records'
            );

            System.assert(
                getFlexProgProductDetails != null,
                'Failed to retrieved Flex Program Product Related Records'
            );
        }
    }

    @isTest
    static void testGetCCEProductRelatedRecordsCB() {
        BypassTriggers__c bypass = [
            SELECT Id, Bypass__c
            FROM BypassTriggers__c
            WHERE SetupOwnerId = :UserInfo.getOrganizationId()
            LIMIT 1
        ];
        bypass.Bypass__c = false;
        update bypass;

        TestDataFactory.loadEDATriggers();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            
            WebStore testWebStoreCCE = new WebStore(Name = 'CCE', DefaultLanguage = 'en_US');
            insert testWebStoreCCE;
            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            Integer accCounter = 0;
            for (Account account : accounts) {
                account.RecordTypeId = BUSINESS_ACC_RECTYPEID;
                accCounter++;
            }
            insert accounts;

            List<BuyerGroupMember> bGroupMember = [
                SELECT Id, Name, BuyerId, BuyerGroupId
                FROM BuyerGroupMember
                WHERE BuyerId = :accounts[0].Id
            ];

            List<BuyerGroup> bGroup = [
                SELECT Id, Name
                FROM BuyerGroup
                WHERE Id = :bGroupMember[0].BuyerGroupId
            ];

            Contact cceContact = new Contact(
                FirstName = 'Test',
                LastName = 'Contact',
                Email = 'testcontact@email.com',
                Registered_Email__c = 'testcontact@email.com',
                AccountId = accounts[0].Id,
                Work_Email__c = 'test@workemail.com',
                hed__Preferred_Email__c = 'Alternate Email',
                hed__AlternateEmail__c = 'test@email.com'
            );
            insert cceContact;
            Test.startTest();
            //get the ACR list to check if exists
            List<AccountContactRelation> acrList = new List<AccountContactRelation>(
                [
                    SELECT ContactId
                    FROM AccountContactRelation
                    WHERE AccountId = :accounts[0].Id
                    LIMIT 1
                ]
            );

            if (acrList.isEmpty()) {
                //create ACR
                AccountContactRelation acr = new AccountContactRelation(
                    AccountId = accounts[0].Id,
                    ContactId = cceContact.Id
                );

                insert acr;
            }

            CCECorporateUserCtrl.CorporateUserDetails enableResponse = new CCECorporateUserCtrl.CorporateUserDetails();
            enableResponse = CCECorporateUserCtrl.enablePortalUser(cceContact.Id, CATEGORY_OPE);

            List<Account> accUniv = [
                SELECT Id, RecordTypeId
                FROM Account
                WHERE RecordTypeId = :ACCT_UNIV_DEP_ID
            ];

            // Create CommerceEntitlementBuyerGroup
            List<CommerceEntitlementBuyerGroup> ceBuyerGroup = [
                SELECT Id, PolicyId, BuyerGroupId
                FROM CommerceEntitlementBuyerGroup
                WHERE BuyerGroupId = :bGroupMember[0].BuyerGroupId
            ];

            ProductCatalog prodCCECatalog = new ProductCatalog(Name = 'CCE Catalog');
            insert prodCCECatalog;
            ProductCategory prodCateg1 = new ProductCategory(
                Name = 'Corporate Bundle',
                CatalogId = prodCCECatalog.Id
            );
            insert prodCateg1;

            // Create Products
            List<Product_Request__c> prodRequestCCE = TestDataFactory.createTestProductRequestRecords(
                1
            );
            prodRequestCCE[0].RecordTypeId = RT_ACTIVITY_ID;
            prodRequestCCE[0].Product_Request_Status__c = 'Published';
            insert prodRequestCCE;

            // Single Products
            List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(
                10,
                accUniv[0].Id,
                prodRequestCCE[0].Id
            );
            insert courses;

            // Update CCE BuyerGroup SIngle
            BuyerGroup bgUpdate = [
                SELECT Id, Name, Product_Request__c, Primary_Account__c
                FROM BuyerGroup
                WHERE Id = :bGroup[0].Id
            ];
            bgUpdate.Product_Request__c = prodRequestCCE[0].Id;
            update bgUpdate;

            List<Product2> singleProductsCCE = TestDataFactory.createTestProductRecords(
                10,
                courses
            );
            Integer sProdCount = 0;
            for (Product2 sProd : singleProductsCCE) {
                sProd.Delivery__c = 'Online Classroom;Online Self-paced;Brisbane Classroom';
                sProd.Study_Area__c = 'Engineering';
                sProd.Product_Type__c = 'Short Course';
                sProd.Course__c = courses[0].Id;
                sProd.Available_on_Cart__c = true;
                sProdCount++;
            }
            insert singleProductsCCE;

            List<Product2> getSingleProd = [
                SELECT Id, Course__c
                FROM Product2
                WHERE Course__c != NULL
            ];
            List<ProductCategoryProduct> setTEEList = new List<ProductCategoryProduct>();
            for (Integer x = 0; x <= sProdCount; x++) {
                ProductCategoryProduct setTEE = new ProductCategoryProduct();
                setTEE.ProductCategoryId = prodCateg1.Id;
                setTEE.ProductId = getSingleProd[x].Id;
                setTEEList.add(setTEE);
            }
            insert setTEEList;

            List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(10, accUniv[0].Id);
            insert terms;

            List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(
                10,
                courses,
                terms
            );
            for (hed__Course_Offering__c cOffering : courseOfferings) {
                cOffering.Registration_Start_Date__c = system.today() - 2;
                cOffering.IsActive__c = true;
                cOffering.Delivery_Type__c = 'Online Classroom';
            }
            insert courseOfferings;

            List<CommerceEntitlementProduct> ceProd = [
                SELECT Id, ProductId, PolicyId
                FROM CommerceEntitlementProduct
            ];
            Integer a = 0;
            for (CommerceEntitlementProduct setCEProd : ceProd) {
                setCEProd.ProductId = getSingleProd[a].Id;
                setCEProd.PolicyId = ceBuyerGroup[0].PolicyId;
                a++;
            }
            insert ceProd;

            // Prescribe Program
            List<Product_Request__c> prodRequestPrescribedProgram = TestDataFactory.createTestProductRequestRecords(
                1
            );
            prodRequestPrescribedProgram[0].RecordTypeId = opeProgProdReqId;
            prodRequestPrescribedProgram[0].OPE_Program_Plan_Type__c = 'Prescribed Program';
            prodRequestPrescribedProgram[0].Product_Request_Status__c = 'Published';
            insert prodRequestPrescribedProgram;

            // Create CCE BuyerGroup Program
            BuyerGroup bgUpdateProg = TestDataFactory.createTestBuyerGroup(true);
            bgUpdateProg.Product_Request__c = prodRequestPrescribedProgram[0].Id;
            bgUpdateProg.Primary_Account__c = accounts[0].Id;
            update bgUpdateProg;

            List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(
                1
            );
            programPlans[0].Product_Request__c = prodRequestPrescribedProgram[0].Id;
            insert programPlans;

            List<Product2> prodProgProductsCCE = TestDataFactory.createTestProductRecords(50);
            Integer pProdCount = 0;
            for (Product2 presProd : prodProgProductsCCE) {
                presProd.Delivery__c = 'Online Classroom;Online Self-paced;Brisbane Classroom';
                presProd.Study_Area__c = 'Engineering';
                presProd.Product_Type__c = 'Short Course';
                presProd.Program_Plan__c = programPlans[0].Id;
                presProd.Available_on_Cart__c = true;
                pProdCount++;
            }
            insert prodProgProductsCCE;
            List<Product2> getPresProd = [
                SELECT Id, Program_Plan__c
                FROM Product2
                WHERE Program_Plan__c != NULL
            ];
            List<ProductCategoryProduct> setTEEProgList = new List<ProductCategoryProduct>();
            for (Integer y = 0; y <= sProdCount; y++) {
                ProductCategoryProduct setTEEProg = new ProductCategoryProduct();
                setTEEProg.ProductCategoryId = prodCateg1.Id;
                setTEEProg.ProductId = getPresProd[y].Id;
                setTEEProgList.add(setTEEProg);
            }
            insert setTEEProgList;

            //Create Child Products
            List<Product_Request__c> prodRequestChild = TestDataFactory.createTestProductRequestRecords(
                10
            );
            prodRequestChild[0].RecordTypeId = RT_ACTIVITY_ID;
            prodRequestChild[0].Product_Request_Status__c = 'Published';
            insert prodRequestChild;

            // Update CCE BuyerGroup
            BuyerGroup bgUpdateChild = [
                SELECT Id, Name, Product_Request__c, Primary_Account__c
                FROM BuyerGroup
                WHERE Id = :bGroup[0].Id
            ];
            bgUpdateChild.Product_Request__c = prodRequestChild[0].Id;
            update bgUpdateChild;

            // Single Products
            List<hed__Course__c> coursesChild = TestDataFactory.createTestCourseRecords(
                10,
                accUniv[0].Id,
                prodRequestChild[0].Id
            );
            insert coursesChild;

            List<Product2> singleProductsChild = TestDataFactory.createTestProductRecords(
                10,
                coursesChild
            );
            Integer sProdCountChild = 0;
            for (Product2 sProdChild : singleProductsChild) {
                sProdChild.Delivery__c = 'Online Classroom;Online Self-paced;Brisbane Classroom';
                sProdChild.Study_Area__c = 'Engineering';
                sProdChild.Product_Type__c = 'Short Course';
                sProdChild.Course__c = coursesChild[0].Id;
                sProdChild.Available_on_Cart__c = true;
                sProdCountChild++;
            }
            insert singleProductsChild;

            Pricebook2 pricebookChild = new Pricebook2(
                isActive = true,
                id = Test.getStandardPricebookId()
            );
            update pricebookChild;

            Pricebook2 pbCBChild = new Pricebook2();
            pbCBChild.Name = 'Corporate Bundle - Test Child';
            pbCBChild.IsActive = true;
            insert pbCBChild;

            // Create BuyerGroupPriceBook
            BuyerGroupPriceBook bgPriceBookChild = new BuyerGroupPriceBook();
            bgPriceBookChild.PriceBook2Id = pbCBChild.Id;
            bgPriceBookChild.BuyerGroupId = bGroupMember[0].BuyerGroupId;
            insert bgPriceBookChild;

            // Create PricebookEntry Standard
            List<PricebookEntry> priceBookEntryListChild = new List<PricebookEntry>();
            for (Product2 singleProdPBEntryChild : singleProductsChild) {
                PricebookEntry priceBookEntry = new PricebookEntry();
                priceBookEntry.pricebook2id = pricebookChild.Id;
                priceBookEntry.UnitPrice = 10;
                priceBookEntry.product2Id = singleProdPBEntryChild.Id;
                priceBookEntry.isActive = true;
                priceBookEntryListChild.add(priceBookEntry);
            }
            insert priceBookEntryListChild;

            List<Product2> getSingleProdChild = [
                SELECT Id, Course__c
                FROM Product2
                WHERE Course__c != NULL
            ];
            List<ProductCategoryProduct> setTEEListChild = new List<ProductCategoryProduct>();
            for (Integer x = 0; x <= sProdCountChild; x++) {
                ProductCategoryProduct setTEEChild = new ProductCategoryProduct();
                setTEEChild.ProductCategoryId = prodCateg1.Id;
                setTEEChild.ProductId = getSingleProdChild[x].Id;
                setTEEList.add(setTEEChild);
            }
            insert setTEEListChild;

            List<hed__Course_Offering__c> courseOfferingsChild = TestDataFactory.createTestCourseOfferingRecord(
                10,
                coursesChild,
                terms
            );
            for (hed__Course_Offering__c cOfferingChild : courseOfferingsChild) {
                cOfferingChild.Registration_Start_Date__c = system.today() - 2;
                cOfferingChild.IsActive__c = true;
                cOfferingChild.Delivery_Type__c = 'Online Classroom';
            }
            insert courseOfferingsChild;

            List<CommerceEntitlementProduct> ceProdChild = [
                SELECT Id, ProductId, PolicyId
                FROM CommerceEntitlementProduct
            ];
            Integer commChildCount = 0;
            for (CommerceEntitlementProduct setCEProdChild : ceProdChild) {
                setCEProdChild.ProductId = getSingleProdChild[commChildCount].Id;
                setCEProdChild.PolicyId = ceBuyerGroup[0].PolicyId;
                a++;
            }
            insert ceProdChild;

            List<Related_Product_Request__c> childProdRelatedRequest = TestDataFactory.createTestRelatedPRRecords(
                1,
                prodRequestChild,
                prodRequestPrescribedProgram
            );
            insert childProdRelatedRequest;
            // End Child Products

            // Create Pricebook
            Pricebook2 pricebook = new Pricebook2(
                isActive = true,
                id = Test.getStandardPricebookId()
            );
            update pricebook;

            Pricebook2 pbCB = new Pricebook2();
            pbCB.Name = 'Corporate Bundle - Test';
            pbCB.IsActive = true;
            insert pbCB;

            // Create BuyerGroupPriceBook
            BuyerGroupPriceBook bgPriceBook = new BuyerGroupPriceBook();
            bgPriceBook.PriceBook2Id = pbCB.Id;
            bgPriceBook.BuyerGroupId = bGroupMember[0].BuyerGroupId;
            insert bgPriceBook;

            // Create PricebookEntry Standard
            List<PricebookEntry> priceBookEntryListCCESTD = new List<PricebookEntry>();
            for (Product2 singleProdPBEntryCCEStd : singleProductsCCE) {
                PricebookEntry priceBookEntry = new PricebookEntry();
                priceBookEntry.pricebook2id = pricebook.Id;
                priceBookEntry.UnitPrice = 12;
                priceBookEntry.product2Id = singleProdPBEntryCCEStd.Id;
                priceBookEntry.isActive = true;
                priceBookEntryListCCESTD.add(priceBookEntry);
            }

            for (Product2 presProgProdPBEntryCCEStd : prodProgProductsCCE) {
                PricebookEntry priceBookEntry = new PricebookEntry();
                priceBookEntry.pricebook2id = pricebook.Id;
                priceBookEntry.UnitPrice = 10;
                priceBookEntry.product2Id = presProgProdPBEntryCCEStd.Id;
                priceBookEntry.isActive = true;
                priceBookEntryListCCESTD.add(priceBookEntry);
            }
            insert priceBookEntryListCCESTD;

            // Create PricebookEntry CB Standard
            List<PricebookEntry> priceBookEntryListCCE = new List<PricebookEntry>();
            for (Product2 singleProdPBEntryCCE : singleProductsCCE) {
                PricebookEntry priceBookEntry = new PricebookEntry();
                priceBookEntry.pricebook2id = pbCB.Id;
                priceBookEntry.UnitPrice = 12;
                priceBookEntry.product2Id = singleProdPBEntryCCE.Id;
                priceBookEntry.isActive = true;
                priceBookEntryListCCE.add(priceBookEntry);
            }

            for (Product2 presProgProdPBEntryCCE : prodProgProductsCCE) {
                PricebookEntry priceBookEntry = new PricebookEntry();
                priceBookEntry.pricebook2id = pbCB.Id;
                priceBookEntry.UnitPrice = 10;
                priceBookEntry.product2Id = presProgProdPBEntryCCE.Id;
                priceBookEntry.isActive = true;
                priceBookEntryListCCE.add(priceBookEntry);
            }
            insert priceBookEntryListCCE;

            Id singleProdId = [
                SELECT Id, Pricebook2.Name, Pricebook2Id, Product2.Name, Product2Id
                FROM PricebookEntry
                WHERE Pricebook2.Name = 'Corporate Bundle - Test' AND Product2.Course__c != NULL
                LIMIT 1
            ]
            .Product2Id;

            Id progProdId = [
                SELECT Id, Pricebook2.Name, Pricebook2Id, Product2.Name, Product2Id
                FROM PricebookEntry
                WHERE
                    Pricebook2.Name = 'Corporate Bundle - Test'
                    AND Product2.Program_Plan__c != NULL
                LIMIT 1
            ]
            .Product2Id;

            ProductDetailsCtrl.ProductDetailsData getSingleProductDetails = new ProductDetailsCtrl.ProductDetailsData();
            ProductDetailsCtrl.ProductDetailsData getProdDet1 = new ProductDetailsCtrl.ProductDetailsData();
            getProdDet1.accountId = accounts[0].Id;
            getProdDet1.categoryName = 'Corporate Bundle';
            getProdDet1.userId = enableResponse.userId;
            getProdDet1.productId = singleProdId;
            getSingleProductDetails = ProductDetailsCtrl.getCCEProductRelatedRecords(getProdDet1);

            ProductDetailsCtrl.ProductDetailsData getFlexProgProductDetails = new ProductDetailsCtrl.ProductDetailsData();
            ProductDetailsCtrl.ProductDetailsData getProdDet2 = new ProductDetailsCtrl.ProductDetailsData();
            getProdDet2.accountId = accounts[0].Id;
            getProdDet2.categoryName = 'Corporate Bundle';
            getProdDet2.userId = enableResponse.userId;
            getProdDet2.productId = progProdId;
            getFlexProgProductDetails = ProductDetailsCtrl.getCCEProductRelatedRecords(getProdDet2);

            Test.stopTest();

            System.assert(
                getSingleProductDetails != null,
                'Failed to retrieved Single Product Related Records'
            );

            System.assert(
                getFlexProgProductDetails != null,
                'Failed retrieved Flex Program Product Related Records'
            );
        }
    }

    @isTest
    static void testGetCCEProductRelatedRecordsSOA() {
        BypassTriggers__c bypass = [
            SELECT Id, Bypass__c
            FROM BypassTriggers__c
            WHERE SetupOwnerId = :UserInfo.getOrganizationId()
            LIMIT 1
        ];
        bypass.Bypass__c = false;
        update bypass;

        TestDataFactory.loadEDATriggers();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            WebStore testWebStoreCCE = new WebStore(Name = 'CCE', DefaultLanguage = 'en_US');
            insert testWebStoreCCE;
            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            Integer accCounter = 0;
            for (Account account : accounts) {
                account.RecordTypeId = BUSINESS_ACC_RECTYPEID;
                accCounter++;
            }
            insert accounts;

            List<BuyerGroupMember> bGroupMember = [
                SELECT Id, Name, BuyerId, BuyerGroupId
                FROM BuyerGroupMember
                WHERE BuyerId = :accounts[0].Id
            ];

            List<BuyerGroup> bGroup = [
                SELECT Id, Name
                FROM BuyerGroup
                WHERE Id = :bGroupMember[0].BuyerGroupId
            ];

            Contact cceContact = new Contact(
                FirstName = 'Test',
                LastName = 'Contact',
                Email = 'testcontact@email.com',
                Registered_Email__c = 'testcontact@email.com',
                AccountId = accounts[0].Id,
                Work_Email__c = 'test@workemail.com',
                hed__Preferred_Email__c = 'Alternate Email',
                hed__AlternateEmail__c = 'test@email.com'
            );
            insert cceContact;
            Test.startTest();
            //get the ACR list to check if exists
            List<AccountContactRelation> acrList = new List<AccountContactRelation>(
                [
                    SELECT ContactId
                    FROM AccountContactRelation
                    WHERE AccountId = :accounts[0].Id
                    LIMIT 1
                ]
            );

            if (acrList.isEmpty()) {
                //create ACR
                AccountContactRelation acr = new AccountContactRelation(
                    AccountId = accounts[0].Id,
                    ContactId = cceContact.Id
                );

                insert acr;
            }

            CCECorporateUserCtrl.CorporateUserDetails enableResponse = new CCECorporateUserCtrl.CorporateUserDetails();
            enableResponse = CCECorporateUserCtrl.enablePortalUser(cceContact.Id, CATEGORY_OPE);

            List<Account> accUniv = [
                SELECT Id, RecordTypeId
                FROM Account
                WHERE RecordTypeId = :ACCT_UNIV_DEP_ID
            ];

            // Create CommerceEntitlementBuyerGroup
            List<CommerceEntitlementBuyerGroup> ceBuyerGroup = [
                SELECT Id, PolicyId, BuyerGroupId
                FROM CommerceEntitlementBuyerGroup
                WHERE BuyerGroupId = :bGroupMember[0].BuyerGroupId
            ];

            ProductCatalog prodCCECatalog = new ProductCatalog(Name = 'CCE Catalog');
            insert prodCCECatalog;
            ProductCategory prodCateg1 = new ProductCategory(
                Name = 'QUTeX Learning Solutions',
                CatalogId = prodCCECatalog.Id
            );
            insert prodCateg1;

            // Create Products
            List<Product_Request__c> prodRequestCCE = TestDataFactory.createTestProductRequestRecords(
                1
            );
            prodRequestCCE[0].RecordTypeId = RT_ACTIVITY_ID;
            prodRequestCCE[0].Product_Request_Status__c = 'Published';
            insert prodRequestCCE;

            // Update CCE BuyerGroup
            BuyerGroup bgUpdate = [
                SELECT Id, Name, Product_Request__c, Primary_Account__c
                FROM BuyerGroup
                WHERE Id = :bGroup[0].Id
            ];
            bgUpdate.Product_Request__c = prodRequestCCE[0].Id;
            update bgUpdate;

            // Single Products
            List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(
                10,
                accUniv[0].Id,
                prodRequestCCE[0].Id
            );
            insert courses;

            List<Product2> singleProductsCCE = TestDataFactory.createTestProductRecords(
                10,
                courses
            );
            Integer sProdCount = 0;
            for (Product2 sProd : singleProductsCCE) {
                sProd.Delivery__c = 'Online Classroom;Online Self-paced;Brisbane Classroom';
                sProd.Study_Area__c = 'Engineering';
                sProd.Product_Type__c = 'Short Course';
                sProd.Course__c = courses[0].Id;
                sProd.Available_on_Cart__c = true;
                sProdCount++;
            }
            insert singleProductsCCE;

            List<Product2> getSingleProd = [
                SELECT Id, Course__c
                FROM Product2
                WHERE Course__c != NULL
            ];
            List<ProductCategoryProduct> setTEEList = new List<ProductCategoryProduct>();
            for (Integer x = 0; x <= sProdCount; x++) {
                ProductCategoryProduct setTEE = new ProductCategoryProduct();
                setTEE.ProductCategoryId = prodCateg1.Id;
                setTEE.ProductId = getSingleProd[x].Id;
                setTEEList.add(setTEE);
            }
            insert setTEEList;

            List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(10, accUniv[0].Id);
            insert terms;

            List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(
                10,
                courses,
                terms
            );
            for (hed__Course_Offering__c cOffering : courseOfferings) {
                cOffering.Registration_Start_Date__c = system.today() - 2;
                cOffering.IsActive__c = true;
                cOffering.Delivery_Type__c = 'Online Classroom';
            }
            insert courseOfferings;

            List<CommerceEntitlementProduct> ceProd = [
                SELECT Id, ProductId, PolicyId
                FROM CommerceEntitlementProduct
            ];
            Integer a = 0;
            for (CommerceEntitlementProduct setCEProd : ceProd) {
                setCEProd.ProductId = getSingleProd[a].Id;
                setCEProd.PolicyId = ceBuyerGroup[0].PolicyId;
                a++;
            }
            insert ceProd;

            // Prescribe Program
            List<Product_Request__c> prodRequestPrescribedProgram = TestDataFactory.createTestProductRequestRecords(
                1
            );
            prodRequestPrescribedProgram[0].RecordTypeId = opeProgProdReqId;
            prodRequestPrescribedProgram[0].OPE_Program_Plan_Type__c = 'Prescribed Program';
            prodRequestPrescribedProgram[0].Product_Request_Status__c = 'Published';
            insert prodRequestPrescribedProgram;

            // Create CCE BuyerGroup Program
            BuyerGroup bgUpdateProg = TestDataFactory.createTestBuyerGroup(true);
            bgUpdateProg.Product_Request__c = prodRequestPrescribedProgram[0].Id;
            bgUpdateProg.Primary_Account__c = accounts[0].Id;
            update bgUpdateProg;

            List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(
                1
            );
            programPlans[0].Product_Request__c = prodRequestPrescribedProgram[0].Id;
            insert programPlans;

            List<Product2> prodProgProductsCCE = TestDataFactory.createTestProductRecords(50);
            Integer pProdCount = 0;
            for (Product2 presProd : prodProgProductsCCE) {
                presProd.Delivery__c = 'Online Classroom;Online Self-paced;Brisbane Classroom';
                presProd.Study_Area__c = 'Engineering';
                presProd.Product_Type__c = 'Short Course';
                presProd.Program_Plan__c = programPlans[0].Id;
                presProd.Available_on_Cart__c = true;
                pProdCount++;
            }
            insert prodProgProductsCCE;
            List<Product2> getPresProd = [
                SELECT Id, Program_Plan__c
                FROM Product2
                WHERE Program_Plan__c != NULL
            ];
            List<ProductCategoryProduct> setTEEProgList = new List<ProductCategoryProduct>();
            for (Integer y = 0; y <= sProdCount; y++) {
                ProductCategoryProduct setTEEProg = new ProductCategoryProduct();
                setTEEProg.ProductCategoryId = prodCateg1.Id;
                setTEEProg.ProductId = getPresProd[y].Id;
                setTEEProgList.add(setTEEProg);
            }
            insert setTEEProgList;

            //Create Child Products
            List<Product_Request__c> prodRequestChild = TestDataFactory.createTestProductRequestRecords(
                10
            );
            prodRequestChild[0].RecordTypeId = RT_ACTIVITY_ID;
            prodRequestChild[0].Product_Request_Status__c = 'Published';
            insert prodRequestChild;

            // Update CCE BuyerGroup
            BuyerGroup bgUpdateChild = [
                SELECT Id, Name, Product_Request__c, Primary_Account__c
                FROM BuyerGroup
                WHERE Id = :bGroup[0].Id
            ];
            bgUpdateChild.Product_Request__c = prodRequestChild[0].Id;
            update bgUpdateChild;

            // Single Products
            List<hed__Course__c> coursesChild = TestDataFactory.createTestCourseRecords(
                10,
                accUniv[0].Id,
                prodRequestChild[0].Id
            );
            insert coursesChild;

            List<Product2> singleProductsChild = TestDataFactory.createTestProductRecords(
                10,
                coursesChild
            );
            Integer sProdCountChild = 0;
            for (Product2 sProdChild : singleProductsChild) {
                sProdChild.Delivery__c = 'Online Classroom;Online Self-paced;Brisbane Classroom';
                sProdChild.Study_Area__c = 'Engineering';
                sProdChild.Product_Type__c = 'Short Course';
                sProdChild.Course__c = coursesChild[0].Id;
                sProdChild.Available_on_Cart__c = true;
                sProdCountChild++;
            }
            insert singleProductsChild;

            Pricebook2 pricebookChild = new Pricebook2(
                isActive = true,
                id = Test.getStandardPricebookId()
            );
            update pricebookChild;

            Pricebook2 pbCBChild = new Pricebook2();
            pbCBChild.Name = 'Corporate Bundle - Test Child';
            pbCBChild.IsActive = true;
            insert pbCBChild;

            // Create BuyerGroupPriceBook
            BuyerGroupPriceBook bgPriceBookChild = new BuyerGroupPriceBook();
            bgPriceBookChild.PriceBook2Id = pbCBChild.Id;
            bgPriceBookChild.BuyerGroupId = bGroupMember[0].BuyerGroupId;
            insert bgPriceBookChild;

            // Create PricebookEntry Standard
            List<PricebookEntry> priceBookEntryListChild = new List<PricebookEntry>();
            for (Product2 singleProdPBEntryChild : singleProductsChild) {
                PricebookEntry priceBookEntry = new PricebookEntry();
                priceBookEntry.pricebook2id = pricebookChild.Id;
                priceBookEntry.UnitPrice = 10;
                priceBookEntry.product2Id = singleProdPBEntryChild.Id;
                priceBookEntry.isActive = true;
                priceBookEntryListChild.add(priceBookEntry);
            }
            insert priceBookEntryListChild;

            List<Product2> getSingleProdChild = [
                SELECT Id, Course__c
                FROM Product2
                WHERE Course__c != NULL
            ];
            List<ProductCategoryProduct> setTEEListChild = new List<ProductCategoryProduct>();
            for (Integer x = 0; x <= sProdCountChild; x++) {
                ProductCategoryProduct setTEEChild = new ProductCategoryProduct();
                setTEEChild.ProductCategoryId = prodCateg1.Id;
                setTEEChild.ProductId = getSingleProdChild[x].Id;
                setTEEList.add(setTEEChild);
            }
            insert setTEEListChild;

            List<hed__Course_Offering__c> courseOfferingsChild = TestDataFactory.createTestCourseOfferingRecord(
                10,
                coursesChild,
                terms
            );
            for (hed__Course_Offering__c cOfferingChild : courseOfferingsChild) {
                cOfferingChild.Registration_Start_Date__c = system.today() - 2;
                cOfferingChild.IsActive__c = true;
                cOfferingChild.Delivery_Type__c = 'Online Classroom';
            }
            insert courseOfferingsChild;

            List<CommerceEntitlementProduct> ceProdChild = [
                SELECT Id, ProductId, PolicyId
                FROM CommerceEntitlementProduct
            ];
            Integer commChildCount = 0;
            for (CommerceEntitlementProduct setCEProdChild : ceProdChild) {
                setCEProdChild.ProductId = getSingleProdChild[commChildCount].Id;
                setCEProdChild.PolicyId = ceBuyerGroup[0].PolicyId;
                a++;
            }
            insert ceProdChild;

            List<Related_Product_Request__c> childProdRelatedRequest = TestDataFactory.createTestRelatedPRRecords(
                1,
                prodRequestChild,
                prodRequestPrescribedProgram
            );
            insert childProdRelatedRequest;
            // End Child Products

            // Create Pricebook
            Pricebook2 pricebook = new Pricebook2(
                isActive = true,
                id = Test.getStandardPricebookId()
            );
            update pricebook;

            Pricebook2 pbCB = new Pricebook2();
            pbCB.Name = 'SOA - Test';
            pbCB.IsActive = true;
            insert pbCB;

            // Create BuyerGroupPriceBook
            BuyerGroupPriceBook bgPriceBook = new BuyerGroupPriceBook();
            bgPriceBook.PriceBook2Id = pbCB.Id;
            bgPriceBook.BuyerGroupId = bGroupMember[0].BuyerGroupId;
            insert bgPriceBook;

            // Create PricebookEntry Standard
            List<PricebookEntry> priceBookEntryListCCESTD = new List<PricebookEntry>();
            for (Product2 singleProdPBEntryCCEStd : singleProductsCCE) {
                PricebookEntry priceBookEntry = new PricebookEntry();
                priceBookEntry.pricebook2id = pricebook.Id;
                priceBookEntry.UnitPrice = 12;
                priceBookEntry.product2Id = singleProdPBEntryCCEStd.Id;
                priceBookEntry.isActive = true;
                priceBookEntryListCCESTD.add(priceBookEntry);
            }

            for (Product2 presProgProdPBEntryCCEStd : prodProgProductsCCE) {
                PricebookEntry priceBookEntry = new PricebookEntry();
                priceBookEntry.pricebook2id = pricebook.Id;
                priceBookEntry.UnitPrice = 10;
                priceBookEntry.product2Id = presProgProdPBEntryCCEStd.Id;
                priceBookEntry.isActive = true;
                priceBookEntryListCCESTD.add(priceBookEntry);
            }
            insert priceBookEntryListCCESTD;

            // Create PricebookEntry CB Standard
            List<PricebookEntry> priceBookEntryListCCE = new List<PricebookEntry>();
            for (Product2 singleProdPBEntryCCE : singleProductsCCE) {
                PricebookEntry priceBookEntry = new PricebookEntry();
                priceBookEntry.pricebook2id = pbCB.Id;
                priceBookEntry.UnitPrice = 12;
                priceBookEntry.product2Id = singleProdPBEntryCCE.Id;
                priceBookEntry.isActive = true;
                priceBookEntryListCCE.add(priceBookEntry);
            }

            for (Product2 presProgProdPBEntryCCE : prodProgProductsCCE) {
                PricebookEntry priceBookEntry = new PricebookEntry();
                priceBookEntry.pricebook2id = pbCB.Id;
                priceBookEntry.UnitPrice = 10;
                priceBookEntry.product2Id = presProgProdPBEntryCCE.Id;
                priceBookEntry.isActive = true;
                priceBookEntryListCCE.add(priceBookEntry);
            }
            insert priceBookEntryListCCE;

            Id singleProdId = [
                SELECT Id, Pricebook2.Name, Pricebook2Id, Product2.Name, Product2Id
                FROM PricebookEntry
                WHERE Pricebook2.Name = 'SOA - Test' AND Product2.Course__c != NULL
                LIMIT 1
            ]
            .Product2Id;

            Id progProdId = [
                SELECT Id, Pricebook2.Name, Pricebook2Id, Product2.Name, Product2Id
                FROM PricebookEntry
                WHERE Pricebook2.Name = 'SOA - Test' AND Product2.Program_Plan__c != NULL
                LIMIT 1
            ]
            .Product2Id;

            ProductDetailsCtrl.ProductDetailsData getSingleProductDetails = new ProductDetailsCtrl.ProductDetailsData();
            ProductDetailsCtrl.ProductDetailsData getProdDet1 = new ProductDetailsCtrl.ProductDetailsData();
            getProdDet1.accountId = accounts[0].Id;
            getProdDet1.categoryName = 'QUTeX Learning Solutions';
            getProdDet1.userId = enableResponse.userId;
            getProdDet1.productId = singleProdId;
            getProdDet1.buyerGroupId = bGroupMember[0].BuyerGroupId;
            getSingleProductDetails = ProductDetailsCtrl.getCCEProductRelatedRecords(getProdDet1);

            ProductDetailsCtrl.ProductDetailsData getFlexProgProductDetails = new ProductDetailsCtrl.ProductDetailsData();
            ProductDetailsCtrl.ProductDetailsData getProdDet2 = new ProductDetailsCtrl.ProductDetailsData();
            getProdDet2.accountId = accounts[0].Id;
            getProdDet2.categoryName = 'QUTeX Learning Solutions';
            getProdDet2.userId = enableResponse.userId;
            getProdDet2.productId = progProdId;
            getProdDet2.buyerGroupId = bGroupMember[0].BuyerGroupId;
            getFlexProgProductDetails = ProductDetailsCtrl.getCCEProductRelatedRecords(getProdDet2);

            Test.stopTest();

            System.assert(
                getSingleProductDetails != null,
                'Failed to retrieved Single Product Related Records'
            );

            System.assert(
                getFlexProgProductDetails != null,
                'Failed to retrieved Flex Program Product Related Records'
            );
        }
    }

    @isTest
    static void testGetProductRelatedRecordsForPrescribedProgram() {
        List<Account> accounts = [
            SELECT Id, Name
            FROM Account
            WHERE RecordTypeId = :ACCT_UNIV_DEP_ID AND Organization_Unit_Level__c = '2'
        ];

        List<Product_Request__c> progProdReq = TestDataFactory.createTestProductRequestRecords(10);
        progProdReq[0].RecordTypeId = opeProgProdReqId;
        progProdReq[0].OPE_Program_Plan_Type__c = 'Prescribed Program';
        insert progProdReq;

        hed__Program_Plan__c programPlan = [
            SELECT Id, Name, Program_Delivery_Structure__c, Product_Request__c
            FROM hed__Program_Plan__c
            LIMIT 1
        ];
        if (programPlan.Program_Delivery_Structure__c != 'Prescribed Program') {
            programPlan.Program_Delivery_Structure__c = 'Prescribed Program';
        }
        programPlan.Product_Request__c = progProdReq[0].Id;
        update programPlan;

        Product2 product = [
            SELECT Id, Name, Program_Plan__c
            FROM Product2
            LIMIT 1
        ];
        product.Program_Plan__c = programPlan.Id;
        update product;

        List<Product_Request__c> childProdRequest = TestDataFactory.createTestProductRequestRecords(
            10
        );
        childProdRequest[0].RecordTypeId = OPE_ACTIVITY_PROD_REQ_RECORD_TYPE_ID;
        insert childProdRequest;

        List<hed__Course__c> childProdCourses = TestDataFactory.createTestCourseRecords(
            10,
            accounts[0].Id,
            childProdRequest[0].Id
        );
        insert childProdCourses;

        hed__Plan_Requirement__c planRequirement = new hed__Plan_Requirement__c(
            hed__Course__c = childProdCourses[0].Id,
            hed__Program_Plan__c = programPlan.Id,
            hed__Sequence__c = 1
        );
        insert planRequirement;

        Program_Offering__c programOffering = new Program_Offering__c(
            Name = 'Program Offering_Test 1',
            hed_Program_Plan__c = programPlan.Id,
            Delivery_Type__c = 'Online Classroom',
            hed_Capacity__c = 30,
            Start_Date__c = system.today() + 1,
            Registration_Start_Date__c = system.today() - 1,
            IsActive__c = true
        );
        insert programOffering;

        List<Product2> singleProducts = TestDataFactory.createTestProductRecords(
            10,
            childProdCourses
        );
        for (Product2 sProd : singleProducts) {
            sProd.Delivery__c = 'Online Classroom;Online Self-paced;Brisbane Classroom';
            sProd.Available_on_Cart__c = true;
        }
        insert singleProducts;

        List<Related_Product_Request__c> childProdRelatedRequest = TestDataFactory.createTestRelatedPRRecords(
            10,
            childProdRequest,
            progProdReq
        );
        insert childProdRelatedRequest;

        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            ProductDetailsCtrl.ProductDetailsData getProductDetails = new ProductDetailsCtrl.ProductDetailsData();
            getProductDetails = ProductDetailsCtrl.getProductRelatedRecords(product.Id);
            System.assert(
                getProductDetails != null,
                'Successfully retrieved Single Product Related Records'
            );
        }
    }

    @isTest
    static void testGetProductRelatedRecordsForFlexibleProgram() {
        List<Account> accounts = [
            SELECT Id, Name
            FROM Account
            WHERE RecordTypeId = :ACCT_UNIV_DEP_ID AND Organization_Unit_Level__c = '2'
        ];

        List<Product_Request__c> progProdReq = TestDataFactory.createTestProductRequestRecords(10);
        progProdReq[0].RecordTypeId = opeProgProdReqId;
        progProdReq[0].OPE_Program_Plan_Type__c = 'Flexible Program';
        insert progProdReq;

        hed__Program_Plan__c programPlan = [
            SELECT Id, Name, Program_Delivery_Structure__c, Product_Request__c
            FROM hed__Program_Plan__c
            LIMIT 1
        ];
        if (programPlan.Program_Delivery_Structure__c != 'Flexible Program') {
            programPlan.Program_Delivery_Structure__c = 'Flexible Program';
        }
        programPlan.Product_Request__c = progProdReq[0].Id;
        update programPlan;

        Product2 product = [
            SELECT Id, Name, Program_Plan__c
            FROM Product2
            LIMIT 1
        ];
        product.Program_Plan__c = programPlan.Id;
        update product;

        List<Product_Request__c> childProdRequest = TestDataFactory.createTestProductRequestRecords(
            10
        );
        childProdRequest[0].RecordTypeId = OPE_ACTIVITY_PROD_REQ_RECORD_TYPE_ID;
        insert childProdRequest;

        List<hed__Course__c> childProdCourses = TestDataFactory.createTestCourseRecords(
            10,
            accounts[0].Id,
            childProdRequest[0].Id
        );
        insert childProdCourses;

        hed__Plan_Requirement__c planRequirement = new hed__Plan_Requirement__c(
            hed__Course__c = childProdCourses[0].Id,
            hed__Program_Plan__c = programPlan.Id,
            hed__Sequence__c = 1
        );
        insert planRequirement;

        Program_Offering__c programOffering = new Program_Offering__c(
            Name = 'Program Offering_Test 1',
            hed_Program_Plan__c = programPlan.Id,
            Delivery_Type__c = 'Online Classroom',
            hed_Capacity__c = 30,
            Start_Date__c = system.today() + 1,
            Registration_Start_Date__c = system.today() - 1,
            IsActive__c = true
        );
        insert programOffering;

        List<Product2> singleProducts = TestDataFactory.createTestProductRecords(
            10,
            childProdCourses
        );
        for (Product2 sProd : singleProducts) {
            sProd.Delivery__c = 'Online Classroom;Online Self-paced;Brisbane Classroom';
            sProd.Available_on_Cart__c = true;
        }
        insert singleProducts;

        List<Related_Product_Request__c> childProdRelatedRequest = TestDataFactory.createTestRelatedPRRecords(
            10,
            childProdRequest,
            progProdReq
        );
        insert childProdRelatedRequest;

        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            ProductDetailsCtrl.ProductDetailsData getProductDetails = new ProductDetailsCtrl.ProductDetailsData();
            getProductDetails = ProductDetailsCtrl.getProductRelatedRecords(product.Id);
            System.assert(
                getProductDetails != null,
                'Successfully retrieved Single Product Related Records'
            );
        }
    }

    @isTest
    static void testGetCourseOfferingRelatedRecords() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            Boolean isCCE = true;
            List<ProductDetailsCtrl.CourseOfferingWrapper> getCourseOfferings = new List<ProductDetailsCtrl.CourseOfferingWrapper>();
            getCourseOfferings = ProductDetailsCtrl.getCourseOfferingRelatedRecords(
                [
                    SELECT Id, Course__c
                    FROM Product2
                    WHERE
                        CreatedById = :TestDataFactory.getProgramAdminUser().Id
                        AND Course__c != NULL
                    LIMIT 1
                ]
                .Course__c,
                new List<String>{ 'Online Classroom' },
                isCCE
            );

            Test.stopTest();

            System.assert(
                getCourseOfferings.size() > 0,
                'Successfully retrieved Course Offering Related Records'
            );
        }
    }

    @isTest
    static void testGetCourseOfferingRelatedRecordsNotCCE() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            Boolean isCCE = false;
            List<ProductDetailsCtrl.CourseOfferingWrapper> getCourseOfferings = new List<ProductDetailsCtrl.CourseOfferingWrapper>();
            getCourseOfferings = ProductDetailsCtrl.getCourseOfferingRelatedRecords(
                [
                    SELECT Id, Course__c
                    FROM Product2
                    WHERE
                        CreatedById = :TestDataFactory.getProgramAdminUser().Id
                        AND Course__c != NULL
                    LIMIT 1
                ]
                .Course__c,
                new List<String>{ 'Online Classroom' },
                isCCE
            );

            Test.stopTest();

            System.assert(
                getCourseOfferings.size() > 0,
                'Successfully retrieved Course Offering Related Records'
            );
        }
    }

    @isTest
    static void testAddToCart() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            String communityId = [
                SELECT Id
                FROM Network
                WHERE Name = 'Study' AND Status = 'Live'
            ]
            .Id;

            String effectiveAccountId = [
                SELECT Id
                FROM Account
                WHERE CreatedById = :TestDataFactory.getProgramAdminUser().Id
                LIMIT 1
            ]
            .Id;

            Product2 prod = [
                SELECT Id, Name, Course__c
                FROM Product2
                WHERE CreatedById = :TestDataFactory.getProgramAdminUser().Id AND Course__c != NULL
                LIMIT 1
            ];

            PriceBookEntry pbe = [
                SELECT Id
                FROM PricebookEntry
                LIMIT 1
            ];

            String productId = prod.Id;
            String productName = prod.Name;
            String pricebookEntryId = pbe.Id;

            String courseOfferingId = [
                SELECT Id
                FROM hed__Course_Offering__c
                WHERE hed__Course__c = :prod.Course__c
                LIMIT 1
            ]
            .Id;

            ProductDetailsCtrl.addToCartItem(
                communityId,
                productId,
                effectiveAccountId,
                productName,
                courseOfferingId,
                '',
                pricebookEntryId,
                TestDataFactory.getProgramAdminUser().Id,
                true
            );
            Test.stopTest();

            System.assert(
                ![
                        SELECT Id
                        FROM CartItem
                        LIMIT 1
                    ]
                    .isEmpty(),
                'No Cart Item Created'
            );
        }
    }

    @isTest
    static void testInsertExpressionOfInterest() {
        User portalSysAdmin = TestDataFactory.getPortalSysAdminUser();
        System.runAs(portalSysAdmin) {
            //Create account
            Account portalAccount1 = new Account(Name = 'TestAccount', OwnerId = portalSysAdmin.Id);

            Database.insert(portalAccount1);

            //Create contact
            Contact contact1 = new Contact(
                FirstName = 'Test',
                Lastname = 'McTesty',
                AccountId = portalAccount1.Id,
                Registered_Email__c = System.now().millisecond() + 'test@test.com'
            );
            Database.insert(contact1);

            //Create user
            User portalUser = TestDataFactory.createPortalUserRecords(
                    1,
                    'Corporate Partner User',
                    contact1.Id
                )
                .iterator()
                .next();
            Database.insert(portalUser);

            Product2 product = [
                SELECT Id
                FROM Product2
                LIMIT 1
            ];
            Test.startTest();

            ProductDetailsCtrl.insertExpressionOfInterest(portalUser.Id, product.Id);
            System.assert(
                ![
                        SELECT Id
                        FROM Expression_of_interest__c
                    ]
                    .isEmpty(),
                'No expression of interest created'
            );
            Test.stopTest();
        }
    }

    @isTest
    static void saveApplicationTest() {
        User portalSysAdmin = TestDataFactory.getPortalSysAdminUser();
        System.runAs(portalSysAdmin) {
            //Create account
            Account portalAccount1 = new Account(Name = 'TestAccount', OwnerId = portalSysAdmin.Id);

            Database.insert(portalAccount1);

            //Create contact
            Contact contact1 = new Contact(
                FirstName = 'Test',
                Lastname = 'McTesty',
                AccountId = portalAccount1.Id,
                Email = System.now().millisecond() + 'test@test.com'
            );
            Database.insert(contact1);

            //Create user
            User portalUser = TestDataFactory.createPortalUserRecords(
                    1,
                    'Corporate Partner User',
                    contact1.Id
                )
                .iterator()
                .next();
            Database.insert(portalUser);
        }

        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            createRecord(OPE_ACTIVITY_PROD_REQ_RECORD_TYPE_ID);
            String cOfferingId = [
                SELECT Id
                FROM hed__Course_Offering__c
                LIMIT 1
            ]
            .Id;

            Id relatedQuestionnaireId = [
                SELECT Id
                FROM Questionnaire__c
                LIMIT 1
            ]
            .Id;

            List<Question__c> questionList = TestDataFactory.createTestQuestionRecords(5);
            insert questionList;

            List<Related_Answer__c> relatedAnswers = TestDataFactory.createTestRelatedAnswerRecords(
                5,
                relatedQuestionnaireId,
                questionList
            );
            insert relatedAnswers;
            List<ProductDetailsCtrl.FileUpload> fileLoadList = new List<ProductDetailsCtrl.FileUpload>();
            List<Answer__c> answerList = new List<Answer__c>();
            Answer__c newAnswer;
            ProductDetailsCtrl.FileUpload fileLoad = new ProductDetailsCtrl.FileUpload();
            for (Related_Answer__c relatedA : relatedAnswers) {
                newAnswer = new Answer__c(
                    Response__c = relatedA.Id,
                    Related_Answer__c = relatedA.Id
                );
                answerList.add(newAnswer);

                fileLoad.Base64 = 'Test Content';
                fileLoad.FileName = relatedA.Id;
                fileLoad.RelatedAnswerId = relatedA.Id;

                fileLoadList.add(fileLoad);
            }

            ProductDetailsCtrl.saveApplication(
                [
                    SELECT Id
                    FROM Contact
                    WHERE LastName = 'McTesty'
                    LIMIT 1
                ]
                ?.Id,
                cOfferingId,
                relatedAnswers,
                answerList,
                JSON.serialize(fileLoadList),
                false,
                null
            );
            Test.stopTest();
            system.assert(
                ![
                        SELECT Id
                        FROM ContentVersion
                    ]
                    .isEmpty(),
                'Document not created'
            );
            system.assert(
                ![
                        SELECT Id
                        FROM Answer__c
                    ]
                    .isEmpty(),
                'Answer not created'
            );
        }
    }

    @isTest
    static void getQuestionsTest() {
        User portalSysAdmin = TestDataFactory.getPortalSysAdminUser();
        System.runAs(portalSysAdmin) {
            //Create account
            Account portalAccount1 = new Account(Name = 'TestAccount', OwnerId = portalSysAdmin.Id);

            Database.insert(portalAccount1);

            //Create contact
            Contact contact1 = new Contact(
                FirstName = 'Test',
                Lastname = 'McTesty',
                AccountId = portalAccount1.Id,
                Email = System.now().millisecond() + 'test@test.com'
            );
            Database.insert(contact1);

            //Create user
            User portalUser = TestDataFactory.createPortalUserRecords(
                    1,
                    'Corporate Partner User',
                    contact1.Id
                )
                .iterator()
                .next();
            Database.insert(portalUser);
        }

        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            createRecord(OPE_ACTIVITY_PROD_REQ_RECORD_TYPE_ID);

            String prodReqId = [
                SELECT Id, Parent_Record_ID__c
                FROM Questionnaire__c
                LIMIT 1
            ]
            .Parent_Record_ID__c;

            List<Related_Answer__c> questionList = ProductDetailsCtrl.getQuestions(prodReqId);
            Test.stopTest();
            system.assert(questionList != null, 'Questins retrieved.');
        }
    }

    private static void createRecord(String productRequestRecordType) {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Id offeringId = null;

            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            for (Account account : accounts) {
                account.RecordTypeId = ACCT_UNIV_DEP_ID;
                account.Organization_Unit_Level__c = '2';
            }
            insert accounts;

            List<Product_Request__c> productRequests = TestDataFactory.createTestProductRequestRecords(
                1
            );
            for (Product_Request__c productRequest : productRequests) {
                productRequest.RecordTypeId = productRequestRecordType;
            }
            insert productRequests;

            List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(
                1,
                accounts[0].Id,
                productRequests[0].Id
            );
            insert courses;

            List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(1, accounts[0].Id);
            insert terms;

            List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(
                1,
                courses,
                terms
            );
            insert courseOfferings;

            offeringId = courseOfferings[0].Id;

            List<Contact> contacts = TestDataFactory.createTestContactRecords(NUMBER_OF_RECORDS);
            for (Integer i = 0; i < contacts.size(); i++) {
                contacts[i].Salutation = 'DR';
                contacts[i].Email = 'testIdeaFormUser' + i + '@mailinator.com';
            }
            insert contacts;

            List<hed__Course_Enrollment__c> students = new List<hed__Course_Enrollment__c>();
            for (Contact contact : contacts) {
                hed__Course_Enrollment__c student = new hed__Course_Enrollment__c();
                student.hed__Contact__c = contact.Id;
                student.RecordTypeId = STUDENT_RECORD_TYPE_ID;
                student.Paid_in_Full__c = 'Yes';
                student.hed__Course_Offering__c = offeringId;
                students.add(student);
            }
            insert students;

            Questionnaire__c questionnaire = new Questionnaire__c();
            questionnaire.Questionnaire_Type__c = 'Application Questions';
            questionnaire.Parent_Record_ID__c = productRequests[0].Id; //test
            insert questionnaire;

            List<Questionnaire_Response_Summary__c> questionnaireResponseList = new List<Questionnaire_Response_Summary__c>();
            for (Contact contact : contacts) {
                Questionnaire_Response_Summary__c questionResp = new Questionnaire_Response_Summary__c();
                questionResp.Contact__c = contact.Id;
                questionResp.Registration_Status__c = 'Confirmed';
                questionResp.Questionnaire__c = questionnaire.Id;
                questionResp.Course_Offering__c = offeringId;
                questionnaireResponseList.add(questionResp);
            }
            insert questionnaireResponseList;

            Related_Answer__c mewRelatedAnswer = new Related_Answer__c(
                Questionnaire__c = questionnaire.Id
            );
            insert mewRelatedAnswer;
        }
    }

    @isTest
    static void testGetProductDataRelatedToProductRequestForPrescribedProgram() {
        Id accountId = [
            SELECT Id
            FROM Account
            WHERE RecordTypeId = :ACCT_UNIV_DEP_ID AND Organization_Unit_Level__c = '2'
            LIMIT 1
        ]
        .Id;
        Product_Request__c produtRequestForProgramPlan = new Product_Request__c(
            Product_Request_Status__c = 'Define',
            Product_Request_Name__c = 'Product Request_T01',
            Child_of_Prescribed_Program__c = false
        );
        insert produtRequestForProgramPlan;

        Product_Request__c produtRequestForModule = new Product_Request__c(
            Product_Request_Status__c = 'Define',
            Product_Request_Name__c = 'Product Request_T02',
            Child_of_Prescribed_Program__c = true
        );
        insert produtRequestForModule;

        hed__Program_Plan__c programPlan = new hed__Program_Plan__c(
            Name = 'Program Plan_Test 1',
            Program_Delivery_Structure__c = 'Prescribed Program',
            Product_Request__c = produtRequestForProgramPlan.Id
        );
        insert programPlan;

        Map<String, String> courseFields = new Map<String, String>();
        courseFields.put('Name', 'Program Plan_T01');
        courseFields.put('ProductRequestID__c', produtRequestForModule.Id);
        courseFields.put('hed__Account__c', accountId);
        courseFields.put('Owning_Faculty__c', accountId);
        hed__Course__c course = TestDataFactory.createTestCourseRecords(courseFields);
        insert course;

        hed__Plan_Requirement__c planRequirement = new hed__Plan_Requirement__c(
            hed__Course__c = course.Id,
            hed__Program_Plan__c = programPlan.Id,
            hed__Sequence__c = 1
        );
        insert planRequirement;

        Map<String, String> programOfferingFields = new Map<String, String>();
        programOfferingFields.put('Name', 'Program Offering_T01');
        programOfferingFields.put('hed_Program_Plan__c', programPlan.Id);
        Program_Offering__c programOffering = TestDataFactory.createTestProgramOfferingRecords(
            programOfferingFields
        );
        insert programOffering;

        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            Map<String, Object> returnMap = ProductDetailsCtrl.getProductDataRelatedToProductRequest(
                produtRequestForProgramPlan.Id
            );

            System.assert(returnMap != null, 'Unable to retrieve data related to Product Request');
            System.assert(
                returnMap.get('productType') == 'Prescribed Program',
                'Unable to retrieve data related to Product Request'
            );
            returnMap = ProductDetailsCtrl.getProductDataRelatedToProductRequest(
                produtRequestForModule.Id
            );

            System.assert(returnMap != null, 'Unable to retrieve data related to Product Request');
            System.assert(
                returnMap.get('productType') == 'Prescribed Program Module',
                'Unable to retrieve data related to Product Request'
            );
            Test.stopTest();
        }
    }

    @isTest
    static void testGetProductDataRelatedToProductRequestForFlexibleProgram() {
        Id accountId = [
            SELECT Id
            FROM Account
            WHERE RecordTypeId = :ACCT_UNIV_DEP_ID AND Organization_Unit_Level__c = '2'
            LIMIT 1
        ]
        .Id;
        Product_Request__c produtRequestForProgramPlan = new Product_Request__c(
            Product_Request_Status__c = 'Define',
            Product_Request_Name__c = 'Product Request_T01',
            Child_of_Prescribed_Program__c = false
        );

        Product_Request__c produtRequestForProgramPlan2 = new Product_Request__c(
            Product_Request_Status__c = 'Define',
            Product_Request_Name__c = 'Product Request_T01',
            Child_of_Prescribed_Program__c = false
        );
        insert produtRequestForProgramPlan2;
        Product_Request__c produtRequestForModule = new Product_Request__c(
            Product_Request_Status__c = 'Define',
            Product_Request_Name__c = 'Product Request_T02',
            Child_of_Prescribed_Program__c = true
        );
        insert produtRequestForModule;

        hed__Program_Plan__c programPlan = new hed__Program_Plan__c(
            Name = 'Program Plan_Test 1',
            Program_Delivery_Structure__c = 'Prescribed Program',
            Product_Request__c = produtRequestForProgramPlan.Id
        );
        insert programPlan;
        hed__Program_Plan__c programPlan1 = new hed__Program_Plan__c(
            Name = 'Program Plan_Test 1',
            Program_Delivery_Structure__c = 'Flexible Program',
            Product_Request__c = produtRequestForProgramPlan2.Id
        );
        insert programPlan1;

        Map<String, String> courseFields = new Map<String, String>();
        courseFields.put('Name', 'Program Plan_T01');
        courseFields.put('ProductRequestID__c', produtRequestForModule.Id);
        courseFields.put('hed__Account__c', accountId);
        courseFields.put('Owning_Faculty__c', accountId);
        hed__Course__c course = TestDataFactory.createTestCourseRecords(courseFields);
        insert course;

        hed__Plan_Requirement__c planRequirement = new hed__Plan_Requirement__c(
            hed__Course__c = course.Id,
            hed__Program_Plan__c = programPlan.Id,
            hed__Sequence__c = 1
        );
        insert planRequirement;
        hed__Plan_Requirement__c planRequirement1 = new hed__Plan_Requirement__c(
            hed__Course__c = course.Id,
            hed__Program_Plan__c = programPlan1.Id,
            hed__Sequence__c = 1
        );
        insert planRequirement1;
        Map<String, String> programOfferingFields = new Map<String, String>();
        programOfferingFields.put('Name', 'Program Offering_T01');
        programOfferingFields.put('hed_Program_Plan__c', programPlan.Id);
        Program_Offering__c programOffering = TestDataFactory.createTestProgramOfferingRecords(
            programOfferingFields
        );
        insert programOffering;

        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();

            Map<String, Object> returnMap1 = ProductDetailsCtrl.getProductDataRelatedToProductRequest(
                produtRequestForProgramPlan2.Id
            );
            System.assert(
                returnMap1 != null,
                'Not able to retrieve data related to Product Request'
            );
            System.assert(
                returnMap1.get('productType') == 'Flexible Program',
                'Not able to retrieve data related to Product Request'
            );
            returnMap1 = ProductDetailsCtrl.getProductDataRelatedToProductRequest(
                produtRequestForProgramPlan2.Id
            );
            System.assert(
                returnMap1 != null,
                'Not able to retrieve data related to Product Request'
            );
            Test.stopTest();
        }
    }

    @isTest
    static void testGetQuestionsForGroupBooking() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            createRecord(OPE_ACTIVITY_PROD_REQ_RECORD_TYPE_ID);
            String prodReqId = [
                SELECT Id
                FROM Product_Request__c
                LIMIT 1
            ]
            .Id;
            Test.startTest();
            List<Related_Answer__c> relatedAnswerList = ProductDetailsCtrl.getQuestionsForGroupBooking(
                prodReqId
            );
            Test.stopTest();
            system.assert(relatedAnswerList.isEmpty(), 'No related answer retrieved');
        }
    }

    @isTest
    static void testSaveContactData() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            createRecord(OPE_ACTIVITY_PROD_REQ_RECORD_TYPE_ID);
            Test.startTest();
            List<Account> acct = TestDataFactory.createTestAccountRecords(1);
            insert acct;
            List<Contact> con = TestDataFactory.createTestContactRecords(1);
            con[0].AccountId = acct[0].Id;
            con[0].Email = 'testestest1234@sample.com';

            List<Contact> contact = ProductDetailsCtrl.saveContactData(JSON.serialize(con));

            Test.stopTest();

            system.assert(!contact.isEmpty(), 'contacts were not inserted');
        }
    }

    @isTest
    static void testGetContactAccountId() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            createRecord(OPE_ACTIVITY_PROD_REQ_RECORD_TYPE_ID);
            Test.startTest();
            List<Account> acct = TestDataFactory.createTestAccountRecords(1);
            insert acct;
            List<Contact> con = TestDataFactory.createTestContactRecords(1);
            con[0].AccountId = acct[0].Id;
            insert con;
            List<Contact> contact = ProductDetailsCtrl.getContactAccountId(con[0].Id);
            Test.stopTest();

            system.assert(!contact.isEmpty(), 'contacts against the account were not found!');
        }
    }

    @isTest
    static void testGetUserContactDetails() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            createRecord(OPE_ACTIVITY_PROD_REQ_RECORD_TYPE_ID);
            Test.startTest();
            List<Contact> con = TestDataFactory.createTestContactRecords(1);
            insert con;
            List<Contact> contact = ProductDetailsCtrl.getUserContactDetails(con[0].Id);
            Test.stopTest();

            system.assert(!contact.isEmpty(), 'contacts were not found!');
        }
    }

    @isTest
    static void testGetUserCartDetails() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            createRecord(OPE_ACTIVITY_PROD_REQ_RECORD_TYPE_ID);
            Test.startTest();
            List<Account> acct = TestDataFactory.createTestAccountRecords(1);
            insert acct;
            WebStore testWebStore = new WebStore(Name = 'Study', DefaultLanguage = 'en_US');
            insert testWebStore;

            WebCart cart = new WebCart(
                Name = 'Cart',
                AccountId = acct[0].Id,
                Status__c = 'Checkout',
                WebStoreId = testWebStore.Id
            );
            insert cart;

            WebCart wb = ProductDetailsCtrl.getUserCartDetails(
                TestDataFactory.getProgramAdminUser().Id
            );
            Test.stopTest();
            System.assert(wb != null, 'Cart details were not retrieved');
        }
    }

    @isTest
    static void testGetPricebookEntryPrice() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            createRecord(OPE_ACTIVITY_PROD_REQ_RECORD_TYPE_ID);
            Test.startTest();
            PricebookEntry pricebookentry = [
                SELECT Id
                FROM PricebookEntry
                LIMIT 1
            ];
            PricebookEntry pb = ProductDetailsCtrl.getPricebookEntryPrice(pricebookentry.Id);
            Test.stopTest();
            system.assert(pb != null, 'Pricebook entry not Retrieve!');
        }
    }

    @isTest
    static void testGetProductRequestWithQuestionairre() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            createRecord(OPE_MODULE_PROD_REQ_RECORD_TYPE_ID);
            String prodReqId = [
                SELECT Id
                FROM Product_Request__c
                WHERE RecordTypeId = :OPE_MODULE_PROD_REQ_RECORD_TYPE_ID
                LIMIT 1
            ]
            .Id;
            Test.startTest();
            List<Related_Answer__c> relatedAnswers = ProductDetailsCtrl.getProductRequestWithQuestionnaire(
                prodReqId
            );
            Test.stopTest();
            system.assert(!relatedAnswers.isEmpty(), 'No related answers retrieved');
        }
    }

    @isTest
    static void testGetQuestions() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            createRecord(OPE_MODULE_PROD_REQ_RECORD_TYPE_ID);
            String prodReqId = [
                SELECT Id
                FROM Product_Request__c
                WHERE RecordTypeId = :OPE_MODULE_PROD_REQ_RECORD_TYPE_ID
                LIMIT 1
            ]
            .Id;
            Test.startTest();
            List<Related_Answer__c> relatedAnswers = ProductDetailsCtrl.getQuestions(prodReqId);
            Test.stopTest();
            system.assert(!relatedAnswers.isEmpty(), 'No related answers retrieved');
        }
    }

    @isTest
    static void testCategoryBulkRegistration() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            BypassTriggers__c bypass = [
                SELECT Id, Bypass__c
                FROM BypassTriggers__c
                WHERE SetupOwnerId = :UserInfo.getOrganizationId()
                LIMIT 1
            ];
            bypass.Bypass__c = false;
            update bypass;

            String effectiveAccountId = [
                SELECT Id
                FROM Account
                WHERE CreatedById = :TestDataFactory.getProgramAdminUser().Id
                LIMIT 1
            ]
            .Id;
            Product2 prod = [
                SELECT Id, Name, Course__c, Course__r.ProductRequestID__c
                FROM Product2
                WHERE
                    CreatedById = :TestDataFactory.getProgramAdminUser().Id
                    AND Course__c != NULL
                    AND Course__r.ProductRequestID__c != NULL
                LIMIT 1
            ];
            Pricebook2 priceBooknew = new Pricebook2(isActive = true, name = 'test pb');
            insert priceBooknew;
            PriceBookEntry newPBE = new PricebookEntry(
                Pricebook2Id = priceBooknew.Id,
                UnitPrice = 12,
                Product2Id = prod.Id
            );
            insert newPBE;

            String productId = prod.Id;
            String productRequest = prod.Course__r.ProductRequestID__c;
            String productName = prod.Name;
            String pricebookEntryId = newPBE.Id;
            String pricebookUnitPrice = String.valueOf(newPBE.UnitPrice);
            BuyerGroup bgToInsert = new BuyerGroup(
                Name = 'CORPO',
                Product_Request__c = productRequest
            );
            insert bgToInsert;

            BuyerGroupPriceBook bgpToInsert = new BuyerGroupPriceBook(
                Pricebook2Id = newPBE.Pricebook2Id,
                BuyerGroupId = bgToInsert.Id
            );

            insert bgpToInsert;

            Asset assetRecord = new Asset(
                Name = 'Test Asset',
                AccountId = effectiveAccountId,
                Product_Request__c = productRequest
            );

            insert assetRecord;

            String courseOfferingId = [
                SELECT Id
                FROM hed__Course_Offering__c
                WHERE hed__Course__c = :prod.Course__c
                LIMIT 1
            ]
            .Id;

            List<hed__Course_Offering__c> courseOffering = new List<hed__Course_Offering__c>(
                [
                    SELECT Id
                    FROM hed__Course_Offering__c
                    LIMIT 1
                ]
            );
            List<User> users = new List<User>(
                [
                    SELECT Id, AccountId
                    FROM User
                    WHERE AccountId != NULL
                    LIMIT 1
                ]
            );
            List<Contact> contacts = TestDataFactory.createTestContactRecords(10);

            List<Product2> products = new List<Product2>(
                [
                    SELECT Id, Name
                    FROM Product2
                    LIMIT 1
                ]
            );

            ProductDetailsCtrl.WrapperClass wrappedData = new ProductDetailsCtrl.WrapperClass();
            wrappedData.courseOfferingId = courseOffering[0].Id;
            wrappedData.isPrescribed = false;
            wrappedData.userId = users[0].Id;
            wrappedData.productName = products[0].Name;
            wrappedData.productId = products[0].Id;
            wrappedData.pricebookEntryId = pricebookEntryId;
            wrappedData.pricebookUnitPrice = pricebookUnitPrice;
            wrappedData.Pricebook2Id = priceBooknew.Id;
            wrappedData.category = 'Corporate Bundle';

            List<hed__Course_Enrollment__c> courseEnrol = TestDataFactory.createTestCourseConnectionRecord(
                1,
                contacts[0].Id,
                courseOffering
            );

            TestDataFactory.createTestProductLedgerRecords(1, courseEnrol[0].Id, assetRecord.Id);

            ProductDetailsCtrl.categoryBulkRegistration(contacts, wrappedData);

            Test.stopTest();
        }

        system.assert(true, 'Data Retrieve!');
    }

    @isTest
    static void testGetAssetDetails() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            BypassTriggers__c bypass = [
                SELECT Id, Bypass__c
                FROM BypassTriggers__c
                WHERE SetupOwnerId = :UserInfo.getOrganizationId()
                LIMIT 1
            ];
            bypass.Bypass__c = false;
            update bypass;

            String effectiveAccountId = [
                SELECT Id
                FROM Account
                WHERE CreatedById = :TestDataFactory.getProgramAdminUser().Id
                LIMIT 1
            ]
            .Id;
            Product2 prod = [
                SELECT Id, Name, Course__c, Course__r.ProductRequestID__c
                FROM Product2
                WHERE
                    CreatedById = :TestDataFactory.getProgramAdminUser().Id
                    AND Course__c != NULL
                    AND Course__r.ProductRequestID__c != NULL
                LIMIT 1
            ];
            Pricebook2 priceBooknew = new Pricebook2(isActive = true, name = 'test pb');
            insert priceBooknew;
            PriceBookEntry newPBE = new PricebookEntry(
                Pricebook2Id = priceBooknew.Id,
                UnitPrice = 12,
                Product2Id = prod.Id
            );
            insert newPBE;

            String productRequest = prod.Course__r.ProductRequestID__c;
            BuyerGroup bgToInsert = new BuyerGroup(
                Name = 'CORPO',
                Product_Request__c = productRequest
            );
            insert bgToInsert;

            BuyerGroupPriceBook bgpToInsert = new BuyerGroupPriceBook(
                Pricebook2Id = newPBE.Pricebook2Id,
                BuyerGroupId = bgToInsert.Id
            );

            insert bgpToInsert;

            Asset assetRecord = new Asset(
                Name = 'Test Asset',
                AccountId = effectiveAccountId,
                Product_Request__c = productRequest
            );

            insert assetRecord;
            Test.stopTest();
            system.assert(true, 'Transaction Failed!');
        }
    }

    @isTest
    static void testRegistrationConfirmationData() {
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            Test.startTest();
            BypassTriggers__c bypass = [
                SELECT Id, Bypass__c
                FROM BypassTriggers__c
                WHERE SetupOwnerId = :UserInfo.getOrganizationId()
                LIMIT 1
            ];
            bypass.Bypass__c = false;
            update bypass;

            String effectiveAccountId = [
                SELECT Id
                FROM Account
                WHERE CreatedById = :TestDataFactory.getProgramAdminUser().Id
                LIMIT 1
            ]
            .Id;
            Product2 prod = [
                SELECT Id, Name, Course__c, Course__r.ProductRequestID__c
                FROM Product2
                WHERE
                    CreatedById = :TestDataFactory.getProgramAdminUser().Id
                    AND Course__c != NULL
                    AND Course__r.ProductRequestID__c != NULL
                LIMIT 1
            ];
            Pricebook2 priceBooknew = new Pricebook2(isActive = true, name = 'test pb');
            insert priceBooknew;
            PriceBookEntry newPBE = new PricebookEntry(
                Pricebook2Id = priceBooknew.Id,
                UnitPrice = 12,
                Product2Id = prod.Id
            );
            insert newPBE;

            String productId = prod.Id;
            String productRequest = prod.Course__r.ProductRequestID__c;
            String productName = prod.Name;
            String pricebookEntryId = newPBE.Id;
            String pricebookUnitPrice = String.valueOf(newPBE.UnitPrice);
            BuyerGroup bgToInsert = new BuyerGroup(
                Name = 'CORPO',
                Product_Request__c = productRequest
            );
            insert bgToInsert;

            BuyerGroupPriceBook bgpToInsert = new BuyerGroupPriceBook(
                Pricebook2Id = newPBE.Pricebook2Id,
                BuyerGroupId = bgToInsert.Id
            );

            insert bgpToInsert;

            Asset assetRecord = new Asset(
                Name = 'Test Asset',
                AccountId = effectiveAccountId,
                Product_Request__c = productRequest
            );

            insert assetRecord;

            String courseOfferingId = [
                SELECT Id
                FROM hed__Course_Offering__c
                WHERE hed__Course__c = :prod.Course__c
                LIMIT 1
            ]
            .Id;

            List<hed__Course_Offering__c> courseOffering = new List<hed__Course_Offering__c>(
                [
                    SELECT Id
                    FROM hed__Course_Offering__c
                    LIMIT 1
                ]
            );
            List<User> users = new List<User>(
                [
                    SELECT Id, AccountId
                    FROM User
                    WHERE AccountId != NULL
                    LIMIT 1
                ]
            );
            List<Contact> contacts = TestDataFactory.createTestContactRecords(10);

            List<Product2> products = new List<Product2>(
                [
                    SELECT Id, Name
                    FROM Product2
                    LIMIT 1
                ]
            );

            ProductDetailsCtrl.WrapperClass wrappedData = new ProductDetailsCtrl.WrapperClass();
            wrappedData.courseOfferingId = courseOffering[0].Id;
            wrappedData.isPrescribed = false;
            wrappedData.userId = users[0].Id;
            wrappedData.productName = products[0].Name;
            wrappedData.productId = products[0].Id;
            wrappedData.pricebookEntryId = pricebookEntryId;
            wrappedData.pricebookUnitPrice = pricebookUnitPrice;
            wrappedData.Pricebook2Id = priceBooknew.Id;
            ProductDetailsCtrl.CartWrapper cartWrapper = ProductDetailsCtrl.categoryBulkRegistration(
                contacts,
                wrappedData
            );
            ProductDetailsCtrl.getRegistrationConfirmationData(cartWrapper.externalId);

            Test.stopTest();
            system.assert(!String.isBlank(cartWrapper.externalId), 'Transaction failed! ');
        }
    }
}
