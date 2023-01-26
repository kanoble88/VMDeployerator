# VMDeployerator
Clone VMs in vSphere With Specific Configs

Essentially what it does is:
Connect to vCenter 
User Inputs VM Config info they want to apply to a Cloned Windows 10 VM 
After Configs are set VM is Deployed 
vCenter uses the OS CustomizationSpec to apply the configs to the cloned VM
Then joins the newly cloned VM to the specified domain
Whole Clone, Deploy and Config Process takes ~15 min.

- Requires PowerCLI to be installed on VM running the script
- Requires a VM Specification to be created that the script will use when cloning
  I have mine set up pretty much standard except the following:
  - Computer Name: Use the Virtual Machine Name
  - Administrator Password is the Local Admin Password for the VM
    - Automatically Logon as Administrator is Checked Yes
    - Number of Times to Logon Automatically is 5
   - The NIC is set to Custom Settings
    - I filled my info in with an IP address, Netmask, DNS and Gateway from one of the networks
      it gets changed anyway so probably not a big deal if you have random info in it.
   - Workgroup or Domain is set to Workgroup
   

