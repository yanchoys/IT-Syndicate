# Task 1
![task1](https://github.com/yanchoys/IT-Syndicate/assets/98917290/406b6629-7b91-4d51-9ee4-c3b9f27abd44)

# Task 2
Obtaining **AWS certifications** is a great way to validate expertise in cloud computing and advance career in the field. To create a certification plan, need to consider current knowledge and experience level, career goals, and the AWS certifications that align with interests and objectives. Suggested AWS certification plan along with goals and an order for obtaining each certificate.

Certification Plan:
1. AWS Certified Cloud Practitioner
- Goal: Establish a foundational understanding of AWS services and cloud computing concepts.
- Study Materials: AWS Certified Cloud Practitioner Exam Guide, AWS Whitepapers, AWS Training, and Practice Tests.
---------------------
2. AWS Certified Solutions Architect – Associate
- Goal: Gain proficiency in designing distributed systems on AWS.
- Study Materials: AWS Certified Solutions Architect – Associate Exam Guide, AWS Training, and Practice Tests.
------------------------------
3. AWS Certified Developer – Associate
- Goal: Learn how to develop and deploy applications on AWS.
- Study Materials: AWS Certified Developer – Associate Exam Guide, AWS Training, and Practice Tests.
------------------------------
4. AWS Certified SysOps Administrator – Associate
- Goal: Focus on system operations and managing AWS resources efficiently.
- Study Materials: AWS Certified SysOps Administrator – Associate Exam Guide, AWS Training, and Practice Tests.

5. AWS Certified Security – Specialty
- Goal: Specialize in AWS security best practices and securing AWS resources.
- Study Materials: AWS Certified Security – Specialty Exam Guide, AWS Training, and Practice Tests.
------------------------------
6. AWS Certified DevOps Engineer – Professional
- Goal: Become proficient in DevOps practices and automation on AWS.
- Study Materials: AWS Certified DevOps Engineer – Professional Exam Guide, AWS Training, and Practice Tests.
------------------------------
7. AWS Certified Solutions Architect – Professional
- Goal: Achieve an advanced level of expertise in architecting complex solutions on AWS.
- Study Materials: AWS Certified Solutions Architect – Professional Exam Guide, AWS Training, and Practice Tests.
------------------------------
8. AWS Certified Advanced Networking – Specialty (Optional)
- Goal: Specialize in AWS networking and connectivity.
- Study Materials: AWS Certified Advanced Networking – Specialty Exam Guide, AWS Training, and Practice Tests.

![image](https://github.com/yanchoys/IT-Syndicate/assets/98917290/0c828bbf-278b-4052-a987-dd4a1ab9f9f5)

# Task 3
 
**1. AWS Elastic Beanstalk:**

**Pros:**
- **Easy to Use:** Elastic Beanstalk abstracts away infrastructure management, making it beginner-friendly.
- **Auto Scaling:** It can automatically scale your application based on traffic, ensuring high availability and cost-efficiency.
- **Django Support:** It provides built-in support for Django applications.
- **Database Integration:** Can be easily integrated with AWS RDS (Relational Database Service), which is a managed PostgreSQL service.
- **Managed Environment:** AWS takes care of OS patching, monitoring, and load balancing.

**Cons:**
- **Less Control:** Limited control over underlying infrastructure compared to other methods.
- **Customization:** Complex custom configurations may require you to use AWS Elastic Beanstalk with Docker containers.

**2. AWS Fargate with AWS RDS:**

**Pros:**
- **Containerized Deployment:** You can package your Django application in Docker containers, providing flexibility and consistency.
- **Scalability:** AWS Fargate allows you to define CPU and memory resources, making it easy to scale.
- **Managed Database:** Utilizing AWS RDS for PostgreSQL means you get a fully managed, highly available database.
- **Security:** IAM roles can be used to manage container permissions.

**Cons:**
- **Container Learning Curve:** Requires knowledge of containerization and Docker.
- **Complex Setup:** Setting up the network and security groups for containers can be intricate.
- **Cost Considerations:** Costs can increase if you don't carefully manage container resource allocations.


**3. AWS Lambda with Amazon RDS and Amazon S3:**

**Pros:**
- **Serverless:** AWS Lambda allows you to run code in response to events, making it truly serverless.
- **Cost-Efficient:** You pay only for the compute time your code consumes.
- **Scalability:** Scales automatically, and you can use Amazon RDS for the database and Amazon S3 for file storage.
- **Managed Services:** RDS and S3 are both managed services, reducing the operational overhead.

**Cons:**
- **Cold Starts:** AWS Lambda can have cold start times, which might affect responsiveness.
- **Application Complexity:** Complex applications may require breaking code into smaller, more modular functions.
- **Resource Limits:** AWS Lambda has resource limits that may not fit all use cases.

In summary, each deployment option has its own set of advantages and disadvantages:

- **Elastic Beanstalk** is a good choice for simplicity and ease of use but offers less control.

- **Fargate with RDS** provides more control through Docker containers and is suitable for applications with varying resource needs.

- **Lambda with RDS and S3** is cost-efficient and scalable, making it ideal for lightweight, event-driven applications, but may not be suitable for all types of applications due to resource constraints.

The choice depends on factors like your application's complexity, scalability requirements, and your team's expertise. It's also possible to combine these approaches in a microservices architecture to leverage the strengths of each for different parts of the application.
--------------------------------
# Task 4

#### Creating 3 different VPC + creating additional subnets for them
![vpcs](https://github.com/yanchoys/IT-Syndicate/assets/98917290/33d5bc64-c6af-46e8-a8bc-2f434c17f4a4)
![subnets](https://github.com/yanchoys/IT-Syndicate/assets/98917290/9b1924fe-5587-4ab8-bf11-f9e579f171a7)

#### Adding IGW to the subnets + Creating Peering connections between VPCs
![igw](https://github.com/yanchoys/IT-Syndicate/assets/98917290/f5ee15eb-7236-4368-b758-d4adc6ee61ff)
![Peering](https://github.com/yanchoys/IT-Syndicate/assets/98917290/e66f0107-d573-404e-892d-73ce257c143a)

#### Modifying subnets route tables to add Peering connections
![routeTables](https://github.com/yanchoys/IT-Syndicate/assets/98917290/d664ba35-4c94-4f99-b209-3cb94c3d77ab)

#### Modifying security to allow ICMP requests
![secGroups](https://github.com/yanchoys/IT-Syndicate/assets/98917290/9588ad4c-115b-4639-9810-ad8e6c757b2e)

#### Checking ping command between our webServers
![pingServers](https://github.com/yanchoys/IT-Syndicate/assets/98917290/f3bd535c-19ad-41e4-93f9-35e01deae9ed)

#### Modified user Data and preview of servers
![userData](https://github.com/yanchoys/IT-Syndicate/assets/98917290/a528f191-d088-4b2a-a563-b2da9414b3db)
![task4](https://github.com/yanchoys/IT-Syndicate/assets/98917290/d9494ae9-1813-43fa-acdd-eed31d0f4a87)

