package test

import (
	"fmt"
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func writeProviderConfig(region, path string) error {
    providerConfig := fmt.Sprintf(`
provider "aws" {
    region = "%s"
}
`, region)

	filePath := path + "/provider.tf"
    err := os.WriteFile(filePath, []byte(providerConfig), 0644)
    if err != nil {
        return fmt.Errorf("error writing provider config to file: %w", err)
    }

    return nil
}

func TestTerraformAwsVpc(t *testing.T) {
    // Copy the terraform folder to a temp folder
    tempTestDir := test_structure.CopyTerraformFolderToTemp(t, "../", "")

    region := "us-east-1"
    err := writeProviderConfig(region, tempTestDir)
	if err != nil {
        t.Fatalf("Error writing provider config to temp folder: %v", err)
    }

	// retryable errors in terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: tempTestDir,
        
        // Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
            "cidr_block": "10.0.0.0/16",
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

    // TODO: assert the cidr is what we expect it to be

	//output := terraform.Output(t, terraformOptions, "hello_world")
	//assert.Equal(t, "Hello, World!", output)
}

