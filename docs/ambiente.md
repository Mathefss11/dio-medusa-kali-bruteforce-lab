# Ambiente de laboratório — checklist

## Host e ferramentas

| Item | Valor |
|---|---|
| Hipervisor | VirtualBox — versão: PENDENTE |
| Kali Linux | Versão: PENDENTE |
| Medusa | Versão (`medusa -h`): PENDENTE |
| Metasploitable 2 | Versão/imagem utilizada: PENDENTE |
| DVWA | Instalado? PENDENTE |
| Segmento host-only | Exemplo: `192.168.56.0/24`; real: PENDENTE |
| IP do Kali | Exemplo: `192.168.56.10`; real: PENDENTE |
| IP do Metasploitable | Exemplo: `192.168.56.20`; real: PENDENTE |

## Checklist de isolamento

- [ ] Duas VMs instaladas e ligadas
- [ ] Snapshots criados antes do experimento
- [ ] Rede host-only habilitada
- [ ] Metasploitable sem rede bridge e sem port forwarding externo
- [ ] Metasploitable sem conexão à internet
- [ ] IPs verificados com `ip -br addr`
- [ ] Ping verificado
- [ ] Nmap executado só no alvo do laboratório
- [ ] Prints sanitizados antes de publicação

## Comandos de coleta não destrutivos

```bash
ip -br addr
ip route
medusa -d
sudo nmap -sV -p 21,80,139,445 192.168.56.20
```

Substitua o IP de exemplo pelo IP confirmado na VM vulnerável.
