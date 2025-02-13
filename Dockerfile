FROM python:3.13-slim-bookworm AS python-base

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_DEFAULT_TIMEOUT=100 \
    PYSETUP_PATH="/usr/src/app" \
    UV_VERSION="0.5.29"

ENV VENV_PATH="$PYSETUP_PATH/.venv"
ENV PATH="$VENV_PATH/bin:$PATH"

FROM python-base AS builder

RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc git \
    && rm -rf /var/lib/apt/lists/

WORKDIR $PYSETUP_PATH

RUN pip install --no-cache-dir uv==$UV_VERSION

COPY ./pyproject.toml ./uv.lock ./
RUN uv venv -p 3.13 \
    && uv sync --all-extras --no-install-project
COPY ./src ./src
RUN uv sync --all-extras --no-editable

FROM python-base AS runner

COPY --from=builder $VENV_PATH $VENV_PATH

CMD ["python", "-Om", "pyapp"]
