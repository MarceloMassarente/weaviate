# syntax=docker/dockerfile:1.6

# Weaviate 1.33.4 com text2vec-transformers OTIMIZADO
# Melhor qualidade vetorial + Performance produção
# Suporte multilíngue (PT, EN, ES, FR, etc)

FROM cr.weaviate.io/semitechnologies/weaviate:1.33.4

# ============================================================================
# METADADOS
# ============================================================================

LABEL maintainer="RAG2 Project"
LABEL description="Weaviate 1.33.4 com text2vec-transformers - OTIMIZADO PARA PRODUÇÃO"
LABEL version="1.0"

# ============================================================================
# MÓDULOS - ATIVAR TEXT2VEC-TRANSFORMERS
# ============================================================================

# Habilitar módulo de transformers
ENV ENABLE_MODULES="text2vec-transformers"

# Usar transformers como vectorizer padrão
ENV DEFAULT_VECTORIZER_MODULE="text2vec-transformers"

# ============================================================================
# TRANSFORMERS - CONFIGURAÇÃO AVANÇADA
# ============================================================================

# Deixar vazio = usa transformers local com cache
# Assim que fizer primeira query, baixa modelo e cacheia
ENV TRANSFORMERS_INFERENCE_API_URL=""

# Diretório de cache para modelos transformers
ENV TRANSFORMERS_CACHE_DIR="/var/lib/weaviate/models"

# Modelo padrão: multilingual-e5-base (excelente para PT, EN, ES, etc)
# Alternativas:
#   - sentence-transformers/multilingual-e5-large (melhor qualidade, +memória)
#   - sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2 (rápido, leve)
#   - intfloat/multilingual-e5-small (muito leve, dev/testes)
ENV TRANSFORMERS_MODEL="sentence-transformers/multilingual-e5-base"

# ============================================================================
# WEAVIATE - CONFIGURAÇÃO GERAL
# ============================================================================

# Autenticação (desabilitada para dev/teste, habilitar em produção)
ENV AUTHENTICATION_ANONYMOUS_ACCESS_ENABLED="true"

# Persistência
ENV PERSISTENCE_DATA_PATH="/var/lib/weaviate"

# Limites de query
ENV QUERY_DEFAULTS_LIMIT="25"

# Cluster (single node)
ENV CLUSTER_HOSTNAME="weaviate-node"

# ============================================================================
# PERFORMANCE - OTIMIZAÇÕES
# ============================================================================

# Logging nível info
ENV LOG_LEVEL="info"

# Usar toda memória/CPU disponível (não limitar)
# Comentar a linha abaixo para limitar recursos:
# ENV LIMIT_RESOURCES="true"

# Cache vetorial em memória
ENV VECTOR_CACHE_MAINTENANCE_IN_MEMORY_PERCENTAGE="70"

# Número de goroutines para indexação (0 = usar todos os cores)
ENV INDEXING_GO_MAX_PROCS="0"

# ============================================================================
# GZIP - COMPRIMIR RESPONSES
# ============================================================================

# Habilitar compressão GZIP para respostas
ENV GZIP_ENABLED="true"

# Tamanho mínimo em bytes para comprimir
ENV GZIP_MIN_LENGTH="1024"

# ============================================================================
# DIRETÓRIOS E PERMISSÕES
# ============================================================================

RUN mkdir -p /var/lib/weaviate/models && \
    mkdir -p /var/lib/weaviate/backups && \
    chmod -R 777 /var/lib/weaviate && \
    chmod -R 777 /var/lib/weaviate/models

# ============================================================================
# HEALTH CHECK - VERIFICAÇÃO DE SAÚDE
# ============================================================================

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/v1/.well-known/ready || exit 1

# ============================================================================
# VOLUMES - PERSISTÊNCIA
# ============================================================================

VOLUME ["/var/lib/weaviate"]
VOLUME ["/var/lib/weaviate/models"]
VOLUME ["/var/lib/weaviate/backups"]

# ============================================================================
# PORTAS
# ============================================================================

EXPOSE 8080
EXPOSE 50051

# ============================================================================
# INICIALIZAÇÃO
# ============================================================================

CMD ["/bin/weaviate", "--host", "0.0.0.0", "--port", "8080", "--scheme", "http"]

# ============================================================================
# NOTAS DE PRODUÇÃO
# ============================================================================

# 1. MODELOS RECOMENDADOS (por qualidade):
#    - sentence-transformers/multilingual-e5-large: ⭐⭐⭐⭐⭐ (1.2GB, melhor)
#    - sentence-transformers/multilingual-e5-base: ⭐⭐⭐⭐ (438MB, recomendado)
#    - sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2: ⭐⭐⭐ (135MB, rápido)

# 2. PRIMEIRA EXECUÇÃO:
#    - Levará 5-10 min na primeira query (download do modelo)
#    - Depois disso, será rápido (~200-500ms por query)

# 3. MEMÓRIA RECOMENDADA:
#    - e5-base: mínimo 4GB, ideal 8GB
#    - e5-large: mínimo 8GB, ideal 16GB

# 4. STORAGE:
#    - Models: ~500MB-1.5GB (dependendo do modelo)
#    - Data: varia com quantidade de documentos

# 5. PERFORMANCE:
#    - BM25 queries: 50-150ms
#    - Semantic search (hybrid): 200-800ms
#    - Batch insert: 1000-5000 docs/seg
