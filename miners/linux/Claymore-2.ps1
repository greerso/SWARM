##Miner Path Information
$Path = "$($nvidia.claymore.path2)"
$Uri = "$($nvidia.claymore.uri)"
$MinerName = "$($nvidia.claymore.minername)"
$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName
$Build = "Tar"

$ConfigType = "NVIDIA2"

##Parse -GPUDevices
if($NVIDIADevices2 -ne ''){
$ClayDevices2  = $NVIDIADevices2 -split ","
$ClayDevices2  = Switch($ClayDevices2){"10"{"a"};"11"{"b"};"12"{"c"};"13"{"d"};"14"{"e"};"15"{"f"};"16"{"g"};"17"{"h"};"18"{"i"};"19"{"j"};"20"{"k"};default{"$_"};}
$ClayDevices2  = $ClayDevices2 | foreach {$_ -replace ("$($_)",",$($_)")}
$ClayDevices2  = $ClayDevices2 -join ""
$ClayDevices2  = $ClayDevices2.TrimStart(" ",",")  
$ClayDevices2 = $ClayDevices2 -replace(",","")
$Devices = $ClayDevices2}

##Get Configuration File
$GetConfig = "$dir\config\miners\claymore.json"
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
   DeviceCall = "claymore"
   Arguments = "-platform 2 -mport 3334 -mode 1 -allcoins 1 -allpools 1 -epool $($AlgoPools.$_.Protocol)://$($AlgoPools.$_.Host):$($AlgoPools.$_.Port) -ewal $($AlgoPools.$_.User2) -epsw $($AlgoPools.$_.Pass2)$($Diff) -wd 0 -dbg -1 -eres 1 $($Config.$ConfigType.commands.$_)"
   HashRates = [PSCustomObject]@{$_ = $($Stats."$($Name)_$($_)_hashrate".Day)}
   PowerX = [PSCustomObject]@{$_ = if($WattOMeter -eq "Yes"){$($Stats."$($Name)_$($_)_Power".Day)}elseif($Watts.$($_)."$($ConfigType)_Watts"){$Watts.$($_)."$($ConfigType)_Watts"}elseif($Watts.default."$($ConfigType)_Watts"){$Watts.default."$($ConfigType)_Watts"}else{0}}
   ocpower = if($Config.$ConfigType.oc.$_.power){$Config.$ConfigType.oc.$_.power}else{$OC."default_$($ConfigType)".Power}
   occore = if($Config.$ConfigType.oc.$_.core){$Config.$ConfigType.oc.$_.core}else{$OC."default_$($ConfigType)".core}
   ocmem = if($Config.$ConfigType.oc.$_.memory){$Config.$ConfigType.oc.$_.memory}else{$OC."default_$($ConfigType)".memory}
   ethpill = $Config.$ConfigType.oc.$_.ethpill
   pilldelay = $Config.$ConfigType.oc.$_.pilldelay
    FullName = "$($AlgoPools.$_.Mining)"
   API = "claymore"
   Port = 3334
   MinerPool = "$($AlgoPools.$_.Name)"
   URI = $Uri
   BUILD = $Build
   Algo = "$($_)"
   }
  }
 }
}
else{
  $CoinPools | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name |
  Where {$($Config.$ConfigType.commands.$($CoinPools.$_.Algorithm)) -NE $null} |
  foreach {
  if($Config.$ConfigType.difficulty.$($CoinPools.$_.Algorithm)){$Diff=",d=$($Difficulty.$($CoinPools.$_.Algorithm))"}
  [PSCustomObject]@{
  Symbol = "$($CoinPools.$_.Symbol)"
  MinerName = $MinerName
  Prestart = $PreStart
  Type = $ConfigType
  Path = $Path
  Devices = $Devices
  DeviceCall = "claymore"
  Arguments = "-platform 2 -mport 3334 -mode 1 -allcoins 1 -allpools 1 -epool $($CoinPools.$_.Protocol)://$($CoinPools.$_.Host):$($CoinPools.$_.Port) -ewal $($CoinPools.$_.User2) -epsw $($CoinPools.$_.Pass2)$($Diff) -wd 0 -dbg -1 -eres 1 $($Config.$ConfigType.commands.$($CoinPools.$_.Algorithm))"
  HashRates = [PSCustomObject]@{$CoinPools.$_.Symbol= $($Stats."$($Name)_$($CoinPools.$_.Algorithm)_hashrate".Day)}
  PowerX = [PSCustomObject]@{$CoinPools.$_.Symbol = if($WattOMeter -eq "Yes"){$($Stats."$($Name)_$($CoinPools.$_.Algorithm)_Power".Day)}elseif($Watts.$($CoinPools.$_.Algorithm)."$($ConfigType)_Watts"){$Watts.$($CoinPools.$_.Algorithm)."$($ConfigType)_Watts"}elseif($Watts.default."$($ConfigType)_Watts"){$Watts.default."$($ConfigType)_Watts"}else{0}}
  ocpower = if($Config.$ConfigType.oc.$($CoinPools.$_.Algorithm).power){$Config.$ConfigType.oc.$($CoinPools.$_.Algorithm).power}else{$OC."default_$($ConfigType)".Power}
  occore = if($Config.$ConfigType.oc.$($CoinPools.$_.Algorithm).core){$Config.$ConfigType.oc.$($CoinPools.$_.Algorithm).core}else{$OC."default_$($ConfigType)".core}
  ocmem = if($Config.$ConfigType.oc.$($CoinPools.$_.Algorithm).memory){$Config.$ConfigType.oc.$($CoinPools.$_.Algorithm).memory}else{$OC."default_$($ConfigType)".memory}
  ethpill = $Config.$ConfigType.oc.$($CoinPools.$_.Algorithm).ethpill
  pilldelay = $Config.$ConfigType.oc.$($CoinPools.$_.Algorithm).pilldelay
  FullName = "$($CoinPools.$_.Mining)"
  MinerPool = "$($CoinPools.$_.Name)"
  API = "claymore"
  Port = 3334
  URI = $Uri
  BUILD = $Build
  Algo = "$($CoinPools.$_.Algorithm)"
   }
  }
 }
