import { LightningElement } from 'lwc';

export default class PageBanner extends LightningElement {
    
    get bannerText1(){
        let text1 ='';
        text1 += `Short courses and professional development`;   
        return text1;
    }

    get bannerText2(){
        let text2 ='';
        text2 += `Improve your job prospects, unlock better career opportunities, and extend your relevance with our selection of real world short courses.`;   
        return text2;
    }


}