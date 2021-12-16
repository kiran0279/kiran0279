import { LightningElement, track, api} from 'lwc';
import getCategoryPickList from '@salesforce/apex/ListingFormClass.getCategoryPickList';
import getDurationPickList from '@salesforce/apex/ListingFormClass.getDurationPickList';
import getStatusPickList from '@salesforce/apex/ListingFormClass.getStatusPickList';
import recordInsert from '@salesforce/apex/ListingFormClass.recordInsert';
import getStatePickList from '@salesforce/apex/ListingFormClass.getStatePickList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const MAX_FILE_SIZE = 100000000; //10mb  
export default class listingForm extends LightningElement
{
    @api recordId;
    uploadedFiles = []; file; fileContents; fileReader; content; fileName 
    onFileUpload(event) {  
        if (event.target.files.length > 0) {  
          this.uploadedFiles = event.target.files;  
          this.fileName = event.target.files[0].name;  
          this.file = this.uploadedFiles[0];  
          if (this.file.size > this.MAX_FILE_SIZE) {  
            alert("File Size Can not exceed" + MAX_FILE_SIZE);  
          }  
        }  
      }
   
    @track categoryPL;
    @track Duroptions;
    @track Statusoptins;
    @track Stateoptions;
    connectedCallback() {
        getCategoryPickList()
            .then(result => {
                let opt = [];
                result.forEach(element => {
                    opt.push({
                        label : element,
                        value : element
                    })
                   });
                this.categoryPL = opt;
            })
            getDurationPickList()
            .then(result => {
                let opti = [];
                result.forEach(element => {
                    opti.push({
                        label : element,
                        value : element
                    })
                   });
                this.Duroptions = opti;
            })
            getStatusPickList()
            .then(result => {
                let optio = [];
                result.forEach(element => {
                    optio.push({
                        label : element,
                        value : element
                    })
                   });
                this.Statusoptins = optio;
            })
            getStatePickList()
            .then(result => {
                let option = [];
                result.forEach(element => {
                    option.push({
                        label : element,
                        value : element
                    })
                   });
                this.Stateoptions = option;
            })
    }
    listingname;
    basePrice;
    NumberofDays;
    Street;
    Priceperperson;
    City;
    Guestmincapacity;
    capacity;
    PostalCode;
    Items;
    Country;
    location;
    status;
    state;
    duration;
    category;
    Description;
    Include;
    Other;
    getDetails(event)
    {
        if(event.target.label == 'Description')
        {
            this.Description = event.target.value;
        }
        if(event.target.label == 'Whats Include')
        {
            this.Include = event.target.value;
        }
        if(event.target.label == 'Other Considerations')
        {
            this.Other = event.target.value;
        }
    }
    handleChange(event)
    {
        console.log(event.target.label);
        console.log(event.target.value);

        if(event.target.label == 'Listing Name')
        {
            this.listingname = event.target.value;
        }
        if(event.target.label == 'Base Price')
        {
            this.basePrice = event.target.value;
        }
        if(event.target.label == 'Number Of Days')
        {
            this.NumberofDays = event.target.value;
        }
        if(event.target.label == 'Street')
        {
            this.Street = event.target.value;
        }
        if(event.target.label == 'Price Per Person(Above minimum)')
        {
            this.Priceperperson = event.target.value;
        }
        if(event.target.label == 'City')
        {
            this.City = event.target.value;
        }
        if(event.target.label == 'Guest Min Capacity')
        {
            this.Guestmincapacity = event.target.value;
        }
        if(event.target.label == 'Guest Max Capacity')
        {
            this.capacity = event.target.value;
        }
        if(event.target.label == 'Zip/Postal Code')
        {
            this.PostalCode = event.target.value;
        }
        if(event.target.label == 'Items To Bring')
        {
            this.Items = event.target.value;
        }
        if(event.target.label == 'Country')
        {
            this.Country = event.target.value;
        }
        if(event.target.label == 'PickUp Location')
        {
            this.location = event.target.value;
        }
        if(event.target.label == 'Status')
        {
            this.status = event.target.value;
        }
        if(event.target.label == 'Category')
        {
            this.category = event.target.value;
        }
        if(event.target.label == 'Duration')
        {
            this.duration = event.target.value;
        }
        if(event.target.label == 'State')
        {
            this.state = event.target.value;
        }
    }
    submitDetails(){
        var values = {};
        values.Name	 = this.listingname;
        values.Price__c	 = this.basePrice;
        values.Number_Of_Days__c = this.NumberofDays;
        values.Street__c = this.Street;
        values.Additional_Price_Per_Person__c = this.Priceperperson;
        values.City__c = this.City;
        values.Guest_Min_Capacity__c = this.Guestmincapacity;
        values.Guest_Max_Capacity__c = this.capacity;
        values.ZIP_Postal_Code__c = this.PostalCode;
        values.Items_To_Bring__c = this.Items;
        values.Country__c = this.Country;
        values.Location__c = this.location;
        values.Category__c = this.category;
        values.Duration__c = this.duration;
        values.State2__c = this.state;
        values.Status__c = this.status;
        values.Other_Considerations__c = this.Other;
        values.Description__c = this.Description;
        values.What_s_Included__c = this.Include;
        this.fileReader = new FileReader();  
        this.fileReader.onloadend = (() => {  
       this.fileContents = this.fileReader.result;  
       let base64 = 'base64,';  
       this.content = this.fileContents.indexOf(base64) + base64.length;  
       this.fileContents = this.fileContents.substring(this.content);  
       recordInsert();  
     });  
     this.fileReader.readAsDataURL(this.file);
  recordInsert({recievedRec : values ,file: encodeURIComponent(this.fileContents),  
             fileName: this.fileName })
         .then(conId => {
             if(conId){
          this.dispatchEvent(
             new ShowToastEvent({
                 title: 'Success',
                 message: 'Record Saved Successfully: ',
                 variant: 'success',
             }),
         );
             }
         });  
    }
    resetForm()
    {
        this.template.querySelectorAll('lightning-input , lightning-combobox , lightning-input-rich-text')
            .forEach(element => {
            element.value = '';
        });
    }
}