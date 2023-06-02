({
  init: function (component, event) {
    // Find the component whose aura:id is "flowData"
    var flow = component.find("flowData");
    var isList = false;
    var object;
    var recordId;
    var opportunityRecordId;
    var engagementRecordId;
    var opportunityOutcomeRecordId;

    //List page
    if (window.location.href.indexOf("list") > -1) {
      isList = true;
      object = window.location.pathname.split("/")[3]; //ex.lightning/o/Opportunity/list'
   
    //view  page 
    }else{
      var pageRef = component.get("v.pageReference");
      var state = pageRef.state.ws; //ex. lightning/r/Opportunity/0069t000005J1drAAC/view
      var obj = state.split('/')[3]; 
      recordId = state.split('/')[4];
     
      if(obj === "Opportunity"){
        opportunityRecordId = recordId;
      }else if(obj === "Engagement__c"){
        engagementRecordId = recordId;
      }else if(obj === "Opportunity_Outcome__c"){
        opportunityOutcomeRecordId = recordId;
      }
    }

    var inputVariables =[
      {
        name : "opportunityId",
        type : "String",
        value : opportunityRecordId ? opportunityRecordId : '' 
      },
      {
        name : "engagementId",
        type : "String",
        value : engagementRecordId ?  engagementRecordId : ''
      },
      {
        name : "opportunityOutcomeId",
        type : "String",
        value : opportunityOutcomeRecordId ? opportunityOutcomeRecordId : '' 
      }
    ]

    // In that component, start your flow. Reference the flow's API Name.
    if(isList){
      if(object === "Opportunity"){
        flow.startFlow("New_Opportunity");
      }else if(object === "Engagement__c"){
        flow.startFlow("New_Engagement");
      }
    }else{
      flow.startFlow("Create_Standard_Type_Document", inputVariables);
    }
  },
  handleStatusChange: function (component, event) {
    let outputVariables = event.getParam("outputVariables");
      if (outputVariables && outputVariables.length > 0) {
          let outputVar = outputVariables.find(e => e.name === 'modalTitle');
          if (outputVar) {
              component.set("v.modalTitle", outputVar.value);
          }
      }
    // close workspace tab when flow status is finished
    if(event.getParam("status") === "FINISHED") {
        $A.enqueueAction(component.get("c.closeFocusedTab"));
    }
  },
  closeFocusedTab: function (component) {
    // close workspace tab when close button is clicked
    var workspaceAPI = component.find("workspace");
    workspaceAPI
      .getTabInfo()
      .then(function (response) {
        var focusedTabId = response.tabId;
        workspaceAPI.closeTab({ tabId: focusedTabId });
      })
      .catch(function (error) {
        console.log(error);
      });
  }
});