import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import Coupon__c_OBJECT from '@salesforce/schema/Coupon__c';
import NAME_FIELD from '@salesforce/schema/Coupon__c.Name';
import DURATION_FIELD from '@salesforce/schema/Coupon__c.Duration_In_Months__c';
import QUANTITY_FIELD from '@salesforce/schema/Coupon__c.Quantity_Of_Coupons__c';
import DATEANDTIME_FIELD from '@salesforce/schema/Coupon__c.Enter_Expiry_Date__c';
export default class trying extends NavigationMixin(LightningElement) {
    @api label;
    name = '';
    duration = '';
    quantity;
    dandt = '';
    @api get discountType() {
        return [
            { label: 'Percentage', value: 'option1' },
            { label: 'Fixed Amount', value: 'option2' },
        ];
    }
    @api handleChange(event) {
        console.log('=======', JSON.stringify(event.target.label));
        console.log('=======', JSON.stringify(event.target.value));
        if (event.target.label == 'Coupon Name') {
            this.name = event.target.value;
        }
        const CouponName = this.name;
        if (CouponName.includes("%")) {
            this.radio1 = "option1";
        }
        else {
            this.radio1 = "option2";
        }
        if (event.target.label == 'Duration in Months') {
            this.duration = event.target.value;
        }
        if (event.target.label == 'Enter Expiry Date') {
            this.dandt = event.target.value;
        }
        if (event.target.label == 'Quantity of Coupon') {
            this.quantity = event.target.value;
        }
    }
    @api createCoupon() {
        const fields = {};
        fields[NAME_FIELD.fieldApiName] = this.name;
        fields[DURATION_FIELD.fieldApiName] = this.duration;
        fields[QUANTITY_FIELD.fieldApiName] = 9; //this.quantity;
        fields[DATEANDTIME_FIELD.fieldApiName] = this.dandt;
        console.log('=======', JSON.stringify(fields));
        const recordInput = { apiName: Coupon__c_OBJECT.objectApiName, fields };
        createRecord(recordInput)
            .then(result => {
                console.log('=======', JSON.stringify(result));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Coupon Created',
                        variant: 'success'
                    }),
                );
                const selectedEvent = new CustomEvent("newcoupondetails", {
                    detail: { value: result.id, label: result.fields.Name.value }
                });
                this.dispatchEvent(selectedEvent);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error Creating Record',
                        message: error.body.message,
                        variant: 'error',
                    })
                );
            });
    }
    @api get expiryDate() {
        return [
            { label: 'Yes', value: 'option11' },
            { label: 'No', value: 'option12' },
        ];
    }
    @track fieldVisible = false;
    @api handleChange1(event) {
        const radio2 = event.detail.value;
        if (radio2 == 'option11') {
            this.fieldVisible = true;
        }
        else {
            this.fieldVisible = false;
        }
    }
    @api get quantity() {
        return [
            { label: 'Yes', value: 'option13' },
            { label: 'No', value: 'option14' },
        ];
    }
    @track field = false;
    @api handleChange2(event) {
        const radio3 = event.detail.value;
        if (radio3 == 'option13') {
            this.field = true;
        }
        else {
            this.field = false;
        }
    }
}