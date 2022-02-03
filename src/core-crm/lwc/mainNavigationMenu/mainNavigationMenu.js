/**
 * @description A custom LWC for Main Navigation
 *
 * @see ../classes/MainNavigationMenuCtrl.cls
 * 
 * @author Accenture
 *      
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                         |
      |---------------------------|-----------------------|--------------|--------------------------------------------------------|
      | aljohn.motas              | January 14, 2022      | DEPP-1392    | Created Custom Navigation Menu                         |
*/


import { LightningElement ,wire} from 'lwc';
import getNavigationMenu from '@salesforce/apex/MainNavigationMenuCtrl.defaultMenu';
import getStoreFrontCategoryMenu from '@salesforce/apex/MainNavigationMenuCtrl.getStoreFrontCategories';
import getOpportunityContractType from '@salesforce/apex/MainNavigationMenuCtrl.getOpportunityContractType';
import communityId from '@salesforce/community/Id';
import basePath from '@salesforce/community/basePath';
import userId from '@salesforce/user/Id';
import USER_ID from '@salesforce/user/Id';

const STORE_FRONT_CATEGORY = 'StorefrontCategories';
const LOGIN_REQUIRED = 'LoginRequired';
const AVAILABLE_TO_BUY = 'Available to Buy';
const CONTRACT_TYPE = 'Standing Offer Arrangement';
export default class MainNavigationMenu extends LightningElement {

    NavigationMenuList;
    CategoriesNavigationMenuList;
    OpportunityList;
    OpportunityContractType;
    


    //retrieve Opportunity Contract Type
    @wire(getOpportunityContractType,{userId:USER_ID})
    handleGetOpportunityContractType(result){    
        if(result.data){
            this.OpportunityList = result.data.map(Opportunity => {
                this.OpportunityContractType=Opportunity.Contract_Type__c;
            });
        }else{
            this.OpportunityContractType = null;
        }
    }
    
    //retrieve navigation Menu
    @wire(getNavigationMenu)
    handleGetNavigationMenuList(result){    
        if(result.data){
            this.NavigationMenuList = result.data.map(linkSets => {
                if(userId!=null || linkSets.AccessRestriction==LOGIN_REQUIRED) {
                    if(linkSets.Label == AVAILABLE_TO_BUY){
                        if(this.OpportunityContractType == CONTRACT_TYPE){
                            return {
                                Target:basePath+linkSets.Target,
                                Id:linkSets.Id,
                                Label:linkSets.Label,
                                isStorefrontCategories:(linkSets.Target==STORE_FRONT_CATEGORY)
                            };                            
                        }
                    }else if(linkSets.Label != AVAILABLE_TO_BUY){
                        return {
                            Target:basePath+linkSets.Target,
                            Id:linkSets.Id,
                            Label:linkSets.Label,
                            isStorefrontCategories:(linkSets.Target==STORE_FRONT_CATEGORY)
                        };
                    }
                }
            });
        }
    }

    //retrieve Category Link Menus
    @wire(getStoreFrontCategoryMenu,{communityId:communityId})
    handleGetStorefrontCategories(result){    
        if(result.data){
            this.CategoriesNavigationMenuList = result.data.map(Category => {
                return {
                    Target:basePath+'/category/'+Category.Name.replaceAll(' ','-').toLowerCase()+'/'+Category.Id.slice(0, -3),
                    Id:Category.Id,
                    Label:Category.Name
                };
            });
        }
    }




}