/**
 * @description LWC for managing registration questions
 *
 * @see ../classes/SetupRegistrationCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                                     |
      |---------------------------|-----------------------|----------------------|----------------------------------------------------|
      | angelika.j.s.galang       | January 21, 2022      | DEPP-1396            | Created file                                       |
      | john.bo.a.pineda          | February 03, 2022     | DEPP-1352            | Changed reference from Answer to Related Answer    |
      |                           |                       |                      |                                                    |
 */
import { LightningElement, api, wire, track } from "lwc";
import { createRecord, deleteRecord } from "lightning/uiRecordApi";
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from "@salesforce/apex";
import HAS_PERMISSION from "@salesforce/customPermission/EditDesignAndReleaseTabsOfProductRequest";
import LWC_Error_General from "@salesforce/label/c.LWC_Error_General";
import ANSWER_OBJECT from "@salesforce/schema/Related_Answer__c";
import PRODUCT_OBJECT from "@salesforce/schema/Product2";
import QUESTION_OBJECT from "@salesforce/schema/Question__c";
import QUESTIONNAIRE_OBJECT from "@salesforce/schema/Questionnaire__c";
import QUESTIONNAIRE_TYPE from "@salesforce/schema/Questionnaire__c.Questionnaire_Type__c";
import getRegistrationData from "@salesforce/apex/SetupRegistrationCtrl.getRegistrationData";
import getQuestionLayout from "@salesforce/apex/SetupRegistrationCtrl.getQuestionLayout";
import updateAnswerSequences from "@salesforce/apex/SetupRegistrationCtrl.updateAnswerSequences";

const COLUMN_CLASS = "slds-col slds-p-around_none slds-border_bottom ";
const COL_ONE = "slds-size_1-of-12";
const COL_TWO = "slds-size_2-of-12";
const STR_QUESTION = "Question";
const STR_QUESTIONNAIRE = "Questionnaire";
const STR_REGISTRATION_CRITERIA = "Registration Criteria";
export default class SetupRegistration extends LightningElement {
  @api recordId;
  @api isStatusCompleted;

  questionColumns = [
    { label: "Sequence", class: COLUMN_CLASS + COL_ONE },
    { label: "Label", class: COLUMN_CLASS + COL_TWO },
    { label: "Type", class: COLUMN_CLASS + COL_TWO },
    { label: "Dropdown Options", class: COLUMN_CLASS + COL_TWO },
    { label: "Acceptable Response", class: COLUMN_CLASS + COL_TWO },
    { label: "Message", class: COLUMN_CLASS + COL_TWO },
    { label: "Action", class: COLUMN_CLASS + COL_ONE }
  ];

  @track selectedQuestionnaire = {};
  @track registrationData = [];
  allQuestions = [];
  availableQuestions = [];
  availableQuestionsToDisplay = [];
  layoutToDisplay = [];
  draftRelatedQuestions = [];
  initialLoad = true;
  isLoading = false;
  createQuestionnaire = false;
  createEditQuestion = false;
  searchBoxOpen = false;
  sequenceEdited = false;
  hasRendered = false;
  createRecord = false;
  createRecordLabel = "";
  selectedQuestionnaireOption = "";
  questionId;
  showAcceptableResponseError = false;

  //checks if user has permission for this feature
  get hasAccess() {
    return HAS_PERMISSION;
  }

  //returns api name of question object
  get questionApiName() {
    return QUESTION_OBJECT.objectApiName;
  }

  //filters questionnaire options based on already selected choice/s
  get questionnaireOptions() {
    let _options = [];
    if (this.questionnaireTypeOptions.data) {
      let _existingTypes = this.registrationData.map((navItem) => {
        return navItem.type;
      });
      _options = this.questionnaireTypeOptions.data.values.filter(
        (item) => !_existingTypes.includes(item.value)
      );
    }
    return _options;
  }

  //decides if main content should appear
  get showContent() {
    return this.registrationData.length > 0 && this.selectedQuestionnaire;
  }

  //decides if create questionnaire button should be disabled
  get disableCreateQuestionnaire() {
    return this.questionnaireOptions.length == 0 || this.isStatusCompleted;
  }

  //decides if create questionnaire button should be disabled
  get disableCreateQuestionnaireHelp() {
    return this.questionnaireOptions.length == 0 && !this.isStatusCompleted;
  }

  //decides if question columns should appear
  get showColumnHeaders() {
    return (
      this.selectedQuestionnaire &&
      this.selectedQuestionnaire.relatedQuestions.length > 0
    );
  }

  //returns api name of record to be created
  get createRecordObject() {
    return this.createRecordLabel == STR_QUESTION
      ? this.questionApiName
      : QUESTIONNAIRE_OBJECT.objectApiName;
  }

  //returns appropriate modal header
  get createRecordHeader() {
    let verb = this.questionId ? "Edit " : "Create ";
    return verb + this.createRecordLabel;
  }

  //checks if question sequence is invalid (empty, zero, with repeats, and out of range)
  get sequenceInvalid() {
    let sequences = this.selectedQuestionnaire.relatedQuestions
      .filter(
        (row) =>
          row.sequence !== "" &&
          row.sequence > 0 &&
          row.sequence <= this.selectedQuestionnaire.relatedQuestions.length
      )
      .map((row) => {
        return row.sequence;
      });
    return (
      [...new Set(sequences)].length !==
      this.selectedQuestionnaire.relatedQuestions.length
    );
  }

  //checks if there are available questions
  get noQuestionAvailable() {
    return this.availableQuestionsToDisplay.length == 0;
  }

  //decides if save button should be disabled
  get disableSave() {
    return this.createQuestionnaire && !this.selectedQuestionnaireOption;
  }

  //decides if acceptable response note is to be shown
  get showAcceptableResponseNote(){
    return this.selectedQuestionnaire.type == STR_REGISTRATION_CRITERIA && 
      !this.noQuestionAvailable &&
      this.searchBoxOpen;
  }

  //gets questionnaire object information
  @wire(getObjectInfo, { objectApiName: QUESTIONNAIRE_OBJECT })
  questionnaireObjectInfo;

  //gets picklist values of questionnaire type field
  @wire(getPicklistValues, {
    recordTypeId: "$questionnaireObjectInfo.data.defaultRecordTypeId",
    fieldApiName: QUESTIONNAIRE_TYPE
  })
  questionnaireTypeOptions;

  //calls apex method and stores question, questionnaire, and related answer records
  registrationResult;
  @wire(getRegistrationData, { productRequestId: "$recordId" })
  handleGetRegistrationData(result) {
    this.isLoading = true;
    if (result.data) {
      this.registrationResult = result;
      this.allQuestions = this.registrationResult.data.questionList;
      this.registrationData =
        this.registrationResult.data.questionnaireList.map((data) => {
          let questionnaire = {};
          questionnaire.id = data.Id;
          questionnaire.name = data.Name;
          questionnaire.type = data.Questionnaire_Type__c;
          questionnaire.url = "/" + data.Id;
          questionnaire.relatedQuestions =
            this.allQuestions.length > 0
              ? this.formatRelatedQuestions(data.Id)
              : [];
          questionnaire.questionCount = questionnaire.relatedQuestions.length;
          return questionnaire;
        });
      if (this.registrationData.length > 0) {
        if (this.initialLoad) {
          this.setSelectedQuestionnaire(this.registrationData[0]);
          this.initialLoad = false;
        } else {
          this.setSelectedQuestionnaire(
            this.registrationData.find(
              (data) => data.id == this.selectedQuestionnaire.id
            )
          );
        }
        this.getAvailableQuestions();
      }
      this.isLoading = false;
    } else if (result.error) {
      this.generateToast("Error.", LWC_Error_General, "error");
      this.isLoading = false;
    }
  }

  //gets question layout from metadata for modal on component load
  connectedCallback() {
    this.isLoading = true;
    getQuestionLayout({ objApiName: this.questionApiName, forOpe: true })
      .then((result) => {
        this.layoutToDisplay = [...result].map((layout) => {
          let layoutItem = {};
          layoutItem.sectionLabel = layout.MasterLabel;
          layoutItem.leftColumn = layout.Left_Column_Long__c
            ? JSON.parse(layout.Left_Column_Long__c)
            : null;
          layoutItem.rightColumn = layout.Right_Column_Long__c
            ? JSON.parse(layout.Right_Column_Long__c)
            : null;
          layoutItem.singleColumn = layout.Single_Column_Long__c
            ? JSON.parse(layout.Single_Column_Long__c)
            : null;
          return layoutItem;
        });
      })
      .catch((error) => {
        this.generateToast("Error.", LWC_Error_General, "error");
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  //pre-selects questionnaire (if available) on component render
  renderedCallback() {
    if (!this.hasRendered && this.template.querySelector(".last-div")) {
      this.hasRendered = true;
      this.setActiveNav();
    }
  }

  //formats related questions of each questionnaire
  formatRelatedQuestions(questionnaireId) {
    let questions = [];
    this.allQuestions.forEach((question) => {
      let relatedAnswer = question.Related_Answers__r
        ? question.Related_Answers__r.find(
            (answer) => answer.Questionnaire__c == questionnaireId
          )
        : null;
      if (relatedAnswer) {
        let _question = {};
        _question.sequence = relatedAnswer.Sequence__c;
        _question.answerId = relatedAnswer.Id;
        _question.id = question.Id;
        _question.label = question.Label__c;
        _question.type = question.Type__c;
        _question.dropdownOptions = question.Dropdown_Options__c;
        _question.acceptableResponse = question.Acceptable_Response__c;
        _question.message = question.Message__c;
        _question.editable = question.Related_Answers__r.find(
          (answer) => answer.Name < relatedAnswer.Name
        )
          ? false
          : true;
        questions.push(_question);
      }
    });
    questions = questions.sort((a, b) => a.sequence - b.sequence);
    return questions;
  }

  //gets all questions not added to questionnaire and sorts by label
  getAvailableQuestions() {
    this.availableQuestions = this.allQuestions.filter(
      (question) =>
        !this.selectedQuestionnaire.relatedQuestions
          .map((rq) => {
            return rq.id;
          })
          .includes(question.Id)
    );
    this.availableQuestions = this.availableQuestions.sort((a, b) =>
      a.Label__c.localeCompare(b.Label__c)
    );

    if(this.selectedQuestionnaire.type == STR_REGISTRATION_CRITERIA){
      this.availableQuestions = this.availableQuestions.filter(question => question.Acceptable_Response__c);
    }
    
    this.availableQuestionsToDisplay = this.availableQuestions;
  }

  //adds active class to selected questionnaire for navigation sidebar
  setActiveNav() {
    this.template
      .querySelector(`[data-id="${this.selectedQuestionnaire.id}"]`)
      .classList.add("slds-is-active");
  }

  //removes active class from previously selected questionnaire
  removeActiveNav() {
    this.template
      .querySelector(`[data-id="${this.selectedQuestionnaire.id}"]`)
      .classList.remove("slds-is-active");
  }

  //assigns selected questionnaire and draft related questions
  setSelectedQuestionnaire(selected) {
    this.selectedQuestionnaire = selected;
    this.draftRelatedQuestions = this.selectedQuestionnaire.relatedQuestions;
  }

  //handles selection of either the create buttons
  handleCreateRecord(event) {
    this.createRecordLabel = event.target.dataset.name;
    if (this.createRecordLabel == STR_QUESTIONNAIRE) {
      this.createQuestionnaire = true;
    } else if (this.createRecordLabel == STR_QUESTION) {
      this.createEditQuestion = true;
    }
    this.createRecord = true;
  }

  //pre-populates field if record is questionnaire
  handleSubmitRecord(event) {
    event.preventDefault();
    this.showAcceptableResponseError = false;
    this.isLoading = true;
    let fields = event.detail.fields;
    if (this.createRecordLabel == STR_QUESTIONNAIRE) {
      fields[QUESTIONNAIRE_TYPE.fieldApiName] =
        this.selectedQuestionnaireOption;
      fields.Object_Type__c = PRODUCT_OBJECT.objectApiName;
      fields.Parent_Record_ID__c = this.recordId;
      this.template.querySelector("lightning-record-edit-form").submit(fields);
    } else if (this.createRecordLabel == STR_QUESTION) {
      if(!fields.Acceptable_Response__c && this.selectedQuestionnaire.type == STR_REGISTRATION_CRITERIA){
        this.showAcceptableResponseError = true;
        this.isLoading = false;
      }else{
        this.template.querySelector("lightning-record-edit-form").submit(fields);
      }
    }
  }

  //handles successful save of record edit form
  handleSuccessRecord(event) {
    if (this.createRecordLabel == STR_QUESTION && !this.questionId) {
      this.handleCreateAnswerRecord(event.detail.id);
    }
    refreshApex(this.registrationResult).then(() => {
      if (this.createRecordLabel == STR_QUESTIONNAIRE) {
        this.removeActiveNav();
        this.setSelectedQuestionnaire(
          this.registrationData[this.registrationData.length - 1]
        );
        this.setActiveNav();
        this.generateToast(
          "Success!",
          STR_QUESTIONNAIRE + " created.",
          "success"
        );
      } else if (this.createRecordLabel == STR_QUESTION && this.questionId) {
        this.generateToast("Success!", STR_QUESTION + " updated.", "success");
      }
      this.isLoading = false;
      this.handleCloseCreateRecord();
    });
  }

  //creates answer record with related fields
  handleCreateAnswerRecord(questionInserted, added) {
    let _fields = {
      Question__c: questionInserted,
      Questionnaire__c: this.selectedQuestionnaire.id,
      Sequence__c: this.selectedQuestionnaire.relatedQuestions.length + 1
    };
    const fields = { ..._fields };
    const recordInput = { apiName: ANSWER_OBJECT.objectApiName, fields };
    createRecord(recordInput)
      .then((record) => {
        let verb = added ? " added." : " created.";
        this.generateToast("Success!", STR_QUESTION + verb, "success");
      })
      .catch((error) => {
        this.generateToast("Error.", LWC_Error_General, "error");
      })
      .finally(() => {
        refreshApex(this.registrationResult);
      });
  }

  //sets spinner to false when a record edit form error is encountered
  handleErrorRecord() {
    this.isLoading = false;
  }

  //resets values of modal is closed
  handleCloseCreateRecord() {
    this.createRecord = false;
    this.createEditQuestion = false;
    this.createQuestionnaire = false;
    this.showAcceptableResponseError = false;
    this.createRecordLabel = "";
    this.questionId = "";
    this.selectedQuestionnaireOption = "";
  }

  //sets the selected questionnaire type
  handleQuestionnaireOptionChange(event) {
    this.selectedQuestionnaireOption = event.detail.value;
  }

  //handles questionnaire selection in sidebar
  handleNavSelect(event) {
    this.removeActiveNav();
    this.setSelectedQuestionnaire(
      this.registrationData.find(
        (item) => item.name == event.target.dataset.name
      )
    );
    this.template.querySelector(".input-search").value = "";
    this.setActiveNav();
    this.handleSearchBlur();
    this.getAvailableQuestions();
  }

  //shows available questions when search bar is clicked
  handleSearchClick() {
    this.template
      .querySelector(".search-results")
      .classList.add("slds-is-open");
    this.template
      .querySelector(".input-search")
      .classList.add("slds-has-focus");
    this.searchBoxOpen = true;
  }

  //hides search results
  handleSearchBlur() {
    this.template
      .querySelector(".search-results")
      .classList.remove("slds-is-open");
    this.template
      .querySelector(".input-search")
      .classList.remove("slds-has-focus");
    this.searchBoxOpen = false;
  }

  //closes search results when escape key is pressed
  handleSearchKeydown(event) {
    if (event.code == "Escape") {
      this.handleSearchBlur();
    }
  }

  //filters search results; resets if input is blank
  handleQuestionSearch(event) {
    let filterString = event.target.value;
    if (filterString) {
      this.availableQuestionsToDisplay = this.availableQuestions.filter(
        (question) =>
          question.Label__c.toLowerCase().includes(filterString.toLowerCase())
      );
    } else {
      this.availableQuestionsToDisplay = this.availableQuestions;
    }
  }

  //handles existing question selection
  handleAddExistingQuestion(event) {
    let qId = event.currentTarget.dataset.recordid;
    this.template.querySelector(".input-search").value = "";
    this.handleCreateAnswerRecord(qId, true);
    this.handleSearchBlur();
  }

  //handles editing of question details
  handleEditQuestion(event) {
    this.questionId = event.target.dataset.name;
    this.createRecordLabel = STR_QUESTION;
    this.createRecord = true;
    this.createEditQuestion = true;
  }

  //deletes related answer record when question is removed from questionnaire
  //updates sequence of succeeding answers (if there are)
  handleRemoveQuestion(event) {
    this.isLoading = true;
    let seq = this.selectedQuestionnaire.relatedQuestions.find(
      (rq) => rq.answerId == event.target.dataset.name
    ).sequence;
    deleteRecord(event.target.dataset.name)
      .then(() => {
        let answersToUpdate = this.selectedQuestionnaire.relatedQuestions
          .filter((draft) => draft.sequence > seq)
          .map((que) => ({ Id: que.answerId, Sequence__c: que.sequence - 1 }));
        if (answersToUpdate.length > 0) {
          this.handleUpdateSequence(answersToUpdate);
        }
        this.generateToast("Success!", "Question removed.", "success");
      })
      .catch((error) => {
        this.generateToast("Error.", LWC_Error_General, "error");
      })
      .finally(() => {
        this.isLoading = false;
        refreshApex(this.registrationResult);
      });
  }

  //updates sequence of related questions to draft values
  handleSequenceChange(event) {
    this.sequenceEdited = true;
    this.selectedQuestionnaire.relatedQuestions =
      this.selectedQuestionnaire.relatedQuestions.map((row) => ({
        ...row,
        sequence:
          event.target.name === row.answerId
            ? parseInt(event.target.value)
            : row.sequence
      }));
  }

  //filters modified sequence and calls update if sequence is valid
  handleSaveSequence() {
    let answersToUpdate = this.selectedQuestionnaire.relatedQuestions
      .filter(
        (draft) =>
          this.draftRelatedQuestions.find(
            (answer) => answer.answerId == draft.answerId
          ).sequence !== draft.sequence
      )
      .map((que) => ({ Id: que.answerId, Sequence__c: que.sequence }));
    if (!this.sequenceInvalid && answersToUpdate.length > 0) {
      this.handleUpdateSequence(answersToUpdate);
    }
  }

  //calls apex class to update answer list with updated sequences
  handleUpdateSequence(answersToUpdate) {
    this.isLoading = true;
    updateAnswerSequences({ answers: answersToUpdate })
      .then((result) => {
        this.generateToast("Success!", "Sequence updated.", "success");
      })
      .catch((error) => {
        this.generateToast("Error.", LWC_Error_General, "error");
      })
      .finally(() => {
        this.isLoading = false;
        refreshApex(this.registrationResult).then(() => {
          this.handleCancelSequence();
        });
      });
  }

  //resets sequence values when cancel button is clicked
  handleCancelSequence() {
    this.sequenceEdited = false;
    this.selectedQuestionnaire.relatedQuestions = this.draftRelatedQuestions;
  }

  //creates toast notification
  generateToast(_title, _message, _variant) {
    const evt = new ShowToastEvent({
      title: _title,
      message: _message,
      variant: _variant
    });
    this.dispatchEvent(evt);
  }
}
