FROM runpod/pytorch:2.8.0-py3.11-cuda12.8.1-cudnn-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    WORKDIR=/workspace \
    JUPYTER_PORT=8888 \
    COMFYUI_PORT=8188 \
    JUPYTER_TOKEN=runpod

RUN apt-get update && apt-get install -y --no-install-recommends \
      git git-lfs curl ca-certificates tini \
    && rm -rf /var/lib/apt/lists/* \
    && git lfs install

WORKDIR ${WORKDIR}

RUN pip install --upgrade pip && \
    pip install "jupyterlab>=4,<5" "notebook>=7,<8" jupyterlab-git

# ComfyUI + Manager
RUN git clone https://github.com/comfyanonymous/ComfyUI.git ${WORKDIR}/ComfyUI && \
    pip install -r ${WORKDIR}/ComfyUI/requirements.txt && \
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git \
      ${WORKDIR}/ComfyUI/custom_nodes/ComfyUI-Manager

VOLUME ["${WORKDIR}", "${WORKDIR}/ComfyUI/models", "${WORKDIR}/ComfyUI/output", "${WORKDIR}/ComfyUI/input"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=5 \
  CMD bash -lc "curl -fsS http://127.0.0.1:${JUPYTER_PORT} >/dev/null || curl -fsS http://127.0.0.1:${COMFYUI_PORT} >/dev/null"

COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 8888 8188
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/usr/local/bin/start.sh"]
