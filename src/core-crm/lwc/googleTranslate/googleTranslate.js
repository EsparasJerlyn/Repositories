/**
 * @description LWC for Google Translate functionality to be used on Case Lightning Record Page
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
      |---------------------------|-----------------------|----------------------|----------------------------------------------|
      | eccarius.munoz            | November 08, 2022     | DEPP-4231            | Created file                                 |
      |                           |                       |                      |                                              |
 */

import { api, LightningElement, wire } from 'lwc';
import { createRecord, getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import CASE_COMMENT_OBJ from '@salesforce/schema/CaseComment';
import SUBJECT_FIELD from '@salesforce/schema/Case.Subject';
import DESCRIPTION_FIELD from '@salesforce/schema/Case.Description';
import GOOGLE_LOGO from '@salesforce/resourceUrl/googleLogo';

const fields = [SUBJECT_FIELD, DESCRIPTION_FIELD];

const SUCCESS_TITLE = 'Success!';
const SUCCESS_VARIANT = 'success';
const SUCCESS_MSG = 'Added to case comment.';  
const HEADER_TITLE = 'TRANSLATE';
const TRANS_SUBJ_DESC_BTN_LABEL = 'Translate Subject and Description';
const COPY_TRANS_BTN_LABEL = 'Copy Translation';
const ADD_TO_COMMENT_BTN_LABEL = 'Add Translation to Comment';

export default class GoogleTranslate extends LightningElement {

    subject = '';
    description = '';
    translatedText = '';

    isShowButtonHidden = false;
    isHideButtonHidden = true;
    displayTranslation = false;

    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields })
    case;

    //Creates Case Comment record
    handleCopyToCaseComment(){     
        let commentToSave = this.template.querySelector(".translatedTextArea").value;
        let fields = {};  
        fields = {
            ParentId : this.recordId,
            CommentBody : commentToSave
        }
        const recordInput = { apiName: CASE_COMMENT_OBJ.objectApiName, fields };
        createRecord(recordInput)
            .then(() => {  
                this.generateToast(SUCCESS_TITLE, SUCCESS_MSG, SUCCESS_VARIANT);
            })
            .catch(error => {
                console.error('ERROR: ' + JSON.stringify(error));
            }
        );
    }

    handleTranslate(){
        //this should call google api translation
        this.translatedText = this.template.querySelector(".sourceTextArea").value;
    }

    handleShowButton(){
        this.isShowButtonHidden = true;
        this.isHideButtonHidden = false;
        this.displayTranslation = true;
    }

    handleHideButton(){
        this.isShowButtonHidden = false;
        this.isHideButtonHidden = true;
        this.displayTranslation = false;
    }

    handleTranslateSubjAndDesc(){
        this.subject = this.case.data.fields.Subject.value;
        this.description = this.case.data.fields.Description.value;
    }

    generateToast(_title, _message, _variant) {
        const evt = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant,
        });

        this.dispatchEvent(evt);
    }

    //Getters
    get sourTextValue(){
        if(this.description && this.subject){
            return this.subject + '\n \n' + this.description;
        }
    }
    
    get translation(){
        return this.translatedText;
    }

    get googleLogo(){
        return GOOGLE_LOGO;
    }

    get headerTitle(){
        return HEADER_TITLE;
    }

    get transSubjAndDescBtnLbl(){
        return TRANS_SUBJ_DESC_BTN_LABEL;
    }

    get copyTransBtnLbl(){
        return COPY_TRANS_BTN_LABEL;
    }

    get addToCommBtnLbl(){
        return ADD_TO_COMMENT_BTN_LABEL;
    }

    get options() {
        return [
            { label: 'Cebuano', value: 'Cebuano' },
            { label: 'Chinese', value: 'Chinese' },
            { label: 'English', value: 'English' },
            { label: 'Filipino', value: 'Filipino' },
            { label: 'French', value: 'French' }
        ];
    }

}