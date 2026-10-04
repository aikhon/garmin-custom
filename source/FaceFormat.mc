import Toybox.Lang;

// Pure formatting helpers are also used by simulator unit tests.
module FaceFormat {
    function time(hour as Number, minute as Number, is24 as Boolean) as String {
        var h = hour;
        if (!is24) {
            h = hour % 12;
            if (h == 0) { h = 12; }
        }
        return h.format(is24 ? "%02d" : "%d") + ":" + minute.format("%02d");
    }

    function steps(value as Number or Null) as String {
        if (value == null || value < 0) { return "--"; }
        if (value < 1000) { return value.toString(); }
        if (value < 100000) {
            return (value / 1000).toNumber().toString() + "," + (value % 1000).format("%03d");
        }
        return (value / 1000).toNumber().toString() + "k";
    }

    function heart(value as Number or Null) as String {
        return (value == null || value <= 0) ? "--" : value.toString();
    }

    function battery(value as Number or Float or Null) as String {
        if (value == null) { return "--%"; }
        var percent = value.toNumber();
        if (percent < 0) { percent = 0; }
        if (percent > 100) { percent = 100; }
        return percent.toString() + "%";
    }
}
