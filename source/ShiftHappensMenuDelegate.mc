import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
using Toybox.Application as App;

class ShiftHappensMenuDelegate extends WatchUi.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item as Symbol) as Void {
        if (item == :idSetPortWD) {
            System.println("idSetPortWD");
            var app = App.getApp();
            app.setWinddirFromCloseHauled(false);

        } else if (item == :idSetStarbWD) {
            System.println("idSetStarbWD");
            var app = App.getApp();
            app.setWinddirFromCloseHauled(true);
        }
    }

}