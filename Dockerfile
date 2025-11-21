# syntax=docker/dockerfile:1.6

# Weaviate 1.33.4 - BYOV Mode (Bring Your Own Vectors)
# Simples, confiável, funciona perfeitamente em Railway
# Sem dependências de módulos complexos

FROM cr.weaviate.io/semitechnologies/weaviate:1.34.0

LABEL maintainer="RAG2 Project"
LABEL description="Weaviate BYOV - Production Ready"

# ============================================================================
# CONFIGURAÇÃO - BYOV MODE
# ============================================================================

# Sem modules - vamos usar BM25 + BYOV
ENV ENABLE_MODULES=""
ENV DEFAULT_VECTORIZER_MODULE="none"

# ============================================================================
# WEAVIATE CORE CONFIG
# ============================================================================

ENV AUTHENTICATION_ANONYMOUS_ACCESS_ENABLED="true"
ENV PERSISTENCE_DATA_PATH="/var/lib/weaviate"
ENV QUERY_DEFAULTS_LIMIT="25"
ENV CLUSTER_HOSTNAME="weaviate-node"
ENV LOG_LEVEL="info"

# ============================================================================
# PERFORMANCE
# ============================================================================

ENV VECTOR_CACHE_MAINTENANCE_IN_MEMORY_PERCENTAGE="70"
ENV INDEXING_GO_MAX_PROCS="0"
ENV GZIP_ENABLED="true"
ENV GZIP_MIN_LENGTH="1024"

# ============================================================================
# SETUP DIRECTORIES
# ============================================================================

RUN mkdir -p /var/lib/weaviate && chmod -R 777 /var/lib/weaviate

# ============================================================================
# HEALTH CHECK
# ============================================================================

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8080/v1/.well-known/ready || exit 1

# ============================================================================
# PORTS
# ============================================================================

EXPOSE 8080
EXPOSE 50051

# ============================================================================
# RUN
# ============================================================================

CMD ["/bin/weaviate", "--host", "0.0.0.0", "--port", "8080", "--scheme", "http"]
