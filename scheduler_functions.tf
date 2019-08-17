resource "google_storage_bucket" "bucket" {
  name = "scheduler-function-bucket"
}

data "archive_file" "start-vm-function-file" {
  type = "zip"
  output_path = "${path.module}/files/start-vm-function.zip"
  source {
    content  = "${file("${path.module}/files/start-vm.py")}"
    filename = "start-vm.py"
  }
}

data "archive_file" "stop-vm-function-file" {
  type = "zip"
  output_path = "${path.module}/files/stop-vm-function.zip"
  source {
    content = "${file("${path.module}/files/stop-vm.py")}"
    filename = "stop-vm.py"
  }
}
resource "google_storage_bucket_object" "start-vm-func-archive" {
  name   = "start-vm-function.zip"
  bucket = "${google_storage_bucket.bucket.name}"
  source = "${path.module}/files/start-vm-function.zip"
  depends_on = ["data.archive_file.start-vm-function-file"]
}

resource "google_storage_bucket_object" "stop-vm-func-archive" {
  name = "stop-vm-function.zip"
  bucket = "${google_storage_bucket.bucket.name}"
  source = "${path.module}/files/stop-vm-function.zip"
  depends_on = ["data.archive_file.stop-vm-function-file"]
}

resource "google_cloudfunctions_function" "start-vm-function" {
  name                  = "compute-start-function"
  description           = "cloud function to start compute VMs at scheduled time"
  runtime               = "python37"

  available_memory_mb   = 128
  source_archive_bucket = "${google_storage_bucket.bucket.name}"
  source_archive_object = "${google_storage_bucket_object.start-vm-func-archive.name}"
  event_trigger	{
    event_type = "google.pubsub.topic.publish"
    resource = "${google_pubsub_topic.compute-scheduler-topic.name}"
  }
#  trigger_http          = true 
  timeout               = 60
  entry_point           = "start_vm"
  environment_variables = {
    START_SCHEDULE = "${var.start_schedule}"
    TIMEZONE = "${var.time_zone}"
    FILTER_DATA = "${var.start_filter_data}"
  }
}

resource "google_cloudfunctions_function" "stop-vm-function" {
  name			= "compute-stop-function"
  description		= "cloud function to stop compute VMs at scheduled time"
  runtime		= "python37"
  available_memory_mb	= 128
  source_archive_bucket = "${google_storage_bucket.bucket.name}"
  source_archive_object = "${google_storage_bucket_object.stop-vm-func-archive.name}"
  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource = "${google_pubsub_topic.compute-scheduler-topic.name}"
  }
  timeout		= 60
  entry_point		= "stop_vm"
  environment_variables = {
    START_SCHEDULE  = "${var.stop_schedule}"
    TIMEZONE = "${var.time_zone}"
    FILTER_DATA = "${var.stop_filter_data}"
  }
}
