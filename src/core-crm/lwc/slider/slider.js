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
      | eugene.andrew.abuan       | July 13, 2022         | DEPP-3376            |Changed onmouse events to ondrag              |

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
        if(isNaN(this._start)){
            
            this._start = MIN_VALUE;
        }if(Math.abs(this._start) >= this._end){
            this._start = this._end - 1;
        }
        return Math.abs(this._start);
    };
    set start(value) {
        this._start = this.setBoundries(value);
    }
    @api
    get end() {
        if(isNaN(this._end))
        {
            this._end = MAX_VALUE;
            this._max = MAX_VALUE;
            this._endValueInPixels = this.convertValueToPixels(this._end);
            this.setThumb('end', this._endValueInPixels);
        }
        return Math.abs(this._end);
    };
    set end(value) {
        this._end = this.setBoundries( value);
    }

    get rangeValue() {
        return this.end - this.start;
    }

    _max = MAX_VALUE;
    _min = 0;
    _step = 1;
    _start = MIN_VALUE;
    _end =  MAX_VALUE;
    _startValueInPixels;
    _endValueInPixels;
    @track tempValStart;
    @track tempValEnd;
    @api parend;
    @api parstart;
    // Elements
    slider;
    sliderRange;
    currentThumb;
    editMode = false;
    @track inputClass = {};
    currentThumbName;   
    currentThumbPositionX; 
    maxRange = 300; 
    newchanges = 0;
   
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
            if(this.parend || this.parstart){
                this.onChangeValue();
            }
        }
    }

    // Functions that set the values of the slider on Load
    initSlider() {
       
        this.slider = this.template.querySelector('.slider');
        this.sliderRange = this.template.querySelector('.range');
        const thumb = this.template.querySelector('.thumb');
        const thumbStart = this.template.querySelector('.start');
        const thumbEnd = this.template.querySelector('.end');
        if(this.slider && thumb){
            this.maxRange = this.slider.offsetWidth - thumb.offsetWidth;
            this._startValueInPixels = this.convertValueToPixels(this.parstart ? this.parstart :this.start);
            this._endValueInPixels = this.convertValueToPixels(this.parend ? this.parend : this.end);
            this.setThumb('start', this._startValueInPixels);
            this.setThumb('end', this._endValueInPixels);
            this.setRange(this._startValueInPixels, this._endValueInPixels);
            window.addEventListener('mouseup', (event) => this.onMouseUp(event));
            this.slider.addEventListener('mousedown', (event) => this.handleMouseDown(event));
            this.slider.addEventListener('mousemove', (event) => this.onMouseMove(event));
            this.slider.addEventListener('touchmove', (event) => this.onMouseMove(event));
            thumbStart.addEventListener('touchstart', (event) =>this.handleMouseDown(event));
            thumbStart.addEventListener('touchend', (event) => this.onMouseUp(event));
            thumbEnd.addEventListener('touchstart', (event) =>this.handleMouseDown(event));
            thumbEnd.addEventListener('touchend', (event) => this.onMouseUp(event));
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
        event.preventDefault(); 

        if (THUMBS.includes(thumbId)) {
            this.currentThumbName = thumbId;
            this.currentThumb = event.target;
            const startX = event.clientX || event.touches[0].clientX;
            this.currentThumbPositionX = startX - this.currentThumb.getBoundingClientRect().left;
            this.toggleActiveThumb(true);
            this.isMoving = true;
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
                    if(moveX < this._endValueInPixels){
                        this._startValueInPixels = moveX;
                        this._start = moveValue;
                        this.setThumb(this.currentThumbName, moveX);
                        this.setRange(this._endValueInPixels, this._startValueInPixels);
                        tempValStart = this._start;
                    }
                    break;
                case 'end':
                    if(moveX > this._startValueInPixels){
                        this._endValueInPixels = moveX;
                        this._end = moveValue;
                        this.setThumb(this.currentThumbName, moveX);
                        this.setRange(this._endValueInPixels, this._startValueInPixels);
                        this.tempValEnd = this._end;
                    }
                    break;
            }
         }
         else {
             event.preventDefault(); 
         }
     }

    //handles when the slider stops moving
    onMouseUp(event) {
        this.isMoving = false;
        this.toggleActiveThumb(false);
        this.newchanges = 1;
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
        this.parend && this.newchanges == 0 ? this._end = this.parend :this._end = this._end;
        this.parstart && this.newchanges == 0 ? this._start = this.parstart :this._start = this._start;
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
        this.newchanges = 1;
        this._start = parseInt(event.target.value);
        this._startValueInPixels = this.convertValueToPixels(this.start);
        this.setThumb('start', this._startValueInPixels);
        this.setRange(this._endValueInPixels, this._startValueInPixels);
        this.inputClass.start = 'input-button';
        this.onChangeValue();
    }

    //Handles when Max price is edited in the input box
    handleOnChangePriceEnd(event){
        this.newchanges = 1;
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
        this.parstart = MIN_VALUE;
        this.parend = MAX_VALUE;

        this.initSlider();
    }

}