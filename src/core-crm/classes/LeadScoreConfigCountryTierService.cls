/**
 * @description Service Class for Country Tier Lead Score Configuration
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | October 02, 2023      | DEPP-5866              | Created file                 |
      | johanna.a.gibas                | November 24, 2023     | DEPP-7143              | Added Developed Nations      |
      | johanna.a.gibas                | December 11, 2023     | DEPP-7143              | Updated logic                |
      | eccarius.munoz                 | February 16, 2024     | DEPP-7714              | Added handling for tier sub  |
      |                                |                       |                        | category and PMD Fix         |
 */
public with sharing class LeadScoreConfigCountryTierService {//NOPMD this is a service class, high number of public methods and class complexity are expected
    public static void getLeadScoreConfig(Lead_Score_Configuration__c leadScoreConfig, LeadScoreConfigCountryTier leadScoreConfigCountryTier, Boolean isDomestic){
        String category = LeadScoreConfigurationDAO.CONFIG_CATEGORY_COUNTRY_TIER;
        Boolean isForCountryTier = leadScoreConfig.Name == category && leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY;
        
        if(isForCountryTier){ 
            leadScoreConfigCountryTier.setTimeLimit(Integer.valueOf(leadScoreConfig.Time_Limit_Months__c));
            leadScoreConfigCountryTier.setMaxScore(Integer.valueOf(leadScoreConfig.Max_Score__c));
        }

        Boolean isSubCategoryAndNotDomestic = !isDomestic && leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY && leadScoreConfig.Parent_Category__r.Name == category;
        if(isSubCategoryAndNotDomestic){
            setLeadScoreConfig(leadScoreConfig, leadScoreConfigCountryTier);
        }
    } 

    private static void setLeadScoreConfig(Lead_Score_Configuration__c leadScoreConfig, LeadScoreConfigCountryTier leadScoreConfigCountryTier){
        if(leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_COUNTRY_TIER1){
            leadScoreConfigCountryTier.setCountryTier1(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
        else if(leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_COUNTRY_TIER2){
            leadScoreConfigCountryTier.setCountryTier2(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
        else if(leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_COUNTRY_TIER3){
            leadScoreConfigCountryTier.setCountryTier3(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
        else if(leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_DEVELOPED_NATIONS){
            leadScoreConfigCountryTier.setDevelopedNations(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
        else if(leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_UNRESTRICTED_COHORT){
            leadScoreConfigCountryTier.setUntieredUnrestricted(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
        else if(leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_RESTRICTED_COHORT){
            leadScoreConfigCountryTier.setUntieredRestricted(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
        else if(leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_UNLISTED){
            leadScoreConfigCountryTier.setUnlisted(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
    }

    public static Map<Id, Integer> calculateLeadScore(Map<Id,Marketing_Segmentation__c> marketingSegmentationMap, LeadScoreConfigCountryTier leadScoreConfigCountryTier, Boolean isDomestic){
        Map<Id, Integer> countryTierMap = new Map<Id, Integer>();
        Integer countryTierScore = 0;

        Map<String,International_Tier__c> countrTierRefMap = InternationalTierService.getCountryTierMap(AccessLevel.SYSTEM_MODE);
        
        for(Marketing_Segmentation__c marketingSeg : marketingSegmentationMap.values()){

            if(countryTierMap.containsKey(marketingSeg.Contact__c)){
                countryTierScore = countryTierMap.get(marketingSeg.Contact__c);
            }else if(countryTierMap.containsKey(marketingSeg.Lead__c)){
                countryTierScore = countryTierMap.get(marketingSeg.Lead__c);
            }else{
                countryTierScore = 0;
            }

            Boolean isCountryOfcitizenshipValid = String.isNotBlank(marketingSeg.My_Country_Of_Citizenship__c);

            if(isCountryOfcitizenshipValid){   
                countryTierScore = countryTierScore + getCountryTierScore(leadScoreConfigCountryTier, countrTierRefMap, marketingSeg.My_Country_Of_Citizenship__c);  
            }
            
            countryTierMap.putAll(getMappedScore(marketingSeg, countryTierScore, leadScoreConfigCountryTier.getMaxScore()));
        }
        return countryTierMap;
    }

    private static Integer getCountryTierScore(
        LeadScoreConfigCountryTier leadScoreConfigCountryTier, 
        Map<String,International_Tier__c> countrTierRefMap, 
        String countryOfCitizenship){

            Integer countryTierScore = 0;

            Boolean hasValidCountryTier = countrTierRefMap.containsKey(countryOfCitizenship);  

            if(hasValidCountryTier){
                String countryTier = countrTierRefMap.get(countryOfCitizenship)?.Tier_Category__c;

                if(countryTier == InternationalTiersDAO.TIER_CATEGORY_1){
                    countryTierScore = countryTierScore + leadScoreConfigCountryTier.getCountryTier1();   
                }else if(countryTier == InternationalTiersDAO.TIER_CATEGORY_2){ 
                    countryTierScore = countryTierScore + leadScoreConfigCountryTier.getCountryTier2();                
                }else if(countryTier == InternationalTiersDAO.TIER_CATEGORY_3){ 
                    countryTierScore = countryTierScore + leadScoreConfigCountryTier.getCountryTier3();                
                }else if(countryTier == InternationalTiersDAO.DEVELOPED_NATIONS){ 
                    countryTierScore = countryTierScore + leadScoreConfigCountryTier.getDevelopedNations();                
                }else if(countryTier == InternationalTiersDAO.UNTIERED){
                    countryTierScore = countryTierScore +  getCountryTierSubCategoryUntieredScore(countrTierRefMap.get(countryOfCitizenship)?.Tier_Subcategory__c, leadScoreConfigCountryTier);
                    
                }
            }else{
                countryTierScore = countryTierScore + leadScoreConfigCountryTier.getUnlisted(); 
            } 

            return countryTierScore;
    }

    private static Integer getCountryTierSubCategoryUntieredScore(String countryTierSubcategory, LeadScoreConfigCountryTier leadScoreConfigCountryTier){
        Integer countryTierScore = 0;
        if(countryTierSubcategory == InternationalTiersDAO.UNTIERED_SUBCATEGORY_RESTRICTED){
            countryTierScore = countryTierScore + leadScoreConfigCountryTier.getUntieredRestricted(); 
         }else if(countryTierSubcategory == InternationalTiersDAO.UNTIERED_SUBCATEGORY_UNRESTRICTED){
            countryTierScore = countryTierScore + leadScoreConfigCountryTier.getUntieredUnrestricted(); 
         }
        return countryTierScore;
    }

    private static Map<Id, Integer> getMappedScore(Marketing_Segmentation__c marketingSeg, Integer countryTierScore, Integer maxScore){
        Map<Id, Integer> countryTierMap = new Map<Id, Integer>();
        Integer score = LeadScoreCalculatorService.validateScore(countryTierScore, maxScore);
        if(marketingSeg.Contact__c != null){
            countryTierMap.put(marketingSeg.Contact__c, score);
        }
        else if(marketingSeg.Lead__c != null){
            countryTierMap.put(marketingSeg.Lead__c, score);
        }
        return countryTierMap;
    }
}