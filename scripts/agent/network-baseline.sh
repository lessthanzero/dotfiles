#!/usr/bin/env bash
# Read-only network baseline from Mac. Offer memorise for ops/networking.md
set -euo pipefail

GATEWAY="${GATEWAY:-192.168.1.254}"
MAC_IP="${MAC_IP:-192.168.1.177}"

echo "==> Network baseline (read-only)"
echo "Gateway: $GATEWAY"
echo "This host: $MAC_IP"
echo ""

echo "==> Gateway ping"
# macOS: -t is whole-run timeout (seconds); bare ping can spin forever if ICMP stalls.
ping -c 3 -t 5 "$GATEWAY" 2>/dev/null || echo "WARN: gateway unreachable"

echo ""
echo "==> DNS via router"
dig @"$GATEWAY" google.com +time=2 +tries=1 2>/dev/null | tail -5 || echo "WARN: router DNS query failed"

echo ""
echo "==> Key hosts"
for ip in 192.168.1.172 192.168.1.165 192.168.1.174; do
  if ping -c 1 -t 2 "$ip" &>/dev/null; then
    echo "OK: $ip up"
  else
    echo "DOWN: $ip"
  fi
done

echo ""
echo "Done. To persist results, use memorise-vault -> ops/networking.md"
