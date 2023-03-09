exec gcloud compute --project pict-app ssh --zone us-central1-a webapp-development-cary -- -NL 3000:localhost:3000 -NL 8000:localhost:8000
