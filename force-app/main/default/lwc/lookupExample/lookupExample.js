import {LightningElement} from 'lwc';

export default class LookupExample extends LightningElement {

    selectedAccount;

    handleAccountSelection(event){
        this.selectedAccount = event.target.value;
    }
}