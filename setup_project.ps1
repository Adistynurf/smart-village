$ErrorActionPreference = "Stop"
$project = "C:\FlutterProjects\sehat_bersama"
$source = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "Memeriksa Flutter..." -ForegroundColor Cyan
flutter --version
if (!(Test-Path "C:\FlutterProjects")) { New-Item -ItemType Directory -Path "C:\FlutterProjects" | Out-Null }

if (Test-Path $project) {
    $backup = "$project-backup-" + (Get-Date -Format "yyyyMMdd-HHmmss")
    Write-Host "Folder tujuan sudah ada. Memindahkan ke $backup" -ForegroundColor Yellow
    Move-Item $project $backup
}

flutter create --platforms=android $project
if ($LASTEXITCODE -ne 0) { throw "flutter create gagal." }

Copy-Item "$source\lib" "$project\lib" -Recurse -Force
Copy-Item "$source\pubspec.yaml" "$project\pubspec.yaml" -Force
Copy-Item "$source\AndroidManifest.xml" "$project\android\app\src\main\AndroidManifest.xml" -Force

Set-Location $project
flutter pub get
if ($LASTEXITCODE -ne 0) { throw "flutter pub get gagal." }

Write-Host ""
Write-Host "SELESAI! Buka folder berikut di Android Studio:" -ForegroundColor Green
Write-Host $project -ForegroundColor Green
Write-Host "Pilih emulator Android lalu tekan tombol Run."
