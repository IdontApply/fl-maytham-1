package test

import (
	"fmt"
	"math/rand"
	"os"
	"path/filepath"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// function to test tf1 moudle for correct tags on aws_instance.a and  aws_s3_bucket.a"
func TestTf1(t *testing.T) {
	planFilePath := filepath.Join("../tf1", "plan.out")

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../tf1",

		PlanFilePath: planFilePath,
	})

	defer os.Remove(planFilePath)
	defer terraform.Destroy(t, terraformOptions)

	plan := terraform.InitAndPlanAndShowWithStruct(t, terraformOptions)

	// terraform.RequirePlannedValuesMapKeyExists(t, plan, "aws_s3_bucket.a")
	ec2Resource := plan.ResourcePlannedValuesMap["aws_instance.a"]
	s3Resource := plan.ResourcePlannedValuesMap["aws_s3_bucket.a"]
	ec2Tags := ec2Resource.AttributeValues["tags"].(map[string]interface{})
	s32Tags := s3Resource.AttributeValues["tags"].(map[string]interface{})

	assert.Equal(t, map[string]interface{}{"Name": "Flugel", "Owner": "InfraTeam"}, ec2Tags)
	assert.Equal(t, map[string]interface{}{"Name": "Flugel", "Owner": "InfraTeam"}, s32Tags)
}

// function to test tf2 moudle, test checks if files are reachable in the ALB
func TestTf2(t *testing.T) {
	// map for radom number of tags between 2 to 5
	rTags := map[string]string{}
	// genrate random number from 2 to 5
	rand.Seed(time.Now().UTC().UnixNano())
	min := 2
	max := 6
	rNum := min + rand.Intn(max-min)
	for i := 0; i < rNum; i++ {
		rTags[fmt.Sprintf("tag%d", i)] = fmt.Sprintf("potato%d", i)
	}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../tf2",
		Vars: map[string]interface{}{
			"tags": rTags,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)
	// url to alb
	albDNS := "http://" + terraform.Output(t, terraformOptions, "aws_alb_dns")

	maxRetries := 30
	timeBetweenRetries := 5 * time.Second
	for key, element := range rTags {
		http_helper.HttpGetWithRetry(t, albDNS+"/"+key, nil, 200, element, maxRetries, timeBetweenRetries)
	}
}
