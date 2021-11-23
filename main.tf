##############################################################################
# IBM Cloud Provider
##############################################################################

provider ibm {
  ibmcloud_api_key      = var.ibmcloud_api_key
  region                = var.region
  ibmcloud_timeout      = 60
}

##############################################################################


##############################################################################
# Resource Group where Cluster will be created
##############################################################################

data ibm_resource_group resource_group {
  name = var.resource_group
}

##############################################################################


##############################################################################
# VPC Data
##############################################################################

data ibm_is_vpc vpc {
  name = var.vpc_name
}

data ibm_is_subnet subnet {
  for_each = toset(var.subnets)
  name     = each.key
}

##############################################################################


##############################################################################
# COS Instance Data
##############################################################################

data ibm_resource_instance cos_instance {
  name              = "jv-dev-cos" #var.cos_instance
  resource_group_id = data.ibm_resource_group.resource_group.id
  service           = "cloud-object-storage"
}

##############################################################################


##############################################################################
# Find default version if kube_version is default
##############################################################################

data external default_cluster_version {
  count = var.kube_version == "default" ? 1 : 0
  program = [
    "bash",
    "${path.module}/default_kube_version.sh",
    var.ibmcloud_api_key,
    true
  ]
}

##############################################################################


##############################################################################
# Create IKS on VPC Cluster
##############################################################################

resource ibm_container_vpc_cluster cluster {

  name              = "${var.prefix}-roks-cluster"
  vpc_id            = data.ibm_is_vpc.vpc.id
  resource_group_id = data.ibm_resource_group.resource_group.id
  flavor            = var.machine_type
  worker_count      = var.workers_per_zone
  kube_version      = var.kube_version == "default" ? data.external.default_cluster_version[0].result.default_version : var.kube_version
  tags              = var.tags
  wait_till         = var.wait_till
  entitlement       = var.entitlement
  cos_instance_crn  = data.ibm_resource_instance.cos_instance.crn
  pod_subnet        = var.pod_subnet
  service_subnet    = var.service_subnet

  dynamic zones {
    for_each = [
      for name in keys(data.ibm_is_subnet.subnet):
      data.ibm_is_subnet.subnet[name]
    ]
    content {
      subnet_id = zones.value.id
      name      = zones.value.zone
    }
  }

  disable_public_service_endpoint = true

}

##############################################################################


##############################################################################
# Worker Pools
##############################################################################

module worker_pools {
  source            = "./worker_pools"
  region            = var.region
  worker_pools      = var.worker_pools
  entitlement       = var.entitlement
  vpc_id            = data.ibm_is_vpc.vpc.id
  resource_group_id = data.ibm_resource_group.resource_group.id
  cluster_name_id   = ibm_container_vpc_cluster.cluster.id
  subnets           = [
      for name in keys(data.ibm_is_subnet.subnet):
      data.ibm_is_subnet.subnet[name]
  ]
}

##############################################################################