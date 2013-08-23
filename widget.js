/* Copyright (c) 2010 Samuel R Madden (madden@csail.mit.edu)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.<
*/
// Defines javascript methods that implement the widget routines
//   used by dashboard widgets.

function Menu() {
    this.addMenuItem = function(item) {
    }
    
    this.setMenuItemEnabledAtIndex = function(index, enabled) {
    }
    

    // terrible hack -- always select the first item
    this.popup = function(x,y) {
        return 0;
    }
}

function Calculator() {
    this.evaluateExpression = function(expr, unknown) {
        if (expr == "decimal_string")
            return ".";
        else if (expr == "thousands_separator")
            return ",";
        else
            return eval(expr);
    }
}

function Widget () {

    this.calculator = new Calculator();
    
    this.identifier = 	"widget";
    
    this.map = {};
    
    this.openURL = function(url) {
        alert ("request to open " + url);
        document.location=url;
        //window.open(url,'','');
    }
    
    this.preferenceForKey = function(key) {
        alert ("lookup " + key );
                alert ("got " + this.map[key] );

        return this.map[key];
    }
    
    this.setPreferenceForKey = function(value, key) {
        alert  ("adding " + value + " for key " + key);
        this.map[key] = value;
    }
    
    //unsure how to implement this
    this.prepareForTransition = function(toState) {
    }
    
    //unsure how to implement this  
    this.performTransition = function() {
    }
    
    this.createMenu = function() {
        return new Menu();
    }
    
    
    this.resizeAndMoveTo = function(left,top,width,height) {
        alert("move:" + left + "," + top + "," + width + "," + height);
        //window.moveTo(left,top);
        resizeTo(width,height);
    }
    
    
    //we don't show close or position boxes
    this.setCloseBoxOffset = function(x,y) {
    }
    
    //we don't show close or position boxes 
    this.setPositionOffset = function(x,y) {
    }
    
    //helper method to load widget settings from a string
    this.setKeys = function(keys) {
        alert ("in setkeys, keys = "  + keys);
        var vals = keys.split("*");
    
        for (var val in vals) {
            var pair = vals[val].split(":");
            alert(vals[val]);
            if (pair[1] == 'true')
                pair[1] = true;
            if (pair[1] == 'false')
                pair[1] = false;
            this.map[pair[0]] = pair[1];
        }
    }
    
    //helper method to save widget settings to a string
    this.getKeys = function() {
        var ret = "";
        var first = true;
        for (var key in this.map) {
            if (!first) {
                ret += "*";
            } else
                first = false;
            ret += key + ":" + this.map[key];
        }
        return ret;
        
    }
}


//window = document.createElement("window");
widget = window.widget = new Widget(); 
window.screenX = 100;
window.screenY = 100;
didChangeSize = false;


resizeTo = function(width,height) {
    alert("resize2:" + width + "," + height);
    alert ("window size = " + window.innerHeight);
    didChangeSize = true;

    if (width != window.innerWidth ) {
       window.innerWidth = width;
       document.body.clientWidth = width;
    }
    if (height != window.innerHeight) {
       window.innerHeight = height;
        document.body.clientHeight = height;
    }   
    
    //window.moveTo(5,5);


}


function setKeys(keys) {
    widget.setKeys(keys);
}


