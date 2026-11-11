# Tarefa: versão iOS do FisiCarlão com build no GitHub Actions

> Leia também o `CLAUDE.md` da raiz para o contexto geral do projeto.
> Carlos usa Windows e **não tem Mac**. Todo build iOS precisa rodar no GitHub Actions (runner macOS).
> Converse em português. Faça o trabalho de ponta a ponta e só pare para o que só o Carlos pode fazer (contas, senhas, pagamentos, aceitar termos, escolher público/privado).

## Objetivo
1. **Fase 1 (agora):** o GitHub Actions compila o app iOS **sem assinatura** (simulador), provando que o projeto iOS funciona.
2. **Fase 2 (quando existir conta Apple Developer, US$ 99/ano):** o workflow assina o app e envia para o **TestFlight**, para alunos instalarem no iPhone.

## Projeto atual
- Pasta: `C:\Carlos\Desenvolvimento\fisicarlao-app`
- Capacitor 6.2.0, `appId` = `br.com.fisicarlao.app`, `appName` = `FisiCarlão`, `webDir` = `www`
- Conteúdo em `www/index.html` e `www/data.js`; KaTeX local em `www/katex.min.js`.
- Já existe a plataforma Android (`android/`). A plataforma iOS ainda **não** foi adicionada.
- `node_modules/` atualmente só tem `@capacitor/android` copiado à mão. Rode `npm install` para ter tudo (`@capacitor/core`, `@capacitor/cli`).

## Passo a passo

### 1. Preparar o repositório
- Verificar se `git` e `gh` estão instalados e se o Carlos está logado (`gh auth status`). Se não estiver, peça para ele rodar `gh auth login`, porque o login é dele.
- **Perguntar ao Carlos** se o repositório deve ser **público** ou **privado**.
  - Público: minutos de macOS grátis.
  - Privado: o plano Free tem 2.000 min/mês, mas minuto de macOS conta 10×, o que dá cerca de 200 min de Mac por mês.
- Confirmar que o `.gitignore` exclui `node_modules/`, `android/app/build/`, `android/build/`, `android/.gradle/`, `ios/App/Pods/`, `ios/App/build/` e `ios/DerivedData/`.
- `git init`, primeiro commit, criar o repo com `gh repo create` e fazer o push.

### 2. Adicionar a plataforma iOS
- `npm install @capacitor/ios@6.2.0` (mesma versão do core) e commitar `package.json` e o lock.
- No Windows, `npx cap add ios` gera os arquivos, mas o `pod install` não roda sem Mac. Escolha uma destas opções:
  - **(a)** gerar `ios/` no Windows e commitar; o `pod install` roda no CI;
  - **(b)** não commitar `ios/` e rodar `npx cap add ios` dentro do workflow.
  Prefira **(a)**, porque permite versionar ajustes no `Info.plist` e nos ícones.
- Ícone e splash do iOS: gerar a partir do ícone "FC" já usado no Android (azul #1F4FD8, sublinhado amarelo). Pode usar `@capacitor/assets` ou gerar os PNGs com script. O AppIcon do iOS **não pode ter transparência**.

### 3. Workflow da Fase 1: `.github/workflows/ios.yml`
- Gatilhos: `push` na branch principal e `workflow_dispatch` (rodar manualmente).
- `runs-on: macos-latest` (confira a versão do Xcode disponível no runner).
- Passos esperados:
  1. `actions/checkout`
  2. `actions/setup-node` (Node 20 ou 22) e `npm ci`
  3. `npx cap sync ios`
  4. `pod install` em `ios/App` (Capacitor 6 usa CocoaPods)
  5. Build para o simulador, sem assinatura:
     `xcodebuild -workspace ios/App/App.xcworkspace -scheme App -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build`
  6. Publicar o `.app` como artifact do workflow (opcional, útil para depurar).
- Disparar o workflow, acompanhar com `gh run watch` e corrigir erros até ficar verde.

### 4. Workflow da Fase 2: assinatura e TestFlight (só depois que o Carlos tiver a conta)
Os passos manuais abaixo são **do Carlos** (ou do irmão, se a conta for dele). Guie-o:
- Criar a conta no Apple Developer Program.
- Registrar o App ID `br.com.fisicarlao.app` e criar o app no App Store Connect.
- Gerar uma **App Store Connect API Key** (Issuer ID, Key ID e o arquivo `.p8`).
- Certificado de distribuição e perfil de provisionamento: dá para fazer sem Mac, via API do App Store Connect, via `fastlane match`/`fastlane cert`+`sigh` no próprio CI, ou com um CSR gerado por `openssl` no Windows.

Guardar como **GitHub Secrets**, nunca no repositório:
`APPSTORE_ISSUER_ID`, `APPSTORE_KEY_ID`, `APPSTORE_P8` (conteúdo), `IOS_DIST_CERT_P12` (base64), `IOS_DIST_CERT_PASSWORD`, `IOS_PROFILE` (base64) e o que mais o método escolhido exigir.

No workflow:
- Importar o certificado num keychain temporário e instalar o perfil.
- `xcodebuild archive`, depois `-exportArchive` com `ExportOptions.plist` (method `app-store`).
- Incrementar o build number automaticamente (por exemplo, com `github.run_number`).
- Enviar para o TestFlight. **Confira na documentação atual da Apple** qual ferramenta de upload é a recomendada hoje (`fastlane pilot`/`upload_to_testflight` ou `xcrun altool` com a API key). Não confie de memória.

### 5. Ajuste no app para iOS: venda de aulas
- A Apple costuma barrar botões que levam para pagamento externo de conteúdo digital (aqui, o checkout da Kiwify). As regras variam por país e mudam com o tempo: **pesquise a regra vigente para o Brasil** antes de decidir.
- Até confirmar, implemente uma flag: quando `Capacitor.getPlatform() === 'ios'`, esconder os botões "Quero essa aula" e "Ver na Kiwify" e a aba Aulas, ou trocá-los por um texto neutro do tipo "Fale com o professor". No Android e na web, nada muda.

## Critérios de pronto
- **Fase 1:** o workflow `ios.yml` roda verde no GitHub, com o build do simulador sem erros.
- **Fase 2:** um build aparece no TestFlight e instala num iPhone de teste.
- O `CLAUDE.md` é atualizado com o estado do iOS, como rodar o workflow e quais secrets existem (só os nomes, nunca os valores).

## O que NÃO fazer
- Não commitar certificados, `.p8`, senhas ou perfis no repositório.
- Não desativar verificações de assinatura ou de hash para "fazer passar".
- Não criar contas nem aceitar termos em nome do Carlos.
