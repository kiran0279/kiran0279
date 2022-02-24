/**
* @Class Name: ContractAgreementTrigger
* @Description: Used for ContractAgreementTriggerHandler as a Trigger.
* ================================================================================================================
* Version | Date | Author | Comments
* -----------------------------------------------------------------------------------------------------------------
* 1.0 | 19th Aug, 2021 | sujata.chaudhari@weare4c.com | 1. This class is used as Trigger for ContractAgreementTriggerHandler.
* =================================================================================================================
*/
trigger ContractAgreementTrigger on APXT_Redlining__Contract_Agreement__c (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        Set<Id> targetIdSet = new Set<Id>();
        for (APXT_Redlining__Contract_Agreement__c ca : (List<APXT_Redlining__Contract_Agreement__c>)Trigger.new) {
            if (
                ca.Is_Submitted_for_Approval__c == true &&
                ca.Is_Submitted_for_Approval__c != ((APXT_Redlining__Contract_Agreement__c)Trigger.oldMap.get(ca.Id)).Is_Submitted_for_Approval__c &&
                ca.Aramex_Contracting_Entity__c != null
            ) {
                targetIdSet.add(ca.Id);
            }            
        }
        ContractAgreementTriggerHandler.setApprovalOwnertoQueue(targetIdSet);
    }
}