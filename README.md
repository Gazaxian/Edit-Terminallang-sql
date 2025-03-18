# Edit Terminallang (SQlite)

Edit Terminallang-sql é um complemento para o Terminallang na versão SQLite, permitindo editar, excluir e listar frases armazenadas no banco de dados de forma simples e intuitiva diretamente pelo terminal.

Este script facilita a gestão das frases cadastradas, permitindo modificações sem precisar abrir um editor de banco de dados.

## Funcionalidades

- 📝 **Listar frases**: Exibe todas as frases armazenadas com paginação para facilitar a navegação.
- 🔄 **Editar frases**: Permite modificar frases existentes no banco de dados.
- ❌ **Excluir frases**: Remova frases indesejadas de forma fácil.
- 🏢 **Interface colorida**: Uso de cores para melhor visualização e usabilidade.

## Como Usar

### 1. Listar Frases
Ao executar o script, você pode listar todas as frases salvas com paginação:
```bash
./edit_terminallang.sh
```
Navegue entre as páginas usando as opções exibidas no terminal.

### 2. Editar uma Frase
Escolha uma frase pelo ID e edite seu conteúdo diretamente no terminal.

### 3. Excluir uma Frase
Escolha uma frase pelo ID e remova-a do banco de dados.

## Requisitos

- Linux, macOS ou Windows com suporte a Bash
- SQLite3 instalado no sistema
- Terminallang (versão SQLite) já configurado

## Como Instalar e Executar

1. Clone o repositório:
   ```bash
   git clone https://github.com/Gazaxian/edit_terminallang.git
   ```
2. Dê permissão de execução ao script:
   ```bash
   chmod +x edit_terminallang-sql.sh
   ```
3. Execute o script:
   ```bash
   ./edit_terminallang-sql.sh
   ```

## Personalização
O script está configurado para acessar o banco de dados em `~/frases.db`. Caso deseje alterar, edite a variável `DB_FILE` no início do script.

## Licença
Este projeto está licenciado sob a MIT License - veja o arquivo LICENSE para mais detalhes.
