# Azure-Architect v1.0

Over the past few weeks I built “Azure Architect v1.0”, a browser-based tool that lets you visually design Azure cloud architectures and instantly export production-ready Infrastructure as Code with zero manual HCL writing.

WHAT IT DOES

✅ Drag & drop Azure resources to a canvas
✅ Nest resources inside containers
✅ Resize containers freely with a drag handle
✅ Set inbound and outbound firewall ports per VM with one click
✅ Export to Terraform HCL instantly

HOW I BUILT IT

With pure HTML, CSS, and vanilla JavaScript.
A single self-contained .html file you can open in any browser.

THE LOGIC BEHIND
When you click the Terraform download button, the generator walks every node on the canvas.

Strict ordering
·Terraform needs to create things in the right sequence. You can't create a VM before its network exists. The app always writes the file in the correct order network first, then subnets, then firewall rules, then VMs so Azure never gets confused about what to build first.
Port rules 
·When you click SSH, HTTP, HTTPS in the app, those become proper firewall rules in the code automatically. You don't need to write them manually.
Public/Private subnet
·If you mark a subnet as Public, the app automatically adds a Public IP to the VM. If Private, it doesn't. You just toggle it visually the code handles itself.
depends on, tags, and references
·Three common mistakes in handwritten Terraform are forgetting to tell resources to wait for each other, forgetting to label resources, and typing resource names as plain text instead of proper links. “The Azure Architect v1.0” never makes these mistakes everything is wired correctly every time.

WHY THIS MATTERS FOR ENTERPRISE
For corporate DevOps and cloud teams this solves real problems:

🔹 Onboarding junior engineers can design architectures visually before touching a CLI
🔹 Architecture reviews share the canvas as a live diagram, not a static image
🔹 IaC acceleration what takes hours of HCL writing takes minutes of drag and drop
🔹 Compliance NSG rules are defined visually and enforced in code, not forgotten
🔹 multi-team collaboration the single HTML file needs no server, no login, no setup
🔹 Audit trail the exported Terraform is readable, commented, and git-committable

Open Source and feel free to extend

The entire application is a single HTML file readable, forkable, and extensible.

Ideas for community contributions:
·     Add GCP and AWS resource libraries
·     Add Terraform state import from existing Azure subscriptions
·     Add cost estimation per resource
·     Add multi-region canvas with region boundaries
·     Integrate with Azure DevOps pipelines

GitHub: https://github.com/Issiwara/Azure-Architect

If you work in cloud infrastructure, DevOps, or platform engineering try it, fork it, break it, improve it. That's the point.
