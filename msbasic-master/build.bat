@echo off
setlocal

REM Create tmp directory if it doesn't exist
if not exist tmp (
    mkdir tmp
)

REM List of targets
for %%i in (
    cbmbasic1
    cbmbasic2
    kbdbasic
    osi
    kb9
    applesoft
    microtan
    aim65
    sym1
    raspbian
) do (
    echo Building %%i
    ca65 -D %%i msbasic.s -o tmp\%%i.o || goto :error
    ld65 -C %%i.cfg tmp\%%i.o -o tmp\%%i.bin -Ln tmp\%%i.lbl || goto :error
)

echo Done.
goto :eof

:error
echo Build failed.
exit /b 1
