import Toybox.Graphics;
import Toybox.Lang;

// Self-contained placeholder artwork. Replace draw() with club bitmap resources
// later; all time/data rendering remains in RunclubView.
module ClubArtwork {
    const ACCENT = 0x55DDCC;
    const MUTED = 0x99AAAA;
    const WHITE = 0xFFFFFF;

    function draw(dc as Graphics.Dc, width as Number) as Void {
        var s = width / 260.0;
        dc.setColor(0x115544, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(42*s, 167*s, 176*s, 49*s, 24*s);
        dc.setPenWidth(1);
        dc.setColor(ACCENT, Graphics.COLOR_TRANSPARENT);
        for (var lane = 0; lane < 3; lane += 1) {
            var inset = lane * 6;
            dc.drawRoundedRectangle((46+inset)*s, (171+inset)*s,
                (168-inset*2)*s, (41-inset*2)*s, (20-inset)*s);
        }
        // Two runners, an original scalable line illustration.
        runner(dc, 112*s, 190*s, s, WHITE);
        runner(dc, 148*s, 186*s, s, ACCENT);
        dc.setPenWidth(1);
    }

    function runner(dc as Graphics.Dc, x as Float, y as Float, s as Float, color as Number) as Void {
        dc.setColor(0x115544, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x-13*s, y-16*s, 29*s, 31*s);
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth((2*s).toNumber());
        dc.fillCircle(x+3*s, y-12*s, 3*s);
        dc.drawLine(x+1*s,y-7*s, x-3*s,y+3*s);
        dc.drawLine(x,y-6*s, x+8*s,y-1*s);
        dc.drawLine(x+8*s,y-1*s, x+13*s,y-6*s);
        dc.drawLine(x,y-6*s, x-7*s,y-7*s);
        dc.drawLine(x-7*s,y-7*s, x-11*s,y-1*s);
        dc.drawLine(x-3*s,y+3*s, x+5*s,y+8*s);
        dc.drawLine(x+5*s,y+8*s, x+9*s,y+15*s);
        dc.drawLine(x-3*s,y+3*s, x-8*s,y+12*s);
        dc.drawLine(x-8*s,y+12*s, x-16*s,y+12*s);
    }
}
