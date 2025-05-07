# ── 설정 영역 ─────────────────────────────────────────────────────────
$pathsToDelete = @(
    # 이벤트 뷰어 로그 파일(.evtx)
    "C:\Windows\System32\winevt\Logs\*.evtx",
    # 사용자 지정 애플리케이션 로그 (예: C:\Logs\*.log)
    "C:\Logs\*.log",
    # 시스템 임시 파일
    "C:\Windows\Temp\*.*",
    # 현재 사용자 임시 파일
    "$env:TEMP\*.*"
)

# 하위 폴더까지 삭제하려면 $true, 아니면 $false
$useRecurse = $true

# 삭제 직전에 “삭제하시겠습니까?” 프롬프트를 띄울지 여부
$confirmBeforeDelete = $true
# ── 스크립트 본문 ───────────────────────────────────────────────────────

Function Delete-Files {
    param(
        [string[]] $Paths,
        [bool]    $Recurse,
        [bool]    $Confirm
    )
    foreach ($p in $Paths) {
        Write-Host "=== 삭제 처리: $p ==="
        $args = @("-Force")
        if ($Recurse) { $args += "-Recurse" }
        if ($Confirm) { $args += "-Confirm" }
        Remove-Item $p @args
    }
}

Function Clear-EventLogs {
    wevtutil el | ForEach-Object {
        Write-Host "이벤트 로그 비우기: $_"
        wevtutil cl $_
    }
}

# 1) 이벤트 뷰어 로그 비우기
Clear-EventLogs

# 2) 시스템/사용자 임시 파일 및 애플리케이션 로그 삭제
Delete-Files -Paths $pathsToDelete -Recurse:$useRecurse -Confirm:$confirmBeforeDelete

# 3) 10초 후 시스템 종료
Write-Host "10초 후 시스템을 종료합니다..."
Start-Sleep -Seconds 10
Stop-Computer -ComputerName localhost -Force
