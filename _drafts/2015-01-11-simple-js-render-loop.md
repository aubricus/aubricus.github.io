---
layout: post
title: "A Simple JS Render Loop"
date: 2015-01-11 15:32:00
modified: 2015-01-11 15:32:00
category: projects
---

A recent experiment lead me to research a basic, Javascript render loop.

I am not a game developer by trade so I've never really attempted this in Javascript; though I've had some experience with render loops working with other platforms.

The subject is [ well documented ](#further-reading), but I thought a blog post would help solidify my understanding and, if I'm extremely fortunate, may prove useful to someone else.

For those uninitiated, a Render Loop is a common pattern in game development to decouple the passage of game time from input and processor speed. [^1]
{: .notice}

First, a very simple example of a Render Loop.

{% highlight js %}

while(true) {
    // 1. process user input
    // 2. update logic
    // 3. redraw
}

{% endhighlight %}

Look familiar? Not much to see here. There's just one problem. This is an infinite loop. Unfortunately this will block the Javascript thread and prevent the browser from executing it's own repaint cycle.

That's typically a bad thing, unless your goal is to lock up the entire browser.

So what can we do?

### Using SetInterval

A simple method to accomplish this lies with __setInterval__.

{% highlight javascript %}

var frequency = 1000 / 60; // roughly 60x a second

var App = {

    frameId: -1,

    run: function() {
        // 1. process user input
        // 2. update logic
        // 3. redraw
    }
}

App.frameId = setInteraval(App.run, frequency);

// canceling the loop looks like:

clearInterval(App.frameId);
App.frameId = -1;

{% endhighlight %}

A very simple technique leveraging the [unique characteristics of setInterval][JS Timers] and not all that more complicated than our original __while__ loop.

Check out [Arthur Schreiber's Article][JS Game Loop Alt] for an alternate implementation that decouples the update and redraw processes.
{: .notice}

Not a bad start. We could probably stop there. But I think we can optimize this technique even further.

Remember, Javascript is coupled to the browser which already runs a it's own render loop and redraw cycle. Any code we write is running on top of those processes.

Wouldn't it be great if we could, somehow, hook into that process?

### Enter RequestAnimationFrame

With __RequestAnimationFrame__ we can. Luckily this implementation is very close to __setInterval__ and __setTimeout__.

{% highlight javascript %}

var App = {

    id: -1,

    run: function() {
        // 1. process user input
        // 2. update logic
        // 3. redraw
    }
}

function animLoop(){
    // browser prefixes notwithstanding:
    App.id = requestAnimationFrame(animLoop);
    App.run();
};

// initial call to get things started
animLoop();

{% endhighlight %}

__RequestAnimationFrame__ allows us to hook right in to the browser rendering process allowing the browser to perform optimization not possible with __setInterval__.

There's a bit of recursive magic here because __RequestAnimationFrame__ only executes the callback once, a lot like __setTimeout__. To handle this, first schedule the next frame, assigning __animLoop__ as the callback, and then call the render process.

You can checkout [Paul Irish's Article][Paul Irish RAF] for more details on __RequestAnimationFrame__.
{: .notice}

<!-- TODO: Create codepen / add link -->

### Further Reading

- [Understanding Javascript Timers][JS Timers]
- [Game Loop Programming Pattern][Game Loop]
- [Paul Irish's Take on RequestAnimationFrame][Paul Irish RAF]
- [Another Example of a Javascript Game Loop][JS Game Loop]

<small>Footnotes</small>:

[^1]: [A great article on the Render Loop Pattern][Game Loop]

<!-- Reference Links -->

[Game Loop]: http://gameprogrammingpatterns.com/game-loop.html
[JS Timers]: http://ejohn.org/blog/how-javascript-timers-work/
[JS Game Loop]: http://nokarma.org/2011/02/02/javascript-game-development-the-game-loop/index.html
[JS Game Loop Alt]: http://nokarma.org/2011/02/02/javascript-game-development-the-game-loop/index.html#thats_it
[Paul Irish RAF]: http://www.paulirish.com/2011/requestanimationframe-for-smart-animating/
[NoKarma.org]: http://nokarma.org/about.html
[Demo Codepen]: http://example.com <!-- Check  -->
