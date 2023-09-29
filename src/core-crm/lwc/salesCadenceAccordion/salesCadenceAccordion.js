/**
 * @description LWC that renders a datatable for cadence sales cadence list view
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                 | Date                  | JIRA                 | Change Summary                                                              |
 *    |---------------------------|-----------------------|----------------------|-----------------------------------------------------------------------------|
 *    | roy.nino.s.regala         | July 14, 2023         | DEPP-5677            | Created file                                                                |
 */
import { LightningElement, api} from "lwc";
export default class SalesCadenceAccordion extends LightningElement {
  /* TARGET CONFIG START */
  @api nurtureTrackList;
  /* TARGET CONFIG END */
  get accordionList(){
    return this.nurtureTrackList?this.nurtureTrackList.split(','):[];
  }
}
