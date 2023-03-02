/**
 * @description Controller Class for list of products to be displayed in Product Listing Page
 * @see ../lwc/productDetails
 * @author Accenture
 * @history
 | Developer                 | Date                  | JIRA                 | Change Summary                             |
 |---------------------------|-----------------------|----------------------|--------------------------------------------|
 | mary.grace.li             | May 02, 2022          | DEPP-1269            | Created File                               |
 | eugene.andrew.abuan       | May 02, 2022          | DEPP-1269            | Modified Ctrl to Map fields                |
 | eugene.andrew.abuan       | May 09, 2022          | DEPP-1979            | Added getFilteredProducts function         |
 | keno.domienri.dico        | May 19, 2022          | DEPP-1980            | Added sorting of courses                   |
 | john.bo.a.pineda          | June 01, 2022         | DEPP-2853            | Updated Registration Dates Logic           |
 | mary.grace.li             | July 01, 2022         | DEPP-3124            | Added new field DetailURL for SEO          |
 | john.bo.a.pineda          | June 11, 2022         | DEPP-3460            | Updated to get Detail_URL__c for Price Sort|
 | keno.domienri.dico		 | August 24, 2022		 | DEPP-3765			| Added product category get method			 |
 | eugene.andrew.abuan       | September 08, 2022    | DEPP-4191            | Adjusted product_type__c in product        |
 |                           |                       |                      | category get method                        |
 | julie.jane.alegre         | September 21, 2022    | DEPP-4399            | Add filter for Product Request on Published|
 | keno.domienri.dico		 | September 28, 2022	 | DEPP-4459 & 4461		| Added new parameter for getProductsByCategory |
 | julie.jane.alegre         | December  12, 2022    | DEPP-4667            | Add Corporate Bundle info in product list  |
 | mary.grace.li             | November 22, 2022     | DEPP-4693            | Modified for Selected account logic        |
 | mary.grace.li             | December  21, 2022    | DEPP-4878            | Added product full detail url for SEO      |

 */
public without sharing class ProductCtrl{

	//burhan
	private final static String STR_SORT_PRICE_LOWTOHIGH = 'priceLowToHigh';
	private final static String STR_SORT_PRICE_HIGHTOLOW = 'priceHighToLow';
	private final static String STR_SORT_COMINGUP = 'comingUp';
	private final static String STR_SORT_NEWLYADDED = 'newlyAdded';

	/**
	 * @description fetches course offerings and pricebooks related to the products
	 * @param productIds - List of Products under the Category
	 * @return course offerings and pricebook entries related to the product
	 */
	@AuraEnabled(cacheable = true)
	public static ProductData getProducts(List<String> productIds, String sortCourse){
		ProductData prodData = new ProductData();
		List<ProductWrapper> prodWrapperList = new List<ProductWrapper>();
		String standardPriceBook = 'Standard Price Book';
		String earlyBirdPricebook = 'Early Bird';
		String freePricebook = 'Free';

		if (sortCourse == STR_SORT_PRICE_LOWTOHIGH || sortCourse == STR_SORT_PRICE_HIGHTOLOW){
			List<PricebookEntry> priceProductList = new List<PricebookEntry>();

			// New Query with selected productIds per page
			String pbeQuery = 'SELECT Id, Name, Pricebook2.ID, Pricebook2.Name, UnitPrice, ';
			pbeQuery += ' Product2.Id, Product2.Name, Product2.Description, Product2.Professional_level__c, Product2.Duration__c, Product2.Delivery__c, Product2.Detail_URL__c, Product2.Detail_Full_URL__c, Product2.Program_Plan__c, Product2.Course__c ';
			pbeQuery += ' FROM PricebookEntry ';
			pbeQuery += ' WHERE Product2Id IN :productIds';
			pbeQuery += ' AND (Pricebook2.Name = :standardPriceBook OR Pricebook2.Name = :earlyBirdPricebook OR Pricebook2.Name = :freePricebook) ';
			pbeQuery += ' AND IsActive = True AND Product2.Available_on_Cart__c = TRUE';
			pbeQuery += ' ORDER BY UnitPrice ASC';

			priceProductList = Database.query(pbeQuery);

			//--new---
			map<id, Product2> productMap = new map<id, Product2>();
			map<id, String> productURLMap = new Map<id, String>();
			map<id, String> productFullURLMap = new Map<id, String>();
			map<id, PricebookEntry> peMap = new map<id, PricebookEntry>();
			Map<Id, Id> productPriceFreeMap = new Map<Id, Id>();
			Map<Id, Id> productPriceEarlyBirdMap = new Map<Id, Id>();
			Map<Id, Id> productPriceStandardMap = new Map<Id, Id>();
			Product2 myProduct;
			for(PricebookEntry data : priceProductList){
				if(!productMap.containsKey(data.Product2Id)){
					myProduct = new Product2();
					myProduct.Id = data.Product2Id;
					myProduct.Name = data.Product2.Name;
					myProduct.Description = data.Product2.Description;
					myProduct.Professional_level__c = data.Product2.Professional_level__c;
					myProduct.Duration__c = data.Product2.Duration__c;
					myProduct.Delivery__c = data.Product2.Delivery__c;
					myProduct.Program_Plan__c = data.Product2.Program_Plan__c;
					myProduct.Course__c = data.Product2.Course__c;
					myProduct.Program_Plan__c = data.Product2.Program_Plan__c;
					productURLMap.put(data.Product2Id, data.Product2.Detail_URL__c);
					productFullURLMap.put(data.Product2Id, data.Product2.Detail_Full_URL__c);
					productMap.put(data.Product2Id, myProduct);
				}

				if(!peMap.containsKey(data.Id)){
					peMap.put(data.Id, data);
				}

				if(data.Pricebook2.Name == freePricebook){
					productPriceFreeMap.put(data.Product2Id, data.Id);
				}else if(data.Pricebook2.Name == earlyBirdPricebook){
					productPriceEarlyBirdMap.put(data.Product2Id, data.Id);
				}else {
					productPriceStandardMap.put(data.Product2Id, data.Id);
				}
			}

			Map<Id, Product2> finalProductMap = new Map<Id, Product2>();
			Map<Id, Double> productPriceMap = new Map<Id, Double>();
			for(Id productId : productMap.keySet()){
				if(!finalProductMap.containsKey(productId)){//check if product does not exist
					if(productPriceFreeMap.containsKey(productId)){
						PricebookEntry pe = peMap.get(productPriceFreeMap.get(productId));
						finalProductMap.put(productId, productMap.get(productId));
						productPriceMap.put(productId, pe.UnitPrice);
						continue;
					}

					if(productPriceEarlyBirdMap.containsKey(productId)){
						PricebookEntry pe = peMap.get(productPriceEarlyBirdMap.get(productId));
						finalProductMap.put(productId, productMap.get(productId));
						productPriceMap.put(productId, pe.UnitPrice);
						continue;
					}

					if(productPriceStandardMap.containsKey(productId)){
						PricebookEntry pe = peMap.get(productPriceStandardMap.get(productId));
						finalProductMap.put(productId, productMap.get(productId));
						productPriceMap.put(productId, pe.UnitPrice);
					}
				}
			}
			//-----

			//Get Id of the course/program plan based on the product
			Set<Id> courseIdSet = new Set<Id>();
			Set<Id> programIdSet = new Set<Id>();

			for (PricebookEntry p : priceProductList){
				if (String.isNotBlank(p.Product2.Program_Plan__c)){
					programIdSet.add(p.Product2.Program_Plan__c);
				} else{
					courseIdSet.add(p.Product2.Course__c);
				}
			}

			//Single Product(Course)
			Map<Id, Date> prodCourseDateMap = new Map<Id, Date>();
			// Map Child Product Earliest Course Offering Date
			List<AggregateResult> startDateListCourse = [SELECT hed__Course__c, MIN(hed__Start_Date__c)startDate
														 FROM hed__Course_Offering__c
														 WHERE hed__Start_Date__c >= TODAY
														 AND Registration_Start_Date__c <= TODAY
														 AND (Registration_End_Date__c = NULL OR Registration_End_Date__c > TODAY)
														 AND IsActive__c = TRUE
														 AND Available_Seats__c > 0
														 AND hed__Course__c IN:courseIdSet
														 GROUP BY hed__Course__c];
			for (AggregateResult startDate : startDateListCourse){
				prodCourseDateMap.put((Id) startDate.get('hed__Course__c'), (Date) startDate.get('startDate'));
			}

			//Program Product (Program Plan)
			Map<Id, Date> prodProgramDateMap = new Map<Id, Date>();
			// Map Child Product Earliest Program Offering Date
			List<AggregateResult> startDateListProgram = [SELECT hed_Program_Plan__c, MIN(Start_Date__c)startDate
														  FROM Program_Offering__c
														  WHERE Start_Date__c >= TODAY
														  AND Registration_Start_Date__c <= TODAY
														  AND (Registration_End_Date__c = NULL OR Registration_End_Date__c > TODAY)
														  AND IsActive__c = TRUE
														  AND Available_Seats__c > 0
														  AND hed_Program_Plan__c IN:programIdSet
														  GROUP BY hed_Program_Plan__c];
			for (AggregateResult startDate : startDateListProgram){
				prodProgramDateMap.put((Id) startDate.get('hed_Program_Plan__c'), (Date) startDate.get('startDate'));
			}

			//--new---
			Map<Id, Product2> allInputProductMap = new Map<Id, Product2>([
				SELECT Id, Name, Description, Program_Plan__c, Professional_level__c, Duration__c, Delivery__c, Course__c, Program_Plan__r.Program_Delivery_Structure__c, Detail_Full_URL__c
				FROM Product2
				WHERE Id IN :productIds
			]);

			ProductWrapper productListWrapper;
			for(Product2 product : finalProductMap.values()){
				productListWrapper = new ProductWrapper();
				productListWrapper.childProdId = product.Id;
				productListWrapper.childProdName = product.Name;
				productListWrapper.childProdDescription = product.Description;
				productListWrapper.isProgramFlex = true;

				if (String.isBlank(product.Program_Plan__c) || ((String.isNotBlank(product.Program_Plan__c)) && allInputProductMap.get(product.Id).Program_Plan__r.Program_Delivery_Structure__c == 'Prescribed Program')){
					productListWrapper.childProdProfLevel = product.Professional_level__c;
					productListWrapper.childProdDuration = product.Duration__c;
					productListWrapper.isProgramFlex = false;

					if (String.isnotblank(product.Delivery__c)){
						productListWrapper.childProdDelivery = product.Delivery__c.replace(';', ',');
					}

					if (String.isBlank(product.Program_Plan__c)){
						//Course Offering -> Single Product
						if (prodCourseDateMap.containsKey(product.Course__c)){
							productListWrapper.childProdOfferingDate = Datetime.newInstance(prodCourseDateMap.get(product.Course__c), Time.newInstance(0, 0, 0, 0)).format('dd MMM yyyy');
						}
					} else{
						//Product Offering -> Presrcibed Product
						if (prodProgramDateMap.containsKey(product.Program_Plan__c)){
							productListWrapper.childProdOfferingDate = Datetime.newInstance(prodProgramDateMap.get(product.Program_Plan__c), Time.newInstance(0, 0, 0, 0)).format('dd MMM yyyy');
						}
					}

					//Get Price
					productListWrapper.childProdPrice = String.valueOf(productPriceMap.get(product.Id));
				}

				productListWrapper.detailURL = productURLMap.get(product.Id);
				productListWrapper.fullDetailURL = productFullURLMap.get(product.Id);
				prodWrapperList.add(productListWrapper);
			}

			if (sortCourse == STR_SORT_PRICE_HIGHTOLOW){//just reverse the list order from ASC SOQL
				List<ProductWrapper> tempIdList = new List<ProductWrapper>();
				for(Integer i = prodWrapperList.size() - 1; i >= 0; i--){
					tempIdList.add(prodWrapperList.get(i));
				}

				prodWrapperList = tempIdList;
			}

			//append all flexible product to the end of the list, since they are not included from the SOQL of PricebookEntry
			ProductWrapper flexiProductWrapper;
			for(String id : productIds){
				if(finalProductMap.keySet().contains(id)){
					continue;
				}

				if(!allInputProductMap.containsKey(id)){
					continue;
				}

				Product2 product = allInputProductMap.get(id);

				if(product.Program_Plan__r.Program_Delivery_Structure__c != 'Flexible Program'){
					continue;
				}

				flexiProductWrapper = new ProductWrapper();
				flexiProductWrapper.childProdId = product.Id;
				flexiProductWrapper.childProdName = product.Name;
				flexiProductWrapper.childProdDescription = product.Description;
				flexiProductWrapper.isProgramFlex = true;
				flexiProductWrapper.fullDetailURL = product.Detail_Full_URL__c;

				prodWrapperList.add(flexiProductWrapper);
			}
		} else{
			// Sort for Dates (Start Date ASC / Publishing Date DESC)
			List<Product2> productList = new List<Product2>();

			String getQuery = '';
			String dateQry = '';

			String prodQry1 = 'SELECT Id, Name, Course__c, Duration__c, Detail_URL__c, Detail_Full_URL__c, Delivery__c, Professional_Level__c, Available_on_Cart__c, Start_Date__c, Description, ';
			String prodQry2 = ' Program_Plan__r.Program_Delivery_Structure__c, ';
			prodQry2 += ' ( SELECT Id, Pricebook2.Name, UnitPrice FROM PricebookEntries WHERE IsActive = TRUE AND (Pricebook2.Name = :standardPriceBook OR Pricebook2.Name = :earlyBirdPricebook OR Pricebook2.Name =:freePricebook)) ';
			prodQry2 += ' FROM Product2 ';
			prodQry2 += ' WHERE Id IN :productIds AND Available_on_Cart__c = TRUE ';

			if (sortCourse == STR_SORT_NEWLYADDED){
				dateQry += ' ORDER BY Publishing_Start_date__c DESC';
			}

			// Query List of Products under the category
			getQuery = prodQry1 + prodQry2 + dateQry;
			productList = Database.query(getQuery);

			if (sortCourse == STR_SORT_COMINGUP){
				Map<Id, Product2> productMap = new Map<Id, Product2>(productList);
				List<Product2> sortedProductList = new List<Product2>();
				for (String id : productIds){
					if (productMap.containsKey(id) ){
						sortedProductList.add(productMap.get(id) );
					}
				}
				productList = sortedProductList;
			}

			//Get Id of the course/program plan based on the product
			Set<Id> courseIdSet = new Set<Id>();
			Set<Id> programIdSet = new Set<Id>();

			for (Product2 p : productList){
				if (String.isNotBlank(p.Program_Plan__c)){
					programIdSet.add(p.Program_Plan__c);
				} else{
					courseIdSet.add(p.Course__c);
				}
			}

			//Single Product(Course)
			Map<Id, Date> prodCourseDateMap = new Map<Id, Date>();
			// Map Child Product Earliest Course Offering Date
			List<AggregateResult> startDateListCourse = [SELECT hed__Course__c, MIN(hed__Start_Date__c)startDate
														 FROM hed__Course_Offering__c
														 WHERE hed__Start_Date__c >= TODAY
														 AND Registration_Start_Date__c <= TODAY
														 AND (Registration_End_Date__c = NULL OR Registration_End_Date__c > TODAY)
														 AND IsActive__c = TRUE
														 AND Available_Seats__c > 0
														 AND hed__Course__c IN:courseIdSet
														 GROUP BY hed__Course__c];
			for (AggregateResult startDate : startDateListCourse){
				prodCourseDateMap.put((Id) startDate.get('hed__Course__c'), (Date) startDate.get('startDate'));
			}
			//Program Product (Program Plan)
			Map<Id, Date> prodProgramDateMap = new Map<Id, Date>();
			// Map Child Product Earliest Program Offering Date
			List<AggregateResult> startDateListProgram = [SELECT hed_Program_Plan__c, MIN(Start_Date__c)startDate
														  FROM Program_Offering__c
														  WHERE Start_Date__c >= TODAY
														  AND Registration_Start_Date__c <= TODAY
														  AND (Registration_End_Date__c = NULL OR Registration_End_Date__c > TODAY)
														  AND IsActive__c = TRUE
														  AND Available_Seats__c > 0
														  AND hed_Program_Plan__c IN:programIdSet
														  GROUP BY hed_Program_Plan__c];
			for (AggregateResult startDate : startDateListProgram){
				prodProgramDateMap.put((Id) startDate.get('hed_Program_Plan__c'), (Date) startDate.get('startDate'));
			}

			//Process List of Products
			for (Product2 prod : productList){
				ProductWrapper productListWrapper = new ProductWrapper();
				//Flexible Program Plan -> Id, Name, Description
				productListWrapper.childProdId = prod.Id;
				productListWrapper.childProdName = prod.Name;
				productListWrapper.childProdDescription = prod.Description;
				productListWrapper.isProgramFlex = true;

				// Product is Single and Prescribed Program Plan
				if (String.isBlank(prod.Program_Plan__c) || ((String.isNotBlank(prod.Program_Plan__c)) && prod.Program_Plan__r.Program_Delivery_Structure__c == 'Prescribed Program')){
					// single product
					productListWrapper.childProdProfLevel = prod.Professional_level__c;
					productListWrapper.childProdDuration = prod.Duration__c;
					productListWrapper.isProgramFlex = false;
					if (String.isnotblank(prod.Delivery__c)){
						productListWrapper.childProdDelivery = prod.Delivery__c.replace(';', ',');
					}
					if (String.isBlank(prod.Program_Plan__c)){
						//Course Offering -> Single Product
						if (prodCourseDateMap.containsKey(prod.Course__c)){
							productListWrapper.childProdOfferingDate = Datetime.newInstance(prodCourseDateMap.get(prod.Course__c), Time.newInstance(0, 0, 0, 0)).format('dd MMM yyyy');
						}
					} else{
						//Product Offering -> Presrcibed Product
						if (prodProgramDateMap.containsKey(prod.Program_Plan__c)){
							productListWrapper.childProdOfferingDate = Datetime.newInstance(prodProgramDateMap.get(prod.Program_Plan__c), Time.newInstance(0, 0, 0, 0)).format('dd MMM yyyy');
						}
					}
					//Product Pricebook Entries
					Map<String, String> prodPBEntryMap = new Map<String, String>();
					if (!prod.PricebookEntries.isEmpty()){
						for (PricebookEntry productPBookEntry : prod.PricebookEntries){
							prodPBEntryMap.put(productPBookEntry.Pricebook2.Name, String.valueOf(productPBookEntry.UnitPrice));
						}
					}
					//Get Price
					if (prodPBEntryMap.containsKey('Free')){
						productListWrapper.childProdPrice = prodPBEntryMap.get('Free');
					} else{
						productListWrapper.childProdPrice = prodPBEntryMap.get('Standard Price Book');
						if (prodPBEntryMap.containsKey('Early Bird')){
							productListWrapper.childProdPrice = prodPBEntryMap.get('Early Bird');
						}
					}
				}
				productListWrapper.detailURL = prod.Detail_URL__c;
				productListWrapper.fullDetailURL = prod.Detail_Full_URL__c;
				prodWrapperList.add(productListWrapper);
			}
		}
		//Set values to wrapper
		prodData.productList = prodWrapperList;
		return prodData;
	}

	/**
	 * @description filters products based on the selected filter
	 * @param productAllId - List of Products under the Category
	 * @param filterData - Filter parameters
	 * @return List of productId that meets the ID
	 */	@AuraEnabled(cacheable = true)
	public static FilterData getFilteredProducts(List<String> productAllId, FilterWrapper filterData){
		FilterData prodData = new FilterData();
		List<Product2> filterDataList = new List<Product2>();
		List<Id> filteredProductId = new List<Id>();
		String standardPriceBook = 'Standard Price Book';
		String earlyBirdPricebook = 'Early Bird';
		String freePricebook = 'Free';
		String studyAreaValue = '';
		String deliveryTypeValue = '';
		String productTypeValue = '';
		String prodSortBy = filterData.sortBy;

		// Dynamic Query that matches the selected filter
		String filterProductsQuery = 'SELECT Id, Name, Course__c, Program_Plan__c, Publishing_Start_date__c, Program_Plan__r.Program_Delivery_Structure__c ';
		filterProductsQuery += ', (SELECT UnitPrice, Pricebook2.Name, Pricebook2.Id, Product2Id FROM PricebookEntries WHERE (Pricebook2.Name = :standardPriceBook OR Pricebook2.Name = :earlyBirdPricebook OR Pricebook2.Name = :freePricebook))';
		filterProductsQuery += ' FROM Product2 ';
		filterProductsQuery += ' WHERE Id IN :productAllId AND Available_on_Cart__c = TRUE';

		//Checks if Search Key is Empty
		if (String.isNotEmpty(filterData.searchKey)){
			String key = '%' + filterData.searchKey + '%';
			filterProductsQuery += ' AND (Name LIKE :key OR Description LIKE :key )';
		}

		//Checks if Study Area if Empty
		if (filterData.studyArea.size() > 0){
			for (String val : filterData.studyArea){
				studyAreaValue += '\'' + val + '\' ' + ',';
			}
			studyAreaValue = studyAreaValue.substring(0, studyAreaValue.length() - 1);
			filterProductsQuery +=
			' AND Study_Area__c INCLUDES (' + studyAreaValue +
			')';
		}

		//Checks if Delivery is Empty
		if (filterData.deliveryType.size() > 0){
			for (String val : filterData.deliveryType){
				deliveryTypeValue += '\'' + val + '\' ' + ',';
			}
			deliveryTypeValue = deliveryTypeValue.substring(0, deliveryTypeValue.length() - 1);
			filterProductsQuery +=
			' AND Delivery__c INCLUDES (' + deliveryTypeValue +
			')';
		}

		//Checks if ProductType is Empty
		if (filterData.productType.size() > 0){
			for (String val : filterData.productType){
				productTypeValue += '\'' + String.escapeSingleQuotes(val) + '\' ' + ',';
			}
			productTypeValue = productTypeValue.substring(0, productTypeValue.length() - 1);
			filterProductsQuery +=
			' AND Product_Type__c IN (' + productTypeValue +
			')';
		}

		if (filterData.sortBy == STR_SORT_NEWLYADDED){
			filterProductsQuery += ' ORDER BY Publishing_Start_date__c DESC';
		}

		//Queries based on Product objects
		filterDataList = Database.query(filterProductsQuery); //NOPMD
		// Complex query. Single quote escape handled prior to this line.

		List<Product2> filteredProductList = new List<Product2>();
		Map<Id, Product2> allInputProductMap = new Map<Id, Product2>(filterDataList);

		//SOQL for product price, this will also exclude flexible products which needs to be added at the end of the list, sort ASC so that free products will be placed first in the list
		Map<Id, PricebookEntry> pricebookEntryMap = new Map<Id, PricebookEntry>([
			SELECT Id, Pricebook2.Name, UnitPrice, Product2Id, Product2.Name
			FROM PricebookEntry
			WHERE IsActive = true
			AND Product2Id IN :allInputProductMap.keySet()
			AND (Pricebook2.Name = :standardPriceBook OR Pricebook2.Name = :earlyBirdPricebook OR Pricebook2.Name = :freePricebook)
			ORDER BY UnitPrice ASC
		]);

		List<Id> duplicateFilterList = new List<Id>();//this list will only hold the cheapest price
		Map<Id, Product2> filteredProductMap = new Map<Id, Product2>();

		for(PricebookEntry data : pricebookEntryMap.values()){
			if(filteredProductMap.containsKey(data.Product2Id)){
				continue;
			}

			if(duplicateFilterList.contains(data.Product2Id)){
				continue;
			}

			if(!allInputProductMap.containsKey(data.Product2Id)){//negate
				continue;
			}

			duplicateFilterList.add(data.Product2Id);

			if(filterData.minUnitPrice != null && data.UnitPrice < filterData.minUnitPrice){
				continue;
			}

			if(filterData.maxUnitPrice != null && data.UnitPrice > filterData.maxUnitPrice){
				continue;
			}

			filteredProductMap.put(data.Product2Id, allInputProductMap.get(data.Product2Id));
		}

		filteredProductList.addAll(filteredProductMap.values());

		Set<Id> courseIdSet = new Set<Id>();
		Set<Id> programIdSet = new Set<Id>();

		for (Product2 p : filteredProductList){
			if (String.isNotBlank(p.Program_Plan__c)){
				programIdSet.add(p.Program_Plan__c);
			} else{
				courseIdSet.add(p.Course__c);
			}
		}

		Set<Id> prodCourseStartDateId = new Set<Id>();
		Set<Id> prodProgramStartDateId = new Set<Id>();

		if (filterData.startDate != null || filterData.endDate != null){
			Date sDate ;
			Date eDate ;
			if(filterData.startDate != null){
				sDate = Date.parse(filterData.startDate);
			}
			if(filterData.endDate !=null){
				eDate = Date.parse(filterData.endDate);
			}

			List<AggregateResult> startDateListCourse = [
				SELECT hed__Course__c, MIN(hed__Start_Date__c) startDate
				FROM hed__Course_Offering__c
				WHERE
					hed__Start_Date__c >= TODAY
					AND Registration_Start_Date__c <= TODAY
					AND (Registration_End_Date__c = NULL OR Registration_End_Date__c > TODAY)
					AND IsActive__c = TRUE
					AND Available_Seats__c > 0
					AND hed__Course__c IN :courseIdSet
				GROUP BY hed__Course__c
			];

			for (AggregateResult startDate : startDateListCourse){
				if(filterData.startDate != null && filterData.endDate == null && (Date) startDate.get('startDate') >= sDate){
					prodCourseStartDateId.add((Id) startDate.get('hed__Course__c'));
				}else if(filterData.endDate != null && filterData.startDate == null && (Date) startDate.get('startDate') <= eDate){
					prodCourseStartDateId.add((Id) startDate.get('hed__Course__c'));
				}else if(filterData.endDate != null && filterData.startDate != null && (Date) startDate.get('startDate') <= eDate && (Date) startDate.get('startDate') >= sDate){
					prodCourseStartDateId.add((Id) startDate.get('hed__Course__c'));
				}
			}

			List<AggregateResult> startDateListProgram = [
				SELECT hed_Program_Plan__c, MIN(Start_Date__c) startDate
				FROM Program_Offering__c
				WHERE
					Start_Date__c >= TODAY
					AND Registration_Start_Date__c <= TODAY
					AND (Registration_End_Date__c = NULL OR Registration_End_Date__c > TODAY)
					AND IsActive__c = TRUE
					AND Available_Seats__c > 0
					AND hed_Program_Plan__c IN :programIdSet
				GROUP BY hed_Program_Plan__c
			];

			for (AggregateResult startDate : startDateListProgram){
				if(filterData.startDate != null && filterData.endDate == null && (Date) startDate.get('startDate') >= sDate){
					prodProgramStartDateId.add((Id) startDate.get('hed_Program_Plan__c'));
				}else if(filterData.endDate != null && filterData.startDate == null && (Date) startDate.get('startDate') <= eDate){
					prodProgramStartDateId.add((Id) startDate.get('hed_Program_Plan__c'));
				}else if(filterData.endDate != null && filterData.startDate != null && (Date) startDate.get('startDate') <= eDate && (Date) startDate.get('startDate') >= sDate){
					prodProgramStartDateId.add((Id) startDate.get('hed_Program_Plan__c'));
				}
			}
		}

		if (filterData.sortBy == STR_SORT_COMINGUP){
			//************course
			Map<Id, hed__course__c> courseMap = new Map<Id, hed__course__c>();
			List<hed__course__c> courses = new List<hed__course__c>([
				SELECT Id, (SELECT Id, hed__Start_Date__c
					FROM hed__Course_Offerings__r
					WHERE hed__Start_Date__c >= TODAY
					AND Registration_Start_Date__c <= TODAY
					AND (Registration_End_Date__c = NULL OR Registration_End_Date__c > TODAY)
					AND IsActive__c = TRUE
					AND Available_Seats__c > 0
					ORDER BY hed__Start_Date__c ASC
					LIMIT 1)
				FROM hed__course__c
				WHERE Id IN:courseIdSet
			]);

			Map<Date, Set<Id>> startDtCourseProgramIdMap = new Map<Date, Set<Id>>();
			Set<Id> noOffering = new Set<Id>();
			Set<Id> sortedIds = new Set<Id>();
			List<Date> startDates = new List<Date>();

			for (hed__course__c crs : courses){
				courseMap.put(crs.Id, crs);
				if (crs.hed__Course_Offerings__r.size() > 0){
					if (startDtCourseProgramIdMap.containsKey(crs.hed__Course_Offerings__r[0].hed__Start_Date__c)){
						startDtCourseProgramIdMap.get(crs.hed__Course_Offerings__r[0].hed__Start_Date__c).add(crs.Id);
					} else{
						startDtCourseProgramIdMap.put(crs.hed__Course_Offerings__r[0].hed__Start_Date__c, new Set<Id>{ crs.Id });
					}
				} else{
					noOffering.add(crs.Id);
				}
			}

			//************program plan
			Map<Id, hed__Program_Plan__c> programPlanMap = new Map<Id, hed__Program_Plan__c>();
			List<hed__Program_Plan__c> program = new List<hed__Program_Plan__c>([
				SELECT Id, (SELECT Id, Start_Date__c
					FROM Program_Offering__r
					WHERE Start_Date__c >= TODAY
					AND Registration_Start_Date__c <= TODAY
					AND (Registration_End_Date__c = NULL OR Registration_End_Date__c > TODAY)
					AND IsActive__c = TRUE
					AND Available_Seats__c > 0
					ORDER BY Start_Date__c ASC
					LIMIT 1)
				FROM hed__Program_Plan__c
				WHERE Id IN:programIdSet
			]);

			for (hed__Program_Plan__c pl : program){
				programPlanMap.put(pl.Id, pl);
				if (pl.Program_Offering__r.size() > 0){
					if (startDtCourseProgramIdMap.containsKey(pl.Program_Offering__r[0].Start_Date__c)){
						startDtCourseProgramIdMap.get(pl.Program_Offering__r[0].Start_Date__c).add(pl.Id);
					} else{
						startDtCourseProgramIdMap.put(pl.Program_Offering__r[0].Start_Date__c, new Set<Id>{ pl.Id });
					}
				} else{
					noOffering.add(pl.Id);
				}
			}

			startDates.addAll(startDtCourseProgramIdMap.keySet());
			startDates.sort();

			List<Id> courseProgramOfferingIdList = new List<Id>();
			List<Product2> productList = new List<Product2>();
			Map<Id, Product2> productCourseMap = new Map<Id, Product2>();
			Map<Id, Product2> productProgramPlanMap = new Map<Id, Product2>();

			// for (Product2 prod : filterDataList){
			for (Product2 prod : filteredProductList){//burhan
				productCourseMap.put(prod.Course__c, prod);
				productProgramPlanMap.put(prod.Program_Plan__c, prod);
			}

			for (Date strtDt : startDates){
				sortedIds.addAll(startDtCourseProgramIdMap.get(strtDt));
				courseProgramOfferingIdList.addAll(startDtCourseProgramIdMap.get(strtDt));
			}

			sortedIds.addAll(noOffering);
			courseProgramOfferingIdList.addAll(noOffering);

			for (Id id : courseProgramOfferingIdList){
				if (productCourseMap.containsKey(id) ){
					productList.add(productCourseMap.get(id) );
				} else if (productProgramPlanMap.containsKey(id) ){
					productList.add(productProgramPlanMap.get(id) );
				}
			}

			filteredProductList = productList;//overwrite list to use new sort sequence
		}

		//Gets the Id of Filtered Products
		// for (Product2 prodFilterDataTemp : filterDataList){
		for (Product2 prodFilterDataTemp : filteredProductList){
			if ((filterData.startDate != null || filterData.endDate != null)){
				//Date or other filters are selected but not price
				if (String.isNotBlank(prodFilterDataTemp.Program_Plan__c)){
					if (prodProgramStartDateId.contains(prodFilterDataTemp.Program_Plan__c)){
						filteredProductId.add(prodFilterDataTemp.Id);
					}
				} else{
					if (prodCourseStartDateId.contains(prodFilterDataTemp.Course__c)){
						filteredProductId.add(prodFilterDataTemp.Id);
					}
				}
			} else{
				//other filters are selected but not price and date
				filteredProductId.add(prodFilterDataTemp.Id);
			}
		}

		if (prodSortBy == STR_SORT_PRICE_LOWTOHIGH || prodSortBy == STR_SORT_PRICE_HIGHTOLOW){
			if (prodSortBy == STR_SORT_PRICE_HIGHTOLOW){//just reverse the list order from ASC SOQL
				List<Id> tempIdList = new List<Id>();
				for(Integer i = filteredProductId.size() - 1; i >= 0; i--){
					tempIdList.add(filteredProductId.get(i));
				}

				filteredProductId = tempIdList;
			}
		}

		//use sort order from SOQL when sort = newlyAdded and including flexible products
		if(filterData.sortBy == STR_SORT_NEWLYADDED){
			List<Id> tempIdList = new List<Id>();
			for(Product2 product : filterDataList){
				if(tempIdList.contains(product.Id)){
					continue;
				}

				if(!allInputProductMap.containsKey(product.Id)){//negated
					continue;
				}

				//felxible check
				if(allInputProductMap.get(product.Id).Program_Plan__r.Program_Delivery_Structure__c == 'Flexible Program'){
					if (filterData.startDate != null || filterData.endDate != null){
						continue;
					}

					if((filterData.minUnitPrice == null || filterData.minUnitPrice == 0) && (filterData.maxUnitPrice == null || (filterData.maxUnitPrice != null && filterData.maxUnitPrice >= 0))){//only include flexible product if min price is null or 0, and max price is null
						//proceed
					}else{
						continue;
					}
				}else{
					//non flexible check
					if(!filteredProductId.contains(product.Id)){
						continue;
					}
				}

				tempIdList.add(product.Id);
			}

			filteredProductId = tempIdList;
		}else{
			//append all flexible product to the end of the list, since they are not included from the SOQL of PricebookEntry
			if((filterData.minUnitPrice == null || filterData.minUnitPrice == 0) && (filterData.maxUnitPrice == null || (filterData.maxUnitPrice != null && filterData.maxUnitPrice >= 0))){//only include flexible product if min price is null or 0, and max price is null
				List<Id> flexibleProductList = new List<Id>();
				for(Id id : allInputProductMap.keySet()){
					if(flexibleProductList.contains(id)){
						continue;
					}

					if(!allInputProductMap.containsKey(id)){//negated
						continue;
					}

					if(allInputProductMap.get(id).Program_Plan__r.Program_Delivery_Structure__c != 'Flexible Program'){
						continue;
					}

					if (filterData.startDate != null || filterData.endDate != null){
						continue;
					}

					flexibleProductList.add(id);
					filteredProductId.add(id);
				}
			}
		}

		prodData.listFilteredProductId = filteredProductId;

		return prodData;
	}

	@AuraEnabled(cacheable=true)
	public static List<Asset> getAssetsByAccount(String accountId){


		return [	SELECT Id, Name, Publishing_End_Date__c
					FROM Asset
					WHERE Account.Id =: accountId
					AND Ready_for_publishing__c = 'Yes'
					AND Product_Request__r.Product_Request_Status__c = 'Published'
					WITH SECURITY_ENFORCED
					ORDER BY Publishing_End_Date__c ASC
				];
	}

	@AuraEnabled(cacheable=true)
	public static List<Product_Specification__c> getProductSpecsByAccount(String accountId){
		Map<Id, Product_Specification__c> prodSpecMap = new Map<Id, Product_Specification__c>([
			SELECT Id, Product_Specification_Name__c FROM Product_Specification__c WHERE Opportunity_Name__r.AccountId =: accountId WITH SECURITY_ENFORCED ORDER By Product_Specification_Name__c ASC
		]);

		List<Product_Specification__c> prodSpecList = new List<Product_Specification__c>();
		Set<Product_Specification__c> prodSpecSet = new Set<Product_Specification__c>();

		List<Product_Request__c> prodReqList = [
			SELECT Id, Product_Specification__c, Product_Request_Status__c, RecordType.Name
			FROM Product_Request__c
			WHERE Child_of_Prescribed_Program__c = false
			AND Product_Specification__c IN :prodSpecMap.keySet()
			AND Product_Request_Status__c ='Published' And (RecordType.Name != 'Corporate Bundle'
			AND RecordType.Name != 'Standing Offer Arrangement') WITH SECURITY_ENFORCED];

		for(Product_Request__c pr : prodReqList){
			if(prodSpecMap.containsKey(pr.Product_Specification__c)){
				prodSpecSet.add(prodSpecMap.get(pr.Product_Specification__c));
			}
		}

		prodSpecList.addAll(prodSpecSet);

		return prodSpecList;
	}


	@AuraEnabled(cacheable=true)
	public static List<BuyerGroup> getBuyerGroups(String accountId){
		
		Set<Id> buyerGroupSet = new Set<Id>();
		Map <Id,Id> buyerGroupMap = new Map <Id,Id>();

		List<BuyerGroupMember> buyerGroupMemberInitList = [
			SELECT Id, BuyerGroup.Name, BuyerId, BuyerGroupId, BuyerGroup.Product_Request__c
			  FROM BuyerGroupMember
			 WHERE BuyerId =: accountId
			   AND BuyerGroup.Ready_for_publishing__c = 'Yes' 
			   AND BuyerGroup.Product_Request__r.Product_Request_Status__c = 'Published'
		  ORDER BY BuyerGroup.Publishing_End_Date__c ASC
		];
		
		List<Id> prodReqIds = new List<Id>();
		for(BuyerGroupMember bgm : buyerGroupMemberInitList){
			prodReqIds.add(bgm.BuyerGroup.Product_Request__c);
			buyerGroupMap.put(bgm.BuyerGroup.Product_Request__c, bgm.BuyerGroupId);
		}

		List<Associated_Products__c> associatedProducts = [
			SELECT Product_Request__c FROM Associated_Products__c 
			 WHERE Product_Request__c IN : prodReqIds 
			  WITH SECURITY_ENFORCED
		];

		List<Related_Product_Request__c> relatedProducts = [
			SELECT Program__c FROM Related_Product_Request__c
			WHERE Program__c IN: prodReqIds
			WITH SECURITY_ENFORCED
		];

		for(Associated_Products__c associatedProduct : associatedProducts){
			if(buyerGroupMap.containsKey(associatedProduct.Product_Request__c)){
				buyerGroupSet.add(buyerGroupMap.get(associatedProduct.Product_Request__c));
			}
		}

		for(Related_Product_Request__c rpr: relatedProducts){
			if(buyerGroupMap.containsKey(rpr.Program__c)){
				buyerGroupSet.add(buyerGroupMap.get(rpr.Program__c));
			}
		}

		return [
			SELECT Id, Name FROM BuyerGroup 
			WHERE Id IN: buyerGroupSet
			AND Ready_for_publishing__c = 'Yes'
			AND Product_Request__r.Product_Request_Status__c = 'Published'
			ORDER BY Publishing_End_Date__c ASC
		];
	}

	/**
	 * Get products by menu category
	 */
	@AuraEnabled
	public static ProductData getProductsByCategory(ProductData acctFilterDataWrapper,  String keyword){
		ProductData prodData = new ProductData();
		List<ProductWrapper> prodWrapperList = new List<ProductWrapper>();
		List<BuyerGroupPricebook>  bgpbList = new List<BuyerGroupPricebook>();
		List<Asset> checkCBPublished = new List<Asset>();

		String standardPriceBook = 'Standard Price Book';
		String earlyBirdPricebook = 'Early Bird';
		String freePricebook = 'Free';

		Map<Id, Product_Request__c> productRequestList = new Map<Id, Product_Request__c>([
			SELECT Id FROM Product_Request__c WHERE Product_Specification__c =: acctFilterDataWrapper.prodSpecId WITH SECURITY_ENFORCED
		]);

		Map<Id,Product2> prodList = new Map<Id,Product2>([SELECT Id FROM Product2
			WHERE Course__r.ProductRequestID__c IN: productRequestList.keySet() OR Program_Plan__r.Product_Request__c IN: productRequestList.keySet() WITH SECURITY_ENFORCED
		]);


		// Get the List of BuyerGroupId
		List<BuyerGroupMember> buyerGroupIdList = [
			SELECT Id, Name, BuyerGroupId, BuyerId, Buyer.Name
			FROM BuyerGroupMember
			WHERE BuyerId = :acctFilterDataWrapper.accountId
		];
		List<String> bgIds = new List<String>();
		for(BuyerGroupMember bgMember : buyerGroupIdList){
			bgIds.add(bgMember.BuyerGroupId);
		}

		// Get the PricebookEntry
		if(acctFilterDataWrapper.assetId != null){
			checkCBPublished = [
				SELECT Id, Account.Id, Name, Start_Date__c, End_Date__c, Total_Value__c, Utilised_Value__c, Pending_Value__c, Remaining_Value__c, Ready_for_publishing__c,
				Product_Request__c
				FROM Asset
				WHERE Id = :acctFilterDataWrapper.assetId
				AND Account.Id = :acctFilterDataWrapper.accountId
				AND Product_Request__r.Product_Request_Status__c = 'Published'
				AND Ready_for_publishing__c = 'Yes'
				WITH SECURITY_ENFORCED
			];
		}
		// Get Product Category Name
		String pbeName;
		ProductCategoryProduct catName = [
			SELECT Id, ProductCategory.Name, ProductId, ProductCategoryId
			FROM ProductCategoryProduct
			 WHERE ProductCategoryId = :acctFilterDataWrapper.categoryId
			LIMIT 1
		];
		if(catName.ProductCategory.Name == 'Corporate Bundle'){
			pbeName = 'Corporate Bundle%';
		} else if(catName.ProductCategory.Name == 'QUTeX Learning Solutions'){
			pbeName = 'SOA%';
		} else {
			pbeName = '%';
		}


		if(!checkCBPublished.isEmpty() && catName.ProductCategory.Name == 'Corporate Bundle'){
			bgpbList = [
				SELECT Id, Name, Pricebook2.Name, Pricebook2Id, BuyerGroup.Name, BuyerGroupId, Pricebook2.IsActive, BuyerGroup.Product_Request__c
				FROM BuyerGroupPricebook
				WHERE BuyerGroupId IN :bgIds
				AND BuyerGroup.Product_Request__r.Product_Request_Status__c = 'Published'
				AND BuyerGroup.Product_Request__c =: checkCBPublished[0].Product_Request__c
			];
		}else if(catName.ProductCategory.Name == 'QUTeX Learning Solutions'){
			bgpbList = [
				SELECT Id, Name, Pricebook2.Name, Pricebook2Id, BuyerGroup.Name, BuyerGroupId, Pricebook2.IsActive, BuyerGroup.Product_Request__c
				FROM BuyerGroupPricebook
				WHERE BuyerGroupId =:acctFilterDataWrapper.buyerGroupId
				AND BuyerGroupId IN: bgIds
				AND BuyerGroup.Product_Request__r.Product_Request_Status__c = 'Published'
			];
		}else{
			bgpbList = [
				SELECT Id, Name, Pricebook2.Name, Pricebook2Id, BuyerGroup.Name, BuyerGroupId, Pricebook2.IsActive, BuyerGroup.Product_Request__c
				FROM BuyerGroupPricebook
				WHERE BuyerGroupId IN :bgIds
				AND BuyerGroup.Product_Request__r.Product_Request_Status__c = 'Published'
			];
		}

		List<String> pbIds = new List<String>();
		for(BuyerGroupPricebook bgpb : bgpbList){
			pbIds.add(bgpb.Pricebook2Id);
		}



		List<ProductCategoryProduct> catProdIds = new List<ProductCategoryProduct>();
		if(!String.isBlank(acctFilterDataWrapper.prodSpecId) &&
			((catName.ProductCategory.Name == 'Tailored Executive Education') ||
			(catName.ProductCategory.Name == 'Tailored Executive Program'))){
				catProdIds = [
					SELECT Id, ProductId, ProductCategoryId
					FROM ProductCategoryProduct
					WHERE ProductCategoryId = :acctFilterDataWrapper.categoryId
					AND ProductId IN : prodList.keySet()
				];
		}else{
			catProdIds = [
				SELECT Id, ProductId, ProductCategoryId
				FROM ProductCategoryProduct
				WHERE ProductCategoryId = :acctFilterDataWrapper.categoryId
			];
		}

		List<String> prodIds = new List<String>();
		for(ProductCategoryProduct getId : catProdIds){
			prodIds.add(getId.ProductId);
		}

		// Get the Price
		Map<Id, Decimal> prodPriceMap = new Map<Id, Decimal>();
		List<PricebookEntry> pbeList = [
			SELECT Id, Name, Product2Id, UnitPrice, Pricebook2Id, Pricebook2.Name
			FROM PricebookEntry
			WHERE Pricebook2Id IN :pbIds
			AND Product2Id IN :prodIds
			AND Pricebook2.Name LIKE :pbeName
		];
		for(PricebookEntry pPrice : pbeList){
			prodPriceMap.put(pPrice.Product2Id,pPrice.UnitPrice);
		}
		// Get the products filtered pricebooks
		Set<String> prodIdsCCE = new Set<String>();
        for(PricebookEntry pbe : pbeList){
            prodIdsCCE.add(pbe.Product2Id);
        }
		// Check if Published to display to Portal
		List<BuyerGroup> getBG = [
			SELECT Id, Name, Product_Request__c
			FROM BuyerGroup
			WHERE Id IN :bgIds
		];
		List<String> prodReqIds = new List<String>();
		for(BuyerGroup bgList : getBG){
			if(bgList.Product_Request__c != null){
				prodReqIds.add(bgList.Product_Request__c);
			}
		}

		Boolean isCBPublished = false;
		Boolean isSOAPublished = false;
		Boolean isTEEPublished = false;
		if(!checkCBPublished.isEmpty() && catName.ProductCategory.Name == 'Corporate Bundle'){

			isCBPublished = true;
			prodData.assetList = checkCBPublished;

			List<Associated_Products__c> getPublishedCB = [
				SELECT Id, Name, Product_Request__r.Product_Request_Status__c, IsActive__c, Product__r.Name, Product__r.Id, Product__r.Product_Category__c
				FROM Associated_Products__c
				WHERE Product_Request__r.Product_Request_Status__c = 'Published' 
				AND Product__r.Id IN :prodIdsCCE
				AND Product_Request__r.Id =: checkCBPublished[0].Product_Request__c
				AND IsActive__c = true
			];
			
			List<String> prodCBIds = new List<String>();
			for(Associated_Products__c prdCB : getPublishedCB){
				prodCBIds.add(prdCB.Product__r.Id);
			}
            
		} else if(!bgpbList.isEmpty() && catName.ProductCategory.Name == 'QUTeX Learning Solutions'){
			List<BuyerGroupMember> checkSOAPublished = [
				SELECT Id, Name, BuyerGroup.Name, BuyerGroupId, BuyerGroup.Ready_for_publishing__c
				FROM BuyerGroupMember
				WHERE BuyerId = :acctFilterDataWrapper.accountId
				AND BuyerGroup.Ready_for_publishing__c = 'Yes'
			];
			if(!checkSOAPublished.isEmpty()){
				isSOAPublished = true;
			}
			// Get list of SOA Flexible Prog
			List<Associated_Products__c> getPublishedSOA = [
				SELECT Id, Name, Product_Request__r.Product_Request_Status__c, IsActive__c, Product__r.Name, Product__r.Id, Product__r.Product_Category__c
				FROM Associated_Products__c
				WHERE Product_Request__r.Product_Request_Status__c = 'Published' 
				AND Product__r.Id IN :prodIds
				AND Product_Request__r.Id =: bgpbList[0].BuyerGroup.Product_Request__c
				AND Product_Request__r.RecordType.Name = 'Standing Offer Arrangement'
				AND IsActive__c = true
			];
			Set<String> prodSOAIds = new Set<String>();
			prodSOAIds = prodIdsCCE;
			for(Associated_Products__c getIds : getPublishedSOA){
				prodSOAIds.add(getIds.Product__r.Id);
			}

		} else if(catName.ProductCategory.Name == 'Tailored Executive Education' || catName.ProductCategory.Name == 'Tailored Executive Program'){
			List<CommerceEntitlementBuyerGroup> getComEntBG = [
				SELECT Id, Name, BuyerGroupId, PolicyId
				FROM CommerceEntitlementBuyerGroup
				WHERE BuyerGroupId = :bgIds
			];
			List<String> policyIds = new List<String>();
			for(CommerceEntitlementBuyerGroup getPolicyIds : getComEntBG){
				policyIds.add(getPolicyIds.PolicyId);
			}

			List<CommerceEntitlementProduct> getComEntProd = [
				SELECT Id, Name, Product.Name, ProductId, PolicyId
				FROM CommerceEntitlementProduct
				WHERE PolicyId = :policyIds
			];
			List<String> prodTEE = new List<String>();
			for(CommerceEntitlementProduct getProdIds : getComEntProd){
				prodTEE.add(getProdIds.ProductId);
			}
			if(prodTEE != null){
				isTEEPublished = true;
			}	
		}

		// Check if Pricebook is empty
		if(isCBPublished || isSOAPublished || isTEEPublished){
			List<Product2> productList = new List<Product2>();
			String getQuery = '';
			if(catName.ProductCategory.Name == 'Tailored Executive Education' || catName.ProductCategory.Name == 'Tailored Executive Program'){
				getQuery = 'SELECT Id, Name, Course__c, Duration__c, Detail_URL__c, Detail_Full_URL__c, Delivery__c, Professional_Level__c, Available_on_Cart__c, Start_Date__c, Description, Product_Type__c, ';
				getQuery += ' Program_Plan__r.Program_Delivery_Structure__c ';
				getQuery += ' FROM Product2 ';
				getQuery += ' WHERE Id IN :prodTEE AND Available_on_Cart__c = TRUE ';
			} else if(catName.ProductCategory.Name == 'Corporate Bundle'){
				getQuery = 'SELECT Id, Name, Course__c, Duration__c, Detail_URL__c, Detail_Full_URL__c, Delivery__c, Professional_Level__c, Available_on_Cart__c, Start_Date__c, Description, Product_Type__c, ';
				getQuery += ' Program_Plan__r.Program_Delivery_Structure__c ';
				getQuery += ' FROM Product2 ';
				getQuery += ' WHERE Id IN :prodCBIds AND Available_on_Cart__c = TRUE ';
			} else {
				getQuery = 'SELECT Id, Name, Course__c, Duration__c, Detail_URL__c, Detail_Full_URL__c, Delivery__c, Professional_Level__c, Available_on_Cart__c, Start_Date__c, Description, Product_Type__c, ';
				getQuery += ' Program_Plan__r.Program_Delivery_Structure__c, ';
				getQuery += ' ( SELECT Id, Pricebook2.Name, UnitPrice FROM PricebookEntries WHERE IsActive = TRUE AND Pricebook2.Id IN :pbIds AND Pricebook2.Name LIKE :pbeName ) ';
				getQuery += ' FROM Product2 ';
				getQuery += ' WHERE Id IN :prodSOAIds AND Available_on_Cart__c = TRUE ';
				
			}
            //Checks if Search Key is Empty
            if(keyword != ''){
                String key = '%' + keyword + '%';
                getQuery += ' AND (Name LIKE :key OR Description LIKE :key )';
            }

			// Query List of Products under the category
			productList = Database.query(getQuery);	

			// Sort by Start Date
			Map<Id, Product2> productMap = new Map<Id, Product2>(productList);
			List<Product2> sortedProductList = new List<Product2>();
			for (String id : prodIds){
				if (productMap.containsKey(id) ){
					sortedProductList.add(productMap.get(id) );
				}
			}
			productList = sortedProductList;

			//Get Id of the course/program plan based on the product
			Set<Id> courseIdSet = new Set<Id>();
			Set<Id> programIdSet = new Set<Id>();

			for (Product2 p : productList){
				if (String.isNotBlank(p.Program_Plan__c)){
					programIdSet.add(p.Program_Plan__c);
				} else{
					courseIdSet.add(p.Course__c);
				}
			}
			
			//Single Product(Course)
			Map<Id, Date> prodCourseDateMap = new Map<Id, Date>();
			// Map Child Product Earliest Course Offering Date
			List<AggregateResult> startDateListCourse = [
				SELECT hed__Course__c, MIN(hed__Start_Date__c)startDate
				FROM hed__Course_Offering__c
				WHERE hed__Start_Date__c >= TODAY 
				AND Registration_Start_Date__c <= TODAY 
				AND (Registration_End_Date__c = NULL OR Registration_End_Date__c > TODAY) 
				AND IsActive__c = TRUE 
				AND Available_Seats__c > 0 
				AND hed__Course__c IN:courseIdSet
				GROUP BY hed__Course__c
			];
			for (AggregateResult startDate : startDateListCourse){
				prodCourseDateMap.put((Id) startDate.get('hed__Course__c'), (Date) startDate.get('startDate'));
			}
			// Map Child Product Earliest Course Offering Date and Available Seats
			Map<Id, Decimal> prodCourseSeatAvailMap = new Map<Id, Decimal>();
			List<hed__Course_Offering__c> getCourseSeatAvail = [
				SELECT hed__Course__c, Available_Seats__c
				FROM hed__Course_Offering__c
				WHERE IsActive__c = TRUE 
				AND Available_Seats__c > 0 
				AND hed__Course__c IN:courseIdSet
			];
			for (hed__Course_Offering__c courseSeatAvail : getCourseSeatAvail){
				prodCourseSeatAvailMap.put((Id) courseSeatAvail.get('hed__Course__c'), (Decimal) courseSeatAvail.get('Available_Seats__c'));
			}
			//Program Product (Program Plan)
			Map<Id, Date> prodProgramDateMap = new Map<Id, Date>();
			// Map Child Product Earliest Program Offering Date
			List<AggregateResult> startDateListProgram = [
				SELECT hed_Program_Plan__c, MIN(Start_Date__c)startDate
				FROM Program_Offering__c
				WHERE Start_Date__c >= TODAY 
				AND Registration_Start_Date__c <= TODAY 
				AND (Registration_End_Date__c = NULL OR Registration_End_Date__c > TODAY) 
				AND IsActive__c = TRUE 
				AND Available_Seats__c > 0 
				AND hed_Program_Plan__c IN:programIdSet
				GROUP BY hed_Program_Plan__c
			];
			for (AggregateResult startDate : startDateListProgram){
				prodProgramDateMap.put((Id) startDate.get('hed_Program_Plan__c'), (Date) startDate.get('startDate'));
			}
			// Map Child Product Earliest Program Offering Date and Seats Available
			Map<Id, Decimal> prodProgSeatAvailMap = new Map<Id, Decimal>();
			List<Program_Offering__c> getProdSeatAvail = [
				SELECT hed_Program_Plan__c, Available_Seats__c
				FROM Program_Offering__c
				WHERE IsActive__c = TRUE 
				AND Available_Seats__c > 0 
				AND hed_Program_Plan__c IN:programIdSet
			];
			for (Program_Offering__c progSeatAvail : getProdSeatAvail){
				prodProgSeatAvailMap.put((Id) progSeatAvail.get('hed_Program_Plan__c'), (Decimal) progSeatAvail.get('Available_Seats__c'));
			}

			//Process List of Products
			for (Product2 prod : productList){
				ProductWrapper productListWrapper = new ProductWrapper();
				//Flexible Program Plan -> Id, Name, Description
				productListWrapper.childProdId = prod.Id;
				productListWrapper.childProdName = prod.Name;
				productListWrapper.childProdDescription = prod.Description;
				productListWrapper.isProgramFlex = true;
				productListWrapper.childProdType = prod.Product_Type__c;

				// Product is Single and Prescribed Program Plan
				if (String.isBlank(prod.Program_Plan__c) || ((String.isNotBlank(prod.Program_Plan__c)) && prod.Program_Plan__r.Program_Delivery_Structure__c == 'Prescribed Program')){
					// single product
					productListWrapper.childProdProfLevel = prod.Professional_level__c;
					productListWrapper.childProdDuration = prod.Duration__c;
					productListWrapper.isProgramFlex = false;
					if (String.isnotblank(prod.Delivery__c)){
						productListWrapper.childProdDelivery = prod.Delivery__c.replace(';', ',');
					}
					if (String.isBlank(prod.Program_Plan__c)){
						//Course Offering -> Single Product
						if (prodCourseDateMap.containsKey(prod.Course__c)){
							productListWrapper.childProdOfferingDate = Datetime.newInstance(prodCourseDateMap.get(prod.Course__c), Time.newInstance(0, 0, 0, 0)).format('dd MMM yyyy');
						}
						if (prodCourseSeatAvailMap.containsKey(prod.Course__c)){
							productListWrapper.seatsAvailable = String.valueOf(prodCourseSeatAvailMap.get(prod.Course__c));
						}
					} else{
						//Product Offering -> Presrcibed Product
						if (prodProgramDateMap.containsKey(prod.Program_Plan__c)){
							productListWrapper.childProdOfferingDate = Datetime.newInstance(prodProgramDateMap.get(prod.Program_Plan__c), Time.newInstance(0, 0, 0, 0)).format('dd MMM yyyy');
						}
						if (prodProgSeatAvailMap.containsKey(prod.Program_Plan__c)){
							productListWrapper.seatsAvailable = String.valueOf(prodProgSeatAvailMap.get(prod.Program_Plan__c));
						}
					}
					if(prodPriceMap.containsKey(prod.Id)){
						productListWrapper.childProdPrice = String.valueOf(prodPriceMap.get(prod.Id));
					}
				}
				productListWrapper.detailURL = prod.Detail_URL__c;
				productListWrapper.fullDetailURL = prod.Detail_Full_URL__c;
				prodWrapperList.add(productListWrapper);
			}
		}

	//Set values to wrapper
	prodData.productList = prodWrapperList;
	return prodData;
	}

	/**
	 * @description Wrapper that contains list of products
	 */
	public class ProductData{
		@AuraEnabled
		public List<ProductWrapper> productList;
		@AuraEnabled
		public List<Asset> assetList;
		@AuraEnabled
		public String userId{ get; set; }
		@AuraEnabled
		public String accountId{ get; set; }
		@AuraEnabled
		public String accountName{ get; set; }
		@AuraEnabled
		public String categoryId{ get; set; }
		@AuraEnabled
		public String prodSpecId{ get; set; }
		@AuraEnabled
		public String assetId{ get; set; }
		@AuraEnabled
		public String buyerGroupId{ get; set; }
	}

	/**
	 * @description Wrapper that contains list of filtered product Id
	 */
	public class FilterData{
		@AuraEnabled
		public List<Id> listFilteredProductId;
	}

	/**
	 * @description Wrapper that contains list of product details
	 */
	public class ProductWrapper{
		@AuraEnabled
		public String childProdId{ get; set; }
		@AuraEnabled
		public String childProdName{ get; set; }
		@AuraEnabled
		public String childProdDescription{ get; set; }
		@AuraEnabled
		public String childProdProfLevel{ get; set; }
		@AuraEnabled
		public String childProdOfferingDate{ get; set; }
		@AuraEnabled
		public String childProdDelivery{ get; set; }
		@AuraEnabled
		public String childProdPrice{ get; set; }
		@AuraEnabled
		public String childProdDuration{ get; set; }
		@AuraEnabled
		public Boolean isProgramFlex{ get; set; }
		@AuraEnabled
		public String detailURL{ get; set; }
		@AuraEnabled
		public String fullDetailURL{ get; set; }
		@AuraEnabled
		public String childProdType{ get; set; }
		@AuraEnabled
		public String seatsAvailable{ get; set; }
	}

	/**
	 * @description Wrapper that contains filter parameters
	 */
	public class FilterWrapper{
		@AuraEnabled
		public String searchKey{ get; set; }
		@AuraEnabled
		public List<String> studyArea{ get; set; }
		@AuraEnabled
		public List<String> deliveryType{ get; set; }
		@AuraEnabled
		public List<String> productType{ get; set; }
		@AuraEnabled
		public Integer minUnitPrice{ get; set; }
		@AuraEnabled
		public Integer maxUnitPrice{ get; set; }
		@AuraEnabled
		public String startDate{ get; set; }
		@AuraEnabled
		public String endDate{ get; set; }
		@AuraEnabled
		public String sortBy{ get; set; }
	}
}