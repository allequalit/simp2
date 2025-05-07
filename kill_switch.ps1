# ── 한글 깨짐 방지 설정 (반드시 맨 위에) ────────────────────────────────
# 1) 콘솔 코드페이지를 UTF-8(65001)로 변경
chcp 65001 | Out-Null

# 2) PowerShell 출력 인코딩을 UTF-8로 설정
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "##################################################"
Write-Host "#          !!! 경 고 !!!                         #"
Write-Host "# 이 프로그램은 서버의 로그/임시 파일을 정리하고   #"
Write-Host "#     즉시 서버 전원을 종료합니다.               #"
Write-Host "##################################################"
$confirm = Read-Host "`n계속하려면 y를 입력하고 Enter를 누르세요"
if ($confirm -notmatch '^(?i)(y|yes)$') {
    Write-Host "`n취소되었습니다."
    exit 1
}

# ── 설정 영역 ─────────────────────────────────────────────────────────
$pathsToDelete = @(
    "C:\Windows\System32\winevt\Logs\*.evtx",
    "C:\Logs\*.log",
    "C:\Windows\Temp\*.*",
    "$env:TEMP\*.*"
)
$useRecurse = $true
$confirmBeforeDelete = $true

# ── 함수 정의 ─────────────────────────────────────────────────────────
Function Clear-EventLogs {
    wevtutil el | ForEach-Object {
        Write-Host "이벤트 로그 비우기: $_"
        wevtutil cl $_
    }
}

Function Delete-Files {
    param(
        [string[]] $Paths,
        [bool]    $Recurse,
        [bool]    $Confirm
    )
    foreach ($p in $Paths) {
        Write-Host "=== 삭제 처리: $p ==="
        $params = @{
            Path    = $p
            Force   = $true
            Confirm = $Confirm
        }
        if ($Recurse) { $params.Recurse = $true }
        Remove-Item @params
    }
}

# ── 실행 본문 ───────────────────────────────────────────────────────────
Clear-EventLogs
Delete-Files -Paths $pathsToDelete -Recurse:$useRecurse -Confirm:$confirmBeforeDelete

Write-Host "`n시스템을 즉시 종료합니다..."
Stop-Computer -Force
