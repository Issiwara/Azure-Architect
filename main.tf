# Terraform (azurerm) — Azure Architect v2
# Generated: 2026-05-12T12:36:50.764Z

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "location" {
  default = "westeurope"
}

# 📦 Resource Group
resource "azurerm_resource_group" "resourcegroupdemo" {
  name     = "resourcegroupdemo"
  location = var.location
}

# 🌐 Virtual Network [rg: resourcegroupdemo]
resource "azurerm_virtual_network" "vnetdemo" {
  name                = "vnetdemo"
  resource_group_name = azurerm_resource_group.resourcegroupdemo.name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
}

# ⬡ Subnet [vnet: vnetdemo]
resource "azurerm_subnet" "publicsubnet" {
  name                 = "publicsubnet"
  resource_group_name  = azurerm_resource_group.resourcegroupdemo.name
  virtual_network_name = azurerm_virtual_network.vnetdemo.name
  address_prefixes     = ["10.0.1.0/24"]

  depends_on = [azurerm_virtual_network.vnetdemo]
}

# ⬡ Subnet [vnet: vnetdemo]
resource "azurerm_subnet" "privatesubnet" {
  name                 = "privatesubnet"
  resource_group_name  = azurerm_resource_group.resourcegroupdemo.name
  virtual_network_name = azurerm_virtual_network.vnetdemo.name
  address_prefixes     = ["10.0.2.0/24"]

  depends_on = [azurerm_virtual_network.vnetdemo]
}

# 🔒 NSG for publicvm (inbound: 22, 80, 3306, 443 | outbound: *)
resource "azurerm_network_security_group" "publicvm_nsg" {
  name                = "publicvm-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.resourcegroupdemo.name

  security_rule {
    name                       = "inbound-allow-22"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "inbound-allow-80"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "inbound-allow-3306"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "inbound-allow-443"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "outbound-allow-all"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  depends_on = [azurerm_resource_group.resourcegroupdemo]

  tags = {
    managed_by = "azure-architect"
  }
}

# 🌐 Public IP for publicvm (public subnet)
resource "azurerm_public_ip" "publicvm_pip" {
  name                = "publicvm-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.resourcegroupdemo.name
  allocation_method   = "Static"
  sku                 = "Standard"

  depends_on = [azurerm_resource_group.resourcegroupdemo]

  tags = {
    managed_by = "azure-architect"
  }
}

# 🔌 Network Interface for publicvm [PUBLIC]
resource "azurerm_network_interface" "publicvm_nic" {
  name                = "publicvm-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.resourcegroupdemo.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.publicsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicvm_pip.id
  }

  depends_on = [azurerm_public_ip.publicvm_pip, azurerm_subnet.publicsubnet]
}

resource "azurerm_network_interface_security_group_association" "publicvm_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.publicvm_nic.id
  network_security_group_id = azurerm_network_security_group.publicvm_nsg.id

  depends_on = [azurerm_network_interface.publicvm_nic, azurerm_network_security_group.publicvm_nsg]
}

# 🔒 NSG for privatevm (inbound: 22, 80, 443, 5432 | outbound: *)
resource "azurerm_network_security_group" "privatevm_nsg" {
  name                = "privatevm-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.resourcegroupdemo.name

  security_rule {
    name                       = "inbound-allow-22"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "inbound-allow-80"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "inbound-allow-443"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "inbound-allow-5432"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "outbound-allow-all"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  depends_on = [azurerm_resource_group.resourcegroupdemo]

  tags = {
    managed_by = "azure-architect"
  }
}

# 🔌 Network Interface for privatevm [PRIVATE]
resource "azurerm_network_interface" "privatevm_nic" {
  name                = "privatevm-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.resourcegroupdemo.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.privatesubnet.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [azurerm_subnet.privatesubnet]
}

resource "azurerm_network_interface_security_group_association" "privatevm_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.privatevm_nic.id
  network_security_group_id = azurerm_network_security_group.privatevm_nsg.id

  depends_on = [azurerm_network_interface.privatevm_nic, azurerm_network_security_group.privatevm_nsg]
}

# 💻 Virtual Machine [subnet: publicsubnet] [vnet: vnetdemo] [rg: resourcegroupdemo]
resource "azurerm_linux_virtual_machine" "publicvm" {
  resource_group_name = azurerm_resource_group.resourcegroupdemo.name
  location            = var.location
  name           = "publicvm"
  size           = "Standard_D2s_v3"
  admin_username = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.publicvm_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("./crud-key.pub")
  }

  depends_on = [azurerm_network_interface.publicvm_nic]

  tags = {
    managed_by = "azure-architect"
  }
}

# 💻 Virtual Machine [subnet: privatesubnet] [vnet: vnetdemo] [rg: resourcegroupdemo]
resource "azurerm_linux_virtual_machine" "privatevm" {
  resource_group_name = azurerm_resource_group.resourcegroupdemo.name
  location            = var.location
  name           = "privatevm"
  size           = "Standard_D2s_v3"
  admin_username = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.privatevm_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("./crud-key.pub")
  }

  depends_on = [azurerm_network_interface.privatevm_nic]

  tags = {
    managed_by = "azure-architect"
  }
}

# 🛡 NSG [vnet: vnetdemo] [rg: resourcegroupdemo]
resource "azurerm_network_security_group" "nsgdemo" {
  resource_group_name = azurerm_resource_group.resourcegroupdemo.name
  location            = var.location
  name = "nsgdemo"

  security_rule {
    name                       = "inbound-allow-80"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "inbound-allow-443"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "inbound-allow-8080"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  tags = {
    managed_by = "azure-architect"
  }
}

