param(
  [Parameter(Mandatory)] [string] $DestDir,
  [Parameter(Mandatory)] [string] $Keys
)

New-Item -ItemType Directory -Path $DestDir -Force | Out-Null

$parsedKeys = if ($Keys -match ';|\r|\n') {
  $Keys -split '\s*;\s*|\r?\n' | Where-Object { $_ -and $_.Trim() }
} else {
  @($Keys.Trim())
}

foreach ($key in $parsedKeys) {
  $safeName = $key -replace '[\\/:*?"<>|]', '_'
  $destFile  = Join-Path $DestDir "$safeName.reg"

  $tmp = [System.IO.Path]::GetTempFileName()
  try {
    reg export $key $tmp /y 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
      Write-Warning "failed to export registry key: $key"
      continue
    }

    $lines   = Get-Content $tmp
    $output  = [System.Collections.Generic.List[string]]::new()
    $block   = [System.Collections.Generic.List[string]]::new()

    foreach ($line in $lines) {
      if ($line -match '^\[') {
        if ($block.Count) {
          foreach ($entry in ($block | Sort-Object)) {
            $output.Add([string]$entry)
          }

          $block.Clear()
        }
        $output.Add($line)
      } elseif ($line -eq '') {
        if ($block.Count) {
          foreach ($entry in ($block | Sort-Object)) {
            $output.Add([string]$entry)
          }
          $block.Clear()
        }
        $output.Add($line)
      } elseif ($line -match '^(Windows Registry Editor|REGEDIT)') {
        $output.Add($line)
      } else {
        $block.Add($line)
      }
    }
    if ($block.Count) { 
      foreach ($entry in ($block | Sort-Object)) {
        $output.Add([string]$entry)
      }
    }

    $output | Set-Content -Encoding Unicode $destFile
  } finally {
    Remove-Item $tmp -ErrorAction SilentlyContinue
  }
}
