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

public without sharing class ProductCtrl {
	/**
	 * @description fetches course offerings and pricebooks related to the products
	 * @param productIds - List of Products under the Category
	 * @return course offerings and pricebook entries related to the product
	 */
	@AuraEnabled(cacheable=true)    
	public static ProductData getProducts( List<String> productIds, String sortCourse){
		ProductData prodData = new ProductData();
		List<ProductWrapper> prodWrapperList = new List<ProductWrapper>();
		String standardPriceBook = 'Standard Price Book';
		String earlyBirdPricebook = 'Early Bird';

		
		if(sortCourse=='priceLowToHigh' || sortCourse=='priceHighToLow'){
			List<PricebookEntry> priceProductList = new List<PricebookEntry>();
			List<PricebookEntry> productListAll = new List<PricebookEntry>();
			List<PricebookEntry> productListRemDup = new List<PricebookEntry>();

			
			String pbeQueryAll = 'SELECT Id, Name, Pricebook2.ID, Pricebook2.Name, UnitPrice, ';
			pbeQueryAll += ' Product2.Id, Product2.Name, Product2.Description, Product2.Professional_level__c, Product2.Duration__c, Product2.Delivery__c, Product2.Program_Plan__c, Product2.Course__c ';
			pbeQueryAll += ' FROM PricebookEntry ';
			pbeQueryAll += ' WHERE Product2.Id IN :productIds ';
			pbeQueryAll += ' AND (Pricebook2.Name = :standardPriceBook OR Pricebook2.Name = :earlyBirdPricebook) ';
			pbeQueryAll += ' AND IsActive = True ';
			if(sortCourse=='priceLowToHigh'){
				pbeQueryAll += ' ORDER BY UnitPrice ASC';
			} else {
				pbeQueryAll += ' ORDER BY UnitPrice DESC';
			}
			productListAll = Database.query(pbeQueryAll);

			// First get products with Early Bird Only
			List<PricebookEntry> pbeEB = [
				SELECT Id, Product2.Id, Pricebook2.Name
				FROM PricebookEntry
				WHERE IsActive = True
				AND Pricebook2.Name = :earlyBirdPricebook
			];
			Set<Id> prodEB = new Set<Id>();
			for(PricebookEntry probEBLoop : pbeEb){
				prodEB.Add(probEBLoop.Product2Id);
			}

			// Then get the Id in PBE and Exclude them in main list
			List<PricebookEntry> getStdProd = [
				SELECT Id, product2Id, Pricebook2.Name
				FROM PricebookEntry
				WHERE Product2Id IN :prodEB
				AND Pricebook2.Name = :standardPriceBook
			];
			Set<Id> stdProdOnly = new Set<Id>();
			for(PricebookEntry getStd : getStdProd){
				stdProdOnly.add(getStd.Id);
			}

			// New Query with selected productIds per page
			String pbeQuery = 'SELECT Id, Name, Pricebook2.ID, Pricebook2.Name, UnitPrice, ';
			pbeQuery += ' Product2.Id, Product2.Name, Product2.Description, Product2.Professional_level__c, Product2.Duration__c, Product2.Delivery__c, Product2.Program_Plan__c, Product2.Course__c ';
			pbeQuery += ' FROM PricebookEntry ';
			pbeQuery += ' WHERE Product2Id IN :productIds';
			pbeQuery += ' AND Id NOT IN :stdProdOnly';
			pbeQuery += ' AND (Pricebook2.Name = :standardPriceBook OR Pricebook2.Name = :earlyBirdPricebook) ';
			pbeQuery += ' AND IsActive = True ';
			if(sortCourse=='priceLowToHigh'){
				pbeQuery += ' ORDER BY UnitPrice ASC';
			} else {
				pbeQuery += ' ORDER BY UnitPrice DESC';
			}
			priceProductList = Database.query(pbeQuery);
			

			//Get Id of the course/program plan based on the product
			Set<Id> courseIdSet = new Set<Id>();
			Set<Id> programIdSet = new Set<Id>();

			for(PricebookEntry p : priceProductList){
				if(String.isNotBlank(p.Product2.Program_Plan__c)){
					programIdSet.add(p.Product2.Program_Plan__c);
				}else{
					courseIdSet.add(p.Product2.Course__c);
				}
			}

			//Single Product(Course)
			Map<Id, Date> prodCourseDateMap = new Map<Id, Date>();
			// Map Child Product Earliest Course Offering Date
			List<AggregateResult> startDateListCourse = [
				SELECT hed__Course__c, MIN(hed__Start_Date__c) startDate
				FROM hed__Course_Offering__c
				WHERE hed__Start_Date__c >= TODAY
				AND Registration_Start_Date__c <= TODAY
				AND (Registration_End_Date__c = NULL
				OR Registration_End_Date__c > TODAY)
				AND IsActive__c = TRUE
				AND Available_Seats__c > 0
					AND hed__Course__c IN :courseIdSet
				GROUP BY hed__Course__c
				];
				for (AggregateResult startDate : startDateListCourse) {
					prodCourseDateMap.put(
					(Id) startDate.get('hed__Course__c'),
					(Date) startDate.get('startDate')
				);
			}

			//Program Product (Program Plan)
			Map<Id, Date> prodProgramDateMap = new Map<Id, Date>();
			// Map Child Product Earliest Program Offering Date
			List<AggregateResult> startDateListProgram = [
				SELECT hed_Program_Plan__c, MIN(Start_Date__c) startDate
				FROM Program_Offering__c
				WHERE Start_Date__c >= TODAY
				AND Registration_Start_Date__c <= TODAY
				AND (Registration_End_Date__c = NULL
				OR Registration_End_Date__c > TODAY)
				AND IsActive__c = TRUE
				AND Available_Seats__c > 0
				AND hed_Program_Plan__c IN :programIdSet
				GROUP BY hed_Program_Plan__c
				];
				for (AggregateResult startDate : startDateListProgram) {
					prodProgramDateMap.put(
					(Id) startDate.get('hed_Program_Plan__c'),
					(Date) startDate.get('startDate')
				);
			}

			//Process List of Products
			for(PricebookEntry pbeList : priceProductList){

				ProductWrapper productListWrapper = new ProductWrapper();
				//Flexible Program Plan -> Id, Name, Description
				productListWrapper.childProdId = pbeList.Product2Id;
				productListWrapper.childProdName = pbeList.Product2.Name;
				productListWrapper.childProdDescription = pbeList.Product2.Description;
				productListWrapper.isProgramFlex = TRUE;

				Product2 getProgName = [ SELECT Id, Program_Plan__r.Program_Delivery_Structure__c FROM Product2 WHERE Id = :pbeList.Product2Id];

				// Product is Single and Prescribed Program Plan
				if(String.isBlank(pbeList.Product2.Program_Plan__c) || ((String.isNotBlank(pbeList.Product2.Program_Plan__c)) && getProgName.Program_Plan__r.Program_Delivery_Structure__c =='Prescribed Program')){ // single product
					productListWrapper.childProdProfLevel = pbeList.Product2.Professional_level__c;
					productListWrapper.childProdDuration = pbeList.Product2.Duration__c;
					productListWrapper.isProgramFlex = FALSE;
					if(String.isnotblank(pbeList.Product2.Delivery__c)){
						productListWrapper.childProdDelivery = pbeList.Product2.Delivery__c.replace(';',',');
					}

					if(String.isBlank(pbeList.Product2.Program_Plan__c)){
						//Course Offering -> Single Product
						if(prodCourseDateMap.containsKey(pbeList.Product2.Course__c)){
							productListWrapper.childProdOfferingDate = Datetime.newInstance(
								prodCourseDateMap.get(pbeList.Product2.Course__c),
								Time.newInstance(0, 0, 0, 0)
							).format('dd MMM yyyy');
						}
					}else{
						//Product Offering -> Presrcibed Product
						if(prodProgramDateMap.containsKey(pbeList.Product2.Program_Plan__c)){
							productListWrapper.childProdOfferingDate = Datetime.newInstance(
								prodProgramDateMap.get(pbeList.Product2.Program_Plan__c),
								Time.newInstance(0, 0, 0, 0)
							).format('dd MMM yyyy');                        
						}
					}
									
					//Get Price
					productListWrapper.childProdPrice = String.valueOf(pbeList.UnitPrice);
					
				}
				prodWrapperList.add(productListWrapper);
			}
		} else { // Sort for Dates (Start Date ASC / Publishing Date DESC)
			List<Product2> productList = new List<Product2>();

			String getQuery = '';
			String priceQry = ''; 
			String dateQry = '';        
					
			String prodQry1 = 'SELECT Id, Name, Course__c, Duration__c, Delivery__c, Professional_Level__c, Available_on_Cart__c, Start_Date__c, Description, ';        
			String prodQry2 = ' Program_Plan__r.Program_Delivery_Structure__c, ';         
			prodQry2 += ' ( SELECT Id, Pricebook2.Name, UnitPrice FROM PricebookEntries WHERE IsActive = TRUE AND (Pricebook2.Name = :standardPriceBook OR Pricebook2.Name = :earlyBirdPricebook)) ';
			prodQry2 += ' FROM Product2 ';
			prodQry2 += ' WHERE Id IN :productIds AND Available_on_Cart__c = TRUE ';

			if(sortCourse=='newlyAdded'){
					dateQry += ' ORDER BY Publishing_Start_date__c DESC';
			}

			// Query List of Products under the category
			getQuery = prodQry1 + prodQry2 + dateQry;
			productList = Database.query(getQuery);
			
			if(sortCourse=='comingUp'){
				Map<Id, Product2> productMap = new Map<Id, Product2>(productList);
				List<Product2> sortedProductList = new List<Product2>();
				for(String id : productIds){
					if(productMap.containsKey(id)){
						sortedProductList.add(productMap.get(id));
					}
				}
				productList = sortedProductList;
			}
			//Get Id of the course/program plan based on the product
			Set<Id> courseIdSet = new Set<Id>();
			Set<Id> programIdSet = new Set<Id>();
				
			for(Product2 p : productList){
				if(String.isNotBlank(p.Program_Plan__c)){
					programIdSet.add(p.Program_Plan__c);
				}else{
					courseIdSet.add(p.Course__c);
				}
			}
			//Single Product(Course)
			Map<Id, Date> prodCourseDateMap = new Map<Id, Date>();
			// Map Child Product Earliest Course Offering Date
			List<AggregateResult> startDateListCourse = [
				SELECT hed__Course__c, MIN(hed__Start_Date__c) startDate
				FROM hed__Course_Offering__c
				WHERE
				hed__Start_Date__c >= TODAY
				AND Registration_Start_Date__c <= TODAY
				AND (Registration_End_Date__c = NULL
				OR Registration_End_Date__c > TODAY)
				AND IsActive__c = TRUE
				AND Available_Seats__c > 0
					AND hed__Course__c IN :courseIdSet
				GROUP BY hed__Course__c
				];
				for (AggregateResult startDate : startDateListCourse) {
					prodCourseDateMap.put(
					(Id) startDate.get('hed__Course__c'),
					(Date) startDate.get('startDate')
				);
			}
			//Program Product (Program Plan)
			Map<Id, Date> prodProgramDateMap = new Map<Id, Date>();
			// Map Child Product Earliest Program Offering Date
			List<AggregateResult> startDateListProgram = [
				SELECT hed_Program_Plan__c, MIN(Start_Date__c) startDate
				FROM Program_Offering__c
				WHERE
				Start_Date__c >= TODAY
				AND Registration_Start_Date__c <= TODAY
				AND (Registration_End_Date__c = NULL
				OR Registration_End_Date__c > TODAY)
				AND IsActive__c = TRUE
				AND Available_Seats__c > 0
					AND hed_Program_Plan__c IN :programIdSet
				GROUP BY hed_Program_Plan__c
				];
				for (AggregateResult startDate : startDateListProgram) {
					prodProgramDateMap.put(
					(Id) startDate.get('hed_Program_Plan__c'),
					(Date) startDate.get('startDate')
				);
			}
		
			//Process List of Products
			for(Product2 prod : productList){
				ProductWrapper productListWrapper = new ProductWrapper();
				//Flexible Program Plan -> Id, Name, Description
				productListWrapper.childProdId = prod.Id;
				productListWrapper.childProdName = prod.Name;
				productListWrapper.childProdDescription = prod.Description;
				productListWrapper.isProgramFlex = TRUE;

				// Product is Single and Prescribed Program Plan
				if(String.isBlank(prod.Program_Plan__c) || ((String.isNotBlank(prod.Program_Plan__c)) && prod.Program_Plan__r.Program_Delivery_Structure__c =='Prescribed Program')){ // single product
					productListWrapper.childProdProfLevel = prod.Professional_level__c;
					productListWrapper.childProdDuration = prod.Duration__c;
					productListWrapper.isProgramFlex = FALSE;
					if(String.isnotblank(prod.Delivery__c)){
						productListWrapper.childProdDelivery = prod.Delivery__c.replace(';',',');
					}
					if(String.isBlank(prod.Program_Plan__c)){
						//Course Offering -> Single Product
						if(prodCourseDateMap.containsKey(prod.Course__c)){
							productListWrapper.childProdOfferingDate = Datetime.newInstance(
								prodCourseDateMap.get(prod.Course__c),
								Time.newInstance(0, 0, 0, 0)
							).format('dd MMM yyyy');
						}
					}else{
						//Product Offering -> Presrcibed Product
						if(prodProgramDateMap.containsKey(prod.Program_Plan__c)){
							productListWrapper.childProdOfferingDate = Datetime.newInstance(
								prodProgramDateMap.get(prod.Program_Plan__c),
								Time.newInstance(0, 0, 0, 0)
							).format('dd MMM yyyy');                        
						}
					}			
					//Product Pricebook Entries
					Map<String, String> prodPBEntryMap = new Map<String, String>();
					if (!prod.PricebookEntries.isEmpty()) {
						for (
						PricebookEntry productPBookEntry : prod.PricebookEntries
						) {
						prodPBEntryMap.put(
							productPBookEntry.Pricebook2.Name,
							String.valueOf(productPBookEntry.UnitPrice)
						);
						}
					}
					//Get Price
					productListWrapper.childProdPrice = prodPBEntryMap.get('Standard Price Book');
					if(prodPBEntryMap.containsKey('Early Bird')){
						productListWrapper.childProdPrice = prodPBEntryMap.get('Early Bird');
					}
				}
				prodWrapperList.add(productListWrapper);
			}
		} // else from sort by price

		//Set values to wrapper
		prodData.productList = prodWrapperList;
		return prodData;
		
	}

	//desc -> fetches the filtered data based on the parameter object values.
	@AuraEnabled(cacheable=true)    
	public static FilterData getFilteredProducts  (List <String> productAllId, FilterWrapper filterData){
		FilterData prodData = new FilterData();
		List<Product2> filterDataList = new List<Product2>();
		List<Id> filteredProductId = new List<Id>();
		String standardPriceBook = 'Standard Price Book';
		String earlyBirdPricebook = 'Early Bird';
		String studyAreaValue = '';
		String deliveryTypeValue = '';
		String productTypeValue = '';
		String prodSortBy = filterData.sortBy;

		// Dynamic Query that matches the selected filter
		String filterProductsQuery = 'SELECT Id, Name, Course__c, Program_Plan__c, Publishing_Start_date__c ';
		if(filterData.minUnitPrice !=null || filterData.maxUnitPrice !=null){
			filterProductsQuery += ', (SELECT UnitPrice, Pricebook2.Name, Pricebook2.Id, Product2Id FROM PricebookEntries ';
			filterProductsQuery += 'WHERE (Pricebook2.Name = \''+standardPriceBook+'\' OR Pricebook2.Name =\''+earlyBirdPricebook+'\'))';
		}
		filterProductsQuery += ' FROM Product2';
		filterProductsQuery += ' WHERE Id IN : productAllId';
		

		//Checks if Search Key is Empty
		if(String.isNotEmpty(filterData.searchKey)){
			String key = '%' + filterData.searchKey + '%'; 
			filterProductsQuery += ' AND (Name LIKE :key OR Description LIKE :key )';
		}
		//Checks if Study Area if Empty
		if(filterData.studyArea.size() >0 ){
			for(String val : filterData.studyArea){
				studyAreaValue += '\''+ val+ '\' '+',';
			}
			studyAreaValue = studyAreaValue.substring(0, studyAreaValue.length() -1 );
			filterProductsQuery += ' AND Study_Area__c INCLUDES (' +studyAreaValue + ')';
		}
		//Checks if Delivery is Empty 
		if(filterData.deliveryType.size() > 0){
			for(String val : filterData.deliveryType){
				deliveryTypeValue += '\''+val + '\' '+',';
			}
			deliveryTypeValue = deliveryTypeValue.substring(0, deliveryTypeValue.length() -1 );
			filterProductsQuery += ' AND Delivery__c INCLUDES (' +deliveryTypeValue + ')';
		}
		//Checks if ProductType is Empty
		if(filterData.productType.size() > 0){
			for(String val : filterData.productType){
				productTypeValue += '\''+ val+ '\' '+',';
			}
			productTypeValue = productTypeValue.substring(0, productTypeValue.length() -1 );
			filterProductsQuery += ' AND Product_Type__c IN (' +productTypeValue + ')';
		}

		if(filterData.sortBy == 'newlyAdded'){
			filterProductsQuery += ' ORDER BY Publishing_Start_date__c DESC';
		} 

		//Queries based on Product objects
		filterDataList = Database.query(filterProductsQuery);

		Set<Id> courseIdSet = new Set<Id>();
		Set<Id> programIdSet = new Set<Id>();
		Set<Id> productPriceId = new Set<Id>();

		//Combination of Price and Date Filter and other filters if selected above
		if((filterData.startDate != null && filterData.endDate !=null) && 
			(filterData.minUnitPrice !=null || filterData.maxUnitPrice != null)){   
				Set<Id> filterProductPriceId = new Set<Id>();
				for(Product2 p: filterDataList){
					for(PricebookEntry pEntry : p.PricebookEntries){
						if(!p.PricebookEntries.isEmpty()){
							//Checks if Product has Early Bird Price
							if(pEntry.Pricebook2.Name == 'Early Bird'){
								productPriceId.add(pEntry.Product2Id);
								if((filterData.maxUnitPrice == null) && (pEntry.UnitPrice >= filterData.minUnitPrice) && (pEntry.Pricebook2.Name == 'Early Bird')){
									filterProductPriceId.add(pEntry.Product2Id);
								}else if((filterData.minUnitPrice == null) && (pEntry.UnitPrice <= filterData.maxUnitPrice) && (pEntry.Pricebook2.Name == 'Early Bird')){
									filterProductPriceId.add(pEntry.Product2Id);
								}else if((pEntry.UnitPrice >= filterData.minUnitPrice && pEntry.UnitPrice <= filterData.maxUnitPrice) && (pEntry.Pricebook2.Name == 'Early Bird')){
									filterProductPriceId.add(pEntry.Product2Id);
								}
							}
							//Product Id not on the list of productPriceId 
							if(!productPriceId.contains(pEntry.Product2Id)){
								if((filterData.maxUnitPrice == null) && (pEntry.UnitPrice >= filterData.minUnitPrice)){                                    
									filterProductPriceId.add(pEntry.Product2Id);
								}else if((filterData.minUnitPrice == null) && (pEntry.UnitPrice <= filterData.maxUnitPrice)){
									filterProductPriceId.add(pEntry.Product2Id);
								}else if(pEntry.UnitPrice >= filterData.minUnitPrice && pEntry.UnitPrice <= filterData.maxUnitPrice){
									filterProductPriceId.add(pEntry.Product2Id);
								}
							}

							if(filterProductPriceId.contains(pEntry.Product2Id)){
								if(String.isNotBlank(p.Program_Plan__c)){
									programIdSet.add(p.Program_Plan__c);
								}else{
									courseIdSet.add(p.Course__c);
								}
							}
						}
					}
				}
			}
		else{
			//Date and Other 4 filters except price
			for(Product2 p : filterDataList){
				if(String.isNotBlank(p.Program_Plan__c)){
					programIdSet.add(p.Program_Plan__c);
				}else{
					courseIdSet.add(p.Course__c);
				}
			}
		}    

		Set<Id> prodCourseStartDateId = new Set<Id>();
		Set<Id> prodProgramStartDateId = new Set<Id>();

		if(filterData.startDate !=null && filterData.endDate !=null){
			Date sDate = Date.parse(filterData.startDate);
			Date eDate = Date.parse(filterData.endDate);
			List<AggregateResult> startDateListCourse = [
				SELECT hed__Course__c, MIN(hed__Start_Date__c) startDate
				FROM hed__Course_Offering__c
				WHERE
					(hed__Start_Date__c >=: sDate
					AND hed__Start_Date__c <=: eDate)
					AND hed__Course__c IN :courseIdSet
				GROUP BY hed__Course__c
				];
				for (AggregateResult startDate : startDateListCourse) {
					prodCourseStartDateId.add((Id) startDate.get('hed__Course__c')
				);
			}
			//Program Product (Program Plan)
			List<AggregateResult> startDateListProgram = [
				SELECT hed_Program_Plan__c, MIN(Start_Date__c) startDate
				FROM Program_Offering__c
				WHERE
					(Start_Date__c >=: sDate
					AND Start_Date__c <=: eDate)                   
					AND hed_Program_Plan__c IN :programIdSet
				GROUP BY hed_Program_Plan__c
				];
				for (AggregateResult startDate : startDateListProgram) {
					prodProgramStartDateId.add((Id) startDate.get('hed_Program_Plan__c')
				);
			}
		}
		
		if(filterData.sortBy == 'comingUp'){
			//************course
			Map<Id, hed__course__c> courseMap = new Map<Id, hed__course__c>();
			List<hed__course__c> courses = new List<hed__course__c>([
				SELECT Id,
					(SELECT Id, hed__Start_Date__c 
					FROM hed__Course_Offerings__r 
					WHERE hed__Start_Date__c >= TODAY 
					AND Registration_Start_Date__c <= TODAY 
					ORDER BY hed__Start_Date__c ASC LIMIT 1) 
				FROM hed__course__c 
				WHERE Id IN: courseIdSet
			]);
			Map<Date, Set<Id>> startDtCourseProgramIdMap = new Map<Date, Set<Id>>();
			Set<Id> noOffering = new Set<Id>();
			Set<Id> sortedIds = new Set<Id>();
			List<Date> startDates = new List<Date>();

			for(hed__course__c crs: courses){
				courseMap.put(crs.Id, crs);
				if(crs.hed__Course_Offerings__r.size() > 0){
					if(startDtCourseProgramIdMap.containsKey(crs.hed__Course_Offerings__r[0].hed__Start_Date__c)){
						startDtCourseProgramIdMap.get(crs.hed__Course_Offerings__r[0].hed__Start_Date__c).add(crs.Id);
					}else{
						startDtCourseProgramIdMap.put(crs.hed__Course_Offerings__r[0].hed__Start_Date__c, new Set<Id>{crs.Id});
					}
				}else{
					noOffering.add(crs.Id);
				}
			}

			//************program plan
			Map<Id, hed__Program_Plan__c> programPlanMap = new Map<Id, hed__Program_Plan__c>();
			List<hed__Program_Plan__c> program = new List<hed__Program_Plan__c>([
				SELECT Id,
					(SELECT Id, Start_Date__c 
					FROM Program_Offering__r 
					WHERE Start_Date__c >= TODAY 
					AND Registration_Start_Date__c <= TODAY 
					ORDER BY Start_Date__c ASC LIMIT 1) 
				FROM hed__Program_Plan__c 
				WHERE Id IN: programIdSet
			]);

			for(hed__Program_Plan__c pl: program){
				programPlanMap.put(pl.Id, pl);
				if(pl.Program_Offering__r.size() > 0){
					if(startDtCourseProgramIdMap.containsKey(pl.Program_Offering__r[0].Start_Date__c)){
						startDtCourseProgramIdMap.get(pl.Program_Offering__r[0].Start_Date__c).add(pl.Id);
					}else{
						startDtCourseProgramIdMap.put(pl.Program_Offering__r[0].Start_Date__c, new Set<Id>{pl.Id});
					}
				}else{
					noOffering.add(pl.Id);
				}
			}

			startDates.addAll(startDtCourseProgramIdMap.keySet());
			startDates.sort();

			List<Id> courseProgramOfferingIdList = new List<Id>();
			List<Product2> productList = new List<Product2>();
			Map<Id, Product2> productCourseMap = new Map<Id, Product2>();
			Map<Id, Product2> productProgramPlanMap = new Map<Id, Product2>();

			for(Product2 prod : filterDataList){
				productCourseMap.put(prod.Course__c, prod);
				productProgramPlanMap.put(prod.Program_Plan__c, prod);
			}    

			for(Date strtDt: startDates){
				sortedIds.addAll(startDtCourseProgramIdMap.get(strtDt));
				courseProgramOfferingIdList.addAll(startDtCourseProgramIdMap.get(strtDt));
			}
			
			sortedIds.addAll(noOffering);
			courseProgramOfferingIdList.addAll(noOffering);

			for(Id id : courseProgramOfferingIdList){
				if(productCourseMap.containsKey(id)){
					productList.add(productCourseMap.get(id));
				}else if(productProgramPlanMap.containsKey(id)){
					productList.add(productProgramPlanMap.get(id));
				}
			}
			filterDataList = productList;
		}

		//Gets the Id of Filtered Products
		for(Product2 prodFilterDataTemp : filterDataList){
			//Price or other filter are selected, but not Date
			if((filterData.minUnitPrice !=null || filterData.maxUnitPrice !=null) &&
				(filterData.startDate == null && filterData.endDate == null)){

				for(PricebookEntry pEntry : prodFilterDataTemp.PricebookEntries ){
					if(!prodFilterDataTemp.PricebookEntries.isEmpty()){
						if(pEntry.Pricebook2.Name == 'Early Bird'){
							productPriceId.add(pEntry.Product2Id);
							if((filterData.maxUnitPrice == null) && (pEntry.UnitPrice >= filterData.minUnitPrice) && (pEntry.Pricebook2.Name == 'Early Bird')){
								filteredProductId.add(pEntry.Product2Id);
							}else if((filterData.minUnitPrice == null) && (pEntry.UnitPrice <= filterData.maxUnitPrice) && (pEntry.Pricebook2.Name == 'Early Bird')){       
								filteredProductId.add(pEntry.Product2Id);
							}else if((pEntry.UnitPrice >= filterData.minUnitPrice && pEntry.UnitPrice <= filterData.maxUnitPrice) && (pEntry.Pricebook2.Name == 'Early Bird')){
								filteredProductId.add(pEntry.Product2Id);
							}
						}

						if(!productPriceId.contains(pEntry.Product2Id)){
							if((filterData.maxUnitPrice == null) && (pEntry.UnitPrice >= filterData.minUnitPrice)){  
								filteredProductId.add(pEntry.Product2Id);
							}else if((filterData.minUnitPrice == null) && (pEntry.UnitPrice <= filterData.maxUnitPrice)){  
								filteredProductId.add(pEntry.Product2Id);
							}else if(pEntry.UnitPrice >= filterData.minUnitPrice && pEntry.UnitPrice <= filterData.maxUnitPrice){
								filteredProductId.add(pEntry.Product2Id);
							}
						}
					}
				}
			}
			//Date or other filters are selected but not price
			else if((filterData.startDate != null && filterData.endDate !=null)){
				if(String.isNotBlank(prodFilterDataTemp.Program_Plan__c)){
					if(prodProgramStartDateId.contains(prodFilterDataTemp.Program_Plan__c)){
						filteredProductId.add(prodFilterDataTemp.Id);
					}
				}else{
					if(prodCourseStartDateId.contains(prodFilterDataTemp.Course__c)){
						filteredProductId.add(prodFilterDataTemp.Id);
					}
				}
			}
			//other filters are selected but not price and date
			else{
				filteredProductId.add(prodFilterDataTemp.Id);
			}
		}

		// Sort by Price List of ProductIds to pass to getProducts
		List<Id> setProdIds = new List<Id>();
		if(prodSortBy == 'priceLowToHigh' || prodSortBy == 'priceHighToLow'){
			List<PricebookEntry> productListSortByPrice = new List<PricebookEntry>();
			String pbeQueryAll = 'SELECT Id, Name, Pricebook2.ID, Pricebook2.Name, UnitPrice, ';
			pbeQueryAll += ' Product2.Id, Product2.Name, Product2.Description, Product2.Professional_level__c, Product2.Duration__c, Product2.Delivery__c, Product2.Program_Plan__c, Product2.Course__c ';
			pbeQueryAll += ' FROM PricebookEntry ';
			pbeQueryAll += ' WHERE Product2.Id IN :filteredProductId ';
			pbeQueryAll += ' AND (Pricebook2.Name = \''+standardPriceBook+'\' OR Pricebook2.Name = \''+earlyBirdPricebook+'\') ';
			pbeQueryAll += ' AND IsActive = True ';
			if(prodSortBy=='priceLowToHigh'){
				pbeQueryAll += ' ORDER BY UnitPrice ASC';
			} else if(prodSortBy=='priceHighToLow') {
				pbeQueryAll += ' ORDER BY UnitPrice DESC';
			}
			productListSortByPrice = Database.query(pbeQueryAll);

			
			// First get products with Early Bird Only
			List<PricebookEntry> pbeEB = [
				SELECT Id, Product2.Id, Pricebook2.Name
				FROM PricebookEntry
				WHERE IsActive = True
				AND Pricebook2.Name = :earlyBirdPricebook
			];
			Set<Id> prodEB = new Set<Id>();
			for(PricebookEntry probEBLoop : pbeEb){
				prodEB.Add(probEBLoop.Product2Id);
			}

			// Then get the Id in PBE and Exclude them in main list
			List<PricebookEntry> getStdProd = [
				SELECT Id, product2Id, Pricebook2.Name
				FROM PricebookEntry
				WHERE Product2Id IN :prodEB
				AND Pricebook2.Name = :standardPriceBook
			];
			Set<Id> stdProdOnly = new Set<Id>();
			for(PricebookEntry getStd : getStdProd){
				stdProdOnly.add(getStd.Id);
			}

			List<PricebookEntry> productListRemDup = new List<PricebookEntry>();
			String pbeQueryRemDup = 'SELECT Id, Name, Pricebook2.ID, Pricebook2.Name, UnitPrice, ';
			pbeQueryRemDup += ' Product2.Id, Product2.Name, Product2.Description, Product2.Professional_level__c, Product2.Duration__c, Product2.Delivery__c, Product2.Program_Plan__c, Product2.Course__c ';
			pbeQueryRemDup += ' FROM PricebookEntry ';
			pbeQueryRemDup += ' WHERE IsActive = True ';
			pbeQueryRemDup += ' AND Product2Id IN :filteredProductId ';
			pbeQueryRemDup += ' AND Id NOT IN :stdProdOnly ';
			pbeQueryRemDup += ' AND (Pricebook2.Name = \''+standardPriceBook+'\' OR Pricebook2.Name = \''+earlyBirdPricebook+'\') ';
			if(prodSortBy=='priceLowToHigh'){
				pbeQueryRemDup += ' ORDER BY UnitPrice ASC';
			} else if(prodSortBy=='priceHighToLow') {
				pbeQueryRemDup += ' ORDER BY UnitPrice DESC';
			}
			productListRemDup = Database.query(pbeQueryRemDup);

			for(PricebookEntry filterSortProdPrice : productListRemDup){
				setProdIds.add(filterSortProdPrice.Product2Id);
			}
		}

		if(prodSortBy == 'priceLowToHigh' || prodSortBy == 'priceHighToLow'){
			prodData.listFilteredProductId = setProdIds;
		} else {
			prodData.listFilteredProductId = filteredProductId ;
		}

		return prodData;
	}

/**
 * @description Wrapper that contains list of products
 */
public class ProductData {
	@AuraEnabled
	public List<ProductWrapper> productList;
}

/**
 * @description Wrapper that contains list of filtered product Id
 */
public class FilterData {
	@AuraEnabled
	public List<Id> listFilteredProductId;
}

/**
 * @description Wrapper that contains list of product details
 */
public class ProductWrapper {
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
	public Boolean isProgramFlex  { get; set;}
}

public class FilterWrapper {
	@AuraEnabled
	public String searchKey { get; set; } // KeyWord Search
	@AuraEnabled
	public List<String> studyArea { get; set; } // Study Area
	@AuraEnabled
	public List<String> deliveryType { get; set; } // Delivery
	@AuraEnabled
	public List<String> productType { get; set; } // Course Type
	@AuraEnabled
	public Integer minUnitPrice{ get; set; } // Price Range -> Minimum Value 
	@AuraEnabled
	public Integer maxUnitPrice{ get; set; } // Price Range -> Maximum Value 
	@AuraEnabled
	public String startDate { get; set; } // Start date 
	@AuraEnabled
	public String endDate{ get; set; } // end date
	@AuraEnabled
	public String sortBy{ get; set; } // sort courses by
}

}