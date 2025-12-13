cde pour lancer la fusion sous powershell en admin
------------------------------------------
Set-ExecutionPolicy RemoteSigned
cd D:\Documents_2To\Git\CTLD_CodeFusion
.\merge.ps1 liste.txt script_final.lua

lancer la fusion depauis invite de commande merge.ps1 doit etre dans meme dossier que liste.txt :
---------------------------------------------------------------------------------------------------
powershell -ExecutionPolicy Bypass -File merge.ps1 liste.txt fusion.lua
powershell -ExecutionPolicy Bypass -File merge.ps1 liste.txt fusion.lua
