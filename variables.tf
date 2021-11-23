##############################################################################
# Account variables
##############################################################################

variable ibmcloud_api_key {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources"
  type        = string
  sensitive   = true
}

# Comment out if not running in schematics
variable TF_VERSION {
 default     = "1.0"
 description = "The version of the Terraform engine that's used in the Schematics workspace."
}

variable prefix {
    description = "A unique identifier need to provision resources. Must begin with a letter"
    type        = string
    default     = "asset-roks"

    validation  {
      error_message = "Unique ID must begin and end with a letter and contain only letters, numbers, and - characters."
      condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.prefix))
    }
}

variable region {
    description = "IBM Cloud region where all resources will be deployed"
    type        = string
}

variable resource_group {
    description = "Name of resource group where all infrastructure will be provisioned"
    type        = string
    default     = "asset-development"

    validation  {
      error_message = "Unique ID must begin and end with a letter and contain only letters, numbers, and - characters."
      condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.resource_group))
    }
}

##############################################################################


##############################################################################
# VPC Variables
##############################################################################

variable vpc_name {
    description = "Name of VPC where cluster is to be created"
    type        = string
}

variable subnets {
    description = "A list of subnet IDs where the cluster will be created"
    type        = list(string)
}

##############################################################################


##############################################################################
# Cluster Variables
##############################################################################

variable cos_instance {
  description = "Name of the COS Instnance for the cluster to use"
  type        = string
}

variable machine_type {
    description = "The flavor of VPC worker node to use for your cluster. Use `ibmcloud ks flavors` to find flavors for a region."
    type        = string
    default     = "bx2.4x16"
}

variable workers_per_zone {
    description = "Number of workers to provision in each subnet"
    type        = number
    default     = 2

    validation {
        error_message = "Each zone must contain at least 2 workers."
        condition     = var.workers_per_zone >= 2
    }
}

variable entitlement {
    description = "If you purchased an IBM Cloud Cloud Pak that includes an entitlement to run worker nodes that are installed with OpenShift Container Platform, enter entitlement to create your cluster with that entitlement so that you are not charged twice for the OpenShift license. Note that this option can be set only when you create the cluster. After the cluster is created, the cost for the OpenShift license occurred and you cannot disable this charge."
    type        = string
    default     = "cloud_pak"
}

variable kube_version {
    description = "Specify the Kubernetes version, including the major.minor version. To see available versions, run `ibmcloud ks versions`. To use the default version, leave as `default`."
    type        = string
    default     = "default"
}

variable pod_subnet {
    description = "pecify a custom subnet CIDR to provide private IP addresses for pods. The subnet must have a CIDR of at least /23 or larger."
    type        = string
    default     = "172.30.0.0/16"
}

variable service_subnet {
    description = "Specify a custom subnet CIDR to provide private IP addresses for services. The subnet must be at least ’/24’ or larger."
    type        = string
    default     = "172.21.0.0/16"
}


variable wait_till {
    description = "To avoid long wait times when you run your Terraform code, you can specify the stage when you want Terraform to mark the cluster resource creation as completed. Depending on what stage you choose, the cluster creation might not be fully completed and continues to run in the background. However, your Terraform code can continue to run without waiting for the cluster to be fully created. Supported args are `MasterNodeReady`, `OneWorkerNodeReady`, and `IngressReady`"
    type        = string
    default     = "IngressReady"

    validation {
        error_message = "`wait_till` value must be one of `MasterNodeReady`, `OneWorkerNodeReady`, or `IngressReady`."
        condition     = contains([
            "MasterNodeReady",
            "OneWorkerNodeReady",
            "IngressReady"
        ], var.wait_till)
    }
}

variable tags {
    description = "A list of tags to add to the cluster"
    type        = list(string)
    default     = []

    validation  {
        error_message = "Tags must match the regex `^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$`."
        condition     = length([
            for name in var.tags:
            false if !can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", name))
        ]) == 0
    }
}

variable worker_pools {
    description = "List of maps describing worker pools"

    type        = list(object({
        name        = string
        machine_type     = string
        workers_per_zone = number
    }))

    default     = []

    validation  {
        error_message = "Worker pool names must match the regex `^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$`."
        condition     = length([
            for pool in var.worker_pools:
            false if !can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", pool.name))
        ]) == 0
    }

    validation {
        error_message = "Worker pools cannot have duplicate names."
        condition     = length(distinct([
            for pool in var.worker_pools:
            pool.name
        ])) == length(var.worker_pools)
    }

    validation {
        error_message = "Worker pools must have at least two workers per zone."
        condition     = length([
            for pool in var.worker_pools:
            false if pool.workers_per_zone < 2
        ]) == 0
    }

}

##############################################################################


##############################################################################
# Resource Variables
##############################################################################

variable cos_id {
    description = "ID of COS instance"
    type        = string
    default     = null
}

variable kms_guid {
    description = "GUID of Key Protect Instance"
    type        = string
    default     = null
}

variable key_id {
    description = "GUID of User Managed Key"
    type        = string
    default     = null
}

##############################################################################