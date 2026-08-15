$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
. (Join-Path $repositoryRoot "scripts\flutter_sdk.ps1")

$testsRun = 0

function Assert-Equal {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Expected,

        [Parameter(Mandatory = $true)]
        [string]$Actual,

        [Parameter(Mandatory = $true)]
        [string]$Because
    )

    $script:testsRun++
    if ($Expected -ne $Actual) {
        throw "Expected '$Expected' but received '$Actual': $Because"
    }
}

function New-FakeFlutterSdk {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root,

        [switch]$WithoutDart
    )

    $binDirectory = Join-Path $Root "bin"
    New-Item -ItemType Directory -Path $binDirectory -Force | Out-Null
    New-Item -ItemType File -Path (Join-Path $binDirectory "flutter.bat") -Force | Out-Null

    if (-not $WithoutDart) {
        New-Item -ItemType File -Path (Join-Path $binDirectory "dart.bat") -Force | Out-Null
    }

    return (Resolve-Path $Root).Path
}

$temporaryBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
$testRoot = Join-Path $temporaryBase ("battery-tracker-flutter-sdk-test-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $testRoot | Out-Null

try {
    $configuredRoot = New-FakeFlutterSdk (Join-Path $testRoot "configured")
    $pathRoot = New-FakeFlutterSdk (Join-Path $testRoot "path")
    $resolved = Resolve-FlutterSdk `
        -ConfiguredRoot $configuredRoot `
        -PathFlutterCommand (Join-Path $pathRoot "bin\flutter.bat") `
        -UserProfilePath "" `
        -MachineSearchRoots @()

    Assert-Equal $configuredRoot $resolved.Root "the explicit configured root must take precedence"

    $fallbackRoot = New-FakeFlutterSdk (Join-Path $testRoot "fallback")
    $resolved = Resolve-FlutterSdk `
        -ConfiguredRoot "" `
        -PathFlutterCommand (Join-Path $pathRoot "bin\flutter.bat") `
        -UserProfilePath "" `
        -MachineSearchRoots @($fallbackRoot)

    Assert-Equal $pathRoot $resolved.Root "PATH must take precedence over fallback locations"

    $profileRoot = Join-Path $testRoot "profile"
    $developRoot = New-FakeFlutterSdk (Join-Path $profileRoot "Develop\flutter")
    $resolved = Resolve-FlutterSdk `
        -ConfiguredRoot "" `
        -PathFlutterCommand "" `
        -UserProfilePath $profileRoot `
        -MachineSearchRoots @()

    Assert-Equal $developRoot $resolved.Root "the per-user Develop installation must be discovered"

    $validMachineRoot = New-FakeFlutterSdk (Join-Path $testRoot "machine-valid")
    $invalidMachineRoot = New-FakeFlutterSdk `
        (Join-Path $testRoot "machine-invalid") `
        -WithoutDart
    $resolved = Resolve-FlutterSdk `
        -ConfiguredRoot "" `
        -PathFlutterCommand "" `
        -UserProfilePath "" `
        -MachineSearchRoots @($invalidMachineRoot, $validMachineRoot)

    Assert-Equal $validMachineRoot $resolved.Root "an incomplete SDK must be skipped"
    Assert-Equal `
        (Join-Path $validMachineRoot "bin\dart.bat") `
        $resolved.Dart `
        "the resolver must return Dart from the same SDK"
}
finally {
    $resolvedTestRoot = (Resolve-Path -LiteralPath $testRoot).Path
    $normalizedBase = $temporaryBase.TrimEnd("\") + "\"
    if (-not $resolvedTestRoot.StartsWith($normalizedBase, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to remove non-temporary test path: $resolvedTestRoot"
    }
    Remove-Item -LiteralPath $resolvedTestRoot -Recurse -Force
}

Write-Host "Flutter SDK resolver tests passed ($testsRun assertions)."
