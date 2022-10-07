/**
 * @description Change QUT Logo in CCE page [ Login Page ]
 *
 * @see ../storeStaticHeader.js
 * 
 * @author Accenture
 *      
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                         |
	  |---------------------------|-----------------------|--------------|--------------------------------------------------------|
	  | john.o.esguerra           | September 20, 2022    | DEPP-4350    | Modified Static header login page                      |
*/

import { LightningElement } from 'lwc';
import qutResourceImg from "@salesforce/resourceUrl/QUTImages";

export default class StoreStaticHeader extends LightningElement {
    qutexlogoUrl = qutResourceImg + "/QUTImages/Logo/QUT_logo_small.png";

    connectedCallback(){
        this.qutMenu = qutResourceImg + "/QUTImages/Logo/QUT_logo_small.png";	
    }
}