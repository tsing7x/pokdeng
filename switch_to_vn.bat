del /f /q res\tutorial_1.jpg
del /f /q res\tutorial_2.jpg
del /f /q res\tutorial_3.jpg
del /f /q res\tutorial_4.jpg

echo override copy res_vn
xcopy /s /q /y ".\res_vn\*.*" ".\res\"

echo override copy src.vn
xcopy /s /q /y ".\src.vn\*.*" ".\src"