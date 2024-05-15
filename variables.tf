variable "oracle_api_key_fingerprint" {
  type        = string
  description = "The fingerprint of the public key"
}

variable "oracle_api_private_key_path" {
  type        = string
  description = "The path to the private key"
  default     = "~/.oci/oci_api_key.pem"
}

variable "ssh_public_key" {
  type        = string
  description = "The public key to use for SSH access"
}

variable "additional_ssh_public_key" {
  type        = string
  description = "Additional public key to use for SSH access example: <<EOF > /home/ubuntu/.ssh/authorized_keys ssh-rsa AAAAB3NzaC1yc2EAA EOF"
  default     = ""
}

variable "compartment_ocid" {
  type        = string
  description = "The OCID of the compartment"
}

variable "tenancy_ocid" {
  type        = string
  description = "The OCID of the tenancy"
}

variable "user_ocid" {
  type        = string
  description = "The OCID of the user to use for authentication"
}

variable "region" {
  type        = string
  description = "The region to deploy to"
  default     = "eu-milan-1"
}

variable "instance_display_name" {
  type        = string
  description = "The display name of the instance"
  default     = "DockerHost"
}

variable "vcn_cidr_block" {
  type        = string
  description = "The CIDR block for the VCN"
  default     = "10.1.0.0/16"
}

variable "availability_domain_number" {
  type        = number
  description = "The availability domain number"
  default     = 1
}

variable "instance_shape" {
  type        = string
  description = "The shape of the instance"
  default     = "VM.Standard.A1.Flex"
}
variable "instance_shape_config_memory_in_gbs" {
  type        = string
  description = "The amount of memory in GBs for the instance"
  default     = "24"
}
variable "instance_shape_config_ocpus" {
  type        = string
  description = "The number of OCPUs for the instance"
  default     = "4"
}

variable "instance_shape_boot_volume_size_in_gbs" {
  type        = string
  description = "The size of the boot volume in GBs"
  default     = "50"
}

variable "instance_shape_docker_volume_size_in_gbs" {
  type        = string
  description = "The size of the docker volume in GBs"
  default     = "150"
}

variable "instance_image_ocid" {
  type        = map(any)
  description = "The OCID of the image to use for the instance"
  default = {
    # See https://docs.oracle.com/en-us/iaas/images/image/d6c24c39-00c1-4ba9-bc0e-b4acf4a6c560/
    # Oracle-provided image "Canonical-Ubuntu-22.04-Minimal-aarch64-2024.03.18-0"
    af-johannesburg-1 = "ocid1.image.oc1.af-johannesburg-1.aaaaaaaayatt2q3wf65wyaey7soibfye7ilnguxfw2m37xspz2dvnk66avha"
    ap-chuncheon-1    = "ocid1.image.oc1.ap-chuncheon-1.aaaaaaaatrfzu3rtfs4clvu3d3lcx3w47dhfwley334h2e4kibgkguof2jbq"
    ap-hyderabad-1    = "ocid1.image.oc1.ap-hyderabad-1.aaaaaaaazws25hclevz2gawql32qjxy47t3qm267pki6a7dovu5s5zec5cuq"
    ap-melbourne-1    = "ocid1.image.oc1.ap-melbourne-1.aaaaaaaaxdac5qbdmi7kjgurknuoxnw6gopfcf63liqljjh5tt24fpd4j7aa"
    ap-mumbai-1       = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaavldnviyso3bjs4ppc6vnvkxhm6cwrd25qxioxvlgfdvuhiolqn3q"
    ap-osaka-1        = "ocid1.image.oc1.ap-osaka-1.aaaaaaaanafsjeu6sgbgtcs2unflym5b3ayetwyig3fjav5ld44qkosv4yxq"
    ap-seoul-1        = "ocid1.image.oc1.ap-seoul-1.aaaaaaaaaogjhvie4g6lnuaqnedzrnqsyoejaisp2ri4pkifofw3gbfx2fsq"
    ap-singapore-1    = "ocid1.image.oc1.ap-singapore-1.aaaaaaaamxlszcgvwvzrknu5b6ajifilcz2g5rdnxzunpqm2tuy5pu5iqf5q"
    ap-sydney-1       = "ocid1.image.oc1.ap-sydney-1.aaaaaaaaifa7kduccxfitcylxubkht7cdhl63obna2bkduk6zkvhymbfnxka"
    ap-tokyo-1        = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaat7tma2qo5x5ceupmsak7w3qj5pq73ir67b45l7su7y3xltym3eoq"
    ca-montreal-1     = "ocid1.image.oc1.ca-montreal-1.aaaaaaaapk2rls5h5v3mtyvtglhq2zglh4a3yyrufz2rdxtspihe6pq4j6va"
    ca-toronto-1      = "ocid1.image.oc1.ca-toronto-1.aaaaaaaa24sdg3g3jhzk4xbbzq66lfkw65iuuhsg4rg5vmi5oq6tx2pw2pja"
    eu-amsterdam-1    = "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaa2thbdtvsvy477jexghizqta2ncgjpb63yc32cir7ecjo4o2qcf5q"
    eu-frankfurt-1    = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaauowdt3masemltfslfv7rp67e6i4ple7t4u6ygyt5k6ub3vduusiq"
    eu-madrid-1       = "ocid1.image.oc1.eu-madrid-1.aaaaaaaaopqz7l22adkrh32xle75d367u5le4cbcalenqssee7kpzek2zera"
    eu-marseille-1    = "ocid1.image.oc1.eu-marseille-1.aaaaaaaat6vsgurqc3yqmc6frh3v3fkgos6ftjsdvzbewxz33sd22fnnucca"
    eu-milan-1        = "ocid1.image.oc1.eu-milan-1.aaaaaaaayqlb7nqz3gdno4paz3h2qqxkyf4zzfttjnoh4ij2kpcg4467y2ea"
    eu-paris-1        = "ocid1.image.oc1.eu-paris-1.aaaaaaaaxvkt7p62m5gwoeffjeocdy26mxdosapdhtld7nxfogc4spooa2sq"
    eu-stockholm-1    = "ocid1.image.oc1.eu-stockholm-1.aaaaaaaalifousimc5zr4ypepp6b6bzjqhx5afuulxaqmujuc2voqs5fsn5a"
    eu-zurich-1       = "ocid1.image.oc1.eu-zurich-1.aaaaaaaaxluw6jh3jmpyg5dkpsnpg63wzphzac4cdhgfte2fss7g5gcwihca"
    il-jerusalem-1    = "ocid1.image.oc1.il-jerusalem-1.aaaaaaaapuniww6o33se3sfty6feri6ktxl6brlwwvsegukjcxoinzwi5wvq"
    me-abudhabi-1     = "ocid1.image.oc1.me-abudhabi-1.aaaaaaaa6b2qwjnh7rpzj3meotg55salzwi563hhbmbyks5hf2dezjoyiecq"
    me-dubai-1        = "ocid1.image.oc1.me-dubai-1.aaaaaaaag3hbb5cvalx747wg6dplm2cxjc4fq5uux2xbticnc3vjrqzwhxgq"
    me-jeddah-1       = "ocid1.image.oc1.me-jeddah-1.aaaaaaaamk2h7ilswb472holpkykgtlyqcsgucr7j7o3k6x2em5pbisywjsq"
    mx-queretaro-1    = "ocid1.image.oc1.mx-queretaro-1.aaaaaaaa5ng35ewch32nilgapabou4olvtqxgabpq762p3qx56qy2dwmctaq"
    sa-santiago-1     = "ocid1.image.oc1.sa-santiago-1.aaaaaaaal6gxoyh4gfm2vxaua2464ieilwfth77msu7uemfpkadkkt6mjfka"
    sa-saopaulo-1     = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaaqghurigdiwlf726pmgzlzmbqkgo5inn7k7bx5q4lpqhfjsr6apcq"
    sa-vinhedo-1      = "ocid1.image.oc1.sa-vinhedo-1.aaaaaaaa3b3p5xmkvam7h2km5irockkgrjl7acnntzbi73u6lcdlmdvwob3a"
    uk-cardiff-1      = "ocid1.image.oc1.uk-cardiff-1.aaaaaaaagy2eilwxcrz7y5vyehraeoisdxpg4ub2txsap4q2tn7h3x2uyznq"
    uk-london-1       = "ocid1.image.oc1.uk-london-1.aaaaaaaanqwfiejnlcawmwoa2ku73qghuiumgaiffldgfk5ig7xx4tlfcjua"
    us-ashburn-1      = "ocid1.image.oc1.iad.aaaaaaaaf4tcgubjzoxwaa4xteropz4zidxitlbjcwogcglzxwtspwiv74ha"
    us-chicago-1      = "ocid1.image.oc1.us-chicago-1.aaaaaaaajrmkhokn3hqdlqtevwvcyxh67fknrp5ljo33kp25nci34viblkxq"
    us-phoenix-1      = "ocid1.image.oc1.phx.aaaaaaaafpqctvbk7lcxfztmjxhyfd5pyhixs4h23uzjiddjlxfs6eva57xa"
    us-sanjose-1      = "ocid1.image.oc1.us-sanjose-1.aaaaaaaa54zxwb6ujfbrycebkkmy4tdc7szox3l76l6un7wfjgln4drzcvda"
  }
}
