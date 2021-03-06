$Path = "$($nvidia.claymore.path1)"
$Uri = "$($nvidia.claymore.uri)"
$MinerName = "$($nvidia.claymore.minername)"

$Build = "Zip"

if($NVIDIADevices1 -ne ''){
  $ClayDevices1  = $NVIDIADevices1 -split ","
  $ClayDevices1  = Switch($ClayDevices1){"10"{"a"};"11"{"b"};"12"{"c"};"13"{"d"};"14"{"e"};"15"{"f"};"16"{"g"};"17"{"h"};"18"{"i"};"19"{"j"};"20"{"k"};default{"$_"};}
  $ClayDevices1  = $ClayDevices1 | foreach {$_ -replace ("$($_)",",$($_)")}
  $ClayDevices1  = $ClayDevices1 -join ""
  $ClayDevices1  = $ClayDevices1.TrimStart(" ",",")  
  $ClayDevices1 = $ClayDevices1 -replace(",","")
  $Devices = $ClayDevices1}

$Commands

$Commands = [PSCustomObject]@{
 "ethash" = '-esm 2'
 "daggerhashimoto" = '-esm 3 -estale 0'
 "dagger" = '-esm 2'
}

$Difficulty = [PSCustomObject]@{
"ethash" = ''
"daggerhashimoto" = ''
"dagger" = ''
}


$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

if($CoinAlgo -eq $null)
{
$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
if($Algorithm -eq "$($AlgoPools.$_.Algorithm)")
 {
  if($Difficulty.$_){$Diff=",d=$($Difficulty.$_)"}
  [PSCustomObject]@{
  Platform = $Platform  
  Symbol = "$($_)"
  MinerName = $MinerName
  Type = "NVIDIA1"
  Path = $Path
  Devices = $Devices
  DeviceCall = "claymore"
  Arguments = "-mport 3333 -mode 1 -allcoins 1 -allpools 1 -epool $($AlgoPools.$_.Protocol)://$($AlgoPools.$_.Host):$($AlgoPools.$_.Port) -ewal $($AlgoPools.$_.User1) -epsw $($AlgoPools.$_.Pass1)$($Diff) -wd 0 -dbg -1 -eres 1 $($Commands.$_)"
  HashRates = [PSCustomObject]@{$_ = $($Stats."$($Name)_$($_)_hashrate".Day)}
  PowerX = [PSCustomObject]@{$_ = if($WattOMeter -eq "Yes"){$($Stats."$($Name)_$($_)_Power".Day)}elseif($Watts.$($_).NVIDIA1_Watts){$Watts.$($_).NVIDIA1_Watts}elseif($Watts.default.NVIDIA1_Watts){$Watts.default.NVIDIA1_Watts}else{0}}
  FullName = "$($AlgoPools.$_.Mining)"
  API = "claymore"
  Port = 3333
  MinerPool = "$($AlgoPools.$_.Name)"
  Wrap = $false
  URI = $Uri
  BUILD = $Build
  Algo = "$($_)"
  NewAlgo = ''
      }
    }
  }
}
else {
$CoinPools | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name |
Where {$($Commands.$($CoinPools.$_.Algorithm)) -NE $null} |
foreach {
  if($Difficulty.$($CoinPools.$_.Algorithm)){$Diff=",d=$($Difficulty.$($CoinPools.$_.Algorithm))"}
  [PSCustomObject]@{
  Platform = $Platform
  Coin = "Yes"
  Symbol = "$($CoinPools.$_.Symbol)"
  MinerName = $MinerName
  Type = "NVIDIA1"
  Path = $Path
  Devices = $Devices
  DeviceCall = "claymore"
  Arguments = "-mport 3333 -mode 1 -allcoins 1 -allpools 1 -epool $($CoinPools.$_.Protocol)://$($CoinPools.$_.Host):$($CoinPools.$_.Port) -ewal $($CoinPools.$_.User1) -epsw $($CoinPools.$_.Pass1)$($Diff) -wd 0 -dbg -1 -eres 1 $($Commands.$($CoinPools.$_.Algorithm))"
  HashRates = [PSCustomObject]@{$CoinPools.$_.Symbol= $($Stats."$($Name)_$($CoinPools.$_.Algorithm)_hashrate".Day)}
  PowerX = [PSCustomObject]@{$CoinPools.$_.Symbol = if($WattOMeter -eq "Yes"){$($Stats."$($Name)_$($CoinPools.$_.Algorithm)_Power".Day)}elseif($Watts.$($CoinPools.$_.Algorithm).NVIDIA1_Watts){$Watts.$($CoinPools.$_.Algorithm).NVIDIA1_Watts}elseif($Watts.default.NVIDIA1_Watts){$Watts.default.NVIDIA1_Watts}else{0}}
  FullName = "$($CoinPools.$_.Mining)"
  MinerPool = "$($CoinPools.$_.Name)"
  API = "claymore"
  Port = 3333
  Wrap = $false
  URI = $Uri
  BUILD = $Build
  Algo = "$($CoinPools.$_.Algorithm)"
    }
  }
}