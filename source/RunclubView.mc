import Toybox.Application;
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
    private var _club as String;
    private var _tagline as String;
    private var _stepsLabel as String;
    private var _heartLabel as String;

    function initialize() {
        WatchFace.initialize();
        _data = new FaceData();
        _amoled = Application.Properties.getValue("amoled") as Boolean;
        _club = WatchUi.loadResource(Rez.Strings.ClubName) as String;
        _tagline = WatchUi.loadResource(Rez.Strings.ClubTagline) as String;
        _stepsLabel = WatchUi.loadResource(Rez.Strings.StepsLabel) as String;
        _heartLabel = WatchUi.loadResource(Rez.Strings.HeartLabel) as String;
    }

    function onShow() as Void { _lastMinute = -1; }
    function onLayout(dc as Graphics.Dc) as Void { _lastMinute = -1; }
    function onEnterSleep() as Void {
        _sleeping = true;
        WatchUi.requestUpdate();
    }
    function onExitSleep() as Void {
        _sleeping = false;
        _lastMinute = -1;
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var now = Time.now();
        var minute = (now.value() / 60).toNumber();
        var clock = System.getClockTime();
        var settings = System.getDeviceSettings();
        var timeText = FaceFormat.time(clock.hour, clock.min, settings.is24Hour);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        if (_sleeping && _amoled) {
            drawAlwaysOn(dc, timeText, minute, settings.is24Hour, clock.hour);
            return;
        }
        if (_lastMinute != minute) {
            _data.refresh();
            _lastMinute = minute;
        }

        var w = dc.getWidth();
        var s = w / 260.0;
        var date = Gregorian.info(now, Time.FORMAT_MEDIUM);
        var topLine = FaceFormat.battery(_data.batteryLevel);
        if (!settings.is24Hour) { topLine += clock.hour < 12 ? " / AM" : " / PM"; }
        label(dc, topLine, w/2, 23*s, Graphics.FONT_XTINY, ClubArtwork.MUTED, 110*s);
        label(dc, (date.day_of_week as String).toUpper() + " " + date.day.format("%02d") + " " + (date.month as String).toUpper(),
            w/2, 48*s, Graphics.FONT_XTINY, ClubArtwork.ACCENT, 170*s);
        label(dc, timeText, w/2, 84*s, Graphics.FONT_NUMBER_THAI_HOT, ClubArtwork.WHITE, 218*s);
        label(dc, FaceFormat.steps(_data.stepCount), 82*s, 135*s, Graphics.FONT_SMALL, ClubArtwork.WHITE, 100*s);
        label(dc, FaceFormat.heart(_data.heartRate), 179*s, 135*s, Graphics.FONT_SMALL, ClubArtwork.WHITE, 70*s);
        label(dc, _stepsLabel, 82*s, 153*s, Graphics.FONT_XTINY, ClubArtwork.MUTED, 85*s);
        label(dc, _heartLabel, 179*s, 153*s, Graphics.FONT_XTINY, ClubArtwork.MUTED, 65*s);
        dc.setColor(0x335555, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(130*s, 125*s, 130*s, 151*s);
        ClubArtwork.draw(dc, w);
        label(dc, _club, w/2, 228*s, Graphics.FONT_SMALL, ClubArtwork.ACCENT, 140*s);
        // Small MIP screens get only the main club name to preserve readability.
        if (w >= 390) {
            label(dc, _tagline, w/2, 245*s, Graphics.FONT_XTINY, ClubArtwork.MUTED, 110*s);
        }
    }

    private function drawAlwaysOn(dc as Graphics.Dc, text as String, minute as Number, is24 as Boolean, hour as Number) as Void {
        var w = dc.getWidth();
        // Four disjoint horizontal bands. Each pixel rests for three minutes;
        // small system fonts keep lit area well below 10% of the round screen.
        var band = minute % 4;
        var y = (dc.getHeight() * (0.26 + band * 0.16)).toNumber();
        var displayText = text;
        if (!is24) { displayText += hour < 12 ? " AM" : " PM"; }
        var font = Graphics.FONT_SMALL;
        if (dc.getFontHeight(font) > w * 0.12) { font = Graphics.FONT_XTINY; }
        label(dc, displayText, w/2, y, font, 0x999999, w*0.65);
    }

    private function label(dc as Graphics.Dc, text as String, x as Numeric, y as Numeric, font as Graphics.FontType,
        color as Number, maxWidth as Numeric) as Void {
        var actualFont = font;
        if (font == Graphics.FONT_NUMBER_THAI_HOT) {
            if (dc.getTextWidthInPixels(text, actualFont) > maxWidth || dc.getFontHeight(actualFont) > dc.getHeight()*0.24) {
                actualFont = Graphics.FONT_NUMBER_HOT;
            }
            if (dc.getTextWidthInPixels(text, actualFont) > maxWidth || dc.getFontHeight(actualFont) > dc.getHeight()*0.24) {
                actualFont = Graphics.FONT_NUMBER_MEDIUM;
            }
        }
        if (dc.getTextWidthInPixels(text, actualFont) > maxWidth) {
            actualFont = Graphics.FONT_SMALL;
        }
        if (dc.getTextWidthInPixels(text, actualFont) > maxWidth) {
            actualFont = Graphics.FONT_XTINY;
        }
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, actualFont, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}
