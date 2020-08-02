<#
Script de automacao para associação de usuarios AD com as portas dos switches HP 2530. Com esse script é possível saber qual são os mac-address cadastrados para determinado hostname, também é possível saber em qual switch e qual porta está determinado mac-address.
Autor: Dimitri Dittrich
Data: 01/12/2017
#>


<#
(Get-ADComputer -Identity ASL0025 -Properties extensionattribute1).extensionattribute1
Get-ADComputer -Filter {extensionattribute1 -like "*A4:1F:72:FE:57:09*"}
show mac-address 1-22
$teste -split "Status and Counters - Port Address Table - " -split "MAC Address   VLANs       
  ------------- ------------"



Get-CimInstance -computerName nead0437 -ClassName win32_operatingsystem | select csname, lastbootuptime | % { $CompName = "*$($_.csname)*"; Get-ADUser -Properties displayname -Filter {Office -like $CompName} | select Displayname } | Out-File c:\temp\AD.txt 

080027 - VIRTUALBOX


#>


#------------AUTOMATIC-PATH-------------"
$completo = $MyInvocation.MyCommand.Path
$scriptname = $MyInvocation.MyCommand.Name
$caminho = $completo -replace $scriptname, ""
#---------------------------------------"
cls

#----------------MENU------------------"
Write-Host "Digite 1, 2 ou 3 conforme opções abaixo"
Write-Host "1 - Procurar mac-address através do HOSTNAME"
Write-Host "2 - Procurar switch, porta do switch, usuário e hostname através do MAC-ADDRESS"
Write-Host "3 - SAIR"
$option = Read-Host






while ($option -eq "1")
{
cls
$hostname = Read-Host "Digite o hostname que você de seja saber o mac-address seguindo o padrão UNIDADE-1234"
$result_mac = ''
$result_mac = ((Get-ADComputer -Identity $hostname -Properties extensionattribute1).extensionattribute1)
    if ($result_mac -ne '')
    {
    Write-Host "Anote ou copie o mac-address do endereço físico exibido abaixo para posterior consulta:"
    write-host "-----------------------------------------------------------------------------------------"
    Write-Host "$result_mac"
    write-host "-----------------------------------------------------------------------------------------"
    }
        else{
            cls
            write-host "----------------------------------------------------------"
            Write-Host "!!!!!-----Hostname ou mac-address não encontrado-----!!!!!"
            write-host "----------------------------------------------------------"
            }
#----------------MENU------------------"
Write-Host "Digite 1, 2 ou 3 conforme opções abaixo"
Write-Host "1 - Procurar mac-address através do HOSTNAME"
Write-Host "2 - Procurar switch, porta do switch, usuário e hostname através do MAC-ADDRESS"
Write-Host "3 - SAIR"
$option = Read-Host
#---------------------------------------"
cls

}
    if ($option -eq "2")
    {
    
    
    

#---------------------------------------"
	
	




Write-Host "`n"
Write-Host "`n"
#----------MODULOS-CAMINHOS-VARIAVEIS-----------"
$cont = 0
$final_verification = "y"

#PRE-REQUISITOS E VALORES A SEREM ALTERADOS CONFORME NECESSIDADE
#Necessario ter instalado o modulo posh-ssh
#Alterar horario de versao na funcion timesync conforme necessidade
$csvfile = "$caminho.\ips-switches.csv"
[string]$arqpassencrypted ="$caminho.\pass.xml"
$pathlog = "$caminho.\log.txt"
$macaprocurar = Read-Host 'Digite o MAC que deseja procurar seguindo o padrao "123456-abcdef" com todas as letras minusculas'
$hostname = ''
$user = ''
#$retornofinal = ''

Import-Module -name posh-ssh
Remove-Module "function01-hp2530"
Import-Module function01-hp2530.psm1
#Import-Module "$caminho.\functions\function01-hp2530.psm1"
#Remove-Module "function02-synctime"
#Import-Module "$caminho.\functions\function02-synctime.psm1"
	
	
cls
#----------------------------------------------"
$macaprocurar_temp = $macaprocurar
$macsequencial = ($macaprocurar_temp.Split("-") -join '')
$maccomdoispontos = ((($macsequencial -split '(..)') |?{$_}) -join ":")
$macacomasterisco = ("*" +$maccomdoispontos+ "*")
$hostname = (Get-ADComputer -Filter {extensionattribute1 -like $macacomasterisco}).Name
$user = (Get-CimInstance -computerName $hostname -ClassName win32_operatingsystem | select csname, lastbootuptime | % { $CompName = "*$($_.csname)*"; Get-ADUser -Properties displayname -Filter {Office -like $CompName} | select Displayname })
$user = $user.Displayname
$user = $user -join ' e '
#Write-Host "O mac-address $maccomdoispontos pertence ao computador $hostname, usuário(s) $user"
#[string]$log = $date.ToString() + " - O mac-address " + $maccomdoispontos + " pertence ao computador " + $hostname + ", usuário(s) " + $user
#Add-Content -Path $pathlog -Value $log





Write-Host "`n"
Write-Host "`n"
Write-Host "#########----------CREDENCIAIS-SSH-----------#########"
$encpwd = Get-Credential | Export-Clixml -Path "$caminho.\pass.xml"
Write-Host "#########------------------------------------#########"

Write-Host "`n"
Write-Host "`n"
Write-Host "#########----------PING-SW-----------#########"
$ColumnHeader = "IPaddress"
Write-Host "Reading file" $csvfile
$ipaddresses = import-csv $csvfile | select-object $ColumnHeader

foreach($ip in $ipaddresses) {
$cont = 0
$ipaddress = $ip.("IPAddress")
    Write-Host "Teste de ping no switch de ip $ipaddress da lista CSV"
    while ($cont -le 2) {

    if (test-connection $ip.("IPAddress") -count 1 -quiet) {
        write-host $ip.("IPAddress") "Ping succeeded." -foreground green
        #variavel ipaddress recebe o ip que esta na vez do csv
        $cont = 4

Remove-SSHSession -Index 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20
Write-Host "#########-----------------------------#########"

Write-Host "`n"
Write-Host "`n"
Write-Host "--------CONEXAO-SSH---------"
$cred = Import-Clixml -Path $arqpassencrypted

Write-Host ">>>>>Cria sessao<<<<<"
$retorno_ssh = New-SSHSession -ComputerName $ipaddress -AcceptKey -Credential $cred -Verbose           

            Write-Host ">>>>>VALIDA-CONEXAO<<<<<"
            
            if ($retorno_ssh.Connected)
            {
            $date = get-date
            Write-Host "CONEXÃO SSH no Switch de IP $ipaddress REALIZADA COM SUCESSO!"
            [string]$log = $date.ToString() + " - CONEXAO SSH no Switch de IP " + $ipaddress.ToString() + " REALIZADA COM SUCESSO!"
            Add-Content -Path $pathlog -Value $log
            }
                else
                {
                $date = get-date
                Write-Host "CONEXÃO SSH no Switch de IP $ipaddress NÃO DEU CERTO!"
                [string]$log = "#####PROBLEM#####"+$date.ToString() +" - CONEXÃO SSH no Switch de IP "+ $ipaddress.ToString() + " NÃO DEU CERTO!"
                Add-Content -Path $pathlog -Value $log
                Start-Sleep -Seconds 5
                cls
                break
                }
$session = Get-SSHSession -Index 0
Write-Host "-----------------------------"

Write-Host "`n"
Write-Host "`n"
Write-Host "--------CRIANDO-SHELL-STREAM---------"
$stream = $session.Session.CreateShellStream("Dimi", 1000, 1000, 1000, 1000, 1000)
$streamoutput = $stream.Read()
Clear-Variable streamoutput -Verbose
Start-Sleep -Seconds 1 -Verbose
$stream
Write-Host "-----------------------------"
				
				Write-Host "`n"
				Write-Host "`n"
				Write-Host "--------FUNCTION01-HP2530---------"
				Function function01-hp2530
				{
					Param ([string]$command)
					Process
					{
						$stream.Write("$command`n")
						Start-Sleep -Seconds 1
						$streamoutput = $stream.Read()
						Write-Host $streamoutput
						Clear-Variable streamoutput
					}
				}
				Write-Host "-----------------------------"
				Import-Module function01-hp2530.psm1
				
Write-Host "`n"
Write-Host "`n"
Write-Host "-----------ENTRADA------------"
$stream.Write("en`n")
Start-Sleep -Seconds 1
$streamoutput = $stream.Read()
Write-Host $streamoutput
Clear-Variable streamoutput
Write-Host "------------------------------"

Write-Host "`n"
Write-Host "`n"
Write-Host "--------RUNNING-CONFIG---------"
function01-hp2530 -command "show run"
Write-Host "-------------------------------"




Write-Host "`n"
Write-Host "`n"
Write-Host "---------SHOW-MACS----------"
$stream.Write("show mac-address 1-24`n")
Start-Sleep -Seconds 15
$streamoutput = $stream.Read()
Write-Host $streamoutput
Write-Host "-----------------------------"

#--------------------------------------------------------
$streamoutput > "$caminho.\macs-temp.txt"

#--------------------------------------------------------
Function Procurar($maca,$macaprocu, $po)
{
$encont = 0
$encontb = 0
$contador = 0
$ehup = $false
$saida = ""
            ($maca.split("{|}")) | %{
            $contador ++
                    if ($_.Contains($macaprocu))
                    {
                    $encont ++
                    $ehup = $false 
                    }
                            if ($encont -gt 0)
                            {
                            $saida = "MAC encontrado na porta $po"    
                            $encont = 0 
                            $encontb ++
                            }
                                    if ($contador -gt 2 -and $ehup -eq $false -and $encontb -gt 0)
                                    {
                                    $saida += ", ESSA PORTA É UM UPLINK"
                                    $ehup = $true
                                    $encontb = 0
                                    $contador = 0     
                                    }
						#Write-Host "esta dentro da functio procurar"
						#Write-Host "porta "$po
						#Write-Host "macaprocu " $macaprocu
						#pause
					}
echo $saida
#Esse if joga pro arquivo de log a porta, somente se nao for um uplink ($ehup -ne 'True) e o ($saida -ne '') é pra nao ficar gerando log sem ter terminado o ciclo
    if ($saida -ne '' -and $ehup -ne 'True')
    {
    $retornofinal = ''
    Write-Host "O mac-address $maccomdoispontos pertence ao computador $hostname, usuário(s) $user"
    [string]$log = $date.ToString() + " - O mac-address " + $maccomdoispontos + " pertence ao computador " + $hostname + ", usuário(s) " + $user
    Add-Content -Path $pathlog -Value $log

    Write-Host "$saida do switch de ip $ipaddress"
    [string]$log = $date.ToString() + " - " + $saida + ". Switch de IP "+ $ipaddress.ToString()
    Add-Content -Path $pathlog -Value $log
    exit
    }
        else #($saida -ne '')
        {
        $retornofinal = ''
        $retornofinal = "Este mac-address ($maccomdoispontos) não foi encontrado em nenhuma porta de nenhum dos switches do arquivo CSV. Talvez este usuário não esteja conectado com o computador ligado e conectado na rede neste momento ou este usuário utilize Máquinas Virtuais. O mac-address $maccomdoispontos pertence ao computador $hostname, usuário(s) $user"
        }

}


        




#--------------------------------------------------------
$porta = $null
$mac = $null
[string] $tempmac = $null
$count = 0
$temdados = $false
$streamoutput = Get-Content "$caminho.\macs-temp.txt"
#--------------------------------------------------------
($streamoutput -split "`n") | %{
    if ($count -gt 0)
    {
    $count ++
    }
        if ($_ -match "Status and Counters")
        {
        $count = 0
                if ($temdados)
                {
                #Exibe -port $porta -ma $mac
                Procurar -maca $mac -macaprocu $macaprocurar -po $porta
                $porta = ""
                $mac = ""
                $temdados = $false                
                }
        $porta = $_[44..45]  -join ''
        $mac = $null       
        }elseif ($_ -match "MAC Address")
         {
         $count ++
         }elseif ($count -gt 2)
          {        
          $tempmac = $_[1..14]
                if($tempmac.length -gt 0)
                {
                $mac += $_[1..14] -join '' 
                $mac += "|" -join ''           
                $temdados = $true
                }
          }
}
#--------------------------------------------------------
if ($porta -gt $null)
{
#Exibe -port $porta -ma $mac
Procurar -maca $mac -macaprocu $macaprocurar -po $porta
}


#--------------------------------------------------------






Write-Host "`n"
Write-Host "`n"
Write-Host "--------REMOVENDO SESSAO SSH---------"
Remove-SSHSession -Index 0 -Verbose
Write-Host "-------------------------------------"





} else {
         write-host $ip.("IPAddress") "Ping failed." -foreground red
         Write-Host "Tentando pingar novamente"
         $cont++
         Start-Sleep -Seconds 2
            if ($cont -gt 2)
            {
            [string]$log = "#####PROBLEM#####"+$date.ToString() +" - Switch de IP "+ $ipaddress.ToString() + " não respondeu ao ping, e por isso não pode ser verificado"
            Add-Content -Path $pathlog -Value $log
            }
       }
    
    }
        
    }
        if ($retornofinal -ne '')
        {
        Write-Host "$retornofinal"
        [string]$log = $date.ToString() + " - Este mac-address (" + $maccomdoispontos + ") não foi encontrado em nenhuma porta de nenhum dos switches do arquivo CSV. Talvez este usuário não esteja conectado com o computador ligado e conectado na rede neste momento ou este usuário utilize Máquinas Virtuais. O mac-address " + $maccomdoispontos + " pertence ao computador " + $hostname + ", usuário(s) " + $user
        Add-Content -Path $pathlog -Value $log
        }




    }#final do if da opcao 2
    
# SIG # Begin signature block
# MIIEOgYJKoZIhvcNAQcCoIIEKzCCBCcCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUAgrn+SEQGheIgST6SR67zlp+
# WwGgggJEMIICQDCCAa2gAwIBAgIQVB3qufqZrZpKhWR9rnNo7zAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0xNzA3MTQxMjEyMTdaFw0zOTEyMzEyMzU5NTlaMCExHzAdBgNVBAMTFkRpbWl0
# cmkgUG93ZXJTaGVsbCBDU0MwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBALXt
# 21SuIH+ODd1F82+fp45oUFGw2R+NzvdfKyao44xABoxtqkv2uquqRbo1Fi+jsd80
# HzcHO3BOPUZJsFtuADZhQZmhV3oMjWoSaGmWgOaERkYb01AJo311LNMd9duwQjqz
# XY6VtOj4SnqwB9xY6VmUVvpsNdIPBsD9pziX3sdFAgMBAAGjdjB0MBMGA1UdJQQM
# MAoGCCsGAQUFBwMDMF0GA1UdAQRWMFSAEGPPo05+xF03EpNY4Co5jEqhLjAsMSow
# KAYDVQQDEyFQb3dlclNoZWxsIExvY2FsIENlcnRpZmljYXRlIFJvb3SCEHt8lZC+
# seeASfvlb8W6Jc4wCQYFKw4DAh0FAAOBgQApVBuK8PfCTBdPMTgv+o/sq0rVCc9Z
# ozaUkfUW91B8APzCL52cHmLN8GQsnm7Up2l0iD9ul3EqaAPrLaoxoeYdCrea5Boi
# TA+zYaS4Cp2oDL/SWtQH4TNpEbQEl+4a5Rn7iq8RqsB1m7EsG80Q1aDrzVyeLhYK
# 8IT6eqWnoiqR6TGCAWAwggFcAgEBMEAwLDEqMCgGA1UEAxMhUG93ZXJTaGVsbCBM
# b2NhbCBDZXJ0aWZpY2F0ZSBSb290AhBUHeq5+pmtmkqFZH2uc2jvMAkGBSsOAwIa
# BQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgor
# BgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3
# DQEJBDEWBBTMmFTDgYvyh3TnlbZbFKYkCrZaEjANBgkqhkiG9w0BAQEFAASBgFWw
# AIghccMrrzlDY7tCLwLmQrHgef+4ebF8t5qqfMMQCArGmQ+VLCpm+tMQW5C/nvg6
# bAymNYSt9OKwg2ivc1HLL9ySqU68nsofH3N98HSqmvxk/8Tir8yUyxAvLhF1F0uU
# miSCvJOsoC6QOXflTegKxh5GOlYh9V/YOe1itxCV
# SIG # End signature block
