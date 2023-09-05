### Create ECR + deploy docker file
![Screenshot_1](https://github.com/yanchoys/IT-Syndicate/assets/98917290/952be493-6b8d-48fe-8f7b-d5b5ace95396)

### Creating 2 Security Groups
For application load balancer to inbound all trafic to port 80
![image](https://github.com/yanchoys/IT-Syndicate/assets/98917290/7353d1d9-af2c-4b47-8af7-b7a1dd8f1b3b)
For Inbound traffic from application load balancer
![image](https://github.com/yanchoys/IT-Syndicate/assets/98917290/184e065e-bc32-49c3-b0b8-1d2b8c7d48ee)

### Creating cluster
![image](https://github.com/yanchoys/IT-Syndicate/assets/98917290/7c874c14-63e4-470e-a211-d261977674af)

### Creating Load Balancer and Target Group
![image](https://github.com/yanchoys/IT-Syndicate/assets/98917290/e5d10888-d6d8-426a-8a02-f3d97a158d5c)

![image](https://github.com/yanchoys/IT-Syndicate/assets/98917290/6c10d1f3-8e87-4942-8bba-2b5704eb4b01)

### Adding a service with a three tasks 
![image](https://github.com/yanchoys/IT-Syndicate/assets/98917290/e558d65c-859d-46cf-b777-e6dc02628b00)

#### Output of load balancer
![image](https://github.com/yanchoys/IT-Syndicate/assets/98917290/a8e5c1b1-f457-4a73-911f-a3e9a66f2dfc)

### Creating cluster with autoscaling and creating autoscaling group
![image](https://github.com/yanchoys/IT-Syndicate/assets/98917290/fdb70442-fd04-4cf7-b81b-183fd90aaa88)




### Testsgoing to tests i used jmeter with 10000 people count
moving on to tests i used jmeter with 5000 people count
ramp-up period 10 for ECS Fargate and Auto-Scaling group
also used not just a get request with a 200 code, but also whether the page contains the text "Welcome to nginx!"
after looking at the graphs and seeing the result, that using ECS ​​Fargate there were 1450 successful logins
Auto-scaling Group showed 3946
but running the test each time completely different results
![image](https://github.com/yanchoys/IT-Syndicate/assets/98917290/144136b9-d904-4a12-8a5f-cc6d96b44934)


**ECS Fargate:**

**Pros:**

**Ease of Setup:**

- Fargate is a serverless container orchestration service, making it incredibly easy to set up. You don't need to manage EC2 instances or worry about infrastructure.
- It abstracts away the underlying infrastructure complexities, allowing you to focus solely on your containers and applications.
Cost-Efficiency:

- You pay only for the resources your containers use, which can lead to cost savings as you don't need to provision or maintain EC2 instances.
- Fargate eliminates the need for over-provisioning to accommodate peak loads, further reducing costs.
Scalability:

- Fargate can automatically scale your containerized applications based on workload demands.
- It provides auto-scaling and load balancing features that make it well-suited for handling varying traffic levels.
Cons:

**Limited Customization:**
- Fargate abstracts the underlying infrastructure, which means you have less control over the host environment compared to EC2.
- You might encounter limitations in terms of customizing the underlying host resources.

**EC2 Auto Scaling:**

**Pros:**

**Customization:**

- EC2 instances provide full control over the underlying infrastructure, allowing you to configure the environment to your specific needs.
- You can install custom software, use specific instance types, and fine-tune performance parameters.
Cost Flexibility:

- EC2 instances offer various pricing options, including On-Demand, Spot Instances, and Reserved Instances, providing flexibility in managing costs.
- You can optimize costs by choosing the right instance types and purchasing options.

**Scalability:**

- EC2 Auto Scaling enables you to dynamically adjust the number of instances based on metrics and triggers.
- It offers granular control over scaling policies, which can be customized for specific use cases.

**Cons:**

**Complex Setup:**

- Setting up and managing EC2 instances and Auto Scaling configurations can be more complex and time-consuming than Fargate.
- It requires expertise in infrastructure management.
Cost Management:

While EC2 offers cost flexibility, it also requires careful management to avoid over-provisioning or under-provisioning instances, which can lead to increased costs.
Infrastructure Maintenance:

You are responsible for maintaining and patching the underlying EC2 instances, which can be a significant operational overhead.
In conclusion, the choice between ECS Fargate and EC2 Auto Scaling depends on your specific requirements and priorities:

If ease of setup, cost-efficiency, and reduced operational overhead are essential, ECS Fargate is a strong choice.
If you need more customization, cost flexibility, and have the expertise to manage infrastructure, EC2 Auto Scaling offers greater control.

### Task 3
Creating Distribution CDN
![image](https://github.com/yanchoys/IT-Syndicate/assets/98917290/cc6b7982-1d27-44e9-bfd1-89c41b90d201)
#### **testing CDN**
![image](https://github.com/yanchoys/IT-Syndicate/assets/98917290/eedde642-8a7c-4c46-85a5-6b46e51b0b0e)

![image](https://github.com/yanchoys/IT-Syndicate/assets/98917290/75a5c11c-054c-4984-93f8-806549eb3241)

#### **output CDN**
![image](https://github.com/yanchoys/IT-Syndicate/assets/98917290/079cf766-3b8b-4b76-be40-59e6e4888b67)

![image](https://github.com/yanchoys/IT-Syndicate/assets/98917290/c63395bf-156c-4892-bdd1-bb501622d87d)



