function parseXML {
    param (
        [string]$xmlFile
    )
    $fileName = Split-Path $xmlFile -leaf
    Write-Log -EntryType Information -Message "Обработка файла $fileName"
    [xml]$xml = Get-Content $xmlFile
    
    $list = $xml.ФайлПФР.ПачкаВходящихДокументов.СПИСОК_НА_ЗАЧИСЛЕНИЕ
    if (($list | Measure-Object).count -eq 0) {        
        throw "Информация для парсинга в файле $fileName не найдена!"
    }
    
    $people = @()
    
    ForEach ($person in $list.СведенияОполучателе) {
        $fio = $person.ФИО
        $fullName = $fio.Фамилия + ' ' + $fio.Имя + ' ' + $fio.Отчество
        
        $obj = New-Object psobject            
        $obj | Add-Member -type noteproperty -name iterator -Value 0            
        $obj | Add-Member -type noteproperty -name  account -Value $person.НомерСчета
        $obj | Add-Member -type noteproperty -name  sum -Value $person.СуммаКдоставке
        $obj | Add-Member -type noteproperty -name  fio -Value $fullName

        $people += $obj        
    }    
    return $people
}

function addIterator {
    param (
        $data
    )
    
    for ($i = 0; $i -lt $data.Count; $i++) {        
        $data[$i].iterator = $i + 1
    }

    return $data
}

function exportCSV {
    param (
        $data,
        [string]$fileName
    )
    
    if (($data | Measure-Object).count -eq 0) {
        throw "Информация в XML-файле не найдена!"        
    }
    
    $data | Export-Csv -Path $fileName -NoTypeInformation -Delimiter "," -Force -Encoding OEM
    
    Write-Log -EntryType Information -Message "Сохраняем результат в файл $fileName"
}

function convertCsv {
    param (
        $fileName
    )
    $content = Get-Content $fileName | Select-Object -Skip 1

    for ($i = 0; $i -lt $content.Count; $i++) {
        $content[$i] = $content[$i] -replace '"', ''
    }
    $content | Set-Content -Path $fileName
}