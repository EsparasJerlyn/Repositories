/**
 * @description A LWC component to display paginator
 * 
 * @see ../classes/B2BSearchCtrl.cls
 * @see ../classes/B2BGetInfo.cls
 * @see searchResults
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
      |---------------------------|-----------------------|----------------------|----------------------------------------------|
      | eugene.andrew.abuan       | March 02, 2022        | DEPP-1269            | Added logic in handling numeric pages        |
 */

import { LightningElement, api } from 'lwc';

/**
 * A simple paginator UI control for any results pagination.
 *
 * @fires SearchPaginator#previous
 * @fires SearchPaginator#next
 */
export default class SearchPaginator extends LightningElement {
    /**
     * An event fired when the user clicked on the previous page button.
     *
     * Properties:
     *   - Bubbles: false
     *   - Composed: false
     *   - Cancelable: false
     *
     * @event SearchPaginator#previous
     * @type {CustomEvent}
     *
     * @export
     */

    /**
     * An event fired when the user clicked on the next page button.
     *
     * Properties:
     *   - Bubbles: false
     *   - Composed: false
     *   - Cancelable: false
     *
     * @event SearchPaginator#next
     * @type {CustomEvent}
     *
     * @export
     */

    /**
     * The current page number.
     *
     * @type {Number}
     */
    @api pageNumber;

    /**
     * The number of items on a page.
     *
     * @type {Number}
     */
    @api pageSize;

    /**
     * The total number of items in the list.
     *
     * @type {Number}
     */
    @api totalItemCount;
    
    @api selectedPage = 1;

    /**
     * Handles a user request to go to the previous page.
     *
     * @fires SearchPaginator#previous
     * @private
     */
    handlePrevious() {
        this.dispatchEvent(new CustomEvent('previous'));
    }

    /**
     * Handles a user request to go to the next page.
     * @fires SearchPaginator#next
     * @private
     */
    handleNext() {
        this.dispatchEvent(new CustomEvent('next'));
    }

    /**
     * Gets the current page number.
     *
     * @type {Number}
     */
    get currentPageNumber() {
        return this.totalItemCount === 0 ? 0 : this.pageNumber;
    }

    /**
     * Gets whether the current page is the first page.
     *
     * @type {Boolean}
     * @readonly
     * @private
     */
    get isFirstPage() {
        return this.pageNumber === 1;
    }

    /**
     * Gets whether the current page is the last page.
     *
     * @type {Boolean}
     * @readonly
     * @private
     */
    get isLastPage() {
        return this.pageNumber >= this.totalPages;
    }

    /**
     * Gets the total number of pages
     *
     * @type {Number}
     * @readonly
     * @private
     */
    get totalPages() {
        return Math.ceil(this.totalItemCount / this.pageSize);
    }

    //Creates event to pass the value of Selected Page to Parent -> searchResults
    handlePage(event) {
        this.selectedPage = event.target.label;
        const selectedPageEvent = new CustomEvent('selectedpage',{
            detail : this.selectedPage
        });
        console.log( 'this selectedPage',this.selectedPage)
        this.dispatchEvent(selectedPageEvent);
    }

    get pages() {
        let pages = [];
        let min = 1;
        let max = 1;

        if((this.currentPageNumber <= 2) && (this.totalPages <= 3)) {
            min = 1;
            max = parseInt(this.totalPages);
        }
        else if( (this.currentPageNumber <= 2) && (this.totalPages > 3 )) {
            min = 1;
            max = 3;
        }
        else if( (this.currentPageNumber > 2) && (this.currentPageNumber < this.totalPages )) {
            min = parseInt(this.pageNumber) - 1;
            max = parseInt(this.pageNumber) + 1;
        }
        else if( (this.pageNumber > 2) && (this.pageNumber == this.totalPages )) {
            min = parseInt(this.pageNumber) - 2;
            max = parseInt(this.totalPages);
        }

        for(let i = min; i <= max; i++){
            pages.push({
                page: i,
                class: (i == this.pageNumber ? 'btn-pagination' : '')
            });
        }
        return pages;
    }
}