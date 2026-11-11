# Tarefa: publicar o FisiCarlão como PWA no GitHub Pages

> Leia também o `CLAUDE.md`. Fale em português. Faça tudo de ponta a ponta; só pare para o que é do Carlos (login no GitHub, escolher nome do repositório e se é público ou privado).

## Já está pronto em `www/`
- `manifest.webmanifest` (nome, cores, `display: standalone`, `start_url`/`scope` relativos `./`)
- `sw.js` (service worker: guarda app, fontes locais, logos e ícones para uso offline; links externos passam direto). Se adicionar arquivo novo em `www/`, inclua na lista `ARQUIVOS`. **Ao mudar qualquer arquivo de `www/`, aumente `VERSAO` em `sw.js`**, senão os alunos continuam vendo a versão antiga.
- `icons/` (192, 512, maskable 512, apple-touch-icon 180 sem transparência, favicon 32), gerados do ícone laranja do Android (foreground sobre o degradê #FFA800→#FF6F00)
- `index.html` com as metas de PWA/iOS e um aviso de instalação:
  - iPhone/Safari: explica "Compartilhar → Adicionar à Tela de Início"; em outro navegador no iPhone, pede para abrir no Safari.
  - Android/Chrome: botão "Instalar" (evento `beforeinstallprompt`).
  - Some se já estiver instalado; "Agora não" esconde por 7 dias.
  - Não registra service worker quando roda dentro do app Android (Capacitor).
- Testado em Chromium (simulando iPhone): service worker ativo, fórmulas e fontes carregam com a rede desligada, aviso de instalação aparece.
- `.github/workflows/pages.yml`: publica `www/` no GitHub Pages a cada push na `main`.

## Passos
1. `git` e `gh` instalados? `gh auth status` → se não logado, peça ao Carlos `gh auth login`.
2. Perguntar ao Carlos o nome do repositório (sugestão: `fisicarlao`) e se é **público** (GitHub Pages grátis) ou **privado** (Pages em repo privado exige plano pago do GitHub).
3. Conferir `.gitignore` (node_modules, builds do Android/iOS). `git init -b main`, commit, `gh repo create <nome> --source . --push` (com `--public` ou `--private`).
4. Ativar o Pages com origem "GitHub Actions": `gh api -X POST repos/{owner}/{repo}/pages -f build_type=workflow` (se já existir, use `PUT`).
5. Rodar/acompanhar o workflow: `gh run watch`. Endereço final: `https://<usuario>.github.io/<repo>/`.
6. Validar no endereço publicado: abre, carrega fórmulas, manifest e service worker sem erro (pode usar Lighthouse/Playwright se disponível).
7. Entregar ao Carlos o link e o texto curto para o professor mandar aos alunos:
   "Instale o FisiCarlão: abra <link> — no iPhone, use o Safari e toque em Compartilhar → Adicionar à Tela de Início. No Android, toque em Instalar."
8. Atualizar o `CLAUDE.md` com o endereço publicado e o lembrete de aumentar `VERSAO` no `sw.js`.

## Depois (opcional)
- Domínio próprio (ex.: fisicarlao.com.br, ~R$ 40/ano) apontando para o GitHub Pages.
- Links reais de checkout da Kiwify em `www/data.js` (faltam os links do professor).
