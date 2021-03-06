<#
SWARM is open-source software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
SWARM is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
#>
  function Get-GPUCount {
    param (
    [Parameter(Mandatory=$false)]
    [String]$Platforms,
    [Parameter(Mandatory=$true)]
    [Array]$DeviceType,
    [Parameter(Mandatory=$false)]
    [Int]$CPUThreads
    )

    $nvidiacounted = $false
    $DeviceList = @{}
    $DeviceList.Add("NVIDIA",@{})
    $DeviceList.Add("CPU",@{})

    $DeviceType | foreach{
      if($_ -like "*NVIDIA*" -and $nvidiacounted -eq $false)
       {
        $nvidiacounted = $true
        Write-Host "Getting NVIDIA GPU Count" -foregroundcolor cyan
        invoke-expression ".\build\apps\nvidia-smi.exe -L > "".\build\txt\gpucount.txt"""
        Start-Sleep -S .25
        $GCount = Get-Content ".\build\txt\gpucount.txt" -Force
        $AttachedGPU = $GCount | foreach {$_ -split ":" | Select -First 1} | foreach {$_ -replace ("GPU ","")}
        for($i=0; $i -lt $AttachedGPU.Count; $i++){$DeviceList.NVIDIA.Add("$($i)","$($AttachedGPU[$i])")}
        }
        if($_ -like "*CPU*")
        {
         Write-Host "Getting CPU Count"
         for($i=0; $i -lt $CPUThreads; $i++)
         { 
          $DeviceList.CPU.Add("$($i)",$i)
         }     
        }
      }
     $DeviceList | ConvertTo-Json | Set-Content ".\build\txt\devicelist.txt"
     $GPUCount = 0
     $GPUCount += $DeviceList.Nvidia.Count
     $GPUCount
  }
 