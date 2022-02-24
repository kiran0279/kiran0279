/**
    * Trigger to handle operations on OpportunityTeamMember object
    * ===============================================================
    * Version | Date | Author 
    * -------------------------------------------------------------------
    * 1.0 | 22/12/2020 | sujata.chaudhari@weare4c.com
    */
    trigger OpportunityTeamMemberTrigger on OpportunityTeamMember(after insert,after delete){
        if(Trigger.isAfter && Trigger.isInsert){
            OpportunityTeamMemberTriggerHandler.afterInsert(Trigger.new);
        }  
        else if(Trigger.isAfter && Trigger.isdelete){
            OpportunityTeamMemberTriggerHandler.afterDelete(Trigger.old);
        }
    }