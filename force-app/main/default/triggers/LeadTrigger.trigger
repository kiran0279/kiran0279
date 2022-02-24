trigger LeadTrigger on Lead ( after update ) {
    LeadHandler handler = new LeadHandler(); 
    if (Trigger.isInsert) {
        if (Trigger.isAfter) {
            handler.LeadConverter(trigger.new);
        }       
    }    
   
}