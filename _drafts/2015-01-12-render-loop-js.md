---
layout: post
title: "RenderLoopJS"
date: 2015-01-12 16:32:00
modified: 2015-01-11 15:32:00
category: projects
excerpt: So far we have a nice render loop implementation that emulates a continuous loop (without blocking the UI) nicely integrated into the native browser render cycle. But I think we can make this more portable.
---

### If You Missed it...

Check out the [first part of this post][RenderLoop JS Pt 1] where I go over the basics that inspired this example.

### Making it reusable

So far we have a nice render loop implementation that emulates a continuous loop (without blocking the UI) nicely integrated into the native browser render cycle.

I think it's time to create an implementation that's a bit more portable!

{% highlight javascript %}

// ----------------------------------------- //
// RenderLoop constructor function
// ----------------------------------------- //

var RenderLoop = function() {
    this.wantsExecuteFrame = RenderLoop.getExecuteFrameMethod();
    this.wantsCancelExecuteFrame = RenderLoop.getCancelFrameMethod();

    // internal init
    this.initialize();
};

{% endhighlight %}

First, let's create a constructor. A call to __requestAnimationFrame__ may or may not be supported by a particular browser. So it's imperative to determine if the method is available and provide a fall back if not.

Normally I like to handle browser feature detection at the application level. For this example however, we'll couple this to the RenderLoop object by creating some static methods:

{% highlight javascript %}

// ----------------------------------------- //
// RenderLoop static methods
// ----------------------------------------- //

RenderLoop.getExecuteFrameFallbackMethod = function() {
    return function(callback) {

        var frequency = 1000 / 60; // match RAF 60* / second
        window.setTimeout(callback, frequency);
    }
};

RenderLoop.getCancelFrameFallbackMethod = function() {
    return window.cancelTimeout;
};

RenderLoop.getExecuteFrameMethod = function() {
    return Features.prefixed('requestAnimationFrame', window) || RenderLoop.getExecuteFrameFallbackMethod();
};

RenderLoop.getCancelFrameMethod = function() {
    return Features.prefixed('cancelAnimationFrame', window) || RenderLoop.getCancelFrameFallbackMethod();
};

{% endhighlight %}

This bit is a bit verbose, but what's happening here is simple. These methods simply clean up the feature detection logic and allow our constructor to do some setup work while keeping things light.

The RenderLoop instance selects a prefixed or un-prefixed implementation of __requestAnimationFrame__ or __cancelAnimationFrame__ if available. If not, we fall back to __setTimeout__, with a frequency of 60 frames per seconds, and __cancelTimeout__.

I'm using __setTimeout__ here because it more closely reproduces the __requestAnimationFrame__ API.
{: .notice}

Now, on to the meat of __RenderLoop__:

{% highlight javascript %}

// ----------------------------------------- //
// RenderLoop instance methods
// ----------------------------------------- //

RenderLoop.prototype = {
    _callback: false,
    frameId: -1,

    initialize: function(options) {
        if(options.callback) {
            this.setCallback(options.callback);
        }
    },

    setCallback: function(callback) {
        if(typeof callback != 'function') {
            var error = new Error('Error attempting to set RenderLoop._callback')
            error.name = 'MalformedTypeError';
            error.reason = 'RenderLoop._callback requires a funtion instance.'
            error.message = e.message + ': ' + error.reason;

            throw error;
        }
    },

    _loop: function() {
        // recursive call to _loop
        this.frameId = this.executeFrameMethod(this._loop.bind(this));
        this._callback();
    },

    start: function(callback) {
        if(callback) {
            this.setCallback(callback);
        }

        this.frameId = this.executeFrameMethod(this._loop.bind(this));
    },

    stop: function() {
        this.cancelFrameMethod(this.frameId);
        this.frameId = -1;
    },

    destroy: function() {
        this.stop();
        this._callback = null;
    }
};

{% endhighlight %}

The API we have here is pretty simple.

RenderLoop stores a reference to a supplied callback provided either through the constructor (via __initialize__), through __setCallback__, or passed directly to the __start__ method.

The __setCallback__ method is our public and internal setter for the internal `_callback` property and will throw an error if something other than a _function_ is passed in.

The __stop__ method is self-explanatory.

I've thrown in __destroy__ as a way to manage the reference to `_callback` and make sure we can clean up after ourselves.

The real meat of __RenderLoop__ happens in __start__ and the internal __loop__ methods.

The __start__ method takes an optional callback and, as you might have guessed, starts the render loop while recording the initial `frameId`.

{% highlight javascript %}

_loop: function() {
    // recursive call to _loop
    this.frameId = this.executeFrameMethod(this._loop.bind(this));
    this._callback();
},

start: function(callback) {
    if(callback) {
        this.setCallback(callback);
    }

    this.frameId = this.executeFrameMethod(this._loop.bind(this));
},

{% endhighlight %}
<small> For reference: The start and _loop methods </small>


The __loop__ method can be a bit confusing; if you're like me an recursive operations tend to be a bit tricky.

Notice that we first call the __executeFrameMethod__ in __start__, which passes in __loop__ as the callback. Unlike __setInterval__, __requestAnimationFrame only executes the assigned callback once; it's up to us to schedule the next frame.

This is where __loop__ comes in. It first schedules the next frame, assigning itself as the callback, and then executes the callback. This continues ad infinitum until someone calls the __stop__ method.

If you refer to the simpler example from [My Previous Post](RenderLoop Pt 1 Enter RAF); you'll see this is the exact same logic; albeit slightly rearranged.
{: .notice}

<!-- Reference Links -->

[RenderLoop Pt 1]: http://example.com <!-- TODO: add real url here -->
[RenderLoop Pt 1 Enter RAF]: http://example.com <!-- TODO: add real url here -->
