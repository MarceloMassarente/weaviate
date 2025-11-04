# syntax=docker/dockerfile:1.6

# 1. COMECE PELA IMAGEM OFICIAL MAIS RECENTE (da documentação)
FROM cr.weaviate.io/semitechnologies/weaviate:1.33.4

# 2. DEFINA AS VARIÁVEIS DE AMBIENTE (da documentação, seção "sem módulos")
#    Esta é a configuração perfeita para o Verba (BYOV).
ENV AUTHENTICATION_ANONYMOUS_ACCESS_ENABLED='true'
ENV PERSISTENCE_DATA_PATH='/var/lib/weaviate'
ENV QUERY_DEFAULTS_LIMIT='25'
ENV CLUSTER_HOSTNAME='node1'
ENV DEFAULT_VECTORIZER_MODULE='none'
ENV ENABLE_MODULES=''

# 3. EXPOR AS PORTAS (da documentação)
EXPOSE 8080
EXPOSE 50051

# O CMD já está na imagem base, conforme a documentação indica.
