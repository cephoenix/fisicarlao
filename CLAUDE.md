# FisiCarlão — contexto do projeto

App Android de fórmulas de física para alunos do ensino médio, feito pelo Carlos para o irmão dele (professor de física). Conversa em português.

## O produto
- Aluno instala o app para consultar fórmulas rápido. 106 fórmulas em 5 áreas (Mecânica, Termologia, Óptica, Ondulatória, Eletricidade), 18 assuntos.
- Cada fórmula: o que é cada letra (com unidade), exemplo resolvido grátis, dica do professor, vídeo grátis (hoje é só um link de busca no YouTube, placeholder) e card de "aula avançada" paga daquele assunto.
- Modelo de negócio: exemplo/aula básica grátis, aula avançada paga por assunto.
- O irmão vende as aulas na **Kiwify** (não Hotmart). Os botões "Quero essa aula" ainda não têm link real: faltam os links de checkout da Kiwify de cada aula (pedir ao Carlos).
- Preços (R$ 24,90–34,90), exemplos e dicas foram escritos pelo Claude como ponto de partida; o professor vai revisar.
- Planos futuros (ainda não começados): bot de WhatsApp (API oficial da Meta) que ajuda o aluno a montar horário de estudo e oferece a aula certa; webhooks da Kiwify para liberar conteúdo.
- Alunos podem ser menores de idade: guardar o mínimo de dados (LGPD).

## Estrutura
- `www/index.html` — o app inteiro (HTML/CSS/JS sem framework). Telas: Fórmulas (abas por área + busca), detalhe da fórmula, Favoritas (localStorage), Aulas.
- `www/data.js` — TODO o conteúdo: `AREAS`, `TOPICS` (com a aula paga de cada assunto: título, itens, preço) e `F` (fórmulas em LaTeX, renderizadas com KaTeX em MathML).
- `www/katex.min.js` — KaTeX 0.16.9 local (app funciona offline).
- Capacitor 6.2.0 (`capacitor.config.json`, appId `br.com.fisicarlao.app`), projeto nativo em `android/`.
- `node_modules/@capacitor/android` já está incluído (não precisa `npm install` para compilar; para `npx cap sync` precisa).
- Ícone e splash com o logo laranja do Carlão em `android/app/src/main/res` (ver "Visual").

## Visual (v2, 17/10/2026)
- Paleta do logo do professor (`outros/media`, PNGs 2048² transparentes): degradê #FFA800 → #FF6F00, preto quente #0F0D0B, branco. Escuro por padrão; claro pelo sistema ou botão ☀/☾ (localStorage `fisi-tema`).
- Cor + emoji por área no objeto `LOOK` do `index.html`: mec #FF9A1F 🚀, ter #FF5C7A 🔥, opt #B49CFF 🌈, ond #3DDCF2 🌊, ele #D4F53C ⚡.
- Estilo para adolescentes: botões "3D" (sombra embaixo, estilo Duolingo), cards arredondados, nav flutuante com blur.
- Logo recortado em `www/img/logo-carlao.png`; fontes locais em `www/fonts/` (Bricolage Grotesque, Plus Jakarta Sans, JetBrains Mono) para funcionar offline.
- Visual antigo (azul) guardado em `outros/versoes/index-v1-azul.html`.
- Ícone: logo branco sobre degradê (adaptativo: `drawable/ic_launcher_gradient.xml` + foreground PNG). Splash: logo laranja sobre #0F0D0B. Gerados por script PowerShell (System.Drawing) a partir de `outros/media`. Recursos antigos em `outros/versoes/res-v1-azul`.

## PWA — versão instalável pelo navegador (caminho escolhido para iPhone, 11/11/2026)
- **Publicado em https://cephoenix.github.io/fisicarlao/** (repo público `cephoenix/fisicarlao`, branch `main`). Todo push que muda `www/` republica sozinho pelo workflow `.github/workflows/pages.yml`.
- Sem Mac, o iPhone será atendido por PWA em vez de app nativo. Tarefa de publicação: `PUBLICAR-PWA.md` (GitHub Pages, workflow `.github/workflows/pages.yml`, publica `www/`).
- Arquivos: `www/manifest.webmanifest`, `www/sw.js`, `www/icons/` (gerados do ícone laranja), metas de PWA/iOS e aviso "Instale o FisiCarlão" no `www/index.html` (iPhone: instrução do Safari; Android: botão Instalar; some quando instalado; "Agora não" = 7 dias).
- O service worker não é registrado dentro do app Android (Capacitor).
- **Sempre que mudar algo em `www/`, aumentar `VERSAO` em `www/sw.js`**; arquivo novo em `www/` entra na lista `ARQUIVOS`.
- `IOS-GITHUB-ACTIONS.md` (app iOS nativo via GitHub Actions) fica como plano futuro, se um dia quiserem a App Store.

## Chat de pedidos do professor (11/11/2026)
- `www/professor.html`: aberta pelo botão ✏️ no topo do app (visível enquanto não há alunos — apagar a linha `id="prof"` no `index.html` para esconder), por 5 toques rápidos no logo, ou abrindo `professor.html`. O professor escreve um pedido → vira issue `[Pedido] ...` com `@claude` no repositório.
- O aparelho do professor guarda (só no localStorage dele) um token fine-grained do GitHub com permissão **apenas Issues (read/write) no repo fisicarlao**. Nunca colocar token no código.
- O professor não configura nada: o Carlos cria o token uma vez, conecta o próprio aparelho e usa "Conectar outro aparelho" para gerar o link `professor.html#chave=…` (o `#` não vai para o servidor; a página guarda o token e limpa a URL). Quem tiver o link pode pedir mudanças — trocar o token se o link vazar.
- `.github/workflows/claude.yml`: `anthropics/claude-code-action@v1` faz a mudança numa branch; o próprio workflow junta na `main`, valida (`data.js`, scripts do `index.html`, `sw.js`), publica no GitHub Pages e comenta "✅ Publicado". Um pedido por vez. Só dono/colaboradores disparam (repo é público).
- Usa o secret `CLAUDE_CODE_OAUTH_TOKEN` (assinatura Pro do Carlos; gerado com `claude setup-token`, vale 1 ano). Para trocar por chave da API, use `anthropic_api_key` no workflow e o secret `ANTHROPIC_API_KEY` em Settings → Secrets and variables → Actions.
- Regras dadas ao Claude no workflow: mexer só em `www/`, aumentar `VERSAO` no `sw.js`, responder em português sem jargão, perguntar se o pedido for ambíguo.
- Push feito pelo próprio workflow (GITHUB_TOKEN) não dispara o `pages.yml`; por isso o `claude.yml` publica sozinho.

## Fluxo de mudança de conteúdo
Editar `www/` → copiar para o Android (`cp -r www/. android/app/src/main/assets/public/`; o `npx cap sync` precisaria de `npm install`) → `bash build.sh`.
Pré-visualizar no navegador: config `www` em `.claude/launch.json` (servidor local na porta 5173).

## Build (funcionando desde 17/10/2026)
`bash build.sh` → `android/app/build/outputs/apk/debug/app-debug.apk` (~4 MB, ~2,5 min).
- Java: Temurin 21 portátil em `~/.jdks/jdk-21.0.12.1+1` (o JBR do Android Studio é Java 25 e quebra o AGP 8.2.1). Gradle 8.5.
- SDK em `$LOCALAPPDATA/Android/Sdk`, instalado via cmdline-tools (não pelo assistente do Android Studio): platforms;android-34, build-tools;34.0.0, platform-tools. Licenças aceitas com autorização do Carlos.
- `sdkmanager.bat` quebra nomes de pacote no `;` — usar `--package_file=<arquivo>`.
- NÃO contornar verificação de hash/checksum em downloads.

## Preferências do Carlos
- Quer que o Claude faça o trabalho de ponta a ponta, sem ficar pedindo para ele rodar comandos. Só interromper para o que só ele pode fazer (janela de administrador do Windows, aceitar licenças, senhas, pagamentos).
- Respostas curtas e diretas, em português.
