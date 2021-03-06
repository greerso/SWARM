##Miner Path Information
$Path = "$($nvidia.klaust.path2)"
$Uri = "$($nvidia.klaust.uri)"
$MinerName = "$($nvidia.klaust.minername)"
$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName
$Build = "Tar"

$ConfigType = "NVIDIA2"

##Parse -GPUDevices
if($NVIDIADevices2 -ne ''){$Devices = $NVIDIADevices2}

##Get Configuration File
$GetConfig = "$dir\config\miners\klaust.json"
try{$Config = Get-Content $GetConfig | ConvertFrom-Json}
catch{Write-Warning "Warning: No config found at $GetConfig"}

##Export would be /path/to/[SWARMVERSION]/build/export##
$ExportDir = Join-Path $dir "build\export"

##Prestart actions before miner launch
$Prestart = @()
$PreStart += "export LD_LIBRARY_PATH=`$LD_LIBRARY_PATH:$ExportDir"
$Config.$ConfigType.prestart | foreach {$Prestart += "$($_)"}

if($CoinAlgo -eq $null)
{
$Config.$ConfigType.commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
if($Algorithm -eq "$($AlgoPools.$_.Algorithm)")
 {
 if($Config.$ConfigType.difficulty.$_){$Diff=",d=$($Difficulty.$_)"}
    [PSCustomObject]@{
    Symbol = "$($_)"
    MinerName = $MinerName
    Prestart = $PreStart
    Type = $ConfigType
    Path = $Path
    Devices = $Devices
    DeviceCall = "ccminer"
    Arguments = "-a $(Get-Nvidia($_)) -o stratum+tcp://$($AlgoPools.$_.Host):$($AlgoPools.$_.Port) -b 0.0.0.0:4069 -u $($AlgoPools.$_.User2) -p $($AlgoPools.$_.Pass2)$($Diff) $($Config.$ConfigType.commands.$_)"
    HashRates = [PSCustomObject]@{$_ = $($Stats."$($Name)_$($_)_hashrate".Day)}
    PowerX = [PSCustomObject]@{$_ = if($WattOMeter -eq "Yes"){$($Stats."$($Name)_$($_)_Power".Day)}elseif($Watts.$($_)."$($ConfigType)_Watts"){$Watts.$($_)."$($ConfigType)_Watts"}elseif($Watts.default."$($ConfigType)_Watts"){$Watts.default."$($ConfigType)_Watts"}else{0}}
    ocpower = if($Config.$ConfigType.oc.$_.power){$Config.$ConfigType.oc.$_.power}else{$OC."default_$($ConfigType)".Power}
    occore = if($Config.$ConfigType.oc.$_.core){$Config.$ConfigType.oc.$_.core}else{$OC."default_$($ConfigType)".core}
    ocmem = if($Config.$ConfigType.oc.$_.memory){$Config.$ConfigType.oc.$_.memory}else{$OC."default_$($ConfigType)".memory}
      Port = 4069
    MinerPool = "$($AlgoPools.$_.Name)"
    FullName = "$($AlgoPools.$_.Mining)"
    API = "Ccminer"
    URI = $Uri
    BUILD = $Build
    Stats = "ccminer"
    Algo = "$($_)"
   }
  }
 }
}
else{  
  $CoinPools | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name |
  Where {$($Config.$ConfigType.commands.$($CoinPools.$_.Algorithm)) -NE $null} |
   foreach {
    if($Config.$ConfigType.difficulty.$_.$($CoinPools.$_.Algorithm)){$Diff=",d=$($Difficulty.$($CoinPools.$_.Algorithm))"}
    [PSCustomObject]@{
   Symbol = "$($CoinPools.$_.Symbol)"
   MinerName = $MinerName
   Prestart = $PreStart
   Type = $ConfigType
   Path = $Path
   Devices = $Devices
   DeviceCall = "ccminer"
   Arguments = "-a $(Get-Nvidia($CoinPools.$_.Algorithm)) -o stratum+tcp://$($CoinPools.$_.Host):$($CoinPools.$_.Port) -b 0.0.0.0:4069 -u $($CoinPools.$_.User2) -p $($CoinPools.$_.Pass2)$($Diff) $($Config.$ConfigType.commands.$($Coinpools.$_.Algorithm))"
   HashRates = [PSCustomObject]@{$CoinPools.$_.Symbol= $Stats."$($Name)_$($CoinPools.$_.Algorithm)_HashRate".Day}
   API = "Ccminer"
   PowerX = [PSCustomObject]@{$CoinPools.$_.Symbol = if($WattOMeter -eq "Yes"){$($Stats."$($Name)_$($CoinPools.$_.Algorithm)_Power".Day)}elseif($Watts.$($CoinPools.$_.Algorithm)."$($ConfigType)_Watts"){$Watts.$($CoinPools.$_.Algorithm)."$($ConfigType)_Watts"}elseif($Watts.default."$($ConfigType)_Watts"){$Watts.default."$($ConfigType)_Watts"}else{0}}
   ocpower = if($Config.$ConfigType.oc.$($CoinPools.$_.Algorithm).power){$Config.$ConfigType.oc.$($CoinPools.$_.Algorithm).power}else{$OC."default_$($ConfigType)".Power}
   occore = if($Config.$ConfigType.oc.$($CoinPools.$_.Algorithm).core){$Config.$ConfigType.oc.$($CoinPools.$_.Algorithm).core}else{$OC."default_$($ConfigType)".core}
   ocmem = if($Config.$ConfigType.oc.$($CoinPools.$_.Algorithm).memory){$Config.$ConfigType.oc.$($CoinPools.$_.Algorithm).memory}else{$OC."default_$($ConfigType)".memory}
    FullName = "$($CoinPools.$_.Mining)"
   MinerPool = "$($CoinPools.$_.Name)"
   Port = 4069
   URI = $Uri
   BUILD = $Build
   Algo = "$($CoinPools.$_.Algorithm)"
   }
  }
 }
