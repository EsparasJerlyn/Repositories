import { LightningElement } from 'lwc';
import individualBanner from '@salesforce/resourceUrl/individualBanner';
import homeBanner from '@salesforce/resourceUrl/homeBanner';
import orgBanner from '@salesforce/resourceUrl/orgBanner';
import logo from '@salesforce/resourceUrl/qutexlogo';
const STUDY_STORE = 'study';


export default class PageBanner extends LightningElement {
    qutexlogo = logo;
    
   /**
   * Handles banner for OPE
   */
    get individualBannerStyle() {
        return `background-image:url(${individualBanner})`;
    }

   /**
   * Handles banner for CCE
   */
    get orgBannerStyle() {
        return `background-image:url(${orgBanner})`;
    }

   /**
   * Handles home banner for OPE/CCE
   */
    get homeBannerStyle() {
        return `background-image:url(${homeBanner})`;
    }

   /**
   * Handles store checking
   */
    get showIfStudy(){
        return (window.location.href.indexOf(STUDY_STORE) > -1 ? true : false);
    }

   /**
   * Handles banner text
   */
    get bannerText(){
        let text ='';
        if(this.showIfStudy){
            text += `Get future fit, fast with our selection of short courses, masterclasses and open programs, designed to help you upskill or reskill to advance your career.`;
        }else{
            text += `Get your team future fit, fast with tailored executive education designed to meet the exact needs of your organisation.`;   
        }
        return text;
    }


}