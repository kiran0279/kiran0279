public class ScheduleClassForApexClass implements Schedulable
{
    public void Execute (SchedulableContext sche)
    {
        UpdatingAccountNameAsContactName b = new UpdatingAccountNameAsContactName(); 
        database.executebatch(b);
    }
  
}