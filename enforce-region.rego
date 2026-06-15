package terraform.analysis

import future.keywords.if
import future.keywords.contains

default allow := false

# Rule 1: Allow the deployment if there are zero violations
allow := true if count(violations) == 0

# Rule 2: Identify resources violating our location policy
violations contains msg if {
    resource := input.resource_changes[_]
    actual_location := resource.change.after.location
    
    # Convert location to lower-case to match both "eastus" and "east us" smoothly
    lower_location := lower(actual_location)
    lower_location != "eastus"
    lower_location != "east us"
    
    msg := sprintf("CRITICAL COMPLIANCE VIOLATION: Resource '%v' is trying to deploy in '%v'. Enterprise policy restricts all deployments to 'East US' only.", [resource.address, actual_location])
}
