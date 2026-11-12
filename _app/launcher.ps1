# ============================================================
#  GAME LAUNCHER  ·  Harmony Edition  v2.1  (launcher.ps1)
#  Светлая / тёмная тема в духе Huawei / HarmonyOS:
#  #0A59F7 (light) и #317AF7 (dark), капсулы, карточки, мягкие тени.
#  Тема сохраняется в _app\theme.ini. Переключатель в шапке и в статус-баре.
#  Вся логика из старой версии сохранена.
# ============================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$refs = @(
    [System.Object].Assembly.Location,
    [System.Windows.Forms.Form].Assembly.Location,
    [System.Drawing.Color].Assembly.Location,
    [System.Uri].Assembly.Location,
    [System.Linq.Enumerable].Assembly.Location
)

try {
Add-Type -ReferencedAssemblies $refs -ErrorAction Stop -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using System.Reflection;

public static class Hx {
    [DllImport("dwmapi.dll")]
    public static extern int DwmSetWindowAttribute(IntPtr hwnd, int attr, ref int val, int size);
    [StructLayout(LayoutKind.Sequential)]
    public struct MARGINS { public int L; public int R; public int T; public int B; }
    [DllImport("dwmapi.dll")]
    public static extern int DwmExtendFrameIntoClientArea(IntPtr hwnd, ref MARGINS m);
    [DllImport("user32.dll")] public static extern bool ReleaseCapture();
    [DllImport("user32.dll")] public static extern IntPtr SendMessage(IntPtr h, int m, IntPtr w, IntPtr l);

    // ===== Единая палитра: меняется из PowerShell через ApplyTheme =====
    public static bool Dark = false;
    public static Color Accent1 = Color.FromArgb(10, 89, 247);
    public static Color Accent2 = Color.FromArgb(96, 134, 255);
    public static Color PageFill = Color.FromArgb(242, 246, 252);
    public static Color CardFill = Color.White;
    public static Color Neutral = Color.FromArgb(241, 243, 245);
    public static Color ChipHover = Color.FromArgb(229, 236, 249);
    public static Color Border = Color.FromArgb(226, 232, 240);
    public static Color TextMain = Color.FromArgb(24, 32, 48);
    public static Color TextDim = Color.FromArgb(90, 104, 126);
    public static Color GhostFill = Color.White;
    public static Color GhostHover = Color.FromArgb(240, 245, 255);
    public static Color AccentTextFill = Color.FromArgb(235, 243, 255);
    public static Color AccentTextHover = Color.FromArgb(223, 235, 255);
    public static Color AccentTextBorder = Color.FromArgb(206, 224, 255);
    public static Color DangerFill = Color.FromArgb(255, 246, 245);
    public static Color DangerHover = Color.FromArgb(255, 234, 231);
    public static Color DangerBorder = Color.FromArgb(250, 214, 210);
    public static Color DangerText = Color.FromArgb(214, 56, 34);
    public static Color SwitchOff1 = Color.FromArgb(216, 223, 234);
    public static Color SwitchOff2 = Color.FromArgb(233, 238, 246);
    public static Color Knob = Color.White;
    public static Color KnobEdge = Color.FromArgb(226, 231, 240);
    public static Color WindowText = Color.FromArgb(110, 122, 140);
    public static Color WindowHover = Color.FromArgb(230, 236, 245);
    public static Color WindowClose = Color.FromArgb(232, 64, 38);

    public static void ApplyTheme(bool dark) {
        Dark = dark;
        if (!dark) {
            Accent1 = Color.FromArgb(10, 89, 247);   // #0A59F7 — системный highlight
            Accent2 = Color.FromArgb(96, 134, 255);
            PageFill = Color.FromArgb(242, 246, 252);
            CardFill = Color.White;
            Neutral = Color.FromArgb(241, 243, 245);
            ChipHover = Color.FromArgb(229, 236, 249);
            Border = Color.FromArgb(226, 232, 240);
            TextMain = Color.FromArgb(24, 32, 48);
            TextDim = Color.FromArgb(90, 104, 126);
            GhostFill = Color.White;
            GhostHover = Color.FromArgb(240, 245, 255);
            AccentTextFill = Color.FromArgb(235, 243, 255);
            AccentTextHover = Color.FromArgb(223, 235, 255);
            AccentTextBorder = Color.FromArgb(206, 224, 255);
            DangerFill = Color.FromArgb(255, 246, 245);
            DangerHover = Color.FromArgb(255, 234, 231);
            DangerBorder = Color.FromArgb(250, 214, 210);
            DangerText = Color.FromArgb(214, 56, 34);
            SwitchOff1 = Color.FromArgb(216, 223, 234);
            SwitchOff2 = Color.FromArgb(233, 238, 246);
            Knob = Color.White;
            KnobEdge = Color.FromArgb(226, 231, 240);
            WindowText = Color.FromArgb(110, 122, 140);
            WindowHover = Color.FromArgb(230, 236, 245);
            WindowClose = Color.FromArgb(232, 64, 38);
        } else {
            Accent1 = Color.FromArgb(49, 122, 247);  // #317AF7 — highlight для тёмной темы
            Accent2 = Color.FromArgb(120, 150, 255);
            PageFill = Color.FromArgb(20, 23, 32);
            CardFill = Color.FromArgb(30, 33, 42);
            Neutral = Color.FromArgb(36, 40, 52);
            ChipHover = Color.FromArgb(44, 54, 80);
            Border = Color.FromArgb(58, 64, 80);
            TextMain = Color.FromArgb(235, 238, 245);
            TextDim = Color.FromArgb(150, 158, 176);
            GhostFill = Color.FromArgb(30, 33, 42);
            GhostHover = Color.FromArgb(42, 50, 72);
            AccentTextFill = Color.FromArgb(30, 46, 84);
            AccentTextHover = Color.FromArgb(38, 58, 100);
            AccentTextBorder = Color.FromArgb(52, 76, 132);
            DangerFill = Color.FromArgb(56, 34, 34);
            DangerHover = Color.FromArgb(74, 40, 38);
            DangerBorder = Color.FromArgb(96, 52, 50);
            DangerText = Color.FromArgb(255, 146, 126);
            SwitchOff1 = Color.FromArgb(60, 66, 82);
            SwitchOff2 = Color.FromArgb(74, 80, 98);
            Knob = Color.FromArgb(240, 244, 252);
            KnobEdge = Color.FromArgb(90, 98, 116);
            WindowText = Color.FromArgb(150, 158, 176);
            WindowHover = Color.FromArgb(52, 58, 74);
            WindowClose = Color.FromArgb(217, 72, 56);
        }
    }

    public static void Chrome(IntPtr h) {
        int dark = Dark ? 1 : 0;
        DwmSetWindowAttribute(h, 20, ref dark, 4);
        int round = 2;
        DwmSetWindowAttribute(h, 33, ref round, 4);
        MARGINS m = new MARGINS(); m.L = 1; m.R = 1; m.T = 1; m.B = 1;
        DwmExtendFrameIntoClientArea(h, ref m);
    }
    public static void Drag(IntPtr h) {
        ReleaseCapture();
        SendMessage(h, 0x00A1, (IntPtr)2, IntPtr.Zero);
    }
    public static void PaintEnable(Control c) {
        ControlStyles f = ControlStyles.AllPaintingInWmPaint |
                          ControlStyles.UserPaint |
                          ControlStyles.OptimizedDoubleBuffer |
                          ControlStyles.ResizeRedraw;
        MethodInfo mi = typeof(Control).GetMethod("SetStyle",
            BindingFlags.Instance | BindingFlags.NonPublic);
        if (mi != null) mi.Invoke(c, new object[] { f, true });
    }
    public static GraphicsPath Rounded(Rectangle r, int radius) {
        int d = radius * 2;
        if (d > r.Width)  d = r.Width;
        if (d > r.Height) d = r.Height;
        if (d < 1) d = 1;
        GraphicsPath p = new GraphicsPath();
        p.AddArc(r.X, r.Y, d, d, 180, 90);
        p.AddArc(r.Right - d, r.Y, d, d, 270, 90);
        p.AddArc(r.Right - d, r.Bottom - d, d, d, 0, 90);
        p.AddArc(r.X, r.Bottom - d, d, d, 90, 90);
        p.CloseFigure();
        return p;
    }
    public static void Shadow(Graphics g, Rectangle r, int radius, int depth) {
        Color c = Dark ? Color.FromArgb(11, 0, 0, 0) : Color.FromArgb(5, 26, 48, 92);
        for (int i = depth; i >= 1; i--) {
            Rectangle rr = new Rectangle(r.X, r.Y + i, r.Width, r.Height);
            using (GraphicsPath p = Rounded(rr, radius))
            using (SolidBrush b = new SolidBrush(c))
                g.FillPath(b, p);
        }
    }
    public static void Card(Graphics g, Rectangle r, int radius, Color fill, Color border) {
        using (GraphicsPath p = Rounded(r, radius))
        using (SolidBrush b = new SolidBrush(fill))
        using (Pen pen = new Pen(border, 1)) {
            g.FillPath(b, p);
            if (border.A > 0) g.DrawPath(pen, p);
        }
    }
    public static void Gradient(Graphics g, Rectangle r, int radius, Color c1, Color c2, float angle) {
        using (GraphicsPath p = Rounded(r, radius))
        using (LinearGradientBrush b = new LinearGradientBrush(r, c1, c2, angle)) {
            g.FillPath(b, p);
        }
    }
    public static Color Mix(Color a, Color b, float t) {
        if (t < 0f) t = 0f;
        if (t > 1f) t = 1f;
        return Color.FromArgb(
            (int)(a.R + (b.R - a.R) * t),
            (int)(a.G + (b.G - a.G) * t),
            (int)(a.B + (b.B - a.B) * t));
    }
    public static void Txt(Graphics g, string s, Font f, Color c, Rectangle r, TextFormatFlags flags) {
        TextRenderer.DrawText(g, s, f, r, c, flags);
    }
}

public class HxButton : Button {
    private bool selected = false;
    private float selBlend = 0f;
    private Timer anim;
    private bool hovered = false;
    private bool pressed = false;

    public string Kind { get; set; }
    public int Radius { get; set; }
    public bool OnCard { get; set; }

    private Color Surface { get { return OnCard ? Hx.CardFill : Hx.PageFill; } }

    public bool Selected {
        get { return selected; }
        set {
            if (selected != value) {
                selected = value;
                if (anim != null) anim.Start();
                Invalidate();
            }
        }
    }

    public HxButton() {
        SetStyle(ControlStyles.AllPaintingInWmPaint | ControlStyles.UserPaint |
                 ControlStyles.OptimizedDoubleBuffer | ControlStyles.ResizeRedraw, true);
        BackColor = Hx.PageFill;
        FlatStyle = FlatStyle.Flat;
        FlatAppearance.BorderSize = 0;
        FlatAppearance.MouseOverBackColor = Color.Transparent;
        FlatAppearance.MouseDownBackColor = Color.Transparent;
        ForeColor = Hx.TextMain;
        Font = new Font("Segoe UI", 9f);
        Cursor = Cursors.Hand;
        TabStop = false;
        Kind = "ghost";
        Radius = 14;
        OnCard = false;
        anim = new Timer();
        anim.Interval = 16;
        anim.Tick += delegate(object s, EventArgs e) {
            float target = selected ? 1f : 0f;
            float diff = target - selBlend;
            if (diff > -0.03f && diff < 0.03f) { selBlend = target; anim.Stop(); }
            else selBlend += diff * 0.28f;
            Invalidate();
        };
    }

    // ВАЖНО: Region отсекает углы, а явная заливка убирает чёрные артефакты
    private void ApplyRegion() {
        if (Width < 2 || Height < 2) return;
        int rad = Math.Min(Radius, Math.Min(Width, Height) / 2);
        using (GraphicsPath p = Hx.Rounded(new Rectangle(0, 0, Width, Height), rad)) {
            if (Region != null) Region.Dispose();
            Region = new Region(p);
        }
    }
    protected override void OnHandleCreated(EventArgs e) { base.OnHandleCreated(e); ApplyRegion(); }
    protected override void OnResize(EventArgs e) { base.OnResize(e); ApplyRegion(); Invalidate(); }
    protected override void OnMouseEnter(EventArgs e) { hovered = true;  Invalidate(); base.OnMouseEnter(e); }
    protected override void OnMouseLeave(EventArgs e) { hovered = false; pressed = false; Invalidate(); base.OnMouseLeave(e); }
    protected override void OnMouseDown(MouseEventArgs e) { if (e.Button == MouseButtons.Left) pressed = true; Invalidate(); base.OnMouseDown(e); }
    protected override void OnMouseUp(MouseEventArgs e)   { pressed = false; Invalidate(); base.OnMouseUp(e); }
    protected override void OnPaintBackground(PaintEventArgs e) { e.Graphics.Clear(Surface); }

    protected override void OnPaint(PaintEventArgs e) {
        Graphics g = e.Graphics;
        g.Clear(Surface);
        g.SmoothingMode = SmoothingMode.AntiAlias;
        g.TextRenderingHint = System.Drawing.Text.TextRenderingHint.ClearTypeGridFit;
        Rectangle r = new Rectangle(0, 0, Width - 1, Height - 1);
        string k = Kind == null ? "ghost" : Kind;
        Color c1 = Hx.Accent1, c2 = Hx.Accent2;
        Color text = Hx.TextMain;
        bool enabled = Enabled;

        if (k == "primary") {
            Color a = pressed ? Hx.Mix(c1, Color.Black, 0.14f) : (hovered ? Hx.Mix(c1, Color.White, 0.12f) : c1);
            Color b = pressed ? Hx.Mix(c2, Color.Black, 0.14f) : (hovered ? Hx.Mix(c2, Color.White, 0.12f) : c2);
            if (!enabled) { a = Hx.Mix(c1, Surface, 0.55f); b = Hx.Mix(c2, Surface, 0.55f); }
            Hx.Gradient(g, r, Radius, a, b, 12f);
            text = Color.White;
        } else if (k == "chip") {
            Color fill = Hx.Mix(Hx.Neutral, c1, selBlend);
            if (hovered && selBlend < 0.5f) fill = Hx.ChipHover;
            if (pressed) fill = Hx.Mix(fill, Color.Black, 0.06f);
            Hx.Gradient(g, r, Radius, fill, Hx.Mix(fill, c2, selBlend * 0.35f), 10f);
            text = Hx.Mix(Hx.TextDim, Color.White, selBlend);
        } else if (k == "ghost") {
            Color fill = hovered ? Hx.GhostHover : Hx.GhostFill;
            if (pressed) fill = Hx.Mix(fill, c1, 0.10f);
            Hx.Card(g, r, Radius, fill, hovered ? Hx.AccentTextBorder : Hx.Border);
            text = hovered ? c1 : Hx.TextMain;
        } else if (k == "accentText") {
            Color fill = hovered ? Hx.AccentTextHover : Hx.AccentTextFill;
            Hx.Card(g, r, Radius, fill, Hx.AccentTextBorder);
            text = c1;
        } else if (k == "danger") {
            Color fill = hovered ? Hx.DangerHover : Hx.DangerFill;
            Hx.Card(g, r, Radius, fill, Hx.DangerBorder);
            text = Hx.DangerText;
        } else if (k == "text") {
            if (hovered) Hx.Card(g, r, Radius, Hx.GhostHover, Color.Transparent);
            text = hovered ? c1 : Hx.TextDim;
        } else if (k == "window") {
            if (hovered) {
                bool close = (Text == "×");
                Hx.Card(g, r, Radius, close ? Hx.WindowClose : Hx.WindowHover, Color.Transparent);
                text = close ? Color.White : Hx.TextMain;
            } else text = Hx.WindowText;
        }

        if (!enabled && k != "primary") text = Hx.Mix(Surface, Hx.TextDim, 0.55f);

        TextFormatFlags flags = TextFormatFlags.HorizontalCenter |
                                TextFormatFlags.VerticalCenter |
                                TextFormatFlags.EndEllipsis |
                                TextFormatFlags.NoPadding;
        Hx.Txt(g, Text ?? "", Font, text, r, flags);
    }
}

public class HxSwitch : CheckBox {
    private float pos = 0f;
    private Timer anim;
    public bool OnCard { get; set; }

    private Color Surface { get { return OnCard ? Hx.CardFill : Hx.PageFill; } }

    public HxSwitch() {
        SetStyle(ControlStyles.AllPaintingInWmPaint | ControlStyles.UserPaint |
                 ControlStyles.OptimizedDoubleBuffer | ControlStyles.ResizeRedraw, true);
        BackColor = Hx.CardFill;
        FlatStyle = FlatStyle.Flat;
        FlatAppearance.BorderSize = 0;
        FlatAppearance.CheckedBackColor = Color.Transparent;
        FlatAppearance.MouseOverBackColor = Color.Transparent;
        FlatAppearance.MouseDownBackColor = Color.Transparent;
        Appearance = Appearance.Button;
        AutoSize = false;
        AutoCheck = true;
        Text = "";
        Cursor = Cursors.Hand;
        TabStop = false;
        OnCard = true;
        Size = new Size(46, 26);
        pos = Checked ? 1f : 0f;
        anim = new Timer();
        anim.Interval = 16;
        anim.Tick += delegate(object s, EventArgs e) {
            float target = Checked ? 1f : 0f;
            float diff = target - pos;
            if (diff > -0.03f && diff < 0.03f) { pos = target; anim.Stop(); }
            else pos += diff * 0.30f;
            Invalidate();
        };
    }
    private void ApplyRegion() {
        if (Width < 2 || Height < 2) return;
        using (GraphicsPath p = Hx.Rounded(new Rectangle(0, 0, Width, Height), 13)) {
            if (Region != null) Region.Dispose();
            Region = new Region(p);
        }
    }
    protected override void OnHandleCreated(EventArgs e) { base.OnHandleCreated(e); ApplyRegion(); }
    protected override void OnResize(EventArgs e) { base.OnResize(e); ApplyRegion(); Invalidate(); }
    protected override void OnCheckedChanged(EventArgs e) { anim.Start(); Invalidate(); base.OnCheckedChanged(e); }
    protected override void OnPaintBackground(PaintEventArgs e) { e.Graphics.Clear(Surface); }
    protected override void OnPaint(PaintEventArgs e) {
        Graphics g = e.Graphics;
        g.Clear(Surface);
        g.SmoothingMode = SmoothingMode.AntiAlias;
        Rectangle t = new Rectangle(1, 3, Width - 2, Height - 6);
        Color a = Checked ? Hx.Accent1 : Hx.SwitchOff1;
        Color b = Checked ? Hx.Accent2 : Hx.SwitchOff2;
        Hx.Gradient(g, t, 13, a, b, 8f);
        int d = Height - 10;
        float x = 3f + pos * (Width - d - 6);
        Rectangle k = new Rectangle((int)x, 5, d, d);
        using (SolidBrush sh = new SolidBrush(Color.FromArgb(40, 20, 40, 90)))
            g.FillEllipse(sh, new Rectangle(k.X + 1, k.Y + 2, k.Width, k.Height));
        using (SolidBrush wb = new SolidBrush(Hx.Knob)) g.FillEllipse(wb, k);
        using (Pen p = new Pen(Hx.KnobEdge)) g.DrawEllipse(p, k);
    }
    protected override void Dispose(bool disposing) {
        if (disposing && anim != null) { anim.Stop(); anim.Dispose(); }
        base.Dispose(disposing);
    }
}
'@
} catch {
    [void][System.Windows.Forms.MessageBox]::Show(
        "Не удалось загрузить компоненты интерфейса.`n$($_.Exception.Message)",
        "Game Launcher", "OK", "Error")
    exit
}

# ===== Пути и конфиг =====
$appDir     = $PSScriptRoot
$configFile = Join-Path $appDir "config.ini"
$logFile    = Join-Path $appDir "launcher.log"
$iconPath   = Join-Path $appDir "icon.ico"
$knownGames = @("BG3", "CS2", "Fortnite", "Genshin")

$sections = @{}
$cur = $null
if (Test-Path $configFile) {
    foreach ($line in (Get-Content $configFile -Encoding UTF8)) {
        $t = $line.Trim()
        if ($t -match '^\[(.+)\]$') { $cur = @{}; $sections[$Matches[1]] = $cur }
        elseif ($cur -ne $null -and $t -match '^([^=]+)=(.*)$') { $cur[$Matches[1].Trim()] = $Matches[2].Trim() }
    }
}

$gameOrder = @($knownGames | Where-Object { $sections.ContainsKey($_) })
$gameOrder += @($sections.Keys | Where-Object { $knownGames -notcontains $_ })

$games = [ordered]@{}
foreach ($g in $gameOrder) {
    $sec = $sections[$g]; $items = @(); $i = 1
    while ($sec.ContainsKey("${i}Name") -and $sec.ContainsKey("${i}Path")) {
        $delay = 0; [void][int]::TryParse($sec["${i}Delay"], [ref]$delay)
        $defRaw = "$($sec["${i}Default"])".ToLower()
        $def = ($defRaw -eq "1" -or $defRaw -eq "true")
        $items += [pscustomobject]@{
            Name = $sec["${i}Name"]; Path = $sec["${i}Path"]
            Args = $sec["${i}Args"]; Proc = $sec["${i}Proc"]
            Delay = $delay; Default = $def
        }
        $i++
    }
    if ($items.Count -gt 0) { $games[$g] = $items }
}

# ===== Палитра Harmony + переключатель тем =====
function Col([int]$r,[int]$g,[int]$b)         { return [System.Drawing.Color]::FromArgb($r,$g,$b) }
function ColA([int]$a,[int]$r,[int]$g,[int]$b) { return [System.Drawing.Color]::FromArgb($a,$r,$g,$b) }
function Rect([int]$x,[int]$y,[int]$w,[int]$h) { return [System.Drawing.Rectangle]::new($x,$y,$w,$h) }

$themeFile = Join-Path $appDir "theme.ini"
$script:initialDark = $false
try {
    if (Test-Path $themeFile) {
        if ((Get-Content $themeFile -Raw) -match '(?i)\bdark\b') { $script:initialDark = $true }
    }
} catch {}

function Apply-ThemeToControls($c) {
    if ($c -eq $null) { return }
    try {
        if     ($c -is [HxButton])                         { $c.Invalidate() }
        elseif ($c -is [HxSwitch])                         { $c.Invalidate() }
        elseif ($c -is [System.Windows.Forms.RichTextBox]) { $c.BackColor = $script:cLogBg; $c.ForeColor = $script:cDim }
        elseif ($c -is [System.Windows.Forms.TextBox])     { $c.BackColor = $script:cLogBg; $c.ForeColor = $script:cText }
        elseif ($c -is [System.Windows.Forms.ComboBox])    { $c.BackColor = $script:cWhite; $c.ForeColor = $script:cText }
        elseif ($c -is [System.Windows.Forms.ListBox])     { $c.BackColor = $script:cLogBg; $c.ForeColor = $script:cText }
        elseif ($c -is [System.Windows.Forms.Label])       { $c.BackColor = $script:cWhite; $c.ForeColor = $script:cDim }
        elseif ($c -is [System.Windows.Forms.TabPage])     { $c.BackColor = $script:cWhite; $c.ForeColor = $script:cText }
        elseif ($c -is [System.Windows.Forms.TabControl])  { $c.ForeColor = $script:cText }
        elseif ($c -is [System.Windows.Forms.Panel])       { $c.BackColor = $script:cPage }
    } catch {}
    foreach ($ch in @($c.Controls)) { Apply-ThemeToControls $ch }
}

function Set-Theme([bool]$dark, [bool]$save = $true) {
    $script:darkTheme = $dark
    [Hx]::ApplyTheme($dark)
    if ($dark) {
        # Тёмная: системный highlight HarmonyOS #317AF7, карточки #1E212A
        $script:cPage   = Col 20 23 32
        $script:cBgTop  = Col 26 29 38
        $script:cBgBot  = Col 16 18 28
        $script:cWhite  = Col 30 33 42
        $script:cText   = Col 235 238 245
        $script:cDim    = Col 150 158 176
        $script:cLine   = Col 58 64 80
        $script:cBlue   = Col 49 122 247
        $script:cBlue2  = Col 120 150 255
        $script:cViolet = Col 160 130 255
        $script:cSoft   = Col 30 46 84
        $script:cSoft2  = Col 24 30 48
        $script:cGreen  = Col 90 200 150
        $script:cWarn   = Col 217 72 56
        $script:cOrange = Col 230 140 80
        $script:cHero1  = Col 30 44 78
        $script:cHero2  = Col 40 33 68
        $script:cHeroBorder = Col 58 76 120
        $script:cTrack  = Col 58 64 80
        $script:cHover  = Col 38 44 58
        $script:cIc1    = Col 38 52 86
        $script:cIc2    = Col 44 46 80
        $script:cDash   = Col 70 84 120
        $script:cLogBg  = Col 24 27 36
        $script:cTabIdle= Col 36 40 52
        $script:cGlow1  = ColA 70 49 122 247
        $script:cGlow2  = ColA 45 139 110 255
        $script:cGlowEdge = ColA 0 0 0 0
    } else {
        # Светлая: #0A59F7, фон карточек #F1F3F5
        $script:cPage   = Col 242 246 252
        $script:cBgTop  = Col 248 250 253
        $script:cBgBot  = Col 231 239 251
        $script:cWhite  = [System.Drawing.Color]::White
        $script:cText   = Col 24 32 48
        $script:cDim    = Col 118 130 150
        $script:cLine   = Col 232 236 242
        $script:cBlue   = Col 10 89 247
        $script:cBlue2  = Col 96 134 255
        $script:cViolet = Col 139 110 255
        $script:cSoft   = Col 232 240 255
        $script:cSoft2  = Col 245 248 255
        $script:cGreen  = Col 38 166 110
        $script:cWarn   = Col 232 64 38
        $script:cOrange = Col 237 111 33
        $script:cHero1  = Col 229 239 255
        $script:cHero2  = Col 246 243 255
        $script:cHeroBorder = Col 214 226 250
        $script:cTrack  = Col 216 226 244
        $script:cHover  = Col 246 249 255
        $script:cIc1    = Col 232 240 255
        $script:cIc2    = Col 214 228 255
        $script:cDash   = Col 198 214 240
        $script:cLogBg  = Col 247 249 252
        $script:cTabIdle= Col 241 243 245
        $script:cGlow1  = ColA 46 10 89 247
        $script:cGlow2  = ColA 30 139 110 255
        $script:cGlowEdge = ColA 0 255 255 255
    }
    $script:cOnAccent = [System.Drawing.Color]::White

    if ($save) {
        $val = if ($dark) { "dark" } else { "light" }
        try { [System.IO.File]::WriteAllText($themeFile, "Theme=$val", [System.Text.UTF8Encoding]::new($false)) } catch {}
    }

    foreach ($f in @([System.Windows.Forms.Application]::OpenForms)) {
        try {
            [Hx]::Chrome($f.Handle)
            $f.BackColor = $script:cPage
            Apply-ThemeToControls $f
            $f.Invalidate($true)
        } catch {}
    }
    if ($script:btnTheme)       { $script:btnTheme.Text = if ($dark) { "◑" } else { "◐" } }
    if ($script:btnThemeFooter) { $script:btnThemeFooter.Text = if ($dark) { "◑ Светлая тема" } else { "◐ Тёмная тема" } }
    if ($script:canvas)         { $script:canvas.Invalidate() }
}

Set-Theme $script:initialDark $false

# ===== Шрифты =====
$families = @([System.Drawing.FontFamily]::Families | ForEach-Object { $_.Name })
$uiFont = "Segoe UI"
if     ($families -contains "HarmonyOS Sans")             { $uiFont = "HarmonyOS Sans" }
elseif ($families -contains "Segoe UI Variable Display") { $uiFont = "Segoe UI Variable Display" }

$fs = [System.Drawing.FontStyle]::Regular
$fb = [System.Drawing.FontStyle]::Bold
$fTitle  = [System.Drawing.Font]::new($uiFont, 17, $fb)
$fHero   = [System.Drawing.Font]::new($uiFont, 20, $fb)
$fCap    = [System.Drawing.Font]::new($uiFont, [single]8.5, $fb)
$fItem   = [System.Drawing.Font]::new($uiFont, [single]10.5, $fb)
$fBtn    = [System.Drawing.Font]::new($uiFont, [single]10.5, $fb)
$fSmall  = [System.Drawing.Font]::new($uiFont, 9, $fs)
$fHint   = [System.Drawing.Font]::new($uiFont, [single]8.5, $fs)
$fIcon   = [System.Drawing.Font]::new($uiFont, 12, $fb)
$fOrb    = [System.Drawing.Font]::new($uiFont, 22, $fb)
$fMono   = [System.Drawing.Font]::new("Consolas", [single]8.5, $fs)
$fWin    = [System.Drawing.Font]::new($uiFont, 13, $fb)

$flagsC = [System.Windows.Forms.TextFormatFlags]::HorizontalCenter -bor
          [System.Windows.Forms.TextFormatFlags]::VerticalCenter -bor
          [System.Windows.Forms.TextFormatFlags]::EndEllipsis -bor
          [System.Windows.Forms.TextFormatFlags]::NoPadding
$flagsL = [System.Windows.Forms.TextFormatFlags]::Left -bor
          [System.Windows.Forms.TextFormatFlags]::VerticalCenter -bor
          [System.Windows.Forms.TextFormatFlags]::EndEllipsis -bor
          [System.Windows.Forms.TextFormatFlags]::NoPadding
$flagsR = [System.Windows.Forms.TextFormatFlags]::Right -bor
          [System.Windows.Forms.TextFormatFlags]::VerticalCenter -bor
          [System.Windows.Forms.TextFormatFlags]::NoPadding
$flagsW = [System.Windows.Forms.TextFormatFlags]::WordBreak -bor
          [System.Windows.Forms.TextFormatFlags]::NoPadding

# ===== Состояние =====
$script:canvas       = $null
$script:geo          = @{}
$script:currentGame  = ""
$script:toggles      = @()
$script:launchedProcs= @()
$script:hoverRow     = -1
$script:selCount     = 0
$script:totalCount   = 0
$script:statusText   = "Готово к запуску"
$script:logExpanded  = $false
$script:needRestart  = $false
$script:dlgResult    = "OK"
$script:hxDlgTitle   = ""
$script:hxDlgMessage = ""
$script:hxDlgKind    = "info"
# $script:darkTheme уже выставлен в Set-Theme — не перезаписывать!
$script:btnTheme       = $null
$script:btnThemeFooter = $null

# ===== Универсальное окно сообщения в том же стиле =====
function Show-HxDialog([string]$title, [string]$message, [string]$kind="info", [string]$buttons="OK", $owner=$null) {
    $script:hxDlgTitle   = $title
    $script:hxDlgMessage = $message
    $script:hxDlgKind    = $kind
    $script:dlgResult    = if ($buttons -eq "YesNo") { "No" } else { "OK" }

    $m = [System.Windows.Forms.TextRenderer]::MeasureText(
            $message, $fSmall, [System.Drawing.Size]::new(336, 500), $flagsW)
    $h = [Math]::Max(230, [Math]::Min(420, 170 + $m.Height))

    $d = [System.Windows.Forms.Form]::new()
    $d.FormBorderStyle = "None"
    $d.StartPosition   = if ($owner) { "CenterParent" } else { "CenterScreen" }
    $d.ClientSize      = [System.Drawing.Size]::new(400, $h)
    $d.BackColor       = $cPage
    $d.ShowInTaskbar   = $true
    $d.KeyPreview      = $true
    $d.Font            = $fSmall
    if (Test-Path $iconPath) { try { $d.Icon = [System.Drawing.Icon]::new($iconPath) } catch {} }

    $cv = [System.Windows.Forms.Panel]::new()
    $cv.Dock = "Fill"
    $cv.BackColor = $cPage
    [Hx]::PaintEnable($cv)
    $d.Controls.Add($cv)

    $cv.Add_Paint({
        param($s,$e)
        $g = $e.Graphics
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
        $W = $s.ClientSize.Width; $H = $s.ClientSize.Height
        $g.Clear($cPage)

        $card = Rect 14 14 ($W-28) ($H-28)
        [Hx]::Shadow($g, $card, 20, 6)
        [Hx]::Card($g, $card, 20, $cWhite, $cLine)

        $orb = Rect 32 32 40 40
        $oc1 = if ($script:hxDlgKind -eq "danger") { $cWarn } else { $cBlue }
        $oc2 = if ($script:hxDlgKind -eq "danger") { $cOrange } else { $cViolet }
        $og = [System.Drawing.Drawing2D.LinearGradientBrush]::new($orb, $oc1, $oc2, [single]45)
        $g.FillEllipse($og, $orb); $og.Dispose()
        $glyph = if ($script:hxDlgKind -eq "success") { "✓" } elseif ($script:hxDlgKind -eq "danger") { "!" } else { "i" }
        [Hx]::Txt($g, $glyph, $fOrb, $cOnAccent, $orb, $flagsC)

        [Hx]::Txt($g, $script:hxDlgTitle, $fItem, $cText, (Rect 84 34 ($W-152) 26), $flagsL)
        [Hx]::Txt($g, $script:hxDlgMessage, $fSmall, $cDim,
                  (Rect 32 86 ($W-64) ($H-160)), $flagsW)
    })

    $cardBottom = $h - 14
    if ($buttons -eq "YesNo") {
        $bNo = [HxButton]::new()
        $bNo.Kind = "ghost"; $bNo.Text = "Отмена"; $bNo.Font = $fSmall; $bNo.OnCard = $true
        $bNo.Location = [System.Drawing.Point]::new(190, ($cardBottom-50))
        $bNo.Size = [System.Drawing.Size]::new(92, 36)
        $bNo.Radius = 12
        $bNo.Add_Click({ $script:dlgResult = "No"; $this.FindForm().Close() })
        $d.Controls.Add($bNo)

        $bYes = [HxButton]::new()
        $bYes.Kind = "primary"; $bYes.Text = "Да"; $bYes.Font = $fSmall; $bYes.OnCard = $true
        $bYes.Location = [System.Drawing.Point]::new(292, ($cardBottom-50))
        $bYes.Size = [System.Drawing.Size]::new(94, 36)
        $bYes.Radius = 12
        $bYes.Add_Click({ $script:dlgResult = "Yes"; $this.FindForm().Close() })
        $d.Controls.Add($bYes)
        $d.CancelButton = $bNo
        $d.AcceptButton = $bYes
    } else {
        $bOk = [HxButton]::new()
        $bOk.Kind = "primary"; $bOk.Text = "ОК"; $bOk.Font = $fSmall; $bOk.OnCard = $true
        $bOk.Location = [System.Drawing.Point]::new(286, ($cardBottom-50))
        $bOk.Size = [System.Drawing.Size]::new(100, 36)
        $bOk.Radius = 12
        $bOk.Add_Click({ $script:dlgResult = "OK"; $this.FindForm().Close() })
        $d.Controls.Add($bOk)
        $d.CancelButton = $bOk
        $d.AcceptButton = $bOk
    }

    $cv.Add_MouseDown({
        param($s,$e)
        if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left -and $e.Y -lt 70) {
            [Hx]::Drag($s.Parent.Handle)
        }
    })
    # Крестик на карточке — окно всегда можно закрыть
    $bx = [HxButton]::new()
    $bx.Kind = "window"; $bx.Text = "×"; $bx.Font = $fWin
    $bx.Location = [System.Drawing.Point]::new(352, 22)
    $bx.Size = [System.Drawing.Size]::new(30, 30); $bx.Radius = 10
    $bx.OnCard = $true
    $bx.Add_Click({ $script:dlgResult = "No"; $this.FindForm().Close() })
    $d.Controls.Add($bx)

    $d.Add_KeyDown({
        param($snd,$ev)
        if ($ev.KeyCode -eq [System.Windows.Forms.Keys]::Escape) {
            $script:dlgResult = "No"; $snd.Close()
        }
    })
    $d.Add_Shown({ param($s,$e) [Hx]::Chrome($s.Handle); $s.Activate() })

    # Фоновая панель добавлена первой => она перекрывала кнопки. Отправляем назад.
    $cv.SendToBack()
    $bx.BringToFront()

    if ($owner) { [void]$d.ShowDialog($owner) } else { [void]$d.ShowDialog() }
    return $script:dlgResult
}

if ($games.Count -eq 0) {
    [void](Show-HxDialog "Конфиг не найден" "Не найден config.ini или в нём нет игр.`n`nСначала запусти setup.bat — он создаст конфиг." "warning" "OK")
    exit
}

# ===== Вспомогательные функции =====
function Draw-Glow($g, $r, $center, $edge) {
    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $path.AddEllipse($r.X, $r.Y, $r.Width, $r.Height)
    $pgb = [System.Drawing.Drawing2D.PathGradientBrush]::new($path)
    $pgb.CenterColor = $center
    $pgb.SurroundColors = [System.Drawing.Color[]]@($edge)
    $pgb.CenterPoint = [System.Drawing.PointF]::new(($r.X + $r.Width/2), ($r.Y + $r.Height/2))
    $g.FillPath($pgb, $path)
    $pgb.Dispose(); $path.Dispose()
}

function Get-ItemHint($item) {
    $hint = ""
    if ($item.Path -like "*://*") {
        if     ($item.Path -like "steam://*") { $hint = "Steam · запуск через протокол · VAC OK" }
        elseif ($item.Path -like "http*")     { $hint = "Ссылка · откроется в браузере" }
        else                                  { $hint = "Протокол: $($item.Path)" }
    } else {
        try   { $hint = [System.IO.Path]::GetFileName($item.Path) }
        catch { $hint = "$($item.Path)" }
    }
    if ($item.Args)       { $hint += " · с аргументами" }
    if ($item.Delay -gt 0){ $hint += " · задержка $($item.Delay) сек" }
    return $hint
}

function Update-Status {
    $total = @($script:toggles).Count
    $sel = 0
    foreach ($t in $script:toggles) { if ($t.Checked) { $sel++ } }
    $script:selCount   = $sel
    $script:totalCount = $total
    $tail = if ($sel -gt 0) { "готово к запуску" } else { "ничего не выбрано" }
    $script:statusText = "Выбрано $sel из $total · $tail"
    if ($script:canvas) { $script:canvas.Invalidate() }
}

function Write-Log([string]$msg, [string]$kind = "info") {
    $stamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch ($kind) {
        "ok"   { $cGreen }
        "err"  { $cWarn }
        "warn" { $cOrange }
        "head" { $cBlue }
        default{ $cDim }
    }
    try {
        $logBox.SelectionStart  = $logBox.TextLength
        $logBox.SelectionColor  = $color
        $logBox.AppendText("$msg`r`n")
        $logBox.SelectionColor  = $cDim
        $logBox.ScrollToCaret()
    } catch {}
    try { Add-Content -Path $logFile -Value "[$stamp] $msg" -Encoding UTF8 -ErrorAction SilentlyContinue } catch {}
    [System.Windows.Forms.Application]::DoEvents()
}

function Write-LogAuto([string]$msg) {
    $k = "info"
    if     ($msg -match '^\[OK\]')            { $k = "ok" }
    elseif ($msg -match '^\[ERR\]')           { $k = "err" }
    elseif ($msg -match '^\[!\]|^\[\?\]')    { $k = "warn" }
    elseif ($msg -match '^===|^---|^-')      { $k = "head" }
    Write-Log $msg $k
}

function Test-ProcAlive([string[]]$names) {
    @(Get-Process -Name $names -ErrorAction SilentlyContinue | Where-Object { -not $_.HasExited })
}

function Get-ProcNames($item) {
    if ($item.Proc) { return @($item.Proc -split "\s*,\s*" | Where-Object { $_ }) }
    if ($item.Path -notlike "*://*") {
        return @([System.IO.Path]::GetFileNameWithoutExtension($item.Path))
    }
    return @()
}

function Get-CustomGameNames {
    $res = @()
    foreach ($line in (Get-Content $configFile -Encoding UTF8)) {
        if ($line -match '^\s*\[(.+)\]\s*$') {
            if ($knownGames -notcontains $Matches[1]) { $res += $Matches[1] }
        }
    }
    return $res
}

function Add-ConfigSection([string]$sectionText) {
    $content = ""
    try { $content = [System.IO.File]::ReadAllText($configFile) } catch {}
    if (-not $content.EndsWith("`n")) { $content += "`r`n" }
    [System.IO.File]::WriteAllText($configFile, $content + $sectionText, [System.Text.UTF8Encoding]::new($false))
}

function Get-MaxItemIndex([string]$game) {
    $max = 0; $in = $false
    foreach ($line in (Get-Content $configFile -Encoding UTF8)) {
        $t = $line.Trim()
        if ($t -match '^\[(.+)\]$') { $in = ($Matches[1] -eq $game); continue }
        if ($in -and $t -match '^(\d+)Name=') {
            $n = [int]$Matches[1]
            if ($n -gt $max) { $max = $n }
        }
    }
    return $max
}

function Add-ItemToSection([string]$game, [string]$block) {
    $lines = @(Get-Content $configFile -Encoding UTF8)
    $secStart = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match "^\s*\[$([regex]::Escape($game))\]\s*$") { $secStart = $i; break }
    }
    if ($secStart -lt 0) { return $false }
    $secEnd = $lines.Count
    for ($i = $secStart + 1; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^\s*\[') { $secEnd = $i; break }
    }
    $blockLines = @($block -split "`r`n" | Where-Object { $_ })
    $tail = @()
    if ($secEnd -lt $lines.Count) { $tail = @($lines[$secEnd..($lines.Count - 1)]) }
    $newLines = @($lines[0..($secEnd - 1)]) + $blockLines + $tail
    [System.IO.File]::WriteAllLines($configFile, $newLines, [System.Text.UTF8Encoding]::new($false))
    return $true
}

function Get-SteamGames {
    $list = @()
    $steamPath = (Get-ItemProperty "HKCU:\Software\Valve\Steam" -Name SteamPath -ErrorAction SilentlyContinue).SteamPath
    if (-not $steamPath) { return $list }
    $libs = @($steamPath)
    $vdf = Join-Path $steamPath "steamapps\libraryfolders.vdf"
    if (Test-Path $vdf) {
        foreach ($l in Get-Content $vdf) {
            if ($l -match '"path"\s+"([^"]+)"') { $libs += ($Matches[1] -replace '\\\\', '\') }
        }
    }
    foreach ($lib in $libs) {
        $sa = Join-Path $lib "steamapps"
        if (-not (Test-Path $sa)) { continue }
        foreach ($acf in (Get-ChildItem $sa -Filter "appmanifest_*.acf" -ErrorAction SilentlyContinue)) {
            $txt = Get-Content $acf.FullName -Raw
            $appid = ""; $name = ""
            if ($txt -match '"appid"\s+"(\d+)"') { $appid = $Matches[1] }
            if ($txt -match '"name"\s+"([^"]+)"') { $name = $Matches[1].Trim() }
            if ($appid -and $name -and $name -notmatch "Steam Runtime|Proton|Steamworks") {
                $list += [pscustomobject]@{ AppId = $appid; Name = $name }
            }
        }
    }
    return @($list | Sort-Object AppId -Unique)
}

function Restart-Launcher {
    Start-Process powershell -WindowStyle Hidden -ArgumentList @(
        "-NoProfile", "-ExecutionPolicy", "Bypass", "-WindowStyle", "Hidden",
        "-File", "`"$PSCommandPath`""
    )
    $form.Close()
}

# ===== Геометрия =====
$gameList  = @($games.Keys)
$chipRows  = [Math]::Max(1, [Math]::Ceiling($gameList.Count / 4))
$maxItems  = 3
foreach ($g in $gameList) { $n = @($games[$g]).Count; if ($n -gt $maxItems) { $maxItems = $n } }
if ($maxItems -lt 3) { $maxItems = 3 }
$script:itemRows = $maxItems

$geo = @{}
$geo.TitleH   = 72
$geo.CapY     = 82
$geo.ChipY    = 102
$geo.ChipH    = 12 + $chipRows*34 + ($chipRows-1)*8 + 12
$geo.HeroY    = $geo.ChipY + $geo.ChipH + 14
$geo.HeroH    = 96
$geo.SecY     = $geo.HeroY + $geo.HeroH + 16
$geo.SecH     = 20
$geo.ItemY    = $geo.SecY + $geo.SecH + 8
$geo.ItemH    = 10 + $maxItems*54 + 10
$geo.PrimaryY = $geo.ItemY + $geo.ItemH + 14
$geo.PrimaryH = 48
$geo.SecondY  = $geo.PrimaryY + $geo.PrimaryH + 10
$geo.SecondH  = 38
$geo.LogY     = $geo.SecondY + $geo.SecondH + 14
$geo.LogH     = 44
$geo.FooterY  = $geo.LogY + $geo.LogH + 10
$script:geo   = $geo
$formH        = $geo.FooterY + 38

# ===== Отрисовка фона, карточек и текстов =====
function Draw-Canvas($g) {
    $geo = $script:geo
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
    $W = $script:canvas.ClientSize.Width
    $H = $script:canvas.ClientSize.Height

    $g.Clear($cPage)
    Draw-Glow $g (Rect ($W-230) -90 340 340) $cGlow1 $cGlowEdge
    Draw-Glow $g (Rect -90 ($H-230) 300 300) $cGlow2 $cGlowEdge

    # --- шапка ---
    $orb = Rect 20 18 36 36
    $og = [System.Drawing.Drawing2D.LinearGradientBrush]::new($orb, $cBlue, $cViolet, [single]45)
    $g.FillEllipse($og, $orb); $og.Dispose()
    [Hx]::Txt($g, "G", $fIcon, $cOnAccent, $orb, $flagsC)
    [Hx]::Txt($g, "Game Launcher", $fTitle, $cText, (Rect 66 12 280 32), $flagsL)
    [Hx]::Txt($g, "Центр запуска игр и приложений", $fHint, $cDim, (Rect 68 44 300 18), $flagsL)
    $penLine = [System.Drawing.Pen]::new($cLine)
    $g.DrawLine($penLine, 20, 72, ($W-20), 72)
    $penLine.Dispose()

    # --- подпись к играм ---
    [Hx]::Txt($g, "ВАШИ ИГРЫ", $fCap, $cDim, (Rect 20 $geo.CapY 200 18), $flagsL)
    [Hx]::Txt($g, "$($gameList.Count) игр", $fHint, $cDim, (Rect 250 $geo.CapY 110 18), $flagsR)

    # --- карточка с чипами ---
    $cr = Rect 20 $geo.ChipY 440 $geo.ChipH
    [Hx]::Shadow($g, $cr, 18, 6)
    [Hx]::Card($g, $cr, 18, $cWhite, $cLine)

    # --- hero-карточка ---
    $hr = Rect 20 $geo.HeroY 440 $geo.HeroH
    [Hx]::Shadow($g, $hr, 22, 7)
    [Hx]::Gradient($g, $hr, 22, $cHero1, $cHero2, [single]12)
    $hp = [Hx]::Rounded($hr, 22)
    $hpen = [System.Drawing.Pen]::new($cHeroBorder)
    $g.DrawPath($hpen, $hp); $hpen.Dispose(); $hp.Dispose()

    $bigOrb = Rect 348 ($geo.HeroY+10) 76 76
    $bo = [System.Drawing.Drawing2D.LinearGradientBrush]::new($bigOrb, $cBlue, $cViolet, [single]45)
    $g.FillEllipse($bo, $bigOrb); $bo.Dispose()
    $gl = [System.Drawing.SolidBrush]::new((ColA 38 255 255 255))
    $g.FillEllipse($gl, (Rect 358 ($geo.HeroY+18) 40 40)); $gl.Dispose()
    $letter = "G"
    try { if ($script:currentGame) { $letter = $script:currentGame.Substring(0,1).ToUpper() } } catch {}
    [Hx]::Txt($g, $letter, $fOrb, $cOnAccent, $bigOrb, $flagsC)

    [Hx]::Txt($g, "АКТИВНАЯ ИГРА", $fCap, $cBlue, (Rect 36 ($geo.HeroY+13) 240 16), $flagsL)
    [Hx]::Txt($g, "$($script:currentGame)", $fHero, $cText, (Rect 36 ($geo.HeroY+31) 296 34), $flagsL)
    $ratio = 0
    if ($script:totalCount -gt 0) { $ratio = $script:selCount / $script:totalCount }
    [Hx]::Txt($g, "Выбрано $($script:selCount) из $($script:totalCount) · готово к запуску",
              $fHint, $cDim, (Rect 36 ($geo.HeroY+63) 296 16), $flagsL)
    [Hx]::Gradient($g, (Rect 36 ($geo.HeroY+82) 280 6), 3, $cTrack, $cTrack, [single]0)
    $pw = [int](280 * $ratio)
    if ($pw -gt 5) { [Hx]::Gradient($g, (Rect 36 ($geo.HeroY+82) $pw 6), 3, $cBlue, $cBlue2, [single]0) }

    # --- подпись к списку ---
    [Hx]::Txt($g, "ЧТО ЗАПУСКАЕМ", $fCap, $cDim, (Rect 20 $geo.SecY 240 20), $flagsL)

    # --- карточка пунктов ---
    $ir = Rect 20 $geo.ItemY 440 $geo.ItemH
    [Hx]::Shadow($g, $ir, 18, 6)
    [Hx]::Card($g, $ir, 18, $cWhite, $cLine)
    $items = @($games[$script:currentGame])
    $sep = [System.Drawing.Pen]::new($cLine)
    for ($i = 0; $i -lt $script:itemRows; $i++) {
        $ry = $geo.ItemY + 10 + $i*54
        if ($i -lt $items.Count) {
            $item = $items[$i]
            if ($script:hoverRow -eq $i) {
                [Hx]::Gradient($g, (Rect 28 ($ry+2) 424 50), 12, $cHover, $cHover, [single]0)
            }
            if ($i -lt @($script:toggles).Count -and $script:toggles[$i].Checked) {
                [Hx]::Gradient($g, (Rect 28 ($ry+13) 4 28), 2, $cBlue, $cBlue2, [single]90)
            }
            if ($i -gt 0) { $g.DrawLine($sep, 36, $ry, 444, $ry) }

            $ic = Rect 44 ($ry+10) 34 34
            [Hx]::Gradient($g, $ic, 17, $cIc1, $cIc2, [single]45)
            $ch = "•"
            try { if ($item.Name) { $ch = $item.Name.Substring(0,1).ToUpper() } } catch {}
            [Hx]::Txt($g, $ch, $fIcon, $cBlue, $ic, $flagsC)

            [Hx]::Txt($g, "$($item.Name)", $fItem, $cText, (Rect 90 ($ry+7) 300 20), $flagsL)
            [Hx]::Txt($g, (Get-ItemHint $item), $fHint, $cDim, (Rect 90 ($ry+28) 300 16), $flagsL)
        } elseif ($i -eq $items.Count) {
            $pr = Rect 28 ($ry+4) 424 46
            $dp = [System.Drawing.Pen]::new($cDash)
            $dp.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash
            $pp = [Hx]::Rounded($pr, 12)
            $g.DrawPath($dp, $pp); $dp.Dispose(); $pp.Dispose()
            [Hx]::Txt($g, "+ Добавить программу в «$($script:currentGame)»", $fHint, $cBlue, $pr, $flagsC)
        }
    }
    $sep.Dispose()

    # --- тень под главной кнопкой ---
    [Hx]::Shadow($g, (Rect 20 $geo.PrimaryY 440 $geo.PrimaryH), 24, 7)

    # --- карточка журнала ---
    $lr = Rect 20 $geo.LogY 440 $geo.LogH
    [Hx]::Shadow($g, $lr, 18, 6)
    [Hx]::Card($g, $lr, 18, $cWhite, $cLine)
    $dot = [System.Drawing.SolidBrush]::new($cBlue)
    $g.FillEllipse($dot, (Rect 30 ($geo.LogY+18) 8 8)); $dot.Dispose()
    [Hx]::Txt($g, "Журнал запуска", $fSmall, $cText, (Rect 46 ($geo.LogY+8) 200 26), $flagsL)
    if ($script:logExpanded) {
        [Hx]::Gradient($g, (Rect 30 ($geo.LogY+36) 420 ($geo.LogH-44)), 12,
                       $cLogBg, $cLogBg, [single]0)
    } else {
        [Hx]::Txt($g, "развернуть", $fHint, $cDim, (Rect 250 ($geo.LogY+10) 90 22), $flagsR)
    }

    # --- подвал ---
    $fd = [System.Drawing.SolidBrush]::new($cBlue)
    $g.FillEllipse($fd, (Rect 20 ($geo.FooterY+7) 8 8)); $fd.Dispose()
    [Hx]::Txt($g, $script:statusText, $fHint, $cDim, (Rect 34 $geo.FooterY 250 20), $flagsL)
}

# ===== Форма =====
$form = [System.Windows.Forms.Form]::new()
$form.Text = "Game Launcher"
$form.FormBorderStyle = "None"
$form.StartPosition = "CenterScreen"
$form.ClientSize = [System.Drawing.Size]::new(480, $formH)
$form.BackColor = $cPage
$form.ForeColor = $cText
$form.Font = $fSmall
$form.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::None
$form.MaximizeBox = $false
$form.ShowInTaskbar = $true
$form.KeyPreview = $true
$form.Add_KeyDown({
    param($snd,$ev)
    if ($ev.KeyCode -eq [System.Windows.Forms.Keys]::Escape) { $snd.Close() }
})
if (Test-Path $iconPath) { try { $form.Icon = [System.Drawing.Icon]::new($iconPath) } catch {} }
$form.Add_Shown({ param($s,$e) [Hx]::Chrome($s.Handle); $s.Activate() })

$canvas = [System.Windows.Forms.Panel]::new()
$canvas.Dock = "Fill"
$canvas.BackColor = $cPage
[Hx]::PaintEnable($canvas)
$form.Controls.Add($canvas)
$script:canvas = $canvas
$canvas.Add_Paint({ param($s,$e) Draw-Canvas $e.Graphics })
$canvas.Add_MouseDown({
    param($s,$e)
    if ($e.Button -ne [System.Windows.Forms.MouseButtons]::Left) { return }
    if ($e.Y -lt 72) { [Hx]::Drag($form.Handle); return }
    $geo = $script:geo
    if ($e.X -ge 20 -and $e.X -le 460 -and
        $e.Y -ge $geo.ItemY -and $e.Y -le ($geo.ItemY + $geo.ItemH)) {
        $idx = [int][Math]::Floor(($e.Y - $geo.ItemY - 10) / 54)
        $items = @($games[$script:currentGame])
        if ($idx -eq $items.Count -and $idx -lt $script:itemRows) { $btnAddGame.PerformClick() }
    }
})
$canvas.Add_MouseMove({
    param($s,$e)
    $geo = $script:geo
    $new = -1
    if ($e.X -ge 28 -and $e.X -le 452 -and
        $e.Y -ge ($geo.ItemY+10) -and $e.Y -le ($geo.ItemY+10+$script:itemRows*54)) {
        $new = [int][Math]::Floor(($e.Y - $geo.ItemY - 10) / 54)
        if ($new -ge @($games[$script:currentGame]).Count) { $new = -1 }
    }
    if ($new -ne $script:hoverRow) { $script:hoverRow = $new; $script:canvas.Invalidate() }
})
$canvas.Add_MouseLeave({ if ($script:hoverRow -ne -1) { $script:hoverRow = -1; $script:canvas.Invalidate() } })

# ===== Кнопки окна =====
$btnMin = [HxButton]::new()
$btnMin.Kind = "window"; $btnMin.Text = "−"; $btnMin.Font = $fWin
$btnMin.Location = [System.Drawing.Point]::new(400, 20)
$btnMin.Size = [System.Drawing.Size]::new(32, 32); $btnMin.Radius = 10
$btnMin.Add_Click({ $form.WindowState = [System.Windows.Forms.FormWindowState]::Minimized })
$form.Controls.Add($btnMin)

$btnWinClose = [HxButton]::new()
$btnWinClose.Kind = "window"; $btnWinClose.Text = "×"; $btnWinClose.Font = $fWin
$btnWinClose.Location = [System.Drawing.Point]::new(436, 20)
$btnWinClose.Size = [System.Drawing.Size]::new(32, 32); $btnWinClose.Radius = 10
$btnWinClose.Add_Click({ $form.Close() })
$form.Controls.Add($btnWinClose)

# ===== Переключатель светлой / тёмной темы =====
$btnTheme = [HxButton]::new()
$btnTheme.Kind = "window"; $btnTheme.Text = "◐"; $btnTheme.Font = $fWin
$btnTheme.Location = [System.Drawing.Point]::new(362, 20)
$btnTheme.Size = [System.Drawing.Size]::new(32, 32); $btnTheme.Radius = 10
$btnTheme.OnCard = $false
$tt = [System.Windows.Forms.ToolTip]::new()
$tt.SetToolTip($btnTheme, "Переключить тёмную / светлую тему")
$btnTheme.Add_Click({ Set-Theme (-not $script:darkTheme) })
$form.Controls.Add($btnTheme)
$script:btnTheme = $btnTheme

# ===== + ИГРА =====
$btnAddGame = [HxButton]::new()
$btnAddGame.Kind = "accentText"; $btnAddGame.Text = "+ ИГРА"; $btnAddGame.Font = $fSmall
$btnAddGame.Location = [System.Drawing.Point]::new(376, ($geo.CapY-8))
$btnAddGame.Size = [System.Drawing.Size]::new(84, 28); $btnAddGame.Radius = 14
$form.Controls.Add($btnAddGame)

# ===== Чипы игр =====
$pillW = [int]((440 - 24 - 3*8) / 4)
$pills = @()
$row = 0; $col = 0
foreach ($g in $gameList) {
    $b = [HxButton]::new()
    $b.Kind = "chip"; $b.Text = "$g"; $b.Tag = $g; $b.OnCard = $true
    $b.Font = [System.Drawing.Font]::new($uiFont, 9, $fb)
    $b.Radius = 11
    $b.Location = [System.Drawing.Point]::new((32 + $col*($pillW+8)), ($geo.ChipY + 12 + $row*42))
    $b.Size = [System.Drawing.Size]::new($pillW, 34)
    $b.Add_Click({
        $sel = $this.Tag
        foreach ($p in $script:pills) { $p.Selected = ($p.Tag -eq $sel) }
        Show-Game $sel
    })
    $form.Controls.Add($b)
    $pills += $b
    $col++
    if ($col -ge 4) { $col = 0; $row++ }
}
$script:pills = $pills

# ===== Текстовые кнопки =====
$btnAll = [HxButton]::new()
$btnAll.Kind = "text"; $btnAll.Text = "Выбрать все"; $btnAll.Font = $fHint
$btnAll.Location = [System.Drawing.Point]::new(296, ($geo.SecY-4))
$btnAll.Size = [System.Drawing.Size]::new(78, 26); $btnAll.Radius = 8
$btnAll.Add_Click({ foreach ($t in $script:toggles) { $t.Checked = $true }; Update-Status })
$form.Controls.Add($btnAll)

$btnNone = [HxButton]::new()
$btnNone.Kind = "text"; $btnNone.Text = "Снять все"; $btnNone.Font = $fHint
$btnNone.Location = [System.Drawing.Point]::new(378, ($geo.SecY-4))
$btnNone.Size = [System.Drawing.Size]::new(82, 26); $btnNone.Radius = 8
$btnNone.Add_Click({ foreach ($t in $script:toggles) { $t.Checked = $false }; Update-Status })
$form.Controls.Add($btnNone)

# ===== Основные кнопки =====
$btnLaunch = [HxButton]::new()
$btnLaunch.Kind = "primary"; $btnLaunch.Text = "ЗАПУСТИТЬ  →"; $btnLaunch.Font = $fBtn
$btnLaunch.Location = [System.Drawing.Point]::new(20, $geo.PrimaryY)
$btnLaunch.Size = [System.Drawing.Size]::new(440, $geo.PrimaryH); $btnLaunch.Radius = 24
$form.Controls.Add($btnLaunch)

$btnCloseLaunch = [HxButton]::new()
$btnCloseLaunch.Kind = "danger"; $btnCloseLaunch.Text = "Закрыть всё запущенное"; $btnCloseLaunch.Font = $fSmall
$btnCloseLaunch.Location = [System.Drawing.Point]::new(20, $geo.SecondY)
$btnCloseLaunch.Size = [System.Drawing.Size]::new(440, $geo.SecondH); $btnCloseLaunch.Radius = 19
$form.Controls.Add($btnCloseLaunch)

# ===== Журнал =====
$logBox = [System.Windows.Forms.RichTextBox]::new()
$logBox.Location = [System.Drawing.Point]::new(32, ($geo.LogY+38))
$logBox.Size = [System.Drawing.Size]::new(416, 84)
$logBox.Multiline = $true
$logBox.ReadOnly = $true
$logBox.ScrollBars = [System.Windows.Forms.RichTextBoxScrollBars]::Vertical
$logBox.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$logBox.BackColor = $cLogBg
$logBox.ForeColor = $cDim
$logBox.Font = $fMono
$logBox.Visible = $false
$form.Controls.Add($logBox)

$btnLogClear = [HxButton]::new()
$btnLogClear.Kind = "text"; $btnLogClear.Text = "Очистить"; $btnLogClear.Font = $fHint
$btnLogClear.OnCard = $true
$btnLogClear.Location = [System.Drawing.Point]::new(348, ($geo.LogY+8))
$btnLogClear.Size = [System.Drawing.Size]::new(68, 26); $btnLogClear.Radius = 8
$btnLogClear.Add_Click({ $logBox.Clear() })
$form.Controls.Add($btnLogClear)

$btnLogToggle = [HxButton]::new()
$btnLogToggle.Kind = "text"; $btnLogToggle.Text = "▼"; $btnLogToggle.Font = $fSmall
$btnLogToggle.OnCard = $true
$btnLogToggle.Location = [System.Drawing.Point]::new(422, ($geo.LogY+8))
$btnLogToggle.Size = [System.Drawing.Size]::new(28, 26); $btnLogToggle.Radius = 8
$btnLogToggle.Add_Click({
    $script:logExpanded = -not $script:logExpanded
    $geo2 = $script:geo
    $geo2.LogH = if ($script:logExpanded) { 132 } else { 44 }
    $geo2.FooterY = $geo2.LogY + $geo2.LogH + 10
    $logBox.Visible = $script:logExpanded
    $btnLogToggle.Text = if ($script:logExpanded) { "▲" } else { "▼" }
    $btnThemeFooter.Location = [System.Drawing.Point]::new(296, ($geo2.FooterY - 3))
    $form.ClientSize = [System.Drawing.Size]::new(480, ($geo2.FooterY + 38))
    $script:canvas.Invalidate()
})
$form.Controls.Add($btnLogToggle)

$btnThemeFooter = [HxButton]::new()
$btnThemeFooter.Kind = "text"
$btnThemeFooter.Text = if ($script:darkTheme) { "◑ Светлая тема" } else { "◐ Тёмная тема" }
$btnThemeFooter.Font = $fHint
$btnThemeFooter.Location = [System.Drawing.Point]::new(296, ($geo.FooterY - 3))
$btnThemeFooter.Size = [System.Drawing.Size]::new(164, 26)
$btnThemeFooter.Radius = 8
$btnThemeFooter.OnCard = $false
$btnThemeFooter.Add_Click({ Set-Theme (-not $script:darkTheme) })
$form.Controls.Add($btnThemeFooter)
$script:btnThemeFooter = $btnThemeFooter

# ===== Фиксированный пул свитчей =====
# ВАЖНО: создаём ОДИН РАЗ. Раньше при каждом переключении игры свитчи
# удалялись и добавлялись заново: Controls.Add кладёт их в конец коллекции,
# т.е. ПОД фоновый canvas (у которого SendToBack), и они исчезали с экрана.
$script:allSwitches = @()
$script:suppressStatus = $false
for ($i = 0; $i -lt $script:itemRows; $i++) {
    $sw = [HxSwitch]::new()
    $sw.OnCard = $true
    $sw.Visible = $false
    $sw.Location = [System.Drawing.Point]::new(398, ($script:geo.ItemY + 10 + $i*54 + 12))
    $sw.Add_CheckedChanged({ if (-not $script:suppressStatus) { Update-Status } })
    $form.Controls.Add($sw)
    $sw.BringToFront()
    $script:allSwitches += $sw
}

# ===== Переключение игры =====
function Show-Game($g) {
    $script:currentGame = $g
    $script:hoverRow = -1
    $script:suppressStatus = $true
    $items = @($games[$g])
    $script:toggles = @()
    for ($i = 0; $i -lt $script:allSwitches.Count; $i++) {
        $sw = $script:allSwitches[$i]
        if ($i -lt $items.Count) {
            $sw.Tag = $items[$i]
            $sw.Checked = [bool]$items[$i].Default
            $sw.Visible = $true
            $sw.BringToFront()
            $script:toggles += $sw
        } else {
            $sw.Visible = $false
            $sw.Checked = $false
            $sw.Tag = $null
        }
    }
    $script:suppressStatus = $false
    Update-Status
    $script:canvas.Invalidate()
}

# ===== Окно управления играми =====
$btnAddGame.Add_Click({
    $script:needRestart = $false

    $dlg = [System.Windows.Forms.Form]::new()
    $dlg.Text = "Управление играми"
    $dlg.FormBorderStyle = "None"
    $dlg.StartPosition = "CenterParent"
    $dlg.ClientSize = [System.Drawing.Size]::new(500, 630)
    $dlg.BackColor = $cPage
    $dlg.Font = $fSmall
    $dlg.ShowInTaskbar = $true
    $dlg.KeyPreview = $true
    if (Test-Path $iconPath) { try { $dlg.Icon = [System.Drawing.Icon]::new($iconPath) } catch {} }
    $dlg.Add_Shown({ param($s,$e) [Hx]::Chrome($s.Handle) })

    $dcv = [System.Windows.Forms.Panel]::new()
    $dcv.Dock = "Fill"; $dcv.BackColor = $cPage
    [Hx]::PaintEnable($dcv)
    $dlg.Controls.Add($dcv)
    $dcv.Add_Paint({
        param($s,$e)
        $g = $e.Graphics
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
        $W = $s.ClientSize.Width; $H = $s.ClientSize.Height
        $g.Clear($cPage)
        Draw-Glow $g (Rect ($W-220) -80 320 320) $cGlow1 $cGlowEdge
        $card = Rect 16 70 468 540
        [Hx]::Shadow($g, $card, 20, 6)
        [Hx]::Card($g, $card, 20, $cWhite, $cLine)
        [Hx]::Txt($g, "Управление играми", $fTitle, $cText, (Rect 24 16 340 32), $flagsL)
        [Hx]::Txt($g, "Добавь игру, программу или импортируй библиотеку Steam",
                  $fHint, $cDim, (Rect 26 48 400 18), $flagsL)
    })
    $dcv.Add_MouseDown({
        param($s,$e)
        if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left -and $e.Y -lt 66) {
            [Hx]::Drag($s.Parent.Handle)
        }
    })

    $btnDlgClose = [HxButton]::new()
    $btnDlgClose.Kind = "window"; $btnDlgClose.Text = "×"; $btnDlgClose.Font = $fWin
    $btnDlgClose.OnCard = $false
    $btnDlgClose.Location = [System.Drawing.Point]::new(452, 20)
    $btnDlgClose.Size = [System.Drawing.Size]::new(32, 32); $btnDlgClose.Radius = 10
    $btnDlgClose.Add_Click({ $this.FindForm().Close() })
    $dlg.Controls.Add($btnDlgClose)

    $tabs = [System.Windows.Forms.TabControl]::new()
    $tabs.Location = [System.Drawing.Point]::new(28, 82)
    $tabs.Size = [System.Drawing.Size]::new(444, 510)
    $tabs.DrawMode = [System.Windows.Forms.TabDrawMode]::OwnerDrawFixed
    $tabs.SizeMode = [System.Windows.Forms.TabSizeMode]::Fixed
    $tabs.ItemSize = [System.Drawing.Size]::new(104, 30)
    $tabs.Font = $fSmall
    $tabs.ForeColor = $cText
    $tabNew   = [System.Windows.Forms.TabPage]::new("Новая игра")
    $tabProg  = [System.Windows.Forms.TabPage]::new("+ Программа")
    $tabSteam = [System.Windows.Forms.TabPage]::new("Steam")
    $tabMy    = [System.Windows.Forms.TabPage]::new("Мои игры")
    $tabs.TabPages.AddRange([System.Windows.Forms.TabPage[]]@($tabNew, $tabProg, $tabSteam, $tabMy))
    foreach ($tp in @($tabNew, $tabProg, $tabSteam, $tabMy)) {
        $tp.BackColor = $cWhite
        $tp.ForeColor = $cText
        $tp.UseVisualStyleBackColor = $false
    }
    $tabs.Add_DrawItem({
        param($s,$e)
        $g = $e.Graphics
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $b = [System.Drawing.Rectangle]::new(($e.Bounds.X+2), ($e.Bounds.Y+2),
                                             ($e.Bounds.Width-4), ($e.Bounds.Height-4))
        $sel = ($e.State -band [System.Windows.Forms.DrawItemState]::Selected) -ne 0
        if ($sel) { [Hx]::Gradient($g, $b, 11, $cBlue, $cBlue2, [single]10); $col = $cWhite }
        else      { [Hx]::Gradient($g, $b, 11, $cTabIdle, $cTabIdle, [single]0); $col = $cDim }
        [Hx]::Txt($g, $s.TabPages[$e.Index].Text, $fSmall, $col, $b, $flagsC)
    })
    $dlg.Controls.Add($tabs)

    function New-HxLabel($parent, $text, $x, $y, $w) {
        $l = [System.Windows.Forms.Label]::new()
        $l.Text = $text
        $l.Location = [System.Drawing.Point]::new($x, $y)
        $l.Size = [System.Drawing.Size]::new($w, 18)
        $l.ForeColor = $cDim
        $l.BackColor = $cWhite
        $l.Font = $fHint
        $parent.Controls.Add($l)
        return $l
    }
    function New-HxText($parent, $x, $y, $w) {
        $t = [System.Windows.Forms.TextBox]::new()
        $t.Location = [System.Drawing.Point]::new($x, $y)
        $t.Size = [System.Drawing.Size]::new($w, 26)
        $t.BackColor = $cLogBg
        $t.ForeColor = $cText
        $t.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
        $t.Font = $fSmall
        $parent.Controls.Add($t)
        return $t
    }
    function New-HxBtn($parent, $text, $x, $y, $w, $h, $kind="ghost") {
        $b = [HxButton]::new()
        $b.Text = $text; $b.Kind = $kind; $b.Font = $fSmall
        $b.OnCard = $true
        $b.Location = [System.Drawing.Point]::new($x, $y)
        $b.Size = [System.Drawing.Size]::new($w, $h)
        $b.Radius = 12
        $parent.Controls.Add($b)
        return $b
    }

    # --- Новая игра ---
    [void](New-HxLabel $tabNew "Название игры (вкладка в лаунчере):" 15 15 390)
    $txtGame = New-HxText $tabNew 15 35 390
    [void](New-HxLabel $tabNew "Название пункта запуска:" 15 65 390)
    $txtItem = New-HxText $tabNew 15 85 390
    [void](New-HxLabel $tabNew "Путь к exe (или steam://... для игр Steam):" 15 115 390)
    $txtPath = New-HxText $tabNew 15 135 270
    $btnBrowse = New-HxBtn $tabNew "Обзор..." 295 134 110 28 "accentText"
    [void](New-HxLabel $tabNew "Аргументы запуска (необязательно):" 15 165 390)
    $txtArgs = New-HxText $tabNew 15 185 390
    $chk = [HxSwitch]::new()
    $chk.Location = [System.Drawing.Point]::new(15, 215)
    $chk.Checked = $true
    $tabNew.Controls.Add($chk)
    [void](New-HxLabel $tabNew "Включено по умолчанию" 70 218 220)
    $btnAdd = New-HxBtn $tabNew "ДОБАВИТЬ ИГРУ" 15 250 390 38 "primary"
    $btnAdd.Font = $fBtn
    [void](New-HxLabel $tabNew "Позже в эту игру можно добавить ещё программы" 15 300 390)
    [void](New-HxLabel $tabNew "на вкладке «+ Программа»." 15 316 390)

    # --- + Программа ---
    [void](New-HxLabel $tabProg "В какую игру добавить:" 15 15 390)
    $cboGame = [System.Windows.Forms.ComboBox]::new()
    $cboGame.Location = [System.Drawing.Point]::new(15, 35)
    $cboGame.Size = [System.Drawing.Size]::new(390, 26)
    $cboGame.DropDownStyle = "DropDownList"
    $cboGame.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $cboGame.BackColor = $cWhite
    $cboGame.ForeColor = $cText
    $cboGame.Font = $fSmall
    $tabProg.Controls.Add($cboGame)
    [void](New-HxLabel $tabProg "Название программы (галочка в лаунчере):" 15 65 390)
    $txtPName = New-HxText $tabProg 15 85 390
    [void](New-HxLabel $tabProg "Путь к exe:" 15 115 390)
    $txtPPath = New-HxText $tabProg 15 135 270
    $btnBrowse2 = New-HxBtn $tabProg "Обзор..." 295 134 110 28 "accentText"
    [void](New-HxLabel $tabProg "Аргументы (если нужны):" 15 165 220)
    [void](New-HxLabel $tabProg "Задержка, сек:" 265 165 140)
    $txtPArgs = New-HxText $tabProg 15 185 240
    $txtPDelay = New-HxText $tabProg 265 185 140
    $chkP = [HxSwitch]::new()
    $chkP.Location = [System.Drawing.Point]::new(15, 215)
    $chkP.Checked = $false
    $tabProg.Controls.Add($chkP)
    [void](New-HxLabel $tabProg "Включено по умолчанию" 70 218 220)
    $btnAddProg = New-HxBtn $tabProg "ДОБАВИТЬ ПРОГРАММУ" 15 250 390 38 "primary"
    $btnAddProg.Font = $fBtn
    [void](New-HxLabel $tabProg "Например: трейнер, Radmin VPN, VK-чат." 15 300 390)
    [void](New-HxLabel $tabProg "Добавится отдельной галочкой в выбранную игру." 15 316 390)

    # --- Steam ---
    $btnFind = New-HxBtn $tabSteam "НАЙТИ УСТАНОВЛЕННЫЕ ИГРЫ STEAM" 15 15 390 32 "accentText"
    $lstSteam = [System.Windows.Forms.CheckedListBox]::new()
    $lstSteam.Location = [System.Drawing.Point]::new(15, 55)
    $lstSteam.Size = [System.Drawing.Size]::new(390, 320)
    $lstSteam.CheckOnClick = $true
    $lstSteam.IntegralHeight = $false
    $lstSteam.BorderStyle = [System.Windows.Forms.BorderStyle]::None
    $lstSteam.BackColor = $cLogBg
    $lstSteam.ForeColor = $cText
    $lstSteam.Font = $fSmall
    $tabSteam.Controls.Add($lstSteam)
    $btnImport = New-HxBtn $tabSteam "ИМПОРТИРОВАТЬ ОТМЕЧЕННЫЕ" 15 385 390 38 "primary"
    $btnImport.Font = $fBtn
    $lblSteamStatus = New-HxLabel $tabSteam "" 15 432 390
    [void](New-HxLabel $tabSteam "Игры добавятся через steam:// (безопасно для VAC)." 15 455 390)

    # --- Мои игры ---
    [void](New-HxLabel $tabMy "Удалять можно только добавленные игры" 15 15 390)
    [void](New-HxLabel $tabMy "(стандартные защищены от случайного удаления)." 15 31 390)
    $lstMine = [System.Windows.Forms.ListBox]::new()
    $lstMine.Location = [System.Drawing.Point]::new(15, 60)
    $lstMine.Size = [System.Drawing.Size]::new(390, 320)
    $lstMine.IntegralHeight = $false
    $lstMine.BorderStyle = [System.Windows.Forms.BorderStyle]::None
    $lstMine.BackColor = $cLogBg
    $lstMine.ForeColor = $cText
    $lstMine.Font = $fSmall
    $tabMy.Controls.Add($lstMine)
    $btnDel = New-HxBtn $tabMy "УДАЛИТЬ ВЫБРАННУЮ" 15 390 390 38 "danger"
    $btnDel.Font = $fBtn

    function Refresh-Lists {
        $names = @(Get-CustomGameNames)
        $lstMine.Items.Clear()
        foreach ($n in $names) { [void]$lstMine.Items.Add($n) }
        $cboGame.Items.Clear()
        foreach ($n in $names) { [void]$cboGame.Items.Add($n) }
        if ($cboGame.Items.Count -gt 0) { $cboGame.SelectedIndex = 0 }
    }
    Refresh-Lists

    $btnBrowse.Add_Click({
        $fd = [System.Windows.Forms.OpenFileDialog]::new()
        $fd.Filter = "Программа (*.exe)|*.exe"
        if ($fd.ShowDialog($this.FindForm()) -eq "OK") { $txtPath.Text = $fd.FileName }
    })
    $btnBrowse2.Add_Click({
        $fd = [System.Windows.Forms.OpenFileDialog]::new()
        $fd.Filter = "Программа (*.exe)|*.exe"
        if ($fd.ShowDialog($this.FindForm()) -eq "OK") { $txtPPath.Text = $fd.FileName }
    })

    $btnAdd.Add_Click({
        $gName = $txtGame.Text.Trim()
        if (-not $gName) {
            [void](Show-HxDialog "Нет названия" "Введи название игры." "warning" "OK" $dlg); return
        }
        if ($gName -match '[\[\]\r\n=]') {
            [void](Show-HxDialog "Плохое имя" "Название не должно содержать [ ] = или переносы." "warning" "OK" $dlg); return
        }
        if ((Get-CustomGameNames) -contains $gName) {
            [void](Show-HxDialog "Уже есть" "Игра ""$gName"" уже есть. Чтобы добавить в неё программу — вкладка «+ Программа»." "warning" "OK" $dlg); return
        }
        $iName = $txtItem.Text.Trim()
        if (-not $iName) { $iName = $gName }
        $iPath = $txtPath.Text.Trim()
        if (-not $iPath) {
            [void](Show-HxDialog "Нет пути" "Выбери файл игры (Обзор) или впиши steam://ссылку." "warning" "OK" $dlg); return
        }
        $defVal = if ($chk.Checked) { "1" } else { "0" }
        $block = "[$gName]`r`n1Name=$iName`r`n1Path=$iPath`r`n"
        if ($txtArgs.Text.Trim()) { $block += "1Args=$($txtArgs.Text.Trim())`r`n" }
        $block += "1Default=$defVal`r`n"
        Add-ConfigSection $block
        Refresh-Lists
        $txtGame.Clear(); $txtItem.Clear(); $txtPath.Clear(); $txtArgs.Clear()
        $script:needRestart = $true
        [void](Show-HxDialog "Готово" "Игра ""$gName"" добавлена!`nЛаунчер перезапустится после закрытия этого окна." "success" "OK" $dlg)
    })

    $btnAddProg.Add_Click({
        if ($cboGame.SelectedIndex -lt 0) {
            [void](Show-HxDialog "Нет игр" "Сначала создай игру на вкладке «Новая игра»." "warning" "OK" $dlg); return
        }
        $selGame = $cboGame.SelectedItem
        $iName = $txtPName.Text.Trim()
        $iPath = $txtPPath.Text.Trim()
        if (-not $iName -or -not $iPath) {
            [void](Show-HxDialog "Не заполнено" "Заполни название и путь." "warning" "OK" $dlg); return
        }
        $idx = (Get-MaxItemIndex $selGame) + 1
        $defVal = if ($chkP.Checked) { "1" } else { "0" }
        $block = "${idx}Name=$iName`r`n${idx}Path=$iPath`r`n"
        if ($txtPArgs.Text.Trim()) { $block += "${idx}Args=$($txtPArgs.Text.Trim())`r`n" }
        $d = 0; [void][int]::TryParse($txtPDelay.Text.Trim(), [ref]$d)
        if ($d -gt 0) { $block += "${idx}Delay=$d`r`n" }
        $block += "${idx}Default=$defVal`r`n"
        if (-not (Add-ItemToSection $selGame $block)) {
            [void](Show-HxDialog "Ошибка" "Не нашёл секцию [$selGame] в конфиге." "danger" "OK" $dlg); return
        }
        $txtPName.Clear(); $txtPPath.Clear(); $txtPArgs.Clear(); $txtPDelay.Clear()
        $script:needRestart = $true
        [void](Show-HxDialog "Готово" "Программа ""$iName"" добавлена в ""$selGame""!`nЛаунчер перезапустится после закрытия этого окна." "success" "OK" $dlg)
    })

    $btnFind.Add_Click({
        $lstSteam.Items.Clear()
        $lblSteamStatus.Text = "Ищу..."
        $dlg.Refresh()
        $found = Get-SteamGames
        $configRaw = ""
        try { $configRaw = [System.IO.File]::ReadAllText($configFile) } catch {}
        $newCount = 0
        foreach ($sg in $found) {
            $already = $configRaw -match [regex]::Escape("steam://rungameid/$($sg.AppId)")
            [void]$lstSteam.Items.Add($sg.Name, (-not $already))
            if (-not $already) { $newCount++ }
        }
        $lblSteamStatus.Text = "Найдено игр: $($found.Count), новых: $newCount"
        if ($found.Count -eq 0) { $lblSteamStatus.Text = "Steam не найден или игр нет." }
    })

    $btnImport.Add_Click({
        $sel = @($lstSteam.CheckedItems)
        if ($sel.Count -eq 0) {
            [void](Show-HxDialog "Ничего не выбрано" "Отметь игры галочками сначала." "warning" "OK" $dlg); return
        }
        $steamGames = Get-SteamGames
        $added = 0
        foreach ($name in $sel) {
            $sg = $steamGames | Where-Object { $_.Name -eq $name } | Select-Object -First 1
            if (-not $sg) { continue }
            $safe = ($name -replace '[\[\]=\r\n]', '').Trim()
            if (-not $safe) { continue }
            $block = "[$safe]`r`n1Name=$safe`r`n1Path=steam://rungameid/$($sg.AppId)`r`n1Default=1`r`n"
            Add-ConfigSection $block
            $added++
        }
        Refresh-Lists
        $script:needRestart = $true
        [void](Show-HxDialog "Готово" "Импортировано игр: $added.`nЛаунчер перезапустится после закрытия этого окна." "success" "OK" $dlg)
    })

    $btnDel.Add_Click({
        if ($lstMine.SelectedIndex -lt 0) {
            [void](Show-HxDialog "Ничего не выбрано" "Сначала выбери игру в списке." "warning" "OK" $dlg); return
        }
        $selGame = $lstMine.SelectedItem
        $confirm = Show-HxDialog "Удалить игру?" "Удалить игру ""$selGame"" из лаунчера?`nФайлы игры не тронем — только запись в конфиге." "danger" "YesNo" $dlg
        if ($confirm -ne "Yes") { return }
        $out = @(); $skip = $false
        foreach ($line in (Get-Content $configFile -Encoding UTF8)) {
            if ($line -match '^\s*\[(.+)\]\s*$') { $skip = ($Matches[1] -eq $selGame) }
            if (-not $skip) { $out += $line }
        }
        while ($out.Count -gt 0 -and "$($out[$out.Count - 1])".Trim() -eq "") { $out = $out[0..($out.Count - 2)] }
        [System.IO.File]::WriteAllLines($configFile, $out, [System.Text.UTF8Encoding]::new($false))
        Refresh-Lists
        $script:needRestart = $true
        [void](Show-HxDialog "Готово" "Игра ""$selGame"" удалена." "success" "OK" $dlg)
    })

    $dlg.Add_KeyDown({
        param($snd,$ev)
        if ($ev.KeyCode -eq [System.Windows.Forms.Keys]::Escape) { $snd.Close() }
    })
    # Фоновая панель с Dock=Fill была добавлена первой и закрывала все вкладки
    $dcv.SendToBack()
    $tabs.BringToFront()
    $btnDlgClose.BringToFront()

    $dlg.Add_FormClosed({ if ($script:needRestart) { Restart-Launcher } })
    [void]$dlg.ShowDialog($form)
})

# ===== Запуск =====
$btnLaunch.Add_Click({
    $btnLaunch.Enabled = $false
    $btnLaunch.Text = "ЗАПУСКАЕМ…"
    $logBox.Clear()
    Write-LogAuto "=== $script:currentGame — $(Get-Date -Format 'HH:mm:ss') ==="
    $launchedAny = $false

    foreach ($t in $script:toggles) {
        if (-not $t.Checked) { continue }
        $item = $t.Tag

        if ($item.Delay -gt 0 -and $launchedAny) {
            for ($i = $item.Delay; $i -gt 0; $i--) {
                Write-LogAuto "Ожидание $i сек. перед запуском '$($item.Name)'..."
                Start-Sleep -Seconds 1
                [System.Windows.Forms.Application]::DoEvents()
            }
        }

        $procNames = Get-ProcNames $item
        try {
            if ($item.Path -like "*://*") {
                Start-Process -FilePath $item.Path | Out-Null
                if ($procNames.Count -gt 0) { $script:launchedProcs += @{ Name = $item.Name; ProcNames = $procNames } }
                Write-LogAuto "[OK] $($item.Name)"
            }
            elseif ($item.Args) {
                Start-Process -FilePath $item.Path -ArgumentList $item.Args | Out-Null
                if ($procNames.Count -gt 0) { $script:launchedProcs += @{ Name = $item.Name; ProcNames = $procNames } }
                Write-LogAuto "[OK] $($item.Name)"
            }
            else {
                $wd = $null
                try { $wd = Split-Path $item.Path -ErrorAction Stop } catch {}
                Start-Process -FilePath $item.Path -WorkingDirectory $wd | Out-Null
                if ($procNames.Count -gt 0) { $script:launchedProcs += @{ Name = $item.Name; ProcNames = $procNames } }
                Write-LogAuto "[OK] $($item.Name)"
            }
            $launchedAny = $true
        } catch {
            Write-LogAuto "[ERR] $($item.Name): $($_.Exception.Message)"
        }
    }

    if (-not $launchedAny) { Write-LogAuto "Ничего не выбрано." }
    Write-LogAuto "=== Готово ==="
    $script:statusText = if ($launchedAny) { "Запущено · можно играть" } else { "Ничего не выбрано" }
    $btnLaunch.Text = "ЗАПУСТИТЬ  →"
    $btnLaunch.Enabled = $true
    $script:canvas.Invalidate()
})

# ===== Закрытие запущенного =====
$btnCloseLaunch.Add_Click({
    if ($script:launchedProcs.Count -eq 0) {
        Write-LogAuto "Нечего закрывать: лаунчер пока ничего не запускал."
        return
    }
    $names = ($script:launchedProcs | ForEach-Object { "  • $($_.Name)" }) -join "`n"
    $answer = Show-HxDialog "Закрыть запущенные программы" `
        "⚠  СНАЧАЛА СОХРАНИСЬ В ИГРЕ!`n`nБудет закрыто:`n$names`n`nСначала «крестик», потом принудительно.`nДля программ с правами администратора может появиться запрос Windows — нажми «Да»." `
        "danger" "YesNo" $form
    if ($answer -ne "Yes") { Write-LogAuto "Закрытие отменено."; return }

    $btnCloseLaunch.Enabled = $false
    Write-LogAuto "--- Закрываем запущенное ---"
    foreach ($entry in $script:launchedProcs) {
        $procNames = [string[]]@($entry.ProcNames | Where-Object { $_ })
        if ($procNames.Count -eq 0) {
            Write-LogAuto "[?] $($entry.Name): не знаю имя процесса (добавь Proc= в config.ini)"
            continue
        }
        $polite = Test-ProcAlive $procNames
        if ($polite.Count -eq 0) { Write-LogAuto "[—] $($entry.Name): уже закрыто"; continue }
        foreach ($p in $polite) {
            try { $p.Refresh(); if ($p.MainWindowHandle -ne [IntPtr]::Zero) { [void]$p.CloseMainWindow() } } catch {}
        }
        $deadline = (Get-Date).AddSeconds(3)
        while ((Get-Date) -lt $deadline -and (Test-ProcAlive $procNames).Count -gt 0) {
            Start-Sleep -Milliseconds 300
            [System.Windows.Forms.Application]::DoEvents()
        }
        if ((Test-ProcAlive $procNames).Count -eq 0) {
            Write-LogAuto "[OK] $($entry.Name) — закрыто (по-хорошему)"
            continue
        }
        Write-LogAuto "[!] $($entry.Name): не ответила на «крестик», убиваю принудительно"
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $denied = $false; $killed = 0
        while ((Test-ProcAlive $procNames).Count -gt 0 -and $sw.Elapsed.TotalSeconds -lt 10) {
            foreach ($n in $procNames) {
                foreach ($p in @(Get-Process -Name $n -ErrorAction SilentlyContinue)) {
                    if ($p.HasExited) { continue }
                    try { Stop-Process -Id $p.Id -Force -ErrorAction Stop; $killed++ }
                    catch { $denied = $true; break }
                }
                if ($denied) { break }
            }
            if ($denied) { break }
            Start-Sleep -Milliseconds 200
            [System.Windows.Forms.Application]::DoEvents()
        }
        if ($denied) {
            Write-LogAuto "[!] $($entry.Name): нужны права администратора, запрашиваю у Windows..."
            $inner = ($procNames | ForEach-Object {
                "Get-Process -Name '$_' -ErrorAction SilentlyContinue | Stop-Process -Force"
            }) -join "; "
            try {
                Start-Process powershell -Verb RunAs -WindowStyle Hidden -Wait `
                    -ArgumentList @("-NoProfile", "-Command", $inner) -ErrorAction Stop
                Write-LogAuto "[OK] $($entry.Name) — закрыто с правами администратора"
            } catch {
                Write-LogAuto "[ERR] UAC-запрос отклонён: $($_.Exception.Message)"
            }
        }
        Start-Sleep -Seconds 1
        $final = Test-ProcAlive $procNames
        if ($final.Count -eq 0) { Write-LogAuto "[OK] $($entry.Name) — закрыто (убито процессов: $killed)" }
        else { Write-LogAuto "[ERR] $($entry.Name): не смог закрыть ($($final.Count) жив(ы)). Запусти лаунчер от администратора." }
    }
    $script:launchedProcs = @()
    Write-LogAuto "--- Готово ---"
    $script:statusText = "Готово к запуску"
    $btnCloseLaunch.Enabled = $true
    $script:canvas.Invalidate()
})

# ===== Старт =====
$firstGame = @($games.Keys)[0]
foreach ($p in $script:pills) { $p.Selected = ($p.Tag -eq $firstGame) }
Show-Game $firstGame
$canvas.SendToBack()

[void]$form.ShowDialog()
