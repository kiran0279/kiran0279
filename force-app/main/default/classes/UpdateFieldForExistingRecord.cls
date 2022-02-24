global class UpdateFieldForExistingRecord implements Database.Batchable<sObject> {

global Database.QueryLocator start(Database.BatchableContext BC) {

String query = 'SELECT Id, ProcessInstanceId, OriginalActorId, ActorId, ProcessInstance.ProcessDefinitionId FROM ProcessInstanceWorkitem where ProcessInstance.ProcessDefinitionId = \'04a3N0000009QiWQAU\'';
system.debug('query>>' + query);
return Database.getQueryLocator(query);

}

 

global void execute(Database.BatchableContext BC, List<ProcessInstanceWorkitem> scope) {

for(ProcessInstanceWorkitem a : scope)

{

a.ActorId = '00G3N000003RibV';

}

update scope;

}

global void finish(Database.BatchableContext BC) {

}

}