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

WORKDIR /app

# Copiar solo los archivos necesarios para instalar gems y aprovechar cache:
COPY Gemfile Gemfile.lock ./

# Instalar gems (esto queda cacheado a menos que cambie Gemfile/Gemfile.lock)
RUN bundle install

# Copiar el resto del código
COPY . .

# Puerto por defecto para rackup
EXPOSE 8000

CMD ["bundle", "exec", "rackup", "-o", "0.0.0.0", "-p", "8000"]
