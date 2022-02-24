public with sharing class submitForApproval {
    public pagereference reassign(Lead lead){

        String uae = '';
        String uk = '';
        String us =  '';
        
       List<Group> user =[SELECT ID, Name FROM GROUP WHERE Name LIKE 'U%'];
       System.debug('List of Ids'+user);
       for(Group gr: user)
       {
           if(gr.Name == 'UAE')
           {
               uae = gr.Id;
           }
           else if(gr.Name == 'UK')
           {
               uk = gr.Id;
           }
           else if(gr.Name == 'US')
           {
               us = gr.Id;
           }
       }

        List<ProcessInstanceWorkItem> workItemList = [Select p.ProcessInstance.Status, 
                                                     p.ProcessInstance.TargetObjectId,
                                                     p.ProcessInstanceId,
                                                     p.OriginalActorId,
                                                     p.Id,p.ActorId
                									From ProcessInstanceWorkitem p 
                                                      where p.ProcessInstance.TargetObjectId = :  lead.Id];
            for(integer i = 0 ; i < workItemList.size() ; i++)
            {
                if( lead.Country__c != null && lead.Country__c == 'UAE')
                {
                    workItemList.get(i).ActorId  = uae;
                }
                else if( lead.Country__c != null && lead.Country__c == 'UK')
                {
                    workItemList.get(i).ActorId  = uk;
                }
                else if( lead.Country__c != null && lead.Country__c == 'US')
                {
                    workItemList.get(i).ActorId  = us;
                }   
            }   
        update workItemList;
        return null; 
        }
}