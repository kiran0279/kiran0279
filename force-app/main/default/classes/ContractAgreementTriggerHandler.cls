/**
* @Class Name: ContractAgreementTriggerHandler
* @Description: Used for ContractAgreementTrigger as handler Class.
* ================================================================================================================
* Version | Date | Author | Comments
* -----------------------------------------------------------------------------------------------------------------
* 1.0 | 19th Aug, 2021 | sujata.chaudhari@weare4c.com | 1. This class is used as handler for ContractAgreementTrigger.
* =================================================================================================================
*/
public with sharing class ContractAgreementTriggerHandler {
    @future
    public static void setApprovalOwnertoQueue(Set<Id> targetIdSet){
        
        List<APXT_Redlining__Contract_Agreement__c> caList = [SELECT Id,Is_Submitted_for_Approval__c,Aramex_Contracting_Entity__c FROM APXT_Redlining__Contract_Agreement__c WHERE Id IN :targetIdSet];
        Map<String, Id> groupNameSet = new Map<String, Id>();
        List<Group> groupList = [SELECT Id, DeveloperName, Name FROM Group WHERE Type = 'Queue' AND Name like '%Credit Team - %'];
        for (Group groupName : groupList) {
            groupNameSet.put(groupName.Name.split(' - ')[1], groupName.Id);
        }

        List<ProcessInstanceWorkItem> processInstanceWorkItems = [SELECT Id, ActorId, ProcessInstance.ProcessDefinition.DeveloperName,ProcessInstance.TargetObjectId, processInstance.Status  from ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId IN :targetIdSet];

        for(APXT_Redlining__Contract_Agreement__c conAgreement : caList){
            for (ProcessInstanceWorkItem pIWI : processInstanceWorkItems) {
                if (
                    pIWI.ProcessInstance.TargetObjectId == conAgreement.Id &&
                    groupNameSet.get(conAgreement.Aramex_Contracting_Entity__c) != null
                ) {
                    pIWI.ActorId = groupNameSet.get(conAgreement.Aramex_Contracting_Entity__c);
                }
                else{
                    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                    req.setComments('Approving request using Trigger');
                    req.setAction('Approve');
                    req.setWorkitemId(pIWI.Id);
                    // Submit the request for approval
                    Approval.ProcessResult result =  Approval.process(req);
                }
            }
        }

        try {
            update processInstanceWorkItems;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
}