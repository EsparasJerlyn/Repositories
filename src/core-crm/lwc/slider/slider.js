/**
 * @description A LWC component to display price silder in searchResults
 *
 * @see ../lwc/searchResults
 * 
 * @see searchResults
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
      |---------------------------|-----------------------|----------------------|----------------------------------------------|
      | marygrace.j.li            | April 18, 2022        | DEPP-1269            | Created File                                 |
      | eugene.andrew.abuan       | May 12, 2022          | DEPP-1979            | Added logic to make price editable           |
 */
import { LightningElement, api,track } from 'lwc';

const MIN_VALUE = '0';
const MAX_VALUE = '5000';
const THUMBS = ['start', 'end'];

export default class Slider extends LightningElement {

    @api 
    get min(){
        return this._min;
    } 
    set min(value){
        this._min = parseFloat(value);
    }
    @api 
    get max(){
        return this._max;
    } 
    set max(value){
        this._max = parseFloat(value);
    }

    @api
    get step(){
        return this._step;
    } 
    set step(value){
        this._step = parseFloat(value);
    }

    @api
    get start() {
        return this._start;
    };
    set start(value) {
        this._start = this.setBoundries(value);
    }
    @api
    get end() {
        return this._end;
    };
    set end(value) {
        this._end = this.setBoundries( value);
    }

    get rangeValue() {
        return Math.abs(this.end - this.start);
    }

    _max = MAX_VALUE;
    _min = 0;
    _step = 1;
    _start = MIN_VALUE;
    _end = MAX_VALUE;
    _startValueInPixels;
    _endValueInPixels;
   
    // Elements
    slider;
    sliderRange;
    currentThumb;
    editMode = false;
    @track inputClass = {};
    currentThumbName;   
    currentThumbPositionX; 
    maxRange = 300; 
   
    isMoving = false;
    rendered = false;

    connectedCallback(){
        this.inputClass.start = "input-button";
        this.inputClass.end = "input-button";
    }
    renderedCallback() {
        if (!this.rendered) {
            this.initSlider();
            this.rendered = true;
        }
    }

    // Functions that set the values of the slider on Load
    initSlider() {
        this.slider = this.template.querySelector('.slider');
        this.sliderRange = this.template.querySelector('.range');
        const thumb = this.template.querySelector('.thumb');
        if(this.slider && thumb){
            this.maxRange = this.slider.offsetWidth - thumb.offsetWidth;
      
            this._startValueInPixels = this.convertValueToPixels(this.start);
            this._endValueInPixels = this.convertValueToPixels(this.end);
            this.setThumb('start', this._startValueInPixels);
            this.setThumb('end', this._endValueInPixels);
            this.setRange(this._startValueInPixels, this._endValueInPixels);
        }
    }

    //Function that sets boundaries between min price and max price
    setBoundries(value) {
        let _value = typeof value === 'number' ? value : parseFloat(value);
            _value = _value < 0 ? 0 : value; // MIN
        return _value > this.max ? this.max : _value; // MAX
    }

    //Function that converts value in the slider to px
    convertValueToPixels(value) {
        return parseFloat(((value / this.max) * this.maxRange).toFixed(2));
    }

    //Function that converts px in the slider to a value to make integer
    convertPixelsToValue(value, step = 1) {
        let _value = parseFloat((value / this.maxRange) * this.max);
        // round to step value
        _value = step > 0 ? Math.round(_value / step) * step : _value;
        return parseFloat(_value.toFixed(2));
    }
    
   //handles the slider when touched 
    handleMouseDown(event) {
        const thumbId = event.target.dataset.name;
        // allow move
        if (THUMBS.includes(thumbId)) {
            this.currentThumbName = thumbId;
            this.currentThumb = event.target;
            const startX = event.clientX || event.touches[0].clientX;
            this.currentThumbPositionX = startX - this.currentThumb.getBoundingClientRect().left;
            this.toggleActiveThumb(true);
            this.isMoving = true;
        }
        else {
             event.preventDefault(); 
        }
    }
 
    //handles the slider when moving 
    onMouseMove(event) {
        // track mouse mouve only when toggle true
         if (this.isMoving) {
             const currentX = event.clientX || event.targetTouches[0].clientX;
             let moveX = currentX - this.currentThumbPositionX - this.slider.getBoundingClientRect().left;
           
             let moveValue = this.convertPixelsToValue(moveX, this.step);
             // lock the thumb within the bounaries
             moveValue = this.setBoundries(moveValue);
             moveX = this.convertValueToPixels(moveValue);
 
             switch (this.currentThumbName) {
                 case 'start':
                     this._startValueInPixels = moveX;
                     this._start = moveValue;
                    break;
                 case 'end':
                     this._endValueInPixels = moveX;
                     this._end = moveValue;
                  break;
             }
             this.setThumb(this.currentThumbName, moveX);
             this.setRange(this._endValueInPixels, this._startValueInPixels);
         }
         else {
             event.preventDefault(); 
         }
     }

    //handles when the slider stops moving
    onMouseUp(event) {
        this.isMoving = false;
        this.toggleActiveThumb(false);
        this.onChangeValue();
        event.preventDefault(); 
    }

   //Function that sets the thumb values that can be visible in screen
    setThumb(thumbName, valueInPixels) {
        const thumbs = this.slider.querySelectorAll('.thumb');
        thumbs.forEach(thumb => {
            if (thumb.dataset.name === thumbName) {
                thumb.style.setProperty('--thumb-left-position', `${valueInPixels}px`);
            }
        });
    }

    //function that sets color to the thumb
    toggleActiveThumb(toggle = true) {
        const color = toggle ? '#000000' : '#000000';
        this.currentThumb.style.setProperty('--thumb-active-color', color);
    }

    //Functions that calculates the difference of the range of min price and max price
    setRange(start, end) {
        const maxThumb = Math.max(start, end);
        const minThumb = Math.min(start, end);
        const width = Math.abs(maxThumb - minThumb);
        this.sliderRange.style.setProperty('--range-left-position', `${minThumb}px`);
        this.sliderRange.style.setProperty('--range-width', `${width}px`);
    }

    //Functions that pass the values to the parent component
    onChangeValue() {
        this.dispatchEvent(new CustomEvent('pricevaluechange', {
            detail: {
                start: this.start,
                end: this.end,
                range: this.rangeValue
            }
        }));
    }

    //Handles when Min price is edited in the input box
    handleOnChangePriceStart(event){
        this._start = parseInt(event.target.value);
        this._startValueInPixels = this.convertValueToPixels(this.start);
        this.setThumb('start', this._startValueInPixels);
        this.setRange(this._endValueInPixels, this._startValueInPixels);
        this.inputClass.start = 'input-button';
        this.onChangeValue();
    }

    //Handles when Max price is edited in the input box
    handleOnChangePriceEnd(event){
        this._end = parseInt(event.target.value);
        this._max = parseInt(event.target.value);
        this._endValueInPixels = this.convertValueToPixels(this.end);
        this.setThumb('end', this._endValueInPixels);
        this.setRange(this._endValueInPixels, this._startValueInPixels);
        this.inputClass.end = 'input-button';
        this.onChangeValue();
    }
    //handles pencil icon for start price
    handleEditStart(){
        this.inputClass.start ='input-button input-button-edit';
    }

    //handles pencil icon for end price
    handleEditEnd(){
        this.inputClass.end = 'input-button input-button-edit';
    }

    //function that sets the default values back to 0 and 5000
    @api setDefaultValues(){
        this._start = MIN_VALUE;
        this._end = MAX_VALUE;
        this._max = MAX_VALUE;

        this.initSlider();
    }

}