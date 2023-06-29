/**
 * @description A aura component to hold the Document related list for Engagement
 *
 * @see ..
 * @see flowContainer
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
      |---------------------------|-----------------------|----------------------|----------------------------------------------|
      | marygrace.li              | June 7, 2023          | DEPP-5392            | Created file                                 |
*/
({
	init: function (component) {
		var pageRef = component.get("v.pageReference");
		var state = pageRef.state.ws; //ex. lightning/r/Engagement__c/00xxxxxxxxxxxxxxx/view
		var recordId = state.split('/')[4];
		
		const inputVariables =[
		  {
			name : "engagementId",
			type : "String",
			value : recordId ? recordId : '' 
		  }
		];
		component.set("v.inputVariables", inputVariables);	
		
		if (inputVariables && inputVariables.length > 0) {
			component.set("v.hasRecord", true);	
		}
	}
})