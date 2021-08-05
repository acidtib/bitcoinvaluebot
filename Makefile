build:
	crystal build -s -p --release -o build/jobs app/jobs.cr

docker.run:
	docker compose up --build

docker.build.prod:
	docker build -t arubinofaux/bvb_services:latest .

docker.build.gcloud:
	gcloud builds submit --tag gcr.io/arubinofaux/bvb_services