# Evaluation Blockchain SDV

## Description

Ce projet est un système de vote, développé en Solidity.


## Spécificités 
 * Les administrateurs peuvent enregistrer des candidats et gérer le workflow.

 * Les votants ne peuvent voter qu’une seule fois et reçoivent un NFT comme preuve de vote.

 * Les financeurs peuvent envoyer des fonds aux candidats.

 * Un rôle spécial WITHDRAWER permet de retirer les fonds uniquement après la fin du vote.

 * Le workflow du vote se fait en 4 étapes :

    - REGISTER_CANDIDATES : enregistrement des candidats
    - FOUND_CANDIDATES : candidats enregistrés
    - VOTE : phase de vote (1 heure après le lancement par l'administrateur)
    - COMPLETED : fin du vote et désignation du gagnant

## Rôles :

**ADMIN** : gérer le workflow et ajouter des candidats

**FOUNDER** : envoyer des fonds aux candidats

**WITHDRAWER** : retirer les fonds après le vote

## Fonctionnalités

Vérification que le votant n’a pas déjà voté via NFT.

Phase de vote débutant 1 heure après l’ouverture.

Attribution automatique d’un NFT au votant.

Désignation du gagnant du vote.

## Urls de transaction sur le réseau Sepolia : 
1) https://sepolia.etherscan.io/tx/0x468d5d1492f2b686dc14d90a244d09afddf586f69aef0f3edf33233729473f3b

2) https://sepolia.etherscan.io/tx/0x0ed60c3d59610f5941e4504e01e2d4fa95357c2305616ec8e9896118fcfd2570


## Usage

### Compilation du projet

```shell
$ forge compile
```

### Lancement des tests

```shell
$ forge test
```


## Author
### Malalatiana Erika ANDRIAFALIMANANA

