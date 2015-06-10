@echo off
del slambda.zip >nul 2>&1

cd src
copy ..\README.md .
zip -r ..\slambda.zip .
del README.md
cd ..

haxelib submit slambda.zip
del slambda.zip
