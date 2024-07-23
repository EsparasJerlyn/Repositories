/**
 * @description An LWC utility methods
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
 *    |---------------------------|-----------------------|----------------------|----------------------------------------------|
 *    | roy.nino.s.regala         | June 15, 2023         | DEPP-5391            | Created file                                 |
 *    | roy.nino.s.regala         | Aug 25, 2023          | DEPP-6348            | added recursion to flatten all lookup fields |
 *    | ryan.j.a.dela.cruz        | January 22, 2023      | DEPP-6950            | Added reduce errors method for LDS           |
 */

const isValidUrl = (urlString) => {
  try {
    let url;
    url = new URL(urlString);
  } catch (_) {
    return false;
  }
  return true;
};

const transformObject = (fieldValue, finalSobjectRow, fieldName) => {
  let rowIndexes = Object.keys(fieldValue);
  rowIndexes.forEach((key) => {
    let finalKey = fieldName + "." + key;

    finalSobjectRow[finalKey] = fieldValue[key];
    if (key == "Id") {
      finalSobjectRow[finalKey + "Url"] = "/" + fieldValue[key];
    } else if (isValidUrl(fieldValue[key])) {
      finalSobjectRow[finalKey + "Url"] = fieldValue[key];
    }

    if (fieldValue[key].constructor === Object) {
      //added recursive method to cater more levels of look up fields
      transformObject(fieldValue[key], finalSobjectRow, finalKey);
    }
  });
};

/**
 * Reduces one or more LDS errors into a string[] of error messages.
 * @param {FetchResponse|FetchResponse[]} errors
 * @return {String[]} Error messages
 */
const reduceErrors = (errors) => {
  if (!Array.isArray(errors)) {
    errors = [errors];
  }

  return (
    errors
      // Remove null/undefined items
      .filter((error) => !!error)
      // Extract an error message
      .map((error) => {
        // Check if the error detail is available
        if (error?.detail) {
          const detail = error.detail;

          // Check if output contains field errors
          if (
            detail.output &&
            detail.output.fieldErrors &&
            Object.keys(detail.output.fieldErrors).length > 0
          ) {
            const fieldNames = Object.keys(detail.output.fieldErrors);
            const errorMessage = `Review the following fields: ${fieldNames.join(
              ", "
            )}`;
            return errorMessage;
          }
          // Check if the detail has a message
          else if (detail.message) {
            return detail.message;
          }
        }
        // UI API read errors
        else if (Array.isArray(error.body)) {
          return error.body.map((e) => e.message);
        }
        // Page level errors
        else if (error?.body?.pageErrors && error.body.pageErrors.length > 0) {
          return error.body.pageErrors.map((e) => e.message);
        }
        // Field level errors
        else if (
          error?.body?.fieldErrors &&
          Object.keys(error.body.fieldErrors).length > 0
        ) {
          const fieldErrors = [];
          Object.values(error.body.fieldErrors).forEach((errorArray) => {
            fieldErrors.push(...errorArray.map((e) => e.message));
          });
          return fieldErrors;
        }
        // UI API DML page level errors
        else if (
          error?.body?.output?.errors &&
          error.body.output.errors.length > 0
        ) {
          return error.body.output.errors.map((e) => e.message);
        }
        // UI API DML field level errors
        else if (
          error?.body?.output?.fieldErrors &&
          Object.keys(error.body.output.fieldErrors).length > 0
        ) {
          const fieldErrors = [];
          Object.values(error.body.output.fieldErrors).forEach((errorArray) => {
            fieldErrors.push(...errorArray.map((e) => e.message));
          });
          return fieldErrors;
        }
        // UI API DML, Apex and network errors
        else if (error.body && typeof error.body.message === "string") {
          return error.body.message;
        }
        // JS errors
        else if (typeof error.message === "string") {
          return error.message;
        }
        // Unknown error shape so try HTTP status text
        return error.statusText;
      })
      // Flatten
      .reduce((prev, curr) => prev.concat(curr), [])
      // Remove empty strings
      .filter((message) => !!message)
  );
};

export { isValidUrl, transformObject, reduceErrors };
