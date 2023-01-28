# This variables contains path to folders
$search_folder = "input\"  # Here we are looking for .xml files
$output_folder = "output\" # This folder is for "ok" .xml
$error_folder = "error\"   # This folder is for "bad" .xml
# Folder that stores log files
$log_folder = "log\"

# Node to test, mabye you will need more than 1
$node_list = @("MainData/subData")

function MoveFile($file,$move_to)
{
    Move-Item -Path $file -Destination $move_to
}

function Write-Log
{
    param([String]$xml_filename, [String]$status)
    $output_filename = $log_folder+"xml_"+(Get-Date -Format "dd_MM_yyyy")+".csv"
    if((Test-Path $output_filename) -eq $false)
    {
        New-Item -path ($output_filename) -type file
        Add-Content -Path ($output_filename) -Value "Filename;Status;Time"
    }
    Add-Content -Path ($output_filename) -Value ("$xml_filename"+";"+"$status"+";"+(Get-Date -Format "HH:mm"))
}

function Check-XMLFile($xml_file)
{
    ForEach($node in $node_list)
    {
        $NodeExists = $xml_file.SelectSingleNode($node)
        if ($NodeExists -eq $null){return $false}
    }
    return $true
}

function Get-XMLFile($xml_filename) 
{
    if(Test-Path $xml_filename)
    {
        try
        {
            [xml]$doc = Get-Content $xml_filename
            if(Check-XMLFile($doc) -eq $true)
            {
                return $true,"ok"
            }
            else{return $false,"xml_lines_error"}
        }
        catch{return $false,"xml_file_error"}
    }
    else{return $false,"file_error"}
}

function main
{
    $file_list = Get-ChildItem -File $search_folder
    ForEach($file in $file_list)
    {
        $returned,$data = Get-XMLFile($file.FullName)
        if($returned -eq $true){Move-Item -Path $file.FullName -Destination $output_folder}
        else{Move-Item -Path $file.FullName -Destination $error_folder}
        Write-Log $file.FullName $data
    }
}

main