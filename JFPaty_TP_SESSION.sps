* Encoding: UTF-8.

*-------------------
*Sélection d'un sous-ensemble : Les personnes à l'emploi d'une organisation.
*ont répondu 1. « Current paid employee» à la question « Répondant présentement travailleur». 
*-----------------------
* Calcul de la valeur du poids moyen pour la population à l’étude : Les personnes en emploi.

TEMPORARY.
SELECT IF CUREMPLO=1.
MEANS TABLES WGHT_PER.
* La moyenne = 1719,65

*Création du poids echantillonnal du sous ensemble:

COMPUTE poids_curemplo = WGHT_PER/1719.65.
EXECUTE.

*Sélection permanente des données de l'échantillon:

SELECT IF CUREMPLO=1.

*Application du poids echantillonal à tous les calculs subséquents :

WEIGHT by poids_curemplo.

*------------------------------------
Préparation des variables dépendantes et indépendantes
*------------------------------------
*Regroupement de la variable satisfaction professionnelle en 3 modalités:

FREQUENCIES VARIABLES jsr_02.
COMPUTE JSR_02_r = JSR_02.
RECODE JSR_02_r (3 THRU 5 =1) (2 =2) (1 =3).
VARIABLE LABELS JSR_02_r "Satisfaction en rapport avec l’emploi - recodé".
VALUE LABELS  JSR_02_r 1"Insatisfait" 2"Satisfait" 3"Trés satisfait".
FORMATS JSR_02_r (f1).
FREQUENCIES VARIABLES JSR_02_r.

* groupe d'age :
* regroupement des groupes d'âge en 3 modalités au lieu de 10 :

***** age en trois catégories :

FREQUENCIES VARIABLES AGEGR10.
COMPUTE Age03 = AGEGR10.
RECODE Age03 (1 THRU 2 =1) (3 thru 4 =2) (5 thru HIGHEST = 3).
VALUE LABELS Age03 1 "moins 35 ans Y" 2"35 à 54 ans X" 3"plus de 55 ans Baby Boomers".
FORMATS Age03 (f1).

VARIABLE LABELS Age03 "Groupe d'âge du répondant - Génération".
FREQUENCIES VARIABLES Age03.


*Regroupement du niveau de scolarité : 

COMPUTE EHG3_01_r=EHG3_01.
RECODE EHG3_01_r (1 THRU 2 =1) (3 THRU 4 =2)  (5 THRU 7 = 3).
VALUE LABELS EHG3_01_r 1"Faible" 2"Moyen" 3"Élevé".
VARIABLE LABELS EHG3_01_r "Niveau d'éducation - recodé".
FORMATS EHG3_01_r (f1).
FREQUENCIES VARIABLES EHG3_01_r.

*Regroupement de la variable classe sociale PSC_01 :

FREQUENCIES VARIABLES PSC_01.
COMPUTE PSC_01_r=PSC_01.
RECODE PSC_01_r (1 THRU 2 =3) (3 =2) (4 THRU 5 =1).

VALUE LABELS PSC_01_r 1"Basse" 2"Moyenne" 3"Haute".
VARIABLE LABELS PSC_01_r "Classe sociale - recodé".
FORMATS PSC_01_r (f1).
FREQUENCIES VARIABLES PSC_01_r.

*Regroupement de la variable province PRV 

FREQUENCIES VARIABLES PRV.
COMPUTE PRV_r = PRV.
RECODE PRV_r (10 thru 13 =1) (24=2) (35=3) (46 thru 48 =4) (59 =5).
VARIABLE LABELS PRV_r "Province de résidence - recodé".
VALUE LABELS PRV_r 1"Maritimes" 2"Québec" 3"Ontario" 4"Prairies" 5"Colombie Britannique".
FORMATS PRV_r (f1).
FREQUENCIES VARIABLES PRV_r.

*---------------------------------------------------
Résultat de l'analyse univarié de la satisfaction professionnelle 
*---------------------------------------------------

FREQUENCIES VARIABLES JSR_02_r.

*Utilisation temporaire du poids populationnel afin de voir le nombre de personnes concernées:

TEMPORARY.
WEIGHT by WGHT_PER.
FREQUENCIES VARIABLES JSR_02_r.


*---------------------------------------------------
* Résulat de l'analyse bivariée des 5 variable retenues
*---------------------------------------------------

WEIGHT by poids_curemplo.

* Satisfaction au travail selon le genre Hommes/Femmes :

CROSSTABS  SEX by JSR_02_r
/STATISTICS CHISQ PHI GAMMA
/CELLS row COUNT
/COUNT CELL.


*Satisfaction au travail selon le groupe d'âge : 

CROSSTABS  Age03 by JSR_02_r
/STATISTICS CHISQ PHI GAMMA
/CELLS row.


*Satisfaction au travail selon le niveau de scolarité

CROSSTABS  EHG3_01_r by JSR_02_r 
/STATISTICS CHISQ PHI GAMMA
/CELLS row.

*satisfaction au travail par classe sociale :

CROSSTABS  PSC_01_r by JSR_02_r
/STATISTICS CHISQ PHI GAMMA
/CELLS row.

*Satisfaction au travail selon la région de résidence :

CROSSTABS  PRV_r by JSR_02_r 
/STATISTICS CHISQ PHI GAMMA
/CELLS row COUNT.



*Utilisation temporaire du poids populationnel afin de voir le nombre de personnes concernées par région:

TEMPORARY.
WEIGHT BY WGHT_PER.
CROSSTABS  PRV_r by JSR_02_r 
/STATISTICS CHISQ PHI GAMMA
/CELLS row COUNT.

*------------------------------------------
Partie 5 : Analyse Multivariée
-------------------------------------------
* Analyse par régression logistique

*Dichotomisation de la variable dépendante : JSR_02_r :
------------------------------------------

FREQUENCIES VARIABLES JSR_02_r .
COMPUTE insatisfait = JSR_02_r .
COMPUTE satisfait = JSR_02_r .
COMPUTE trés_satisfait = JSR_02_r .

RECODE insatisfait (2 THRU 3=0).
RECODE satisfait (1 =0) (3=0) (2=1).
RECODE trés_satisfait (1 THRU 2=0) ( 3=1).
VALUE LABELS insatisfait satisfait trés_satisfait 0"non" 1"oui".
FORMATS insatisfait satisfait trés_satisfait (f1).
FREQUENCIES VARIABLES  insatisfait satisfait trés_satisfait.



*Dichotomisation des variables indépendantes.
*-----------------------------------------------------------------

*Le genre du répondant : SEX :

FREQUENCIES VARIABLES SEX.
COMPUTE Hommes=SEX.
COMPUTE Femmes=SEX.

RECODE Hommes (2 =0).
RECODE Femmes (2 = 1) (1=0).

VALUE LABELS Hommes Femmes 0"non" 1"oui".
FORMATS Hommes Femmes (f1).

FREQUENCIES VARIABLES Hommes Femmes.

* dichotomisation de la varible age en 3 générations : 

COMPUTE Age03_Moins35 = Age03.
COMPUTE Age03_3554 = Age03.
COMPUTE Age03Plus55  = Age03.

RECODE Age03_Moins35 (2 THRU 3 =0).
RECODE Age03_3554 (1=0) (2=1) (3=0).
RECODE Age03Plus55 (1 THRU 2 =0) (3=1).

VALUE LABELS Age03_Moins35 Age03_3554 Age03Plus55  0"non" 1"oui".
FORMATS Age03_Moins35 Age03_3554 Age03Plus55 (f1).
FREQUENCIES VARIABLES Age03_Moins35 Age03_3554 Age03Plus55.


*Le niveau de scolarité :  EHG3_01_r

FREQUENCIES VARIABLES  EHG3_01_r.
COMPUTE Scolarité_faible =  EHG3_01_r.
COMPUTE  Scolarité_moyenne =  EHG3_01_r.
COMPUTE Scolarité_élevée =  EHG3_01_r.

RECODE Scolarité_faible (2 THRU 3 =0).
RECODE Scolarité_moyenne (1=0) (3=0) (2=1).
RECODE Scolarité_élevée (1 THRU 2 =0) (3=1).
VALUE LABELS Scolarité_faible Scolarité_moyenne Scolarité_élevée 0"non" 1"oui".
FORMATS  Scolarité_faible Scolarité_moyenne Scolarité_élevée (f1).
FREQUENCIES VARIABLES  Scolarité_faible Scolarité_moyenne Scolarité_élevée.


* La classe sociale : PSC_01_r

FREQUENCIES VARIABLES PSC_01_r.
COMPUTE Classe_basse = PSC_01_r.
COMPUTE Classe_moyenne = PSC_01_r.
COMPUTE Classe_haute= PSC_01_r.

RECODE Classe_basse ( 2 thru 3 =0).
RECODE Classe_moyenne (1 =0) (3=0) (2=1).
RECODE Classe_haute ( 1 thru 2 =0) (3=1).

VALUE LABELS Classe_basse Classe_moyenne Classe_haute 0"non" 1"oui".
FORMATS Classe_basse Classe_moyenne Classe_haute (f1).
FREQUENCIES VARIABLES Classe_basse Classe_moyenne Classe_haute.

*La région : PRV
Maritimes = Prince Edouard, Nova Scotia, New Brunswick, New Foudland
* Prairie : Manitoba, Saskatchewan, Alberta

FREQUENCIES VARIABLES PRV.
COMPUTE Maritimes=PRV.
COMPUTE Québec=PRV.
COMPUTE Ontario=PRV.
COMPUTE Prairies=PRV.
COMPUTE Colombie_Britannique=PRV.


RECODE Maritimes (10 thru 13 =1) (14 THRU HIGHEST=0).
RECODE Québec (24 =1) (10 THRU 13=0) (35 THRU HIGHEST = 0).
RECODE Ontario (10 THRU 24 =0) ( 35=1) (46 THRU HIGHEST =0).
RECODE Prairies (10 THRU 35 =0) (46 thru 48 =1 ) (59 =0).
RECODE Colombie_Britannique (10 THRU 48 =0) (59=1).

VALUE LABELS Maritimes Québec Ontario Prairies Colombie_Britannique 0"non" 1"oui".
FORMATS Maritimes Québec Ontario Prairies Colombie_Britannique (f1).
FREQUENCIES VARIABLES Maritimes Québec Ontario Prairies Colombie_Britannique.

*---------------------------------------------
Analyse par régression logistique : 

*Catégories de références :
*Sexe : hommes
• Âge : moins de 25 : Age03_Moins25
• Niveau de scolarité : Scolarité_élevée
* Classe sociale : Classe_haute
• Province : Québec


LOGISTIC REGRESSION VARIABLES trés_satisfait
/METHOD=ENTER Femmes
/METHOD=ENTER Age03_3554 Age03Plus55
/METHOD=ENTER Classe_basse Classe_moyenne 
/METHOD=ENTER Scolarité_faible Scolarité_moyenne
/METHOD=ENTER Maritimes Ontario Prairies Colombie_Britannique
/PRINT=ITER(1).

