import { LightningElement, api } from 'lwc';

export default class DisplayImagesBySearchingChild extends LightningElement 
{
   
    prevPage() {
        this.dispatchEvent(new CustomEvent('previous'));
    }
    nextPage() {
        this.dispatchEvent(new CustomEvent('next'));
    }
    get disablePrevious(){
        return this.currentPage<=1
    }
    get disableNext(){
        return this.currentPage>=this.totalPage
    }
}