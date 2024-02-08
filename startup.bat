set PYTHONUNBUFFERED=TRUE
set PYTHONFAULTHANDLER=1

set OPENBLAS_NUM_THREADS=1
set OPENBLAS_MAIN_FREE=1

mkdir -p /logs
python manage.py showmigrations > ./logs/show_migrate.log
python manage.py migrate > ./logs/command_migrate.log
python manage.py showmigrations > ./logs/show_migrate.log
python manage.py collectstatic --no-input
python image_similarity/main.py > ./logs/image_similarity.log &
python service/thumbnail/main.py > ./logs/thumbnail.log &
python service/face_recognition/main.py > ./logs/face_recognition.log &
python service/clip_embeddings/main.py > ./logs/clip_embeddings.log &
python service/image_captioning/main.py > ./logs/image_captioning.log &
#python service/llm/main.py > ./logs/llm.log &
python manage.py clear_cache 
python manage.py build_similarity_index > ./logs/command_build_similarity_index.log

if [[ -n "$ADMIN_USERNAME" ]]; then
    python manage.py createadmin -u "$ADMIN_USERNAME" "$ADMIN_EMAIL" 2>&1 | tee /logs/command_createadmin.log
fi

echo "Running backend server..."

python manage.py qcluster > ./logs/qcluster.log &

if [[ "$DEBUG" = 1 ]]; then
    echo "development backend starting"
    gunicorn --worker-class=gevent --max-requests 50 --reload --bind 0.0.0.0:8001 --log-level=info librephotos.wsgi > ./logs/gunicorn_django.log
else
    echo "production backend starting"
    gunicorn --worker-class=gevent --max-requests 50 --bind 0.0.0.0:8001 --log-level=info librephotos.wsgi > ./logs/gunicorn_django.log
fi
