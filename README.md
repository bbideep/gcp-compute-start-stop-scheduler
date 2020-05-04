# gcp-compute-start-stop-scheduler

Google Cloud Compute start stop Cloud Functions (Python 3.7). This Terraform code does the following -

* Creates a Cloud Storage bucket.
* Packages the cloud function code to zip files.
* Uploads the zip files to the Cloud Storage bucket.
* Create Cloud PubSub Topic and jobs to trigger the Cloud Functions

Following inputs are provided through the terraform variables:
* Filter criteria to target a set of compute VMs. Refer [GCP documentation](https://cloud.google.com/sdk/gcloud/reference/topic/filters) for the syntax.
* Start and Stop schedules (cron expression)


PREREQUISITES:

* Service Account needs to be created/enabled to interact with the required APIs (Compute, Cloud Frunctions, Cloud Scheduler, PubSub)

TODOs:

* Some additional error handling
