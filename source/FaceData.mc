import Toybox.ActivityMonitor;
import Toybox.Lang;
import Toybox.SensorHistory;
import Toybox.System;
import Toybox.Time;

class FaceData {
    var stepCount as Number or Null = null;
    var heartRate as Number or Null = null;
    var batteryLevel as Number or Float or Null = null;
    var distanceCm as Number or Null = null;
    var stepGoal as Number = 10000;

    function initialize() {}

    function refresh() as Void {
        batteryLevel = System.getSystemStats().battery;
        var activity = ActivityMonitor.getInfo();
        var tracking = System.getDeviceSettings().activityTrackingOn;
        stepCount = tracking ? activity.steps : null;
        distanceCm = tracking ? activity.distance : null;
        var goal = activity.stepGoal;
        stepGoal = (goal != null && goal > 0) ? goal : 10000;
        heartRate = null;
        if ((Toybox has :SensorHistory) && (SensorHistory has :getHeartRateHistory)) {
            // Read recorded samples; never turn the sensor on. Avoid showing stale HR.
            var iterator = SensorHistory.getHeartRateHistory({
                :period => new Time.Duration(300),
                :order => SensorHistory.ORDER_NEWEST_FIRST
            });
            var sample = iterator.next();
            while (sample != null) {
                var reading = sample.data;
                if (reading != null && reading > 0) {
                    heartRate = reading.toNumber();
                    break;
                }
                sample = iterator.next();
            }
        }
    }
}
