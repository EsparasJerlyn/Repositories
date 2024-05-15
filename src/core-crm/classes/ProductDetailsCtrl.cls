/**
 * @description Controller Class for productDetails and productDetailsDisplay LWC
 * @see ../lwc/productDetails
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                             |
			|---------------------------|-----------------------|----------------------|--------------------------------------------|
			| roy.nino.s.regala         | December 03, 2021     | DEPP-116             | Created file                               |
			| roy.nino.s.regala         | February 04, 2022     | DEPP-213             | Added insertion of Expression of Interest  |
			| roy.nino.s.regala         | March 04, 2022        | DEPP-1985            | Bug fix added recordtype                   |
			| john.bo.a.pineda          | April 11, 2022        | DEPP-1211            | Updated logic for new UI                   |
			| marlon.vasquez            | May 04,2022           | DEPP-1531            | Added Questionnaire Form                   |
			| keno.domienri.dico        | April 29, 2022        | DEPP-2038            | Added Child products display               |
			| eugene.andrew.abuan       | May 10, 2022          | DEPP-1269            | Added isProgramFlex to match in prodCard   |
			| julie.jane.alegre         | May 24, 2022          | DEPP-2070            | Added logic for Group Booking              |
			| john.bo.a.pineda          | June 01, 2022         | DEPP-2853            | Updated Registration Dates Logic           |
			| john.bo.a.pineda          | June 16, 2022         | DEPP-3016            | Updated Logic for Prescribed Child Order   |
			| john.bo.a.pineda          | June 18, 2022         | DEPP-3166            | Updated Logic for Facilitator Image URL    |
			| john.bo.a.pineda          | June 22, 2022         | DEPP-3211            | Modified logic to use correct logic to get |
			|                           |                       |                      | Earliest Upcoming Offering                 |
			| john.bo.a.pineda          | June 27, 2022         | DEPP-3216            | Modified add validation if Product already |
			|                           |                       |                      | exists in Cart only for URL Defaults       |
			| john.bo.a.pineda          | July 07, 2022         | DEPP-3435            | Added Detail URL to Flex Child Query       |
			| john.m.tambasen           | July 29, 2022         | DEPP-3577            | early bird number of days                  |
			| eugene.andrew.abuan       | July 30, 2022         | DEPP-3534            | Added Do not Show Start Date               |
			| keno.domienri.dico        | August 2, 2022        | DEPP-3474            | Added Product Category field               |
			| roy.nino.s.regala         | August 7, 2022        | DEPP-2498            | Added BuyerGroup Filter                    |
			|jessel.bajao               | August 17, 2022       | DEPP-3483            | Added code in insertLearnerInfo mehod for  |
			|                           |                       |                      | inserting Contact, Course connection       |
			| keno.domienri.dico        | August 18, 2022       | DEPP-3765            | Added new Product category identifier      | 
			|                           |                       |                      | Added new method for CCE ProductDetails    |
			| eugene.john.basilan       | September 01,2022     | DEPP-3479            | Added new method for CB Bulk Register      |
			| jessel.bajao		        | September 10, 2022    | DEPP-4071            | Removed inserlearnerInfo method, reuse cv  |
			| 							| 					    |                      | Close webcart manually					    |
			| john.m.tambasen			| September 12, 2022    | DEPP-3743            | validate duplicate contacts	  		    |
			| john.m.tambasen			| October 11, 2022   	| DEPP-4535            | added payment method Contract 				|
			| keno.domienri.dico		| October 12, 2022  	| DEPP-4283            | added condition for Prescribed Program child |
			| mary.grace.li             | November 22, 2022     | DEPP-4693            | Modified for Selected account logic          |
			| eugene.andrew.abuan       | February 14, 2023     | DEPP-5180            | Added method for TEECEE Checking             |
			| julie.jane.alegre         | September 28, 2023    | DEPP-4762            | Added Position & Company Name fields         |   

*/
public without sharing class ProductDetailsCtrl {
	public static final Id STUDENT_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName()
		.get('Student')
		.getRecordTypeId();
	public static final Id FACULTY_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName()
		.get('Faculty')
		.getRecordTypeId();

		private static final String RT_CONTACT_PERSON = System.Label.RT_Contact_Person;
		private static final Id RT_CONTACT_PERSON_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
			.get(RT_CONTACT_PERSON)
			.getRecordTypeId();

		public static final String EMPLOYEE_ROLE = 'Employee';
		public static final String CURRENT_STATUS = 'Current';
		public static final String CORPORATE_BUNDLE = 'Corporate Bundle';
		public static final String TAILORED_EXECUTIVE_EDUCATION = 'Tailored Executive Education';
		public static final String TAILORED_EXECUTIVE_PROGRAM = 'Tailored Executive Program';
		private static List<String> FACILITATOR_TITLE = System.Label.LWC_List_FacilitatorTitle.split(',');

	/**
	 * @description fetches course offerings and pricebooks related to the product
	 * @param productId - Product Id on productdetailpage
	 * @return prodDetailsData - Product Details & Pricebook Entries for Price picklist
	 */
	@AuraEnabled(cacheable=true)
	public static ProductDetailsData getProductRelatedRecords(Id productId) {
		ProductDetailsData prodDetailsData = new ProductDetailsData();
		List<PricebookEntryWrapper> pbEntryWrapperList = new List<PricebookEntryWrapper>();
		List<DeliveryWrapper> delivWrapperList = new List<DeliveryWrapper>();
		List<childProduct> childProdWrapperList = new List<childProduct>();
		Set<Id> priceBookIdsOPE = new Set<Id>();

		List<BuyerGroupPricebook> priceBookListOPE = [  
			SELECT Id, BuyerGroup.Name, Pricebook2Id 
			FROM BuyerGroupPricebook 
			WHERE BuyerGroup.Name = 'OPE BuyerGroup' 
			AND Pricebook2.IsActive = true];

			if(!priceBookListOPE.isEmpty()){
					for(BuyerGroupPricebook pb: priceBookListOPE){
							priceBookIdsOPE.add(pb.Pricebook2Id);
					}
			} 

		// Product
		Product2 productOnPage = [
			SELECT
				Id,
				Name,
				Description,
				StockKeepingUnit,
				Course__c,
				Course__r.ProductRequestID__c,
				Course__r.Minimum_Participants__c,
				Course__r.Maximum_Participants__c,
				Program_Plan__c,
				Program_Plan__r.Program_Delivery_Structure__c,
				Program_Plan__r.Minimum_Participants__c,
				Program_Plan__r.Maximum_Participants__c,
				Duration__c,
				Delivery__c,
				Minimum_Participants_Group__c,
				Maximum_Participants_Group__c,
				Payment_Options__c,
				Register_Interest_Available__c,
				Overview__c,
				Evolve_with_QUTeX__c,
				Who_Should_Participate__c,
				Core_Concepts__c,
				More_Details__c,
				Do_not_Show_Start_Date__c,
				Product_Category__c, 
				IsActive,
				(
					SELECT Id, Pricebook2.Name, UnitPrice, Early_Bird_No_of_Days__c
					FROM PricebookEntries
					WHERE IsActive = TRUE
					AND (Pricebook2.IsStandard = true 
					OR Pricebook2Id IN: priceBookIdsOPE)
					ORDER BY CreatedDate, Pricebook2.IsStandard DESC
				),
				Program_Plan__r.Product_Request__c
			FROM Product2
			WHERE Id = :productId
		];

		//Modules under the program
		if (
			productOnPage.Program_Plan__r.Program_Delivery_Structure__c ==
			'Prescribed Program'
		) {
			prodDetailsData.moduleWrapperList = getProgramModules(productOnPage.Program_Plan__c);
			prodDetailsData.programDeliveryAndOfferingMap = getProgramOfferings(productOnPage.Program_Plan__c);
		}

		// Pricebook Entries
		Map<String, PricebookEntry> pbEntryMap = new Map<String, PricebookEntry>();
		if (!productOnPage.PricebookEntries.isEmpty()) {
			for (PricebookEntry pricebookEntry : productOnPage.PricebookEntries) {
				pbEntryMap.put(pricebookEntry.Pricebook2.Name, pricebookEntry);
			}

			// If Free is configured, Only Free PriceBook will be displayed in Options
			if (pbEntryMap.containsKey('Free')) {
				pbEntryMap = new Map<String, PricebookEntry>{
					'Free' => (PricebookEntry) pbEntryMap.get('Free')
				};
			} 

			// Process PriceBookEntry Wrapper
			for (String pbEntryString : pbEntryMap.keySet()) {
				PricebookEntryWrapper pbEntryWrapper = new PricebookEntryWrapper();
				PricebookEntry pbEntry = pbEntryMap.get(pbEntryString);
				pbEntryWrapper.label = pbEntry.Pricebook2.Name;
				pbEntryWrapper.value = pbEntry.Id;
				pbEntryWrapper.meta = String.valueOf(pbEntry.UnitPrice);
				pbEntryWrapper.noOfDays = Integer.valueOf(pbEntry.Early_Bird_No_of_Days__c);
				pbEntryWrapperList.add(pbEntryWrapper);
			}
		}

		// Set isNotFlexProgram to True
		prodDetailsData.isNotFlexProgram = true;

		// Single Product
		if (String.isBlank(productOnPage.Program_Plan__c)) {
			// Delivery Options
			if (String.isNotBlank(productOnPage.Delivery__c)) {
				// Course Offering counter for Delivery
				Map<String, Integer> deliveryCountMap = new Map<String, Integer>();
				List<AggregateResult> countList = [
					SELECT Count(Id) counter, Delivery_Type__c, hed__Start_Date__c
					FROM hed__Course_Offering__c
					WHERE
						Registration_Start_Date__c <= TODAY
						AND (Registration_End_Date__c = NULL
						OR Registration_End_Date__c > TODAY)
						AND IsActive__c = TRUE
						AND Available_Seats__c > 0
						AND hed__Course__c = :productOnPage.Course__c
					GROUP BY Delivery_Type__c, hed__Start_Date__c
					ORDER BY hed__Start_Date__c
				];

				List<String> delivList = productOnPage.Delivery__c.split(';');
				List <String> checkDuplicateDelivList = new List<String>();

				for (AggregateResult count : countList) {
					deliveryCountMap.put( (String) count.get('Delivery_Type__c'), (Integer) count.get('counter') );
					// Display Delivery Options w/ Course Offerings
					if ( (deliveryCountMap.get( (String) count.get('Delivery_Type__c')) > 0) && !checkDuplicateDelivList.contains( (String) count.get('Delivery_Type__c')) && delivList.contains( (String) count.get('Delivery_Type__c'))) {
						checkDuplicateDelivList.add( (String) count.get('Delivery_Type__c'));
						DeliveryWrapper delivWrapper = new DeliveryWrapper();
						delivWrapper.label = (String) count.get('Delivery_Type__c');
						delivWrapper.value = (String) count.get('Delivery_Type__c');
						delivWrapperList.add(delivWrapper);
					}
				}
			}
		} else {
			// List Courses from Related Product Request
			Set<Id> courseIdSet = new Set<Id>();
			List<Related_Product_Request__c> relProdReqList = [
				SELECT Id, Name, Program__c, Course__c
				FROM Related_Product_Request__c
				WHERE Program__c = :productOnPage.Program_Plan__r.Product_Request__c
			];
			for (Related_Product_Request__c relProdReq : relProdReqList) {
				courseIdSet.add(relProdReq.Course__c);
			}
			// Get Child Products
			List<Product2> childProdList = [
				SELECT
					Id,
					Name,
					Course__c,
					Duration__c,
					Delivery__c,
					Description,
					Professional_Level__c,
					Detail_URL__c,
					(
						SELECT Id, Pricebook2.Name, UnitPrice, Early_Bird_No_of_Days__c
						FROM PricebookEntries
						WHERE IsActive = TRUE
						AND (Pricebook2.IsStandard = true 
						OR Pricebook2Id IN: priceBookIdsOPE)
						ORDER BY CreatedDate, Pricebook2.IsStandard DESC
					)
				FROM Product2
				WHERE
					Course__r.ProductRequestID__c IN :courseIdSet
					AND Available_on_Cart__c = TRUE
			];

			// Get sequence on Program Plan
			List<hed__Plan_Requirement__c> programPlanRequirementList = [
				SELECT Id, 
				hed__Course__c, 
				hed__Sequence__c
				FROM hed__Plan_Requirement__c
				WHERE hed__Program_Plan__c = :productOnPage.Program_Plan__c
				AND IsActive__c = TRUE
				ORDER BY hed__Sequence__c 
				];
	
			// Child Products set to childProductList
			List<Product2> childProductList = new List<Product2>();

			if(programPlanRequirementList.size() > 0){
				Set<Id> courseIdWithPlanSet = new Set<Id>();
				List<hed__Plan_Requirement__c> childProdWithPlanList = new List<hed__Plan_Requirement__c>();
				Map<String, Product2> childProductMap = new Map<String, Product2>();

				for (hed__Plan_Requirement__c programPlanRequirement : programPlanRequirementList) {
					courseIdWithPlanSet.add(programPlanRequirement.hed__Course__c);

					childProdWithPlanList.add(programPlanRequirement);
				}

				for (Product2 childProd : childProdList) {

					if(courseIdWithPlanSet.contains(childProd.Course__c)){
						childProductMap.put(childProd.Course__c, childProd);
					}
				}

				for (hed__Plan_Requirement__c programPlanRequirement : programPlanRequirementList) {
					
					if(childProductMap.containsKey(programPlanRequirement.hed__Course__c)){
						childProductList.add(childProductMap.get(programPlanRequirement.hed__Course__c));
					}
				}
			}
			
			// Flexible-Program
			Map<Id, Date> cProdDateMap = new Map<Id, Date>();
			if (
				productOnPage.Program_Plan__r.Program_Delivery_Structure__c ==
				'Flexible Program'
			) {
				// Set isNotFlexProgram to False
				prodDetailsData.isNotFlexProgram = false;

				// Map Child Product Earliest Course Offering Date
				List<AggregateResult> startDateList = [
					SELECT hed__Course__c, MIN(hed__Start_Date__c) startDate
					FROM hed__Course_Offering__c
					WHERE
						hed__Start_Date__c >= TODAY
						AND Registration_Start_Date__c <= TODAY
						AND (Registration_End_Date__c = NULL
						OR Registration_End_Date__c > TODAY)
						AND IsActive__c = TRUE
						AND Available_Seats__c > 0
						AND hed__Course__r.ProductRequestID__c IN :courseIdSet
					GROUP BY hed__Course__c
				];
				for (AggregateResult startDate : startDateList) {
					cProdDateMap.put( (Id) startDate.get('hed__Course__c'), (Date) startDate.get('startDate') );
				}
			}

			// Process Child Products
			for (Product2 childProd : childProductList) {
				childProduct childProductWrapper = new childProduct();
				childProductWrapper.childProdId = childProd.Id;
				childProductWrapper.childProdName = childProd.Name;
				childProductWrapper.childProdProfLevel = childProd.Professional_Level__c;
				childProductWrapper.childProdDuration = childProd.Duration__c;
				childProductWrapper.childProdDescription = childProd.Description;
				childProductWrapper.isProgramFlex = false;
				if (
					productOnPage.Program_Plan__r.Program_Delivery_Structure__c ==
					'Flexible Program'
				) {
					// Child Product Pricebook Entries
					Map<String, String> cProdPBEntryMap = new Map<String, String>();
					if (!childProd.PricebookEntries.isEmpty()) {
						for (PricebookEntry cProductPBookEntry : childProd.PricebookEntries) {
							cProdPBEntryMap.put( cProductPBookEntry.Pricebook2.Name, String.valueOf(cProductPBookEntry.UnitPrice));
						}
					}

					if (childProd.Delivery__c != null) {
						childProductWrapper.childProdDelivery = childProd.Delivery__c.replace(';', ', ');
					}

					if (cProdDateMap.containsKey(childProd.Course__c)) {
						childProductWrapper.childProdOfferingDate = Datetime.newInstance(cProdDateMap.get(childProd.Course__c), Time.newInstance(0, 0, 0, 0)).format('dd MMM yyyy');
					}

					if (cProdPBEntryMap.containsKey('Free')) {
						childProductWrapper.childProdPrice = cProdPBEntryMap.get('Free');
					} else {
						childProductWrapper.childProdPrice = cProdPBEntryMap.get('Standard Price Book');
						if (cProdPBEntryMap.containsKey('Early Bird')) {
							childProductWrapper.childProdPrice = cProdPBEntryMap.get('Early Bird');
						}
					}
					childProductWrapper.detailURL = childProd.Detail_URL__c;
				}
				childProdWrapperList.add(childProductWrapper);
			}
		}

		// Set values to wrapper
		prodDetailsData.productOnPage = productOnPage;
		prodDetailsData.pricebookWrapperList = pbEntryWrapperList;
		prodDetailsData.deliveryWrapperList = delivWrapperList;
		prodDetailsData.childProductList = childProdWrapperList;

		return prodDetailsData;
	}

	/**
	 * @description fetches course offerings and pricebooks related to the product
	 * @param productId - Product Id on productdetailpage
	 * @param userId - Get User Id 
	 * @return prodDetailsData - Product Details & Pricebook Entries for Price picklist
	 */
	@AuraEnabled(cacheable=true)
	public static ProductDetailsData getCCEProductRelatedRecords(ProductDetailsData productDetailsDataWrapper) {
		ProductDetailsData prodDetailsData = new ProductDetailsData();
		List<PricebookEntryWrapper> pbEntryWrapperList = new List<PricebookEntryWrapper>();
		List<DeliveryWrapper> delivWrapperList = new List<DeliveryWrapper>();
		List<childProduct> childProdWrapperList = new List<childProduct>();
		Set<Id> priceBookIdsOPE = new Set<Id>();
		List<Asset> assetList = new List<Asset>();
		List<BuyerGroupPricebook> bgpbList = new List<BuyerGroupPricebook>();
		Boolean hasProductsTEE;

		assetList = [
			SELECT Id, Product_Request__c
			FROM Asset
			WHERE Id =: productDetailsDataWrapper.assetId
			AND AccountId =: productDetailsDataWrapper.accountId
			WITH SECURITY_ENFORCED
		];

		// Get the List of BuyerGroupId
		List<BuyerGroupMember> buyerGroupIdList = [
			SELECT Id, Name, BuyerGroupId, BuyerId, Buyer.Name
			FROM BuyerGroupMember
			WHERE BuyerId = : productDetailsDataWrapper.accountId
		];

		List<String> bgIds = new List<String>();
		for(BuyerGroupMember bgMember : buyerGroupIdList){
			bgIds.add(bgMember.BuyerGroupId);
		}

		if(!bgIds.isEmpty() && productDetailsDataWrapper.categoryName == 'Tailored Executive Education' || productDetailsDataWrapper.categoryName == 'Tailored Executive Program'){
			//check if the Product is under that account 
			hasProductsTEE = checkProductsForTailored(bgIds,productDetailsDataWrapper.productId);
		}

		if(!assetList.isEmpty() && productDetailsDataWrapper.categoryName == 'Corporate Bundle'){
			// Get the Pricebook2Id from PricebookEntry
			bgpbList = [
				SELECT Id, Name, Pricebook2.Name, Pricebook2Id, BuyerGroup.Name, BuyerGroupId, Pricebook2.IsActive
				FROM BuyerGroupPricebook
				WHERE BuyerGroup.Product_Request__r.Product_Request_Status__c = 'Published'
				AND BuyerGroup.Product_Request__c =: assetList[0].Product_Request__c
			];
		}else if(productDetailsDataWrapper.categoryName == 'QUTeX Learning Solutions'){
			// Get the Pricebook2Id from PricebookEntry
			bgpbList = [
				SELECT Id, Name, Pricebook2.Name, Pricebook2Id, BuyerGroup.Name, BuyerGroupId, Pricebook2.IsActive
				FROM BuyerGroupPricebook
				WHERE BuyerGroupId =: productDetailsDataWrapper.buyerGroupId
				AND BuyerGroup.Product_Request__r.Product_Request_Status__c = 'Published'
			];
		}else{
			// Get the Pricebook2Id from PricebookEntry
			bgpbList = [
				SELECT Id, Name, Pricebook2.Name, Pricebook2Id, BuyerGroup.Name, BuyerGroupId, Pricebook2.IsActive
				FROM BuyerGroupPricebook
				WHERE BuyerGroupId IN :bgIds
				AND BuyerGroup.Product_Request__r.Product_Request_Status__c = 'Published'
			];
		}

		// Check if CB or SOA
		List<BuyerGroup> getPRId = [
			SELECT Id, Name, Product_Request__r.Name, Product_Request__r.Id
			FROM BuyerGroup
			WHERE Id IN :bgIds 
		];
		List<String> prIds = new List<String>();
		for(BuyerGroup setPRIds : getPRId){
			prIds.add(setPRIds.Product_Request__r.Id);
		}

		String pbeNameCB = 'Corporate Bundle';
		String pbeNameSOA = 'SOA';
		List<String> pbIds = new List<String>();
		for(BuyerGroupPricebook bgpb : bgpbList){
			pbIds.add(bgpb.Pricebook2Id);
		}
		String pbeName = '%';
		if(productDetailsDataWrapper.categoryName == 'Corporate Bundle'){
			pbeName = pbeNameCB + '%';
		} else {
			pbeName = pbeNameSOA + '%';
		}
		Product2 productOnPage = new Product2();
		// Product Tailored Executive Education
			Product2 prodTEEDetails = [
				SELECT
					Id,
					Name,
					Description,
					StockKeepingUnit,
					Course__c,
					Course__r.ProductRequestID__c,
					Course__r.Minimum_Participants__c,
					Course__r.Maximum_Participants__c,
					Program_Plan__c,
					Program_Plan__r.Program_Delivery_Structure__c,
					Program_Plan__r.Minimum_Participants__c,
					Program_Plan__r.Maximum_Participants__c,
					Duration__c,
					Delivery__c,
					Minimum_Participants_Group__c,
					Maximum_Participants_Group__c,
					Payment_Options__c,
					Register_Interest_Available__c,
					Overview__c,
					Evolve_with_QUTeX__c,
					Who_Should_Participate__c,
					Core_Concepts__c,
					More_Details__c,
					Do_not_Show_Start_Date__c,
					Product_Category__c, 
					Program_Plan__r.Product_Request__c
				FROM Product2
				WHERE Id = :productDetailsDataWrapper.productId
			];

			// Product Corporate Bundle and QUTeX Learning Solutions
			Product2 prodCBSOAList = [
				SELECT
					Id,
					Name,
					Description,
					StockKeepingUnit,
					Course__c,
					Course__r.ProductRequestID__c,
					Course__r.Minimum_Participants__c,
					Course__r.Maximum_Participants__c,
					Program_Plan__c,
					Program_Plan__r.Program_Delivery_Structure__c,
					Program_Plan__r.Minimum_Participants__c,
					Program_Plan__r.Maximum_Participants__c,
					Duration__c,
					Delivery__c,
					Minimum_Participants_Group__c,
					Maximum_Participants_Group__c,
					Payment_Options__c,
					Register_Interest_Available__c,
					Overview__c,
					Evolve_with_QUTeX__c,
					Who_Should_Participate__c,
					Core_Concepts__c,
					More_Details__c,
					Do_not_Show_Start_Date__c,
					Product_Category__c, 
					(
						SELECT Id, Pricebook2.Name, UnitPrice
						FROM PricebookEntries
						WHERE IsActive = true
						AND Pricebook2Id IN: pbIds
						AND Product2Id =:productDetailsDataWrapper.productId
						AND Pricebook2.Name LIKE :pbeName
					),
					Program_Plan__r.Product_Request__c
				FROM Product2
				WHERE Id =:productDetailsDataWrapper.productId
			];

		if(productDetailsDataWrapper.categoryName == 'Tailored Executive Education' || productDetailsDataWrapper.categoryName == 'Tailored Executive Program'){
			productOnPage = hasProductsTEE? prodTEEDetails : null;
			prodDetailsData.priceCCE = String.valueOf('0');
		} else {
			productOnPage = prodCBSOAList;
			
			// Check if Flexible Programs	
			Product2 checkFlex = [
				SELECT Id, Name, Program_Plan__r.Program_Delivery_Structure__c
				FROM Product2
				WHERE ID = :productDetailsDataWrapper.productId
			];
			Boolean isFlex = false;
			if(checkFlex.Program_Plan__r.Program_Delivery_Structure__c == 'Flexible Program'){
				isFlex = true;
			}
			
			if(!isFlex){
				//Get the Price from Pricebook
				PricebookEntry getPrice = [
					SELECT Id, Pricebook2.Name, UnitPrice, Pricebook2Id, Product2Id, IsActive
					FROM PricebookEntry
					WHERE IsActive = true
					AND Pricebook2Id IN :pbIds
					AND Pricebook2.Name LIKE :pbeName
					AND Product2Id = :productDetailsDataWrapper.productId
				];

				// Pricebook Entries
				if (getPrice != null) {
					prodDetailsData.priceCCE = String.valueOf(getPrice.UnitPrice);
					prodDetailsData.pricebookEntryIdCCE = getPrice.Id;
				}
			} else {
				prodDetailsData.priceCCE = String.valueOf('0');
			}
		}

		if(productOnPage != null){
			//Modules under the program
			if (
				productOnPage.Program_Plan__r.Program_Delivery_Structure__c ==
				'Prescribed Program'
			) {
				prodDetailsData.moduleWrapperList = getProgramModules(productOnPage.Program_Plan__c);
				prodDetailsData.programDeliveryAndOfferingMap = getProgramOfferings(productOnPage.Program_Plan__c);
			}
	
			// Set isNotFlexProgram to True
			prodDetailsData.isNotFlexProgram = true;
	
			// Single Product
			if (String.isBlank(productOnPage.Program_Plan__c)) {
				// Delivery Options
				if (String.isNotBlank(productOnPage.Delivery__c)) {
					// Course Offering counter for Delivery
					Map<String, Integer> deliveryCountMap = new Map<String, Integer>();
					List<AggregateResult> countList = [
						SELECT Count(Id) counter, Delivery_Type__c
						FROM hed__Course_Offering__c
						WHERE
							Registration_Start_Date__c <= TODAY
							AND (Registration_End_Date__c = NULL
							OR Registration_End_Date__c > TODAY)
							AND IsActive__c = TRUE
							AND Available_Seats__c > 0
							AND hed__Course__c = :productOnPage.Course__c
						GROUP BY Delivery_Type__c
					];
					for (AggregateResult count : countList) {
						deliveryCountMap.put( (String) count.get('Delivery_Type__c'), (Integer) count.get('counter') );
					}
	
					// Display Delivery Options w/ Course Offerings
					List<String> delivList = productOnPage.Delivery__c.split(';');
					for (String deliv : delivList) {
						if (deliveryCountMap.get(deliv) > 0) {
							DeliveryWrapper delivWrapper = new DeliveryWrapper();
							delivWrapper.label = deliv;
							delivWrapper.value = deliv;
							delivWrapperList.add(delivWrapper);
						}
					}
				}
			} else {
				// List Courses from Related Product Request
				Set<Id> courseIdSet = new Set<Id>();
				List<Related_Product_Request__c> relProdReqList = [
					SELECT Id, Name, Program__c, Course__c
					FROM Related_Product_Request__c
					WHERE Program__c = :productOnPage.Program_Plan__r.Product_Request__c
				];
				for (Related_Product_Request__c relProdReq : relProdReqList) {
					courseIdSet.add(relProdReq.Course__c);
				}
				// Get Child Products
				List<Product2> childProdList = [
					SELECT
						Id,
						Name,
						Course__c,
						Duration__c,
						Delivery__c,
						Description,
						Professional_Level__c,
						Detail_URL__c,
						(
							SELECT Id, Pricebook2.Name, UnitPrice, Early_Bird_No_of_Days__c
							FROM PricebookEntries
							WHERE IsActive = TRUE
							AND (Pricebook2.IsStandard = true 
							OR Pricebook2Id IN: priceBookIdsOPE)
							ORDER BY CreatedDate, Pricebook2.IsStandard DESC
						)
					FROM Product2
					WHERE
						Course__r.ProductRequestID__c IN :courseIdSet
						AND Available_on_Cart__c = TRUE
				];
	
				// Get sequence on Program Plan
				List<hed__Plan_Requirement__c> programPlanRequirementList = [
					SELECT Id, 
					hed__Course__c,
					hed__Sequence__c
					FROM hed__Plan_Requirement__c
					WHERE hed__Program_Plan__c = :productOnPage.Program_Plan__c
					AND IsActive__c = TRUE
					ORDER BY hed__Sequence__c 
					];
		
				// Child Products set to childProductList
				List<Product2> childProductList = new List<Product2>();
	
				if(programPlanRequirementList.size() > 0){
					Set<Id> courseIdWithPlanSet = new Set<Id>();
					List<hed__Plan_Requirement__c> childProdWithPlanList = new List<hed__Plan_Requirement__c>();
					Map<String, Product2> childProductMap = new Map<String, Product2>();
	
					for (hed__Plan_Requirement__c programPlanRequirement : programPlanRequirementList) {
						courseIdWithPlanSet.add(programPlanRequirement.hed__Course__c);
	
						childProdWithPlanList.add(programPlanRequirement);
					}
	
					for (Product2 childProd : childProdList) {
	
						if(courseIdWithPlanSet.contains(childProd.Course__c)){
							childProductMap.put(childProd.Course__c, childProd);
						}
					}
	
					for (hed__Plan_Requirement__c programPlanRequirement : programPlanRequirementList) {
						if(childProductMap.containsKey(programPlanRequirement.hed__Course__c)){
							childProductList.add(childProductMap.get(programPlanRequirement.hed__Course__c));
						}
					}
				}
			
	
				// Flexible-Program
				Map<Id, Date> cProdDateMap = new Map<Id, Date>();
				if (productOnPage.Program_Plan__r.Program_Delivery_Structure__c == 'Flexible Program'){
					// Set isNotFlexProgram to False
					prodDetailsData.isNotFlexProgram = false;
	
					// Map Child Product Earliest Course Offering Date
					List<AggregateResult> startDateList = [
						SELECT hed__Course__c, MIN(hed__Start_Date__c) startDate
						FROM hed__Course_Offering__c
						WHERE
							hed__Start_Date__c >= TODAY
							AND Registration_Start_Date__c <= TODAY
							AND (Registration_End_Date__c = NULL
							OR Registration_End_Date__c > TODAY)
							AND IsActive__c = TRUE
							AND Available_Seats__c > 0
							AND hed__Course__r.ProductRequestID__c IN :courseIdSet
						GROUP BY hed__Course__c
					];
					for (AggregateResult startDate : startDateList) {
						cProdDateMap.put( (Id) startDate.get('hed__Course__c'), (Date) startDate.get('startDate') );
					}
				}
	
				// Process Child Products
				for (Product2 childProd : childProductList) {
					childProduct childProductWrapper = new childProduct();
					childProductWrapper.childProdId = childProd.Id;
					childProductWrapper.childProdName = childProd.Name;
					childProductWrapper.childProdProfLevel = childProd.Professional_Level__c;
					childProductWrapper.childProdDuration = childProd.Duration__c;
					childProductWrapper.childProdDescription = childProd.Description;
					childProductWrapper.isProgramFlex = false;
					if (productOnPage.Program_Plan__r.Program_Delivery_Structure__c == 'Flexible Program') {
						// Child Product Pricebook Entries
						Map<String, String> cProdPBEntryMap = new Map<String, String>();
						if (!childProd.PricebookEntries.isEmpty()) {
							for (PricebookEntry cProductPBookEntry : childProd.PricebookEntries) {
								cProdPBEntryMap.put(cProductPBookEntry.Pricebook2.Name, String.valueOf(cProductPBookEntry.UnitPrice));
							}
						}
	
						if (childProd.Delivery__c != null) {
							childProductWrapper.childProdDelivery = childProd.Delivery__c.replace(';', ', ');
						}
	
						if (cProdDateMap.containsKey(childProd.Course__c)) {
							childProductWrapper.childProdOfferingDate = Datetime.newInstance(
									cProdDateMap.get(childProd.Course__c),
									Time.newInstance(0, 0, 0, 0)
								)
								.format('dd MMM yyyy');
						}
	
						if (cProdPBEntryMap.containsKey('Free')) {
							childProductWrapper.childProdPrice = cProdPBEntryMap.get('Free');
						} else {
							childProductWrapper.childProdPrice = cProdPBEntryMap.get(
								'Standard Price Book'
							);
							if (cProdPBEntryMap.containsKey('Early Bird')) {
								childProductWrapper.childProdPrice = cProdPBEntryMap.get(
									'Early Bird'
								);
							}
						}
						childProductWrapper.detailURL = childProd.Detail_URL__c;
					}
					childProdWrapperList.add(childProductWrapper);
				}
			}
		}

		// Set values to wrapper
		prodDetailsData.productOnPage = productOnPage;
		prodDetailsData.pricebookWrapperList = pbEntryWrapperList;
		prodDetailsData.deliveryWrapperList = delivWrapperList;
		prodDetailsData.childProductList = childProdWrapperList;

		return prodDetailsData;
	}

	/**
	 * @description fetches related course offerings to the product
	 * @param courseId - Product Id on productdetailpage
	 * @param deliveryParam - Delivery Parameter selected on productdetailpage
	 * @param ccePortal - check if CCE Portal
	 * @return cOfferList - Product Details & Pricebook Entries for Price picklist
	 */
	@AuraEnabled(cacheable=true)
	public static List<CourseOfferingWrapper> getCourseOfferingRelatedRecords(
		Id courseId,
		List<String> deliveryParam,
		Boolean ccePortal
	) {
		List<CourseOfferingWrapper> cOfferWrapperList = new List<CourseOfferingWrapper>();

		if (deliveryParam.size() > 0) {
			// Get Course Offering from selected Delivery Options
			List<hed__Course_Offering__c> cOfferList = [
				SELECT
					Id,
					Delivery_Type__c,
					hed__Start_Date__c,
					Available_Seats__c,
					hed__Facility__r.Display_Name__c,
					hed__Course__c, //get course value
					Program_Offering__c, //get program value
					(
						SELECT
							Id,
							hed__Contact__c,
							hed__Contact__r.Name,
							toLabel(hed__Contact__r.Salutation),
							Facilitator_Bio__r.Professional_Bio__c,
							hed__Contact__r.Contact_Image__c,
							hed__Primary__c
						FROM hed__Course_Enrollment__r
						WHERE RecordTypeId = :FACULTY_RECTYPEID AND IsActive__c = TRUE
						ORDER BY hed__Primary__c DESC
					)
				FROM hed__Course_Offering__c
				WHERE
					Registration_Start_Date__c <= TODAY
					AND (Registration_End_Date__c = NULL
					OR Registration_End_Date__c > TODAY)
					AND IsActive__c = TRUE
					AND Available_Seats__c > 0
					AND hed__Course__c = :courseId
					AND Delivery_Type__c IN :deliveryParam
				ORDER BY hed__Start_Date__c ASC
			];

			if (cOfferList.size() > 0) {
				// Get Set of Contact Ids
				Set<Id> conIdSet = new Set<Id>();
				for (hed__Course_Offering__c cOfferConId : cOfferList) {
					for (
						hed__Course_Enrollment__c cEnrollConId : cOfferConId.hed__Course_Enrollment__r
					) {
						conIdSet.add(cEnrollConId.hed__Contact__c);
					}
				}

				// Get ContentDocumentLink for Contacts
				Map<Id, Id> conContentDocuIdMap = new Map<Id, Id>();
				Map<Id, ContentVersion> conContentVersionMap = new Map<Id, ContentVersion>();
				Map<Id, ContentDistribution> conContentDistributionMap = new Map<Id, ContentDistribution>();
				if (conIdSet.size() > 0) {
					List<ContentDocumentLink> conContentDocuLinkList = [
						SELECT Id, ContentDocumentId, LinkedEntityId
						FROM ContentDocumentLink
						WHERE LinkedEntityId IN :conIdSet
					];
					for (
						ContentDocumentLink conContentDocuLink : conContentDocuLinkList
					) {
						conContentDocuIdMap.put(
							conContentDocuLink.ContentDocumentId,
							conContentDocuLink.LinkedEntityId
						);
					}

					// Get Contact Version
					List<ContentVersion> conContentVersionList = [
						SELECT Id, ContentDocumentId, ContentBodyId, FileType
						FROM ContentVersion
						WHERE
							Title = 'ContactImage.jpg'
							AND ContentDocumentId IN :conContentDocuIdMap.keySet()
					];
					for (ContentVersion conContentVersion : conContentVersionList) {
						conContentVersionMap.put(
							conContentDocuIdMap.get(conContentVersion.ContentDocumentId),
							conContentVersion
						);
					}

					// Get Content Distribution
					List<ContentDistribution> conContentDistributionList = [
						SELECT Id, ContentDocumentId, ContentDownloadUrl
						FROM ContentDistribution
						WHERE
							Name = 'ContactImage.jpg'
							AND ContentDocumentId IN :conContentDocuIdMap.keySet()
					];
					for (
						ContentDistribution conContentDistribution : conContentDistributionList
					) {
						conContentDistributionMap.put(
							conContentDocuIdMap.get(conContentDistribution.ContentDocumentId),
							conContentDistribution
						);
					}
				}

				// Set Available Start Date Wrapper
				for (hed__Course_Offering__c cOffer : cOfferList) {
					CourseOfferingWrapper cOfferWrapper = new CourseOfferingWrapper();
					// label
					cOfferWrapper.label = Datetime.newInstance(
							cOffer.hed__Start_Date__c,
							Time.newInstance(0, 0, 0, 0)
						)
						.format('dd MMM yyyy');
					// value
					cOfferWrapper.value = cOffer.Id;
					// Delivery
					cOfferWrapper.defDeliv = cOffer.Delivery_Type__c;
					// //available seats
					cOfferWrapper.availableSeats = cOffer.Available_Seats__c;
					//program plan
					cOfferWrapper.programPlan = coffer.Program_Offering__c;
					//course
					cOfferWrapper.course = coffer.hed__Course__c;
					// meta 
					if (ccePortal){
						if (cOffer.Available_Seats__c == 1) {
							cOfferWrapper.meta =
								cOffer.Available_Seats__c +
								' ' +
								Label.QUT_ProductDetail_CourseSeatLeft;
						} else {
							cOfferWrapper.meta =
								cOffer.Available_Seats__c +
								' ' +
								Label.QUT_ProductDetail_CourseSeatsLeft;
						}
					}
					else
					{
					 if (cOffer.Available_Seats__c <= 10) {           
							if (cOffer.Available_Seats__c == 1) {
								cOfferWrapper.meta =
									cOffer.Available_Seats__c +
									' ' +
									Label.QUT_ProductDetail_CourseSeatLeft;
							} else {
								cOfferWrapper.meta =
									cOffer.Available_Seats__c +
									' ' +
									Label.QUT_ProductDetail_CourseSeatsLeft;
							}  
						}         
					}
					// facilitator
					List<facilitatorWrapper> facilWrapperList = new List<facilitatorWrapper>();
					for (
						hed__Course_Enrollment__c cEnroll : cOffer.hed__Course_Enrollment__r
					) {
						facilitatorWrapper facilWrapper = new facilitatorWrapper();
						// Facilitator Name
						facilWrapper.facilitatorName = cEnroll.hed__Contact__r.Name;
						if(FACILITATOR_TITLE.contains(cEnroll.hed__Contact__r.Salutation)){
							facilWrapper.facilitatorName = cEnroll.hed__Contact__r.Salutation + ' ' + cEnroll.hed__Contact__r.Name;
						}
						// Facilitator Bio
						facilWrapper.facilitatorBio = cEnroll.Facilitator_Bio__r.Professional_Bio__c;
						// Facilitator Image
						if (conContentVersionMap.containsKey(cEnroll.hed__Contact__c)) {
							ContentDistribution cDis = conContentDistributionMap.get(
								cEnroll.hed__Contact__c
							);

							// Construct Public URL for Contact Image

							String picURL = String.valueOf(cDis.ContentDownloadUrl)
								.replace(
									'download/?',
									'renditionDownload?rendition=ORIGINAL_Jpg&'
								);

							facilWrapper.facilitatorImage = picURL.replace(
								'&ids',
								'&versionId'
							);
						}
						facilWrapperList.add(facilWrapper);
					}

					// Set values to wrapper
					cOfferWrapper.facilitator = facilWrapperList;
					cOfferWrapperList.add(cOfferWrapper);
				}
			}
		}

		return cOfferWrapperList;
	}

	/**
	 * @description Custom Add to Cart process
	 * @param communityId The Id of the community from which the call originated
	 * @param productId The Id of the product
	 * @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
	 * @param productName The Product Name.
	 * @param courseOfferingId The Course Offering Id of the selected Available Start Date on UI.
	 * @param pricebookEntryId The Pricebook Entry Id of the selected Price on UI.
	 */
	@AuraEnabled
	public static void addToCartItem(
		String communityId,
		String productId,
		String effectiveAccountId,
		String productName,
		String courseOfferingId,
		String programOfferingId,
		String pricebookEntryId,
		String userId,
		Boolean urlDefaultAddToCart
	) {
		try {
			// Lookup the webstore ID associated with the community
			String webstoreId;
			Boolean addCart = true;
			if (Test.isRunningTest()) {
				webstoreId = [SELECT Id FROM WebStore LIMIT 1].Id;
			} else {
				webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
			}

			// Get Current User Active Cart
			Id cartId = [
				SELECT Id, Name, WebStoreId, AccountId, Status, Type
				FROM WebCart
				WHERE
					Status = 'Active'
					AND OwnerId = :userId
					AND WebStoreId = :webstoreId
				LIMIT 1
			]
			.Id;

			Id contactId = [SELECT Id, ContactId FROM User WHERE Id = :userId LIMIT 1]
			?.ContactId;

			// Get Current User Active Cart Delivery Group
			Id cartDeliveryGroupId = [
				SELECT Id, Name, CreatedDate, LastModifiedDate, CartId
				FROM CartDeliveryGroup
				WHERE CartId = :cartId
			]
			.Id;

			PriceBookEntry pbEntry = [
				SELECT Id, UnitPrice
				FROM PriceBookEntry
				WHERE Id = :pricebookEntryId
			];

			// Only for URL Defaults, Validate if Product Exists in Cart
			if (urlDefaultAddToCart) {
				List<CartItem> urlDefaultCartItem = [
					SELECT Id
					FROM CartItem
					WHERE
						CartId = :cartId
						AND Product2Id = :productId
						AND Pricebook_Entry_ID__c = :pricebookEntryId
						AND (Course_Offering__c = :courseOfferingId
						OR Program_Offering__c = :programOfferingId)
				];

				// If URL Defaults exists in Cart, set addCart to False
				if (urlDefaultCartItem.size() > 0) {
					addCart = false;
				}
			}

			// Set Cart Item to be inserted
			if (addCart) {
				CartItem cItem = new CartItem();
				cItem.CartId = cartId;
				cItem.Contact__c = contactId;
				cItem.CartDeliveryGroupId = cartDeliveryGroupId;
				cItem.Name = productName;
				cItem.Product2Id = productId;
				if (String.isNotBlank(courseOfferingId)) {
					cItem.Course_Offering__c = courseOfferingId;
				} else if (String.isNotBlank(programOfferingId)) {
					cItem.Program_Offering__c = programOfferingId;
				}
				cItem.Pricebook_Entry_ID__c = pricebookEntryId;
				cItem.Quantity = 1;
				cItem.Type = 'Product';
				cItem.TotalPrice = pbEntry.UnitPrice;

				insert cItem;
			}
		} catch (Exception e) {
			AuraHandledException auraEx = new AuraHandledException(e.getMessage());
			throw auraEx;
		}
	}

	@AuraEnabled
	public static Asset assetRecordData(Id Pricebook2Id){
		Id prodReqId = [SELECT Id, BuyerGroup.Product_Request__c FROM BuyerGroupPricebook WHERE Pricebook2Id= :Pricebook2Id LIMIT 1].BuyerGroup.Product_Request__c;
		return [
			SELECT
				Id,
				Remaining_Value__c
			FROM Asset
			WHERE Product_Request__c = :prodReqId
			LIMIT 1
		];
	}

	@AuraEnabled
	public static CartWrapper categoryBulkRegistration(
	  List<Contact> learnerInfoList,
	  WrapperClass wrappedData
	) {
		CartWrapper cartWrapper = new CartWrapper();
		try{
			Id prodReqId;
			Id assetId;
		
		
			List<CartItem> cartItemsToInsert = new List<CartItem>();
			User user = [SELECT Id, AccountId, Contact.hed__Primary_Organization__c FROM User WHERE Id= :wrappedData.userId LIMIT 1];

			Id accountId = user.Contact.hed__Primary_Organization__c != null?user.Contact.hed__Primary_Organization__c:user.AccountId;
	
			Id webId = [SELECT Id from WebStore WHERE Name = 'CCE'].ID;

			if(wrappedData.cartId!=Null){
				WebCart webCart = new WebCart(Id = wrappedData.cartId, Status = 'Closed');
				update webCart;
			}

			WebCart newUserCart = new WebCart(
				Name = 'Cart',
				AccountId = accountId,
				Status = 'Active', 
				WebStoreId = webId
			);
			insert newUserCart;
  
		  	Id cartPayment = [SELECT Id, Cart_Payment__c FROM WebCart WHERE Id= :newUserCart.Id].Cart_Payment__c;
			  // // Get Current User Active Cart Delivery Group

			CartDeliveryGroup newCartDel = new CartDeliveryGroup(
				CartId = newUserCart.Id,
				Name = 'Default Delivery'
			);
			insert newCartDel;
			cartWrapper.cartId = newUserCart.Id;

			//loop on the contact list to populate record type of new values
			for (Contact con : learnerInfoList) {
				if(con.Id == null){
					con.RecordTypeId = RT_CONTACT_PERSON_ID;
				}
			}
			upsert learnerInfoList;
			
			for (Contact con : learnerInfoList) {
				
  
				//adding cart item to the cartItemList
  
				CartItem cItem = new CartItem();
				cItem.CartId = newUserCart.Id;
				cItem.CartDeliveryGroupId = newCartDel.Id;
				cItem.Name = wrappedData.productName;
				cItem.Contact__c = con.Id;
				cItem.Product2Id = Id.valueOf(wrappedData.productId);
				if (!boolean.valueOf(wrappedData.isPrescribed)) {
					cItem.Course_Offering__c = Id.valueOf(wrappedData.courseOfferingId);
				} else{
					cItem.Program_Offering__c = Id.valueOf(wrappedData.courseOfferingId);
				}
				if(wrappedData.category == CORPORATE_BUNDLE){
					cItem.Pricebook_Entry_ID__c = Id.valueOf(wrappedData.pricebookEntryId);
					cItem.TotalPrice = decimal.valueOf(wrappedData.pricebookUnitPrice);
				}else{
					cItem.Pricebook_Entry_ID__c = null;
				}
				// /cItem.Pricebook_Entry_ID__c = wrappedData.category == CORPORATE_BUNDLE ? Id.valueOf(wrappedData.pricebookEntryId) : '' ; // PUT EMPTY STRING IF NULL
				cItem.Quantity = 1;
				cItem.Type = 'Product';
				//cItem.TotalPrice = wrappedData.category == CORPORATE_BUNDLE ? decimal.valueOf(wrappedData.pricebookUnitPrice) : 0.00; // PUT ZERO IF NULL
				cartItemsToInsert.add(cItem);
			}
  
			if(wrappedData.category == CORPORATE_BUNDLE){
				//get the Product_Request__c from buyergroup
				prodReqId = [SELECT Id, BuyerGroup.Product_Request__c FROM BuyerGroupPricebook WHERE Pricebook2Id= :wrappedData.Pricebook2Id ].BuyerGroup.Product_Request__c;

				//get asset
				
				 assetId = [SELECT Id FROM Asset WHERE Product_Request__c= :prodReqId].Id;
			}
			
  
			if(!cartItemsToInsert.isEmpty()){ //insert cart Item per contact
				insert cartItemsToInsert;

				//update cartpaymentstatus
				Cart_Payment__c carpaymentstatus = new Cart_Payment__c(Id = cartPayment, Payment_Status__c = 'Approved');
				update carpaymentstatus;

				//end
				List <hed__Course_Enrollment__c> courseConnectionList = [
					SELECT Id, Name, Cart_ID__c, Cart_Item__c, Cart_Item__r.TotalPrice 
					FROM hed__Course_Enrollment__c 
					WHERE Cart_ID__c =:newUserCart.Id 
					AND ((RecordType.DeveloperName = 'Student' 
					AND Program_Offering__c = null) 
					OR (RecordType.DeveloperName = 'Student_Program' 
					AND hed__Course_Offering__c = null)) 
				];

				if(wrappedData.category == CORPORATE_BUNDLE){

        		// hed__Course_Enrollment__c pupdateCoursepayment = new hed__Course_Enrollment__c(Cart_ID__c = newUserCart.Id, Payment_Method__c  = '');
				// update pupdateCoursepayment;

				//update course enrollment object payment method empty(null) and pain in full should be 'Yes'

				// create product ledger per course connection
					List<Product_Ledger__c> prodLedgerList = new List<Product_Ledger__c>();
					for(hed__Course_Enrollment__c course : courseConnectionList){
						Product_Ledger__c prodLedge = new Product_Ledger__c ();
						prodLedge.Asset__c = assetId;
						prodLedge.Course_Connection__c = course.Id;
						prodLedge.Purchased_Price_v2__c = course.Cart_Item__r.TotalPrice;
						prodLedgerList.add(prodLedge);

					}
					insert(prodLedgerList);
				}

				//end of if block

				List<hed__Course_Enrollment__c> courseList = new List<hed__Course_Enrollment__c>();

				for(hed__Course_Enrollment__c currentCourse : courseConnectionList){
				
					hed__Course_Enrollment__c courseTemp = new hed__Course_Enrollment__c();
					courseTemp = currentCourse;
					courseTemp.Payment_Method__c = 'Contract';
					courseTemp.Paid_in_Full__c = wrappedData.category == CORPORATE_BUNDLE?'Yes':'Contract';
					courseList.add(courseTemp);
				}
				update courseList;
				
			}
			String externalId = [SELECT Id, Name, External_Id__c FROM WebCart WHERE Id = :newUserCart.Id LIMIT 1].External_Id__c;  
			cartWrapper.cartId = newUserCart.Id;
			cartWrapper.externalId = externalId;

		} catch (Exception e) {
			Logger.error('error on ProductDetailsCtrl.insertLearnerInfo').setExceptionDetails(e);
		} finally {
			if(Logger.getBufferSize() > 0) {
				Logger.saveLog();
			}
		}

		return cartWrapper;
	}


	//get external Id of cart, returns course or program data and it's learners
	@AuraEnabled
	public static RegistrationConfirmationData getRegistrationConfirmationData(String externalId){

	  RegistrationConfirmationData confirmationData = new RegistrationConfirmationData();

			
			//get cart using external id
			WebCart webcart = [
				SELECT 
					Id, 
					Name, 
					Cart_Payment__c,
					External_Id__c, Status
				FROM 
					WebCart 
				WHERE 
					External_Id__c =: externalId LIMIT 1
			];
			//assign data to wrapper
			confirmationData.externalId = webcart.External_Id__c;
			confirmationData.cartId = webcart.Id;
			confirmationData.cartPaymentId = webcart.Cart_Payment__c;

			// update web cart to closed manually 
			try{
				webcart.Status = 'Closed';
				UPDATE webcart;
			}catch(Exception e){
				Logger.error('error on updating Webcart').setExceptionDetails(e);
			} finally {
				if(Logger.getBufferSize() > 0) {
					Logger.saveLog();
				}
			}
			
			//get cart and course info through cart item
			CartItem cartandCourseDetails = [
				SELECT 
					Id, 
					Name,
					Course_Offering__c,
					Course_Offering__r.hed__Course__r.ProductRequestID__c,
					Course_Offering__r.hed__Start_Date__c,
					Course_Offering__r.Delivery_Type__c,
					Course_Offering__r.Available_Seats__c,
					Course_Offering__r.Total_Number_of_Registered_Learners__c,
					Program_Offering__c,
					Program_Offering__r.hed_Program_Plan__r.Product_Request__c,
					Program_Offering__r.Start_Date__c,
					Program_Offering__r.Delivery_Type__c,
					Program_Offering__r.Total_Number_of_Registered_Learners__c
			FROM CartItem WHERE CartId = :webcart.Id LIMIT 1];
			//assign  cartAndCourseDetails details
			confirmationData.cartAndCourseDetails = cartandCourseDetails;

			String offeringId;

			//get the course offering ID if for course
			if(cartandCourseDetails.Course_Offering__c != null){
				offeringId = cartandCourseDetails.Course_Offering__c;
			//else get the program offering ID
      }else{
				offeringId = cartandCourseDetails.Program_Offering__c;
      }

			//learners info; those who are enrolled in the course
			List<CartItem> learners = [
				SELECT 
					Id, 
					Contact__r.Name, 
					Contact__r.Email, 
					Contact__r.Position__c,
					Contact__r.Company_Name__c,
					Contact__r.ContactMobile_Locale__c,
					Contact__r.MobilePhone, 
					Contact__r.Birthdate, 
					Contact__r.Accessibility_Requirement__c,
					Contact__r.Dietary_Requirement__c 
				FROM 
					CartItem 
				WHERE 
					CartId =: webcart.Id 
				// AND 
				// 	((Program_Offering__c =: offeringId AND hed__Course_Offering__c = null) 
				// 		OR (hed__Course_Offering__c =: offeringId AND Program_Offering__c =  null))
			];
			//assign data to wrapper
			confirmationData.learners = learners;
			return confirmationData;
	}

	/**
	 * @description Inserts record to Expression of Intereset Object
	 * @param userId - Current logged in User Id
	 * @param productId - Product Id on productdetailpage
	 */
	@AuraEnabled
	public static void insertExpressionOfInterest(Id userId, Id productId) {
		User loggedInUser = [SELECT Id, Contact.Id FROM User WHERE Id = :userId];
		List<Expression_of_Interest__c> existingInterest = new List<Expression_of_Interest__c>(
			[
				SELECT Id
				FROM Expression_of_Interest__c
				WHERE
					Contact__c = :loggedInUser.Contact.Id
					AND Product__c = :productId
					AND Type__c = 'Register Interest'
					AND Status__c = 'Active'
			]
		);

		if (!existingInterest.isEmpty()) {
			AuraHandledException auraEx = new AuraHandledException(
				'Register Interest Exists'
			);
			throw auraEx;
		} else {
			Expression_of_Interest__c expressionOfInterest = new Expression_of_Interest__c(
				Contact__c = loggedInUser.Contact.Id,
				Product__c = productId,
				Type__c = 'Register Interest',
				Status__c = 'Active'
			);

			insert (expressionOfInterest);
		}
	}

	/**
	 * @description
	 * @param productRequestId -
	 * @return qrList -
	 */
	@AuraEnabled(cacheable=true)
	public static List<Related_Answer__c> getProductRequestWithQuestionnaire(
		String productRequestId
	) {
		List<Related_Answer__c> qrList = [
			SELECT
				Id,
				Question__r.Type__c,
				Question__r.Label__c,
				Sequence__c,
				Questionnaire__r.Parent_Record_ID__c,
				Question__r.Acceptable_Response__c,
				Question__r.Message__c,
				Questionnaire__r.Questionnaire_Type__c,
				Question__r.Dropdown_Options__c
			FROM Related_Answer__c
			WHERE
				Questionnaire__r.Parent_Record_ID__c = :productRequestId
				AND Questionnaire__r.Questionnaire_Type__c = 'Application Questions'
			ORDER BY Questionnaire__r.Questionnaire_Type__c, Sequence__c
		];
		return qrList;
	}

	/**
	 * @description
	 * @param productReqId -
	 * @return relatedAnswersList -
	 */
	@AuraEnabled(cacheable=true)
	public static List<Related_Answer__c> getQuestions(String productReqId) {
		List<Related_Answer__c> relatedAnswersList = new List<Related_Answer__c>(
			[
				SELECT
					Id,
					Question__r.Type__c,
					Question__r.Label__c,
					Sequence__c,
					Questionnaire__r.Parent_Record_ID__c,
					Question__r.Acceptable_Response__c,
					Question__r.Message__c,
					Questionnaire__r.Questionnaire_Type__c,
					Question__r.Dropdown_Options__c
				FROM Related_Answer__c
				WHERE
					Questionnaire__r.Parent_Record_ID__c = :productReqId
					AND Questionnaire__r.Questionnaire_Type__c = 'Application Questions'
				ORDER BY Questionnaire__r.Questionnaire_Type__c, Sequence__c
			]
		);
		return relatedAnswersList;
	}

	@AuraEnabled
	public static void saveApplication(
		String contactId,
		String offeringId,
		List<Related_Answer__c> relatedAnswerList,
		List<Answer__c> answerList,
		String fileUpload,
		Boolean isPrescribed,
		String pricebookEntryId
	) {
		List<FileUpload> parsedFileUpload = new List<FileUpload>();
		if (fileUpload != '') {
			parsedFileUpload = (List<FileUpload>) JSON.deserialize(
				fileUpload,
				List<FileUpload>.class
			);
		}

		List<Questionnaire_Response_Summary__c> questionnaireSummaryToInsert = new List<Questionnaire_Response_Summary__c>();
		Map<String, String> cvToRelatedAnswerMap = new Map<String, String>();
		List<ContentDocumentLink> contentDocLinkListToInsert = new List<ContentDocumentLink>();
		List<ContentVersion> cvListToInsertList = new List<ContentVersion>();
		Map<Id, Id> relatedAnswerToQuestionnaireMap = new Map<Id, Id>();
		Map<Id, Id> questionnaireToqResSummaryMap = new Map<Id, Id>();
		Map<Id, Id> relatedAnswerToAnswerMap = new Map<Id, Id>();
		Set<Id> questionnaireIds = new Set<Id>();

		List<Answer__c> answersToInsert = new List<Answer__c>();
		Map<Id, Answer__c> answersToUpdate = new Map<Id, Answer__c>();

		for (Related_Answer__c relatedA : relatedAnswerList) {
			questionnaireIds.add(relatedA.Questionnaire__c);
			relatedAnswerToQuestionnaireMap.put(
				relatedA.Id,
				relatedA.Questionnaire__c
			);
		}

		Questionnaire_Response_Summary__c qResSummary;

		for (Id qId : questionnaireIds) {
			qResSummary = new Questionnaire_Response_Summary__c();
			qResSummary.Questionnaire__c = qId;
			if (isPrescribed) {
				qResSummary.Program_Offering__c = offeringId;
			} else {
				qResSummary.Course_Offering__c = offeringId;
			}
			qResSummary.Contact__c = contactId;
			qResSummary.Application_Status__c = 'Pending';
			qResSummary.Pricebook_Entry_ID__c = pricebookEntryId;
			questionnaireSummaryToInsert.add(qResSummary);
		}

		if (!questionnaireSummaryToInsert.isEmpty()) {
			insert questionnaireSummaryToInsert;
		}

		for (
			Questionnaire_Response_Summary__c questionResSummary : questionnaireSummaryToInsert
		) {
			questionnaireToqResSummaryMap.put(
				questionResSummary.Questionnaire__c,
				questionResSummary.Id
			);
		}

		if (!answerList.isEmpty()) {
			for (Answer__c a : answerList) {
				a.Questionnaire_Response_Summary__c = questionnaireToqResSummaryMap.get(
					relatedAnswerToQuestionnaireMap.get(a.Related_Answer__c)
				);
				answersToInsert.add(a);
			}
			insert answersToInsert;
		}

		for (Answer__c ans : answersToInsert) {
			relatedAnswerToAnswerMap.put(ans.Related_Answer__c, ans.Id);
		}

		for (FileUpload file : parsedFileUpload) {
			if (relatedAnswerToAnswerMap.containsKey(file.RelatedAnswerId)) {
				ContentVersion cv = createContentVersion(file.Base64, file.FileName);
				cvToRelatedAnswerMap.put(cv.Title, file.RelatedAnswerId);
				cvListToInsertList.add(cv);
			}
		}

		if (!cvListToInsertList.isEmpty()) {
			insert cvListToInsertList;
		}

		List<ContentVersion> newContentVersionList = new List<ContentVersion>(
			[
				SELECT ContentDocumentId, Title
				FROM ContentVersion
				WHERE Id IN :cvListToInsertList
			]
		);

		if (!newContentVersionList.isEmpty()) {
			ContentDocumentLink cdl;
			Answer__c updateAnswer;
			for (ContentVersion cv : newContentVersionList) {
				cdl = new ContentDocumentLink(
					ContentDocumentId = cv.ContentDocumentId,
					LinkedEntityId = relatedAnswerToAnswerMap.get(
						cvToRelatedAnswerMap.get(cv.Title)
					),
					ShareType = 'V'
				);
				updateAnswer = new Answer__c(
					Id = cdl.LinkedEntityId,
					Response__c = cv.ContentDocumentId
				);
				answersToUpdate.put(updateAnswer.Id, updateAnswer);
				contentDocLinkListToInsert.add(cdl);
			}
		}

		if (!contentDocLinkListToInsert.isEmpty()) {
			insert contentDocLinkListToInsert;
		}

		if (!answersToUpdate.keySet().isEmpty()) {
			update answersToUpdate.values();
		}
	}
	/**
	 * @description
	 * @param base64 -
	 * @param filename -
	 * @return cv -
	 */
	private static ContentVersion createContentVersion(
		String base64,
		String filename
	) {
		ContentVersion cv = new ContentVersion();
		cv.VersionData = EncodingUtil.base64Decode(base64);
		cv.Title = filename;
		cv.PathOnClient = filename;
		return cv;
	}

	/**
	 * @description wrapper that contains Product Details & Pricebook entries
	 */
	public class ProductDetailsData {
		@AuraEnabled
		public Product2 productOnPage;
		@AuraEnabled
		public List<PricebookEntryWrapper> pricebookWrapperList;
		@AuraEnabled
		public List<DeliveryWrapper> deliveryWrapperList;
		@AuraEnabled
		public List<ModuleWrapper> moduleWrapperList;
		@AuraEnabled
		public Map<String, List<ProgramOfferingWrapper>> programDeliveryAndOfferingMap;
		@AuraEnabled
		public Boolean isNotFlexProgram;
		@AuraEnabled
		public List<childProduct> childProductList;
		@AuraEnabled
		public String priceCCE;
		@AuraEnabled
		public String pricebookEntryIdCCE;
		@AuraEnabled
		public String accountId{ get; set; }
		@AuraEnabled
		public String categoryName{ get; set; }
		@AuraEnabled
		public Id productId{ get; set; }
		@AuraEnabled
		public Id userId{ get; set; }
		@AuraEnabled
		public String assetId{ get; set; }
		@AuraEnabled
		public String buyerGroupId{ get; set; }
	}

	/**
	 * @description wrapper that contains list of pricebook entries
	 */
	public class PricebookEntryWrapper {
		@AuraEnabled
		public String label;
		@AuraEnabled
		public String value;
		@AuraEnabled
		public String meta;
		@AuraEnabled
		public Integer noOfDays;
	}

	/**
	 * @description wrapper that contains list of delivery options
	 */
	public class DeliveryWrapper {
		@AuraEnabled
		public String label;
		@AuraEnabled
		public String value;
	}

	/**
	 * @description wrapper that contains list of Course Offerings
	 */
	public class CourseOfferingWrapper {
		@AuraEnabled
		public String label;
		@AuraEnabled
		public String value;
		@AuraEnabled
		public String meta;
		@AuraEnabled
		public String defDeliv;
		@AuraEnabled
		public Decimal availableSeats;
		@AuraEnabled
		public String programPlan;
		@AuraEnabled
		public String course;
		@AuraEnabled
		public List<facilitatorWrapper> facilitator;
	}

	/**
	 * @description wrapper that contains the facilitator details
	 */
	public class facilitatorWrapper {
		@AuraEnabled
		public String facilitatorName { get; set; }
		@AuraEnabled
		public String facilitatorBio { get; set; }
		@AuraEnabled
		public String facilitatorImage { get; set; }
	}

	/**
	 * @description Wrapper class that holds the file uploaded by user
	 */
	public class FileUpload {
		@AuraEnabled
		public String Base64;
		@AuraEnabled
		public String FileName;
		@AuraEnabled
		public String RelatedAnswerId;
	}

	/**
	 * @description wrapper that contains the facilitator details
	 */
	public class childProduct {
		@AuraEnabled
		public String childProdId { get; set; }
		@AuraEnabled
		public String childProdName { get; set; }
		@AuraEnabled
		public String childProdDescription { get; set; }
		@AuraEnabled
		public String childProdProfLevel { get; set; }
		@AuraEnabled
		public String childProdOfferingDate { get; set; }
		@AuraEnabled
		public String childProdDelivery { get; set; }
		@AuraEnabled
		public String childProdPrice { get; set; }
		@AuraEnabled
		public String childProdDuration { get; set; }
		@AuraEnabled
		public Boolean isProgramFlex { get; set; }
		@AuraEnabled
		public String detailURL { get; set; }
	}

	/**
	 * @description wrapper that contains the additional data needed to insert records
	 */
	public class WrapperClass {
		@AuraEnabled
		public String courseOfferingId { get; set; }
		@AuraEnabled
		public String userId { get; set; }
		@AuraEnabled
		public String cartId { get; set; }
		@AuraEnabled
		public String productName { get; set; }
		@AuraEnabled
		public String productId { get; set; }
		@AuraEnabled
		public Boolean isPrescribed { get; set; }
		@AuraEnabled
		public String pricebookEntryId { get; set; }
		@AuraEnabled
		public String pricebookUnitPrice { get; set; }
		@AuraEnabled
		public String Pricebook2Id { get; set; }
		//category name for checking purposes
		@AuraEnabled
		public String category { get; set; } 
	}

		/**
	 * @description wrapper that contains the additional data needed to insert records
	 */
	public class CartWrapper{
		@AuraEnabled
		public String externalId { get; set; }
		@AuraEnabled
		public String cartId { get; set; }
		 
	}
	public class RegistrationConfirmationData{
		@AuraEnabled
		public String externalId { get; set; }
		@AuraEnabled
		public String userId { get; set; }
		@AuraEnabled
		public String cartId { get; set; }
		@AuraEnabled
		public String cartPaymentId { get; set; }
		@AuraEnabled
		public List<CartItem> learners { get; set; }
		@AuraEnabled
		public CartItem cartAndCourseDetails { get; set; }
		@AuraEnabled
		public hed__Course_Offering__c courseOffering { get; set; }
		@AuraEnabled
		public Program_Offering__c programOffering { get; set; }
	}

	@AuraEnabled(cacheable=true)
	public static List<ModuleWrapper> getProgramModules(String programPlanId) {
		List<ModuleWrapper> modules = new List<ModuleWrapper>();
		try {
			List<hed__Plan_Requirement__c> programPlanRequirements = [
				SELECT Id, 
				hed__Course__c, 
				hed__Sequence__c
				FROM hed__Plan_Requirement__c
				WHERE hed__Program_Plan__c = :programPlanId
				AND IsActive__c = TRUE
				AND hed__Course__c IN ( 
					SELECT Id 
					FROM hed__Course__c 
					WHERE ProductRequestID__r.Product_Request_Status__c = 'Published' )
				ORDER BY hed__Sequence__c
			];
			Map<Decimal, Id> coursesInPlanRequirements = new Map<Decimal, Id>();
			for (
				hed__Plan_Requirement__c programPlanRequirement : programPlanRequirements
			) {
				coursesInPlanRequirements.put(
					programPlanRequirement.hed__Sequence__c,
					programPlanRequirement.hed__Course__c
				);
			}
			List<Product2> courseProducts = [
				SELECT
					Id,
					Name,
					Duration__c,
					Delivery__c,
					Overview__c,
					Professional_Level__c,
					Course__c,
					Evolve_with_QUTeX__c,
					Who_Should_Participate__c,
					Core_Concepts__c,
					More_Details__c
				FROM Product2
				WHERE Course__c IN :coursesInPlanRequirements.values()
			];
			Map<Id, Product2> courseProductsMap = new Map<Id, Product2>();
			for (Product2 prod2 : courseProducts) {
				courseProductsMap.put(prod2.Course__c, prod2);
			}
			for (Decimal courseOrder : coursesInPlanRequirements.keySet()) {
				Id courseProductId = (Id) coursesInPlanRequirements.get(courseOrder);
				Product2 courseProduct = (Product2) courseProductsMap.get(
					courseProductId
				);
				ModuleWrapper moduleWrapper = new ModuleWrapper();
				moduleWrapper.id = courseProduct.Id;
				moduleWrapper.name = courseProduct.Name;
				moduleWrapper.duration = courseProduct.Duration__c;
				moduleWrapper.overview = courseProduct.Overview__c;
				moduleWrapper.professionalLevel = courseProduct.Professional_Level__c;
				moduleWrapper.evolveWithQUTeX = courseProduct.Evolve_with_QUTeX__c;
				moduleWrapper.whoShouldParticipate = courseProduct.Who_Should_Participate__c;
				moduleWrapper.coreConcepts = courseProduct.Core_Concepts__c;
				moduleWrapper.sequence = courseOrder;
				moduleWrapper.moreDetails = courseProduct.More_Details__c;
				modules.add(moduleWrapper);
			}
			return modules;
		} catch (Exception e) {
			AuraHandledException auraEx = new AuraHandledException(e.getMessage());
			throw auraEx;
		}
	}

	@AuraEnabled(cacheable=true)
	public static Map<String, List<ProgramOfferingWrapper>> getProgramOfferings(
		String programPlanId
	) {
		Map<String, List<ProgramOfferingWrapper>> programDeliveryAndOfferingMap = new Map<String, List<ProgramOfferingWrapper>>();
		try {
			List<Program_Offering__c> programOfferings = [
				SELECT
					Id,
					Available_Seats__c,
					Delivery_Type__c,
					Start_Date__c,
					End_Date__c,
					IsActive__c
				FROM Program_Offering__c
				WHERE
					hed_Program_Plan__c = :programPlanId
					AND IsActive__c = TRUE
					AND Available_Seats__c > 0
					AND Registration_Start_Date__c <= TODAY
					AND (Registration_End_Date__c = NULL
					OR Registration_End_Date__c > TODAY)
				ORDER BY Start_Date__c ASC
			];
			for (Program_Offering__c programOffering : programOfferings) {
				ProgramOfferingWrapper programOfferingWrapper = new ProgramOfferingWrapper();
				programOfferingWrapper.id = programOffering.Id;
				programOfferingWrapper.startDate = Datetime.newInstance(
						programOffering.Start_Date__c,
						Time.newInstance(0, 0, 0, 0)
					)
					.format('dd MMM yyyy');
				programOfferingWrapper.defDeliv = programOffering.Delivery_Type__c;
				programOfferingWrapper.availableSeats = programOffering.Available_Seats__c;
				List<ProgramOfferingWrapper> programOfferingWrapperList = new List<ProgramOfferingWrapper>();
				if (
					programDeliveryAndOfferingMap.get(programOffering.Delivery_Type__c) !=
					null
				) {
					programOfferingWrapperList = programDeliveryAndOfferingMap.get(
						programOffering.Delivery_Type__c
					);
				}
				programOfferingWrapperList.add(programOfferingWrapper);
				programDeliveryAndOfferingMap.put(
					programOffering.Delivery_Type__c,
					programOfferingWrapperList
				);
			}
			return programDeliveryAndOfferingMap;
		} catch (Exception e) {
			AuraHandledException auraEx = new AuraHandledException(e.getMessage());
			throw auraEx;
		}
	}

	/**
	 * @description wrapper that contains the details of a module
	 */
	public class ModuleWrapper {
		@AuraEnabled
		public String id { get; set; }
		@AuraEnabled
		public String name { get; set; }
		@AuraEnabled
		public String duration { get; set; }
		@AuraEnabled
		public String overview { get; set; }
		@AuraEnabled
		public String professionalLevel { get; set; }
		@AuraEnabled
		public Decimal sequence { get; set; }
		@AuraEnabled
		public String evolveWithQUTeX { get; set; }
		@AuraEnabled
		public String whoShouldParticipate { get; set; }
		@AuraEnabled
		public String coreConcepts { get; set; }
		@AuraEnabled
		public String moreDetails { get; set; }
	}

	public class ProgramOfferingWrapper {
		@AuraEnabled
		public String id { get; set; }
		@AuraEnabled
		public String startDate { get; set; }
		@AuraEnabled
		public String defDeliv { get; set; }
		@AuraEnabled
		public Decimal availableSeats { get; set; }
		@AuraEnabled
		public String label { get; set; }
		@AuraEnabled
		public String value { get; set; }
		@AuraEnabled
		public String meta { get; set; }
	}

	@AuraEnabled(cacheable=true)
	public static Map<String, Object> getProductDataRelatedToProductRequest(
		String productRequestId
	) {
		Map<String, Object> returnMap = new Map<String, Object>();
		String productType = '';
		Id productId;
		List<Product2> products;
		ProductDetailsData prodDetailsData;
		List<hed__Program_Plan__c> programPlans = [
			SELECT Id, Name, Product_Request__c, Program_Delivery_Structure__c
			FROM hed__Program_Plan__c
			WHERE Product_Request__c = :productRequestId
		];
		if (programPlans.size() > 0) {
			products = [
				SELECT
					Id,
					Name,
					Program_Plan__c,
					Program_Plan__r.Program_Delivery_Structure__c
				FROM Product2
				WHERE Program_Plan__c = :programPlans[0].Id
			];
			if (products.size() > 0) {
				if (
					programPlans[0].Program_Delivery_Structure__c == 'Prescribed Program'
				) {
					productType = 'Prescribed Program';
					prodDetailsData = getProductRelatedRecords(products[0].Id);
					returnMap.put('product', prodDetailsData);
				} else if (
					programPlans[0].Program_Delivery_Structure__c == 'Flexible Program'
				) {
					productType = 'Flexible Program';
					prodDetailsData = getProductRelatedRecords(products[0].Id);
					returnMap.put('product', prodDetailsData);
				}
			}
		} else {
			List<hed__Course__c> courses = [
				SELECT
					Id,
					Name,
					ProductRequestID__c,
					ProductRequestID__r.Child_of_Prescribed_Program__c
				FROM hed__Course__c
				WHERE ProductRequestID__c = :productRequestId
			];
			if (courses.size() > 0) {
				products = [
					SELECT Id, Name
					FROM Product2
					WHERE Course__c = :courses[0].Id
				];
				productId = products[0].Id;
				if (
					courses[0].ProductRequestID__r.Child_of_Prescribed_Program__c == true
				) {
					productType = 'Prescribed Program Module';
					List<hed__Plan_Requirement__c> programPlanRequirements = [
						SELECT Id, 
						hed__Course__c, 
						hed__Sequence__c, 
						hed__Program_Plan__c
						FROM hed__Plan_Requirement__c
						WHERE 
						IsActive__c = TRUE
						AND hed__Course__c = :courses[0].Id
					];
					Id programPlanId = programPlanRequirements[0].hed__Program_Plan__c;
					Id parentProductId = [
						SELECT Id
						FROM Product2
						WHERE Program_Plan__c = :programPlanId
					]
					.Id;
					//Call getProductRelatedRecords(productId);
					prodDetailsData = getProductRelatedRecords(parentProductId);
					List<ModuleWrapper> modules = prodDetailsData.moduleWrapperList;
					for (ModuleWrapper module : modules) {
						if (module.id == productId) {
							returnMap.put('product', module);
							break;
						}
					}
					returnMap.put('parent', prodDetailsData);
				} else {
					productType = 'Single Product';
					//Call getProductRelatedRecords(productId);
					prodDetailsData = getProductRelatedRecords(productId);
					returnMap.put('product', prodDetailsData);
				}
			}
		}
		returnMap.put('productType', productType);
		returnMap.put('productId', productId);
		return returnMap;
	}

	@AuraEnabled(cacheable=true)
	public static List<Related_Answer__c> getQuestionsForGroupBooking(
		String productReqId
	) {
		List<Related_Answer__c> relatedAnswersList = new List<Related_Answer__c>(
			[
				SELECT
					Id,
					Question__r.Type__c,
					Question__r.Label__c,
					Sequence__c,
					Questionnaire__r.Parent_Record_ID__c,
					Question__r.Acceptable_Response__c,
					Question__r.Message__c,
					Questionnaire__r.Questionnaire_Type__c,
					Question__r.Dropdown_Options__c
				FROM Related_Answer__c
				WHERE
					Questionnaire__r.Parent_Record_ID__c = :productReqId
					AND Questionnaire__r.Questionnaire_Type__c = 'Registration Questions'
				ORDER BY Questionnaire__r.Questionnaire_Type__c, Sequence__c
			]
		);
		return relatedAnswersList;
	}

	@AuraEnabled
	public static List<Contact> saveContactData(String contactDataString) {
		List<Contact> contactList = (List<Contact>) System.JSON.deserializeStrict(
			contactDataString,
			List<Contact>.class
		);
		Database.insert(contactList);
		return contactList;
	}
	@AuraEnabled
	public static List<Contact> getContactAccountId(Id connId) {
		return [
			SELECT Id, FirstName, LastName, Account.Name, Account.Id
			FROM Contact
			WHERE Id = :connId
		];
	}
	@AuraEnabled
	public static List<Contact> getUserContactDetails(Id connId) {
		return [
			SELECT Id, FirstName, LastName, Email
			FROM Contact
			WHERE Id = :connId
		];
	}

	@AuraEnabled
	public static WebCart getUserCartDetails(Id userId) {
		return [
			SELECT
				Id,
				OwnerId,
				Name,
				WebStoreId,
				AccountId,
				External_Id__c,
				Amount_Paid__c,
				Status,
				Cart_Payment__c
			FROM WebCart
			WHERE OwnerId = :userId AND Status = :'Active'
			LIMIT 1
		];
	}
	@AuraEnabled
	public static PricebookEntry getPricebookEntryPrice(Id pricebookId) {
		return [
			SELECT Id, Name, Pricebook2Id, Product2Id, UnitPrice
			FROM PricebookEntry
			WHERE Id = :pricebookId
			LIMIT 1
		];
	}

	/**
	 * @description Gets related products for tailored executive 
	 * @param bgIds - Buyer Group Id of the selected account
	 * @param productId - Id of the Selected Product
	 * @return hasProducts - Boolean that checks the product Id is in the Entilement Policy
	 */
	@AuraEnabled
	public static Boolean checkProductsForTailored(List<String> bgIds , Id productId) {

		Boolean hasProducts;
		// Query list of entilement policy
		Set<Id> policyIdSet = new Set<Id>();
		List<CommerceEntitlementBuyerGroup> cembgList = [SELECT PolicyId, BuyerGroupId FROM CommerceEntitlementBuyerGroup WHERE BuyerGroupId IN :bgIds];

		//Store List of Policy Id inside the Set
		for(CommerceEntitlementBuyerGroup cembg : cembgList){
			if(String.isNotEmpty(cembg.PolicyId)){
				policyIdSet.add(cembg.PolicyId);
			}
		}

		if(!policyIdSet.isEmpty()){
			List<CommerceEntitlementProduct> cep = [SELECT PolicyId, ProductId 
												FROM CommerceEntitlementProduct 
												WHERE PolicyId IN :policyIdSet  
												AND ProductId =: productId];
			hasProducts = !cep.isEmpty()? true : false;
		}
		return hasProducts;
	}

}
