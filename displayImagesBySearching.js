import { LightningElement, wire, track } from 'lwc';
import recordSearch from'@salesforce/apex/DisplayImageClass.recordSearch';

export default class DisplayImagesBySearching extends LightningElement 
{
    search = '';
    @track currentPage = 1; //this will initialize 1st page
    @track start = 1; //start record position per page
    @track end = 0; //end record position per page
    @track recordSize = 3; //default value we are assigning
    @track totalRecCount = 0; //total record count received from all retrieved records
    @track totalPage = 0; //total number o
    @track sid = [];
    // @track recorddata = [];
    // visibleRecords
    // data;
    // @wire(recordSearch)
    // wiredRecord({error,data})
    // {
    //     if(data){
    //         recorddata = data
    //         console.log(recorddata)
    //     }
    //     if(error){
    //         console.error(error)
    //     }
    // }
    // updaterecord(event)
    // {
    //     this.visibleRecords=[event.detail.records]
    //     console.log(event.detail.records)
    // }
    handleChange(event)
    {
        if(event.target.name == 'search')
        {
            this.search = event.target.value;
            console.log('Onclick Event : '+this.search);
        }
    }
    passdata()
    {
        recordSearch({value : this.search})
        .then(result => {
            // console.log('data ==> '+JSON.stringify(result));
            var recorddata = result.listingList;
            var data = result.rIdsWithConIds;
            console.log('imageId ==> '+JSON.stringify(result));
            for(let list in recorddata){
                for(var key in data){
                    if(recorddata[list].Id == key){
                        this.sid.push({
                            Id : recorddata[list].Id,
                            state : recorddata[list].State2__c,
                            Name : recorddata[list].Name,
                            Category : recorddata[list].Category__c,
                            Duration : recorddata[list].Duration__c,
                            GuestMaxCapacity : recorddata[list].Guest_Max_Capacity__c,
                            url : data[key]
                            
                        })
                        console.log('sai'+JSON.stringify(recorddata));
                        this.totalRecCount = this.sid.length; //here it is 10
                        this.totalPage = Math.ceil(this.totalRecCount / this.recordSize);
                        this.visibleRecords = this.sid.slice(0, this.recordSize);
                        console.log('visible ==> : '+JSON.stringify(this.visibleRecords)) ;  
                        this.end = this.recordSize;
                    }
                }
            }
        })
    }
    previousHandler(){
        if(this.currentPage>1){
            this.currentPage = this.currentPage-1; //decrease currentPage by 1
            this.updateRecords(this.currentPage);
        }
    }
    nextHandler(){
        if((this.currentPage < this.totalPage) && this.currentPage !== this.totalPage){
            this.currentPage = this.currentPage+1; //increase page by 1
            this.updateRecords(this.currentPage);
        }
    }
    updateRecords(currentPage){
        this.start = ((currentPage-1) * this.recordSize);
        this.end = (this.recordSize * currentPage);
        this.end = (this.end > this.totalRecCount)
                    ? this.totalRecCount : this.end;
        this.visibleRecords = this.sid.slice(this.start, this.end);
        this.start = this.start + 1;
    }
}