Les gMSA sont des comptes de service stocké dans l'Active Directory et qui ont un mot de passe renouvelé automatiquement à intervalle régulier sans aucune configuration de notre part.

Ils sont fait pour leur attribuer des tâches automatiques ou planifiées.



Créer un gMSA
La création du compte se fait sur powershell, de préférence avec les droits administrateurs.

Clé KDS racine
Le compte à d'abord besoin d'une clé KDS racine qu'on peux ajouter avec la commande suivante :

Création de la clé KDS racine
Add-KdsRootKey -EffectiveImmediately
La clé met une 10aine d'heure à être active, si vous souhaitez pouvoir utiliser la clé KDS immédiatement, on peux le forcer avec cette commande :

Argument AddKdsRootKey pour utilisation immédiate
Add-KdsRootKey –EffectiveTime ((Get-Date).AddHours(-10))
Création et paramétrage du compte
La création du compte se fait avec le cmdlet New-ADServiceAccount, je conseille de rajouter les arguments suivant que je détaille en dessous :

New-ADServiceAccount
New-ADServiceAccount -Name "gMSA_test" `
                     -Description "gMSA test pour la création de comptes de services" `
                     -DNSHostName "gmsa_test.domain.lan" `
                     -ManagedPasswordIntervalInDays 180 `
                     -PrincipalsAllowedToRetrieveManagedPassword "SERVERNAM$" `
                     -KerberosEncryptionType AES128, AES256 `
                     -Enabled $True
Name : le nom qu'aura le compte de service, soyez concis et faite le commencer par gMSA_ pour qu'il soit identifiable au premier coup d'œil

Descriptiion : la description que le compte aura

DNSHostName : le nom dns qu'aura le compte, rajoutez simplement .domain.lan au nom du compte

ManagedPasswordIntervalInDays : le mot de passe sera changé automatiquement tout les X jours, X étant le chiffre que vous avez renseignés.

PrincipalsAllowedToRetrieveManagedPassword : Les principaux AD qui peuvent récupérer le mot de passe et donc utiliser le compte de service. Il faut mettre ici le nom des serveurs qui utiliseront le compte. C'est IMPORTANT car sinon, le serveur ne pourra pas utiliser le compte comme sur des tâches planifiées ou des services. Si vous avez une erreur de droit, cela viens probablement de ce paramètre. Vous pouvez le changer après (voir en dessous). AUSSI le $ après le nom est important. Vous pouvez en mettre plusieurs, par exemple "ACTIVEDIRECTORY01$","TOOLSERVER02$"

KerberosEncryptionType : Le type d'encryptions utilisé pour les tickets Kerberos, il faut bien préciser AES128 et AES256 que nous utilisons, sinon il risquent d'utiliser d'autre type et provoque des erreurs

Enabled : Pour activer le compte



La liste des arguments et leur fonction est disponible ici : New-ADServiceAccount (ActiveDirectory) | Microsoft Learn





Il faut ensuite associer le serveur au compte que nous venons de créer (le $ n'est pas nécessaire après le nom du serveur ici)

Associer le compte au serveur
Add-ADComputerServiceAccount -Identity "SERVERNAME" -ServiceAccount "gMSA_test"
Un fois le compte créé dans l'annuaire on l'ajoute dans un groupe en fonction des droits dont il aura besoin (aussi faisable par l'interface graphique), le $ est nécessaire après le nom du compte de service.

Ajout dans un groupe
Add-ADGroupMember -Identity "domains admins" -Members "gMSA_test$"
Installation du compte sur un serveur
Enfin, il faut Installer le compte de service sur le serveur qui va l'utiliser (à faire en powershell directement depuis le serveur en question) pour que ce dernier puisse faire appel au compte

Installation du compte sur le serveur
Install-ADServiceAccount "gMSA_test"
Utiliser le gMSA
Pour l'utiliser dans un service ou une tâche planifiée, il faudra permettre à l'AD de le voir lors de la sélection de compte en changeant quelques paramètres :

Dans cette fenêtre de gauche, cliquez sur Types d'objets... et désélectionnez tout sauf des comptes de service


S'il n'est toujours pas détecté, cliquez sur Emplacement... et sélectionnez l'Unité d'Organisation dans lequel est le compte (normalement Managed Service Account) et refaite la recherche

S'il vous demande le mot de passe, laissez vide

Modifier le gMSA
Il est toujours possible  de modifier les paramètres du gMSA après sa création avec le cmdlet Set-ADServiceAccount, il faudra dans tous les cas commencer par l'argument -Identity afin de définir le compte à modifier

Modification du gMSA
Set-ADServiceAccount -Identity "gMSA_test"
La liste des arguments et leur fonction est disponible ici : Set-ADServiceAccount (ActiveDirectory) | Microsoft Learn



Plus d'informations et de procédures sur le sujet
