import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

class RunclubView extends WatchUi.WatchFace {
    private var _sleeping as Boolean = false;
    private var _amoled as Boolean = false;
    private var _data as FaceData;
    private var _lastMinute as Number = -1;
    private var _s as Number = 0;
    private var _left as Numeric = 0;
    private var _top as Numeric = 0;
    private var _logo as WatchUi.BitmapResource;
    private var _sleepLogo as WatchUi.BitmapResource;
    private var _skyline as WatchUi.BitmapResource;
    private var _topography as WatchUi.BitmapResource;
    private var _icons as Array<WatchUi.BitmapResource>;
    private var _filled as Graphics.FontType;
    private var _outline as Graphics.FontType;
    private var _ui as Graphics.FontType;
    private var _bold as Graphics.FontType;
    private var _label as Graphics.FontType;

    function initialize() {
        WatchFace.initialize();
        _data = new FaceData();
        _amoled = DisplayProfile.AMOLED;
        // All static resources are loaded once and held for the view's lifetime.
        _logo = WatchUi.loadResource(Rez.Drawables.ClubLogo) as WatchUi.BitmapResource;
        _sleepLogo = WatchUi.loadResource(Rez.Drawables.SleepLogo) as WatchUi.BitmapResource;
        _skyline = WatchUi.loadResource(Rez.Drawables.Skyline) as WatchUi.BitmapResource;
        _topography = WatchUi.loadResource(Rez.Drawables.Topography) as WatchUi.BitmapResource;
        _icons = [WatchUi.loadResource(Rez.Drawables.StepsIcon) as WatchUi.BitmapResource,
                  WatchUi.loadResource(Rez.Drawables.DistanceIcon) as WatchUi.BitmapResource,
                  WatchUi.loadResource(Rez.Drawables.HeartIcon) as WatchUi.BitmapResource];
        _filled = WatchUi.loadResource(Rez.Fonts.TimeFilled) as WatchUi.FontResource;
        _outline = WatchUi.loadResource(Rez.Fonts.TimeOutline) as WatchUi.FontResource;
        _ui = WatchUi.loadResource(Rez.Fonts.UiSemiBold) as WatchUi.FontResource;
        _bold = WatchUi.loadResource(Rez.Fonts.UiBold) as WatchUi.FontResource;
        _label = WatchUi.loadResource(Rez.Fonts.UiLabel) as WatchUi.FontResource;
    }

    function onShow() as Void { _lastMinute = -1; }
    function onLayout(dc as Graphics.Dc) as Void {
        _s = dc.getWidth() < dc.getHeight() ? dc.getWidth() : dc.getHeight();
        _left = (dc.getWidth()-_s)/2;
        _top = (dc.getHeight()-_s)/2;
        _lastMinute = -1;
    }
    function onEnterSleep() as Void { _sleeping = true; WatchUi.requestUpdate(); }
    function onExitSleep() as Void { _sleeping = false; _lastMinute = -1; WatchUi.requestUpdate(); }

    function onUpdate(dc as Graphics.Dc) as Void {
        if (_s == 0) { onLayout(dc); }
        var now = Time.now();
        var minute = (now.value()/60).toNumber();
        var clock = System.getClockTime();
        var is24 = System.getDeviceSettings().is24Hour;
        var timeText = FaceFormat.time(clock.hour, clock.min, is24);
        var date = Gregorian.info(now, Time.FORMAT_SHORT);
        var days = ["SUN","MON","TUE","WED","THU","FRI","SAT"];
        var months = ["JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC"];
        var day = days[(date.day_of_week as Number)-1];
        var rest = date.day.format("%02d") + " " + months[(date.month as Number)-1];
        dc.setColor(DesignTokens.WHITE, DesignTokens.BACKGROUND);
        dc.clear();
        if (_sleeping) {
            drawSleep(dc, timeText, day+" "+rest, minute);
            return;
        }
        if (_lastMinute != minute) { _data.refresh(); _lastMinute = minute; }

        dc.drawBitmap(_left, _top, _topography);
        // Masks keep contour lines out of primary type and club branding.
        dc.setColor(DesignTokens.BACKGROUND, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x(0.22),y(0.035),_s*0.56,_s*0.13);
        dc.fillRectangle(x(0.10),y(0.17),_s*0.80,_s*0.38);
        dc.fillRectangle(x(0.0),y(0.70),_s,_s*0.30);
        drawStatusRow(dc, day, rest, is24 ? "" : (clock.hour < 12 ? " AM" : " PM"));
        drawHero(dc, timeText);

        var steps = _data.stepCount;
        var distance = _data.distanceCm;
        var hr = _data.heartRate;
        var stepProgress = steps == null ? 0.0 : steps.toFloat()/_data.stepGoal;
        var distanceProgress = distance == null ? 0.0 : distance.toFloat()/100000.0/DesignTokens.DISTANCE_GAUGE_KM;
        var heartProgress = hr == null ? 0.0 : hr.toFloat()/DesignTokens.HEART_GAUGE_MAX;
        metric(dc,0,0.24,FaceFormat.steps(steps),"STEPS",stepProgress);
        metric(dc,1,0.50,FaceFormat.distance(distance),"KM",distanceProgress);
        metric(dc,2,0.76,FaceFormat.heart(hr),"BPM",heartProgress);
        drawBrand(dc);
        dc.drawBitmap(x(0.5)-_skyline.getWidth()/2,
            y(1.0)-_skyline.getHeight()*DesignTokens.SKYLINE_BASELINE,_skyline);
    }

    private function x(r as Numeric) as Numeric { return _left+_s*r; }
    private function y(r as Numeric) as Numeric { return _top+_s*r; }

    private function drawHero(dc as Graphics.Dc, text as String) as Void {
        var hours = text.substring(0,text.length()-2) as String;
        var minutes = text.substring(text.length()-2,text.length()) as String;
        var leftWidth = dc.getTextWidthInPixels(hours,_filled);
        var rightWidth = dc.getTextWidthInPixels(minutes,_outline);
        var start = x(0.5)-(leftWidth+rightWidth)/2;
        dc.setColor(DesignTokens.LIME,Graphics.COLOR_TRANSPARENT);
        dc.drawText(start,y(DesignTokens.TIME_Y),_filled,hours,Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(DesignTokens.WHITE,Graphics.COLOR_TRANSPARENT);
        dc.drawText(start+leftWidth,y(DesignTokens.TIME_Y),_outline,minutes,Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function drawStatusRow(dc as Graphics.Dc, day as String, rest as String, meridiem as String) as Void {
        var value = _data.batteryLevel;
        var batteryText = (value == null ? "--" : FaceFormat.battery(value))+meridiem;
        var batteryWidth = _s*0.067+dc.getTextWidthInPixels(batteryText,_ui);
        var dateWidth = dc.getTextWidthInPixels(day+" "+rest,_ui);
        var gap = _s*0.035;
        var start = x(0.5)-(batteryWidth+gap+dateWidth)/2;
        drawBattery(dc,batteryText,start);
        drawDate(dc,day,rest,start+batteryWidth+gap);
    }

    private function drawDate(dc as Graphics.Dc, day as String, rest as String, start as Numeric) as Void {
        var a = day+" ";
        var width = dc.getTextWidthInPixels(a,_ui);
        dc.setColor(DesignTokens.LIME,Graphics.COLOR_TRANSPARENT);
        dc.drawText(start,y(DesignTokens.STATUS_ROW_Y),_ui,a,Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(DesignTokens.WHITE,Graphics.COLOR_TRANSPARENT);
        dc.drawText(start+width,y(DesignTokens.STATUS_ROW_Y),_ui,rest,Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function drawBattery(dc as Graphics.Dc, batteryText as String, start as Numeric) as Void {
        var value = _data.batteryLevel;
        var w = _s*0.052;
        var h = _s*0.023;
        var gap = _s*0.015;
        var top = y(DesignTokens.STATUS_ROW_Y)-h/2;
        dc.setPenWidth(1);
        dc.setColor(DesignTokens.WHITE,Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(start,top,w,h);
        dc.fillRectangle(start+w,top+h*0.3,_s*0.006,h*0.4);
        if (value != null && value > 0) {
            var progress = value.toFloat()/100;
            if (progress > 1) { progress = 1.0; }
            dc.setColor(DesignTokens.LIME,Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(start+2,top+2,(w-4)*progress,h-4);
        }
        dc.setColor(DesignTokens.WHITE,Graphics.COLOR_TRANSPARENT);
        dc.drawText(start+w+gap,y(DesignTokens.STATUS_ROW_Y),_ui,batteryText,Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function metric(dc as Graphics.Dc, index as Number, center as Float, value as String, unit as String, progress as Float) as Void {
        if (progress < 0) { progress = 0.0; }
        if (progress > 1) { progress = 1.0; }
        var cx = x(center);
        var cy = y(DesignTokens.METRICS_Y);
        var radius = _s*DesignTokens.METRIC_RADIUS;
        dc.setColor(DesignTokens.BACKGROUND,Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(cx,cy,radius);
        var stroke = (5*_s/454.0).toNumber();
        if (stroke < 2) { stroke = 2; }
        dc.setPenWidth(stroke);
        dc.setColor(DesignTokens.GRAPHITE,Graphics.COLOR_TRANSPARENT);
        dc.drawArc(cx,cy,radius,Graphics.ARC_CLOCKWISE,225,315);
        if (progress > 0) {
            dc.setColor(DesignTokens.LIME,Graphics.COLOR_TRANSPARENT);
            dc.drawArc(cx,cy,radius,Graphics.ARC_CLOCKWISE,225,(225-270*progress+360).toNumber()%360);
        }
        dc.setPenWidth(1);
        var icon = _icons[index];
        dc.drawBitmap(cx-icon.getWidth()/2,y(DesignTokens.METRIC_ICON_Y)-icon.getHeight()/2,icon);
        var font = _bold;
        if (dc.getTextWidthInPixels(value,font) > _s*0.155) { font = _ui; }
        if (dc.getTextWidthInPixels(value,font) > _s*0.155) { font = _label; }
        text(dc,value,cx,y(DesignTokens.METRIC_VALUE_Y),font,DesignTokens.WHITE);
        text(dc,unit,cx,y(DesignTokens.METRIC_UNIT_Y),_label,DesignTokens.SECONDARY);
    }

    private function drawBrand(dc as Graphics.Dc) as Void {
        drawLogo(dc,_logo,DesignTokens.LOGO_Y);
    }

    private function drawLogo(dc as Graphics.Dc, logo as WatchUi.BitmapResource, centerY as Numeric) as Void {
        var w = logo.getWidth();
        var h = logo.getHeight();
        var left = x(0.5)-w/2;
        var top = y(centerY)-h/2;
        dc.drawBitmap(left,top,logo);
        // Remove the embedded EST text while preserving the original logo.
        dc.setColor(DesignTokens.BACKGROUND,Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(left+w*899/1440.0,top+h*287/481.0,w*203/1440.0,h*44/481.0);
    }

    private function drawSleep(dc as Graphics.Dc, clock as String, date as String, minute as Number) as Void {
        if (!_amoled) {
            // MIP has no AMOLED pixel budget: retain a large readable clock.
            text(dc,date,x(0.5),y(DesignTokens.STATUS_ROW_Y),_ui,DesignTokens.SECONDARY);
            drawHero(dc,clock);
            drawLogo(dc,_sleepLogo,DesignTokens.LOGO_Y);
            return;
        }
        // Four non-overlapping bands on AMOLED. Text and logo pixels get three
        // minutes of rest between appearances. MIP uses a static centered group.
        var center = 0.235+(minute%4)*0.17;
        drawLogo(dc,_sleepLogo,center-0.060);
        text(dc,clock,x(0.5),y(center-0.005),_bold,DesignTokens.SECONDARY);
        text(dc,date,x(0.5),y(center+0.045),_label,DesignTokens.SECONDARY);
    }

    private function text(dc as Graphics.Dc, value as String, px as Numeric, py as Numeric, font as Graphics.FontType, color as Number) as Void {
        dc.setColor(color,Graphics.COLOR_TRANSPARENT);
        dc.drawText(px,py,font,value,Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}
