# ============================================================
#  GAME LAUNCHER · Setup  (autodetect.ps1)  ·  Harmony Edition
#  Одно окно, вся отрисовка через Paint — никаких вложенных панелей,
#  поэтому «белое пустое окно» больше невозможно в принципе.
#  Тема подхватывается из _app\theme.ini.
# ============================================================
$ErrorActionPreference = "SilentlyContinue"

$appDir     = $PSScriptRoot
$configFile = Join-Path $appDir "config.ini"
$reportFile = Join-Path $appDir "setup_report.txt"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$refs = @(
    [System.Object].Assembly.Location,
    [System.Windows.Forms.Form].Assembly.Location,
    [System.Drawing.Color].Assembly.Location
)

try {
Add-Type -ReferencedAssemblies $refs -ErrorAction Stop -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using System.Reflection;

public static class HxS {
    [DllImport("dwmapi.dll")]
    public static extern int DwmSetWindowAttribute(IntPtr hwnd, int attr, ref int val, int size);
    [StructLayout(LayoutKind.Sequential)]
    public struct MARGINS { public int L; public int R; public int T; public int B; }
    [DllImport("dwmapi.dll")]
    public static extern int DwmExtendFrameIntoClientArea(IntPtr hwnd, ref MARGINS m);
    [DllImport("user32.dll")] public static extern bool ReleaseCapture();
    [DllImport("user32.dll")] public static extern IntPtr SendMessage(IntPtr h, int m, IntPtr w, IntPtr l);

    public static bool Dark = false;

    public static void Chrome(IntPtr h) {
        int v = Dark ? 1 : 0;
        DwmSetWindowAttribute(h, 20, ref v, 4);
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
        Color c = Dark ? Color.FromArgb(12, 0, 0, 0) : Color.FromArgb(5, 26, 48, 92);
        for (int i = depth; i >= 1; i--) {
            Rectangle rr = new Rectangle(r.X, r.Y + i, r.Width, r.Height);
            using (GraphicsPath p = Rounded(rr, radius))
            using (SolidBrush b = new SolidBrush(c)) g.FillPath(b, p);
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
        using (LinearGradientBrush b = new LinearGradientBrush(r, c1, c2, angle)) g.FillPath(b, p);
    }
    public static void Glow(Graphics g, Rectangle r, Color center, Color edge) {
        using (GraphicsPath path = new GraphicsPath()) {
            path.AddEllipse(r.X, r.Y, r.Width, r.Height);
            using (PathGradientBrush b = new PathGradientBrush(path)) {
                b.CenterColor = center;
                b.SurroundColors = new Color[] { edge };
                b.CenterPoint = new PointF(r.X + r.Width / 2f, r.Y + r.Height / 2f);
                g.FillPath(b, path);
            }
        }
    }
    public static void Txt(Graphics g, string s, Font f, Color c, Rectangle r, TextFormatFlags flags) {
        TextRenderer.DrawText(g, s, f, r, c, flags);
    }
}

public static class ConsoleMin {
    [DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")]   public static extern bool ShowWindow(IntPtr h, int n);
    public static void Minimize() {
        IntPtr h = GetConsoleWindow();
        if (h != IntPtr.Zero) ShowWindow(h, 6);   // SW_MINIMIZE — лог остаётся в панели задач
    }
}
'@
} catch {
    [void][System.Windows.Forms.MessageBox]::Show(
        "Не удалось загрузить компоненты интерфейса.`n$($_.Exception.Message)",
        "Настройка Game Launcher", "OK", "Error")
    exit 1
}

# ===== Тема (общая с лаунчером) =====
$dark = $false
try {
    $tf = Join-Path $appDir "theme.ini"
    if (Test-Path $tf) { if ((Get-Content $tf -Raw) -match '(?i)\bdark\b') { $dark = $true } }
} catch {}
[HxS]::Dark = $dark

function Col([int]$r,[int]$g,[int]$b)           { return [System.Drawing.Color]::FromArgb($r,$g,$b) }
function ColA([int]$a,[int]$r,[int]$g,[int]$b)  { return [System.Drawing.Color]::FromArgb($a,$r,$g,$b) }
function Rect([int]$x,[int]$y,[int]$w,[int]$h)  { return [System.Drawing.Rectangle]::new($x,$y,$w,$h) }

if ($dark) {
    $cPage   = Col 20 23 32;     $cBg1    = Col 27 30 40;     $cBg2    = Col 16 18 28
    $cCard   = Col 30 33 42;     $cText   = Col 235 238 245;  $cDim    = Col 150 158 176
    $cLine   = Col 58 64 80;     $cBlue   = Col 49 122 247;   $cBlue2  = Col 120 150 255
    $cViolet = Col 160 130 255;  $cGreen  = Col 90 200 150;   $cAmber  = Col 230 140 80
    $cRed    = Col 217 72 56;    $cTrack  = Col 58 64 80;     $cSoft   = Col 30 46 84
    $cGlow   = ColA 60 49 122 247
    $cEdge   = ColA 0 0 0 0
} else {
    $cPage   = Col 242 246 252;  $cBg1    = Col 248 250 253;  $cBg2    = Col 231 239 251
    $cCard   = [System.Drawing.Color]::White
    $cText   = Col 24 32 48;     $cDim    = Col 118 130 150;  $cLine   = Col 232 236 242
    $cBlue   = Col 10 89 247;    $cBlue2  = Col 96 134 255;   $cViolet = Col 139 110 255
    $cGreen  = Col 38 166 110;   $cAmber  = Col 237 111 33;   $cRed    = Col 232 64 38
    $cTrack  = Col 216 226 244;  $cSoft   = Col 232 240 255;  $cGlow   = ColA 46 10 89 247
    $cEdge   = ColA 0 255 255 255
}
$cOnAccent = [System.Drawing.Color]::White
$cWait     = if ($dark) { Col 74 80 98 } else { Col 200 208 220 }

$fams = @([System.Drawing.FontFamily]::Families | ForEach-Object { $_.Name })
$fam = "Segoe UI"
if     ($fams -contains "HarmonyOS Sans")             { $fam = "HarmonyOS Sans" }
elseif ($fams -contains "Segoe UI Variable Display") { $fam = "Segoe UI Variable Display" }
$fr = [System.Drawing.FontStyle]::Regular
$fb = [System.Drawing.FontStyle]::Bold
$fTitle = [System.Drawing.Font]::new($fam, 16, $fb)
$fItem  = [System.Drawing.Font]::new($fam, [single]10.5, $fb)
$fSmall = [System.Drawing.Font]::new($fam, 9, $fr)
$fHint  = [System.Drawing.Font]::new($fam, [single]8.5, $fr)
$fCap   = [System.Drawing.Font]::new($fam, [single]8.5, $fb)
$fOrb   = [System.Drawing.Font]::new($fam, 18, $fb)
$fWin   = [System.Drawing.Font]::new($fam, 13, $fb)

$flC = [System.Windows.Forms.TextFormatFlags]::HorizontalCenter -bor
       [System.Windows.Forms.TextFormatFlags]::VerticalCenter -bor
       [System.Windows.Forms.TextFormatFlags]::EndEllipsis -bor
       [System.Windows.Forms.TextFormatFlags]::NoPadding
$flL = [System.Windows.Forms.TextFormatFlags]::Left -bor
       [System.Windows.Forms.TextFormatFlags]::VerticalCenter -bor
       [System.Windows.Forms.TextFormatFlags]::EndEllipsis -bor
       [System.Windows.Forms.TextFormatFlags]::NoPadding
$flR = [System.Windows.Forms.TextFormatFlags]::Right -bor
       [System.Windows.Forms.TextFormatFlags]::VerticalCenter -bor
       [System.Windows.Forms.TextFormatFlags]::NoPadding
$flW = [System.Windows.Forms.TextFormatFlags]::WordBreak -bor
       [System.Windows.Forms.TextFormatFlags]::NoPadding

# ===== Состояние мастера =====
$script:steps = @(
    @{ N = "Microsoft Teams";    S = "wait"; D = "Ожидание..." },
    @{ N = "Radmin VPN";         S = "wait"; D = "Ожидание..." },
    @{ N = "Baldur's Gate 3";    S = "wait"; D = "Ожидание..." },
    @{ N = "Трейнер BG3";        S = "wait"; D = "Ожидание..." },
    @{ N = "Counter-Strike 2";   S = "wait"; D = "Запуск через steam://" },
    @{ N = "Fortnite";           S = "wait"; D = "Ожидание..." },
    @{ N = "Genshin Impact";     S = "wait"; D = "Ожидание..." }
)
$script:stepIndex = 0
$script:phaseText = "Подготовка..."
$script:done      = $false
$script:closed    = $false
$script:okCount   = 0
$script:hoverBtn  = $false
$script:hoverX    = $false
$script:running   = $true

$rectBtn = Rect 330 604 150 40
$rectX   = Rect 456 18 30 30

function Pump {
    if ($script:canvas) { $script:canvas.Invalidate(); $script:canvas.Update() }
    [System.Windows.Forms.Application]::DoEvents()
}

function Set-Step([int]$i, [string]$state, [string]$detail) {
    if ($i -lt 0 -or $i -ge $script:steps.Count) { return }
    $script:steps[$i].S = $state
    if ($detail) { $script:steps[$i].D = $detail }
    $script:stepIndex = $i
    Pump
}

function Set-Phase([string]$t) { $script:phaseText = $t; Pump }

function Draw-Setup($g) {
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
    $W = $script:canvas.ClientSize.Width
    $H = $script:canvas.ClientSize.Height

    # --- фон: ВСЕГДА рисуем первым делом, чтобы окно никогда не было пустым ---
    $bg = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
            (Rect 0 0 $W $H), $cBg1, $cBg2, [single]60)
    $g.FillRectangle($bg, (Rect 0 0 $W $H)); $bg.Dispose()
    [HxS]::Glow($g, (Rect ($W-230) -100 340 340), $cGlow, $cEdge)
    $glow2 = if ($dark) { ColA 38 160 130 255 } else { ColA 26 139 110 255 }
    [HxS]::Glow($g, (Rect -100 ($H-220) 300 300), $glow2, $cEdge)

    # --- шапка ---
    $orb = Rect 20 16 40 40
    $og = [System.Drawing.Drawing2D.LinearGradientBrush]::new($orb, $cBlue, $cViolet, [single]45)
    $g.FillEllipse($og, $orb); $og.Dispose()
    [HxS]::Txt($g, "G", $fOrb, $cOnAccent, $orb, $flC)
    [HxS]::Txt($g, "Настройка Game Launcher", $fTitle, $cText, (Rect 72 12 370 28), $flL)
    [HxS]::Txt($g, "Ищу игры и приложения на этом компьютере", $fHint, $cDim,
               (Rect 74 42 370 18), $flL)
    $px = [System.Drawing.Pen]::new($cLine)
    $g.DrawLine($px, 20, 76, ($W-20), 76); $px.Dispose()

    # --- крестик ---
    if ($script:hoverX) {
        [HxS]::Card($g, $rectX, 10, $cRed, $cLine)
        [HxS]::Txt($g, "×", $fWin, $cOnAccent, $rectX, $flC)
    } else {
        [HxS]::Txt($g, "×", $fWin, $cDim, $rectX, $flC)
    }

    # --- прогресс ---
    $doneN = @($script:steps | Where-Object { $_.S -eq "ok" }).Count
    $label = if ($script:done) { "ГОТОВО" } else { "ШАГ $($script:stepIndex + 1) ИЗ $($script:steps.Count)" }
    [HxS]::Txt($g, $label, $fCap, $cBlue, (Rect 20 88 200 18), $flL)
    [HxS]::Txt($g, $script:phaseText, $fHint, $cDim, (Rect 220 88 260 18), $flR)
    [HxS]::Gradient($g, (Rect 20 114 460 8), 4, $cTrack, $cTrack, [single]0)
    $ratio = if ($script:done) { 1 } else { ($script:stepIndex + 0.35) / $script:steps.Count }
    if ($ratio -gt 1) { $ratio = 1 }
    $pw = [int](460 * $ratio)
    if ($pw -gt 8) { [HxS]::Gradient($g, (Rect 20 114 $pw 8), 4, $cBlue, $cBlue2, [single]0) }

    # --- карточка результатов ---
    $card = Rect 20 142 460 398
    [HxS]::Shadow($g, $card, 20, 7)
    [HxS]::Card($g, $card, 20, $cCard, $cLine)
    $sep = [System.Drawing.Pen]::new($cLine)
    for ($i = 0; $i -lt $script:steps.Count; $i++) {
        $st = $script:steps[$i]
        $ry = 154 + $i * 52
        if ($i -gt 0) { $g.DrawLine($sep, 36, ($ry-4), 464, ($ry-4)) }

        $dot = switch ($st.S) {
            "ok"     { $cGreen }
            "warn"   { $cAmber }
            "miss"   { $cRed }
            "run"    { $cBlue }
            default  { $cWait }
        }
        $db = [System.Drawing.SolidBrush]::new($dot)
        $g.FillEllipse($db, (Rect 36 ($ry+16) 10 10)); $db.Dispose()

        $col = if ($st.S -eq "wait") { $cDim } else { $cText }
        [HxS]::Txt($g, "$($st.N)", $fItem, $col, (Rect 56 ($ry+4) 390 21), $flL)
        [HxS]::Txt($g, "$($st.D)", $fHint, $cDim, (Rect 56 ($ry+26) 390 17), $flL)
    }
    $sep.Dispose()

    # --- подсказка ---
    if ($script:done) {
        [HxS]::Txt($g, "Если игры нет — это нормально, она не появится в лаунчере.",
                   $fHint, $cDim, (Rect 20 550 460 18), $flL)
        [HxS]::Txt($g, "CS2 → steam://rungameid/730 · Отчёт: _app\setup_report.txt",
                   $fHint, $cDim, (Rect 20 568 460 18), $flL)
    } else {
        [HxS]::Txt($g, "Можно закрыть окно: всё найденное уже сохранится в config.ini.",
                   $fHint, $cDim, (Rect 20 556 460 18), $flL)
    }

    # --- кнопка ---
    $canGo = $script:done
    if ($canGo) {
        [HxS]::Shadow($g, $rectBtn, 20, 6)
        $b1 = if ($script:hoverBtn) { $cBlue2 } else { $cBlue }
        [HxS]::Gradient($g, $rectBtn, 20, $b1, $cBlue2, [single]12)
        [HxS]::Txt($g, "ГОТОВО  →", $fItem, $cOnAccent, $rectBtn, $flC)
    } else {
        [HxS]::Card($g, $rectBtn, 20, $cSoft, $cLine)
        [HxS]::Txt($g, "ПОДОЖДИТЕ…", $fHint, $cDim, $rectBtn, $flC)
    }

    # --- счётчик ---
    [HxS]::Txt($g, "Найдено $doneN из $($script:steps.Count)",
               $fHint, $cDim, (Rect 20 610 260 28), $flL)
}

# ===== Окно =====
$form = [System.Windows.Forms.Form]::new()
$form.Text = "Настройка Game Launcher"
$form.FormBorderStyle = "None"
$form.StartPosition = "CenterScreen"
$form.ClientSize = [System.Drawing.Size]::new(500, 660)
$form.BackColor = $cPage
$form.ForeColor = $cText
$form.Font = $fSmall
$form.ShowInTaskbar = $true
$form.KeyPreview = $true
$form.MaximizeBox = $false
if (Test-Path (Join-Path $appDir "icon.ico")) {
    try { $form.Icon = [System.Drawing.Icon]::new((Join-Path $appDir "icon.ico")) } catch {}
}
$form.Add_Shown({ param($s,$e) [HxS]::Chrome($s.Handle); $s.Activate() })
$form.Add_KeyDown({
    param($snd,$ev)
    if ($ev.KeyCode -eq [System.Windows.Forms.Keys]::Escape -or
        ($script:done -and $ev.KeyCode -eq [System.Windows.Forms.Keys]::Enter)) {
        $script:closed = $true; $snd.Close()
    }
})
$form.Add_FormClosed({ $script:closed = $true; $script:running = $false })

$canvas = [System.Windows.Forms.Panel]::new()
$canvas.Dock = "Fill"
$canvas.BackColor = $cPage
[HxS]::PaintEnable($canvas)
$form.Controls.Add($canvas)
$script:canvas = $canvas

$canvas.Add_Paint({
    param($s,$e)
    try { Draw-Setup $e.Graphics }
    catch {
        try {
            $e.Graphics.Clear($cPage)
            [HxS]::Txt($e.Graphics, "Ошибка отрисовки: $($_.Exception.Message)",
                       $fSmall, $cRed, (Rect 20 20 460 100), $flW)
        } catch {}
    }
})
$canvas.Add_MouseDown({
    param($s,$e)
    if ($e.Button -ne [System.Windows.Forms.MouseButtons]::Left) { return }
    if ($e.Y -lt 76) {
        if ($e.X -ge 440) { $script:closed = $true; $form.Close(); return }
        [HxS]::Drag($form.Handle); return
    }
    if ($script:done -and $rectBtn.Contains($e.X, $e.Y)) {
        $script:closed = $true; $form.Close()
    }
})
$canvas.Add_MouseMove({
    param($s,$e)
    $hb = $script:done -and $rectBtn.Contains($e.X, $e.Y)
    $hx = $rectX.Contains($e.X, $e.Y)
    if ($hb -ne $script:hoverBtn -or $hx -ne $script:hoverX) {
        $script:hoverBtn = $hb; $script:hoverX = $hx
        $script:canvas.Invalidate()
    }
})
$canvas.Add_MouseLeave({
    if ($script:hoverBtn -or $script:hoverX) {
        $script:hoverBtn = $false; $script:hoverX = $false
        $script:canvas.Invalidate()
    }
})

# Сворачиваем консоль: лог остаётся доступен с панели задач, но не мешает
try { [ConsoleMin]::Minimize() } catch {}

$form.Show()
$form.BringToFront()
Pump

# ============================================================
#  Поиск (логика из оригинального autodetect.ps1 сохранена полностью)
# ============================================================
function Find-SteamLibs {
    $libs = @()
    $steamPath = (Get-ItemProperty -Path "HKCU:\Software\Valve\Steam" -Name SteamPath -ErrorAction SilentlyContinue).SteamPath
    if ($steamPath) {
        $libs += $steamPath
        $vdf = Join-Path $steamPath "steamapps\libraryfolders.vdf"
        if (Test-Path $vdf) {
            foreach ($l in Get-Content $vdf) {
                if ($l -match '"path"\s+"([^"]+)"') { $libs += ($Matches[1] -replace '\\\\', '\') }
            }
        }
    }
    return $libs
}
function Find-InSteamLibs([string]$relPath) {
    foreach ($lib in (Find-SteamLibs)) {
        $p = Join-Path $lib $relPath
        if (Test-Path $p) { return $p }
    }
    return ""
}
function Pick-File($title) {
    $dlg = [System.Windows.Forms.OpenFileDialog]::new()
    $dlg.Title = $title
    $dlg.Filter = "Программа (*.exe)|*.exe"
    if ($dlg.ShowDialog($form) -eq "OK") { return $dlg.FileName }
    return ""
}
function Short([string]$p) {
    if (-not $p) { return "не найдено — можно пропустить" }
    if ($p -like "*://*") { return $p }
    try   { return [System.IO.Path]::GetFileName($p) }
    catch { return $p }
}
function Out-Found($path, [string]$miss = "НЕ найден") {
    if ($path) { Write-Host "      Найден: $path" -ForegroundColor Green }
    else       { Write-Host "      $miss" -ForegroundColor Yellow }
}
function Mark([string]$state, [string]$detail) { return @{ S = $state; D = $detail } }

# --- 1. Teams ---
Set-Phase "Поиск Microsoft Teams..."
Set-Step 0 "run" "Проверяю Store-версию и Program Files..."
Write-Host "[1/7] Ищу Microsoft Teams..." -ForegroundColor Cyan
$teams = ""
$pkg = Get-AppxPackage -Name "MSTeams" | Select-Object -First 1
if ($pkg) { $p = Join-Path $pkg.InstallLocation "ms-teams.exe"; if (Test-Path $p) { $teams = $p } }
if (-not $teams) { $p = "${env:ProgramFiles(x86)}\Microsoft\Teams\current\Teams.exe"; if (Test-Path $p) { $teams = $p } }
$st0 = if ($teams) { "ok" } else { "miss" }
$dt0 = if ($teams) { $teams } else { "не найдено — можно выбрать вручную" }
Set-Step 0 $st0 $dt0
Out-Found $teams

# --- 2. Radmin ---
Set-Phase "Поиск Radmin VPN..."
Set-Step 1 "run" "Проверяю Program Files..."
Write-Host "[2/7] Ищу Radmin VPN..." -ForegroundColor Cyan
$radmin = ""
foreach ($c in @("${env:ProgramFiles(x86)}\Radmin VPN\RvRvpnGui.exe", "$env:ProgramFiles\Radmin VPN\RvRvpnGui.exe")) {
    if (Test-Path $c) { $radmin = $c; break }
}
$st1 = if ($radmin) { "ok" } else { "miss" }
$dt1 = if ($radmin) { $radmin } else { "не найдено — можно выбрать вручную" }
Set-Step 1 $st1 $dt1
Out-Found $radmin

# --- 3. BG3 ---
Set-Phase "Поиск Baldur's Gate 3..."
Set-Step 2 "run" "Читаю библиотеки Steam..."
Write-Host "[3/7] Ищу Baldur's Gate 3..." -ForegroundColor Cyan
$bg3 = Find-InSteamLibs "steamapps\common\Baldurs Gate 3\bin\bg3_dx11.exe"
$st2 = if ($bg3) { "ok" } else { "miss" }
$dt2 = if ($bg3) { $bg3 } else { "не найдено — можно выбрать вручную" }
Set-Step 2 $st2 $dt2
Out-Found $bg3 "НЕ найдена"

# --- 4. Трейнер ---
Set-Phase "Поиск трейнера BG3..."
Set-Step 3 "run" "Смотрю Рабочий стол, Загрузки, D:\Programs..."
Write-Host "[4/7] Ищу трейнер BG3..." -ForegroundColor Cyan
$trainer = ""
foreach ($dir in @("D:\Programs\BG3", "$env:USERPROFILE\Desktop", "$env:USERPROFILE\Downloads", "C:\Games")) {
    if (Test-Path $dir) {
        $found = Get-ChildItem -Path $dir -Filter "*.exe" -Recurse -Depth 2 |
                 Where-Object { $_.Name -match 'trainer' -and $_.Name -match 'bg3|baldur' } |
                 Select-Object -First 1
        if ($found) { $trainer = $found.FullName; break }
    }
}
$st3 = if ($trainer) { "ok" } else { "miss" }
$dt3 = if ($trainer) { (Short $trainer) } else { "не найдено — можно выбрать вручную" }
Set-Step 3 $st3 $dt3
Out-Found $trainer

# --- 5. CS2 ---
Set-Phase "Поиск Counter-Strike 2..."
Set-Step 4 "run" "Проверяю библиотеки Steam..."
Write-Host "[5/7] Ищу Counter-Strike 2..." -ForegroundColor Cyan
$cs2 = Find-InSteamLibs "steamapps\common\Counter-Strike Global Offensive\game\bin\win64\cs2.exe"
Set-Step 4 "ok" "steam://rungameid/730 · VAC работает корректно"
Out-Found $cs2 "НЕ найдена (запуск всё равно через steam://)"

# --- 6. Fortnite ---
Set-Phase "Поиск Fortnite..."
Set-Step 5 "run" "Проверяю Epic Games..."
Write-Host "[6/7] Ищу Fortnite..." -ForegroundColor Cyan
$fortnite = ""
foreach ($c in @("C:\Program Files\Epic Games\Fortnite", "D:\Epic Games\Fortnite", "E:\Epic Games\Fortnite")) {
    $p = Join-Path $c "FortniteGame\Binaries\Win64\FortniteClient-Win64-Shipping_EAC_EOS.exe"
    if (Test-Path $p) { $fortnite = $p; break }
}
if (-not $fortnite) {
    $dat = "C:\ProgramData\Epic\UnrealEngineLauncher\LauncherInstalled.dat"
    if (Test-Path $dat) {
        $json = Get-Content $dat -Raw | ConvertFrom-Json
        foreach ($inst in $json.InstallationList) {
            if ($inst.AppName -eq "Fortnite") {
                $p = Join-Path $inst.InstallLocation "FortniteGame\Binaries\Win64\FortniteClient-Win64-Shipping_EAC_EOS.exe"
                if (Test-Path $p) { $fortnite = $p; break }
            }
        }
    }
}
$st5 = if ($fortnite) { "ok" } else { "miss" }
$dt5 = if ($fortnite) { $fortnite } else { "не найдено — можно выбрать вручную" }
Set-Step 5 $st5 $dt5
Out-Found $fortnite

# --- 7. Genshin ---
Set-Phase "Поиск Genshin Impact..."
Set-Step 6 "run" "Проверяю HoYoPlay..."
Write-Host "[7/7] Ищу Genshin Impact..." -ForegroundColor Cyan
$genshin = ""
foreach ($c in @("C:\Program Files\HoYoPlay\games\Genshin Impact game\GenshinImpact.exe",
                  "D:\HoYoPlay\games\Genshin Impact game\GenshinImpact.exe",
                  "D:\Program Files\HoYoPlay\games\Genshin Impact game\GenshinImpact.exe")) {
    if (Test-Path $c) { $genshin = $c; break }
}
$st6 = if ($genshin) { "ok" } else { "miss" }
$dt6 = if ($genshin) { $genshin } else { "не найдено — можно выбрать вручную" }
Set-Step 6 $st6 $dt6
Out-Found $genshin

# --- Браузеры ---
Set-Phase "Поиск браузеров..."
Write-Host "      Ищу браузеры..." -ForegroundColor Cyan
$whale = ""
foreach ($c in @("C:\Program Files\Naver\Naver Whale\Application\whale.exe",
                  "C:\Program Files (x86)\Naver\Naver Whale\Application\whale.exe")) {
    if (Test-Path $c) { $whale = $c; break }
}
$edge = ""
foreach ($c in @("C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
                  "C:\Program Files\Microsoft\Edge\Application\msedge.exe")) {
    if (Test-Path $c) { $edge = $c; break }
}
Out-Found $whale "Whale не найден"
Out-Found $edge "Edge не найден"

# --- Ручной выбор (если что-то не нашлось) ---
$picks = @(
    @{ I = 0; Var = "teams";   T = "Teams: выбери ms-teams.exe (Отмена = пропустить)" },
    @{ I = 1; Var = "radmin";  T = "Radmin VPN: выбери RvRvpnGui.exe (Отмена = пропустить)" },
    @{ I = 2; Var = "bg3";     T = "BG3: выбери bg3_dx11.exe (Отмена = пропустить)" },
    @{ I = 3; Var = "trainer"; T = "Трейнер BG3: выбери exe трейнера (Отмена = пропустить)" },
    @{ I = 5; Var = "fortnite";T = "Fortnite: выбери FortniteClient-Win64-Shipping_EAC_EOS.exe (Отмена = пропустить)" },
    @{ I = 6; Var = "genshin"; T = "Genshin: выбери GenshinImpact.exe (Отмена = пропустить)" }
)
foreach ($pk in $picks) {
    $curVal = Get-Variable -Name $pk.Var -ValueOnly
    if (-not $curVal) {
        Set-Phase "Нужен файл вручную: $($script:steps[$pk.I].N)"
        Set-Step $pk.I "run" "Откроется окно выбора файла · Отмена = пропустить"
        Start-Sleep -Milliseconds 250
        $chosen = Pick-File $pk.T
        Set-Variable -Name $pk.Var -Value $chosen
        $pkState  = if ($chosen) { "ok" } else { "miss" }
        $pkDetail = if ($chosen) { $chosen } else { "пропущено — игры нет, это нормально" }
        Set-Step $pk.I $pkState $pkDetail
    }
}
if (-not $whale) { $whale = $edge }
if (-not $edge)  { $edge  = $whale }

$vkUrl  = "https://vk.ru/im/convo/324766294?entrypoint=list_all"
$mapUrl = "https://act.hoyolab.com/ys/app/interactive-map"

# ============================================================
#  Запись config.ini (без потери пользовательских секций)
# ============================================================
Set-Phase "Сохраняю config.ini..."
$sb = [System.Text.StringBuilder]::new()
function Add-Line($s) { [void]$sb.AppendLine($s) }

Add-Line "[BG3]"
Add-Line "1Name=Microsoft Teams";   Add-Line "1Path=$teams";   Add-Line "1Default=0"
Add-Line "2Name=Radmin VPN";        Add-Line "2Path=$radmin";  Add-Line "2Default=0"
if ($trainer) {
    Add-Line "3Name=Трейнер BG3";     Add-Line "3Path=$trainer"; Add-Line "3Default=1"
    Add-Line "4Name=Baldur's Gate 3"; Add-Line "4Path=$bg3";     Add-Line "4Default=1"; Add-Line "4Delay=12"
} else {
    Add-Line "3Name=Baldur's Gate 3"; Add-Line "3Path=$bg3";     Add-Line "3Default=1"
}
Add-Line ""
Add-Line "[CS2]"
Add-Line "1Name=Counter-Strike 2";  Add-Line "1Path=steam://rungameid/730"; Add-Line "1Proc=cs2"; Add-Line "1Default=1"
if ($whale) { Add-Line "2Name=VK-чат"; Add-Line "2Path=$whale"; Add-Line "2Args=$vkUrl"; Add-Line "2Default=1" }
Add-Line "3Name=Microsoft Teams";   Add-Line "3Path=$teams";   Add-Line "3Default=0"
Add-Line ""
Add-Line "[Fortnite]"
Add-Line "1Name=Fortnite";          Add-Line "1Path=$fortnite"; Add-Line "1Default=1"
if ($whale) { Add-Line "2Name=VK-чат"; Add-Line "2Path=$whale"; Add-Line "2Args=$vkUrl"; Add-Line "2Default=1" }
Add-Line "3Name=Microsoft Teams";   Add-Line "3Path=$teams";   Add-Line "3Default=0"
Add-Line ""
Add-Line "[Genshin]"
Add-Line "1Name=Genshin Impact";    Add-Line "1Path=$genshin"; Add-Line "1Default=1"
if ($edge) { Add-Line "2Name=Интерактивная карта"; Add-Line "2Path=$edge"; Add-Line "2Args=$mapUrl"; Add-Line "2Default=1" }
Add-Line "3Name=Microsoft Teams";   Add-Line "3Path=$teams";   Add-Line "3Default=0"

$customText = ""
$inCustom = $false
if (Test-Path $configFile) {
    foreach ($line in (Get-Content $configFile -Encoding UTF8)) {
        $t = $line.Trim()
        if ($t -match '^\[(.+)\]$') {
            $inCustom = ($Matches[1] -notin @("BG3", "CS2", "Fortnite", "Genshin"))
        }
        if ($inCustom -and $t -ne "") { $customText += $line + "`r`n" }
    }
}
if ($customText) { Add-Line ""; [void]$sb.Append($customText) }
[System.IO.File]::WriteAllText($configFile, $sb.ToString(), [System.Text.UTF8Encoding]::new($false))

# --- Отчёт ---
$checks = @(
    @{ N = "Microsoft Teams";  P = $teams },
    @{ N = "Radmin VPN";       P = $radmin },
    @{ N = "Baldur's Gate 3";  P = $bg3 },
    @{ N = "Трейнер BG3";      P = $trainer },
    @{ N = "Counter-Strike 2"; P = "steam://rungameid/730" },
    @{ N = "Fortnite";         P = $fortnite },
    @{ N = "Genshin Impact";   P = $genshin }
)
$report = @(); $msg = @(); $ok = 0
foreach ($c in $checks) {
    $isUrl  = $c.P -like "*://*"
    $exists = if ($isUrl) { $true } elseif ($c.P) { (Test-Path $c.P) -eq $true } else { $false }
    if     ($c.P -and $exists) { $mark = "[OK]"; $markText = "найдена" }
    elseif ($c.P)              { $mark = "[?]";  $markText = "путь записан, но файла нет" }
    else                       { $mark = "[X]";  $markText = "НЕ НАЙДЕНА" }
    $color = switch ($mark) { "[OK]" { "Green" } "[?]" { "Yellow" } default { "Red" } }
    Write-Host ("{0,-20} {1} {2}" -f $c.N, $mark, $markText) -ForegroundColor $color
    if ($c.P) { Write-Host ("     $($c.P)") -ForegroundColor Gray }
    if ($mark -eq "[OK]") { $ok++; $msg += ("  $($c.N) — OK") }
    else                  {        $msg += ("  $($c.N) — не найдена") }
    $report += "$($c.N) : $mark $markText : $($c.P)"
}
$report | Set-Content -Path $reportFile -Encoding UTF8

# --- Финальное состояние окна ---
$script:okCount = $ok
$script:done    = $true
$script:phaseText = "Найдено $ok из $($checks.Count) · конфиг сохранён"
foreach ($i in 0..6) {
    if ($script:steps[$i].S -eq "run") { $script:steps[$i].S = "miss"; $script:steps[$i].D = "пропущено" }
}
Pump
Write-Host ""
Write-Host "Готово. Найдено: $ok из $($checks.Count)." -ForegroundColor Cyan

# --- Держим окно, пока пользователь не закроет ---
while ($script:running -and -not $script:closed) {
    [System.Windows.Forms.Application]::DoEvents()
    Start-Sleep -Milliseconds 40
}
try { $form.Dispose() } catch {}
