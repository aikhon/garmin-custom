# Deterministic bitmap-font atlases and vector-drawn resources for Garmin.
# Original club media is never modified. Font files retain their OFL license.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.IO;
using System.Text;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Text;
public static class RunclubAssets {
 public static void FontAtlas(string fontFile,string folder,string name,int em,bool outline,string chars) {
  using(var fonts=new PrivateFontCollection()) {
   fonts.AddFontFile(fontFile); var family=fonts.Families[0];
   using(var all=new GraphicsPath()) {
    all.AddString(chars,family,0,em,new PointF(0,0),StringFormat.GenericTypographic);
    var bounds=all.GetBounds(); int pad=Math.Max(2,(int)Math.Ceiling(em/70.0));
    int h=(int)Math.Ceiling(bounds.Height)+2*pad, maxW=0;
    foreach(char c in chars) {if(c==' ')continue;using(var path=new GraphicsPath()){path.AddString(c.ToString(),family,0,em,new PointF(),StringFormat.GenericTypographic);maxW=Math.Max(maxW,(int)Math.Ceiling(path.GetBounds().Width));}}
    int cell=maxW+2*pad+2, cols=16, rows=(chars.Length+cols-1)/cols;
    using(var bmp=new Bitmap(cell*cols,h*rows)) using(var g=Graphics.FromImage(bmp)) {
     g.Clear(Color.Transparent);g.SmoothingMode=SmoothingMode.None;g.PixelOffsetMode=PixelOffsetMode.Half;
     var f=new StringBuilder();
     f.AppendLine("info face=\"Barlow Condensed\" size="+em+" bold=1 italic=0 charset=\"\" unicode=1 stretchH=100 smooth=0 aa=1 padding=0,0,0,0 spacing=0,0");
     f.AppendLine("common lineHeight="+h+" base="+(h-pad)+" scaleW="+bmp.Width+" scaleH="+bmp.Height+" pages=1 packed=0");
     f.AppendLine("page id=0 file=\""+name+".png\"");f.AppendLine("chars count="+chars.Length);
     for(int i=0;i<chars.Length;i++) {
      char c=chars[i];int x=(i%cols)*cell,y=(i/cols)*h,advance;
      using(var path=new GraphicsPath()) {
       if(c!=' ')path.AddString(c.ToString(),family,0,em,new PointF(),StringFormat.GenericTypographic);
       var b=path.GetBounds();advance=c==' '?Math.Max(3,em/5):(int)Math.Ceiling(b.Width)+2*pad;
       if(name.StartsWith("Time") && c!=':')advance=cell-2;
       if(!name.StartsWith("Time") && c!=' ')advance=(int)Math.Ceiling(b.Width)+Math.Max(1,(int)Math.Round(em/18.0));
       if(c!=' ') {
        using(var m=new Matrix()) {m.Translate(x+pad-b.X+(advance-2*pad-b.Width)/2,y+pad-bounds.Y);path.Transform(m);}
        if(outline) {using(var pen=new Pen(Color.White,Math.Max(1.5f,em/48f))){pen.LineJoin=LineJoin.Round;g.DrawPath(pen,path);}}
        else g.FillPath(Brushes.White,path);
       }
       f.AppendLine("char id="+(int)c+" x="+x+" y="+y+" width="+advance+" height="+h+" xoffset=0 yoffset=0 xadvance="+advance+" page=0 chnl=15");
      }
     }
     Directory.CreateDirectory(folder);bmp.Save(Path.Combine(folder,name+".png"),System.Drawing.Imaging.ImageFormat.Png);
     File.WriteAllText(Path.Combine(folder,name+".fnt"),f.ToString(),new UTF8Encoding(false));
    }
   }
  }
 }
 public static void Topography(string file,int s) {
  using(var bmp=new Bitmap(s,s))using(var g=Graphics.FromImage(bmp))using(var p=new Pen(Color.FromArgb(39,51,0),Math.Max(1,s/454f))) {
   g.Clear(Color.Black);g.SmoothingMode=SmoothingMode.None;
   for(int group=0;group<4;group++)for(int ring=0;ring<5;ring++) {
    var points=new PointF[81];double cx=(group%2==0?.06:.97)*s,cy=(group<2?.20:.80)*s;
    for(int i=0;i<points.Length;i++){double a=i*Math.PI*2/80,r=(.09+ring*.036)*s*(1+.12*Math.Sin(a*3+group)+.06*Math.Cos(a*5));points[i]=new PointF((float)(cx+Math.Cos(a)*r),(float)(cy+Math.Sin(a)*r*.85));}
    g.DrawLines(p,points);
   }
   bmp.Save(file,System.Drawing.Imaging.ImageFormat.Png);
  }
 }
 public static void Icon(string file,int size,string kind) {
  using(var bmp=new Bitmap(size,size))using(var g=Graphics.FromImage(bmp))using(var p=new Pen(Color.FromArgb(204,255,0),2)) {
   g.Clear(Color.Transparent);g.ScaleTransform(size/32f,size/32f);g.SmoothingMode=SmoothingMode.None;p.LineJoin=LineJoin.Round;
   if(kind=="steps") {
    g.DrawLines(p,new[]{new PointF(3,20),new PointF(6,8),new PointF(13,13),new PointF(20,16),new PointF(28,19),new PointF(29,24),new PointF(4,24),new PointF(3,20)});
    g.DrawLine(p,11,12,9,17);g.DrawLine(p,16,15,13,19);g.DrawLine(p,4,20,27,20);
   } else if(kind=="distance") {
    g.DrawEllipse(p,3,22,4,4);g.DrawLines(p,new[]{new PointF(7,24),new PointF(13,24),new PointF(13,15),new PointF(22,15)});
    using(var path=new GraphicsPath()){path.AddBezier(24,20,14,11,17,3,24,3);path.AddBezier(24,3,31,3,33,11,24,20);g.DrawPath(p,path);}g.DrawEllipse(p,22,7,4,4);
   } else {
    using(var path=new GraphicsPath()){path.AddBezier(16,27,4,18,0,12,5,6);path.AddBezier(5,6,9,2,13,5,16,9);path.AddBezier(16,9,19,5,23,2,27,6);path.AddBezier(27,6,32,12,28,18,16,27);g.DrawPath(p,path);}
   }
   bmp.Save(file,System.Drawing.Imaging.ImageFormat.Png);
  }
 }
}
'@
$root = Split-Path $PSScriptRoot -Parent
$uiCharacters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .:-/%K'
$uiCharacters = -join ($uiCharacters.ToCharArray() | Select-Object -Unique)
foreach ($target in @(@{Id='fr255';Size=260},@{Id='fr265';Size=416},@{Id='fr965';Size=454})) {
    $folder = Join-Path $root ('resources-' + $target.Id)
    $fonts = Join-Path $folder 'fonts'
    $drawables = Join-Path $folder 'drawables'
    New-Item -ItemType Directory -Force -Path $fonts,$drawables | Out-Null
    $scale = $target.Size/454.0
    foreach ($spec in @(
        @{Name='TimeFilled';Weight='ExtraBold';Em=148;Outline=$false;Chars='0123456789:'},
        @{Name='TimeOutline';Weight='ExtraBold';Em=148;Outline=$true;Chars='0123456789'},
        @{Name='UiSemiBold';Weight='SemiBold';Em=28;Outline=$false;Chars=$uiCharacters},
        @{Name='UiBold';Weight='Bold';Em=34;Outline=$false;Chars=$uiCharacters},
        @{Name='UiLabel';Weight='Medium';Em=22;Outline=$false;Chars=$uiCharacters},
        @{Name='UiTiny';Weight='Medium';Em=18;Outline=$false;Chars=$uiCharacters}
    )) {
        [RunclubAssets]::FontAtlas((Join-Path $root ('media\fonts\BarlowCondensed-'+$spec.Weight+'.ttf')),$fonts,$spec.Name,[int][Math]::Round($spec.Em*$scale),$spec.Outline,$spec.Chars)
    }
    $fontXml = '<fonts>' + ((@('TimeFilled','TimeOutline','UiSemiBold','UiBold','UiLabel','UiTiny') | ForEach-Object { '<font id="'+$_+'" filename="'+$_+'.fnt"/>' }) -join '') + '</fonts>'
    [System.IO.File]::WriteAllText((Join-Path $fonts 'fonts.xml'),$fontXml,(New-Object System.Text.UTF8Encoding $false))
    [RunclubAssets]::Topography((Join-Path $drawables 'bg-topography.png'),$target.Size)
    foreach ($kind in @('steps','distance','heart')) {
        [RunclubAssets]::Icon((Join-Path $drawables ('icon-'+$kind+'.png')),[Math]::Max(14,[int][Math]::Round(28*$scale)),$kind)
    }
    Write-Output ('Generated design resources for '+$target.Id)
}
