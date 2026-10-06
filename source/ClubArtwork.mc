import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// Shared brand colors and the supplied club logo. The resource compiler scales
// the original PNG while retaining its black ink and transparency.
module ClubArtwork {
    const ACCENT = 0xCCFC00;
    const BACKGROUND = 0xCCFC00;
    const FOREGROUND = 0x000000;
    const MUTED = 0x333333;

    function draw(dc as Graphics.Dc, width as Number, logo as WatchUi.BitmapResource) as Void {
        var s = width / 260.0;
        dc.drawBitmap((width-logo.getWidth())/2, 200*s-logo.getHeight()/2, logo);
    }
}
