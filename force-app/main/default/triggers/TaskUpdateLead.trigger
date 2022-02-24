/**
* Trigger to handle operations on Task object
*  ===============================================================
* Version | Date | Author 
* -------------------------------------------------------------------
* 1.0 | 22/12/2020 | shubhangi.gadpale@weare4c.com
*/
trigger TaskUpdateLead on Task (after insert, after delete, after undelete) { 
    if (trigger.isAfter ){
		if( trigger.isInsert) 
		{
			TaskHandler.afterInsert(trigger.new);
		}
        else if(trigger.isDelete )
        {
 		   TaskHandler.afterDelete(trigger.old);           
        }
        else if(trigger.isUndelete){
            TaskHandler.afterUnDelete(trigger.new);
        }
	}	
}