/**
 * @description A custom LWC for showing custom search or lookup component
 * 
 * @author Accenture
 *      
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                         |
      |---------------------------|-----------------------|--------------|--------------------------------------------------------|
      | angelika.j.s.galang       | February 11, 2022     | DEPP-1258    | Created file                                           | 
      |                           |                       |              |                                                        |
*/
import { LightningElement, api, track } from 'lwc';

export default class CustomSearch extends LightningElement {
    @api searchLabel; //label of input field
    @api searchInputPlaceholder; //placeholder text of input field
    @api searchItemIcon; //icon of search items
    @api parentId; //id of related parent
    @api customLookup; //determines if used as a custom lookup (not normal search)
    @api required; //determines if lookup field is required

    searchBoxOpen = false;
    customSelect = false;
    selectedItem = '';
    
    @api
    get searchItems() { //pass with the ff properties: id,label,meta
        return this._searchItems;
    }
    set searchItems(value) {
        this.setAttribute('searchItems', value);
        this._searchItems = value;
        this.searchItemsToDisplay = value;
    }

    @track _searchItems;
    @track searchItemsToDisplay;
    
    get noItemsAvailable(){
        return this.searchItemsToDisplay.length == 0;
    }

    handleSearchClick(){
        this.template.querySelector(".search-results").classList.add("slds-is-open");
        this.template.querySelector(".input-search").classList.add("slds-has-focus");
        this.searchBoxOpen = true;
    }

    handleSearchKeydown(event){
        if (event.code == "Escape") {
            this.handleSearchBlur();
        }
    }

    handleSearchBlur() {
        this.template.querySelector(".search-results").classList.remove("slds-is-open");
        this.template.querySelector(".input-search").classList.remove("slds-has-focus");
        this.searchBoxOpen = false;
    }

    handleItemSearch(event){
        let filterString = event.target.value;
        if(filterString){
            this.searchItemsToDisplay = this.searchItems.filter((question) =>
                question.label.toLowerCase().includes(filterString.toLowerCase())
            );
        }else{
            this.searchItemsToDisplay = this.searchItems;
        }
    }

    handleItemClick(event){
        let itemId = event.currentTarget.dataset.recordid;
        if(this.customLookup){
            this.selectedItemName = this.searchItems.find(item => item.id == itemId).label;
            this.customSelect = true;
        }
        const selectionEvent = new CustomEvent('itemselect',{
            detail: {
                value:itemId,
                parent:this.parentId
            }
        });
        this.dispatchEvent(selectionEvent);
        this.template.querySelector(".input-search").value = "";
        this.handleSearchBlur();
    }

    handleRemoveSelected(event){
        event.preventDefault();
        this.customSelect = false;
        const removeEvent = new CustomEvent('itemremove');
        this.dispatchEvent(removeEvent);
    }
}