# linux-hardening

Script bash qui passe une machine Linux en revue sur quelques points de
durcissement classiques (inspiré des benchmarks CIS, en beaucoup plus léger) :
config SSH, pare-feu, comptes UID 0, comptes sans mot de passe, mises à jour
automatiques.

Lecture seule. Le script ne change rien, il affiche juste [OK] ou [WARN] et un
petit score à la fin.

## Utilisation

```
chmod +x audit.sh
./audit.sh          # lancer en root pour voir /etc/shadow
sudo ./audit.sh
```

A tester sur une VM jetable (Ubuntu/Debian par exemple). Normal d'avoir
plusieurs [WARN] sur une install par défaut, c'est exactement ce qu'on veut
voir et corriger.

## A rajouter

- vérifier les permissions de fichiers sensibles (/etc/passwd, /etc/shadow)
- lister les services en écoute avec ss -tulpn
- sortir un rapport dans un fichier au lieu d'afficher seulement à l'écran
