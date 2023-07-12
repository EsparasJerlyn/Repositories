/**
 * @description Aura component controller for linkIpManagement
 * @author Accenture
 * @history
 * | Developer         | Date          | JIRA
 * | alexander.cadalin | July 06, 2023 | DEPP-5378
 */
({
    init: function (component) {
        var pageRef = component.get("v.pageReference");
        var state = pageRef.state.ws;
        var sobjectType = state.split('/')[3];
        var recordId = state.split('/')[4];
        const inputVariables = [
            {
                name : "srcId",
                type : "String",
                value : recordId ? recordId : ''
            },
            {
                name : "srcSobjectType",
                type : "String",
                value : sobjectType ? sobjectType : ''
            }
        ];
        component.set("v.inputVariables", inputVariables);
        if(inputVariables && inputVariables.length > 0) {
            component.set("v.hasRecord", true);
        }
    }
})