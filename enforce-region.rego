package terraform.analysis

import future.keywords.if
import future.keywords.contains

default allow := false

# Rule 1: Allow the deployment if there are zero violations
allow := true if count(violations) == 0

# Rule 2: Identify resources violating our location policy
violations contains msg if {
    # Scan through all resource modifications in the plan
    resource := input.resource_changes[_]
    
    # Isolate the location attribute if it exists
    actual_location := resource.change.after.location
    
    # Check if the location is NOT East US
    actual_location != "East US"
    
    # Generate the custom error message for the pipeline logs
    msg := sprintf("CRITICAL COMPLIANCE VIOLATION: Resource '%v' is trying to deploy in '%v'. Enterprise policy restricts all deployments to 'East US' only.", [resource.address, actual_location])
}
