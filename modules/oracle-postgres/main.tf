resource "oci_core_instance" "postgres_instance" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_id
  #   shape               = "VM.Standard.A1.Flex"
  shape = "VM.Standard.E2.1.Micro"

  #   shape_config {
  #     memory_in_gbs = 24
  #     ocpus         = 4
  #   }

  source_details {
    source_id   = var.ubuntu_image_id
    source_type = "image"
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.postgres_subnet.id
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
    user_data = base64encode(templatefile("${path.module}/templates/cloud-init.yaml", {
      docker_compose_content = file("${path.module}/files/docker-compose.yml")
      postgres_user          = var.postgres_user
      postgres_password      = var.postgres_password
      postgres_db            = var.postgres_db
    }))
  }
}

resource "oci_core_vcn" "postgres_vcn" {
  compartment_id = var.compartment_id
  cidr_block     = "10.0.0.0/16"
  display_name   = "postgres-vcn"
}

resource "oci_core_subnet" "postgres_subnet" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.postgres_vcn.id
  cidr_block     = "10.0.1.0/24"

  # security list 연결
  security_list_ids = [oci_core_security_list.postgres_security_list.id]

  # 서브넷 이름 추가
  display_name = "postgres-subnet"

  # DHCP options와 route table은 VCN의 기본값 사용
  route_table_id  = oci_core_vcn.postgres_vcn.default_route_table_id
  dhcp_options_id = oci_core_vcn.postgres_vcn.default_dhcp_options_id
}

resource "oci_core_security_list" "postgres_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.postgres_vcn.id
  display_name   = "postgres-security-list"

  # 인바운드 규칙 (기존)
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 5432
      max = 5432
    }
  }

  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }

  # 아웃바운드 규칙 추가
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}

data "oci_identity_availability_domain" "ad" {
  compartment_id = var.compartment_id
  ad_number      = 1
}

# 블록 볼륨 생성
resource "oci_core_volume" "postgres_volume" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_id
  display_name        = "postgres-volume"
  size_in_gbs         = 150
}

# 블록 볼륨 attachment
resource "oci_core_volume_attachment" "postgres_volume_attachment" {
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.postgres_instance.id
  volume_id       = oci_core_volume.postgres_volume.id
}

# 인터넷 게이트웨이 추가
resource "oci_core_internet_gateway" "postgres_igw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.postgres_vcn.id
  display_name   = "postgres-igw"
}

# 기본 라우트 테이블 규칙 추가
resource "oci_core_default_route_table" "postgres_route_table" {
  manage_default_resource_id = oci_core_vcn.postgres_vcn.default_route_table_id

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.postgres_igw.id
  }
}
