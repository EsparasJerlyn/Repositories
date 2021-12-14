let urlString = window.location.href;
let url = urlString.substring(0, urlString.indexOf("s/"));


/**
* @description html decode
*/
const htmlDecode = (input) => {
    if(input == null || input == undefined) {
        return '';
    } else {
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent;
    }
}

/**
* @description truncate text
*/
const truncateText = (str, length, ending) => {
    if (length == null) length = 100;
    if (ending == null) ending = '...';

    if (str.length > length)
        return str.substring(0, length - ending.length) + ending;
    else
        return str;
}

/**
* @description email format validations
*/
const isValidEmail = (email) => {
  
    let regExpEmailformat = /[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\.)+[a-zA-Z0-9]{2,}(?:[a-zA-Z0-9-]*[a-zA-Z0-9])?/g;
    let isValid = false;

    if (email) {
        if (email.match(regExpEmailformat)) {
           isValid = true;
        } else {
            isValid = false;
           
        }
    }
    return isValid;
}

/**
* @description concatenates error name and message
*/
 const generateErrorMessage = (err) =>{

    let _errorMsg = ' (';
    _errorMsg += err.name && err.message ? err.name + ': ' + err.message : err.body.message;
    _errorMsg += ')';
    
    return _errorMsg;

}


const baseURL = `${url}s`;

export default {
    htmlDecode,
    truncateText,
    isValidEmail,
    generateErrorMessage,
    baseURL
   
}