/**
 * @description Test class for ProductCtrl
 * @see ../classes ProductCtrl
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                             |
	  |---------------------------|-----------------------|----------------------|--------------------------------------------|
	  | eugene.andrew.abuan       | May 02, 2022          | DEPP-1269            | Created File                               |
	  | eugene.andrew.abuan       | May 20, 2022          | DEPP-1979            | Added methods for filters                  |
	  | keno.domienri.dico		  | May 30, 2022		  | DEPP-1980			 | Added methods for sorting				  |
	  | mary.grace.li             | July 01, 2022         | DEPP-3124            | Added new method for createTestProducts    |
	  | keno.domienri.dico        | July 15, 2022		  | DEPP-2699		     | CCE Homepage				                  |
	  | julie.jane.alegre         | November 28, 2022     | DEPP-4693		     | Update getProductsByCategory			      |
*/
@isTest
public with sharing class ProductCtrlTest {
	private static final String CATEGORY_OPE = 'Product Catalogue';
	private static final string STUDENT_RT = System.Label.RT_CourseConnection_Student;
	private static final String RT_PRODUCT_REQ = System.Label.RT_ProductRequest_Activity;
	private static final Id OPE_ACTIVITY_RECQ = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName()
		.get(RT_PRODUCT_REQ)
		.getRecordTypeId();
	private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
	private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
		.get(ACCT_UNIV_DEP)
		.getRecordTypeId();
	public static final Id FACULTY_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName()
		.get('Faculty')
		.getRecordTypeId();
	private static final Integer NUMBER_OF_RECORDS = 100;
	private static string prPROGRAM = System.Label.RT_ProductRequest_Program;
	private static Id opeProgProdReqId = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName()
		.get(prPROGRAM)
		.getRecordTypeId();
	private static final Id STUDENT_RT_ID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(STUDENT_RT).getRecordTypeId();
	private static final String RT_ACTIVITY = System.Label.RT_ProductRequest_Activity;
	private static final Id RT_ACTIVITY_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(RT_ACTIVITY).getRecordTypeId();
	private static final Id BUSINESS_ACC_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
	.get('Business_Organization')
	.getRecordTypeId();
	private static Id cceProdSpecId = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get('CCE').getRecordTypeId();

	@testSetup
	static void setupMethod() {
		TestDataFactory.generateTestUsers();
		BypassTriggers__c bypass = new BypassTriggers__c(Bypass__c = true, SetupOwnerId = UserInfo.getOrganizationId());
		insert bypass;
		Test.startTest();
		System.runAs(TestDataFactory.getProgramAdminUser()) {
			WebStore testWebStore = new WebStore(Name='CCE', DefaultLanguage='en_US');
			insert testWebStore;
			List<Account> accounts = TestDataFactory.createTestAccountRecords(2);
			Integer accCounter = 0;
			for (Account account : accounts) {
				if(accCounter == 0){
					account.RecordTypeId = ACCT_UNIV_DEP_ID;
					account.Organization_Unit_Level__c = '2';
				}

				if(accCounter == 1){
					account.RecordTypeId = BUSINESS_ACC_RECTYPEID;
				}
				accCounter++;
			}
			insert accounts;

			List<BuyerGroupMember> bgm = [
				SELECT Id, Name, BuyerId, BuyerGroupId FROM BuyerGroupMember 
				WHERE BuyerId = :accounts[1].Id
			];

			List<BuyerGroup> bGroup = [
				SELECT Id, Name FROM BuyerGroup
				WHERE Id = :bgm[0].BuyerGroupId
			];

			List<CommerceEntitlementPolicy> cePolicy = [
				SELECT Id, Name FROM CommerceEntitlementPolicy
			];

			List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
			insert contacts;

			Contact cceContact = new Contact(
				FirstName = 'Test',
				LastName = 'Contact',
				Email = 'testcontact@email.com',
				Registered_Email__c = 'testcontact@email.com',
				AccountId = accounts[1].Id,
				hed__Primary_Organization__c = accounts[1].Id,
				Work_Email__c = 'test@workemail.com',
				hed__Preferred_Email__c = 'Alternate Email',
				hed__AlternateEmail__c = 'test@email.com'
			);
			insert cceContact;

			CCECorporateUserCtrl.CorporateUserDetails enableResponse = CCECorporateUserCtrl.enablePortalUser(cceContact.Id,CATEGORY_OPE);
			List<User> userList = [
				SELECT Id, ProfileId, Profile.Name, ContactId 
				FROM User
				WHERE ContactId = :cceContact.Id
				LIMIT 1
			];

			List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(
				10,
				accounts[0].Id
			);
			insert terms;

			List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(
				1
			);
			prodRequest[0].RecordTypeId = RT_ACTIVITY_ID;
			insert prodRequest;

			List<Product_Request__c> prodRequestPrescribedProgram = TestDataFactory.createTestProductRequestRecords(
				1
			);
			prodRequestPrescribedProgram[0].RecordTypeId = opeProgProdReqId;
			prodRequestPrescribedProgram[0]
				.OPE_Program_Plan_Type__c = 'Prescribed Program';
			insert prodRequestPrescribedProgram;

			List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(
				1
			);
			programPlans[0].Product_Request__c = prodRequestPrescribedProgram[0].Id;
			insert programPlans;

			Program_Offering__c programOffering = new Program_Offering__c(
				Name = 'Program Offering_Test 1',
				hed_Program_Plan__c = programPlans[0].Id,
				Delivery_Type__c = 'Online Classroom',
				hed_Capacity__c = 30,
				Start_Date__c = system.today() + 1,
				Registration_Start_Date__c = system.today() - 1,
				IsActive__c = true
			);
			insert programOffering;

			List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(
				10,
				accounts[0].Id,
				prodRequest[0].Id
			);
			insert courses;

			// Standard Pricebook

			List<Product2> singleProducts = TestDataFactory.createTestProductRecords(
				10,
				courses
			);
			for (Product2 sProd : singleProducts) {
				sProd.Delivery__c = 'Online Classroom;Online Self-paced;Brisbane Classroom';
				sProd.Study_Area__c = 'Engineering';
				sProd.Product_Type__c = 'Short Course';
				sProd.Course__c = courses[0].Id;
				sProd.Available_on_Cart__c = true;
			}
			insert singleProducts;

			List<Product2> prodProgProducts = TestDataFactory.createTestProductRecords(
				50
			);
			for (Product2 presProd : prodProgProducts) {
				presProd.Delivery__c = 'Online Classroom;Online Self-paced;Brisbane Classroom';
				presProd.Study_Area__c = 'Engineering';
				presProd.Product_Type__c = 'Short Course';
				presProd.Program_Plan__c = programPlans[0].Id;
				presProd.Available_on_Cart__c = true;
			}
			insert prodProgProducts;

			List<Product2> prodProgProducts2 = TestDataFactory.createTestProductRecords(
				50
			);
			for (Product2 presProd : prodProgProducts2) {
				presProd.Delivery__c = 'Online Classroom;Online Self-paced;Brisbane Classroom';
				presProd.Study_Area__c = 'Business';
				presProd.Product_Type__c = 'Short Course';
				presProd.Program_Plan__c = programPlans[0].Id;
				presProd.Available_on_Cart__c = true;
			}
			insert prodProgProducts2;

			Pricebook2 pricebook = new Pricebook2(
				isActive = true,
				id = Test.getStandardPricebookId()
			);
			update pricebook;

			Pricebook2 pbEB = new Pricebook2();
			pbEB.Name = 'Early Bird';
			insert pbEB;

			List<PricebookEntry> priceBookEntryList = new List<PricebookEntry>();
			for (Product2 singleProdPBEntry : singleProducts) {
				PricebookEntry priceBookEntry = new PricebookEntry();
				priceBookEntry.pricebook2id = pricebook.Id;
				priceBookEntry.UnitPrice = 12;
				priceBookEntry.product2Id = singleProdPBEntry.Id;
				priceBookEntry.isActive = true;
				priceBookEntryList.add(priceBookEntry);
			}

			for (Product2 presProgProdPBEntry : prodProgProducts) {
				PricebookEntry priceBookEntry = new PricebookEntry();
				priceBookEntry.pricebook2id = pricebook.Id;
				priceBookEntry.UnitPrice = 10;
				priceBookEntry.product2Id = presProgProdPBEntry.Id;
				priceBookEntry.isActive = true;
				priceBookEntryList.add(priceBookEntry);
			}

			insert priceBookEntryList;

			List<PricebookEntry> priceBookEBEntryList = new List<PricebookEntry>();
			for (Product2 singleProdPBEBEntry : singleProducts) {
				PricebookEntry priceBookEBEntry = new PricebookEntry();
				priceBookEBEntry.pricebook2id = pbEB.Id;
				priceBookEBEntry.UnitPrice = 12;
				priceBookEBEntry.product2Id = singleProdPBEBEntry.Id;
				priceBookEBEntry.isActive = true;
				priceBookEBEntryList.add(priceBookEBEntry);
			}

			for (Product2 presProgProdPBEBEntry : prodProgProducts) {
				PricebookEntry priceBookEBEntry = new PricebookEntry();
				priceBookEBEntry.pricebook2id = pbEB.Id;
				priceBookEBEntry.UnitPrice = 10;
				priceBookEBEntry.product2Id = presProgProdPBEBEntry.Id;
				priceBookEBEntry.isActive = true;
				priceBookEBEntryList.add(priceBookEBEntry);
			}

			insert priceBookEBEntryList;

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

			List<hed__Course_Enrollment__c> courseConnections = TestDataFactory.createTestCourseConnectionRecord(
				10,
				contacts[0].Id,
				courseOfferings
			);
			for (hed__Course_Enrollment__c courseConnection : courseConnections) {
				courseConnection.RecordTypeId = FACULTY_RECTYPEID;
			}
			insert courseConnections;

			ProductCatalog prodCatalog = new ProductCatalog(Name = 'Study Catalog');
			insert prodCatalog;
			ProductCategory prodCateg = new ProductCategory(
				Name = 'Products',
				CatalogId = prodCatalog.Id
			);
			insert prodCateg;
			CommerceEntitlementPolicy commEntPolicy = new CommerceEntitlementPolicy(
				Name = 'OPE Entitlement'
			);
			insert commEntPolicy;
		}
		Test.stopTest();
	}

	@isTest
	static void getProductsSortNewlyAdded_SingleFreeTest() {
		System.runAs(TestDataFactory.getProgramAdminUser()) {
			Pricebook2 pbFree = new Pricebook2();
			pbFree.Name = 'Free';
			insert pbFree;

			// Pricebook2 pricebook = new Pricebook2();
			// pricebook = [SELECT Id, Name FROM Pricebook2 WHERE Name = 'Free'];
			List<Product2> pSTD = new List<Product2>();
			pSTD = [
				SELECT Id, Name, Course__c
				FROM Product2
				WHERE Course__c != null
				];

			List<PricebookEntry> priceBookEntryList = new List<PricebookEntry>();
			for (Product2 singleProdPBEntry : pSTD) {
				PricebookEntry priceBookEntry = new PricebookEntry();
				priceBookEntry.pricebook2id = pbFree.Id;
				priceBookEntry.UnitPrice = 0;
				priceBookEntry.product2Id = singleProdPBEntry.Id;
				priceBookEntry.isActive = true;
				priceBookEntryList.add(priceBookEntry);
			}
			insert priceBookEntryList;

			List<Product2> p = new List<Product2>();
			p = [
				SELECT Id, Name, Course__c,
				(SELECT Id, Pricebook2.Name, Product2Id FROM PricebookEntries WHERE IsActive = true and Pricebook2.Name = 'Free')
				FROM Product2
				WHERE Course__c != null
				];
			List<String> productId = new List<String>();
			for (Product2 product : p) {
				productId.add(product.Id);
			}

			Test.startTest();
			ProductCtrl.ProductData getProd = new ProductCtrl.ProductData();
			getProd = ProductCtrl.getProducts(productId, 'newlyAdded');
			Test.stopTest();

			System.assert(getProd != null, 'Successfully retrieved Products');
		}
	}

	@isTest
	static void getProductsSortNewlyAdded_SingleEBTest() {
		System.runAs(TestDataFactory.getProgramAdminUser()) {
			List<Product2> p = new List<Product2>();
			p = [
				SELECT Id, Name, Course__c,
				(SELECT Id, Pricebook2.Name, Product2Id FROM PricebookEntries WHERE IsActive = true and Pricebook2.Name = 'Early Bird')
				FROM Product2
				WHERE Course__c != null
				];
			List<String> productId = new List<String>();
			for (Product2 product : p) {
				productId.add(product.Id);
			}

			Test.startTest();
			ProductCtrl.ProductData getProd = new ProductCtrl.ProductData();
			getProd = ProductCtrl.getProducts(productId, 'newlyAdded');
			Test.stopTest();

			System.assert(getProd != null, 'Successfully retrieved Products');
		}
	}

	@isTest
	static void getProductsSortNewlyAdded_SingleSTDTest() {
		System.runAs(TestDataFactory.getProgramAdminUser()) {
			List<Product2> p = new List<Product2>();
			p = [
				SELECT Id, Name, Course__c,
				(SELECT Id, Pricebook2.Name, Product2Id FROM PricebookEntries WHERE IsActive = true and Pricebook2.Name = 'Standard Price Book')
				FROM Product2
				WHERE Course__c != null
				];
			List<String> productId = new List<String>();
			for (Product2 product : p) {
				productId.add(product.Id);
			}

			Test.startTest();
			ProductCtrl.ProductData getProd = new ProductCtrl.ProductData();
			getProd = ProductCtrl.getProducts(productId, 'newlyAdded');
			Test.stopTest();

			System.assert(getProd != null, 'Successfully retrieved Products');
		}
	}

	@isTest
	static void getProductsSortComingUp_SingleSTDTest() {
		System.runAs(TestDataFactory.getProgramAdminUser()) {
			List<Product2> p = new List<Product2>();
			p = [
				SELECT Id, Name, Course__c,
				(SELECT Id, Pricebook2.Name, Product2Id FROM PricebookEntries WHERE IsActive = true and Pricebook2.Name = 'Standard Price Book')
				FROM Product2
				WHERE Course__c != null
				];
			List<String> productId = new List<String>();
			for (Product2 product : p) {
				productId.add(product.Id);
			}

			Test.startTest();
			ProductCtrl.ProductData getProd = new ProductCtrl.ProductData();
			getProd = ProductCtrl.getProducts(productId, 'comingUp');
			Test.stopTest();

			System.assert(getProd != null, 'Successfully retrieved Products');
		}
	}

	@isTest
	static void getProductsSortComingUp_SingleEBTest() {
		System.runAs(TestDataFactory.getProgramAdminUser()) {
			List<Product2> p = new List<Product2>();
			p = [
				SELECT Id, Name, Course__c,
				(SELECT Id, Pricebook2.Name, Product2Id FROM PricebookEntries WHERE IsActive = true and Pricebook2.Name = 'Early Bird')
				FROM Product2
				WHERE Course__c != null
				];
			List<String> productId = new List<String>();
			for (Product2 product : p) {
				productId.add(product.Id);
			}

			Test.startTest();
			ProductCtrl.ProductData getProd = new ProductCtrl.ProductData();
			getProd = ProductCtrl.getProducts(productId, 'comingUp');
			Test.stopTest();

			System.assert(getProd != null, 'Successfully retrieved Products');
		}
	}

	@isTest
	static void getProductsSortComingUp_SingleEFreeTest() {
		System.runAs(TestDataFactory.getProgramAdminUser()) {
			Pricebook2 pbFree = new Pricebook2();
			pbFree.Name = 'Free';
			insert pbFree;

			// Pricebook2 pricebook = new Pricebook2();
			// pricebook = [SELECT Id, Name FROM Pricebook2 WHERE Name = 'Free'];
			List<Product2> pSTD = new List<Product2>();
			pSTD = [
				SELECT Id, Name, Course__c
				FROM Product2
				WHERE Course__c != null
				];

			List<PricebookEntry> priceBookEntryList = new List<PricebookEntry>();
			for (Product2 singleProdPBEntry : pSTD) {
				PricebookEntry priceBookEntry = new PricebookEntry();
				priceBookEntry.pricebook2id = pbFree.Id;
				priceBookEntry.UnitPrice = 0;
				priceBookEntry.product2Id = singleProdPBEntry.Id;
				priceBookEntry.isActive = true;
				priceBookEntryList.add(priceBookEntry);
			}
			insert priceBookEntryList;

			List<Product2> p = new List<Product2>();
			p = [
				SELECT Id, Name, Course__c,
				(SELECT Id, Pricebook2.Name, Product2Id FROM PricebookEntries WHERE IsActive = true and Pricebook2.Name = 'Free')
				FROM Product2
				WHERE Course__c != null
				];
			List<String> productId = new List<String>();
			for (Product2 product : p) {
				productId.add(product.Id);
			}

			Test.startTest();
			ProductCtrl.ProductData getProd = new ProductCtrl.ProductData();
			getProd = ProductCtrl.getProducts(productId, 'comingUp');
			Test.stopTest();

			System.assert(getProd != null, 'Successfully retrieved Products');
		}
	}

	@isTest
	static void getProductsSortComingUp_ProgEBTest() {
		System.runAs(TestDataFactory.getProgramAdminUser()) {
			List<Product2> p = new List<Product2>();
			p = [
				SELECT Id, Name, Program_Plan__c,
				(SELECT Id, Pricebook2.Name, Product2Id FROM PricebookEntries WHERE IsActive = true and Pricebook2.Name = 'Early Bird')
				FROM Product2
				WHERE Program_Plan__c != null
				];
			List<String> productId = new List<String>();
			for (Product2 product : p) {
				productId.add(product.Id);
			}

			Test.startTest();
			ProductCtrl.ProductData getProd = new ProductCtrl.ProductData();
			getProd = ProductCtrl.getProducts(productId, 'comingUp');
			Test.stopTest();

			System.assert(getProd != null, 'Successfully retrieved Products');
		}
	}

	@isTest
	static void getProductsSortComingUp_ProgSTDTest() {
		System.runAs(TestDataFactory.getProgramAdminUser()) {
			List<Product2> p = new List<Product2>();
			p = [
				SELECT Id, Name, Program_Plan__c,
				(SELECT Id, Pricebook2.Name, Product2Id FROM PricebookEntries WHERE IsActive = true and Pricebook2.Name = 'Standard Price Book')
				FROM Product2
				WHERE Program_Plan__c != null
				];
			List<String> productId = new List<String>();
			for (Product2 product : p) {
				productId.add(product.Id);
			}

			Test.startTest();
			ProductCtrl.ProductData getProd = new ProductCtrl.ProductData();
			getProd = ProductCtrl.getProducts(productId, 'comingUp');
			Test.stopTest();

			System.assert(getProd != null, 'Successfully retrieved Products');
		}
	}

	@isTest
	static void getProductsSortPriceLowToHigh_ProgSTDTest() {
		System.runAs(TestDataFactory.getProgramAdminUser()) {
			List<Product2> p = new List<Product2>();
			p = [
				SELECT Id, Name, Program_Plan__c,
				(SELECT Id, Pricebook2.Name, Product2Id FROM PricebookEntries WHERE IsActive = true and Pricebook2.Name = 'Standard Price Book')
				FROM Product2
				WHERE Program_Plan__c != null
				];
			List<String> productId = new List<String>();
			for (Product2 product : p) {
				productId.add(product.Id);
			}

			Test.startTest();
			ProductCtrl.ProductData getProd = new ProductCtrl.ProductData();
			getProd = ProductCtrl.getProducts(productId, 'priceLowToHigh');
			Test.stopTest();

			System.assert(getProd != null, 'Successfully retrieved Products');
		}
	}

	@isTest
	static void getProductsSortPriceLowToHigh_ProgEBTest() {
		System.runAs(TestDataFactory.getProgramAdminUser()) {
			List<Product2> p = new List<Product2>();
			p = [
				SELECT Id, Name, Program_Plan__c,
				(SELECT Id, Pricebook2.Name, Product2Id FROM PricebookEntries WHERE IsActive = true and Pricebook2.Name = 'Early Bird')
				FROM Product2
				WHERE Program_Plan__c != null
				];
			List<String> productId = new List<String>();
			for (Product2 product : p) {
				productId.add(product.Id);
			}

			Test.startTest();
			ProductCtrl.ProductData getProd = new ProductCtrl.ProductData();
			getProd = ProductCtrl.getProducts(productId, 'priceLowToHigh');
			Test.stopTest();

			System.assert(getProd != null, 'Successfully retrieved Products');
		}
	}

	@isTest
	static void getProductsSortPriceLowToHigh_SingleFreeTest() {
		System.runAs(TestDataFactory.getProgramAdminUser()) {
			Pricebook2 pbFree = new Pricebook2();
			pbFree.Name = 'Free';
			insert pbFree;
			// Pricebook2 pricebook = new Pricebook2();
			// pricebook = [SELECT Id, Name FROM Pricebook2 WHERE Name = 'Free'];
			List<Product2> pFree = new List<Product2>();
			pFree = [
				SELECT Id, Name, Course__c
				FROM Product2
				WHERE Course__c != null
				];

			List<PricebookEntry> priceBookEntryList = new List<PricebookEntry>();
			for (Product2 singleProdPBEntry : pFree) {
				PricebookEntry priceBookEntry = new PricebookEntry();
				priceBookEntry.pricebook2id = pbFree.Id;
				priceBookEntry.UnitPrice = 0;
				priceBookEntry.product2Id = singleProdPBEntry.Id;
				priceBookEntry.isActive = true;
				priceBookEntryList.add(priceBookEntry);
			}
			insert priceBookEntryList;

			List<Product2> p = new List<Product2>();
			p = [
				SELECT Id, Name, Course__c,
				(SELECT Id, Pricebook2.Name, Product2Id FROM PricebookEntries WHERE IsActive = true and Pricebook2.Name = 'Free')
				FROM Product2
				WHERE Course__c != null
				];
			List<String> productId = new List<String>();
			for (Product2 product : p) {
				productId.add(product.Id);
			}

			Test.startTest();
			ProductCtrl.ProductData getProd = new ProductCtrl.ProductData();
			getProd = ProductCtrl.getProducts(productId, 'priceLowToHigh');
			Test.stopTest();

			System.assert(getProd != null, 'Successfully retrieved Products');
		}
	}

	@isTest
	static void getProductsSortPriceLowToHigh_SingleEBTest() {
		System.runAs(TestDataFactory.getProgramAdminUser()) {
			List<Product2> p = new List<Product2>();
			p = [
				SELECT Id, Name, Course__c,
				(SELECT Id, Pricebook2.Name, Product2Id FROM PricebookEntries WHERE IsActive = true and Pricebook2.Name = 'Early Bird')
				FROM Product2
				WHERE Course__c != null
				];
			List<String> productId = new List<String>();
			for (Product2 product : p) {
				productId.add(product.Id);
			}

			Test.startTest();
			ProductCtrl.ProductData getProd = new ProductCtrl.ProductData();
			getProd = ProductCtrl.getProducts(productId, 'priceLowToHigh');
			Test.stopTest();

			System.assert(getProd != null, 'Successfully retrieved Products');
		}
	}

	@isTest
	static void getProductsSortPriceLowToHigh_SingleSTDTest() {
		System.runAs(TestDataFactory.getProgramAdminUser()) {
			List<Product2> p = new List<Product2>();
			p = [
				SELECT Id, Name, Course__c,
				(SELECT Id, Pricebook2.Name, Product2Id FROM PricebookEntries WHERE IsActive = true and Pricebook2.Name = 'Standard Price Book')
				FROM Product2
				WHERE Course__c != null
				];
			List<String> productId = new List<String>();
			for (Product2 product : p) {
				productId.add(product.Id);
			}

			Test.startTest();
			ProductCtrl.ProductData getProd = new ProductCtrl.ProductData();
			getProd = ProductCtrl.getProducts(productId, 'priceLowToHigh');
			Test.stopTest();

			System.assert(getProd != null, 'Successfully retrieved Products');
		}
	}

	@isTest
	static void getProductsSortPriceLowToHighTest() {
		System.runAs(TestDataFactory.getProgramAdminUser()) {
			List<Product2> p = new List<Product2>();
			p = [SELECT Id, Delivery__c FROM Product2];
			List<String> productId = new List<String>();
			for (Product2 product : p) {
				productId.add(product.Id);
			}

			Test.startTest();
			ProductCtrl.ProductData getProd = new ProductCtrl.ProductData();
			getProd = ProductCtrl.getProducts(productId, 'priceLowToHigh');
			Test.stopTest();

			System.assert(getProd != null, 'Successfully retrieved Products');
		}
	}

	@isTest
	static void getProductsSortPriceHighToLowTest() {
		System.runAs(TestDataFactory.getProgramAdminUser()) {
			List<Product2> p = new List<Product2>();
			p = [SELECT Id, Delivery__c FROM Product2];
			List<String> productId = new List<String>();
			for (Product2 product : p) {
				productId.add(product.Id);
			}

			Test.startTest();
			ProductCtrl.ProductData getProd = new ProductCtrl.ProductData();
			getProd = ProductCtrl.getProducts(productId, 'priceHighToLow');
			Test.stopTest();

			System.assert(getProd != null, 'Successfully retrieved Products');
		}
	}

	@isTest
	static void getProductsPublishDateTest() {
		System.runAs(TestDataFactory.getProgramAdminUser()) {
			List<Product2> p = new List<Product2>();
			p = [SELECT Id, Delivery__c FROM Product2];
			List<String> productId = new List<String>();
			for (Product2 product : p) {
				productId.add(product.Id);
			}

			Test.startTest();
			ProductCtrl.ProductData getProd = new ProductCtrl.ProductData();
			getProd = ProductCtrl.getProducts(productId, 'newlyAdded');
			Test.stopTest();

			System.assert(getProd != null, 'Successfully retrieved Products');
		}
	}

	@isTest
	static void getProductsStartDateTest() {
		System.runAs(TestDataFactory.getProgramAdminUser()) {
			List<Product2> p = new List<Product2>();
			p = [SELECT Id, Delivery__c FROM Product2];
			List<String> productId = new List<String>();
			for (Product2 product : p) {
				productId.add(product.Id);
			}

			Test.startTest();
			ProductCtrl.ProductData getProd = new ProductCtrl.ProductData();
			getProd = ProductCtrl.getProducts(productId, 'comingUp');
			Test.stopTest();

			System.assert(getProd != null, 'Successfully retrieved Products');
		}
	}
    
	@isTest
	static void getProductsByCategoryTailoredExecEducTest() {
		final User PROGRAM_ADMIN = TestDataFactory.getProgramAdminUser();
		DmlException expectedException;
		System.runAs(PROGRAM_ADMIN) {
			Test.startTest();
			List<Account> accBusinessOrg = [SELECT Id, RecordTypeId 
				FROM Account 
				WHERE RecordTypeId = :BUSINESS_ACC_RECTYPEID
				AND CreatedById = :PROGRAM_ADMIN.Id
			];

			List<Account> accUniv = [SELECT Id, RecordTypeId 
				FROM Account
				WHERE RecordTypeId =: ACCT_UNIV_DEP_ID
			];

			List<User> user = [
				SELECT Id, Name, ContactId, AccountId
				FROM User
				WHERE Contact.hed__Primary_Organization__c = :accBusinessOrg[0].Id
			];

			// Create BuyerGroupMember
			BuyerGroupMember gbMember = [
				SELECT Id, BuyerId, BuyerGroupId 
				FROM BuyerGroupMember
				WHERE BuyerId = :accBusinessOrg[0].Id
			];

			// Create CommerceEntitlementBuyerGroup
			CommerceEntitlementBuyerGroup ceBuyerGroup = [
				SELECT Id, PolicyId, BuyerGroupId 
				FROM CommerceEntitlementBuyerGroup
				WHERE BuyerGroupId = :gbMember.BuyerGroupId
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
				SELECT Id, Course__c FROM Product2 WHERE Course__c != null
			];
			List<ProductCategoryProduct> setTEEList = new List<ProductCategoryProduct>();
			for(Integer x = 0; x <= sProdCount; x++){
				ProductCategoryProduct setTEE = new ProductCategoryProduct();
				setTEE.ProductCategoryId = prodCateg1.Id;
				setTEE.ProductId = getSingleProd[x].Id;
				setTEEList.add(setTEE);
			}
			insert setTEEList;

			List<CommerceEntitlementProduct> ceProd = [
				SELECT Id, ProductId, PolicyId FROM CommerceEntitlementProduct 
			];
			Integer a = 0;
			for(CommerceEntitlementProduct setCEProd : ceProd){
				setCEProd.ProductId = getSingleProd[a].Id;
				setCEProd.PolicyId = ceBuyerGroup.PolicyId;
				a++;
			}
			insert ceProd;

			// Prescribe Program
			List<Product_Request__c> prodRequestPrescribedProgram = TestDataFactory.createTestProductRequestRecords(
				1
			);
			prodRequestPrescribedProgram[0].RecordTypeId = opeProgProdReqId;
			prodRequestPrescribedProgram[0]
				.OPE_Program_Plan_Type__c = 'Prescribed Program';
			insert prodRequestPrescribedProgram;

			List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(
				1
			);
			programPlans[0].Product_Request__c = prodRequestPrescribedProgram[0].Id;
			insert programPlans;

			List<Product2> prodProgProductsCCE = TestDataFactory.createTestProductRecords(
				50
			);
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
				SELECT Id, Program_Plan__c FROM Product2 WHERE Program_Plan__c != null
			];
			List<String> presProgProdId = new List<String>();
			List<ProductCategoryProduct> setTEEProgList = new List<ProductCategoryProduct>();
			for(Integer y = 0; y <= sProdCount; y++){
				ProductCategoryProduct setTEEProg = new ProductCategoryProduct();
				setTEEProg.ProductCategoryId = prodCateg1.Id;
				setTEEProg.ProductId = getPresProd[y].Id;
				setTEEProgList.add(setTEEProg);
			}
			insert setTEEProgList;

			List<CommerceEntitlementProduct> ceProdPres = [
				SELECT Id, ProductId, PolicyId FROM CommerceEntitlementProduct 
			];
			Integer b = 0;
			for(CommerceEntitlementProduct setCEProdPres : ceProdPres){
				setCEProdPres.ProductId = getPresProd[b].Id;
				setCEProdPres.PolicyId = ceBuyerGroup.PolicyId;
				b++;
			}
			insert ceProdPres;

			List<ProductCategoryProduct> pcpList = [
				SELECT Id, Name, ProductId, CatalogId, ProductCategory.Name, Product.Name, ProductCategoryId
				FROM ProductCategoryProduct
			];
		 
			ProductCtrl.ProductData getProdByCat = new ProductCtrl.ProductData();
            ProductCtrl.ProductData getProdByCatResult = new ProductCtrl.ProductData();
            getProdByCat.userId = user[0].Id;
            getProdByCat.categoryId = prodCateg1.Id;
            getProdByCat.accountId = accBusinessOrg[0].Id;
            
			getProdByCatResult = ProductCtrl.getProductsByCategory(getProdByCat, '');
			
			Test.stopTest();

			System.assert(getProdByCatResult != null, 'No retrieved Products');
		}
	}

	@isTest
	static void getProductsByCategoryCorpBundleTest() {
	  final User PROGRAM_ADMIN = TestDataFactory.getProgramAdminUser();
	  DmlException expectedException;
	  System.runAs(TestDataFactory.getProgramAdminUser()) {
	    Test.startTest();
			List<Account> accBusinessOrg = [SELECT Id, RecordTypeId 
				FROM Account 
				WHERE RecordTypeId = :BUSINESS_ACC_RECTYPEID
				AND CreatedById = :PROGRAM_ADMIN.Id];

			List<Account> accUniv = [SELECT Id, RecordTypeId 
				FROM Account
				WHERE RecordTypeId =: ACCT_UNIV_DEP_ID];

			List<User> user = [
				SELECT Id, Name, ContactId, AccountId
				FROM User
				WHERE Contact.Work_Email__c = 'test@workemail.com'
			];

			// Create BuyerGroupMember
			BuyerGroupMember gbMember = [
				SELECT Id, BuyerId, BuyerGroupId 
				FROM BuyerGroupMember
				WHERE BuyerId = :accBusinessOrg[0].Id
			];

			// Create CommerceEntitlementBuyerGroup
			CommerceEntitlementBuyerGroup ceBuyerGroup = [
				SELECT Id, PolicyId, BuyerGroupId 
				FROM CommerceEntitlementBuyerGroup
				WHERE BuyerGroupId = :gbMember.BuyerGroupId
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
				sProd.Product_Category__c = 'Corporate Bundle';
				sProdCount++;
			}
			insert singleProductsCCE;

			List<Product2> getSingleProd = [
				SELECT Id, Course__c FROM Product2 WHERE Course__c != null
			];
			List<ProductCategoryProduct> setTEEList = new List<ProductCategoryProduct>();
			for(Integer x = 0; x <= sProdCount; x++){
				ProductCategoryProduct setTEE = new ProductCategoryProduct();
				setTEE.ProductCategoryId = prodCateg1.Id;
				setTEE.ProductId = getSingleProd[x].Id;
				setTEEList.add(setTEE);
			}
			insert setTEEList;

			// Prescribe Program
			List<Product_Request__c> prodRequestPrescribedProgram = TestDataFactory.createTestProductRequestRecords(
				1
			);
			prodRequestPrescribedProgram[0].RecordTypeId = opeProgProdReqId;
			prodRequestPrescribedProgram[0]
				.OPE_Program_Plan_Type__c = 'Prescribed Program';
			insert prodRequestPrescribedProgram;

			List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(
				1
			);
			programPlans[0].Product_Request__c = prodRequestPrescribedProgram[0].Id;
			insert programPlans;

			List<Product2> prodProgProductsCCE = TestDataFactory.createTestProductRecords(
				50
			);
			Integer pProdCount = 0;
			for (Product2 presProd : prodProgProductsCCE) {
				presProd.Delivery__c = 'Online Classroom;Online Self-paced;Brisbane Classroom';
				presProd.Study_Area__c = 'Engineering';
				presProd.Product_Type__c = 'Short Course';
				presProd.Program_Plan__c = programPlans[0].Id;
				presProd.Available_on_Cart__c = true;
				presProd.Product_Category__c = 'Corporate Bundle';
				pProdCount++;
			}
			insert prodProgProductsCCE;
			List<Product2> getPresProd = [
				SELECT Id, Program_Plan__c FROM Product2 WHERE Program_Plan__c != null
			];
			List<String> presProgProdId = new List<String>();
			List<ProductCategoryProduct> setTEEProgList = new List<ProductCategoryProduct>();
			for(Integer y = 0; y <= sProdCount; y++){
				ProductCategoryProduct setTEEProg = new ProductCategoryProduct();
				setTEEProg.ProductCategoryId = prodCateg1.Id;
				setTEEProg.ProductId = getPresProd[y].Id;
				setTEEProgList.add(setTEEProg);
			}
			insert setTEEProgList;

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

			// Create PricebookEntry CB Standard
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

			// Create BuyerGroupPriceBook
			BuyerGroupPriceBook bgPriceBook = new BuyerGroupPriceBook(
				PriceBook2Id = pbCB.Id,
				BuyerGroupId = gbMember.BuyerGroupId
			);
			insert bgPriceBook;

			List<ProductCategoryProduct> pcpList = [
				SELECT Id, Name, ProductId, CatalogId, ProductCategory.Name, Product.Name, ProductCategoryId
				FROM ProductCategoryProduct
			];
			ProductCtrl.ProductData getProdByCat = new ProductCtrl.ProductData();
            ProductCtrl.ProductData getProdByCatResult = new ProductCtrl.ProductData();
            getProdByCat.userId = user[0].Id;
            getProdByCat.categoryId = prodCateg1.Id;
            getProdByCat.accountId = accBusinessOrg[0].Id;
            
			getProdByCatResult = ProductCtrl.getProductsByCategory(getProdByCat, '');
			
			Test.stopTest();

			System.assert(getProdByCatResult != null, 'No retrieved Products');

	  }
	}

	@isTest
	static void getProductsByCategoryQUTeXLearningTest() {
	  final User PROGRAM_ADMIN = TestDataFactory.getProgramAdminUser();
	  DmlException expectedException;
	  System.runAs(TestDataFactory.getProgramAdminUser()) {
	    Test.startTest();
			List<Account> accBusinessOrg = [SELECT Id, RecordTypeId 
				FROM Account 
				WHERE RecordTypeId = :BUSINESS_ACC_RECTYPEID
				AND CreatedById = :PROGRAM_ADMIN.Id];

			List<Account> accUniv = [SELECT Id, RecordTypeId 
				FROM Account
				WHERE RecordTypeId =: ACCT_UNIV_DEP_ID];

			List<User> user = [
				SELECT Id, Name, ContactId, AccountId
				FROM User
				WHERE Contact.hed__Primary_Organization__c = :accBusinessOrg[0].Id
			];

			// Create BuyerGroupMember
			BuyerGroupMember gbMember = [
				SELECT Id, BuyerId, BuyerGroupId 
				FROM BuyerGroupMember
				WHERE BuyerId = :accBusinessOrg[0].Id
			];

			// Create CommerceEntitlementBuyerGroup
			CommerceEntitlementBuyerGroup ceBuyerGroup = [
				SELECT Id, PolicyId, BuyerGroupId 
				FROM CommerceEntitlementBuyerGroup
				WHERE BuyerGroupId = :gbMember.BuyerGroupId
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
				sProd.Product_Category__c = 'QUTeX Learning Solutions';
				sProdCount++;
			}
			insert singleProductsCCE;

			List<Product2> getSingleProd = [
				SELECT Id, Course__c FROM Product2 WHERE Course__c != null
			];
			List<ProductCategoryProduct> setTEEList = new List<ProductCategoryProduct>();
			for(Integer x = 0; x <= sProdCount; x++){
				ProductCategoryProduct setTEE = new ProductCategoryProduct();
				setTEE.ProductCategoryId = prodCateg1.Id;
				setTEE.ProductId = getSingleProd[x].Id;
				setTEEList.add(setTEE);
			}
			insert setTEEList;

			// Prescribe Program
			List<Product_Request__c> prodRequestPrescribedProgram = TestDataFactory.createTestProductRequestRecords(
				1
			);
			prodRequestPrescribedProgram[0].RecordTypeId = opeProgProdReqId;
			prodRequestPrescribedProgram[0]
				.OPE_Program_Plan_Type__c = 'Prescribed Program';
			insert prodRequestPrescribedProgram;

			List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(
				1
			);
			programPlans[0].Product_Request__c = prodRequestPrescribedProgram[0].Id;
			insert programPlans;

			List<Product2> prodProgProductsCCE = TestDataFactory.createTestProductRecords(
				50
			);
			Integer pProdCount = 0;
			for (Product2 presProd : prodProgProductsCCE) {
				presProd.Delivery__c = 'Online Classroom;Online Self-paced;Brisbane Classroom';
				presProd.Study_Area__c = 'Engineering';
				presProd.Product_Type__c = 'Short Course';
				presProd.Program_Plan__c = programPlans[0].Id;
				presProd.Available_on_Cart__c = true;
				presProd.Product_Category__c = 'QUTeX Learning Solutions';
				pProdCount++;
			}
			insert prodProgProductsCCE;
			List<Product2> getPresProd = [
				SELECT Id, Program_Plan__c FROM Product2 WHERE Program_Plan__c != null
			];
			List<String> presProgProdId = new List<String>();
			List<ProductCategoryProduct> setTEEProgList = new List<ProductCategoryProduct>();
			for(Integer y = 0; y <= sProdCount; y++){
				ProductCategoryProduct setTEEProg = new ProductCategoryProduct();
				setTEEProg.ProductCategoryId = prodCateg1.Id;
				setTEEProg.ProductId = getPresProd[y].Id;
				setTEEProgList.add(setTEEProg);
			}
			insert setTEEProgList;

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

			// Create PricebookEntry CB Standard
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

			// Create BuyerGroupPriceBook
			BuyerGroupPriceBook bgPriceBook = new BuyerGroupPriceBook(
				PriceBook2Id = pbCB.Id,
				BuyerGroupId = gbMember.BuyerGroupId
			);
			insert bgPriceBook;

			List<ProductCategoryProduct> pcpList = [
				SELECT Id, Name, ProductId, CatalogId, ProductCategory.Name, Product.Name, ProductCategoryId
				FROM ProductCategoryProduct
			];

	   		ProductCtrl.ProductData getProdByCat = new ProductCtrl.ProductData();
            ProductCtrl.ProductData getProdByCatResult = new ProductCtrl.ProductData();
            getProdByCat.userId = user[0].Id;
            getProdByCat.categoryId = prodCateg1.Id;
            getProdByCat.accountId = accBusinessOrg[0].Id;
            
			getProdByCatResult = ProductCtrl.getProductsByCategory(getProdByCat, '');
			
			Test.stopTest();

			System.assert(getProdByCatResult != null, 'No retrieved Products');
      }

	}

	@isTest
	static void getFilterSearchKeyTest() {
		System.runAs(TestDataFactory.getProgramAdminUser()) {
			List<Product2> p = new List<Product2>();
			p = [SELECT Id, Delivery__c FROM Product2];
			List<String> productId = new List<String>();
			for (Product2 product : p) {
				productId.add(product.Id);
			}

			Test.startTest();
			ProductCtrl.FilterWrapper var = new ProductCtrl.FilterWrapper();
			var.searchKey = 'Test';
			var.studyArea = new List<String>();
			var.deliveryType = new List<String>();
			var.productType = new List<String>();
			var.minUnitPrice = 0;
			var.maxUnitPrice = 5000;
			//var.sortby = 'comingUp';
			ProductCtrl.FilterData getFilterProd = ProductCtrl.getFilteredProducts(
				productId,
				var
			);
			Test.stopTest();

			System.assert(
				getFilterProd != null,
				'No Products were found with Search key as filter'
			);
		}
	}

	@isTest
	static void getFilterStudyAreaTest() {
		System.runAs(TestDataFactory.getProgramAdminUser()) {
			List<Product2> p = new List<Product2>();
			p = [SELECT Id, Delivery__c FROM Product2];
			List<String> productId = new List<String>();
			for (Product2 product : p) {
				productId.add(product.Id);
			}

			Test.startTest();
			ProductCtrl.FilterWrapper var = new ProductCtrl.FilterWrapper();
			var.searchKey = '';
			var.studyArea = new List<String>{ 'Engineering' };
			var.deliveryType = new List<String>();
			var.productType = new List<String>();
			// var.sortby = 'comingUp';
			ProductCtrl.FilterData getFilterProd = ProductCtrl.getFilteredProducts(
				productId,
				var
			);
			Test.stopTest();

			System.assert(
				getFilterProd != null,
				'No Products were found with Study Area as filter'
			);
		}
	}

	@isTest
	static void getFilterDeliveryTest() {
		System.runAs(TestDataFactory.getProgramAdminUser()) {
			List<Product2> p = new List<Product2>();
			p = [SELECT Id, Delivery__c FROM Product2];
			List<String> productId = new List<String>();
			for (Product2 product : p) {
				productId.add(product.Id);
			}

			Test.startTest();
			ProductCtrl.FilterWrapper var = new ProductCtrl.FilterWrapper();
			var.searchKey = '';
			var.studyArea = new List<String>();
			var.deliveryType = new List<String>{ 'Online Classroom' };
			var.productType = new List<String>();
			var.sortby = 'comingUp';

			ProductCtrl.FilterData getFilterProd = ProductCtrl.getFilteredProducts(
				productId,
				var
			);
			Test.stopTest();

			System.assert(
				getFilterProd != null,
				'No Products were found with Delivery Type as filter'
			);
		}
	}

	@isTest
	static void getFilterProductTypeTest() {
		System.runAs(TestDataFactory.getProgramAdminUser()) {
			List<Product2> p = new List<Product2>();
			p = [SELECT Id, Delivery__c FROM Product2];
			List<String> productId = new List<String>();
			for (Product2 product : p) {
				productId.add(product.Id);
			}

			Test.startTest();
			ProductCtrl.FilterWrapper var = new ProductCtrl.FilterWrapper();
			var.searchKey = '';
			var.studyArea = new List<String>();
			var.deliveryType = new List<String>();
			var.productType = new List<String>{ 'Short Course' };
			var.sortby = 'comingUp';

			ProductCtrl.FilterData getFilterProd = ProductCtrl.getFilteredProducts(
				productId,
				var
			);
			Test.stopTest();

			System.assert(
				getFilterProd != null,
				'No Products were found with Short Course as filter'
			);
		}
	}

	@isTest
	static void getFilterDateSortPriceTest() {
		System.runAs(TestDataFactory.getProgramAdminUser()) {
			List<Product2> p = new List<Product2>();
			p = [SELECT Id, Delivery__c FROM Product2];
			List<String> productId = new List<String>();
			for (Product2 product : p) {
				productId.add(product.Id);
			}

			Test.startTest();
			ProductCtrl.FilterWrapper var = new ProductCtrl.FilterWrapper();
			Date dToday = Date.today();
			Date dTodayMinus3 = dToday - 3;
			Date dTodayPlus10 = dToday + 10;
			var.searchKey = '';
			var.studyArea = new List<String>();
			var.deliveryType = new List<String>();
			var.productType = new List<String>();
			var.minUnitPrice = 3;
			var.startDate = dTodayMinus3.day() + '/' + dTodayMinus3.month() + '/' + dTodayMinus3.year();
			var.endDate = dTodayPlus10.day() + '/' +dTodayPlus10.month() + '/' + dTodayPlus10.year();
			var.sortby = 'priceLowToHigh';

			ProductCtrl.FilterData getFilterProd = ProductCtrl.getFilteredProducts(
				productId,
				var
			);

			Test.stopTest();

			System.assert(
				getFilterProd != null,
				'No Products were found with Date as Filter'
			);
		}
	}

	@isTest
	static void getFilterDateTest() {
		System.runAs(TestDataFactory.getProgramAdminUser()) {
			List<Product2> p = new List<Product2>();
			p = [SELECT Id, Delivery__c FROM Product2];
			List<String> productId = new List<String>();
			for (Product2 product : p) {
				productId.add(product.Id);
			}

			Test.startTest();
			ProductCtrl.FilterWrapper var = new ProductCtrl.FilterWrapper();
			Date dToday = Date.today();
			Date dTodayMinus3 = dToday - 3;
			Date dTodayPlus10 = dToday + 10;
			var.searchKey = '';
			var.studyArea = new List<String>();
			var.deliveryType = new List<String>();
			var.productType = new List<String>();
			var.minUnitPrice = 3;
			var.startDate =
				dTodayMinus3.day() +
				'/' +
				dTodayMinus3.month() +
				'/' +
				dTodayMinus3.year();
			var.endDate =
				dTodayPlus10.day() +
				'/' +
				dTodayPlus10.month() +
				'/' +
				dTodayPlus10.year();
			var.sortby = 'comingUp';

			ProductCtrl.FilterData getFilterProd = ProductCtrl.getFilteredProducts(
				productId,
				var
			);

			Test.stopTest();

			System.assert(
				getFilterProd != null,
				'No Products were found with Date as Filter'
			);
		}
	}

	@isTest
	static void getFilterPriceDateCombo_ComingUpTest() {
		System.runAs(TestDataFactory.getProgramAdminUser()) {
			List<Product2> p = new List<Product2>();
			p = [SELECT Id, Delivery__c FROM Product2];
			List<String> productId = new List<String>();
			for (Product2 product : p) {
				productId.add(product.Id);
			}

			Test.startTest();
			ProductCtrl.FilterWrapper var = new ProductCtrl.FilterWrapper();
			Date dToday = Date.today();
			Date dTodayMinus3 = dToday - 3;
			Date dTodayPlus10 = dToday + 10;
			var.searchKey = '';
			var.studyArea = new List<String>();
			var.deliveryType = new List<String>();
			var.productType = new List<String>();
			var.minUnitPrice = 3;
			var.maxUnitPrice = 15;
			var.startDate =
				dTodayMinus3.day() +
				'/' +
				dTodayMinus3.month() +
				'/' +
				dTodayMinus3.year();
			var.endDate =
				dTodayPlus10.day() +
				'/' +
				dTodayPlus10.month() +
				'/' +
				dTodayPlus10.year();
			var.sortby = 'comingUp';

			ProductCtrl.FilterData getFilterProd = ProductCtrl.getFilteredProducts(
				productId,
				var
			);

			Test.stopTest();

			System.assert(
				getFilterProd != null,
				'No Products were found with Date and Price as filter'
			);
		}
	}

	@isTest
	static void getFilterPriceDateCombo_NewlyAddedTest() {
		System.runAs(TestDataFactory.getProgramAdminUser()) {
			List<Product2> p = new List<Product2>();
			p = [SELECT Id, Delivery__c FROM Product2];
			List<String> productId = new List<String>();
			for (Product2 product : p) {
				productId.add(product.Id);
			}

			Test.startTest();
			ProductCtrl.FilterWrapper var = new ProductCtrl.FilterWrapper();
			Date dToday = Date.today();
			Date dTodayMinus3 = dToday - 3;
			Date dTodayPlus10 = dToday + 10;
			var.searchKey = '';
			var.studyArea = new List<String>();
			var.deliveryType = new List<String>();
			var.productType = new List<String>();
			var.minUnitPrice = 3;
			var.maxUnitPrice = 15;
			var.startDate =
				dTodayMinus3.day() +
				'/' +
				dTodayMinus3.month() +
				'/' +
				dTodayMinus3.year();
			var.endDate =
				dTodayPlus10.day() +
				'/' +
				dTodayPlus10.month() +
				'/' +
				dTodayPlus10.year();
			var.sortby = 'newlyAdded';

			ProductCtrl.FilterData getFilterProd = ProductCtrl.getFilteredProducts(
				productId,
				var
			);

			Test.stopTest();

			System.assert(
				getFilterProd != null,
				'No Products were found with Date and Price as filter'
			);
		}
	}

	@isTest
	static void getFilterPriceDateCombo_HighToLowTest() {
		System.runAs(TestDataFactory.getProgramAdminUser()) {
			List<Product2> p = new List<Product2>();
			p = [SELECT Id, Delivery__c FROM Product2];
			List<String> productId = new List<String>();
			for (Product2 product : p) {
				productId.add(product.Id);
			}

			Test.startTest();
			ProductCtrl.FilterWrapper var = new ProductCtrl.FilterWrapper();
			Date dToday = Date.today();
			Date dTodayMinus3 = dToday - 3;
			Date dTodayPlus10 = dToday + 10;
			var.searchKey = '';
			var.studyArea = new List<String>();
			var.deliveryType = new List<String>();
			var.productType = new List<String>();
			var.minUnitPrice = 3;
			var.maxUnitPrice = 15;
			var.startDate =
				dTodayMinus3.day() +
				'/' +
				dTodayMinus3.month() +
				'/' +
				dTodayMinus3.year();
			var.endDate =
				dTodayPlus10.day() +
				'/' +
				dTodayPlus10.month() +
				'/' +
				dTodayPlus10.year();
			var.sortby = 'priceHighToLow';

			ProductCtrl.FilterData getFilterProd = ProductCtrl.getFilteredProducts(
				productId,
				var
			);

			Test.stopTest();

			System.assert(
				getFilterProd != null,
				'No Products were found with Date and Price as filter'
			);
		}
	}

	@isTest
	static void getFilterPriceDateCombo_LowToHighTest() {
		System.runAs(TestDataFactory.getProgramAdminUser()) {
			List<Product2> p = new List<Product2>();
			p = [SELECT Id, Delivery__c FROM Product2];
			List<String> productId = new List<String>();
			for (Product2 product : p) {
				productId.add(product.Id);
			}

			Test.startTest();
			ProductCtrl.FilterWrapper var = new ProductCtrl.FilterWrapper();
			Date dToday = Date.today();
			Date dTodayMinus3 = dToday - 3;
			Date dTodayPlus10 = dToday + 10;
			var.searchKey = '';
			var.studyArea = new List<String>();
			var.deliveryType = new List<String>();
			var.productType = new List<String>();
			var.minUnitPrice = 3;
			var.maxUnitPrice = 15;
			var.startDate =
				dTodayMinus3.day() +
				'/' +
				dTodayMinus3.month() +
				'/' +
				dTodayMinus3.year();
			var.endDate =
				dTodayPlus10.day() +
				'/' +
				dTodayPlus10.month() +
				'/' +
				dTodayPlus10.year();
			var.sortby = 'priceLowToHigh';

			ProductCtrl.FilterData getFilterProd = ProductCtrl.getFilteredProducts(
				productId,
				var
			);

			Test.stopTest();

			System.assert(
				getFilterProd != null,
				'No Products were found with Date and Price as filter'
			);
		}
	}
}