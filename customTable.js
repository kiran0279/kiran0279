import { LightningElement,api,track } from 'lwc';
import getContacts from '@salesforce/apex/AccountHelper.getContacts'
import EditedCon from '@salesforce/apex/AccountHelper.EditedCon'
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class customTable extends LightningElement {
    @api recordId;
    @track contactList=[];
    renderTable = false;
    @track objectApiName
    @track isEdit=false;
        // <<<<< Js Code for Showing the Table >>>>>
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
                    Mobile:ele.Mobile,
                    isEdit:false
                     })
                    });
                })
            }
            //<<<< Js Code For Deleting The Record Permanently In the Ui Page >>>>>>
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
            //  <<< Code for edit perticular Contact by useing find method to select the perticular id in table >>>>>
            // the field = false for to show the Save button after clicking edit icon >>>>
    @track field = false;
    // <<<  the cfield = false same as save but this is for cancel button >>>>>
    @track cfield = false;
    editContact(event)
    {
        //<<<<  Find method to select perticular id in contact table >>>>>>
        var selectedId = event.currentTarget.dataset.recid;
        console.log('4444444444', selectedId);
        let contact = this.contactList.find(ele=>ele.Id === selectedId);
        console.log('---------', contact);
        contact.isEdit = true;
        if(contact.isEdit = true){
            this.field = true;
            this.cfield = true;
        }
        else{   
            this.field = false;
            this.cfield = false;
        }
        console.log('*********', this.field);
        console.log('&&&&&&&&&&&' ,JSON.stringify(contact));
    }
    //<<<<<<<< this is onchange event for table to change the values in the table >>>>>>>>
    update(event) {
        //<<<<<< here also we used find method to select perticular record and edit for that record
        var selectedId = event.currentTarget.dataset.recid;
        var contactfn = this.contactList.find(ele=>ele.Id === selectedId);

        //This is for to store the values given by you >>>
        if (event.target.label === "FirstName") {
        
          //this is FirstName input textbox
          
          contactfn.FirstName=event.target.value;
          console.log('-------------&' ,JSON.stringify(contactfn));
        } 
         else if (event.target.label === "LastName") {
        
            //this is LastName input textbox
            contactfn.LastName=event.target.value;
            console.log(this.ln);
          }
          else if (event.target.label === "Email") {
        
            //this is Email input textbox
            contactfn.Email=event.target.value;
            console.log(this.email);
          } 
          else if (event.target.label === "Phone") {
        
            //this is Phone input textbox
            contactfn.Phone=event.target.value;
            console.log(this.phone);
          } 
          else if (event.target.label === "Mobile") {
        
            //this is Mobile input textbox
            contactfn.Mobile=event.target.value;
            console.log(this.mobile);
          } 
          console.log('Thdskal',this.contactList);
          console.log('Thdskal',JSON.stringify(this.contactList));
    }
    // <<<<  The save the records edited in the Ui page >>>>>>
    // <<<< here we imported the Editedcon metod from the apex class and contList array from apex class >>>>
    saverecord(){
        
        EditedCon({contList: this.contactList})
            .then(() => {
              this.dispatchEvent(
                  new ShowToastEvent({
                      title: 'Success',
                      message: 'Record Is Successfully Edited And Saved',
                      variant: 'success',
                  }),
              );
          })
          .catch(error => {
              this.dispatchEvent(
                  new ShowToastEvent({
                      title: 'Error',
                      message: error.message,
                      variant: 'error',
                  }),
              );
          });
          window.location.reload();
          console.log('%%%%%%%%%%%' ,contactList);
    }
    // <<<<< code for the reload page when click on the cancel button >>>>
    Cancel(){
        window.location.reload();
    }
}