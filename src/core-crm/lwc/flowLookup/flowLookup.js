/**
 * @description An LWC which contains logic for the flow custom lookup component
 * @see ../classes/FlowLookupController
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
 *    |---------------------------|-----------------------|----------------------|----------------------------------------------|
 *    | ryan.j.a.dela.cruz        | June 5, 2023          | DEPP-5385            | Created file                                 |
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
    this._fieldsToSearch = value;
    this.visibleFields_ToSearchNames = JSON.parse(value)
      .map((field) => field.name)
      .join();
    this.fieldCollection_toSearch = JSON.parse(value).map(
      (field) => field.name
    );
  }

  @track _fieldsToSearch;
  @api visibleFields_ToSearchNames;
  @api fieldCollection_toSearch = [];

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
  @api excludeSublabelInFilter = false; // If true, the 'sublabel' text of an option is included when determining if an option is a match for a given search text.
  @api includeValueInFilter = false; // If true, the 'value' text of an option is not included when determining if an option is a match for a given search text.
  @api orderByClause; // Reserved for future use
  @api disabled = false;
  @api _defaultValueInput;

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

  @api
  get defaultValueInput() {
    return this._defaultValueInput;
  }

  @api
  get selectedRecordOutput() {
    return this._selectedRecordOutput;
  }

  set selectedRecordOutput(value) {
    this._selectedRecordOutput = value;
    this.handleEventChanges("selectedRecordOutput", value);
  }

  set defaultValueInput(value) {
    this._defaultValueInput = value;
    this.selectedRecordIdOutput = value;
    this.selectedRecordIdOutput = value;
    // Set numberOfRecordsOutput if value is set
    value ? (this.numberOfRecordsOutput = 1) : (this.numberOfRecordsOutput = 0);
    this.handleEventChanges("defaultValueInput", value);
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
            this.addNewRecordAction();
          })
          .catch((error) => {
            if (logger) {
              logger.error(
                "flowLookup [getRecordsFromIds method]: ",
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
    });
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
            "flowLookup [getRecentlyViewed method]: ",
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
            "flowLookup [getRecords method]: ",
            JSON.stringify(error)
          );
          logger.saveLog();
        }
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  handleSearchChange = (searchText) => {
    if (!searchText) {
      this.resetRecentlyViewed();
    } else {
      this.isLoading = true;
      const logger = this.template.querySelector("c-logger");

      search({
        searchTerm: searchText,
        objectName: this.objectName,
        fieldsToSearch:
          this.visibleFields_ToSearchNames ||
          (this.excludeSublabelInFilter
            ? null
            : this.visibleFields_ToDisplayNames),
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
            logger.error("flowLookup [search method]: ", JSON.stringify(error));
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
        const logger = this.template.querySelector("c-logger");

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

  // Parse the relationship fields
  // Define the key fields for the relationship and remove them from the list of fields to return
  parseRelationshipFields(fieldName, record) {
    // fieldName is set like this Account.CreatedBy.FirstName
    let relationshipFields = fieldName.split(".");
    let relationshipField = relationshipFields[1];
    let field = relationshipFields[2];
    // Value is set like this "CreatedBy":{"FirstName":"Ryan","Id":"0055e000001mKpCAAU"}
    // Set new object
    let relationshipObject = record[relationshipField];
    // "CreatedBy.FirstName":"Ryan"
    let keyFieldValue = relationshipObject[field];

    return keyFieldValue;
  }

  handleComboboxChange(event) {
    this.value = event.detail.value;
    this._selectedRecordIdOutput = event.detail.value;
    this._numberOfRecordsOutput = event.detail.value ? 1 : 0;
    this._selectedRecordIdsOutput = null;
    let detail = {
      value: this.value,
      selectedRecord: this.selectedRecord
    };

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
              "flowLookup [newRecordModal method]: ",
              JSON.stringify(error)
            );
            logger.saveLog();
          }
        });
    }
  }

  handleEventChanges(apiName, value) {
    const attributeChangeEvent = new FlowAttributeChangeEvent(apiName, value);
    this.dispatchEvent(attributeChangeEvent);
  }
}
