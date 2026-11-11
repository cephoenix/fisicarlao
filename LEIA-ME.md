# FisiCarlão — app Android

## Gerar o app (primeira vez)

No Git Bash, dentro desta pasta:

    npm install
    npx cap sync android
    npx cap open android

O Android Studio abre o projeto. Espere o "Gradle sync" terminar (barra embaixo; a primeira vez demora alguns minutos).

Depois: menu **Build → Build App Bundle(s) / APK(s) → Build APK(s)**.
Quando terminar, clique em **locate**. O arquivo fica em:

    android/app/build/outputs/apk/debug/app-debug.apk

Mande esse .apk para o celular (WhatsApp, cabo ou Drive) e instale.
O Android vai pedir para permitir "instalar apps de fontes desconhecidas" — é normal para apps de teste.

## Testar direto no celular pelo cabo

1. No celular: Configurações → Sobre o telefone → toque 7 vezes em "Número da versão" → volte e ative "Depuração USB" em Opções do desenvolvedor.
2. Ligue no cabo, aceite a autorização no celular.
3. No Android Studio, escolha o celular no topo e clique no ▶ (Run).

## Mudar o conteúdo

- Fórmulas, exemplos, dicas e aulas: `www/data.js`
- Visual e telas: `www/index.html`

Depois de editar, rode `npx cap sync android` e gere o APK de novo.

## Publicar na Play Store (depois)

Build → Generate Signed App Bundle → crie uma chave (guarde bem o arquivo e a senha!) → envie o .aab no Google Play Console.
