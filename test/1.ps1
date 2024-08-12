# Установите модуль PowerCLI, если еще не установлен
if (-not (Get-Module -ListAvailable -Name VMware.PowerCLI)) {
    Install-Module -Name VMware.PowerCLI -Scope CurrentUser -AllowClobber
}

# Импорт модуля PowerCLI
Import-Module VMware.PowerCLI

# Подключение к vCenter серверу
# Укажите свои учетные данные
$vcServer = "vcenter.avselectro.ru"
$vcUser = "adm_avselectro@avselectro.ru"
$vcPassword = "iuh829amZ"
Connect-VIServer -Server $vcServer -User $vcUser -Password $vcPassword

# Функция для получения IP адреса BMC
function Get-BMCIPAddress {
    param (
        [VMware.VimAutomation.ViCore.Impl.V1.Inventory.HostSystemImpl]$ESXiHost
    )

    # Предположим, что IPMI/BMC IP доступен через CIM интерфейс
    try {
        $bmcInfo = Get-View $ESXiHost.ExtensionData.ConfigManager.BaseBoardManagementInfo
        return $bmcInfo.ManagerIp
    } catch {
        return "N/A"
    }
}

# Сбор данных с ESXi хостов
$esxiHosts = Get-VMHost

$vmhostData = foreach ($vmhost in $esxiHosts) {
    #$vmkernelIps = ($vmhost.ExtensionData.Config.Network.Vnic | Where-Object {$_.Portgroup -eq "Management Network"} | Select-Object -ExpandProperty Spec | Select-Object -ExpandProperty Ip).ipaddress
    $vmkernelIps = ($vmhost.ExtensionData.Config.Network.Vnic  | Select-Object -ExpandProperty Spec | Select-Object -ExpandProperty Ip| Where-Object {$_.ipaddress -like "10.36.24.*"}).ipaddress
    $tags = Get-TagAssignment -Entity $vmhost | ForEach-Object { $_.Tag.Name }  

    [PSCustomObject]@{
        HostName        = $vmhost.Name
        VMKernelIP      = $vmkernelIps -join ", "
        Tags            = $tags
    }
}

# Отключение от vCenter
Disconnect-VIServer -Server $vcServer -Confirm:$false

# Вывод данных в виде таблицы
$vmhostData | Format-Table -AutoSize