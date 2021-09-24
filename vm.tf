# Resource-1: Create Vm
resource "azurerm_windows_virtual_machine" "vm1" {
  name                = "vm1-machine"
  resource_group_name = azurerm_resource_group.myrg.name
  location            = azurerm_resource_group.myrg.location
  size                = "Standard_F2"
  admin_username      = data.azurerm_key_vault_secret.KeyValueSecretusername.value
  admin_password      = data.azurerm_key_vault_secret.KeyValueSecretpass.value
  network_interface_ids = [
    azurerm_network_interface.myvmnic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_windows_virtual_machine" "vm2" {
  name                = "vm2-machine"
  resource_group_name = azurerm_resource_group.myrg.name
  location            = azurerm_resource_group.myrg.location
  size                = "Standard_F2"
  admin_username      = data.azurerm_key_vault_secret.KeyValueSecretusername.value
  admin_password      = data.azurerm_key_vault_secret.KeyValueSecretpass.value
  network_interface_ids = [
    azurerm_network_interface.myvmnic1.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

data "azurerm_key_vault" "Mykey1"{
 name                = "resource-kvt1"
 resource_group_name = "my-resource-rg"
}

data "azurerm_key_vault_secret" "KeyValueSecretusername" {
  name         = "username"
  key_vault_id = data.azurerm_key_vault.Mykey1.id
}

data "azurerm_key_vault_secret" "KeyValueSecretpass" {
  name         = "password"
  key_vault_id = data.azurerm_key_vault.Mykey1.id
}

# Resource-2: Create Virtual Network
resource "azurerm_virtual_network" "myvnet" {
  name                = "myvnet-1"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name
}

# Resource-3: Create Subnet
resource "azurerm_subnet" "mysubnet1" {
  name                 = "mysubnet-1"
  resource_group_name  = azurerm_resource_group.myrg.name
  virtual_network_name = azurerm_virtual_network.myvnet.name
  address_prefixes     = ["10.0.2.0/24"]

}

resource "azurerm_subnet" "mysubnet2" {
  name                 = "mysubnet-2"
  resource_group_name  = azurerm_resource_group.myrg.name
  virtual_network_name = azurerm_virtual_network.myvnet.name
  address_prefixes     = ["10.0.3.0/24"]

}

# Resource-4: Create Public IP Address
resource "azurerm_public_ip" "mypublicip" {
  name                = "mypublicip-1"
  resource_group_name = azurerm_resource_group.myrg.name
  location            = azurerm_resource_group.myrg.location
  allocation_method   = "Static"
}

# Resource-5: Create Network Interface
resource "azurerm_network_interface" "myvmnic" {
  name                = "vmnic"
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mysubnet1.id
    private_ip_address_allocation = "Dynamic"
    
  }
}

resource "azurerm_network_interface" "myvmnic1" {
  name                = "vmnic1"
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mysubnet2.id
    private_ip_address_allocation = "Dynamic"
    
  }
}


resource "azurerm_network_security_group" "mynsg" {
  name                = "acceptanceTestSecurityGroup1"
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name

  security_rule {
    name                       = "test123"
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
    name                       = "test1234"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  tags = {
    environment = "Test"
  }
}

