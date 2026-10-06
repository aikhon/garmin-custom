import Toybox.Test;
import Toybox.Lang;

(:test)
function timeBoundaries(logger as Test.Logger) as Boolean {
    Test.assertEqual(FaceFormat.time(0, 0, true), "00:00");
    Test.assertEqual(FaceFormat.time(0, 5, false), "12:05");
    Test.assertEqual(FaceFormat.time(12, 0, false), "12:00");
    Test.assertEqual(FaceFormat.time(23, 59, false), "11:59");
    Test.assertEqual(FaceFormat.time(23, 59, true), "23:59");
    return true;
}

(:test)
function missingAndLargeData(logger as Test.Logger) as Boolean {
    Test.assertEqual(FaceFormat.steps(null), "--");
    Test.assertEqual(FaceFormat.steps(0), "0");
    Test.assertEqual(FaceFormat.steps(999), "999");
    Test.assertEqual(FaceFormat.steps(1000), "1,000");
    Test.assertEqual(FaceFormat.steps(10005), "10,005");
    Test.assertEqual(FaceFormat.steps(99999), "99,999");
    Test.assertEqual(FaceFormat.steps(100000), "100k");
    Test.assertEqual(FaceFormat.heart(null), "--");
    Test.assertEqual(FaceFormat.heart(0), "--");
    Test.assertEqual(FaceFormat.heart(85), "85");
    Test.assertEqual(FaceFormat.battery(null), "--%");
    Test.assertEqual(FaceFormat.battery(0), "0%");
    Test.assertEqual(FaceFormat.battery(99.9), "99%");
    Test.assertEqual(FaceFormat.battery(101), "100%");
    return true;
}
