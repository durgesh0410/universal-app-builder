#!/bin/bash
# use: ./newapp.sh mygame
NAME=$1
if [ -z "$NAME" ]; then
  NAME="app$(date +%s)"
fi
PKG="com.durgesh0410.$NAME"
echo "Bana raha hu: $NAME - $PKG"

mkdir -p $NAME
cd $NAME
flutter create --org com.durgesh0410 --project-name $NAME .
# iski alag chabi
keytool -genkey -v -keystore $NAME-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias $NAME -storepass 123456 -keypass 123456 -dname "CN=Durgesh, OU=$NAME, O=Durgesh, L=Dindori, ST=MP, C=IN"
cp $NAME-key.jks ../$NAME-key.jks
printf "storePassword=123456\nkeyPassword=123456\nkeyAlias=$NAME\nstoreFile=$NAME-key.jks\n" > android/key.properties
cp $NAME-key.jks android/app/$NAME-key.jks
cd ..
git add $NAME-key.jks
git commit -m "new app $NAME"
echo "Ho gaya! $NAME ready hai, package: $PKG"
