#!/usr/bin/env bash
set -euo pipefail
TARGET="${1:-}"
if [[ ! "$TARGET" =~ ^192\.168\.56\.[0-9]{1,3}$ ]]; then
  echo 'Uso: ./scripts/verificar-lab.sh 192.168.56.20'
  echo 'Por segurança, este script somente aceita destinos 192.168.56.x da rede de exemplo.'
  exit 2
fi
for cmd in ip ping nmap medusa; do
  if ! command -v "$cmd" >/dev/null 2>&1; then echo "Ferramenta ausente: $cmd"; exit 1; fi
done
printf '\n[1/4] Interfaces do Kali\n'; ip -br addr
printf '\n[2/4] Rotas\n'; ip route
printf '\n[3/4] Ping para o alvo isolado\n'; ping -c 2 -W 2 "$TARGET" || true
printf '\n[4/4] Identificação dos serviços do laboratório\n'; nmap -sV -p 21,80,139,445 "$TARGET"
printf '\nColeta inicial concluída. Registre os resultados em docs/resultados.md.\n'
