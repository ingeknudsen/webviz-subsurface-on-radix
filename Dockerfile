FROM webviz/base_image:latest

COPY --chown=appuser . dash_app
RUN mv ./dash_app/hack/blob_storage/ ./dash_app/blob_storage && \
    mv ./dash_app/hack/setup.py ./dash_app/setup.py

RUN pip install dash_app/. && \
    pip install azure-storage-blob && \
    pip install libecl --upgrade

RUN pip list

CMD gunicorn \
    --access-logfile "-" \
    --bind 0.0.0.0:5000 \
    --keep-alive 120 \        
    --max-requests 40 \
    --preload \
    --workers 10 \
    --worker-class gthread \
    --worker-tmp-dir /dev/shm \        
    --threads 4 \
    --timeout 100000 \
    "dash_app.webviz_app:server"