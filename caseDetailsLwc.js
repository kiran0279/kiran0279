/* *@author        Saikiran Chintakayala        <saikiran.chintakayala@raagvitech.com>
* @modifiedBy     Saikiran Chintakayala        <saikiran.chintakayala@raagvitech.com>
* @maintainedBy   Saikiran Chintakayala        <saikiran.chintakayala@raagvitech.com>
* @version        52.0
* @created        2021-12-10
* @modified      
* @systemLayer     Apex Class
*/ 
import { LightningElement } from 'lwc';
import saveCaseDetails from'@salesforce/apex/CaseDetails.saveCaseDetails';
import sendMails from'@salesforce/apex/CaseDetails.sendMails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class CaseDetailsLwc extends LightningElement {
Name = '';
Email = '';
Phone = '';
Subject = '';
Description = '';

    getDetails(event)
    {
        console.log(event.target.label);
        console.log(event.target.value);

        if(event.target.label == 'Name')
        {
            this.Name = event.target.value;
        }
        if(event.target.label == 'Email')
        {
            this.Email = event.target.value;
        }
        if(event.target.label == 'Phone')
        {
            this.Phone = event.target.value;
        }
        if(event.target.label == 'Subject')
        {
            this.Subject = event.target.value; 
        }
        if(event.target.label == 'Description')
        {
             this.Description = event.target.value; 
        }
    }

    submitDetails(event)
    {
        var values = {};
        values.Name = this.Name;
        values.Email = this.Email;
        values.Phone = this.Phone;
        values.Subject = this.Subject;
        values.Description = this.Description;
        values.SobjectType = 'Case';
        console.log(values);

        saveCaseDetails({CaseDetails : values })
                    .then(() => {
                        console.log("the values 000000-------",values);
                        this.dispatchEvent(
                        new ShowToastEvent({
                        title: 'Success',
                        message: 'we got your meassge..! we will get back to you',
                        variant: 'success',
                        }),
                    );
                    [...this.template
                        .querySelectorAll('lightning-input, lightning-textarea')]
                        .forEach((input) => { input.value = ''; });
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: error.message,
                            variant: 'error',
                           
                            
                        }),                    

                    );console.log(error);
                });
                
  
            sendMails({NAME : this.Name, EMAIL : this.Email, PHONE : this.phone, SUBJECT : this.Subject, DESCRIPTION : this.Description})
            .then(result => {
                console.log('result  ',result);    
        
            })
            .catch(error => {
                console.log(error);
                this.error = error;
                this.contacts = undefined;
            });

  }
}