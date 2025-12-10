# Life Planner - Guia de Instalação e Compilação

## Visão Geral

O **Life Planner** é um aplicativo Android completo de organização de vida e rotina, desenvolvido com Flutter. Ele inclui todas as funcionalidades solicitadas:

- ✅ To-Do List com progresso diário
- ✅ Diário de anotações com tags
- ✅ Metas e objetivos com categorias
- ✅ Compromissos com alarmes e lembretes
- ✅ Controle financeiro com categorias
- ✅ Tarefas agendadas com calendário
- ✅ Acompanhamento diário com estatísticas
- ✅ Design em tons pastéis
- ✅ Notificações e alarmes do sistema
- ✅ Banco de dados local (SQLite)

## Requisitos

Para compilar e instalar o aplicativo, você precisa de:

1. **Flutter SDK** (versão 3.24.0 ou superior)
2. **Android SDK** com API 21 ou superior
3. **Java Development Kit (JDK)** 11 ou superior
4. **Git** (para clonar repositórios)

## Passo a Passo: Compilação no Windows

### 1. Instalar Flutter

1. Baixe o Flutter SDK em: https://flutter.dev/docs/get-started/install
2. Extraia em um local sem espaços (ex: `C:\flutter`)
3. Adicione ao PATH do Windows:
   - Abra "Variáveis de Ambiente"
   - Adicione `C:\flutter\bin` ao PATH

### 2. Instalar Android SDK

1. Baixe o Android Studio em: https://developer.android.com/studio
2. Instale e abra o Android Studio
3. Vá em **Tools > SDK Manager**
4. Instale:
   - Android SDK Platform 31 ou superior
   - Android SDK Build-Tools 33 ou superior
   - Android Emulator (opcional)

### 3. Configurar Variáveis de Ambiente

Abra o Prompt de Comando como administrador e execute:

```bash
setx ANDROID_HOME "C:\Users\[seu_usuario]\AppData\Local\Android\sdk"
setx PATH "%PATH%;%ANDROID_HOME%\tools;%ANDROID_HOME%\tools\bin;%ANDROID_HOME%\platform-tools"
```

### 4. Clonar/Copiar o Projeto

Se você tiver o código-fonte:

```bash
cd C:\Users\[seu_usuario]\Documents
git clone [URL_DO_REPOSITORIO] life_planner_app
cd life_planner_app
```

Ou copie a pasta do projeto para seu computador.

### 5. Instalar Dependências

```bash
flutter pub get
```

### 6. Compilar o APK

Para gerar o APK em modo release (otimizado):

```bash
flutter build apk --release
```

O arquivo APK será gerado em:
```
build/app/outputs/flutter-apk/app-release.apk
```

### 7. Instalar no Celular

**Opção A: Usando ADB (Android Debug Bridge)**

1. Conecte seu celular via USB
2. Ative o Modo de Desenvolvedor (toque 7 vezes em "Número da Compilação")
3. Ative "Depuração USB"
4. Execute:

```bash
flutter install
```

**Opção B: Transferência Manual**

1. Copie o arquivo `app-release.apk` para seu celular
2. Abra o arquivo no celular
3. Clique em "Instalar"

## Passo a Passo: Compilação no macOS

### 1. Instalar Flutter

```bash
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"
```

### 2. Instalar Android SDK

```bash
brew install android-sdk
export ANDROID_HOME=/usr/local/share/android-sdk
export PATH="$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools"
```

### 3. Compilar

```bash
cd path/to/life_planner_app
flutter pub get
flutter build apk --release
```

## Passo a Passo: Compilação no Linux

### 1. Instalar Flutter

```bash
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:$PWD/flutter/bin"
```

### 2. Instalar Android SDK

```bash
sudo apt-get install android-sdk android-sdk-build-tools
export ANDROID_HOME=/usr/lib/android-sdk
export PATH="$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools"
```

### 3. Compilar

```bash
cd path/to/life_planner_app
flutter pub get
flutter build apk --release
```

## Compilar App Bundle (para Google Play Store)

Se você deseja publicar na Google Play Store:

```bash
flutter build appbundle --release
```

O arquivo será gerado em:
```
build/app/outputs/bundle/release/app-release.aab
```

## Solução de Problemas

### Erro: "No Android SDK found"

Verifique se a variável `ANDROID_HOME` está configurada corretamente:

```bash
echo $ANDROID_HOME  # Linux/macOS
echo %ANDROID_HOME%  # Windows
```

### Erro: "License status unknown"

Execute:

```bash
flutter doctor --android-licenses
```

E aceite todas as licenças digitando `y`.

### Erro: "Gradle build failed"

Limpe o projeto e tente novamente:

```bash
flutter clean
flutter pub get
flutter build apk --release
```

## Estrutura do Projeto

```
life_planner_app/
├── lib/
│   ├── main.dart                 # Ponto de entrada
│   ├── theme/
│   │   └── app_theme.dart        # Tema em tons pastéis
│   ├── models/
│   │   └── models.dart           # Modelos de dados
│   ├── database/
│   │   └── database_helper.dart  # SQLite
│   ├── services/
│   │   └── notification_service.dart  # Notificações
│   └── screens/
│       ├── home_screen.dart
│       ├── todo_screen.dart
│       ├── diary_screen.dart
│       ├── goals_screen.dart
│       ├── appointments_screen.dart
│       ├── financial_screen.dart
│       ├── scheduled_tasks_screen.dart
│       └── progress_screen.dart
├── pubspec.yaml                  # Dependências
└── android/                      # Configuração Android
```

## Funcionalidades Principais

### 1. To-Do List
- Criar, editar e deletar tarefas
- Marcar tarefas como completas
- Visualizar progresso diário
- Data de vencimento

### 2. Diário
- Escrever anotações com título e conteúdo
- Adicionar tags para organizar
- Editar e deletar entradas
- Histórico completo

### 3. Metas
- Criar metas por categoria
- Acompanhar progresso (0-100%)
- Marcar como completa
- Categorias: Leitura, Exercício, Aprendizado, Saúde, Carreira, Pessoal

### 4. Compromissos
- Agendar compromissos com data e hora
- Configurar lembretes (5, 10, 15, 30, 60 minutos antes)
- Notificações automáticas
- Descrição opcional

### 5. Controle Financeiro
- Registrar receitas e despesas
- Categorizar transações
- Visualizar saldo mensal
- Gráfico de renda vs despesa

### 6. Tarefas Agendadas
- Calendário interativo
- Tarefas recorrentes (diária, semanal, mensal)
- Alarmes personalizados
- Visualização por data

### 7. Acompanhamento Diário
- Registrar conclusão de tarefas
- Acompanhar progresso de metas
- Registrar humor (😊 😐 😢)
- Estatísticas dos últimos 30 dias

## Cores do Tema (Tons Pastéis)

- **Roxo Pastel**: #B4A7D6 (Primária)
- **Rosa Pastel**: #FFB4D6 (Secundária)
- **Azul Pastel**: #A8D8EA (Acentuada)
- **Verde Pastel**: #A8E6CF (Sucesso)
- **Laranja Pastel**: #FFD3B6 (Aviso)
- **Vermelho Pastel**: #FFAFAF (Erro)

## Permissões do Android

O aplicativo requer as seguintes permissões (configuradas automaticamente):

- `android.permission.POST_NOTIFICATIONS` - Para notificações
- `android.permission.SCHEDULE_EXACT_ALARM` - Para alarmes
- `android.permission.READ_EXTERNAL_STORAGE` - Para ler ebooks

## Dicas de Uso

1. **Primeiro Uso**: Ao abrir o aplicativo, todas as funcionalidades estão disponíveis na tela inicial
2. **Notificações**: Certifique-se de que as notificações estão habilitadas nas configurações do Android
3. **Backup**: Os dados são armazenados localmente no SQLite. Faça backup regularmente
4. **Widgets**: Para adicionar widgets na tela inicial, mantenha pressionado e selecione "Life Planner"

## Suporte e Contribuições

Para dúvidas ou sugestões, entre em contato com o desenvolvedor.

## Licença

Este projeto é fornecido como está para uso pessoal.

---

**Desenvolvido com ❤️ usando Flutter**
