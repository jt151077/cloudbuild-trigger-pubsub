/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */



resource "google_pubsub_topic" "mytopic" {
  name    = "mytopic"
  project = local.project_id
  depends_on = [
    google_project_service.gcp_services
  ]
}

resource "google_cloudbuild_trigger" "pubsub-config-trigger" {
  project     = local.project_id
  location    = local.project_default_region
  name        = "pubsub-trigger"
  description = "acceptance test example pubsub build trigger"

  depends_on = [
    google_project_service.gcp_services,
    google_pubsub_topic.mytopic
  ]

  pubsub_config {
    topic = google_pubsub_topic.mytopic.id
  }

  source_to_build {
    uri       = "https://hashicorp/terraform-provider-google-beta"
    ref       = "refs/heads/main"
    repo_type = "GITHUB"
  }

  git_file_source {
    path      = "cloudbuild.yaml"
    uri       = "https://hashicorp/terraform-provider-google-beta"
    revision  = "refs/heads/main"
    repo_type = "GITHUB"
  }

  substitutions = {
    _ACTION = "$(body.message.data.action)"
  }

  filter = "_ACTION.matches('INSERT')"
}

resource "google_pubsub_subscription" "pubsub-config-trigger" {
  project = local.project_id
  name    = "gcb-pubsub-trigger"
  topic   = google_pubsub_topic.mytopic.name

  push_config {
    push_endpoint = "rpc://name:CloudBuildPushEndpoint:gslb:google.pubsub.v1.cloudbuildpushendpoint-prod-${local.project_default_region}"
  }

  expiration_policy {
    ttl = ""
  }
}
