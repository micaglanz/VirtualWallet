<h1 id="title">VirtualWallet [Wallee]</h1>

## 📄 Documentación

- 📘 [Diagrama de clase UML](UML_Wallet_00.png)
- 🎨 [Figma - Design Preview](https://www.figma.com/design/2Qq6lUiSN2v3rzlVPjB7bj/Billetera-Virtual?node-id=0-1&t=MxYwBQJZPj9aqfz8-1)

## 🚀 Cómo comenzar

- Sigue estos pasos para ejecutar el proyecto localmente.

### 1. Clonar el repositorio

```bash
git clone https://github.com/usuario/VirtualWallet.git
cd VirtualWallet
```

### 2. Construye y levanta los servicios

```bash
docker compose build
```
```bash
docker compose up
```

### 3. Crea la base de datos
```bash
docker compose exec app bundle exec rake db:create
```

- El servicio estará inicializado en:

[text](http://localhost:8000)

### 4. Acceder a la consola interactiva de Ruby

- Para probar lógica o ejecutar código manualmente:

```bash
docker compose exec app bundle exec irb -I. -r server.rb
```