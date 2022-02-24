/**
    * Trigger to handle operations on AccountTeamMember object
    * ===============================================================
    * Version | Date | Author 
    * -------------------------------------------------------------------
    * 1.0 | 22/12/2020 | sujata.chaudhari@weare4c.com
    * Modified By: Bhupesh Kumar to add the validation logic of add/remove member for credit manager profile.
    */
trigger AccountTeamMemberTrigger on AccountTeamMember(before insert, before update, before delete, after insert, after delete){
    /* Before Insert */
    if(Trigger.isInsert && Trigger.isBefore){
        AccountTeamMemberTriggerHandler.OnBeforeInsert(Trigger.new);
    }
    /* After Insert */
    else if(Trigger.isAfter && Trigger.isInsert){
        AccountTeamMemberTriggerHandler.afterInsert(Trigger.new);
    }  
    /* Before Update */
    else if(Trigger.isUpdate && Trigger.isBefore){
        AccountTeamMemberTriggerHandler.OnBeforeUpdate(Trigger.new);
    }
    /* Before Delete */
    else if(Trigger.isDelete && Trigger.isBefore){
        AccountTeamMemberTriggerHandler.OnBeforeDelete(Trigger.old);
    }
    /* After Delete */
    else if(Trigger.isAfter && Trigger.isdelete) {
        AccountTeamMemberTriggerHandler.afterDelete(Trigger.old);
    }   
}