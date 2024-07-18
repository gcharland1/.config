# Explo language pour scripting versionning

## Javascript
### Apperçu dans l'écosystème Omnimed
* Tous nos serveurs ont node.js d'installé
* Tous les devs connaissent bien le language
* Possibilité de faire un frontend ben simple pour manipuler l'environment local selon les solutions qu'on veut modifier
* ? Peut gérer les secrets

### Librairies disponibles
**:white_check_mark: Git**
* [simple-git](https://www.npmjs.com/package/simple-git)
    * Permet d'intéragir avec les remotes de manière async
    * Supporte toutes les opérations qu'on a besoin

**:white_check_mark: K8s**
* [@kubernetes/client-node](https://www.npmjs.com/package/@kubernetes/client-node)
    * :+1: Maintenu par kubernetes directement

**:white_check_mark: Maven**
* [maven-deploy](https://www.npmjs.com/package/maven-deploy)
    * wrapper qui facilite la gestion des configs/déploiements de maven
    * Exécute mvn directement dans un sub-process
    * ? Est-ce qu'on pourrait publish directement avec des noms customs sans avoir à modifier le poms?

**:white_check_mark: Filesytem**
* fs (Builtin)

## Python
### Apperçu dans l'écosystème Omnimed
+ On a introduit python récemment dans l'écosystème et Python est réputé pour être un language facile à lire/apprendre.
- C'est pas tous les devs qui y sont familiers
- La gestion des pip-envs peut être difficile si mal gérée

### Librairies disponibles
**:x: Git**
* [GitPython](https://github.com/gitpython-developers/GitPython)
    * La lib n'est plus supportée et est en transition vers Rust
* [pygit2](https://www.pygit2.org/)
    * Ne permet pas de faire de log par sous-directories (Opération de base de toute la logique du versionning)
* On peut toujours rouler les commande dans un sub-process


**:white_check_mark: K8s**
* [kubernetes](https://github.com/kubernetes-client/python)
    * Support officiel par kubernetes

**:x: Maven**
* Subprocess uniquement

**:white_check_mark: Filesytem**
* os (Builtin)
    * Permet la manipulation de fichiers et la navigation du filesystem


## Notes sur la performance et le testing
Je ne crois pas que les gains de performance à aller chercher avec les différents languages sont si grands que ça. Le projet Omnimed-solutions comprend ~80'000 et les fichiers à modifier sont de l'ordre de ~30kb. La logique de l'algorithme de gestion de la compilation va apporter un beaucoup plus grand gain que les performances du language.

Tous les languages analysés sont faciles à tester
