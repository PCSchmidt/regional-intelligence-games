param(
    [ValidateSet('Run', 'Test', 'VisualTest', 'Benchmark', 'Export', 'PackagedTest')]
    [string]$Mode = 'Run',
    [string]$GodotPath = ''
)

$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$project = Join-Path $root 'games\cable-ship'
$build = Join-Path $root 'builds\CableShip'
if (-not $GodotPath) {
    $GodotPath = Join-Path $root '.tools\godot\Godot_v4.7.2-stable_win64_console.exe'
}
if (-not (Test-Path -LiteralPath $GodotPath -PathType Leaf)) {
    throw 'Supply -GodotPath with an official Godot 4.7.2 standard Windows executable.'
}

function Invoke-Engine {
    param([string[]]$EngineArguments)
    $ErrorActionPreference = 'Continue'
    $output = & $GodotPath @EngineArguments 2>&1
    $code = $LASTEXITCODE
    $ErrorActionPreference = 'Stop'
    $output | ForEach-Object { Write-Host $_ }
    if ($code -ne 0 -or ($output | Out-String) -match '(?m)^(SCRIPT ERROR:|ERROR:)') {
        throw "Godot failed (exit $code): $($EngineArguments -join ' ')"
    }
}

switch ($Mode) {
    'Run' { Invoke-Engine @('--path', $project) }
    'Test' {
        Invoke-Engine @('--headless', '--path', $project, '--editor', '--import', '--quit')
        foreach ($test in @('test_survey', 'test_scene', 'test_controls')) {
            Invoke-Engine @('--headless', '--path', $project, '--script', "res://tests/$test.gd")
        }
    }
    'VisualTest' {
        New-Item -ItemType Directory -Path $build -Force | Out-Null
        Invoke-Engine @('--path', $project, '--resolution', '1600x900', '--script', 'res://tests/test_scene.gd', '--', "--preview=$(Join-Path $build 'survey')")
        Invoke-Engine @('--path', $project, '--resolution', '1180x700', '--script', 'res://tests/test_controls.gd', '--', "--preview=$(Join-Path $build 'small-window.png')")
    }
    'Benchmark' {
        New-Item -ItemType Directory -Path $build -Force | Out-Null
        Invoke-Engine @('--path', $project, '--resolution', '1920x1080', '--script', 'res://tests/benchmark.gd', '--', "--output=$(Join-Path $build 'benchmark.json')")
    }
    'Export' {
        New-Item -ItemType Directory -Path $build -Force | Out-Null
        Invoke-Engine @('--headless', '--path', $project, '--editor', '--import', '--quit')
        Invoke-Engine @('--headless', '--path', $project, '--export-release', 'Windows Desktop')
        Copy-Item -LiteralPath (Join-Path $project 'PLAYER_README.md') -Destination (Join-Path $build 'README.md') -Force
        $files = @((Join-Path $build 'CableShip.exe'), (Join-Path $build 'README.md'))
        Compress-Archive -LiteralPath $files -DestinationPath (Join-Path $root 'builds\CableShip-Windows.zip') -Force
    }
    'PackagedTest' {
        $directory = Join-Path ([IO.Path]::GetTempPath()) ('CableShip-package-' + [Guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $directory | Out-Null
        $originalAppData = $env:APPDATA
        $process = $null
        try {
            Expand-Archive -LiteralPath (Join-Path $root 'builds\CableShip-Windows.zip') -DestinationPath $directory
            $exe = Join-Path $directory 'CableShip.exe'
            if (-not (Test-Path -LiteralPath (Join-Path $directory 'README.md'))) { throw 'Package instructions missing.' }
            $env:APPDATA = Join-Path $directory 'appdata'
            New-Item -ItemType Directory -Path $env:APPDATA | Out-Null
            foreach ($test in @('test_survey', 'test_scene', 'test_controls')) {
                Invoke-Engine @('--headless', '--main-pack', $exe, '--script', (Join-Path $project "tests\$test.gd"))
            }
            Invoke-Engine @('--main-pack', $exe, '--resolution', '1600x900', '--script', (Join-Path $project 'tests\test_scene.gd'))
            Invoke-Engine @('--main-pack', $exe, '--resolution', '1180x700', '--script', (Join-Path $project 'tests\test_controls.gd'))
            $log = Join-Path $directory 'release.log'
            $process = Start-Process -FilePath $exe -WorkingDirectory $directory -ArgumentList @('--max-fps', '30', '--quit-after', '180', '--log-file', "`"$log`"") -PassThru
            $deadline = [DateTime]::UtcNow.AddSeconds(20)
            do {
                Start-Sleep -Milliseconds 200
                $process.Refresh()
            } while (-not $process.HasExited -and $process.MainWindowHandle -eq 0 -and [DateTime]::UtcNow -lt $deadline)
            if ($process.HasExited -or $process.MainWindowHandle -eq 0 -or -not $process.Responding) {
                throw 'Extracted release did not open a responsive desktop window.'
            }
            Write-Host "Extracted release opened: $($process.MainWindowTitle)"
            if (-not $process.WaitForExit(30000)) { throw 'Release startup check timed out.' }
            if ($process.ExitCode -ne 0) { throw "Release exit $($process.ExitCode)" }
            if ((Get-Content -LiteralPath $log -Raw) -match '(?m)^(SCRIPT ERROR:|ERROR:)') { throw 'Release logged an engine error.' }
            $save = Join-Path $env:APPDATA 'Godot\app_userdata\Cable Ship - Survey\survey\session.json'
            $saved = Get-Content -LiteralPath $save -Raw | ConvertFrom-Json
            if ($saved.survey_id -ne 'bashi-span-01' -or $saved.state.phase -ne 'deck' -or $saved.save_version -ne 1) {
                throw 'Unexpected release autosave.'
            }
            Write-Host 'PACKAGED STARTUP: responsive release, correct independent autosave, normal exit 0.'
        }
        finally {
            if ($null -ne $process -and -not $process.HasExited) {
                Stop-Process -Id $process.Id
                $process.WaitForExit()
            }
            $env:APPDATA = $originalAppData
            Remove-Item -LiteralPath $directory -Recurse -Force
        }
    }
}
