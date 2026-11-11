#!/usr/bin/env bash
# FisiCarlão — gera o APK de teste. Uso no Git Bash:  bash ~/Documents/fisicarlao-app/build.sh
set -e
cd "$(dirname "$0")/android"

major() { "$1/bin/java" -version 2>&1 | head -1 | sed -E 's/.*version "([0-9]+).*/\1/'; }

echo "== Procurando um Java 17 ou 21 =="
JH=""
for d in "/c/Program Files/Android/Android Studio/jbr" \
         /c/Program\ Files/Eclipse\ Adoptium/jdk-21* /c/Program\ Files/Eclipse\ Adoptium/jdk-17* \
         /c/Program\ Files/Microsoft/jdk-21* /c/Program\ Files/Microsoft/jdk-17* \
         /c/Program\ Files/Java/jdk-21* /c/Program\ Files/Java/jdk-17* \
         "$HOME"/.jdks/*; do
  [ -x "$d/bin/java" ] || continue
  m=$(major "$d"); echo "  $d -> Java $m"
  if [ "$m" = "17" ] || [ "$m" = "21" ]; then JH="$d"; break; fi
done

if [ -z "$JH" ]; then
  echo
  echo "Nenhum Java 17 ou 21 encontrado. Instalando o Temurin 21 (Eclipse Adoptium) pelo winget..."
  winget install --id EclipseAdoptium.Temurin.21.JDK -e --accept-package-agreements || true
  for d in /c/Program\ Files/Eclipse\ Adoptium/jdk-21*; do [ -x "$d/bin/java" ] && JH="$d"; done
fi

if [ -z "$JH" ]; then
  echo "ERRO: não consegui um Java 17/21. Mande esta saída para o Claude."; exit 1
fi

export JAVA_HOME="$JH"
export ANDROID_HOME="${ANDROID_HOME:-$LOCALAPPDATA/Android/Sdk}"
echo "== Usando JAVA_HOME=$JAVA_HOME"
echo "== Usando ANDROID_HOME=$ANDROID_HOME"
[ -d "$ANDROID_HOME/platforms" ] || { echo "ERRO: Android SDK não encontrado. Abra o Android Studio uma vez (configuração Standard) e rode de novo."; exit 1; }

./gradlew --stop >/dev/null 2>&1 || true
./gradlew assembleDebug

APK="$(pwd)/app/build/outputs/apk/debug/app-debug.apk"
echo
echo "PRONTO: $APK"
explorer.exe "$(cygpath -w "$(dirname "$APK")")" || true
