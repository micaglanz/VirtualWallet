FROM ruby:3.2.2-alpine

# Define variables de entorno para Bundler:
ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_APP_CONFIG=/usr/local/bundle/config \
    RAILS_ENV=development

# Instalar dependencias necesarias y herramientas de Alpine
RUN apk add --no-cache \
    bash \
    sqlite \
    build-base \
    libxml2-dev \
    libxslt-dev \
    git \
    curl

# Definir directorio de trabajo
WORKDIR /app

# Copiar solo los archivos necesarios para instalar gems y aprovechar cache:
COPY Gemfile Gemfile.lock ./

# Instalar gems (esto queda cacheado a menos que cambie Gemfile/Gemfile.lock)
RUN bundle install

# Copiar el resto del código
COPY . .

# Crear la base de datos y las tablas si es necesario (si no está hecha)
RUN bundle install

# Exponer el puerto de la app
EXPOSE 8000

# Define el comando predeterminado para iniciar el contenedor:
# - bundle exec: Ejecuta comandos en el contexto de las gemas instaladas.
# - rackup: Inicia el servidor Rack.
# - -o 0.0.0.0: Escucha en todas las interfaces de red.
# - -p 8000: Usa el puerto 8000.
# Busca automáticamente config.ru para iniciar la aplicación.

CMD ["bundle", "exec", "rackup", "-o", "0.0.0.0", "-p", "8000"]
