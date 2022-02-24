/**
* ───────────────────────────────────────────────────────────────────────────────────────────────────┐
	* @author         Saikiran Chintakayala   <saikiran.chintakayala@raaagvitech.com>
    * @modifiedBy     Saikiran Chintakayala   <saikiran.chintakayala@raaagvitech.com>
    * @maintainedBy   Saikiran Chintakayala   <saikiran.chintakayala@raaagvitech.com>
    * @version        53.0
    * @created        2021-12-02
    * @modified      
    * @systemLayer    Batch  Class
    *  **/
public class ScheduleClassForEmailWithNames implements Schedulable
{
    
    /**
    * @description Execute  Method to Execute the EmailWithNames Batch Apex Class
    * ───────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    EmailWithNames
    * @param    Executes the Batch Apex Class In Schedule Class
    * @param    Contact Object
    * ───────────────────────────────────────────────────────────────────────────────────────────────────┘ 
    *  **/
	public void execute(SchedulableContext sc)
    {
        EmailWithNames ewn = new EmailWithNames();
        database.executebatch(ewn);
    }
}