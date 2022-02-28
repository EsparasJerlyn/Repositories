/**
 * @description Lightning Web Component for custom datatable.
 *  
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | eccarius.karl.munoz       | February 09, 2022     | DEPP-1483            | Created file                 | 
      |                           |                       |                      |                              | 
 */

import { LightningElement, api } from 'lwc';

export default class CustomDatatable extends LightningElement {

    @api records;
    @api columns;
    @api enableEdit;
    @api enableDelete;

    sortBy;
    sortDirection; 
    draftValues = [];          

    //Adds row action based on parent component
    connectedCallback(){ 
        let columns = [];
        this.columns.forEach(element => {
            columns.push(element);
        });
        if(this.enableEdit){
            let editAction = { type: 'action', typeAttributes: {  rowActions: [ { label: 'Edit', name: 'edit' } ] } };  
            columns.push(editAction);          
        }
        if(this.enableDelete){
            let deleteAction = { type: 'action', typeAttributes: {  rowActions: [ { label: 'Delete', name: 'delete' } ] } }; 
            columns.push(deleteAction);           
        }    
        this.columns = columns;
    } 

    //Fires an event (save) that sends draftvalues to parent component
    handleSave(event){
        this.draftValues = event.detail.draftValues; 
        const saveRecordsEvent = new CustomEvent('save', {
            detail: this.draftValues
        });
        this.dispatchEvent(saveRecordsEvent);  
        this.draftValues = [];          
    } 

    //Fires an event (edit/delete) that sends row details to parent component
    handleRowActions(event){
        let actionName = event.detail.action.name;
        if(actionName === 'edit'){
            const editEvent = new CustomEvent('edit', {
                detail: event.detail.row
            });
            this.dispatchEvent(editEvent);  
        }
        if(actionName === 'delete'){
            const editEvent = new CustomEvent('delete', {
                detail: event.detail.row
            });
            this.dispatchEvent(editEvent);
        }   
    }   

    //handles sorting of table columns
    handleSort(event) {     
        this.sortBy = event.detail.fieldName;      
        this.sortDirection = event.detail.sortDirection;        
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }

    sortData(fieldname, direction) {       
        let parseData = JSON.parse(JSON.stringify(this.records));     
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1: -1;
           parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        this.records = parseData;
    }    

}
