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

    if(fieldValue[key].constructor === Object){//added recursive method to cater more levels of look up fields
      transformObject(fieldValue[key],finalSobjectRow,finalKey);
    }
  });
};


export { isValidUrl, transformObject };