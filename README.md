RotaryControl
=============

RotaryControl started as a learning project for making a custom circular control.  The RotaryControlView class is a custom view for creating an interactable circular dial to select values ranging from 0-100%.  It gives you the ability to change the dial's look (color & size), it's max value, and it allows you to animate a percentage change.  The control is drawn entirely using Core Graphics.


The dial has a dead zone around 0% and 100% so that it's easy to stop rotating at the ends of the spectrum.  For instance, when sliding clockwise to 100%, you need to slide your finger a bit further past the 100% mark to get it to reset to 0%.  Same going counterclockwise to 0%.


The demo project here will create 2 rotary controls that are linked together, with one ranging from 0-100 and the other 0-255.


The demo view was created specifically for the iPhone 5 :)

![Alt text](/screenshot.png?raw=true "Example of 2 RotaryControlViews")
