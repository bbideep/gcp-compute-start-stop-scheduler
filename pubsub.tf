resource "google_pubsub_topic" "compute-scheduler-topic" {
  name = "compute-scheduler-topic"
}

resource "google_cloud_scheduler_job" "compute-start-scheduler-job" {
  name = "compute-start-scheduler-job"
  description = "Job to start compute VMs"
  schedule = "${var.start_schedule}"
  pubsub_target {
    topic_name = "${google_pubsub_topic.compute-scheduler-topic.id}"
    data = "${base64encode(jsonencode({"start_schedule"="${var.start_schedule}","tz"="${var.time_zone}"}))}"
  }
}

resource "google_cloud_scheduler_job" "compute-stop-scheduler-job" {
  name = "compute-stop-scheduler-job"
  description = "Job to stop compute VMs"
  schedule = "${var.stop_schedule}"
  pubsub_target {
    topic_name = "${google_pubsub_topic.compute-scheduler-topic.id}"
    data = "${base64encode(jsonencode({"stop_schedule"="${var.stop_schedule}","tz"="${var.time_zone}"}))}"
  }
}
