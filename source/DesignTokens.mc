module DesignTokens {
    const PRIMARY = 0xCCFF00;
    const SECONDARY = 0x000000;
    const BACKGROUND = PRIMARY;
    const FOREGROUND = SECONDARY;
    const GAUGE_TRACK = 0x99BB00;
    // AMOLED sleep keeps a separate, sparse palette to limit lit pixels.
    const SLEEP_BACKGROUND = 0x000000;
    const SLEEP_FOREGROUND = 0xBEBEBE;
    const LOGO_Y = 0.105;
    const STATUS_ROW_Y = 0.23;
    const TIME_Y = 0.400;
    const METRICS_Y = 0.645;
    const METRIC_RADIUS = 0.084;
    const METRIC_ICON_Y = 0.595;
    const METRIC_VALUE_Y = 0.656;
    const METRIC_UNIT_Y = 0.706;
    // The supplied PNG has transparent space below its ground line.
    // Align that ground line to the screen bottom; deliberately crop the sides.
    const SKYLINE_BASELINE = 658.0 / 724.0;
    const DISTANCE_GAUGE_KM = 5.0;
    const HEART_GAUGE_MAX = 200.0;
}
