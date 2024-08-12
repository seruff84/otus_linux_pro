
if (-not (Get-Module -ListAvailable -Name VMware.PowerCLI)) {
  Install-Module -Name VMware.PowerCLI -Scope CurrentUser -AllowClobber
}


Import-Module VMware.PowerCLI


$vcServer = "vcenter.avselectro.ru"
$vcUser = "adm_avselectro@avselectro.ru"
$vcPassword = "iuh829amZ"

Connect-VIServer -Server $vcServer -User $vcUser -Password $vcPassword


$vmName = "CRM_APP_2012R2Std" 
$vm = Get-VM -Name $vmName


Write-Host "Имя виртуальной машины: $($vm.Name)"
Write-Host "Кол-во vCPU: $($vm.NumCpu)"
Write-Host "Объем памяти (МБ): $($vm.MemoryMB)"


Write-Host "Сетевые адаптеры:"
$vm | Get-NetworkAdapter | ForEach-Object {
    Write-Host "  Тип адаптера: $($_.Type)"
    Write-Host "  MAC адрес: $($_.MacAddress)"
    Write-Host "  Сетевая карта: $($_.NetworkName)"
}


Write-Host "Диски:"
$vm | Get-HardDisk | ForEach-Object {
    Write-Host "  Имя диска: $($_.Name)"
    Write-Host "  Тип: $($_.StorageFormat)"  
    Write-Host "  Размер (ГБ): $($_.CapacityGB)"
    Write-Host "  Расположение: $($_.Filename)"
}


Write-Host "Тип доступа к памяти: $($vm.MemoryReservationType)"



Disconnect-VIServer -Server $vcServer -Confirm:$false

