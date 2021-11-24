import { LightningElement, track,api,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation'
import getCoupons from '@salesforce/apex/couponController.getCoupons';
export default class AllCoupons extends NavigationMixin(LightningElement){
    NavigateTochild(event){
        event.preventDefault();
        let componentDef={
            componentDef :"c:setCoupon",
            attributes :{
                label : 'Create New Coupon'
            }
        };
        let encodedComponentDef = btoa(JSON.stringify(componentDef));
        this[NavigationMixin.Navigate]({
            type : 'standard__webPage',
            attributes :{
                url : 'one/one.app#' + encodedComponentDef
            }
        });
    }
    @track data;
        @track columns = [
            {label :"label", fieldName : 'Name', type : 'text'},
        ];
        @wire (getCoupons) accountRecords({error,data}){
            if(data){
                this.data = data;
            }
            else if(error)
            {
                this.data = undefined
            }
        }

   
 handleRadioChange(event)
    {
        const selectedOption = event.detail.value;
        if(selectedOption == 'Test5'){
            this.Test5FieldValue = true;
        }else{
            this.Test5FieldValue = false;
        }
        if(selectedOption == 'Test4'){
            this.Test4FieldValue = true;
        }else{
            this.Test4FieldValue = false;
        }
        if(selectedOption == 'Test3'){
            this.Test3FieldValue = true;
        }else{
            this.Test3FieldValue = false;
        }
        if(selectedOption=='Test2'){
            this.Test2Fieldvalue = true;
        }else{
            this.Test2FieldValue = false;
        }
        if(selectedOption == 'Test1'){
            this.Test1FieldValue = true;
        }else{
            this.Test1FieldValue = false;
        }
    }
}