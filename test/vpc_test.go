package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TODO: configure aws provider

func TestTerraformAwsVpc(t *testing.T) {
	// retryable errors in terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../",
        
        // Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
            "vpc_cidr": "10.0.0.0/16",
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

    // TODO: assert the cidr is what we expect it to be

	//output := terraform.Output(t, terraformOptions, "hello_world")
	//assert.Equal(t, "Hello, World!", output)
}

