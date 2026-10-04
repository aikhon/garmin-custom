import Toybox.ActivityMonitor;
import Toybox.Lang;
import Toybox.SensorHistory;
import Toybox.System;
import Toybox.Time;

class FaceData {
    var stepCount as Number or Null = null;
    var heartRate as Number or Null = null;
    var batteryLevel as Number or Float or Null = null;

    function initialize() {}

    function refresh() as Void {
        batteryLevel = System.getSystemStats().battery;
        stepCount = System.getDeviceSettings().activityTrackingOn ? ActivityMonitor.getInfo().steps : null;
        heartRate = null;
        if ((Toybox has :SensorHistory) && (SensorHistory has :getHeartRateHistory)) {
            // Read recorded samples; never turn the sensor on. Avoid showing stale HR.
            var iterator = SensorHistory.getHeartRateHistory({
                :period => new Time.Duration(300),
                :order => SensorHistory.ORDER_NEWEST_FIRST
            });
            var sample = iterator.next();
            while (sample != null) {
                if (sample.data != null && sample.data > 0) {
                    heartRate = sample.data.toNumber();
                    break;
                }
                sample = iterator.next();
            }
        }
    }
}
