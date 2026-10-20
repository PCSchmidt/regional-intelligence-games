param(
    [ValidateSet('Run', 'Test', 'VisualTest', 'Export', 'PackagedTest')]
    [string]$Mode = 'Run',
    [string]$GodotPath = ''
)

$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$project = Join-Path $root 'games\regional-desk'
$build = Join-Path $root 'builds\RegionalDesk'
if (-not $GodotPath) {
    $GodotPath = Join-Path $root '.tools\godot\Godot_v4.7.2-stable_win64_console.exe'
}
if (-not (Test-Path -LiteralPath $GodotPath -PathType Leaf)) {
    throw 'Godot not found. Supply -GodotPath with an official Godot Windows executable.'
}

function Invoke-Engine {
    param(
        [string[]]$EngineArguments,
        [string]$Executable = $GodotPath
    )
    $ErrorActionPreference = 'Continue'
    $output = & $Executable @EngineArguments 2>&1
    $code = $LASTEXITCODE
    $ErrorActionPreference = 'Stop'
    $output | ForEach-Object { Write-Host $_ }
    if ($code -ne 0 -or ($output | Out-String) -match '(?m)^(SCRIPT ERROR:|ERROR:)') {
        throw "Godot invocation failed (exit $code): $($EngineArguments -join ' ')"
    }
}

switch ($Mode) {
    'Run' {
        Invoke-Engine -EngineArguments @('--path', $project)
    }
    'Test' {
        Invoke-Engine -EngineArguments @('--headless', '--path', $project, '--editor', '--import', '--quit')
        foreach ($test in @('test_case', 'test_save', 'test_map', 'test_ui', 'test_campaign', 'test_atlas')) {
            Invoke-Engine -EngineArguments @('--headless', '--path', $project, '--script', "res://tests/$test.gd")
        }
    }
    'VisualTest' {
        New-Item -ItemType Directory -Path $build -Force | Out-Null
        $preview = Join-Path $build 'preview.png'
        Invoke-Engine -EngineArguments @('--path', $project, '--script', 'res://tests/test_ui.gd', '--', "--preview=$preview")
        $secondPreview = Join-Path $build 'case02.png'
        Invoke-Engine -EngineArguments @('--path', $project, '--script', 'res://tests/test_campaign.gd', '--', "--preview=$secondPreview")
        $mapPreview = Join-Path $build 'atlas.png'
        Invoke-Engine -EngineArguments @('--path', $project, '--script', 'res://tests/test_atlas.gd', '--', "--preview=$mapPreview")
    }
    'Export' {
        New-Item -ItemType Directory -Path $build -Force | Out-Null
        Invoke-Engine -EngineArguments @('--headless', '--path', $project, '--editor', '--import', '--quit')
        Invoke-Engine -EngineArguments @('--headless', '--path', $project, '--export-release', 'Windows Desktop')
        Copy-Item -LiteralPath (Join-Path $root 'PORTFOLIO_BUILD_README.md') -Destination (Join-Path $build 'README.md') -Force
        $archive = Join-Path $root 'builds\RegionalDesk-Windows.zip'
        $files = @((Join-Path $build 'RegionalDesk.exe'), (Join-Path $build 'README.md'))
        Compress-Archive -LiteralPath $files -DestinationPath $archive -Force
        Write-Host "Portfolio archive: $archive"
    }
    'PackagedTest' {
        $archive = Join-Path $root 'builds\RegionalDesk-Windows.zip'
        if (-not (Test-Path -LiteralPath $archive)) {
            throw 'Export the Windows build before running PackagedTest.'
        }
        $testDirectory = Join-Path ([IO.Path]::GetTempPath()) ('RegionalDesk-package-' + [Guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $testDirectory | Out-Null
        $originalAppData = $env:APPDATA
        $process = $null
        try {
            Expand-Archive -LiteralPath $archive -DestinationPath $testDirectory
            $executable = Join-Path $testDirectory 'RegionalDesk.exe'
            if (-not (Test-Path -LiteralPath (Join-Path $testDirectory 'README.md')) -or
                (Test-Path -LiteralPath (Join-Path $testDirectory 'README.txt'))) {
                throw 'Extracted package must contain Markdown instructions, not the old text README.'
            }
            $env:APPDATA = Join-Path $testDirectory 'appdata'
            New-Item -ItemType Directory -Path $env:APPDATA | Out-Null
            # Release templates cannot run an external --script. The standard engine
            # exercises the exported resource pack; a separate release launch checks startup.
            foreach ($test in @('test_case', 'test_map', 'test_ui', 'test_campaign', 'test_atlas')) {
                Invoke-Engine -EngineArguments @('--headless', '--main-pack', $executable, '--script', (Join-Path $project "tests\$test.gd"))
            }
            $process = Start-Process -FilePath $executable -WorkingDirectory $testDirectory -ArgumentList @('--max-fps', '30', '--quit-after', '180') -PassThru
            $deadline = [DateTime]::UtcNow.AddSeconds(15)
            do {
                Start-Sleep -Milliseconds 200
                $process.Refresh()
            } while (-not $process.HasExited -and $process.MainWindowHandle -eq 0 -and [DateTime]::UtcNow -lt $deadline)
            if ($process.HasExited -or $process.MainWindowHandle -eq 0 -or -not $process.Responding) {
                throw 'Extracted release did not open a responsive desktop window.'
            }
            Write-Host "Extracted release opened: $($process.MainWindowTitle)"
            if (-not $process.WaitForExit(20000)) {
                throw 'Extracted release exceeded its bounded startup check.'
            }
            if ($process.ExitCode -ne 0) {
                throw "Extracted release failed with exit $($process.ExitCode)."
            }
            $savePath = Join-Path $env:APPDATA 'Godot\app_userdata\Regional Analysis Desk\session.json'
            if (-not (Test-Path -LiteralPath $savePath)) {
                throw 'Extracted release did not autosave its initialized case.'
            }
            $saved = Get-Content -LiteralPath $savePath -Raw | ConvertFrom-Json
            if ($saved.case_id -ne 'missing-interval' -or $saved.save_version -ne 1 -or 'manifest' -notin $saved.read) {
                throw 'Extracted release saved an unexpected case state.'
            }
            Write-Host 'PACKAGED STARTUP: responsive window, case autosave, normal exit 0.'
        }
        finally {
            if ($null -ne $process -and -not $process.HasExited) {
                Stop-Process -Id $process.Id
                $process.WaitForExit()
            }
            $env:APPDATA = $originalAppData
            Remove-Item -LiteralPath $testDirectory -Recurse -Force
        }
    }
}
