/**
 * @description A custom LWC for showing custom search or 
 *              lookup component (for pre-defined lookup items)
 * 
 * @author Accenture
 *      
 * @history
 *    | Developer                 | Date                  | JIRA                | Change Summary                                         |
      |---------------------------|-----------------------|---------------------|--------------------------------------------------------|
      | angelika.j.s.galang       | February 11, 2022     | DEPP-1258           | Created file                                           | 
      | roy.nino.s.regala         | February 20, 2022     | DEPP-1773,1406,1257 | Edited to work as a custom column in datatables        | 
*/
import { LightningElement, api, track } from 'lwc';

export default class CustomSearch extends LightningElement {
    @api searchLabel; //label of input field
    @api searchInputPlaceholder; //placeholder text of input field
    @api searchItemIcon; //icon of search items
    @api parentId; //id of related parent
    @api customLookup; //determines if used as a custom lookup (not normal search)
    @api required; //determines if lookup field is required
    @api itemServerName; //name of record that is saved in database
    @api itemId; //id of the record selected
    @api newRecordAvailable; //indicates that creating a new record is available
    @api objectLabelName;// name of the object to be created for creating new record
    @api customServerSearch; //enables database search on clicking button
    @api searchInProgress;
    @api editable;


    searchBoxOpen = false;
    selectedItem = '';
    filterString ='';
    
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

    get customSelect(){
        if((this.itemServerName || this.selectedItemName) && this.customLookup){
            return true;
        }else{
            return false;
        }
    }

    get hasInitialItemName(){
        return this.itemServerName || 
            (this.editable && this.selectedItemName) ?
            true : false;
    }

    get selectedItemName(){
        //shows the item name of the record from database
        if(this.itemServerName){ 
            return this.itemServerName;
        //if there is no selected item yet
        }else if(!this.itemId){
            return '';
        //if there is a selcted item, search for the name from the searchitems
        }else if(this.itemId && this.searchItems.find(item => item.id == this.itemId)){
            return this.searchItems.find(item => item.id == this.itemId).label;
        //else empty
        }else{
            
            return '';
        }
    }

    get itemUrl(){
        return '/' + this.itemId;
    }

    handleEdit(){
        this.itemId = undefined;
        this.itemServerName = undefined;
        const editEvent = new CustomEvent('itemselect',{
            bubbles    : true,
            composed   : true,
            cancelable : true,
            detail     : {
                value:undefined,
                parent:this.parentId
            }
        });
        this.dispatchEvent(editEvent);
    }


    showSearchBox(){
        this.template.querySelector(".search-results").classList.add("slds-is-open");
        this.template.querySelector(".input-search").classList.add("slds-has-focus");
        this.searchBoxOpen = true;
    }

    handleSearchClick(){
        this.showSearchBox();
    }

    handleSearchKeydown(event){
        if (event.code == "Escape") {
            this.handleSearchBlur();
        }
    }

    handleSearchKeyUp(){
        if(this.filterString !== '' && this.filterString && this.filterString.length > 2 && this.customServerSearch){
            const searchEvent = new CustomEvent('search',{
                bubbles    : true,
                composed   : true,
                cancelable : true,
                detail     : {
                    filterString:this.filterString
                }
            });
            this.dispatchEvent(searchEvent);
            this.showSearchBox();
        }
    }

    handleSearchBlur() {
        this.template.querySelector(".search-results").classList.remove("slds-is-open");
        this.template.querySelector(".input-search").classList.remove("slds-has-focus");
        this.searchBoxOpen = false;
    }

    handleItemSearch(event){
        if(this.customServerSearch){
            const percentLookupRegex = /^%|%$/g;
            this.filterString = event.target.value.replace(percentLookupRegex, '');
        }else{
            this.filterString = event.target.value;
        }
        
        if(this.filterString && !this.customServerSearch){
            this.searchItemsToDisplay = this.searchItems.filter((question) =>
                question.label.toLowerCase().includes(this.filterString.toLowerCase())
            );
        }else{
            this.searchItemsToDisplay = this.searchItems;
        }
    }

    handleItemClick(event){
        let itemId = event.currentTarget.dataset.recordid;
        if(this.editable){
            this.itemId = itemId;
        }
        this.selectedItem = itemId;

        const selectionEvent = new CustomEvent('itemselect',{
            bubbles    : true,
            composed   : true,
            cancelable : true,
            detail     : {
                value:itemId,
                parent:this.parentId
            }
        });
        this.dispatchEvent(selectionEvent);
        this.template.querySelector(".input-search").value = "";
        this.handleSearchBlur();
    }

    handleNewRecord(){
        const createEvent = new CustomEvent('create',{
            bubbles    : true,
            composed   : true,
            cancelable : true,
            detail     : {
                parent:this.parentId
            }
        });
        this.dispatchEvent(createEvent);
    }
    
    handleRemoveSelected(event){
        event.preventDefault();
        let selectedItem = this.itemId?this.itemId:this.selectedItem;
        const removeEvent = new CustomEvent('itemremove',{
            bubbles    : true,
            composed   : true,
            cancelable : true,
            detail     : {
                value:selectedItem
            }
        });
        this.dispatchEvent(removeEvent);
        this.selectedItem = '';
        this.filterString = '';
    }

}