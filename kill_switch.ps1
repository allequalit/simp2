# ���� �ѱ� ���� ���� (�ݵ�� �� ����) ��������������������������������������������������������������������������
# �ܼ� �ڵ��������� UTF-8(65001)�� ����
chcp 65001 | Out-Null

# �Ŀ��� ����� ��� UTF-8 ���
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8


Write-Host "##################################################"
Write-Host "#          !!! �� �� !!!                         #"
Write-Host "# �� ���α׷��� ������ �α�/�ӽ� ������ �����ϰ�   #"
Write-Host "#     ��� ���� ������ �����մϴ�.               #"
Write-Host "##################################################"
$confirm = Read-Host "`n����Ϸ��� y�� �Է��ϰ� Enter�� ��������"
if ($confirm -notmatch '^(?i)(y|yes)$') {
    Write-Host "`n��ҵǾ����ϴ�."
    exit 1
}

# ���� ���� ���� ������������������������������������������������������������������������������������������������������������������
$pathsToDelete = @(
    "C:\Windows\System32\winevt\Logs\*.evtx",
    "C:\Logs\*.log",
    "C:\Windows\Temp\*.*",
    "$env:TEMP\*.*"
)
$useRecurse = $true
$confirmBeforeDelete = $false

# ���� �Լ� ���� ������������������������������������������������������������������������������������������������������������������
Function Clear-EventLogs {
    wevtutil el | ForEach-Object {
        Write-Host "�̺�Ʈ �α� ����: $_"
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
        Write-Host "=== ���� ó��: $p ==="
        # Confirm �Ű������� ����, �׻� false �� ����
        Remove-Item -Path $p -Force -Recurse:$Recurse -Confirm:$false -ErrorAction SilentlyContinue
    }
}

# ���� ���� ���� ����������������������������������������������������������������������������������������������������������������������
Clear-EventLogs
Delete-Files -Paths $pathsToDelete -Recurse:$useRecurse -Confirm:$confirmBeforeDelete

Write-Host "`n�ý����� ��� �����մϴ�..."
Stop-Computer -Force
