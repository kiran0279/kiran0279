/**
    * Trigger to handle operations on Opportunity object
    * ===============================================================
    * Version | Date | Author 
    * -------------------------------------------------------------------
    * 1.0 | 22/12/2020 | sujata.chaudhari@weare4c.com
    */
    trigger OpportunityTrigger on Opportunity(after update, after delete, before Update, before Delete){
        if(Trigger.isBefore && Trigger.isUpdate){
            OpportunityTriggerHandler.beforeUpdate(Trigger.old, Trigger.newMap);
        }
        else if(Trigger.isBefore &&  Trigger.isdelete){
            OpportunityTriggerHandler.beforeDelete(Trigger.old, Trigger.oldMap);
        }
        else if(Trigger.isAfter && Trigger.isUpdate){
            OpportunityTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }  
        else if(Trigger.isAfter && Trigger.isdelete){
            OpportunityTriggerHandler.afterDelete(Trigger.old, Trigger.oldMap);
        }
    }