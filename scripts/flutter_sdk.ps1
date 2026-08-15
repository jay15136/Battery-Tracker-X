Set-StrictMode -Version Latest

function Resolve-FlutterSdk {
    [CmdletBinding()]
    param(
        [AllowEmptyString()]
        [string]$ConfiguredRoot = $env:BATTERY_TRACKER_FLUTTER_ROOT,

        [AllowEmptyString()]
        [string]$PathFlutterCommand = $(
            $pathCommand = Get-Command flutter -CommandType Application -ErrorAction SilentlyContinue |
                Select-Object -First 1
            if ($null -ne $pathCommand) {
                $pathCommand.Source
            }
        ),

        [AllowEmptyString()]
        [string]$UserProfilePath = $env:USERPROFILE,

        [AllowEmptyCollection()]
        [string[]]$MachineSearchRoots = @("C:\src\flutter", "C:\flutter")
    )

    $candidates = @()

    if (-not [string]::IsNullOrWhiteSpace($ConfiguredRoot)) {
        $candidates += [pscustomobject]@{
            Root = $ConfiguredRoot
            Flutter = Join-Path $ConfiguredRoot "bin\flutter.bat"
            Source = "BATTERY_TRACKER_FLUTTER_ROOT"
        }
    }

    if (-not [string]::IsNullOrWhiteSpace($PathFlutterCommand)) {
        $pathBin = Split-Path -Parent $PathFlutterCommand
        $candidates += [pscustomobject]@{
            Root = Split-Path -Parent $pathBin
            Flutter = $PathFlutterCommand
            Source = "PATH"
        }
    }

    if (-not [string]::IsNullOrWhiteSpace($UserProfilePath)) {
        $userRelativeRoots = @(
            "Develop\flutter",
            "development\flutter",
            "flutter",
            "fvm\default",
            "AppData\Local\Flutter"
        )

        foreach ($relativeRoot in $userRelativeRoots) {
            $root = Join-Path $UserProfilePath $relativeRoot
            $candidates += [pscustomobject]@{
                Root = $root
                Flutter = Join-Path $root "bin\flutter.bat"
                Source = "per-user location"
            }
        }
    }

    foreach ($root in $MachineSearchRoots) {
        if (-not [string]::IsNullOrWhiteSpace($root)) {
            $candidates += [pscustomobject]@{
                Root = $root
                Flutter = Join-Path $root "bin\flutter.bat"
                Source = "common location"
            }
        }
    }

    $seenFlutterCommands = @{}
    foreach ($candidate in $candidates) {
        if ($seenFlutterCommands.ContainsKey($candidate.Flutter)) {
            continue
        }
        $seenFlutterCommands[$candidate.Flutter] = $true

        $dartCommand = Join-Path (Split-Path -Parent $candidate.Flutter) "dart.bat"
        if (
            (Test-Path -LiteralPath $candidate.Flutter -PathType Leaf) -and
            (Test-Path -LiteralPath $dartCommand -PathType Leaf)
        ) {
            return [pscustomobject]@{
                Root = (Resolve-Path -LiteralPath $candidate.Root).Path
                Flutter = (Resolve-Path -LiteralPath $candidate.Flutter).Path
                Dart = (Resolve-Path -LiteralPath $dartCommand).Path
                Source = $candidate.Source
            }
        }
    }

    throw @"
Flutter SDK not found. The scripts checked:
  1. BATTERY_TRACKER_FLUTTER_ROOT
  2. flutter on PATH
  3. Common per-user Flutter folders
  4. C:\src\flutter and C:\flutter

Set BATTERY_TRACKER_FLUTTER_ROOT to the Flutter SDK root or add its bin folder to PATH.
"@
}
