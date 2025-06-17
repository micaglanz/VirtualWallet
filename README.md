<h1 id="title">VirtualWallet [Wallee]</h1>

## 📄 Documentación

- 📘 [Diagrama de clase UML]
    [V1](UML-VirtualWallet.png)
    [V2](SVGWallet_V2.jpg)
- 🎨 [Figma - Design Preview](https://www.figma.com/design/2Qq6lUiSN2v3rzlVPjB7bj/Billetera-Virtual?node-id=0-1&t=MxYwBQJZPj9aqfz8-1)

## 🚀 Cómo comenzar

- Sigue estos pasos para ejecutar el proyecto localmente.

### 1. Clonar el repositorio

```bash
git clone https://github.com/usuario/VirtualWallet.git
cd app
```

### 2. Construye y levanta los servicios

- Si ya tenes uno corriendo

```bash
docker-compose down
```

- Sino, segui desde estos pasos

```bash
docker-compose build
```
- Levanta el contenedor (quita el argumento -d para ver la interaccion de la pagina con el software)

```bash
docker-compose up -d
```
- Hace una migracion para crear una DB

```bash
docker compose exec app bundle exec rake db:migrate db:seed
```

- Si no es la primera ves que hacer la migracion y la carga del seed

```bash
docker compose exec app bundle exec rake db:migrate db:reset
```

- El servicio estará inicializado en:

(http://localhost:8000)

### 4. Acceder a la consola interactiva de Ruby

- Para probar lógica o ejecutar código manualmente:

```bash
docker compose exec app bundle exec irb -I. -r app.rb
```