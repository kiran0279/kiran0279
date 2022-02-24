import {LightningElement} from 'lwc';

export default class getUsers extends LightningElement {

    selectedAccount;

    handleAccountSelection(event){
        this.selectedAccount = event.target.value;
    }
}