import { LightningElement,api,track } from 'lwc';
import getContacts from '@salesforce/apex/AccountHelper.getContacts'
import NAME_FIELD from "@salesforce/schema/Contact.Name";
import Email_FIELD from "@salesforce/schema/Contact.Email";
import Mobile_FIELD from "@salesforce/schema/Contact.MobilePhone";
import Phone_FIELD from "@salesforce/schema/Contact.Phone";
import { deleteRecord } from 'lightning/uiRecordApi';
import { updateRecord } from "lightning/uiRecordApi";

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class customTable extends LightningElement {
    @api recordId;
    @track contactList=[];
    renderTable = false;
    @track objectApiName
    @track isEdit=false;
    @track fields;
    isloading;
    NAME;
    Email;
    Mobile;
    Phone
    connectedCallback() {
        console.log('the recif',this.recordId)
        getContacts({ sourceAccount: this.recordId })
            .then(result => {
                this.renderTable = true;
              result.forEach(ele =>{
                   console.log(ele.FirstName)
                this.contactList.push({
                    Id: ele.Id,
                    FirstName: ele.FirstName,
                    LastName:ele.LastName,
                    Email:ele.Email,
                    Phone:ele.Phone,
                    isEdit:false
                     })
                    });
                })
            }
            deleteContact(event) {
                this.isLoading = true;
                deleteRecord(event.currentTarget.dataset.recid)
                    .then(() => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Record Is Deleted',
                                variant: 'success',
                            }),
                        );
                        this.connectedCallback();
                        this.isLoading = false;
                    })
                    .catch(error => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: error.message,
                                variant: 'error',
                            }),
                        );
                        this.connectedCallback();
                        this.isLoading = false;
                    });
                    window.location.reload();
            }
    @track field = false;
    editContact(event)
    {
        var selectedId = event.currentTarget.dataset.recid;
        console.log('4444444444', selectedId);
        let contactId = this.contactList.find(ele=>ele.Id === selectedId);
        console.log('&&&&&&&&&&&' ,JSON.stringify(contactId));
       
        contactId.isEdit = true;
        if(contactId.isEdit = true){
            this.field = true;
        }
        else{
            this.field = false;
        }
        console.log('*********', this.field);
    }
    update(event) {
        // if (event.target.name === "FirstName") {
        
        //   //this is name input textbox
        //   this.fn = event.target.value;
        //   console.log(this.fn);
        // } 
        // if (event.target.name === "LastName") {
        
        //     //this is name input textbox
        //     this.ln = event.target.value;
        //     console.log(this.ln);
        //   } 
        //   if (event.target.name === "Email") {
        
        //     //this is name input textbox
        //     this.email = event.target.value;
        //     console.log(this.email);
        //   } 
        //   if (event.target.name === "Phone") {
        
        //     //this is name input textbox
        //     this.phone = event.target.value;
        //     console.log(this.phone);
        //   } 
        //   if (event.target.name === "mobile") {
        
        //     //this is name input textbox
        //     this.mobile = event.target.value;
        //     console.log(this.mobile);
        //   } 
    }
    saverecord(event) {
        // prevending default type sumbit of record edit form
        event.preventDefault();

        // querying the record edit form and submiting fields to form
        this.template.querySelector('lightning-input').submit(event.detail.fields);

        // closing modal
        this.isEdit = false;

        // showing success message
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success!!',
            message: event.detail.fields.FirstName + ' '+ event.detail.fields.LastName +' Contact updated Successfully!!.',
            variant: 'success'
        }),);

    }
}