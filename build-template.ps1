$ErrorActionPreference = 'Stop'

$sourceDir = 'C:\Users\E1560361\AppData\Local\Temp\opencode\form5_unpacked'
$templateDir = 'C:\Users\E1560361\AppData\Local\Temp\opencode\form5_template'
$documentXmlPath = Join-Path $templateDir 'word\document.xml'
$outputDocx = 'C:\Users\E1560361\Desktop\workspaces\WPR\template.docx'
$outputBase64 = 'C:\Users\E1560361\AppData\Local\Temp\opencode\template.base64.txt'

if (Test-Path $templateDir) {
    Remove-Item -LiteralPath $templateDir -Recurse -Force
}

Copy-Item -LiteralPath $sourceDir -Destination $templateDir -Recurse

$doc = New-Object System.Xml.XmlDocument
$doc.PreserveWhitespace = $true
$doc.Load($documentXmlPath)

$ns = New-Object System.Xml.XmlNamespaceManager($doc.NameTable)
$ns.AddNamespace('w', 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')
$ns.AddNamespace('w14', 'http://schemas.microsoft.com/office/word/2010/wordml')

function Get-Paragraph([string]$paraId) {
    $paragraph = $doc.SelectSingleNode("//*[@w14:paraId='$paraId']", $ns)
    if (-not $paragraph) {
        throw "Paragraph with paraId $paraId not found."
    }
    return $paragraph
}

function Ensure-FirstRun([System.Xml.XmlNode]$paragraph) {
    $run = $paragraph.SelectSingleNode('w:r[1]', $ns)
    if (-not $run) {
        $run = $doc.CreateElement('w', 'r', $ns.LookupNamespace('w'))
        $paragraph.AppendChild($run) | Out-Null
    }
    return $run
}

function Ensure-FirstTextNode([System.Xml.XmlNode]$paragraph) {
    $textNode = $paragraph.SelectSingleNode('.//w:t[1]', $ns)
    if (-not $textNode) {
        $run = Ensure-FirstRun $paragraph
        $textNode = $doc.CreateElement('w', 't', $ns.LookupNamespace('w'))
        $run.AppendChild($textNode) | Out-Null
    }
    return $textNode
}

function Apply-WhitespaceRule([System.Xml.XmlElement]$textNode, [string]$text) {
    $spaceAttr = $textNode.GetAttributeNode('space', 'http://www.w3.org/XML/1998/namespace')
    $needsPreserve = $text -match '^\s|\s$|\s{2,}'
    if ($needsPreserve) {
        if (-not $spaceAttr) {
            $spaceAttr = $doc.CreateAttribute('xml', 'space', 'http://www.w3.org/XML/1998/namespace')
            $textNode.Attributes.Append($spaceAttr) | Out-Null
        }
        $spaceAttr.Value = 'preserve'
    }
    elseif ($spaceAttr) {
        $textNode.Attributes.Remove($spaceAttr) | Out-Null
    }
}

function Set-FirstText([string]$paraId, [string]$text) {
    $paragraph = Get-Paragraph $paraId
    $textNode = Ensure-FirstTextNode $paragraph
    $textNode.InnerText = $text
    Apply-WhitespaceRule $textNode $text
}

function Replace-ParagraphContent([string]$paraId, [string]$text) {
    $paragraph = Get-Paragraph $paraId
    $paragraphProperties = $paragraph.SelectSingleNode('w:pPr', $ns)
    $templateRun = $paragraph.SelectSingleNode('w:r[1]', $ns)
    $templateRunProperties = $null
    if ($templateRun) {
        $templateRunProperties = $templateRun.SelectSingleNode('w:rPr', $ns)
    }

    while ($paragraph.HasChildNodes) {
        $paragraph.RemoveChild($paragraph.FirstChild) | Out-Null
    }

    if ($paragraphProperties) {
        $paragraph.AppendChild($paragraphProperties) | Out-Null
    }

    $newRun = $doc.CreateElement('w', 'r', $ns.LookupNamespace('w'))
    if ($templateRunProperties) {
        $newRun.AppendChild($templateRunProperties.CloneNode($true)) | Out-Null
    }

    $newText = $doc.CreateElement('w', 't', $ns.LookupNamespace('w'))
    $newText.InnerText = $text
    Apply-WhitespaceRule $newText $text
    $newRun.AppendChild($newText) | Out-Null
    $paragraph.AppendChild($newRun) | Out-Null
}

$simpleParagraphs = @{
    '00000001' = 'Department of {{DEPARTMENT}}'
    '00000003' = 'WEEKLY PROGRESS REPORT No. {{WEEK_NUMBER}}'
    '0000001A' = 'Work  Schedule           :       {{WORK_SCHEDULE}}     '
    '00000006' = '{{INTERN_NAME}}'
    '00000009' = '{{FROM_DATE}}'
    '0000000B' = '{{COMPANY}}'
    '0000000E' = '{{TO_DATE}}'
    '00000010' = '{{DEPT_DEPLOYED}}'
    '00000013' = '{{HOURS_THIS_WEEK}}'
    '00000015' = '{{SUPERVISOR_NAME}}'
    '00000085' = '{{INTERN_NAME}}'
    '0000008B' = 'Date: {{PREPARED_DATE}}'
    '0000008D' = 'Date: {{SUPERVISOR_DATE}}'
}

foreach ($entry in $simpleParagraphs.GetEnumerator()) {
    Set-FirstText -paraId $entry.Key -text $entry.Value
}

Replace-ParagraphContent -paraId '00000018' -text '{{TOTAL_HOURS}} out of {{REQUIRED_HOURS}}'

$dayMappings = @(
    @{ Date = '00000026'; TimeIn = '00000027'; TimeOut = '00000028'; Hours = '00000029'; Tasks = @(
        @{ Desc = '0000002A'; Hrs = '0000002B'; Status = '0000002C'; Index = 1 },
        @{ Desc = '0000002E'; Hrs = '0000002F'; Status = '00000030'; Index = 2 },
        @{ Desc = '00000032'; Hrs = '00000033'; Status = '00000034'; Index = 3 }
    ); Day = 1 },
    @{ Date = '00000039'; TimeIn = '0000003A'; TimeOut = '0000003B'; Hours = '0000003C'; Tasks = @(
        @{ Desc = '0000003D'; Hrs = '0000003E'; Status = '0000003F'; Index = 1 },
        @{ Desc = '00000041'; Hrs = '00000042'; Status = '00000043'; Index = 2 },
        @{ Desc = '00000045'; Hrs = '00000046'; Status = '00000047'; Index = 3 }
    ); Day = 2 },
    @{ Date = '0000004C'; TimeIn = '0000004D'; TimeOut = '0000004E'; Hours = '0000004F'; Tasks = @(
        @{ Desc = '00000050'; Hrs = '00000051'; Status = '00000052'; Index = 1 },
        @{ Desc = '00000054'; Hrs = '00000055'; Status = '00000056'; Index = 2 },
        @{ Desc = '00000058'; Hrs = '00000059'; Status = '0000005A'; Index = 3 }
    ); Day = 3 },
    @{ Date = '0000005F'; TimeIn = '00000060'; TimeOut = '00000061'; Hours = '00000062'; Tasks = @(
        @{ Desc = '00000063'; Hrs = '00000064'; Status = '00000065'; Index = 1 },
        @{ Desc = '00000067'; Hrs = '00000068'; Status = '00000069'; Index = 2 },
        @{ Desc = '0000006B'; Hrs = '0000006C'; Status = '0000006D'; Index = 3 }
    ); Day = 4 },
    @{ Date = '0000006E'; TimeIn = '0000006F'; TimeOut = '00000070'; Hours = '00000071'; Tasks = @(
        @{ Desc = '00000072'; Hrs = '00000073'; Status = '00000074'; Index = 1 },
        @{ Desc = '00000076'; Hrs = '00000077'; Status = '00000078'; Index = 2 },
        @{ Desc = '0000007A'; Hrs = '0000007B'; Status = '0000007C'; Index = 3 }
    ); Day = 5 }
)

foreach ($dayMapping in $dayMappings) {
    $day = $dayMapping.Day
    Set-FirstText -paraId $dayMapping.Date -text "Date: {{D${day}_DATE}}"
    Set-FirstText -paraId $dayMapping.TimeIn -text "Time In: {{D${day}_TIME_IN}}"
    Set-FirstText -paraId $dayMapping.TimeOut -text "Time Out: {{D${day}_TIME_OUT}}"
    Set-FirstText -paraId $dayMapping.Hours -text "Hours Worked: {{D${day}_HOURS}}"

    foreach ($task in $dayMapping.Tasks) {
        $taskIndex = $task.Index
        Set-FirstText -paraId $task.Desc -text "${taskIndex}. {{D${day}_T${taskIndex}_DESC}}"
        Set-FirstText -paraId $task.Hrs -text "{{D${day}_T${taskIndex}_HRS}}"
        Set-FirstText -paraId $task.Status -text "{{D${day}_T${taskIndex}_STATUS}}"
    }
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$settings = New-Object System.Xml.XmlWriterSettings
$settings.Encoding = $utf8NoBom
$settings.Indent = $false
$settings.NewLineHandling = [System.Xml.NewLineHandling]::None

$writer = [System.Xml.XmlWriter]::Create($documentXmlPath, $settings)
try {
    $doc.Save($writer)
}
finally {
    $writer.Dispose()
}

if (Test-Path $outputDocx) {
    Remove-Item -LiteralPath $outputDocx -Force
}

$pythonPacker = @"
import pathlib
import zipfile

source = pathlib.Path(r'$templateDir')
target = pathlib.Path(r'$outputDocx')

with zipfile.ZipFile(target, 'w', compression=zipfile.ZIP_DEFLATED) as archive:
    for path in sorted(source.rglob('*')):
        if path.is_file():
            archive.write(path, path.relative_to(source).as_posix())
"@

$pythonPacker | python -

$base64 = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($outputDocx))
$wrappedBase64 = ($base64 -split '(.{120})' | Where-Object { $_ }) -join [Environment]::NewLine
[System.IO.File]::WriteAllText($outputBase64, $wrappedBase64, [System.Text.Encoding]::ASCII)

Write-Output "template.docx written to $outputDocx"
Write-Output "base64 written to $outputBase64"
