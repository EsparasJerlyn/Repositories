let urlString = window.location.href,
    url = urlString.substring(
        0,
        urlString.indexOf("s/"));

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
const truncateText = (str, length) => {
    return str.substring(0, length);
}

/**
* @description email format validations
*/
const isValidEmail = (email) => {

    let regExpEmailformat = /[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\.)+[a-zA-Z0-9]{2,}(?:[a-zA-Z0-9-]*[a-zA-Z0-9])?/g;
    let isValid = false;

    if (email){
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

/**
* @description birthdate validation
*/
const birthdateValidation = (input) => {

    let result = true;

    let dobInput = new Date(input);
    let dobDate = dobInput.getDate();
    let dobMonth = dobInput.getMonth();
    let dobYear = dobInput.getFullYear();
    let dob = new Date(dobYear, dobMonth, dobDate);

    let today = new Date(Date.now());
    let fifteenYearsBackDate = today.getDate();
    let fifteenYearsBackMonth = today.getMonth();
    let fifteenYearsBackYear = today.getFullYear() - 15;
    let fifteenYearsBack = new Date(fifteenYearsBackYear, fifteenYearsBackMonth, fifteenYearsBackDate);

    if(dob > fifteenYearsBack){
        result = false;
    }

    return result;
}


/**
* @description numeric field validation
*/
const preventNonNumbersInInput = (event) => {

    let isNumeric;

    var characters = String.fromCharCode(event.which);
    if((!/^[0-9]*$/.test(characters))){
        isNumeric = false;
    }else{
        isNumeric = true;
    }
    return isNumeric;
  }
  

/**
* @description numeric field validation for onpaste event
*/
const checkPasteIfNumeric = (event) => {

  let isNumeric;

  var clipboardData = event.clipboardData || window.clipboardData;
  var characters = clipboardData.getData('text');

  if((!/^[0-9]+$/.test(characters))){
    isNumeric = false;
  }else{
    isNumeric = true;
  }
  return isNumeric;
}

const baseURL = `${url}s`;

export default{
    htmlDecode,
    truncateText,
    isValidEmail,
    generateErrorMessage,
    birthdateValidation,
    checkPasteIfNumeric,
    preventNonNumbersInInput,
    baseURL
   
}