/**
* @Class Name: TaskHandler
* @Description: Used for TaskUpdateLead Trigger as handler Class.
* ================================================================================================================
* Version | Date | Author | Comments
* -----------------------------------------------------------------------------------------------------------------
* 1.0 | 27th Dec, 2020 | shubhangi.gadpale@weare4c.com | 1. This class is used as handler for TaskUpdateLead Trigger.
* =================================================================================================================
*/
public class TaskHandler {
    public static void afterInsert(List<Task> tasks){
        TaskUpdateLead(tasks);
    }
    public static void afterDelete(List<Task> tasks){
        TaskUpdateLead(tasks);
    }
    public static void afterUnDelete(List<Task> tasks){
        TaskUpdateLead(tasks);
    }
    /*
    * Get the List of Task to update count of tasks that are realted to lead
    * @param List<Task> : Selected List of Task.
    * @return Void
    */ 
    public static void TaskUpdateLead(List<Task> tasks){
        Set<ID> LeadIds = new Set<ID>();
        /*
        * We only care about tasks linked to Leads.
        */
        String leadPrefix = Lead.SObjectType.getDescribe().getKeyPrefix();
        /*
        * Add any Lead ids coming from the new data
        */
        if(!tasks.isEmpty()){
            for (Task t : tasks){
                if (t.WhoId!= null && string.valueof(t.WhoId).startsWith(leadPrefix)){
                    if(!LeadIds.contains(t.WhoId)){
                        /*
                        * adding unique lead ids since there can be many tasks with single lead
                        */
                        LeadIds.add(t.WhoId);
                    }
                }
            }
        }
        if (!LeadIds.isEmpty()){
        List<Lead> leadsWithTasks = [select id,Number_of_Call_Attempts_Made__c ,(select id,Call_Response__c from Tasks where Call_Response__c = 'Un Answered') from Lead where Id IN : Leadids];
        List<Lead> leadsUpdatable = new List<Lead>();
            for(Lead L : leadsWithTasks){
            L.Number_of_Call_Attempts_Made__c = L.Tasks.size();
            leadsUpdatable.add(L);
            }
            if(leadsUpdatable.size()>0){
            update leadsUpdatable;
            /* 
            * update all the leads with activity count
            */
            }
        }
    }
}