import multiprocessing
bind = "0.0.0.0:8080"
workers = max(2, multiprocessing.cpu_count() * 2 + 1)
worker_class = "uvicorn.workers.UvicornWorker"
timeout = 60
graceful_timeout = 30
loglevel = "info"