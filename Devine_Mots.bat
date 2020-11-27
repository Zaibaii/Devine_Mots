@echo off
Title Devine Mots !  ~  Auteur: Zaibai
mode con: COLS=120 LINES=30
setlocal EnableDelayedExpansion
cd /D "%temp%"
echo.
echo   Chargement de la base de donn‚es...

:::::::::::::::::::::::::::::::: Variables Utilisateur ::::::::::::::::::::
REM Temps de réponse en secondes entre chaques indices dans le mode CLM (Contre-la-montre)
set /a iTempsDeReponseEnSecondes=15

REM Valeur à saisir pour quitter une partie / le script
set /a iValeurDeSortie=4

REM Permet de faire un check visuel de la base de données en mettant la variable à 1
set /a iBDDVerifVisuel=0
:::::::::::::::::::::::::::::::: Variables Utilisateur ::::::::::::::::::::

:::::::::::::::::::::::::::::::: Variables ::::::::::::::::::::::::::::::::
REM Titre du jeu
set "sTitreDuJeu=Devine Mots"

REM Chemin complet + fichier du script
set fScript=%0

REM Commande externe généré dynamiquement
set fBatbox="batbox.exe"

REM Variable pour calculer le temps restant en mode CLM (Contre-la-montre)
set /a iFinDuTempsEnSecondes=%iTempsDeReponseEnSecondes%

REM Récupère un Back Space/Retour Arrière pour les espaces au début des commandes 'set /p'
for /f %%a in ('"prompt;$H&for %%b in (0) do rem"') do set BS=%%a
:::::::::::::::::::::::::::::::: Variables ::::::::::::::::::::::::::::::::

REM Création de la commande externe %fBatbox%
call :Creation_Batbox

REM Chargement de la BDD interne au script (voir le label :BDD_Interne pour modification de la BDD)
REM Récupère les informations sous le format: mot_à_trouver;Indice1;Indice2;Indice3;Indice4;Indice5
REM %sIDListe% 2047 caractères max, au-delà erreur: la ligne d'entrée semble trop longue
REM Du coup, nombre de mot/ligne max dans la BDD (dû au préfixe _): 1540
for /F "tokens=1* delims=!!" %%c in ('findstr /B /I /C:"^!^!" %fScript%') do (
	set /a iBDDNbrDeMotTotal+=1
	set aBDD[_!iBDDNbrDeMotTotal!]=%%c
	set sIDListeOri=!sIDListeOri!:_!iBDDNbrDeMotTotal!
)
set sIDListeOri=%sIDListeOri:~1%:

REM Check si une vérification visuel de la BDD est demandé
If %iBDDVerifVisuel% EQU 1 (call :BDD_Verification)

:Menu_Mode
call :Curseur_Off
set iModeDeJeu=
cls
echo.
%fBatbox% /c 0x09 &echo							     %sTitreDuJeu% &%fBatbox% /c 0x07
echo.
echo							Mode de jeu:
%fBatbox% /c 0x0A &echo							1: Mode Classique &%fBatbox% /c 0x07
%fBatbox% /c 0x0C &echo							2: Mode Contre-la-montre &%fBatbox% /c 0x07
echo							3: Pr‚sentation et RŠgles
echo							%iValeurDeSortie%: Quitter
echo. &echo.
call :Curseur_On

REM Gestion du Menu Mode
set /p iModeDeJeu=.%BS%  Entrez le num‚ro du mode de jeu souhait‚: 
If not defined iModeDeJeu (set /a iModeDeJeu=9999)
set iModeDeJeuTemp=%iModeDeJeu:~0,1%
If %iModeDeJeuTemp% EQU 0 (set /a iModeDeJeu=9999)
If %iModeDeJeu% EQU 1 (goto :Menu_Difficulte)
If %iModeDeJeu% EQU 2 (goto :Menu_Difficulte)
If %iModeDeJeu% EQU 3 (goto :Regles)
If %iModeDeJeu% EQU %iValeurDeSortie% (goto :Quit)
echo. &pause>nul |echo   Merci de rentrer une valeur attendue. &goto :Menu_Mode

:Menu_Difficulte
call :Curseur_Off
set iNbrIndiceMax=
cls
echo.
%fBatbox% /c 0x09 &echo							     %sTitreDuJeu% &%fBatbox% /c 0x07
echo.
echo							Niveau de difficult‚:
%fBatbox% /c 0x0A &echo							1: Facile (5 indices) &%fBatbox% /c 0x07
%fBatbox% /c 0x0E &echo							2: Normal (4 indices) &%fBatbox% /c 0x07
%fBatbox% /c 0x0C &echo							3: Difficile (3 indices) &%fBatbox% /c 0x07
echo							%iValeurDeSortie%: Retour au menu principal
echo. &echo.
call :Curseur_On

REM Gestion du Menu Difficulté
set /p iNbrIndiceMax=.%BS%  Entrez le num‚ro de difficult‚ souhait‚: 
If not defined iNbrIndiceMax (set /a iNbrIndiceMax=9999)
set iNbrIndiceMaxTemp=%iNbrIndiceMax:~0,1%
If %iNbrIndiceMaxTemp% EQU 0 (set /a iNbrIndiceMax=9999)
If %iNbrIndiceMax% EQU 1 (set /a iNbrIndiceMax=5 &goto :Menu_Nombre_Mot)
If %iNbrIndiceMax% EQU 2 (set /a iNbrIndiceMax=4 &goto :Menu_Nombre_Mot)
If %iNbrIndiceMax% EQU 3 (set /a iNbrIndiceMax=3 &goto :Menu_Nombre_Mot)
If %iNbrIndiceMax% EQU %iValeurDeSortie% (goto :Menu_Mode)
echo. &pause>nul |echo   Merci de rentrer une valeur attendue. &goto :Menu_Difficulte

:Menu_Nombre_Mot
call :Curseur_Off
set iNbrMotaTrouver=
set /a iScore=0
set /a iErreur=0
cls
echo.
%fBatbox% /c 0x09 &echo							     %sTitreDuJeu% &%fBatbox% /c 0x07
echo.
echo							Nombre de mots … trouver:
%fBatbox% /c 0x0A &echo							Minimum: 5 &%fBatbox% /c 0x07
%fBatbox% /c 0x0C &echo							Maximum: %iBDDNbrDeMotTotal% &%fBatbox% /c 0x07
echo							%iValeurDeSortie%: Retour au menu principal
echo. &echo.
call :Curseur_On

REM Gestion du Menu Nombre Mot
set /p iNbrMotaTrouver=.%BS%  Entrez le nombre de mots … trouver souhait‚: 
If not defined iNbrMotaTrouver (set /a iNbrMotaTrouver=9999)
set iNbrMotaTrouverTemp=%iNbrMotaTrouver:~0,1%
If %iNbrMotaTrouverTemp% EQU 0 (set /a iNbrMotaTrouver=9999)
If %iNbrMotaTrouver% EQU %iValeurDeSortie% (goto :Menu_Mode)
If %iNbrMotaTrouver% GEQ 5 if %iNbrMotaTrouver% LEQ %iBDDNbrDeMotTotal% (goto :Nouvelle_Partie)
echo. &pause>nul |echo   Merci de rentrer une valeur attendue. &goto :Menu_Nombre_Mot

:Nouvelle_Partie
set /a iNbrMotaTrouverRestant=%iNbrMotaTrouver% 
set /a iBDDNbrDeMotNonFait=%iBDDNbrDeMotTotal%
set sIDListe=%sIDListeOri%

:Nouveau_Mot
REM Check si il reste des mots à trouver
If %iNbrMotaTrouverRestant% EQU 0 (goto :Jeu_Fini)

REM Pioche une ligne de la BDD aléatoirement dans les lignes restantes (random contrôlé entre 1 et %iBDDNbrDeMotNonFait%)
set /a iRCtrl=%random%%%%iBDDNbrDeMotNonFait%+1
set /a iRCtrlSave=%iRCtrl%
set sIDListeTemp=%sIDListe%
Call :Extract_ID_Ligne

REM Extraction de la ligne + mise à jour des lignes restantes
Call :BDD_Extract_Ligne %sBDDLigne%
set "sIDListe=!sIDListe:%sBDDLigne%:=!"
set /a iBDDNbrDeMotNonFait-=1
set /a iNbrMotaTrouverRestant-=1
set iRCtrl=
set iRCtrlSave=
set sIDListeTemp=
set sBDDLigne=
set iNbrIndice=

:Nouvel_Indice
set /a iNbrIndice+=1

:Indice_Actuel
set sMotPropose=

REM Gère l'affichage du Mot N°/Score/Erreur/Indice/Mot proposé et Timeout si mode CLM (Contre La Montre)
call :Affichage_Jeu

REM Saisie particulière pour le mode CLM (Contre La Montre)
If %iModeDeJeu% EQU 2 (goto :CLM_Saisie)

REM Demande de saisie - Mot à trouver
set /p sMotPropose=.%BS%  Votre r‚ponse: 
If not defined sMotPropose (echo. &pause>nul |echo   Merci de rentrer une valeur. &goto :Indice_Actuel)

:Resultat_Saisie
REM Pour ne pas avoir le pb d'affichage '~0,28' si variable vide/non défini --> !sMotPropose[%%m]:~0,28! (CLM mode)
If not defined sMotPropose (set "sMotPropose= ")

REM Si sMotPropose vaut %iValeurDeSortie% goto :Annuler_Jeu_En_Cours (Pour CLM mode on retourne directement au menu sans demander confirmation)
If "%sMotPropose%"=="%iValeurDeSortie%" (
	If %iModeDeJeu% EQU 2 (goto :Menu_Mode)
	echo.
	goto :Annuler_Jeu_En_Cours
)

REM Sauvegarde la saisie
set sMotPropose[%iNbrIndice%]=%sMotPropose%
echo.

REM Si mot trouvé
If /i "%sMotPropose%"=="%sMotATrouver%" (
	set /a iScore+=1
	echo   Bravo ^^!
	echo. &pause>nul|echo   Appuyez sur une touche pour continuer...
	goto :Nouveau_Mot
)

REM Si mot non trouvé
set /a iErreur+=1
If %iNbrIndice% EQU %iNbrIndiceMax% (
	set /a iScore-=1
	echo   Perdu =/
	echo   Le mot ‚tait: %sMotATrouver%
	echo. &pause>nul|echo   Appuyez sur une touche pour continuer...
	goto :Nouveau_Mot
) else (
	echo   Rat‚, essaye encore ^^!
	timeout /t 3 >nul
	goto :Nouvel_Indice
)

:Jeu_Fini
cls
echo. &echo.
if %iScore% GEQ 1 (
	%fBatbox% /c 0x0A /d "  Bien jou" /a 130 /d " ^!" /c 0x07 &echo.
	echo   Tu as gagn‚ avec un score de %iScore% ^^!
) else (
	%fBatbox% /c 0x0C /d "  GAME OVER ^!" /c 0x07 &echo.
	echo   Tu feras mieux la prochaine fois ^^!
	echo   Ton score est de %iScore%.
)
echo. &pause>nul|echo   Appuyez sur une touche pour revenir au menu...
goto :Menu_Mode

:CLM_Saisie
REM Ces variables servent au déplacement du curseur (entre "Temps restant:" et "Votre réponse:")
set /a iCLMSaisieLongueur=0
set /a iTempsRestantCurseurPosY=6+%iNbrIndice%
set /a iTempsRestantCurseurPosX=17
set /a iReponseCurseurPosY=8+%iNbrIndice%

REM Récupère l'heure actuelle (heure1) dans des variables et enlève les 0 d'en-têtes (01,02 etc)
for /f "tokens=1-3 delims=:," %%e in ("%time%") do (
	set iHeure1=%%e
	set iHeure1=!iHeure1: =!
	set /a iHeure1=1!iHeure1!-^(11!iHeure1!-1!iHeure1!^)/10
	set iMin1=%%f
	set /a iMin1=1!iMin1!-^(11!iMin1!-1!iMin1!^)/10
	set iSec1=%%g
	set /a iSec1=1!iSec1!-^(11!iSec1!-1!iSec1!^)/10
)

:CLM_Saisie_Boucle
REM Récupère la touche pressé (continue le code même si aucune touche n'est pressé)
%fBatbox% /k_
set /a iTouchePresse=%errorlevel%
::echo code ASCII : %iTouchePresse% &pause

REM Récupère l'heure actuelle (heure2) dans des variables et enlève les 0 d'en-têtes (01,02 etc)
for /f "tokens=1-3 delims=:," %%h in ("%time%") do (
	set iHeure2=%%h
	set iHeure2=!iHeure2: =!
	set /a iHeure2=1!iHeure2!-^(11!iHeure2!-1!iHeure2!^)/10
	set iMin2=%%i
	set /a iMin2=1!iMin2!-^(11!iMin2!-1!iMin2!^)/10
	set iSec2=%%j
	set /a iSec2=1!iSec2!-^(11!iSec2!-1!iSec2!^)/10
)

REM Met à jour le temps de réponse restant (déplace le curseur, saisie les secondes restantes et remet le curseur à sa place)
set /a iFinDuTempsEnSecondes=3600*(%iHeure1%-%iHeure2%)+60*(%iMin1%-%iMin2%)+(%iSec1%-%iSec2%)+%iTempsDeReponseEnSecondes%
set /a iReponseCurseurPosX=17+%iCLMSaisieLongueur%
%fBatbox% /h 0 /g %iTempsRestantCurseurPosX% %iTempsRestantCurseurPosY% /d "%iFinDuTempsEnSecondes% " /g %iReponseCurseurPosX% %iReponseCurseurPosY% /h 1

REM Fin du temps de réponse
If %iFinDuTempsEnSecondes% LEQ 0 (set /a iFinDuTempsEnSecondes=%iTempsDeReponseEnSecondes% &echo. &goto :Resultat_Saisie)

REM Si aucune touche pressé
If %iTouchePresse% EQU 0 (goto :CLM_Saisie_Boucle)

REM Gestion de la touche Entrée
If %iTouchePresse% EQU 13 (
	If not "%sMotPropose%"=="" (
		set /a iFinDuTempsEnSecondes=%iTempsDeReponseEnSecondes%
		echo.
		goto :Resultat_Saisie
	)
	goto :CLM_Saisie_Boucle
)

REM Gestion de la touche RetourArrière (efface le dernier caractère)
If %iTouchePresse% EQU 8 (
	If %iCLMSaisieLongueur% GEQ 1 (
		set sMotPropose=%sMotPropose:~0,-1%
		set /a iCLMSaisieLongueur-=1
		call :Affichage_Jeu
	)
	goto :CLM_Saisie_Boucle
)

REM Gestion de la touche Echap/Suppr (efface toute la saisie)
set /a iErase=0
If %iTouchePresse% EQU 27 (set iErase=1)
If %iTouchePresse% EQU 338 (set iErase=1)
If %iErase% EQU 1 (
	If %iCLMSaisieLongueur% GEQ 1 (
		set sMotPropose=
		set /a iCLMSaisieLongueur=0
		call :Affichage_Jeu
	)
	goto :CLM_Saisie_Boucle
)

REM Gestion de la touche ';' (ne fonctionne pas avec '%fBatbox% /a %iTouchePresse%')
If %iTouchePresse% EQU 59 (
	echo |set /p=";"
	set "sMotPropose=%sMotPropose%;"
	set /a iCLMSaisieLongueur+=1
	goto :CLM_Saisie_Boucle
)

REM Bloque les touches suivantes: 
REM CTRL+UneTouche;1-31
REM Flèches directionnelles: FlècheHaut;327 - FlècheGauche;330 - FlècheDroite;332 - FlècheBas;335
REM F11;388 - F12;389
REM Insert;337 - Home;326 - PageUP;328 - Fin;334 - PageDown;336
If %iTouchePresse% GEQ 1 If %iTouchePresse% LEQ 31 (goto :CLM_Saisie_Boucle)
for %%k in (326;327;328;330;332;334;335;336;337;388;389) do (
	If %iTouchePresse% EQU %%k (goto :CLM_Saisie_Boucle)
)

REM Affiche la touche pressé (pas de nouvelle ligne) - ASCII 33 pour sauvegarder la touche '!'
for /F "delims=" %%l in ('%fBatbox% /a %iTouchePresse%') do (
	%fBatbox% /a %iTouchePresse%
	If %iTouchePresse% NEQ 33 (set "sSaisieTemp=%%l") else (set "sSaisieTemp=^!")
	set "sMotPropose=%sMotPropose%!sSaisieTemp!"
	set /a iCLMSaisieLongueur+=1
)

REM Pause de 10 millisecondes (pour éviter une éventuelle surcharge CPU)
%fBatbox% /w 10
goto :CLM_Saisie_Boucle

:Annuler_Jeu_En_Cours
set sAnnulerJeu=
set /a iQuestCurseurPosY=8+%iNbrIndice%
set /p sAnnulerJeu=.%BS%  Voulez-vous vraiment arrˆter la partie ? (O/N): 
If /i "%sAnnulerJeu%"=="O" (goto :Menu_Mode)
If /i "%sAnnulerJeu%"=="Oui" (goto :Menu_Mode)
If /i "%sAnnulerJeu%"=="N" (goto :Indice_Actuel)
If /i "%sAnnulerJeu%"=="Non" (goto :Indice_Actuel)
%fBatbox% /g 0 %iQuestCurseurPosY%
goto :Annuler_Jeu_En_Cours

:Regles
cls
echo.
echo   Pr‚sentation:
echo.
%fBatbox% /c 0x09 &echo |set /p=".%BS%  %sTitreDuJeu% "&%fBatbox% /c 0x07 &echo est un jeu de r‚flexion o— vous devez trouver un mot.
echo   Comment ? Avec l'aide de plusieurs indices ^^!
echo.
echo   RŠgles:
echo.
echo   - Mode de Jeu:  Le jeu comporte deux modes diff‚rents, classique et contre-la-montre.
echo                   Le mode contre-la-montre vous donne %iTempsDeReponseEnSecondes% secondes par indice.
echo                   Une partie peut-ˆtre quitt‚e … tout moment avec la saisie "%iValeurDeSortie%".
echo.
echo   - Dificult‚:    Le nombre d'indices varie de 3 … 5 en fonction du niveau de difficult‚ choisi
echo                   o— chaque indice vous donne une possibilit‚ de r‚ponse.
echo.
echo   - Score:        Chaque bonne r‚ponse vous fait gagner un point tandis que chaque mot non trouv‚,
echo                   vous en fait perdre un.
echo.			   
echo   - Erreur:       Chaque erreur de saisie est ‚galement comptabilis‚e … titre informatif.
echo.  
echo   - Saisie:       Les majuscules/minuscules ne sont pas prises en compte dans la saisie,
echo                   cependant faites attention … l'orthographe et aux accents ^^!
echo.
echo   Auteur/D‚veloppeur:
echo.
echo   Zaibai
echo. &pause>nul|echo   Appuyez sur une touche pour revenir au menu...
goto :Menu_Mode

:Quit
call :SUPPR_Batbox
exit

:Affichage_Jeu
call :Curseur_Off
set /a iNbrMotActuel=%iNbrMotaTrouver%-%iNbrMotaTrouverRestant%
cls
echo.
echo   Mot Nø: %iNbrMotActuel%/%iNbrMotaTrouver%
If %iScore% GEQ 1 (%fBatbox% /c 0x0A /d "  Score:  %iScore%" /c 0x07 &echo.)
If %iScore% LSS 0 (%fBatbox% /c 0x0C /d "  Score: %iScore%" /c 0x07 &echo.)
If %iScore% EQU 0 (echo   Score:  %iScore%)
echo   Erreur: %iErreur%
echo.

REM Aligne et affiche les indices et les mots proposés
for /L %%m in (1,1,%iNbrIndice%) do (
	If %%m NEQ %iNbrIndice% (
		set "sIndiceEcho=Indice %%m/%iNbrIndiceMax%: !sIndice[%%m]!                            "
		echo   !sIndiceEcho:~0,40!Mot propos‚: !sMotPropose[%%m]:~0,28!
	) else (
		echo   Indice %%m/%iNbrIndiceMax%: !sIndice[%%m]!
	)
)
echo.

REM Affiche le temps restant + saisie en cas de mode CLM (Contre-la-montre)
If %iModeDeJeu% EQU 2 (
	echo   Temps restant: %iFinDuTempsEnSecondes%
	echo.
	echo |set /p=".%BS%  Votre r‚ponse: %sMotPropose%"
)
call :Curseur_On
GOTO:EOF

:Curseur_On
%fBatbox% /h 1
GOTO:EOF

:Curseur_Off
%fBatbox% /h 0
GOTO:EOF

:SUPPR_Batbox
REM Supprime le fichier %fBatbox%
If exist %fBatbox% (
	taskkill /IM %fBatbox% /T /F >nul 2>&1
	del /F /Q /A:H %fBatbox% >nul 2>&1
	del /F /Q %fBatbox% >nul 2>&1
)
GOTO:EOF

:Creation_Batbox
REM https://batch.xoo.it/t2243-Commande-Externe-Batbox-v1-0.htm
call :SUPPR_Batbox
for %%u in (
	4D534346000000001D040000000000002C000000000000000301010001000000
	000000004700000001000100000800000000000000001C437A4D200062617462
	6F782E6578650000D407ABCE030008434BBD557F681B75147F973665B3B5894D
	0E0B3A768355C6C0E20F8A522964B475AB4B66C8C5056430D3E692BB2CBD0B77
	171B717F6434016705270CEC1F433A2A8A0A4E648E3AFF584BC58158F06FFDC3
	E21FDAFC63FDC71FE0B6F3F3EEAE4D0AC32AA85FFAB97BEFF3DEF77DDF7BDF77
	69E2F91A0944D44961721CA2182B5831DA7DD580DEFDD77BE9EADEB5034B427C
	ED405AD52CA96C1A05333B2D4D6575DDB0A54945322BBAA4E9D2D8B3B2346DE4
	94C17BEF39B81523394E1417047AE2FD7DA92D6E9D4242B7203C4D5D50BA7C32
	DC06CE8EDF01223F5DE4EF2FC9E35FD7883ADAF76D7BFAAABFFEE823AA04FE46
	B1FFF21ACC97B236DE6F07FD84BABCBCDBD70BDC8AFF78A935314645EFA5DAFC
	28E3E1880F32FD8B23DE8AC468F12C2BBFFA4A15CAC671A43AFA6AA4F6A5F4A8
	93FFB49B86DFDCEC8B51A87E18FCD1C2F73F37BF711C67630FB4A43374D68DD8
	198D51731574ED65E174A8D18BC31DF1204C8DE550FD03F08ED80F6D844B0E35
	BA5D33134187C7C411253EF71A6EB123F831CE1AE0695DAC3379D925AF815C59
	0F0B41E69C21EFE91DBD878F3EC619BD08D79BC1EB7DDE782FB2A0BA8F77FAD8
	310AF7E67E762CC2516E67F7822DF63B4355372221A2D73A417DC53DC9E37BC0
	CF8EB001CD58C396FCEC08DB03A1C60D68BF05E7A1DC86146A5CC1736EE435E8
	E7EFAC6C86CFFDC0055DBEE037E40D583B5CEF64E6A4FA5E2B8F737790DD15AF
	2561AEABCCC45B5C0DB765E3224BDC8B660606F5525B1BFAE1BEC143B7B8C017
	DD6E8A72A48738521AF6F3373100603238630977DEEC61CB307F786ED1DB772A
	F1B6CDDBBEB1F61455829FB95315C02C174976C479DEBEC61EFDE08B1E79089B
	673FEF595DF931E0BC7B03B9CE0679F43AE7F6F16BEE81C6B7A13A7FAEAB45F2
	EE7DC0A281DCB0FBB7737CAD708C3E047E024E01F7DF17A387812F804F80EF80
	A338200C1C06CE14B253B9696346B5CAF9DFA3AD38A723445191E8EB488B2B42
	BE057CD4C655212F0117DAB83AE4F9C8DD3FAF847C7234951E1C8BC7E9F878EA
	C478FCF1C75C859E93C7535B7266E24422E189B4E0075AD80E982C655F928D8A
	9E3BC2DAB2CF2F6FDB65D598C9687ACE9861ED108A7A127806C80135E0227009
	B80A7C05ACFB85FF135F7CD68A2DDBB963593D5752DC73157BD4D02DA3A424F0
	9BBE93492B55FB886D9BDA64C5567658462BA6659849C3D26CCDD079574AC9E6
	7CE3845EAED85CA65C5294F25DF64DE879C3CF6517BED591568C31CD2AA3996E
	BA8FE0B2878131200D9C02F2A257E95FD988CAA6A6DB7977680A8A3DA5BA128B
	D3594DCF9A050BBA52D56C973F33A97A92659BB651FAFFFFCFECB6FE04     
) do >>t.dat (
	echo.For b=1 To len^("%%u"^) Step 2
	echo WScript.StdOut.Write Chr^(Clng^("&H"^&Mid^("%%u",b,2^)^)^) : Next
)
cscript /b /e:vbs t.dat>batbox.ex_
timeout /T 1 >nul
del /f /q t.dat >nul 2>&1
expand -r batbox.ex_ >nul 2>&1
del /f /q batbox.ex_ >nul 2>&1
GOTO:EOF

:BDD_Verification
REM Vérification de la BDD
for /L %%t in (1,1,%iBDDNbrDeMotTotal%) do (
 	cls
 	call :BDD_Extract_Ligne _%%t
 	echo.
 	echo.
	echo   Ligne:    %%t
	echo   Mot:      !sMotATrouver!
 	echo   Indice 1: !sIndice[1]!
 	echo   Indice 2: !sIndice[2]!
 	echo   Indice 3: !sIndice[3]!
	echo   Indice 4: !sIndice[4]!
 	echo   Indice 5: !sIndice[5]!
	echo.
 	pause>nul|echo   Appuyez sur une touche pour continuer...
)
GOTO:EOF

:BDD_Extract_Ligne
set sBDDLigneCible=%1

REM Extrait la ligne %sBDDLigneCible% pour mettre le mot_à_trouver + les indices dans des variables séparées
For /F "tokens=1-6 delims=;" %%n in ("!aBDD[%sBDDLigneCible%]!") do (
	set sMotATrouver=%%n
	set sIndice[1]=%%o
	set sIndice[2]=%%p
	set sIndice[3]=%%q
	set sIndice[4]=%%r
	set sIndice[5]=%%s
)
set sBDDLigneCible=
GOTO:EOF

:Extract_ID_Ligne
REM Récupère un ID de ligne dans les lignes restantes (ce code contourne la limitation des 31 tokens)
If %iRCtrl% GTR 30 (
	For /F "tokens=30* delims=:" %%a in ('echo %sIDListeTemp%') do (
		set /a iRCtrl-=30
		set sIDListeTemp=%%b
	)
	REM Rustine au cas où - Cette condition est là pour éviter une éventuelle boucle infinie en cas de problème
	If not !iRCtrl! EQU !iRCtrlSave! (set /a iRCtrlSave=!iRCtrl!) else (set /a iRCtrl=1)
	goto :Extract_ID_Ligne
)
For /F "tokens=%iRCtrl% delims=:" %%a in ('echo %sIDListeTemp%') do (
	set sBDDLigne=%%a
)
REM Rustine au cas où
If not defined sBDDLigne if %iRCtrl% NEQ 1 (set /a iRCtrl=1 &goto :Extract_ID_Ligne)
GOTO:EOF

:BDD_Interne
REM Syntaxe pour ajout de mot --> !!mot_à_trouver;Indice1;Indice2;Indice3;Indice4;Indice5
REM Nombre de mot/ligne max dans la BDD -> 1540 (à cause de la longueur de %sIDListe%)
!!b‚ton;MatiŠre;Solide;Construction;Portugais;Murs
!!scŠne;Metteur;M‚nage;Horreur;Devant;Th‚ƒtre
!!visite;Domicile;Droit;M‚dicale;Carte;Rendre
!!planche;Voile;Dessin;Pain;Repasser;EtagŠre
!!arbre;Chat;Vie;Feuille;Fruitier;Racine
!!bouteille;Encre;Mer;Vin;Soda;Eau
!!pointe;Pied;Compas;Vitesse;Cheveux;Aiguille
!!bras;Levier;Bout;Tour;Droit;Fer
!!d‚fense;Instinct;Moyen;El‚phant;SystŠme;Arme
!!tableau;Galerie;Noir;Craie;Affichage;Cadre
!!fauteuil;Plage;Jardin;Bascule;Roulant;Pliant
!!bouton;Sonnette;Chemise;Porte;FiŠvre;Acn‚
!!arc;Bander;Tirer;Cible;FlŠche;Archer
!!air;Temps;Trou;Courant;Chanson;Vent
!!mariage;Fleurs;Champagne;C‚r‚monie;Pr‚sents;Anneaux
!!banque;Euros;Caissier;Argent;Crise;Virement
!!police;Menottes;Arme;Voiture;Prison;Arrestation
!!lettre;A;Z;Facteur;Courrier;Alphabet
!!roche;Min‚ral;Solide;Dur;S‚dimentaire;Pierre
!!vent;Moulin;Instrument;Coupe;Air;Souffle
!!salaire;Minimum;Virement;Bulletin;Fin du mois;SMIC
!!base;Connaissance;Donn‚es;Ravitaillement;Navale;Militaire
!!plume;Poids;Stylo;Oreiller;Oiseau;Paon
!!travail;Bleu;Table;Manuel;Entreprise;Esclavage
!!or;Livre;Silence;Coeur;Argent;Mine
!!ventre;Mal;Plat;Creux;Faim;Nombril
!!soleil;Chapeau;Lunettes;Levant;Rayon;Bronzer
!!bouche;Incendie;M‚tro;Fine;Amuse;LŠvres
!!pomme;Jus;Quartier;Douche;Adam;Fruit
!!fermeture;Porte;Annuelle;Horaires;Automatique;Cl‚
!!noeud;Papillon;Coulant;Marin;Lacets;Corde
!!rŠgle;Conduite;Exception;Conforme;Jeu;Mesurer
!!neige;Oeuf;Chute;Blanc;Hiver;Flocons
!!voyage;Carnet;Scolaire;Sac;Agence;Noces
!!escalier;Cage;Ext‚rieur;Colima‡on;Secours;Marches
!!route;Pav‚e;Accident;D‚partementale;Nationale;Voiture
!!boŒte;Sardine;Musique;Crƒnienne;Bijoux;Nuit
!!disque;Compact;Frein;Optique;Dur;Album
!!tour;Contr“le;Magie;France;Monde;Eiffel
!!train;Gare;TchouTchou;Rails;Wagons;TGV
!!accouchement;Naturel;Provoqu‚;Terme;Douleur;C‚sarienne
!!tˆte;Coup;Signe;Perdre;Linotte;Visage
!!voie;AccŠs;Publique;Prioritaire;Garage;Lact‚e
!!plat;Oeuf;Japonais;Chaud;Principal;R‚chauff‚
!!pˆche;Poisson;Patience;Ligne;Bouchon;Asticot
!!piste;Tour;Jeu;Atterrisage;Bowling;Ski
!!tapis;Souris;Sport;Sol;Yoga;Marchand
!!mur;Papier Peint;Portugais;B‚ton;Plƒtre;Cloison
!!voile;Porter;Char;Bateau;Hisser;Mari‚e
!!nuit;Noces;Blanche;Noire;Veilleuse;Lune
!!doigt;Petit;Montrer;Honneur;Main;Ongle
!!brosse;Balai;Dents;Cheval;Cheveux;Dentifrice
!!bataille;Plan;Touch‚;Coul‚;Navale;Lutte
!!vol;Vent;Vitesse;Plan‚;Papillon;Oiseau
!!note;Manuscrite;Fausse;Carnet;Gamme;Musique
!!oeuf;Neige;Autruche;Dur;Brouill‚;Pƒques
!!boule;Jeu;Perdre;Neige;Bowling;P‚tanque
!!portefeuille;Carte d'identit‚;Permis de conduire;Carte Bleue;Sac;Poche
!!sac;Voyage;Affaire;Sport;Papier;Main
!!agent;Police;Immobilier;MaŒtrise;Commercial;Secret
!!verre;Oeil;Boire;Tremp‚;Lunettes;Whisky
!!d‚part;Faux;Top;Point;Ligne;Arriv‚e
!!descente;Rappel;Enfers;Police;Ski;Mont‚e
!!s‚curit‚;Danger;Accident;Ceinture;Marge;RoutiŠre;
!!feu;Eau;Extincteur;Fum‚e;Chaleur;Pompier
!!lion;Cage;Roi;Zodiaque;Mufasa;Simba
!!couronne;Dentaire;No‰l;Fleurs;DiadŠme;Reine
!!th‚ƒtre;PiŠce;Rideau;Loges;Actes;Coulisses
!!pain;Planche;Campagne;Four;Farine;Mie
!!fort boyard;Nain;Cl‚s;PŠre Fouras;Emission;Jeu
!!batterie;Percussion;Baguette;Piles;Charge;Voiture
!!timbre;Carnet;Philat‚lie;Lettre;Fiscal;Poste
!!ciel;Bleu;Etoiles;SeptiŠme;Paradis;Nuages
!!bague;Oiseau;Cigare;Bijoux;Doigt;Alliance
!!rame;Train;Papier;Aviron;Barque;Pagaie
!!angle;G‚om‚trie;Degr‚;Droit;Rapporteur;Coin
!!magicien;Illusion;Tour;Num‚ro;Chapeau;Lapin
!!cuisine;Salle … manger;Couteau;Casserole;Pr‚paration;Recette
!!carton;Accident;Papier;Rouge;BoŒte;Colis
!!secret;Jardin;D‚fense;Polichinelle;Cach‚;Intime
!!cloche;Fromages;Quasimodo;Pƒques;Eglise;Sonner
!!‚clair;G‚nie;Chocolat;Fermeture;Orage;Foudre
!!maŒtre;Chien;Ecole;Chanteur;Jeu;Serviteur
!!fruit;Arbre;Salade;Pomme;Quartier;Cl‚mentine
!!argent;Comptant;M‚tal;Billet;Or;Monnaie
!!balle;Jeu;Fusil;Golf;Football;Ballon
!!mario;Football;Tennis;Kart;Princesse;Luigi
!!noyau;Terre;Fruit;Centre;Olive;Pˆche
!!point;Vue;Croix;Score;Ponctuation;Virgule
!!robe;Cheval;Soir‚e;Vˆtement;Mari‚e;Jupe
!!lunette;Vue;Toilette;Ski;Soleil;Opticien
!!rouge;Pomme;Cerise;Fraise;Sang;Couleur
!!h“tel;Chambre;R‚servation;Nuit;Ibis;Formule 1
!!radio;Silence;R‚veil;Fr‚quence;Poste;Antenne
!!part;Gƒteau;Pizza;Partage;Portion;Tranche
!!gare;RoutiŠre;Quai;Train;Station;RER
!!clou;Spectacle;Marteau;Quincaillerie;Vis;Pointe
!!bande;Originale;Dessin‚e;Son;Cyclable;Annonce
!!lame;Bistouri;Couteau;C‚ramique;Fine;Rasoir
!!ordinateur;Binaire;Informatique;Unit‚ Centrale;Windows;PC

REM Amélioration :
