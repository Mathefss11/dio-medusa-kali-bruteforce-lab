# Laboratório de Auditoria de Autenticação com Kali Linux e Medusa

![Kali Linux](https://img.shields.io/badge/Kali-Linux-557C94?logo=kalilinux&logoColor=white) ![Security](https://img.shields.io/badge/Cybersecurity-Ethical%20Hacking-2ea44f) ![Status](https://img.shields.io/badge/Status-Laborat%C3%B3rio%20a%20validar-orange) ![DIO](https://img.shields.io/badge/Desafio-DIO-blue)

> **Status:** projeto documentado e preparado para execução. Os resultados e capturas reais ainda precisam ser coletados nas máquinas virtuais. Nenhum acesso bem-sucedido foi presumido.

## 1. Sobre o projeto

Projeto educacional para explorar **autenticação fraca**, **ataques de dicionário**, **força bruta**, **password spraying** e medidas de mitigação em uma rede virtual isolada, utilizando **Kali Linux**, **Medusa**, **Metasploitable 2** e, opcionalmente, **DVWA**.

**Objetivos:** (1) configurar um laboratório isolado; (2) identificar os serviços FTP, SMB e HTTP; (3) demonstrar tentativas controladas de autenticação; (4) registrar evidências verificáveis; (5) recomendar controles preventivos e detectivos.

**Ética e escopo:** execute apenas nas VMs de sua propriedade ou em sistemas com autorização explícita. Nunca exponha o Metasploitable/DVWA à internet, nem reutilize listas de credenciais de terceiros. Não execute estes comandos contra serviços públicos ou redes de produção.

## 2. Arquitetura do laboratório

```text
                  Rede host-only / laboratório isolado
                        192.168.56.0/24
             +-----------------------------------+
             |                                   |
    +------------------+             +------------------------+
    | Kali Linux       |             | Metasploitable 2       |
    | 192.168.56.10    | ----------> | 192.168.56.20          |
    | Medusa, Nmap     |    testes   | FTP, SMB, HTTP         |
    +------------------+             +------------------------+
```

**IP ilustrativo:** ajuste os comandos aos endereços realmente atribuídos às suas VMs. Recomenda-se um adaptador **host-only** em cada VM e nenhum adaptador em bridge. Se o Kali precisar instalar pacotes, conecte um NAT temporário somente nele e desconecte antes dos testes. O Metasploitable deve permanecer isolado.

### Requisitos

- VirtualBox, Kali Linux (VM) e Metasploitable 2 (VM).
- Medusa, Nmap e clientes FTP/SMB instalados no Kali.
- 2–4 GB RAM disponíveis para Kali; 512 MB–1 GB para Metasploitable 2 (conforme recursos do host).
- Snapshots das VMs antes de iniciar.

### Verificando a rede

```bash
ip -br addr
ip route
ping -c 3 192.168.56.20
sudo nmap -sV -p 21,80,139,445 192.168.56.20
```

Em uma instalação típica do Metasploitable 2, esses serviços podem estar disponíveis, mas **confirme com o Nmap** antes dos testes. Documente a saída em `docs/resultados.md`.

## 3. Preparação

```bash
sudo apt update
sudo apt install -y medusa nmap smbclient curl
medusa -h
medusa -d
```

As listas **intencionalmente pequenas** ficam em `wordlists/`. São credenciais fictícias/de laboratório para reduzir o volume de tentativas. O login padrão `msfadmin` é conhecido no Metasploitable 2 e deve ser usado **somente dentro da VM vulnerável**.

## 4. Cenário 1 — Auditoria FTP com Medusa

**Hipótese:** contas com senhas previsíveis permitem autenticação por tentativa automatizada.

1. Confirme que a porta 21 está aberta no Metasploitable.
2. Execute a tentativa limitada a uma conta e uma lista pequena de senhas:

```bash
medusa -h 192.168.56.20 -u msfadmin -P wordlists/ftp-passwords.txt -M ftp -t 1 -f -v 4
```

**Parâmetros:** `-h` é o host; `-u` define um usuário; `-P` fornece a lista de senhas; `-M ftp` seleciona o módulo FTP; `-t 1` limita a uma tarefa paralela; `-f` interrompe após a primeira senha válida; `-v 4` fornece informações de execução.

Se houver um acesso autorizado, valide manualmente **apenas dentro do laboratório**:

```bash
ftp 192.168.56.20
# Informe o usuário e a senha de laboratório no prompt interativo.
# Encerre com: bye
```

**Registre:** serviço/versão, total aproximado de tentativas, duração, resposta do serviço, resultado e captura. **Não inclua senhas reais em prints ou logs públicos.**

## 5. Cenário 2 — Formulário Web (DVWA)

A automação de autenticação Web depende de parâmetros do formulário, cookies de sessão, tokens CSRF e controles configurados. Por isso, a técnica não é simplesmente trocar o módulo do Medusa: **primeiro inspecione o comportamento do DVWA**.

1. Instale e acesse uma instância **local e isolada** do DVWA; não publique a instância online.
2. Configure o nível de segurança para `Low` **exclusivamente no laboratório**.
3. Abra a ferramenta de desenvolvedor do navegador e observe o método, URL, campos, cookies e redirecionamentos de uma tentativa manual.
4. Registre o comportamento em `docs/resultados.md` e analise se há limitação de tentativas.
5. Como exercício opcional, compare respostas para 3 entradas de teste usando o navegador, com anotações e capturas (sem automatizar uma campanha massiva).

**Perguntas técnicas para responder:** existe token CSRF? A resposta de falha é distinguível da de sucesso? Há bloqueio, atraso progressivo, MFA ou CAPTCHA? A sessão muda após login?

## 6. Cenário 3 — Password spraying em SMB

**Password spraying** testa **uma senha** em várias contas, em vez de muitas senhas numa única conta. Em ambientes reais, isso pode levar a bloqueios e alertas, por isso aqui restringimos o exercício a **até três usuários locais de teste**.

### Enumeração de serviço e contas de laboratório

```bash
sudo nmap -sV -p 139,445 192.168.56.20
smbclient -L //192.168.56.20 -U msfadmin
```

Para a enumeração de nomes de usuário, utilize apenas os nomes das contas do laboratório listados em `wordlists/smb-users.txt` (uma lista fornecida pelo operador, **não** coletada de terceiros). Confirme manualmente a existência das contas pela configuração da VM, quando possível.

### Um ciclo controlado com Medusa

```bash
medusa -h 192.168.56.20 -U wordlists/smb-users.txt -p msfadmin -M smbnt -t 1 -v 4
```

O módulo `smbnt` e o protocolo negociado podem exigir ajustes conforme a versão da ferramenta/servidor. Verifique `medusa -d` e a ajuda do módulo. **Não interprete mensagens de incompatibilidade de SMB como prova de que nenhuma senha é válida.** Não repita ciclos indiscriminadamente.

Se o módulo não funcionar, documente a incompatibilidade, a versão do Samba e o que você aprendeu. O objetivo não é forçar um resultado positivo.

## 7. Evidências e documentação

Use `docs/resultados.md` para substituir cada campo `PENDENTE` pelos resultados **reais**. Salve imagens com nomes neutros, por exemplo:

```text
images/
  01-topologia-virtualbox.png
  02-conectividade-kali-metasploitable.png
  03-nmap-servicos.png
  04-medusa-ftp.png
  05-dvwa-formulario.png
  06-medusa-smb.png
```

Antes de publicar, revise prints para remover nomes pessoais, endereços externos, cookies, tokens e segredos.

## 8. Riscos e medidas de mitigação

| Risco | Como se manifesta | Controles sugeridos |
|---|---|---|
| Senhas fracas ou padrão | Login obtido por tentativa de senha previsível | Senhas únicas e fortes; eliminar credenciais padrão; gerenciador de senhas |
| Tentativas repetidas | Muitas falhas de login no mesmo serviço | Limites por conta/IP, atrasos progressivos, rate limiting e monitoramento |
| Password spraying | Uma senha comum tentada em múltiplas contas | MFA, detecção por padrão distribuído, listas de senhas proibidas e alertas |
| FTP sem criptografia | Credenciais podem trafegar em texto claro | Desativar FTP legado; usar SFTP ou FTPS com configuração segura |
| SMB legado/exposto | Serviço visível e protocolos antigos | Restringir acesso por firewall; desabilitar SMBv1; atualizar Samba/Windows |
| Aplicação Web vulnerável | Fluxos frágeis e falhas de autenticação | Controles server-side, sessões seguras, proteção CSRF e autenticação robusta |

A resposta defensiva deve equilibrar segurança e disponibilidade: bloqueios rígidos demais podem permitir negação de serviço contra usuários legítimos. Prefira controles em camadas, correlação de eventos e autenticação multifator.

## 9. Conclusão e aprendizados

O exercício ilustra como serviços distintos expõem superfícies de autenticação semelhantes, mas com particularidades importantes: FTP usa um protocolo próprio; SMB depende de versões e negociação; formulários Web podem incluir cookies, estados de sessão e tokens. A mitigação não depende apenas de senhas fortes, mas também de configuração, segmentação, telemetria, limitação de tentativas e políticas de acesso.

**Nota de integridade:** este repositório é um guia de implementação; a seção de resultados precisa ser concluída após a execução prática. Não declare resultados não observados.

## 10. Estrutura do repositório

```text
.
├── README.md
├── docs/
│   ├── ambiente.md
│   └── resultados.md
├── images/
│   └── README.md
├── scripts/
│   └── verificar-lab.sh
└── wordlists/
    ├── ftp-passwords.txt
    └── smb-users.txt
```

## 11. Referências

- [Kali Linux](https://www.kali.org/)
- [Medusa](https://www.foofus.net/jmk/medusa/medusa.html)
- [DVWA](https://github.com/digininja/DVWA)
- [Metasploitable 2 (Rapid7)](https://docs.rapid7.com/metasploit/metasploitable-2/)
- [Nmap Reference Guide](https://nmap.org/book/man.html)
- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)

---

Desenvolvido como atividade educacional de segurança ofensiva e defensiva para a **DIO**.
