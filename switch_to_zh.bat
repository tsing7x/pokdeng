del /f /q res\tutorial_1.jpg
del /f /q res\tutorial_2.jpg
del /f /q res\tutorial_3.jpg
del /f /q res\tutorial_4.jpg

echo override copy res_zh
xcopy /s /q /y ".\res_zh\*.*" ".\res\"

echo override copy src.zh
xcopy /s /q /y ".\src.zh\*.*" ".\src"