# Process-resources

## Initialisation de l'environment virtuel (Pour des seulement)

### Pré-requis (Python 3.10)
```
# S'assurer d'avoir python3.10 et son venv d'installé
sudo apt install python3.10 python3.10-venv
```

### Initialisation de l'environment virtuel (Nécessaire aux unit-tests)
```
cd ~/git/Omnimed-solutions/build-tools/workspace/local/process-resources/
python3 -m venv ./venv
source ./venv/bin/activate
```

## Utilisation de l'app

Les omnikools ajoutent un alias `processResources` à ~/.bashrc. Simplement la rouler pour lancer le CLI.
