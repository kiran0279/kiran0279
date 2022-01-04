trigger LeadTrigger on Lead ( after update) {
    for (Integer i = 0; i < Trigger.new.size(); i++)
        {
         try
         {
    
            if( Trigger.isUpdate || (Trigger.new[i].Status__c == 'Submit' && Trigger.old[i].Status__c != 'Submit'))
            {
               submitForApproval(Trigger.new[i]);
            }
        }
         catch(Exception e)
         {
    
             Trigger.new[i].addError('Can not edit the record while the approval is still pending.');
    
         }
    
    }
    public void submitForApproval(Lead lead) 
    {
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval automatically using Trigger');
        req1.setObjectId(lead.id);
        req1.setNextApproverIds(new Id[] {UserInfo.getUserId()});

        Approval.ProcessResult result = Approval.process(req1);
    }
    // public Id getWorkItemId(Id targetObjectId)

    // {
    //     Id retVal = null;
    //     for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p
    //     where p.ProcessInstance.TargetObjectId =: targetObjectId])
    //     {
    //         retVal  =  workItem.Id;

    //     }
    //     return retVal;

    // }
}