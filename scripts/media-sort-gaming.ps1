# =============================================================================
# media-sort-gaming.ps1 — tri des depots medias (Windows) — equivalent du .sh
# =============================================================================
#   powershell -File media-sort-gaming.ps1              # simulation (defaut, sur)
#   powershell -File media-sort-gaming.ps1 -Execute     # execution reelle
# ROMs : rangees par plateforme (roms\<console>\ -> RomM\roms\<console>\).
# Ne traite que les elements STABLES (non modifies depuis StableMin minutes).
# A enregistrer en UTF-8 (accents des dossiers Series/Musique). PowerShell 7 (pwsh)
# recommande. Ne supprime jamais : au moindre doute -> _quarantaine.
# =============================================================================
param(
  [int]$StableMin = 5,
  [switch]$Execute
)
$ErrorActionPreference = 'Continue'
$Root  = 'D:\'
$Inbox = Join-Path $Root '_inbox'
$Quar  = Join-Path $Root '_quarantaine'
$Log   = Join-Path $env:ProgramData 'media-sort.log'

$Dest = [ordered]@{
  films='Jellyfin\Films'; series='Jellyfin\Séries'; anime='Jellyfin\Anime';
  cartoons='Jellyfin\Cartoons'; music='Navidrome\Musique'; livres='Kavita\eBook';
  'livres-audio'='AudioBookShelf'; comics='Kavita\Comics'; manga='Kavita\Manga'
}
$Video='mkv|mp4|avi|m4v|mov|ts|webm'; $Audio='flac|mp3|m4a|m4b|ogg|opus|wav|aac'
$Ebook='epub|pdf|mobi|azw3|djvu';     $Comic='cbz|cbr|pdf'
$RomPlatforms = 'nes','snes','n64','gc','wii','gb','gbc','gba','nds','3ds','ps',
  'ps2','psp','sms','genesis','gamegear','saturn','dreamcast','segacd','arcade',
  'atari2600','pcengine','neogeo'

function Write-Log($m){ $l='{0} {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'),$m; Write-Output $l; Add-Content -Path $Log -Value $l }
function Test-Valide($type,$name){
  $ext = ([IO.Path]::GetExtension($name)).TrimStart('.').ToLower()
  switch -Regex ($type){
    '^(films|anime|cartoons)$' { return ($name -match '\(\d{4}\)') -and ($ext -match "^($Video)$") }
    '^series$'                 { return ($name -match '[Ss]\d{1,2}[Ee]\d{1,3}') -and ($ext -match "^($Video)$") }
    '^music$'                  { return $ext -match "^($Audio)$" }
    '^livres$'                 { return $ext -match "^($Ebook)$" }
    '^livres-audio$'           { return $ext -match "^($Audio)$" }
    '^(comics|manga)$'         { return $ext -match "^($Comic)$" }
    default                    { return $false }
  }
}
function Move-To($src,$dstDir){
  if(-not $Execute){ Write-Log "[SIM] ranger  : $src -> $dstDir\"; return }
  New-Item -ItemType Directory -Force -Path $dstDir | Out-Null
  try { Move-Item -LiteralPath $src -Destination $dstDir -ErrorAction Stop
        Write-Log "[OK]  range   : $(Split-Path $src -Leaf) -> $dstDir\" }
  catch { Write-Log "[ERR] echec  : $src ($($_.Exception.Message))" }
}
function Quarantine($src,$reason){
  if(-not $Execute){ Write-Log "[SIM] quaran. : $src ($reason)"; return }
  New-Item -ItemType Directory -Force -Path $Quar | Out-Null
  try { Move-Item -LiteralPath $src -Destination $Quar -ErrorAction Stop
        Write-Log "[QUAR] $(Split-Path $src -Leaf) ($reason)" } catch {}
}
$cutoff = (Get-Date).AddMinutes(-$StableMin)
function Is-Stable($i){ $i.LastWriteTime -lt $cutoff }
function Is-Temp($n){ ($n -match '\.(part|tmp|crdownload)$') -or $n.StartsWith('.') }

if(-not (Test-Path $Inbox)){ Write-Log "inbox absente: $Inbox"; exit 1 }
Write-Log "=== tri demarre (Execute=$Execute, stable>${StableMin}min) ==="

foreach($type in $Dest.Keys){
  $dir = Join-Path $Inbox $type
  if(-not (Test-Path $dir)){ continue }
  $dest = Join-Path $Root $Dest[$type]
  Get-ChildItem -LiteralPath $dir -Force | ForEach-Object {
    if(Is-Temp $_.Name){ return }
    if(-not (Is-Stable $_)){ return }
    if($_.PSIsContainer){ Move-To $_.FullName $dest }
    elseif(Test-Valide $type $_.Name){ Move-To $_.FullName $dest }
    else { Quarantine $_.FullName "nom non conforme ($type)" }
  }
}

$rdir = Join-Path $Inbox 'roms'
if(Test-Path $rdir){
  Get-ChildItem -LiteralPath $rdir -File -Force | ForEach-Object {
    if(Is-Temp $_.Name){ return }
    if(-not (Is-Stable $_)){ return }
    Quarantine $_.FullName "ROM sans console : range-la dans roms\<console>\ (ex. roms\ps\)"
  }
  foreach($plat in $RomPlatforms){
    $pdir = Join-Path $rdir $plat
    if(-not (Test-Path $pdir)){ continue }
    $target = Join-Path $Root ("RomM\roms\" + $plat)
    Get-ChildItem -LiteralPath $pdir -Force | ForEach-Object {
      if(Is-Temp $_.Name){ return }
      if(-not (Is-Stable $_)){ return }
      Move-To $_.FullName $target
    }
  }
}
Write-Log "=== tri termine ==="
