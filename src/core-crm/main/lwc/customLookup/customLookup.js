import { LightningElement, track, api } from 'lwc';
import MINIMAL_SEARCH_TERM_LENGTH from '@salesforce/label/c.Minimum_Search_Term_Length';
import SEARCH_DELAY from '@salesforce/label/c.Search_Delay';

export default class CustomLookup extends LightningElement {
   
    static delegatesFocus = true;
    
    @api label;
    @api isRequired= false;
    @api selection = [];
    @api placeholder = '';
    @api isMultiEntry = false;
    @api errors = [];
    @api scrollAfterNItems;
    @api customKey;
    @api tabIndex;
    @api defaultvalue;
    @api defaultlabel;
    @api getdisabled;

    @track searchTerm = '';
    @track searchResults = [];
    @track hasFocus = false;
    @track loading = false;

    cleanSearchTerm;
    blurTimeout;
    searchThrottlingTimeout;

    @api isBtnDisabled = false;
    @api disabled;
    @api displayName;
    @api counter =0;
    @track previousCounter=0;
    @track isMouseOut = true;
    @track scrollTop;

    // EXPOSED FUNCTIONS

    @api
    setSearchResults(results) {
        // Reset the spinner
        this.loading = false;
        this.searchResults = results.map(result => {
            // Clone and complete search result if icon is missing
            const { label, value } = result;
            return {
                label,
                value,
                //icon: 'standard:groups'
            };
            //return result;
        });  
    }

    @api
    getSelection() {
        return this.selection;
    }

    @api
    getkey() {
        return this.customKey;
    }

    // INTERNAL FUNCTIONS

    updateSearchTerm(newSearchTerm) {
        this.searchTerm = newSearchTerm;

        // Compare clean new search term with current one and abort if identical
        const newCleanSearchTerm = newSearchTerm
            .trim()
            .replace(/\*/g, '')
            .toLowerCase();
        if (this.cleanSearchTerm === newCleanSearchTerm) {
            return;
        }

        // Save clean search term
        this.cleanSearchTerm = newCleanSearchTerm;

        // Ignore search terms that are too small
        if (newCleanSearchTerm.length < MINIMAL_SEARCH_TERM_LENGTH) {
            this.searchResults = [];
            return;
        }

        // Apply search throttling (prevents search if user is still typing)
        if (this.searchThrottlingTimeout) {
            clearTimeout(this.searchThrottlingTimeout);
        }
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.searchThrottlingTimeout = setTimeout(() => {
            // Send search event if search term is long enougth
            if (this.cleanSearchTerm.length >= MINIMAL_SEARCH_TERM_LENGTH) {
                // Display spinner until results are returned
                this.loading = true;
                const searchEvent = new CustomEvent('search', {
                    detail: {
                        searchTerm: this.cleanSearchTerm
                    }
                    //removed from the detail block -> ,selectedIds: this.selection.map(element => element.id)
                });
                this.dispatchEvent(searchEvent);
            }
            this.searchThrottlingTimeout = null;
        }, SEARCH_DELAY);
    }

    isSelectionAllowed() {
        if (this.isMultiEntry) {
            return true;
        }
        return !this.hasSelection();
    }

    @api hasResults() {
        return this.searchResults.length > 0;
    }

   @api hasSelection() {
        return this.selection.length > 0;
    }

    getSearchResults(){
        return this.searchResults.length < 0;
    }

    // EVENT HANDLING

    handleInput(event) {
        // Prevent action if selection is not allowed
        if (!this.isSelectionAllowed()) {
            return;
        }
        this.updateSearchTerm(event.target.value);
    }

    handleResultClick(event) {
        const recordId = event.currentTarget.dataset.recordid;
        const recordLabel = event.currentTarget.dataset.name;
        //this.defaultlabel = recordLabel;
        
        this.handleResultClick2(recordId, recordLabel);
    }

    handleResultClick2(recordId, recordLabel) {
        
        //Pass the selected Record ID
        const passRecId = new CustomEvent( 'passrecordid', { detail : recordId });      
        this.dispatchEvent(passRecId);
       
        //Pass the selected Record Name
        const passRecLabel = new CustomEvent( 'passrecordlabel', { detail : recordLabel });
        this.dispatchEvent(passRecLabel);
  
        // this.defaultlabel = recordLabel;
        
        // Save selection
        let selectedItem = this.searchResults.filter(
            // result => result.id === recordId --> orig codes
            result => result.value === recordId
        );

        if (selectedItem.length === 0) {
            return;
        }
        selectedItem = selectedItem[0];
        const newSelection = [...this.selection];
        newSelection.push(selectedItem);
        this.selection = newSelection;

        // Reset search
        this.searchTerm = '';
        this.searchResults = [];

        // Notify parent components that selection has changed
        this.dispatchEvent(new CustomEvent('selectionchange'));

    }

    handleComboboxClick() {
        // Hide combobox immediatly
        if (this.blurTimeout) {
            window.clearTimeout(this.blurTimeout);
        }
        this.hasFocus = false;
    }

    @api handleFocus() {
        // Prevent action if selection is not allowed
        if (!this.isSelectionAllowed()) {
            return;
        }
        this.hasFocus = true;
    }

    handleBlur() {
        // Prevent action if selection is not allowed
        if (!this.isSelectionAllowed()) {
            return;
        }
        // Delay hiding combobox so that we can capture selected result
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.blurTimeout = window.setTimeout(() => {
            this.hasFocus = false;
            this.blurTimeout = null;
        }, 300);
    }

    handleRemoveSelectedItem(event) {
        const recordId = event.currentTarget.name;
        this.selection = this.selection.filter(item => item.id !== recordId);
        // Notify parent components that selection has changed
        this.dispatchEvent(new CustomEvent('selectionchange'));
    }

    handleClearSelection() {
        this.selection = [];
        this.counter =0;
        // Notify parent components that selection has changed
        this.dispatchEvent(new CustomEvent('selectionchange'));

        //set focus to input 
        this.handleInputFocus();

    }

    // STYLE EXPRESSIONS
    get getContainerClass() {
        let css = 'slds-combobox_container slds-has-inline-listbox ';
        if (this.hasFocus && this.hasResults()) {
            css += 'slds-has-input-focus ';
        }
        if (this.errors.length > 0) {
            css += 'has-custom-error';
        }
        return css;
    }

    get getDropdownClass() {
        let css =
            //'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click '; orig
            'slds-combobox slds-dropdown-trigger';
        if (
            this.hasFocus &&
            this.cleanSearchTerm &&
            this.cleanSearchTerm.length >= MINIMAL_SEARCH_TERM_LENGTH
        ) {
            css += 'slds-is-open';
        }
        return css;
    }

    get getInputClass() {
        let css =
            'slds-input slds-combobox__input has-custom-height ' +
            (this.errors.length === 0 ? '' : 'has-custom-error ');
        if (!this.isMultiEntry) {
            css +=
                'slds-combobox__input-value ' +
                (this.hasSelection() ? 'has-custom-border' : '');
            
            /* if(this.hasSelection()){
                this.template.querySelector('[data-id="container"]').classList.remove('slds-has-input-focus');
            }*/
            
        }
        return css;
    }

    get getComboboxClass() {
        let css = 'slds-combobox__form-element slds-input-has-icon ';
        if (this.isMultiEntry) {
            css += 'slds-input-has-icon_right';
        } else {
            css += this.hasSelection()
                ? 'slds-input-has-icon_right' //slds-input-has-icon_left-right
                : 'slds-input-has-icon_right';
        }
        return css;
    }

    get getSearchIconClass() {
        let css = 'slds-input__icon slds-input__icon_right ';
        if (!this.isMultiEntry) {
            css += this.hasSelection() ? 'slds-hide' : '';
        }
        return css;
    }

    get getClearSelectionButtonClass() {
        return (
            'slds-button slds-button_icon slds-input__icon slds-input__icon_right ' +
            (this.hasSelection() ? '' : 'slds-hide')
        );
    }

    get getSelectIconName() {
        return this.hasSelection()
            ? this.selection[0].icon
            : 'standard:default';
    }

    get getSelectIconClass() {
        return (
            'slds-combobox__input-entity-icon ' +
            (this.hasSelection() ? '' : 'slds-hide')
        );
    }

    get getInputValue() {
        
        /*if(this.defaultlabel){
            return   this.defaultlabel;
        }*/
        if (this.isMultiEntry) {
            return this.searchTerm;
        }
        /**original code */
        // return this.hasSelection() ? this.selection[0].title : this.searchTerm; 
        return this.hasSelection() ? this.selection[0].label : this.searchTerm;
    }

    get getInputTitle() {
        /*if(this.defaultvalue){
            return this.defaultvalue;
        }*/
        if (this.isMultiEntry) {
            return '';
        }

            /**original code */
        //return this.hasSelection() ? this.selection[0].title : '';
        return this.hasSelection() ? this.selection[0].label : '';
    }

    get getListboxClass() {
        let overflow = ' container-overflow-auto ';
        let css =  'slds-listbox slds-listbox_vertical slds-dropdown slds-dropdown_fluid container-scroll ' +
                    (this.searchResults.length > 3 ? overflow  : ' ' ) +
                    //(this.result === true ? ' slds-hide ' : ' slds-show ' ) +
                    (this.scrollAfterNItems
                        ? 'slds-dropdown_length-with-icon-' + this.scrollAfterNItems
                        : '');
        return css;
    }

    get isInputReadonly() {
        if (this.isMultiEntry) {
            return false;
        }
        return this.hasSelection();
    }

    get isExpanded() {
        return this.hasResults();
    }

    get getIsNoResults(){
        return !this.hasSelection() && !this.hasResults();
    }

    handleKeyDown({code}){
    
        if(this.isMouseOut){
            if ('ArrowUp' === code && !this.hasSelection()) {
                if(this.counter > 1){
                    this.previousCounter = this.counter;
                    this.counter --;
                    this.handleFocusSelection(this.counter, this.previousCounter);
                  
                }else if(this.searchResults.length >0){
                    this.previousCounter = this.counter;
                    this.counter = this.searchResults.length;
                    this.handleFocusSelection(this.counter, this.previousCounter);
                }
                
            } else if('ArrowDown' === code) {

                if(this.counter < this.searchResults.length){
                this.previousCounter = this.counter;
                this.counter ++;
                this.handleFocusSelection(this.counter, this.previousCounter);
               
                }else if(this.searchResults.length > 0){
                    //if last item return to 1st row
                    this.previousCounter = this.counter;
                    this.counter = 1;
                    this.handleFocusSelection(this.counter, this.previousCounter);
                    
                }

            } 
            else if('Enter' === code && this.searchResults.length >0 && this.counter>0) {
                const selectedItem = this.searchResults[this.counter-1];
                this.handleResultClick2(selectedItem.value, selectedItem.label);

                const selected = this.template.querySelector(`[data-id="searchBox"]`)
                selected.classList.add('slds-has-focus');
                selected.focus();

            }
            else if('Backspace' === code){
                if(this.counter !==0){
                    this.previousCounter =0;
                    this.counter =0;
                }
            }
            
        } 
        if(this.counter >0 && 'Tab' !== code && !this.hasSelection()){
            this.handleScrollTop();
        }
    }

    handleFocusSelection(counter, previousCounter){

        if(previousCounter >0){
            const prevSelected = this.template.querySelector(`[data-id="${previousCounter -1}"]`)
            prevSelected.classList.remove('slds-has-focus');
        }

        const selected = this.template.querySelector(`[data-id="${counter -1}"]`)
        selected.classList.add('slds-has-focus');
        selected.focus();
        
    }

    getMouseOut(){
        this.isMouseOut = true;
    }

    getMouseOver(){
        
        this.isMouseOut = false;
        if(this.counter>0){
            const selected = this.template.querySelector(`[data-id="${this.counter -1}"]`)
            selected.classList.remove('slds-has-focus');
            this.counter =0;
            this.previousCounter =0;
        }
    }

    handleScrollTop(){
        //set to top
        this.template.querySelector('.container-scroll').scrollTop=0;

        //then set equal to the position of the selected element minus the height of scrolling div
        const offset = this.template.querySelector(`[data-id="${this.counter -1}"]`).offsetTop;
        const height = this.template.querySelector('.container-scroll').offsetHeight -36;

        this.template.querySelector('.container-scroll').scrollTop =(offset-height);
    
    }

    @api handleInputFocus(){
        this.template.querySelector('[data-id="searchBox"]').focus();
        this.template.querySelector('[data-id="container"]').classList.add('slds-has-input-focus');
        // this.hasFocus = true;
    }


    @api handleError(){
        const lookup = this.template.querySelector('[data-name="lookup-container"]');
            setTimeout(() => {
                lookup.classList.add('slds-has-error');
            }) 
        }
}