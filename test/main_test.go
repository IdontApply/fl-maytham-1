package main

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTf1(t *testing.T) {
	planFilePath := filepath.Join("../tf1", "plan.out")
	// bla bla bla
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../tf1",

		PlanFilePath: planFilePath,
	})

	defer os.Remove(planFilePath)
	defer terraform.Destroy(t, terraformOptions)

	plan := terraform.InitAndPlanAndShowWithStruct(t, terraformOptions)

	terraform.RequirePlannedValuesMapKeyExists(t, plan, "aws_s3_bucket.a")
	ec2Resource := plan.ResourcePlannedValuesMap["aws_instance.a"]
	s3Resource := plan.ResourcePlannedValuesMap["aws_s3_bucket.a"]
	ec2Tags := ec2Resource.AttributeValues["tags"].(map[string]interface{})
	s32Tags := s3Resource.AttributeValues["tags"].(map[string]interface{})

	assert.Equal(t, map[string]interface{}{"Name": "Flugel", "Owner": "InfraTeam"}, ec2Tags)
	assert.Equal(t, map[string]interface{}{"Name": "Flugel", "Owner": "InfraTeam"}, s32Tags)

}
