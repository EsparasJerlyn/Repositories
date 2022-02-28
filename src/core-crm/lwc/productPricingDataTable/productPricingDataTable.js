
/**
 * @description A custom datable for enabling search box in lightning datatable
 *
 * @see ../lwc/productPricing
 * 
 * @author Accenture
 *      
 * @history
 *    | Developer                 | Date                  | JIRA                | Change Summary                                         |
      |---------------------------|-----------------------|---------------------|--------------------------------------------------------|
      | roy.nino.s.regala         | February 20, 2022     | DEPP-1773,1406,1257 | Created file                                           |
*/
import LightningDatatable from 'lightning/datatable';
/*
    import all supporting components
*/
import customSearch      from        './customSearch.html';

export default class ProductPriceDataTable extends LightningDatatable {
    static customTypes = {
        customSearch : {
            template: customSearch,
            typeAttributes: ['icon','parentId','placeholder','lookupItems','itemServerName','itemId','objectLabelName'],
        }
    };
}