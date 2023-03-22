provider "azurerm" {
  features {}
}

# Define variables
variable "location" {
  default = "northeurope"
}

# Define resource groups for each environment
resource "azurerm_resource_group" "dev_rg" {
  name     = "dev-rg"
  location = var.location
}

resource "azurerm_resource_group" "qa_rg" {
  name     = "qa-rg"
  location = var.location
}

resource "azurerm_resource_group" "prod_rg" {
  name     = "prod-rg"
  location = var.location
}

# Define virtual networks for each environment
resource "azurerm_virtual_network" "dev_vnet" {
  name                = "dev-vnet"
  location            = azurerm_resource_group.dev_rg.location
  resource_group_name = azurerm_resource_group.dev_rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_virtual_network" "qa_vnet" {
  name                = "qa-vnet"
  location            = azurerm_resource_group.qa_rg.location
  resource_group_name = azurerm_resource_group.qa_rg.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_virtual_network" "prod_vnet" {
  name                = "prod-vnet"
  location            = azurerm_resource_group.prod_rg.location
  resource_group_name = azurerm_resource_group.prod_rg.name
  address_space       = ["10.2.0.0/16"]
}

# Define network security groups for each environment
resource "azurerm_network_security_group" "dev_nsg" {
  name                = "dev-nsg"
  location            = azurerm_resource_group.dev_rg.location
  resource_group_name = azurerm_resource_group.dev_rg.name

  security_rule {
    name                       = "block-internet-access"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "qa_nsg" {
  name                = "qa-nsg"
  location            = azurerm_resource_group.qa_rg.location
  resource_group_name = azurerm_resource_group.qa_rg.name

  security_rule {
    name                       = "block-internet-access"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "prod_nsg" {
  name                = "prod-nsg"
  location            = azurerm_resource_group.prod_rg.location
  resource_group_name = azurerm_resource_group.prod_rg.name

  security_rule {
    name                       = "block-internet-access"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

# Define storage accounts
#Define load balancer for production environment
resource "azurerm_lb" "prod_lb" {
name = "prod-lb"
location = azurerm_resource_group.prod_rg.location
resource_group_name = azurerm_resource_group.prod_rg.name

frontend_ip_configuration {
name = "prod-lb-frontend"
subnet_id = azurerm_subnet.prod_subnet.id
public_ip_address_id = azurerm_public_ip.prod_pip.id
private_ip_address_allocation = "Dynamic"
}

backend_address_pool {
name = "prod-lb-backend"
}

probe {
name = "http-probe"
protocol = "Http"
request_path = "/"
port = 80
interval = 30
unhealthy_threshold = 3
pass = 2
}

rule {
name = "http-rule"
protocol = "Tcp"
frontend_port = 80
backend_port = 80
backend_address_pool_id = azurerm_lb_backend_address_pool.prod_bap.id
probe_id = azurerm_lb_probe.http.id
}
}

#Define load balancer backend address pool for production environment
resource "azurerm_lb_backend_address_pool" "prod_bap" {
name = "prod-lb-backend"
load_balancer_id = azurerm_lb.prod_lb.id
}

#Define load balancer probes for production environment
resource "azurerm_lb_probe" "http" {
name = "http-probe"
resource_group_name = azurerm_resource_group.prod_rg.name
load_balancer_id = azurerm_lb.prod_lb.id
protocol = "http"
port = 80
request_path = "/"
interval = 30
unhealthy_threshold = 3
}

#Define virtual machine scale set for production environment
resource "azurerm_linux_virtual_machine_scale_set" "prod_vmss" {
name = "prod-vmss"
location = azurerm_resource_group.prod_rg.location
resource_group_name = azurerm_resource_group.prod_rg.name

sku {
name = "Standard_DS1_v2"
tier = "Standard"
capacity = 2
}

storage_image_reference {
publisher = "Canonical"
offer = "UbuntuServer"
sku = "16.04-LTS"
version = "latest"
}

os_disk {
name = "prod-vmss-osdisk"
caching = "ReadWrite"
storage_account_type = "Standard_LRS"
}

upgrade_policy_mode = "Manual"

network_interface {
name = "prod-vmss-nic"
primary = true
network_security_group_id = azurerm_network_security_group.prod_nsg.id


ip_configuration {
  name                          = "prod-ip-config"
  subnet_id                     = azurerm_subnet.prod_subnet.id
  load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.prod_bap.id]
  load_balancer_inbound_nat_rules_ids    = []
  application_gateway_backend_address_pool_ids = []
  application_security_group_ids = []
  public_ip_address_id          = azurerm_public_ip.prod_pip.id
}
}

depends_on = [
azurerm_lb_backend_address_pool.prod_bap,
azurerm_public_ip.prod_pip
]
}

#Define availability sets for each environment
resource "azurerm_availability_set" "dev_as" {
name = "dev-as"
location = azurerm_resource_group.dev_rg.location
resource_group_name = azurerm_resource_group.dev_rg.name
}

resource "azurerm_availability_set" "qa_as" {
name = "qa-as"
location = azurerm_resource_group.qa_rg.location
resource_group_name = azurerm_resource_group.qa_rg.name
}

resource "azurerm_availability_set" "prod_as" {
name = "prod-as"
location = azurerm_resource_group.prod_rg.location
resource_group_name = azurerm_resource_group.prod_rg.name
}

#Define load balancers for each environment
resource "azurerm_lb" "dev_lb" {
name = "dev-lb"
location = azurerm_resource_group.dev_rg.location
resource_group_name = azurerm_resource_group.dev_rg.name
sku = "Standard"
frontend_ip_configuration {
name = "dev-fe-ip-config"
public_ip_address_id = azurerm_public_ip.dev_pip.id
private_ip_address_allocation = "Dynamic"
}
}

resource "azurerm_lb" "qa_lb" {
name = "qa-lb"
location = azurerm_resource_group.qa_rg.location
resource_group_name = azurerm_resource_group.qa_rg.name
sku = "Standard"
frontend_ip_configuration {
name = "qa-fe-ip-config"
public_ip_address_id = azurerm_public_ip.qa_pip.id
private_ip_address_allocation = "Dynamic"
}
}

resource "azurerm_lb" "prod_lb" {
name = "prod-lb"
location = azurerm_resource_group.prod_rg.location
resource_group_name = azurerm_resource_group.prod_rg.name
sku = "Standard"
frontend_ip_configuration {
name = "prod-fe-ip-config"
public_ip_address_id = azurerm_public_ip.prod_pip.id
private_ip_address_allocation = "Dynamic"
}
}

#Define backend pool for the load balancer
resource "azurerm_lb_backend_address_pool" "dev_backend_pool" {
name = "dev-backend-pool"
loadbalancer_id = azurerm_lb.dev_lb.id
resource_group_name = azurerm_resource_group.dev_rg.name
}

resource "azurerm_lb_backend_address_pool" "qa_backend_pool" {
name = "qa-backend-pool"
loadbalancer_id = azurerm_lb.qa_lb.id
resource_group_name = azurerm_resource_group.qa_rg.name
}

resource "azurerm_lb_backend_address_pool" "prod_backend_pool" {
name = "prod-backend-pool"
loadbalancer_id = azurerm_lb.prod_lb.id
resource_group_name = azurerm_resource_group.prod_rg.name
}

#Define probe for the load balancer
resource "azurerm_lb_probe" "dev_probe" {
name = "dev-probe"
protocol = "tcp"
port = 80
interval = 30
threshold = 2
loadbalancer_id = azurerm_lb.dev_lb.id
resource_group_name = azurerm_resource_group.dev_rg.name
}

resource "azurerm_lb_probe" "qa_probe" {
name = "qa-probe"
protocol = "tcp"
resource "azurerm_sql_database" "dev_db" {
name = "dev-db"
resource_group_name = azurerm_resource_group.dev_rg.name
location = azurerm_resource_group.dev_rg.location
server_name = azurerm_sql_server.dev_sql_server.name
edition = "Standard"
requested_service_objective_name = "S0"
}

resource "azurerm_sql_database" "qa_db" {
name = "qa-db"
resource_group_name = azurerm_resource_group.qa_rg.name
location = azurerm_resource_group.qa_rg.location
server_name = azurerm_sql_server.qa_sql_server.name
edition = "Standard"
requested_service_objective_name = "S0"
}

resource "azurerm_sql_database" "prod_db" {
name = "prod-db"
resource_group_name = azurerm_resource_group.prod_rg.name
location = azurerm_resource_group.prod_rg.location
server_name = azurerm_sql_server.prod_sql_server.name
edition = "Standard"
requested_service_objective_name = "S0"
}

Define virtual machines for each environment
resource "azurerm_linux_virtual_machine" "dev_vm" {
name = "dev-vm"
location = azurerm_resource_group.dev_rg.location
resource_group_name = azurerm_resource_group.dev_rg.name
size = "Standard_B2s"
admin_username = "adminuser"
network_interface_ids = [
azurerm_network_interface.dev_nic.id,
]
os_disk {
name = "dev-vm-os-disk"
caching = "ReadWrite"
storage_account_type = "Standard_LRS"
}
source_image_reference {
publisher = "Canonical"
offer = "UbuntuServer"
sku = "18.04-LTS"
version = "latest"
}
custom_data = filebase64("startup-script.sh")
}

resource "azurerm_linux_virtual_machine" "qa_vm" {
name = "qa-vm"
location = azurerm_resource_group.qa_rg.location
resource_group_name = azurerm_resource_group.qa_rg.name
size = "Standard_B2s"
admin_username = "adminuser"
network_interface_ids = [
azurerm_network_interface.qa_nic.id,
]
os_disk {
name = "qa-vm-os-disk"
caching = "ReadWrite"
storage_account_type = "Standard_LRS"
}
source_image_reference {
publisher = "Canonical"
offer = "UbuntuServer"
sku = "18.04-LTS"
version = "latest"
}
custom_data = filebase64("startup-script.sh")
}

resource "azurerm_linux_virtual_machine" "prod_vm" {
name = "prod-vm"
location = azurerm_resource_group.prod_rg.location
resource_group_name = azurerm_resource_group.prod_rg.name
size = "Standard_B2s"
admin_username = "adminuser"
network_interface_ids = [
azurerm_network_interface.prod_nic.id,
]
os_disk {
name = "prod-vm-os-disk"
caching = "ReadWrite"
storage_account_type = "Standard_LRS"
}
source_image_reference {
publisher = "Canonical"
offer = "UbuntuServer"
sku = "18.04-LTS"
version =

#Define virtual machine scale sets for each environment
resource "azurerm_linux_virtual_machine_scale_set" "dev_vmss" {
name = "dev-vmss"
location = azurerm_resource_group.dev_rg.location
resource_group_name = azurerm_resource_group.dev_rg.name
sku = "Standard_DS1_v2"

capacity = 3

storage_profile_image_reference {
publisher = "Canonical"
offer = "UbuntuServer"
sku = "16.04-LTS"
version = "latest"
}

os_disk {
name = "dev-vmss-osdisk"
caching = "ReadWrite"
storage_account_type = "Standard_LRS"
}

os_profile {
computer_name_prefix = "dev-vm"
admin_username = "adminuser"
admin_password = "Password1234!"
custom_data = base64encode("echo 'Hello, World!'")
}

network_interface {
name = "dev-nic"
primary = true


ip_configuration {
  name                          = "dev-ip-config"
  subnet_id                     = azurerm_subnet.dev_subnet.id
  load_balancer_backend_address_pool_ids = [
    azurerm_lb_backend_address_pool.dev_backend_pool.id
  ]
  application_gateway_backend_address_pool_ids = [
    azurerm_application_gateway_backend_address_pool.dev_backend_pool.id
  ]
}
}
}

resource "azurerm_linux_virtual_machine_scale_set" "qa_vmss" {
name = "qa-vmss"
location = azurerm_resource_group.qa_rg.location
resource_group_name = azurerm_resource_group.qa_rg.name
sku = "Standard_DS2_v2"

capacity = 3

storage_profile_image_reference {
publisher = "Canonical"
offer = "UbuntuServer"
sku = "16.04-LTS"
version = "latest"
}

os_disk {
name = "qa-vmss-osdisk"
caching = "ReadWrite"
storage_account_type = "Standard_LRS"
}

os_profile {
computer_name_prefix = "qa-vm"
admin_username = "adminuser"
admin_password = "Password1234!"
custom_data = base64encode("echo 'Hello, World!'")
}

network_interface {
name = "qa-nic"
primary = true


ip_configuration {
  name                          = "qa-ip-config"
  subnet_id                     = azurerm_subnet.qa_subnet.id
  load_balancer_backend_address_pool_ids = [
    azurerm_lb_backend_address_pool.qa_backend_pool.id
  ]
  application_gateway_backend_address_pool_ids = [
    azurerm_application_gateway_backend_address_pool.qa_backend_pool.id
  ]
}
}
}

resource "azurerm_linux_virtual_machine_scale_set" "prod_vmss" {
name = "prod-vmss"
location = azurerm_resource_group.prod_rg.location
resource_group_name = azurerm_resource_group.prod_rg.name
sku = "Standard_DS3_v2"

capacity = 3

storage_profile_image_reference {
publisher = "Canonical"
offer = "UbuntuServer"
sku = "16.04-LTS"
version = "latest"
}

os_disk {
name = "prod-vmss-osdisk"
caching = "ReadWrite"
storage_account_type = "Standard_LRS"
}

os_profile {
computer_name_prefix = "prod-vm"


# Define the virtual machine scale set for each environment
resource "azurerm_linux_virtual_machine_scale_set" "dev_vmss" {
  name                = "dev-vmss"
  location            = azurerm_resource_group.dev_rg.location
  resource_group_name = azurerm_resource_group.dev_rg.name

  sku {
    name     = "Standard_DS1_v2"
    capacity = 2
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_profile_os_disk {
    name              = "dev-vmss-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  network_interface {
    name    = "dev-nic"
    primary = true

    ip_configuration {
      name                          = "dev-ip-config"
      subnet_id                     = azurerm_subnet.dev_subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.dev_pool.id]
      load_balancer_inbound_nat_rules_ids   = [azurerm_lb_nat_rule.dev_nat_rule.id]
    }
  }

  os_profile {
    computer_name_prefix = "dev-vmss"
    admin_username       = "adminuser"
    admin_password       = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
    ssh_keys {
      path     = "/home/adminuser/.ssh/authorized_keys"
      key_data = file("~/.ssh/id_rsa.pub")
    }
  }
}

resource "azurerm_linux_virtual_machine_scale_set" "qa_vmss" {
  name                = "qa-vmss"
  location            = azurerm_resource_group.qa_rg.location
  resource_group_name = azurerm_resource_group.qa_rg.name

  sku {
    name     = "Standard_DS2_v2"
    capacity = 4
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_profile_os_disk {
    name              = "qa-vmss-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  network_interface {
    name    = "qa-nic"
    primary = true

    ip_configuration {
      name                          = "qa-ip-config"
      subnet_id                     = azurerm_subnet.qa_subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.qa_pool.id]
      load_balancer_inbound_nat_rules_ids   = [azurerm_lb_nat_rule.qa_nat_rule.id]
    }
  }

  os_profile {
    computer_name_prefix = "qa-vmss"
    admin_username       = "adminuser"
    admin_password       = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
    ssh_keys {
      path     = "/home/adminuser/.ssh/authorized_keys"
      key_data = file("~/.ssh/id_rsa.pub")
    }
  }
}

resource "azurerm_linux_virtual_machine_scale_set" "prod_vmss" {
  name                = "prod-vmss"
  location            = azurerm_resource_group.prod_rg.location
  resource_group_name = azurerm_resource_group.prod_rg.name

  
    
# Define the Kubernetes cluster for production environment
module "aks" {
  source              = "Azure/kubernetes-engine/azurerm"
  resource_group_name = azurerm_resource_group.prod_rg.name
  location            = azurerm_resource_group.prod_rg.location
  dns_prefix          = "prod"
  kubernetes_version  = "1.21.5"
  agent_pool_profiles = [
    {
      name            = "prod"
      count           = 1
      vm_size         = "Standard_DS2_v2"
      os_type         = "Linux"
      vnet_subnet_id  = azurerm_subnet.prod_subnet.id
      max_pods        = 30
      availability_zones = [1,2]
    }
  ]
}

# Define the Kubernetes cluster for dev environment
module "aks-dev" {
  source              = "Azure/kubernetes-engine/azurerm"
  resource_group_name = azurerm_resource_group.dev_rg.name
  location            = azurerm_resource_group.dev_rg.location
  dns_prefix          = "dev"
  kubernetes_version  = "1.21.5"
  agent_pool_profiles = [
    {
      name            = "dev"
      count           = 1
      vm_size         = "Standard_DS2_v2"
      os_type         = "Linux"
      vnet_subnet_id  = azurerm_subnet.dev_subnet.id
      max_pods        = 30
    }
  ]
}

# Define the Kubernetes cluster for QA environment
module "aks-qa" {
  source              = "Azure/kubernetes-engine/azurerm"
  resource_group_name = azurerm_resource_group.qa_rg.name
  location            = azurerm_resource_group.qa_rg.location
  dns_prefix          = "qa"
  kubernetes_version  = "1.21.5"
  agent_pool_profiles = [
    {
      name            = "qa"
      count           = 1
      vm_size         = "Standard_DS2_v2"
      os_type         = "Linux"
      vnet_subnet_id  = azurerm_subnet.qa_subnet.id
      max_pods        = 30
    }
  ]
}

