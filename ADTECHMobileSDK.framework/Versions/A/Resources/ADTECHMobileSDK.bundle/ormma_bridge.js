/*  Copyright (c) 2011 The ORMMA.org project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

(function () {

    var ormmaview = window.ormmaview = {};
	var readyFired = false;

    /****************************************************/
    /********** PROPERTIES OF THE ORMMA BRIDGE **********/
    /****************************************************/

    /** Expand Properties */
    var expandProperties = {
        width:Number.NaN,
        height:Number.NaN,
        useCustomClose:false,
        isModal:true,
        useBackground:false,
        backgroundColor:'#ffffff',
        backgroundOpacity:1.0,
        lockOrientation:false
    };

    var orientationProperties = {
        allowOrientationChange:true,
        forceOrientation:'none'
    };

    /** Resize Properties */
    var resizeProperties = {
        width:Number.NaN,
        height:Number.NaN,
        customClosePosition:null,
        offsetX:Number.NaN,
        offsetY:Number.NaN,
        allowOffscreen:true
    };

    /** Shake Properties */
    var shakeProperties = {
        intensity:1.3,
        interval:0.4
    };


    /** The set of listeners for ORMMA Native Bridge Events */
    var listeners = { };


    /** A Queue of Calls to the Native SDK that still need execution */
    var nativeCallQueue = [ ];

    /** Identifies if a native call is currently in progress */
    var nativeCallInFlight = false;

    /** timer for identifying iframes */
    var timer;
    var totalTime;


    /**********************************************/
    /********** OBJECTIVE-C ENTRY POINTS **********/
    /**********************************************/

    /**
     * Called by the Objective-C SDK when an asset has been fully cached.
     *
     * @returns string, "OK"
     */
    ormmaview.fireAssetReadyEvent = function (alias, URL) {
        var handlers = listeners["assetReady"];
        if (handlers != null) {
            for (var i = 0; i < handlers.length; i++) {
                handlers[i](alias, URL);
            }
        }

        return "OK";
    };


    /**
     * Called by the Objective-C SDK when an asset has been removed from the
     * cache at the request of the creative.
     *
     * @returns string, "OK"
     */
    ormmaview.fireAssetRemovedEvent = function (alias) {
        var handlers = listeners["assetRemoved"];
        if (handlers != null) {
            for (var i = 0; i < handlers.length; i++) {
                handlers[i](alias);
            }
        }

        return "OK";
    };


    /**
     * Called by the Objective-C SDK when an asset has been automatically
     * removed from the cache for reasons outside the control of the creative.
     *
     * @returns string, "OK"
     */
    ormmaview.fireAssetRetiredEvent = function (alias) {
        var handlers = listeners["assetRetired"];
        if (handlers != null) {
            for (var i = 0; i < handlers.length; i++) {
                handlers[i](alias);
            }
        }

        return "OK";
    };


    /**
     * Called by the Objective-C SDK when various state properties have changed.
     *
     * @returns string, "OK"
     */
    ormmaview.fireChangeEvent = function (properties) {
	
		if (!this.readyFired) {
			for (var property in properties) {
				if (property == "ready") {
					readyFired = true;
					break;
				}
			}
		}
	
        var handlers = listeners["change"];
        if (handlers != null) {
            for (var i = 0; i < handlers.length; i++) {
                handlers[i](properties);
            }
        }

        return "OK";
    };


    /**
     * Called by the Objective-C SDK when an error has occured.
     *
     * @returns string, "OK"
     */
    ormmaview.fireErrorEvent = function (message, action) {
        var handlers = listeners["error"];
        if (handlers != null) {
            for (var i = 0; i < handlers.length; i++) {
                handlers[i](message, action);
            }
        }

        return "OK";
    };


    /**
     * Called by the Objective-C SDK when the user shakes the device.
     *
     * @returns string, "OK"
     */
    ormmaview.fireShakeEvent = function () {
        var handlers = listeners["shake"];
        if (handlers != null) {
            for (var i = 0; i < handlers.length; i++) {
                handlers[i]();
            }
        }

        return "OK";
    };


    /**
     * nativeCallComplete notifies the abstraction layer that a native call has
     * been completed..
     *
     * NOTE: This function is called by the native code and is not intended to be
     *       used by anything else.
     *
     * @returns string, "OK"
     */
    ormmaview.nativeCallComplete = function (cmd) {

        // anything left to do?
        if (nativeCallQueue.length == 0) {
            nativeCallInFlight = false;
            return;
        }

        // still have something to do
        var bridgeCall = nativeCallQueue.pop();
        this.performCall(bridgeCall, true);

        return "OK";
    };


    /**
     *
     */
    ormmaview.showAlert = function (message) {
        alert(message);
    };


    /*********************************************/
    /********** INTERNALLY USED METHODS **********/
    /*********************************************/


    /**
     *
     */
    ormmaview.zeroPad = function (number) {
        var text = "";
        if (number < 10) {
            text += "0";
        }
        text += number;
        return text;
    }
 
	/**
	 *
	 */
	ormmaview.performCall = function (call, checkSDKReady) {
		if (!readyFired && checkSDKReady) {
			console.log("WARNING: Ad calls native before ready event is fired with URL: " + call);
		}
 
		var iframe = document.createElement("IFRAME");
		iframe.setAttribute("src", call);
		document.documentElement.appendChild(iframe);
		iframe.parentNode.removeChild(iframe);
		iframe = null;
//		window.location = call;
	}

    /**
     *
     */
    ormmaview.executeNativeCall = function (command) {
        // build iOS command
        var bridgeCall = "ormma://" + command;
        var value;
        var firstArg = true;

        for (var i = 1; i < arguments.length; i += 2) {
            value = arguments[i + 1];
            if (value == null) {
                // no value, ignore the property
                continue;
            }

            // add the correct separator to the name/value pairs
            if (firstArg) {
                bridgeCall += "?";
                firstArg = false;
            }
            else {
                bridgeCall += "&";
            }
            bridgeCall += arguments[i] + "=" + encodeURIComponent(value);
        }

        // add call to queue
        if (nativeCallInFlight) {
            // call pending, queue up request
            nativeCallQueue.push(bridgeCall);
        }
        else {
            // no call currently in process, execute it directly
            nativeCallInFlight = true;
			this.performCall(bridgeCall, true);
        }
    };


    /***************************************************************************/
    /********** LEVEL 0 (not part of spec, but required by public API **********/
    /***************************************************************************/

    /**
     *
     */
    ormmaview.activate = function (event) {
        this.executeNativeCall("service",
            "name", event,
            "enabled", "Y");
    };


    /**
     *
     */
    ormmaview.addEventListener = function (event, listener) {
        var handlers = listeners[event];
        if (handlers == null) {
            // no handlers defined yet, set it up
            listeners[event] = [];
            handlers = listeners[event];
        }

        // see if the listener is already present
        for (var handler in handlers) {
            if (listener == handler) {
                // listener already present, nothing to do
                return;
            }
        }

        // not present yet, go ahead and add it
        handlers.push(listener);
    };


    /**
     *
     */
    ormmaview.deactivate = function (event) {
        this.executeNativeCall("service",
            "name", event,
            "enabled", "N");
    };


    /**
     *
     */
    ormmaview.removeEventListener = function (event, listener) {
        var handlers = listeners[event];
        if (handlers != null) {
            handlers.remove(listener);
        }
    };


    /*****************************/
    /********** LEVEL 1 **********/
    /*****************************/

    /**
     *
     */
    ormmaview.close = function () {
        this.executeNativeCall("close");
    };


    /**
     * ORMMA version of expand
     */
    ormmaview.ormmaExpand = function (URL) {
        try {
            var cmd = "this.executeNativeCall( 'expand'";
            if (URL != null) {
                cmd += ", 'url', '" + URL + "'";
            }
            if (( typeof expandProperties.width != "undefined" ) && ( expandProperties.width != null ) && ( !isNaN(expandProperties.width) ) && ( expandProperties.width >= 0 )) {
                cmd += ", 'w', '" + expandProperties.width + "'";
            }
            if (( typeof expandProperties.height != "undefined" ) && ( expandProperties.height != null ) && ( !isNaN(expandProperties.height) ) && ( expandProperties.height >= 0 )) {
                cmd += ", 'h', '" + expandProperties.height + "'";
            }
            if (( typeof expandProperties.useBackground != "undefined" ) && ( expandProperties.useBackground != null )) {
                cmd += ", 'useBG', '" + ( expandProperties.useBackground ? "Y" : "N" ) + "'";
            }
            if (( typeof expandProperties.backgroundColor != "undefined" ) && ( expandProperties.backgroundColor != null )) {
                cmd += ", 'bgColor', '" + expandProperties.backgroundColor + "'";
            }
            if (( typeof expandProperties.backgroundOpacity != "undefined" ) && ( expandProperties.backgroundOpacity != null )) {
                cmd += ", 'bgOpacity', " + expandProperties.backgroundOpacity;
            }
            if (( typeof expandProperties.lockOrientation != "undefined" ) && ( expandProperties.lockOrientation != null )) {
                cmd += ", 'lkOrientation', '" + ( expandProperties.lockOrientation ? "Y" : "N" ) + "'";
            }
            if (( typeof expandProperties.useCustomClose != "undefined" ) && ( expandProperties.useCustomClose != null )) {
                cmd += ", 'useCustomClose', '" + ( expandProperties.useCustomClose ? "Y" : "N" ) + "'";
            }
            cmd += ", 'standard', 'ormma' );";
            eval(cmd);
        } catch (e) {
            alert("executeNativeExpand: " + e + ", cmd = " + cmd);
        }
    };

    /**
     * MRAID 2.0 version of expand
     */
    ormmaview.mraidExpand = function (URL) {
        try {
            var cmd = "this.executeNativeCall( 'expand'";
            if (URL != null) {
                cmd += ", 'url', '" + URL + "'";
            }
            if (( typeof expandProperties.width != "undefined" ) && ( expandProperties.width != null ) && ( !isNaN(expandProperties.width) ) && ( expandProperties.width >= 0 )) {
                cmd += ", 'w', '" + expandProperties.width + "'";
            }
            if (( typeof expandProperties.height != "undefined" ) && ( expandProperties.height != null ) && ( !isNaN(expandProperties.height) ) && ( expandProperties.height >= 0 )) {
                cmd += ", 'h', '" + expandProperties.height + "'";
            }
            if (( typeof expandProperties.useCustomClose != "undefined" ) && ( expandProperties.useCustomClose != null )) {
                cmd += ", 'useCustomClose', '" + ( expandProperties.useCustomClose ? "Y" : "N" ) + "'";
            }

            cmd += ", 'allowOrientationChange', '" + (orientationProperties.allowOrientationChange ? "Y" : "N") + "'";
            cmd += ", 'forceOrientation', '" + orientationProperties.forceOrientation + "'";
            cmd += ", 'standard', 'mraid' );";
            eval(cmd);
        } catch (e) {
            alert("executeNativeExpand: " + e + ", cmd = " + cmd);
        }
    };

    ormmaview.getExpandProperties = function () {
        return expandProperties;
    }

    /**
     *
     */
    ormmaview.setExpandProperties = function (properties) {
        expandProperties = properties;

        // background opacity is not supported in the iOS SDK, always 1.0
        expandProperties.backgroundOpacity = 1.0;

        // expanded ad is always presented as modal in the iOS SDK, always true
        expandProperties.isModal = true;
    };

    ormmaview.setOrientationProperties = function (properties) {
		for (var prop in properties) {
            orientationProperties[prop] = properties[prop];
        }
		
		// Warning (ZU): If the state is loading, we must not call any native methods because that changes the window.location value which stops the rendering.
		var state = ormma.getState();
		if (state != 'loading')
		{
			try {
				var cmd = "this.executeNativeCall( 'setOrientationProperties'";
				cmd += ", 'allowOrientationChange', '" + ( orientationProperties.allowOrientationChange ? "Y" : "N" ) + "'";
				cmd += ", 'forceOrientation', '" + orientationProperties.forceOrientation + "'";
				cmd += " );";
				eval(cmd);
			} catch (e) {
				alert("executeNativeSetOrientationProperties: " + e + ", cmd = " + cmd);
			}
		}
    }

    ormmaview.getOrientationProperties = function () {
        return orientationProperties;
    }

    /**
     *
     */
    ormmaview.hide = function () {
        this.executeNativeCall("hide");
    };
 
	/**
	 *
	 */
	ormmaview.vibrate = function (repeat) {
		this.executeNativeCall("vibrate",
							   "repeat", repeat);
	};

    /**
     *
     */
    ormmaview.open = function (URL, controls) {
        // the navigation parameter is an array, break it into its parts
        var back = false;
        var forward = false;
        var refresh = false;
        if (controls == null) {
            back = true;
            forward = true;
            refresh = true;
        }
        else {
            for (var i = 0; i < controls.length; i++) {
                if (( controls[i] == "none" ) && ( i > 0 )) {
                    // error
                    self.fireErrorEvent("none must be the only navigation element present.", "open");
                    return;
                }
                else if (controls[i] == "all") {
                    if (i > 0) {
                        // error
                        self.fireErrorEvent("none must be the only navigation element present.", "open");
                        return;
                    }

                    // ok
                    back = true;
                    forward = true;
                    refresh = true;
                }
                else if (controls[i] == "back") {
                    back = true;
                }
                else if (controls[i] == "forward") {
                    forward = true;
                }
                else if (controls[i] == "refresh") {
                    refresh = true;
                }
            }
        }


        this.executeNativeCall("open",
            "url", URL,
            "back", ( back ? "Y" : "N" ),
            "forward", ( forward ? "Y" : "N" ),
            "refresh", ( refresh ? "Y" : "N" ));
    };


    /**
     *
     */
    ormmaview.openMap = function (URL, fullscreen) {

        this.executeNativeCall("openMap",
            "url", URL,
            "fullscreen", fullscreen
        );
    };

    /**
     *
     */
    ormmaview.resize = function (width, height) {
        this.executeNativeCall("resize",
            "w", width,
            "h", height,
            "standard", "ormma");
    };

    /**
     *
     */
    ormmaview.mraidResize = function () {
        if (isNaN(resizeProperties.width) || isNaN(resizeProperties.height)) {
            self.fireErrorEvent("resizeProperties were not set prior to calling resize.", "resize");
            return;
        }

        try {
            var cmd = "this.executeNativeCall( 'resize'";
            if (!isNaN(resizeProperties.width)) {
                cmd += ", 'width', '" + resizeProperties.width + "'";
            }
            if (!isNaN(resizeProperties.height)) {
                cmd += ", 'height', '" + resizeProperties.height + "'";
            }
            if (resizeProperties.customClosePosition != null) {
                cmd += ", 'customClosePosition', '" + resizeProperties.customClosePosition + "'";
            }
            if (!isNaN(resizeProperties.offsetX)) {
                cmd += ", 'offsetX', '" + resizeProperties.offsetX + "'";
            }
            if (!isNaN(resizeProperties.offsetY)) {
                cmd += ", 'offsetY', '" + resizeProperties.offsetY + "'";
            }
            cmd += ", 'allowOffscreen', '" + (resizeProperties.allowOffscreen ? "Y" : "N") + "'";
            cmd += ", 'standard', 'mraid');";
            eval(cmd);
        }
        catch (e) {
            self.fireErrorEvent("Resize failed.", "resize");
        }
    };

    ormmaview.getResizeProperties = function () {
        return resizeProperties;
    }

    ormmaview.setResizeProperties = function (properties) {
		for (var prop in properties) {
			resizeProperties[prop] = properties[prop];
		}
    };

    /**
     *
     */
    ormmaview.show = function () {
        this.executeNativeCall("show");
    };


    /**
     *
     */
    ormmaview.playAudio = function (URL, properties) {

        var cmd = "this.executeNativeCall( 'playAudio'";

        cmd += ", 'url', '" + URL + "'";

        if (properties != null) {

            if (( typeof properties.autoplay != "undefined" ) && ( properties.autoplay != null )) {
                cmd += ", 'autoplay', 'Y'";
            }
            else {
                cmd += ", 'autoplay', 'N'";
            }

            if (( typeof properties.controls != "undefined" ) && ( properties.controls != null )) {
                cmd += ", 'controls', 'Y'";
            }
            else {
                cmd += ", 'controls', 'N'";
            }

            if (( typeof properties.loop != "undefined" ) && ( properties.loop != null )) {
                cmd += ", 'loop', 'Y'";
            }
            else {
                cmd += ", 'loop', 'N'";
            }

            if (( typeof properties.inline != "undefined" ) && ( properties.inline != null )) {
                cmd += ", 'inline', 'Y'";
            }
            else {
                cmd += ", 'inline', 'N'";
            }

            //TODO check valid values...

            if (( typeof properties.startStyle != "undefined" ) && ( properties.startStyle != null )) {
                cmd += ", 'startStyle', '" + properties.startStyle + "'";
            }
            else {
                cmd += ", 'startStyle', 'normal'";
            }

            if (( typeof properties.stopStyle != "undefined" ) && ( properties.stopStyle != null )) {
                cmd += ", 'stopStyle', '" + properties.stopStyle + "'";
            }
            else {
                cmd += ", 'stopStyle', 'normal'";
            }

        }

        cmd += " );";

        eval(cmd);
    };


    /**
     *
     */
    ormmaview.playVideo = function (URL, properties) {
        var cmd = "this.executeNativeCall( 'playVideo'";

        cmd += ", 'url', '" + URL + "'";

        if (properties != null) {

            if (( typeof properties.audio != "undefined" ) && ( properties.audio != null )) {
                cmd += ", 'audioMuted', 'Y'";
            }
            else {
                cmd += ", 'audioMuted', 'N'";
            }

            if (( typeof properties.autoplay != "undefined" ) && ( properties.autoplay != null )) {
                cmd += ", 'autoplay', 'Y'";
            }
            else {
                cmd += ", 'autoplay', 'N'";
            }

            if (( typeof properties.controls != "undefined" ) && ( properties.controls != null )) {
                cmd += ", 'controls', 'Y'";
            }
            else {
                cmd += ", 'controls', 'N'";
            }

            if (( typeof properties.loop != "undefined" ) && ( properties.loop != null )) {
                cmd += ", 'loop', 'Y'";
            }
            else {
                cmd += ", 'loop', 'N'";
            }

            if (( typeof properties.inline != "undefined" ) && ( properties.inline != null )) {
                cmd += ", 'position_top', '" + properties.inline.top + "'";
                cmd += ", 'position_left', '" + properties.inline.left + "'";

                if (( typeof properties.width != "undefined" ) && ( properties.width != null )) {
                    cmd += ", 'position_width', '" + properties.width + "'";
                }
                else {
                    //TODO ERROR
                }

                if (( typeof properties.height != "undefined" ) && ( properties.height != null )) {
                    cmd += ", 'position_height', '" + properties.height + "'";
                }
                else {
                    //TODO ERROR
                }
            }


            if (( typeof properties.startStyle != "undefined" ) && ( properties.startStyle != null )) {
                cmd += ", 'startStyle', '" + properties.startStyle + "'";
            }
            else {
                cmd += ", 'startStyle', 'normal'";
            }

            if (( typeof properties.stopStyle != "undefined" ) && ( properties.stopStyle != null )) {
                cmd += ", 'stopStyle', '" + properties.stopStyle + "'";
            }
            else {
                cmd += ", 'stopStyle', 'normal'";
            }

        }

        cmd += " );";

        eval(cmd);

    };


    /*****************************/
    /********** LEVEL 2 **********/
    /*****************************/

    /**
     *
     */
    ormmaview.createEvent = function (date, title, body) {
        ormmaview.createCalendarEvent({"start": date, "description": body, "summary": title});
    };

    ormmaview.createCalendarEvent = function(w3c_calendar_params) {
        var cmd = "this.executeNativeCall( 'createCalendarEvent'";

        if ((typeof w3c_calendar_params.id != "undefined") && w3c_calendar_params.id != null) {
            cmd += ", 'id', '" + this.addslashes(w3c_calendar_params.id) + "'";
        }
        if ((typeof w3c_calendar_params.description != "undefined") && w3c_calendar_params.description != null) {
            cmd += ", 'description', '" + this.addslashes(w3c_calendar_params.description) + "'";
        }
        if ((typeof w3c_calendar_params.location != "undefined") && w3c_calendar_params.location != null) {
            cmd += ", 'location', '" + this.addslashes(w3c_calendar_params.location) + "'";
        }
        if ((typeof w3c_calendar_params.summary != "undefined") && w3c_calendar_params.summary != null) {
            cmd += ", 'summary', '" + this.addslashes(w3c_calendar_params.summary) + "'";
        }
        if ((typeof w3c_calendar_params.start != "undefined") && w3c_calendar_params.start != null) {
            cmd += ", 'start', '" + (w3c_calendar_params.start) + "'";
        }
        if ((typeof w3c_calendar_params.end != "undefined") && w3c_calendar_params.end != null) {
            cmd += ", 'end', '" + (w3c_calendar_params.end) + "'";
        }
        if ((typeof w3c_calendar_params.status != "undefined") && w3c_calendar_params.status != null) {
            cmd += ", 'status', '" + this.addslashes(w3c_calendar_params.status) + "'";
        }
        if ((typeof w3c_calendar_params.transparency != "undefined") && w3c_calendar_params.transparency != null) {
            cmd += ", 'transparency', '" + this.addslashes(w3c_calendar_params.transparency) + "'";
        }
        if ((typeof w3c_calendar_params.reminder != "undefined") && w3c_calendar_params.reminder != null) {
            cmd += ", 'reminder', '" + this.addslashes(w3c_calendar_params.reminder) + "'";
        }

        if ((typeof w3c_calendar_params.recurrence != "undefined") && w3c_calendar_params.recurrence != null) {
            if ((typeof w3c_calendar_params.recurrence.frequency != "undefined") && w3c_calendar_params.recurrence.frequency != null) {
                cmd += ", 'recurrence.frequency', '" + this.addslashes(w3c_calendar_params.recurrence.frequency) + "'";
            }
            if ((typeof w3c_calendar_params.recurrence.interval != "undefined") && w3c_calendar_params.recurrence.interval != null) {
                cmd += ", 'recurrence.interval', '" + this.addslashes(w3c_calendar_params.recurrence.interval) + "'";
            }
            if ((typeof w3c_calendar_params.recurrence.expires != "undefined") && w3c_calendar_params.recurrence.expires != null) {
                cmd += ", 'recurrence.expires', '" + this.addslashes(w3c_calendar_params.recurrence.expires) + "'";
            }
            if ((typeof w3c_calendar_params.recurrence.exceptionDates != "undefined") && w3c_calendar_params.recurrence.exceptionDates != null) {
                var arrayOfExceptionDates = this.addslashes(stringify(w3c_calendar_params.recurrence.exceptionDates));
                cmd += ", 'recurrence.exceptionDates', '" + arrayOfExceptionDates + "'";
            }
            if ((typeof w3c_calendar_params.recurrence.daysInWeek != "undefined") && w3c_calendar_params.recurrence.daysInWeek != null) {
                var arrayOfDaysInWeek = this.addslashes(stringify(w3c_calendar_params.recurrence.daysInWeek));
                cmd += ", 'recurrence.daysInWeek', '" + arrayOfDaysInWeek + "'";
            }
            if ((typeof w3c_calendar_params.recurrence.daysInMonth != "undefined") && w3c_calendar_params.recurrence.daysInMonth != null) {
                var arrayOfDaysInMonth = this.addslashes(stringify(w3c_calendar_params.recurrence.daysInMonth));
                cmd += ", 'recurrence.daysInMonth', '" + arrayOfDaysInMonth + "'";
            }
            if ((typeof w3c_calendar_params.recurrence.daysInYear != "undefined") && w3c_calendar_params.recurrence.daysInYear != null) {
                var arrayOfDaysInYear = this.addslashes(stringify(w3c_calendar_params.recurrence.daysInYear));
                cmd += ", 'recurrence.daysInYear', '" + arrayOfDaysInYear + "'";
            }
            if ((typeof w3c_calendar_params.recurrence.weeksInMonth != "undefined") && w3c_calendar_params.recurrence.weeksInMonth != null) {
                var arrayOfWeeksInMonth = this.addslashes(stringify(w3c_calendar_params.recurrence.weeksInMonth));
                cmd += ", 'recurrence.weeksInMonth', '" + arrayOfWeeksInMonth + "'";
            }
            if ((typeof w3c_calendar_params.recurrence.monthsInYear != "undefined") && w3c_calendar_params.recurrence.monthsInYear != null) {
                var arrayOfMonthsInYear = this.addslashes(stringify(w3c_calendar_params.recurrence.monthsInYear));
                cmd += ", 'recurrence.monthsInYear', '" + arrayOfMonthsInYear + "'";
            }
        }

        cmd += " );";

        eval(cmd);
    }

    /**
     *
     */
    ormmaview.makeCall = function (phoneNumber) {
        this.executeNativeCall("phone",
            "number", phoneNumber);
    };


    /**
     *
     */
    ormmaview.sendMail = function (recipient, subject, body) {
        this.executeNativeCall("email",
            "to", recipient,
            "subject", subject,
            "body", body,
            "html", "N");
    };


    /**
     *
     */
    ormmaview.sendSMS = function (recipient, body) {
        this.executeNativeCall("sms",
            "to", recipient,
            "body", body);
    };

    ormmaview.getShakeProperties = function () {
        return shakeProperties;
    };

    ormmaview.setShakeProperties = function (properties) {
        shakeProperties = properties;
    };

    /**
     *
     */
    ormmaview.storePicture = function (URL) {
        this.executeNativeCall("storePicture",
            "URL", URL
        );
    };

    /*****************************/
    /********** LEVEL 3 **********/
    /*****************************/

    /**
     *
     */
    ormmaview.addAsset = function (URL, alias) {
        this.executeNativeCall("addasset",
            "uri", url,
            "alias", alias);
    };


    /**
     *
     */
    ormmaview.request = function (URI, display) {
        this.executeNativeCall("request",
            "uri", uri,
            "display", display);
    };


    /**
     *
     */
    ormmaview.removeAsset = function (alias) {
        this.executeNativeCall("removeasset",
            "alias", alias);
    };

    ormmaview.hasCustomClose = function () {
        return ormmaview.getExpandProperties().useCustomClose;
    };
 
	ormmaview.notifyAdLoaded = function () {
		this.performCall("ormma://adloaded", false);
	};

    ormmaview.stringify = function (obj) {
        if (typeof obj == 'object') {
            if (obj.push) {
                var out = [];
                for (var p = 0; p < obj.length; p++) {
                    out.push(obj[p]);
                }
                return'[' + out.join(',') + ']';
            } else {
                var out = [];
                for (var p in obj) {
                    out.push('\'' + p + '\': ' + obj[p]);
                }
                return '{' + out.join(',') + '}';
            }
        } else {
            return String(obj);
        }
    };

})();

    ormmaview.addslashes = function (str) {
        // http://kevin.vanzonneveld.net
        // +   original by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
        // +   improved by: Ates Goral (http://magnetiq.com)
        // +   improved by: marrtins
        // +   improved by: Nate
        // +   improved by: Onno Marsman
        // +   input by: Denny Wardhana
        // +   improved by: Brett Zamir (http://brett-zamir.me)
        // +   improved by: Oskar Larsson Högfeldt (http://oskar-lh.name/)
        // *     example 1: addslashes("kevin's birthday");
        // *     returns 1: 'kevin\'s birthday'
        return (str + '').replace(/[\\"']/g, '\\$&').replace(/\u0000/g, '\\0').replace(/\n/g,'\\n').replace(/\t/g,'\\t');
    }

console = new Object();
console.log = function (log) {
    var iframe = document.createElement("IFRAME");
    iframe.setAttribute("src", "log://" + log);
    document.documentElement.appendChild(iframe);
    iframe.parentNode.removeChild(iframe);
    iframe = null;
}

console.error = function (error) {
    console.log('ERROR:' + error);
}

console.warn = function (val) {
    console.log('WARN:' + val);
}

console.debug = function (val) {
    console.log('DEBUG:' + val);
}

console.info = function (val) {
    console.log('INFO:' + val);
}


ormmaview.scriptFound = true;
