terraform {
  required_providers {
    #
    # Hashicorp Vault
    #
    # Docs: https://registry.terraform.io/providers/hashicorp/vault/latest/docs
    #
    vault = {
      source = "hashicorp/vault"
      version = "2.24.0"
    }
  }
}

locals {
  ONE_HOUR = 60 * 60

  SIX_HOURS = (60 * 60) * 6

  TWELVE_HOURS = (60 * 60) * 12

  ONE_DAY = (60 * 60) * 24

  ONE_WEEK = ((60 * 60) * 24) * 7

  ONE_MONTH = ((60 * 60) * 24) * 31

  THREE_MONTHS = (((60 * 60) * 24) * 31) * 3

  SIX_MONTHS = (((60 * 60) * 24) * 31) * 6

  ONE_YEAR = ((60 * 60) * 24) * 365

  TWO_YEARS = (((60 * 60) * 24) * 365) * 2

  THREE_YEARS = (((60 * 60) * 24) * 365) * 3
}

resource "random_string" "RootMount" {
  length           = 10

  special = false
  upper = false
}

resource "vault_mount" "RootPKI" {
  path        = random_string.RootMount.result

  #
  #
  #
  type        = "pki"

  description = "PKI for the ROOT CA"
  default_lease_ttl_seconds = local.SIX_MONTHS
  max_lease_ttl_seconds = local.THREE_YEARS
}

resource "vault_pki_secret_backend_root_cert" "RootCA" {
  depends_on = [
    vault_mount.RootPKI 
  ]

  backend = vault_mount.RootPKI.path

  type = "internal"

  common_name = "Root CA"
  ttl = local.THREE_YEARS

  #
  # Formats
  #  
  
  #
  # Vault Docs: https://www.vaultproject.io/api/secret/pki#format-2
  # 
  format = "pem"

  #
  # Vault Docs: https://www.vaultproject.io/api/secret/pki#private_key_format-2
  #
  private_key_format = "der"

  #
  # Vault Docs: https://www.vaultproject.io/api/secret/pki#key_type-2
  #
  key_type = "ec"

  #
  # Vault Docs: https://www.vaultproject.io/api/secret/pki#key_bits-2
  #
  key_bits = 384
}