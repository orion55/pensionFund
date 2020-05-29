#Программа конвертации xml-файлов из Пенсионного фонда в csv-файл
#(c) Гребенёв О.Е. 29.05.2020

[string]$curDir = Split-Path -Path $myInvocation.MyCommand.Path -Parent
Set-Location $curDir
[string]$lib = "$curDir\lib"
$curDate = Get-Date -Format "ddMMyyyy"
[string]$logName = $curDir + "\log\" + $curDate + "_pension.log"

[string]$inPath = "$curDir\in"
[string]$outPath = "$curDir\out"

[string]$csvFile = $outPath + "\" + $curDate + ".txt"

. $lib/PSMultiLog.ps1
. $lib/libs.ps1
. $lib/util.ps1

Clear-Host

Start-HostLog -LogLevel Information
Start-FileLog -LogLevel Information -FilePath $logName -Append

#проверяем существуют ли нужные пути и файлы
testDir(@($inPath, $outPath))

Write-Log -EntryType Information -Message "Начало работы pensionFund"

$xmlFiles = Get-ChildItem "$inPath\PFR*SPIS*.xml"
if (($xmlFiles | Measure-Object).count -eq 0) {
    Write-Log -EntryType Error -Message "Xml-файлы в $inPath не найдены!"
    exit
}

$info = @()

ForEach ($xmlFile in $xmlFiles) {
    Try {        
        $info += parseXML -xmlFile $xmlFile
    }
    Catch {
        Write-Log -EntryType Error $PSItem.ToString()
    }  
}

$info = addIterator -data $info

$info | Format-Table

Try {        
    exportCSV -data $info -fileName $csvFile
}
Catch {
    Write-Log -EntryType Error $PSItem.ToString()
}  

convertCsv -fileName $csvFile

Write-Log -EntryType Information -Message "Конец работы pensionFund"

Stop-FileLog
Stop-HostLog