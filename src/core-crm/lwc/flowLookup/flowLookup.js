/**
 * @description An LWC which contains logic for the flow custom lookup component
 * @see ../classes/FlowLookupController
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                 | Date                  | JIRA                 | Change Summary                                       |
 *    |---------------------------|-----------------------|----------------------|------------------------------------------------------|
 *    | ryan.j.a.dela.cruz        | June 5, 2023          | DEPP-5385            | Created file                                         |
 *    | ryan.j.a.dela.cruz        | August 9, 2023        | DEPP-6082            | Added unique session storage for lookup fields       |
 *    | ryan.j.a.dela.cruz        | August 17, 2023       | DEPP-6165            | Dynamically Display Option Sublabel as applicable    |
 *    | ryan.j.a.dela.cruz        | October 19, 2023      | DEPP-6928/DEPP-6973  | Fix empty fieldsToSearch                             |
 */
import { LightningElement, api, track } from "lwc";
import { FlowAttributeChangeEvent } from "lightning/flowSupport";
import { NavigationMixin } from "lightning/navigation";
import newRecordModal from "c/flowNewRecordModal";
import search from "@salesforce/apex/FlowLookupController.search";
import getRecentlyViewed from "@salesforce/apex/FlowLookupController.getRecentlyViewed";
import getRecordsFromIds from "@salesforce/apex/FlowLookupController.getRecordsFromIds";
import getObjectIcon from "@salesforce/apex/FlowLookupController.getObjectIcon";
import getRecords from "@salesforce/apex/FlowLookupController.getRecords";
import getRecordDetail from "@salesforce/apex/FlowLookupController.getRecordDetail";

const DEFAULTS = {
  NUM_RECENTLY_VIEWED: 5,
  DEBOUNCE_DELAY: 200
};

const ACTIONS = {
  NEW_RECORD: {
    label: "New Record",
    value: "newRecord",
    icon: "utility:add",
    isAction: true
  }
};

export default class FlowLookup extends NavigationMixin(LightningElement) {
  /* PUBLIC PROPERTIES */
  @api identifier; // Unique identifier from flow for field value retention
  @api objectName;
  @api label = "Select Record";
  @api required;
  @api messageWhenValueMissing = "Please select a record";
  @api publicClass;
  @api publicStyle;
  @api debounceDelay = DEFAULTS.DEBOUNCE_DELAY;

  @api get fieldsToSearch() {
    return this._fieldsToSearch;
  }

  set fieldsToSearch(value) {
    try {
      this._fieldsToSearch = value.toString();
      this.visibleFields_ToSearchNames = value.toString();
    } catch (error) {
      const logger = this.template.querySelector("c-logger");
      if (logger) {
        logger.error(
          "Exception caught in method fieldsToSearch in LWC flowLookup: ",
          JSON.stringify(error)
        );
        logger.saveLog();
      }
    }
  }

  @track _fieldsToSearch;
  @api visibleFields_ToSearchNames;

  @api get fieldsToDisplay() {
    return this._fieldsToDisplay;
  }
  set fieldsToDisplay(value) {
    this._fieldsToDisplay = value;

    // Check to see it _fieldsToDisplay is a array then parse it. If string do nothing
    // Depending if the user typed in the fields or used the picklist we need to account for both
    if (!value.includes("[")) {
      this.visibleFields_ToDisplayNames = value.replaceAll('"', "");
      this.fieldCollection_toDisplay = value.replaceAll('"', "");
    } else {
      this.visibleFields_ToDisplayNames = JSON.parse(value)
        .map((field) => field.name)
        .join();
      this.fieldCollection_toDisplay = JSON.parse(value).map(
        (field) => field.name
      );
    }
  }

  @track _fieldsToDisplay;
  @api visibleFields_ToDisplayNames;
  @api fieldCollection_toDisplay = [];

  @api get iconName() {
    return this._iconName;
  }
  set iconName(value) {
    this._iconName = value;
  }

  @track _iconName;
  @api leftIconName = "utility:search";
  @api rightIconName = "utility:down";
  @api placeholder;
  @api noMatchString = "No matches found";
  @api fieldLevelHelp;
  @api isLoading = false;
  @api showNewRecordAction = false;
  @api orderByClause; // Reserved for future use
  @api disabled = false;
  @api _defaultValueInput; // Id of default selected record

  /* PRIVATE PROPERTIES */
  @track recentlyViewedRecords = [];
  @track records = [];
  @track showNewRecordModal;

  /* OUTPUT PROPERTIES */
  @track _selectedRecordIdOutput; // Id of selected record
  @track _selectedRecordOutput; // Selected record ( full record detail )
  @track _numberOfRecords = 0;

  @api
  get whereClause() {
    return this._whereClause;
  }

  set whereClause(value) {
    this._whereClause = value;
    // If the where clause is changed then we need to reset the records
    this.loadRecords();
  }

  @track _whereClause;

  @api
  get numberOfRecordsOutput() {
    return this._numberOfRecords;
  }

  set numberOfRecordsOutput(value) {
    this._numberOfRecords = value;
    this.handleEventChanges("numberOfRecordsOutput", value);
  }

  @api
  get selectedRecordIdOutput() {
    return this._selectedRecordIdOutput;
  }

  set selectedRecordIdOutput(value) {
    this._selectedRecordIdOutput = value;

    // If value is set then get the full record details
    if (value) {
      // Get the full details of the selected records
      getRecordDetail({
        objectName: this.objectName,
        recordIds: this._selectedRecordIdOutput
      }).then((result) => {
        // Dispatch the entire record details
        this.selectedRecordOutput = result ? result[0] : {};
      });
    }
  }

  get defaultValueInput() {
    return this._defaultValueInput;
  }

  @api
  set defaultValueInput(value) {
    this._defaultValueInput = value;
    this.selectedRecordIdOutput = value;
    // Set numberOfRecordsOutput if value is set
    value ? (this.numberOfRecordsOutput = 1) : (this.numberOfRecordsOutput = 0);
    this.handleEventChanges("defaultValueInput", value);
  }

  @api
  get selectedRecordOutput() {
    return this._selectedRecordOutput;
  }

  set selectedRecordOutput(value) {
    this._selectedRecordOutput = value;
    this.handleEventChanges("selectedRecordOutput", value);
  }

  /* PUBLIC GETTERS AND SETTERS */
  @api
  get values() {
    return this._values || [];
  }
  set values(values) {
    if (!values) {
      this._values = [];
    } else {
      this._values = Array.isArray(values) ? values : [values];
      let unqueriedValues = this.values.filter(
        (value) => !this.records.some((record) => record.value == value)
      );
      if (unqueriedValues.length) {
        const logger = this.template.querySelector("c-logger");

        // String objectName, String fieldsToReturn, List<String> idsToRetrieve
        getRecordsFromIds({
          objectName: this.objectName,
          fieldsToReturn: this.visibleFields_ToDisplayNames,
          idsToRetrieve: unqueriedValues
        })
          .then((result) => {
            this.records = [...this.records, ...this.parseFields(result)];

            const seenValues = {};
            for (let i = 0; i < this.records.length; i++) {
              if (seenValues[this.records[i].value]) {
                this.records.splice(i, 1);
                i--; // Decrement index to account for the removed element
              } else {
                seenValues[this.records[i].value] = true;
              }
            }

            this.addNewRecordAction();
          })
          .catch((error) => {
            if (logger) {
              logger.error(
                "Exception caught in method getRecordsFromIds in LWC flowLookup: ",
                JSON.stringify(error)
              );
              logger.saveLog();
            }
          })
          .finally(() => {
            this.isLoading = false;
          });
      }
    }
  }

  @track _values = [];
  @api
  get value() {
    return this.values.join(this.valueDelimiter);
  }
  set value(value) {
    value = String(value);
    this.values = [value];
  }

  @api
  get selectedRecords() {
    let records = [];
    for (let value of this.values) {
      const record = this.records.find((rec) => rec.value === value);
      if (record) {
        records.push(record);
      }
    }
    return records;
  }

  @api
  get selectedRecord() {
    return this.selectedRecords.length ? this.selectedRecords[0] : null;
  }

  @api
  validate() {
    // If it is not valid then return error message and isValid = false
    if (
      this.required &&
      (this.values.length === 0 ||
        (this.values.length === 1 && this.values[0] === ""))
    ) {
      return {
        isValid: false,
        errorMessage: this.messageWhenValueMissing
      };
    } else {
      return { isValid: true };
    }
  }

  // Lifecycle hooks
  connectedCallback() {
    // Load the inital values and icon
    this.loadRecords();
  }

  loadRecords() {
    // Get the object's icon from getObjectIcon and set iconName
    getObjectIcon({ objectName: this.objectName }).then((result) => {
      this.iconName = result;

      // If defaultValueInput is set, we want to ignore the values passed in and set the default value
      if (this.defaultValueInput) {
        this.values = this.defaultValueInput;
        // Else if whereClause is set, we want to ignore the values passed in and set the whereClause
      } else if (this._whereClause) {
        this.getRecords();
        // Else get the recently viewed records
      } else {
        this.getRecentlyViewed();
      }

      if (this.identifier) {
        // Get the "uid" parameter from the URL
        const uid = this.getUrlParameter("uid");
        const sessionKey = uid
          ? `LOOKUP-${uid}-${this.identifier}`
          : `LOOKUP-${this.getCharacterHash(window.location.href)}-${
              this.identifier
            }`;
        // Check if the value already exists in session storage
        const existingValue = sessionStorage.getItem(sessionKey);

        if (existingValue !== null) {
          // A value already exists, set it t.o the value property
          this.values = [existingValue];
          this.selectedRecordIdOutput = existingValue;
        }
      }
    });
  }

  // Helper method to get URL parameters
  getUrlParameter(param) {
    const urlParams = new URLSearchParams(window.location.search);
    return urlParams.get(param);
  }

  // Helper method to extract the hash portion of the URL
  getCharacterHash(url) {
    return url.split("#")[1];
  }

  // Get the recently viewed records
  getRecentlyViewed() {
    this.isLoading = true;
    const logger = this.template.querySelector("c-logger");

    getRecentlyViewed({
      objectName: this.objectName,
      fieldsToReturn: this.visibleFields_ToDisplayNames,
      numRecordsToReturn: DEFAULTS.NUM_RECENTLY_VIEWED,
      whereClause: this._whereClause
    })
      .then((result) => {
        this.recentlyViewedRecords = this.parseFields(result);
        if (!this.records.length) {
          this.resetRecentlyViewed();
        }
      })
      .catch((error) => {
        if (logger) {
          logger.error(
            "Exception caught in method getRecentlyViewed in LWC flowLookup: ",
            JSON.stringify(error)
          );
          logger.saveLog();
        }
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  // Get the records from the whereClause
  // This will then populate the dropdown with the records that match the whereClause
  getRecords() {
    this.isLoading = true;
    const logger = this.template.querySelector("c-logger");

    getRecords({
      objectName: this.objectName,
      fieldsToReturn: this.visibleFields_ToDisplayNames,
      numRecordsToReturn: DEFAULTS.NUM_RECENTLY_VIEWED,
      whereClause: this._whereClause
    })
      .then((result) => {
        this.records = this.parseFields(result);
        this.addNewRecordAction();
      })
      .catch((error) => {
        if (logger) {
          logger.error(
            "Exception caught in method getRecords in LWC flowLookup: ",
            JSON.stringify(error)
          );
          logger.saveLog();
        }
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  // Method to handle changes in the search input
  handleSearchChange = (searchText) => {
    if (!searchText) {
      this.resetRecentlyViewed();
    } else {
      this.isLoading = true;
      const logger = this.template.querySelector("c-logger");

      if( searchText.length < 2 && this.objectName == 'Contact'){
        this.isLoading = false;
        return;
      }

      search({
        searchTerm: searchText,
        objectName: this.objectName,
        fieldsToSearch: this.visibleFields_ToSearchNames,
        fieldsToReturn: this.visibleFields_ToDisplayNames,
        whereClause: this._whereClause,
        orderByClause: this.orderByClause,
        numRecordsToReturn: 0
      })
        .then((result) => {
          this.records = this.parseFields(result);
          this.addNewRecordAction();
        })
        .catch((error) => {
          if (logger) {
            logger.error(
              "Exception caught in method search in LWC flowLookup: ",
              JSON.stringify(error)
            );
            logger.saveLog();
          }
        })
        .finally(() => {
          this.isLoading = false;
        });
    }
  };

  parseFields(apexResults) {
    let displayFields, labelField, sublabel, searchValue;

    // If visibleFields_ToDisplayNames is set, use that to parse the fields
    if (this.visibleFields_ToDisplayNames) {
      displayFields = this.visibleFields_ToDisplayNames.split(",");
      labelField = displayFields.splice(0, 1);
    }
    return apexResults.map((record) => {
      if (!labelField) {
        let nonIdFields = Object.keys(record).filter(
          (fieldName) => fieldName != "Id"
        );

        labelField = nonIdFields[0];
        // Check if the label is a lookup field
        if (labelField.includes(".")) {
          labelField = this.parseRelationshipFields(label, record);
        }
      }

      // Go through the displayFields and build the sublabel
      // If the field is a lookup, parse the relationship fields
      if (displayFields && displayFields.length > 0) {
        sublabel = displayFields
          .map((fieldName) => {
            if (fieldName.includes(".")) {
              return this.parseRelationshipFields(fieldName, record);
            } else {
              return record[fieldName];
            }
          })
          .filter((value) => value) // Filter out falsy values (e.g., empty strings, null)
          .join(" - ");
      }

      // if visibleFields_ToSearchNames is set, join the values and set as searchField
      if (this.visibleFields_ToSearchNames) {
        let searchFields = this.visibleFields_ToSearchNames.split(",");
        let searchFieldValues = [];
        for (let searchField of searchFields) {
          if (record[searchField]) {
            searchFieldValues.push(record[searchField]);
          }
        }
        searchValue = searchFieldValues.join("");
      }

      return {
        label: record[labelField],
        value: record.Id,
        sublabel: sublabel,
        icon: this.iconName,
        searchValue: searchValue
      };
    });
  }

  resetRecentlyViewed() {
    this.records = this.recentlyViewedRecords.map((rec) =>
      Object.assign({}, rec)
    );
    this.addNewRecordAction();
  }

  addNewRecordAction() {
    if (this.showNewRecordAction) {
      // Check to see if the ACTION.NEW_RECORD is already in the list
      let newRecordAction = this.records.find(
        (record) => record.value === ACTIONS.NEW_RECORD.value
      );
      if (!newRecordAction) {
        // Check if the user has create access
        if (!this.canCreateRecord) {
          // Add the new record action to the top of the list
          this.records.unshift(ACTIONS.NEW_RECORD);
        }
      }
    }
  }

  // Parse the nested relationship fields
  // Define the nested keys for the relationship and extract the corresponding values
  parseRelationshipFields(fieldName, record) {
    // Split the fieldName into individual relationship and field parts
    let relationshipFields = fieldName.split(".");

    // Extract the relationship and field names
    let relationshipName = relationshipFields[0]; // CustomObject__r
    let fieldChain = relationshipFields.slice(1); // ["Name"]

    // Navigate through the nested relationships
    let fieldValue = record[relationshipName]; // Get the initial relationship object

    for (const field of fieldChain) {
      if (fieldValue && fieldValue[field]) {
        fieldValue = fieldValue[field];
      } else {
        // Handle cases where the nested relationship or field does not exist
        fieldValue = null;
        break;
      }
    }

    return fieldValue;
  }

  // Method to handle combobox selection changes
  handleComboboxChange(event) {
    this.value = event.detail.value;
    this._selectedRecordIdOutput = event.detail.value;
    this._numberOfRecordsOutput = event.detail.value ? 1 : 0;
    this._selectedRecordIdsOutput = null;
    let detail = {
      value: this.value,
      selectedRecord: this.selectedRecord
    };

    if (this.identifier) {
      const uid = this.getUrlParameter("uid");
      const sessionKey = uid
        ? `LOOKUP-${uid}-${this.identifier}`
        : `LOOKUP-${this.getCharacterHash(window.location.href)}-${
            this.identifier
          }`;
      sessionStorage.setItem(sessionKey, this._selectedRecordIdOutput);
    }

    this.dispatchEvent(new CustomEvent("recordchange", { detail: detail }));
    this.handleEventChanges(
      "selectedRecordIdOutput",
      this._selectedRecordIdOutput
    );
    this.handleEventChanges(
      "numberOfRecordsOutput",
      this._numberOfRecordsOutput
    );
  }

  // Method to handle the custom "New Record" action
  handleCustomAction(event) {
    if (event.detail === ACTIONS.NEW_RECORD.value) {
      const logger = this.template.querySelector("c-logger");

      // Call the new record modal
      newRecordModal
        .open({
          size: "large",
          description: "Create a new " + this.objectName,
          objectApiName: this.objectName,
          modalTitle: "New " + this.objectName
        })
        .then((result) => {
          // If the modal is closed with success, then get the record details and set the selectedRecordIdOutput
          if (result.status === "success") {
            // Set the selectedRecordIdOutput
            this.value = result.id;
            this._selectedRecordIdOutput = result.id;
            this._numberOfRecordsOutput = 1;

            let detail = {
              value: this.value,
              selectedRecord: this.selectedRecord
            };
            this.dispatchEvent(
              new CustomEvent("recordchange", { detail: detail })
            );
            this.handleEventChanges(
              "selectedRecordIdOutput",
              this._selectedRecordIdOutput
            );
            this.handleEventChanges(
              "numberOfRecordsOutput",
              this._numberOfRecordsOutput
            );
          }
        })
        .catch((error) => {
          if (logger) {
            logger.error(
              "Exception caught in method newRecordModal in LWC flowLookup: ",
              JSON.stringify(error)
            );
            logger.saveLog();
          }
        });
    }
  }

  // Method to dispatch attribute change events to the flow
  handleEventChanges(apiName, value) {
    const attributeChangeEvent = new FlowAttributeChangeEvent(apiName, value);
    this.dispatchEvent(attributeChangeEvent);
  }
}
