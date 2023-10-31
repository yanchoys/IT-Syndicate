```
version: 2.1

executors:
  tfsec-executor:
    docker:
      - image: aquasec/tfsec:latest
        environment:
          TF_SEC_DIR: /tmp/project
    working_directory: /tmp/project

  terraform-executor: 
    docker:
      - image: hashicorp/terraform:latest 
    working_directory: /tmp/project

  aws-executor:
    docker:
      - image: amazon/aws-cli:latest
    working_directory: /tmp/project
    
  git-executor:
    docker:
      - image: circleci/python:3.7.9  # A basic image that includes git
    working_directory: /tmp/project  

jobs:
  tfsec-test:
    executor: tfsec-executor
    steps:
      - checkout
      - run:
          name: Run tfsec tests
          command: tfsec . 

  # terraform-init:
  #   executor: terraform-executor
  #   steps:
  #     - checkout
  #     - run:
  #         name: Terraform init
  #         command: |
  #           cd infrastructure
  #           terraform init

  terraform-validate-plan:
    executor: terraform-executor
    steps:
      - checkout
      - run:
          name: Terraform validate and plan
          command: |
            cd infrastructure
            terraform init
            terraform validate
            terraform plan

  hold-for-approval-1:
    executor: tfsec-executor
    steps:
      - checkout
      - run:
          name: Hold for approval
          command: echo "Hold for approval. Approve in CircleCI dashboard to continue."

  terraform-apply:
    executor: terraform-executor
    steps:
      - checkout
      - run:
          name: Terraform apply
          command: echo "terraform apply -auto-approve"

  infrastructure-tests:
    executor: aws-executor
    steps:
     - checkout
     - run:
         name: Check EC2 instances
         command: |
           aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
           aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
           aws configure set region us-east-1 
           aws ec2 describe-instances --query "Reservations[*].Instances[*].{ID:InstanceId}" --output text
     - run:
         name: Check RDS database
         command: |
           aws rds describe-db-instances --query "DBInstances[*].DBInstanceIdentifier" --output text
     - run:
         name: Check VPC and subnets
         command: |
           aws ec2 describe-vpcs --query "Vpcs[*].{ID:VpcId}" --output text
           echo "AWS CLI commands completed"
           # aws ec2 describe-subnets --query "Subnets[*].{ID:SubnetId}" --output text
           
           
     - run:
         name: Check database accessibility
         command: |
           # aws rds describe-db-instances --db-instance-identifier YOUR_DB_INSTANCE_ID --query "DBInstances[*].VpcSecurityGroups[0].VpcSecurityGroupId" --output text
           # aws ec2 describe-security-groups --group-ids YOUR_SECURITY_GROUP_ID --query "SecurityGroups[*].{Ingress:IpPermissions}" --output text
           


  hold-for-approval-2:
    executor: tfsec-executor
    steps:
      - checkout
      - run:
          name: Hold for approval
          command: echo "Hold for approval. Approve in CircleCI dashboard to continue."
          
  terraform-destroy:
    executor: terraform-executor
    steps:
      - checkout
      - run:
          name: Terraform destroy
          command: |
            cd infrastructure
            echo "terraform destroy -auto-approve"

  git-pull:
    executor: git-executor
    steps:
      - checkout
      - run:
          name: Setup Git Configuration
          command: |
            git config user.name "illia"
            git config user.email "llolik7262@gmail.com"
      - run:
          name: Create and Submit Pull Request
          command: |
            # git checkout -b my-new-changes
            # git add .
            # git commit -m "Describe your changes"
            # git push origin circleci-project-setup
            gh pr create --base main --head circleci-project-setup

            
workflows:
  version: 2
  build-deploy:
    jobs:
      - tfsec-test
      #- terraform-init
      - terraform-validate-plan
          # requires: 
          #   - terraform-init
      #- hold-for-approval-1:
      #    type: approval
      - terraform-apply:
          requires:
            - terraform-validate-plan
            #- hold-for-approval-1
      - infrastructure-tests:
          requires:
            - terraform-apply
      #- hold-for-approval-2:
      #    type: approval
      - terraform-destroy:
          requires:
            - infrastructure-tests
      - git-pull:
          requires:
            - terraform-destroy
```

Task 2
adding this to previous .circle.yaml
```
git-revert:
  executor: git-executor
  steps:
    - checkout
    - run:
        name: Git Revert
        command: |
          git checkout master
          git revert HEAD --no-edit
          git push origin master

terraform-apply-after-revert:
  executor: terraform-executor
  steps:
    - checkout
    - run:
        name: Terraform apply (after Git revert)
        command:|
            cd infrastructure
            terraform init
            terraform apply -auto-approve

infrastructure-tests-after-revert:
    executor: aws-executor
    steps:
      - checkout
      - run:
          name: Check EC2 instances
          command: |
            aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
            aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
            aws configure set region us-east-1 
            aws ec2 describe-instances --query "Reservations[*].Instances[*].{ID:InstanceId}" --output text
      - run:
          name: Check RDS database
          command: |
            aws rds describe-db-instances --query "DBInstances[*].DBInstanceIdentifier" --output text
      - run:
          name: Check VPC and subnets
          command: |
            aws ec2 describe-vpcs --query "Vpcs[*].{ID:VpcId}" --output text
            echo "AWS CLI commands completed"
```
