trigger ContactTrigger on Contact (before insert) {
    ContactHandler handler = new ContactHandler(); 
    if (Trigger.isInsert) {
        if (Trigger.isBefore) {
            handler.preventDuplicate(trigger.new);
        }       
    }    

}