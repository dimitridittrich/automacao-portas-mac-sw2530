# Projeto Automação de associação entre o mac-address dos clientes com as portas dos switches HP2530 e os usuários do Active Directory.

Projeto criado para manter os scripts de forma distribuida, versionada e economizar tempo de operação.
Com este script é possível saber em qual Switch e em qual porta está conectado determinado mac-address. Caso você não saiba o mac-address que quer procurar, o script também dá a opção de buscar o mac-address pelo hostname.

## Pré-requisitos e observações para utilização deste projeto :exclamation:

Para pleno funcionamento deste projeto, você precisará:
- TER INSTALADO O MÓDULO POSH-SSH NO SEU POWERSHELL;
- TER INSTALADO O RSAT E HABILITADO MÓDULO ACTIVE DIRECTORY NO SEU POWERSHELL;
- TER A LISTA DE IPS DOS SWITCHES QUE DESEJA PESQUISAR;
- PARA MÁQUINAS QUE POSSUEM VMs INSTALADAS (COMO POR EXEMPLO AS DA EQUIPE DE DESENVOLVEDORES) O SCRIPT NÃO IRÁ FUNCIONAR, POIS ELE CONSIDERA QUALQUER PORTA COM MAIS DE 1 MAC-ADDRESS COMO UPLINK/DOWNLINK. NESTE CASO, É NECESSÁRIO ACOMPANHAR OS RETORNOS NO SHELL MANUALMENTE.

## Como Utilizar este projeto

**Na pasta "Scripts" há o Script principal:**<br />
1 - "1-portas-hp2530.ps1"
Este script faz todo o processo de conexão e pesquisa nos Switches e a interação com o Active Directory.<br />
[Para acessar esse script clique aqui](/scripts/1-portas-hp2530.ps1)

**Na pasta "Scripts\functions\" há uma function que é utilizada pelo script principal:**<br />
1 - "function01-hp2530.psm1"<br />
Esta function é utilizada pelo script principal para invoke de comandos nos switches HP2530<br />
[Para acessar essa function clique aqui](scripts/functions/function01-hp2530.psm1)

**Na pasta "Scripts" existe um arquivo CSV que contém a lista de IPs dos switches a serem atualizados. Altere essa lista conforme sua necessidade:**<br />
1 - "ips-switches.csv"<br />
[Para acessar esse arquivo com a lista de IPs clique aqui](scripts/ips-switches.csv)

**Na pasta "Scripts" existe um arquivo txt onde são guardados todos os LOGs que os scripts geram:**<br />
1 - "log.txt"<br />
[Para acessar esse arquivo de log clique aqui](scripts/log.txt)

**Na pasta "Scripts" há um arquivo referente à criptografia das credenciais para acesso SSH:**<br />
1 - "pass.xml"<br />
Este .xml é o arquivo gerado pelo script principal, com base nas credenciais digitadas pelo usuário. Nele contem um hash criptografado da senha digitada para conexão SSH nos switches.<br />
[Para acessar esse arquivo .xml clique aqui](scripts/pass.xml)