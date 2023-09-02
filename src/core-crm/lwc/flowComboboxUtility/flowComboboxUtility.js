/**
 * @description An LWC for constant and utility methods for combobox
 * @see ../lwc/flowCombobox
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
 *    |---------------------------|-----------------------|----------------------|----------------------------------------------|
 *    | ryan.j.a.dela.cruz        | June 5, 2023          | DEPP-5385            | Created file                                 |
 *    | ryan.j.a.dela.cruz        | August 17, 2023       | DEPP-6165            | Added code documentation                     |
 */

// Define key constants for various keyboard keys
const KEYS = {
  ESCAPE: "Escape",
  UP: "ArrowUp",
  DOWN: "ArrowDown",
  ENTER: "Enter"
};

/**
 * Convert input values to an array.
 * @param {any[] | any} values - Input values to be converted.
 * @returns {any[]} - An array containing the input values.
 */
const setValuesFromMultipleInput = (values) => {
  if (!values) {
    return [];
  } else {
    // If values is an array, spread its elements into a new array; if not, create an array with the single value.
    return Array.isArray(values) ? [...values] : [values];
  }
};

/**
 * Convert input value to an array based on multi-select flag and delimiter.
 * @param {string} value - Input value to be converted.
 * @param {string} delimiter - Delimiter used to split the input value.
 * @param {boolean} isMultiSelect - Flag indicating whether multi-select is enabled.
 * @returns {string[]} - An array containing the split values.
 */
const setValuesFromSingularInput = (value, delimiter, isMultiSelect) => {
  if (!value) {
    return [];
  } else {
    // If multi-select is enabled, split the value using the specified delimiter and trim each part.
    // Otherwise, create an array with the single value.
    return isMultiSelect
      ? value.split(delimiter).map((val) => val.trim())
      : [value];
  }
};

/**
 * Check if a value (or values in an array) contains another value (case-insensitive).
 * @param {string | string[]} valueToSearch - Value or values to be searched.
 * @param {string} valueToSearchFor - Value to search for.
 * @returns {boolean} - true if the search value is found, false otherwise.
 */
const includesIgnoreCase = (valueToSearch, valueToSearchFor) => {
  if (Array.isArray(valueToSearch)) {
    // Convert array values to lowercase and check if the search value is included.
    return valueToSearch
      .map((arrayValue) => arrayValue.toLowerCase())
      .includes(valueToSearchFor.toLowerCase());
  } else {
    // Convert single value to lowercase and check if the search value is included.
    return valueToSearch.toLowerCase().includes(valueToSearchFor.toLowerCase());
  }
};

// Export the defined constants and functions
export {
  KEYS,
  setValuesFromMultipleInput,
  setValuesFromSingularInput,
  includesIgnoreCase
};
