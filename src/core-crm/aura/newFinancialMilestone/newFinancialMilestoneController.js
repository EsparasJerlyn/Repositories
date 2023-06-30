/**
 * @description A aura component to hold the Create New Milestone Flow
 *
 * @see ..
 * @see flowContainer
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
      |---------------------------|-----------------------|----------------------|----------------------------------------------|
      | kenneth.f.alsay           | June 27, 2023         | DEPP-5960            | Created file                                 |
*/
({
	init: function (component) {
		var pageRef = component.get("v.pageReference");
		var state = pageRef.state.ws; //ex. lightning/r/Opportunity/00xxxxxxxxxxxxxxx/view
		var recordId = state.split('/')[4];
		console.log('recordId ' + state);
		const inputVariables =[
		  {
			name : "opportunityOutcomeId",
			type : "String",
			value : recordId ? recordId : '' 
		  },
          {
			name : "milestoneType",
			type : "String",
			value : 'Financial'
		  }
		];
		component.set("v.inputVariables", inputVariables);	
		
		if (inputVariables && inputVariables.length > 0) {
			component.set("v.hasRecord", true);	
		}
	}
})