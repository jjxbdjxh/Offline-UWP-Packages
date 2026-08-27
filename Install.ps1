# ==========================================
# LTSC 2018照片 & 电影与电视 一键离线安装脚本
# 作者: JJXBDJXH
# 说明: 自动安装 ./Appxs 目录下的依赖和主程序
# ==========================================

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$AppxDir = Join-Path $ScriptDir "Appxs"

if (-not (Test-Path $AppxDir)) {
    Write-Host "[错误] 找不到 'Appxs' 文件夹！请确保脚本和文件夹在同一目录下。" -ForegroundColor Red
    Read-Host "按回车键退出"
    exit
}

Set-Location $AppxDir
Write-Host "当前目录: $AppxDir" -ForegroundColor Cyan
Write-Host "开始安装，请耐心等待（不要关闭窗口）..." -ForegroundColor Yellow

function Install-Package {
    param([string]$Pattern)

    $Package = Get-ChildItem -Filter *.appx* | Where-Object { $_.Name -match $Pattern -and $_.Name -notmatch "BlockMap" -and $_.Name -match "x64|neutral" } | Select-Object -First 1
    
    if ($Package) {
        Write-Host "正在安装: $($Package.Name)" -ForegroundColor Green
        try {
            Add-AppxPackage -Path $Package.FullName -ErrorAction Stop
            Write-Host "安装成功: $($Package.Name)" -ForegroundColor Green
        } catch {
            Write-Host "安装失败: $($Package.Name) - 错误信息: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "注意：如果提示已安装，直接忽略即可。" -ForegroundColor Yellow
        }
    } else {
        Write-Host "跳过: 未找到匹配 $Pattern 的安装包" -ForegroundColor DarkYellow
    }
}

Write-Host "`n[1/7] 安装 .NET Framework 1.3..." -ForegroundColor Cyan
Install-Package -Pattern "NET.Native.Framework.1.3"

Write-Host "`n[2/7] 安装 .NET Framework 2.2..." -ForegroundColor Cyan
Install-Package -Pattern "NET.Native.Framework.2.2"

Write-Host "`n[3/7] 安装 .NET Runtime 2.2..." -ForegroundColor Cyan
Install-Package -Pattern "NET.Native.Runtime.2.2"

Write-Host "`n[4/7] 安装 UI.Xaml 2.0..." -ForegroundColor Cyan
Install-Package -Pattern "UI.Xaml.2.0"

Write-Host "`n[5/7] 安装 VCLibs 运行库..." -ForegroundColor Cyan
Install-Package -Pattern "VCLibs.140.00"

Write-Host "`n[6/7] 安装 WindowsAppRuntime..." -ForegroundColor Cyan
Install-Package -Pattern "WindowsAppRuntime"

Write-Host "`n[7/7] 安装主程序 (照片 & 电影与电视)..." -ForegroundColor Cyan
Install-Package -Pattern "Windows.Photos"
Install-Package -Pattern "ZuneVideo"

Write-Host "`n==========================================" -ForegroundColor Green
Write-Host "所有安装步骤已结束！" -ForegroundColor Green
Write-Host "建议重启电脑以完全生效。" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

Read-Host "按回车键退出"