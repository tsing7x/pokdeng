del /f /q res\tutorial_1.jpg
del /f /q res\tutorial_2.jpg
del /f /q res\tutorial_3.jpg
del /f /q res\tutorial_4.jpg

echo override copy res_en
xcopy /s /q /y ".\res_en\*.*" ".\res\"

echo override copy src.th
xcopy /s /q /y ".\src.en\*.*" ".\src"