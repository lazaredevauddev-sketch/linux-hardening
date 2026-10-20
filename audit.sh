#!/usr/bin/env bash
# Petit audit de durcissement pour une machine Linux (type checks CIS alleges).
# Lecture seule : le script ne modifie rien, il signale juste.
# A lancer sur sa propre VM. Certaines verifs demandent root pour tout voir.

pass=0
fail=0

ok()   { echo "[OK]   $1"; pass=$((pass+1)); }
ko()   { echo "[WARN] $1"; fail=$((fail+1)); }

echo "=== audit durcissement $(hostname) ==="
echo

# 1. login root direct en ssh
if grep -Eqs '^\s*PermitRootLogin\s+no' /etc/ssh/sshd_config; then
    ok "ssh: login root desactive"
else
    ko "ssh: PermitRootLogin n'est pas sur 'no'"
fi

# 2. auth par mot de passe en ssh (mieux: cle seulement)
if grep -Eqs '^\s*PasswordAuthentication\s+no' /etc/ssh/sshd_config; then
    ok "ssh: auth par mot de passe desactivee"
else
    ko "ssh: PasswordAuthentication autorisee (cles recommandees)"
fi

# 3. pare-feu present et actif
if command -v ufw >/dev/null && ufw status 2>/dev/null | grep -qi active; then
    ok "pare-feu ufw actif"
elif command -v firewall-cmd >/dev/null && firewall-cmd --state 2>/dev/null | grep -qi running; then
    ok "pare-feu firewalld actif"
else
    ko "aucun pare-feu actif detecte (ufw/firewalld)"
fi

# 4. comptes avec UID 0 autres que root
others=$(awk -F: '($3==0 && $1!="root"){print $1}' /etc/passwd)
if [ -z "$others" ]; then
    ok "un seul compte UID 0 (root)"
else
    ko "autres comptes UID 0: $others"
fi

# 5. comptes sans mot de passe
empty=$(awk -F: '($2==""){print $1}' /etc/shadow 2>/dev/null)
if [ -z "$empty" ]; then
    ok "aucun compte sans mot de passe"
else
    ko "comptes sans mot de passe: $empty"
fi

# 6. mises a jour auto (debian)
if dpkg -l unattended-upgrades >/dev/null 2>&1; then
    ok "unattended-upgrades installe"
else
    ko "pas de mises a jour automatiques (unattended-upgrades absent)"
fi

echo
echo "resultat: $pass ok / $fail a corriger"
