# CV WordPress - IaaS
__________________________

Fonctionnement global
---
> Docker / GitHub / Terraform
---


Structure
---
'''
main
├── Contient :
│   ├── README.md
│   └── environments/dev/ ← contenu de la branche `dev` (via subtree)
│   └── environments/prod/ ← contenu de la branche `prod` (via subtree)
│
├── Suivi distant : origin/main

dev
├── Contient : (initialement vide, prêt à recevoir du contenu spécifique à dev)
├── Suivi distant : origin/dev

prod
├── Contient : (initialement vide, prêt à recevoir du contenu spécifique à prod)
├── Suivi distant : origin/prod

---



Pour mettre à jour les dossiers environments/dev/ et environments/prod/ dans la branche 'main' :
'''
git subtree add --prefix=environments/dev dev --squash
git subtree add --prefix=environments/prod prod --squash