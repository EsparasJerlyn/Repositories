/**
 * @description Controller Class for list of products to be displayed in Product Listing Page
 * @see ../lwc/productDetails
 * @author Accenture
 * @history
 *  | Developer                 | Date                  | JIRA                 | Change Summary                             |
 |---------------------------|-----------------------|----------------------|--------------------------------------------|
 | mary.grace.li             | May 02, 2022          | DEPP-1269            | Created File                               |
 | eugene.andrew.abuan       | May 02, 2022          | DEPP-1269            | Modified Ctrl to Map fields                |
 | eugene.andrew.abuan       | May 09, 2022          | DEPP-1979            | Added getFilteredProducts function         |
 | keno.domienri.dico        | May 19, 2022          | DEPP-1980            | Added sorting of courses                   |
 | john.bo.a.pineda          | June 01, 2022         | DEPP-2853            | Updated Registration Dates Logic           |
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
			pbeQuery += ' Product2.Id, Product2.Name, Product2.Description, Product2.Professional_level__c, Product2.Duration__c, Product2.Delivery__c, Product2.Program_Plan__c, Product2.Course__c ';
			pbeQuery += ' FROM PricebookEntry ';
			pbeQuery += ' WHERE Product2Id IN :productIds';
			pbeQuery += ' AND (Pricebook2.Name = :standardPriceBook OR Pricebook2.Name = :earlyBirdPricebook OR Pricebook2.Name = :freePricebook) ';
			pbeQuery += ' AND IsActive = True AND Product2.Available_on_Cart__c = TRUE';
			pbeQuery += ' ORDER BY UnitPrice ASC';

			priceProductList = Database.query(pbeQuery);

            //--new---
            map<id, Product2> productMap = new map<id, Product2>();
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
                SELECT Id, Name, Description, Program_Plan__c, Professional_level__c, Duration__c, Delivery__c, Course__c, Program_Plan__r.Program_Delivery_Structure__c
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

				prodWrapperList.add(flexiProductWrapper);
			}
		} else{
			// Sort for Dates (Start Date ASC / Publishing Date DESC)
			List<Product2> productList = new List<Product2>();

			String getQuery = '';
			String priceQry = '';
			String dateQry = '';

			String prodQry1 = 'SELECT Id, Name, Course__c, Duration__c, Delivery__c, Professional_Level__c, Available_on_Cart__c, Start_Date__c, Description, ';
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
				productTypeValue += '\'' + val + '\' ' + ',';
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
		filterDataList = Database.query(filterProductsQuery);

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

	/**
	 * @description Wrapper that contains list of products
	 */
	public class ProductData{
		@AuraEnabled
		public List<ProductWrapper> productList;
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