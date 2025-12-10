# Life Planner - Aplicativo de Organização de Vida e Rotina

![Flutter](https://img.shields.io/badge/Flutter-3.24.0-blue)
![Dart](https://img.shields.io/badge/Dart-3.5.0-blue)
![License](https://img.shields.io/badge/License-Personal-green)

Um aplicativo Android completo e intuitivo para organização de vida e rotina, desenvolvido com Flutter. Inclui to-do list, diário, metas, compromissos com alarmes, controle financeiro, tarefas agendadas e acompanhamento diário.

## 🎨 Características Principais

### 📋 To-Do List
- Criar e gerenciar tarefas diárias
- Marcar tarefas como completas
- Visualizar progresso em tempo real
- Datas de vencimento personalizadas

### 📔 Diário de Anotações
- Escrever anotações com título e conteúdo
- Adicionar tags para organizar
- Editar e deletar entradas
- Histórico completo de anotações

### 🎯 Metas e Objetivos
- Definir metas por categoria
- Acompanhar progresso (0-100%)
- Categorias: Leitura, Exercício, Aprendizado, Saúde, Carreira, Pessoal
- Marcar metas como completas

### 📅 Compromissos
- Agendar compromissos com data e hora
- Configurar lembretes automáticos
- Notificações do sistema
- Descrição e detalhes opcionais

### 💰 Controle Financeiro
- Registrar receitas e despesas
- Categorizar transações
- Visualizar saldo mensal
- Análise de gastos por categoria

### ⏰ Tarefas Agendadas
- Calendário interativo
- Tarefas recorrentes (diária, semanal, mensal)
- Alarmes personalizados
- Visualização por data

### 📊 Acompanhamento Diário
- Registrar conclusão de tarefas
- Acompanhar progresso de metas
- Registrar humor (😊 😐 😢)
- Estatísticas dos últimos 30 dias

## 🎨 Design

O aplicativo utiliza um **tema em tons pastéis** cuidadosamente selecionado para proporcionar uma experiência visual agradável e relaxante.

## 🛠️ Tecnologias Utilizadas

- **Framework**: Flutter 3.24.0
- **Linguagem**: Dart 3.5.0
- **Banco de Dados**: SQLite (sqflite)
- **Notificações**: flutter_local_notifications
- **Calendário**: table_calendar

## 🚀 Instalação Rápida

### Pré-requisitos

- Flutter 3.24.0 ou superior
- Android SDK API 21 ou superior
- Java Development Kit (JDK) 11 ou superior

### Passos

1. **Instale as dependências**
```bash
flutter pub get
```

2. **Compile o APK**
```bash
flutter build apk --release
```

3. **Instale no seu celular**
```bash
flutter install
```

Para instruções detalhadas, veja [GUIA_INSTALACAO.md](GUIA_INSTALACAO.md)

## 📱 Requisitos do Sistema

- **Android**: 5.0 (API 21) ou superior
- **RAM**: Mínimo 2GB
- **Espaço**: ~50MB

## 📂 Estrutura do Projeto

```
life_planner_app/
├── lib/
│   ├── main.dart                          # Ponto de entrada
│   ├── theme/
│   │   └── app_theme.dart                 # Tema da aplicação
│   ├── models/
│   │   └── models.dart                    # Modelos de dados
│   ├── database/
│   │   └── database_helper.dart           # Gerenciamento do SQLite
│   ├── services/
│   │   └── notification_service.dart      # Serviço de notificações
│   └── screens/
│       ├── home_screen.dart               # Tela inicial
│       ├── todo_screen.dart               # To-Do List
│       ├── diary_screen.dart              # Diário
│       ├── goals_screen.dart              # Metas
│       ├── appointments_screen.dart       # Compromissos
│       ├── financial_screen.dart          # Controle Financeiro
│       ├── scheduled_tasks_screen.dart    # Tarefas Agendadas
│       └── progress_screen.dart           # Acompanhamento Diário
├── android/                               # Configuração Android
├── pubspec.yaml                           # Dependências do projeto
├── GUIA_INSTALACAO.md                     # Guia de instalação
└── README.md                              # Este arquivo
```

## 🔐 Permissões

O aplicativo requer as seguintes permissões:

- `POST_NOTIFICATIONS` - Para enviar notificações
- `SCHEDULE_EXACT_ALARM` - Para agendar alarmes
- `READ_EXTERNAL_STORAGE` - Para acessar arquivos

## 💡 Dicas de Uso

1. **Primeira Execução**: Todas as funcionalidades estão disponíveis na tela inicial
2. **Notificações**: Habilite as notificações nas configurações do Android
3. **Backup de Dados**: Os dados são armazenados localmente; faça backup regularmente

## 👨‍💻 Desenvolvido com ❤️ usando Flutter

---

**Versão**: 1.0.0  
**Última Atualização**: Dezembro 2025
