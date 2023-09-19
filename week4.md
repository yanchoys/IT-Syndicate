terraform structure
```
myapp/
|-- main.tf
|-- variables.tf
|-- networking/
|   |-- main.tf
|   |-- variables.tf
|   |-- outputs.tf
|-- alb/
|   |-- main.tf
|   |-- variables.tf
|-- ec2/
|   |-- main.tf
|   |-- variables.tf
```
main.tf
```
provider "aws" {
  region     = var.AWS_REGION
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
}
module "Networking" {
  source = "./modules/Networking"

}

module "EC2" {
  source             = "./modules/EC2"
  security_group_id  = module.Networking.security_group_id
  public_subnet_ids  = module.Networking.public_subnet_ids
  private_subnet_ids = module.Networking.private_subnet_ids
  depends_on         = [module.Networking]

}

module "ALB" {
  source             = "./modules/ALB"
  security_group_id  = module.Networking.security_group_id
  public_subnet_ids  = module.Networking.public_subnet_ids
  private_subnet_ids = module.Networking.private_subnet_ids
  vpc_id             = module.Networking.vpc_id
  depends_on         = [module.Networking]

}

```

Networking
```
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

# Subnets
# Internet Gateway for Public Subnet
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.environment}-igw"
    Environment = var.environment
  }
}

# Elastic-IP (eip) for NAT
resource "aws_eip" "nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.ig]
}

# NAT
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnet.*.id, 0)

  tags = {
    Name        = "nat"
    Environment = "${var.environment}"
  }
}

# Public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.public_subnets_cidr)
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-${element(var.availability_zones, count.index)}-public-subnet"
    Environment = "${var.environment}"
  }
}


# Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.private_subnets_cidr)
  cidr_block              = element(var.private_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.environment}-${element(var.availability_zones, count.index)}-private-subnet"
    Environment = "${var.environment}"
  }
}


# Routing tables to route traffic for Private Subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${var.environment}-private-route-table"
    Environment = "${var.environment}"
  }
}

# Routing tables to route traffic for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${var.environment}-public-route-table"
    Environment = "${var.environment}"
  }
}

# Route for Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

# Route for NAT
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Route table associations for both Public & Private Subnets
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets_cidr)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

# Default Security Group of VPC
resource "aws_security_group" "default" {
  name        = "${var.environment}-default-sg"
  description = "Default SG to alllow traffic from the VPC"
  vpc_id      = aws_vpc.vpc.id
  depends_on = [
    aws_vpc.vpc
  ]

  egress {
    cidr_blocks = ["0.0.0.0/0", ]
    description = ""
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0", ]
    description = ""
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0", ]
    description = ""
    from_port   = 8080
    protocol    = "tcp"
    to_port     = 8080
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0", ]
  }
  tags = {
    Environment = "${var.environment}"
  }
}

```
ALB
```
module "EC2" {
  source = "../EC2"

}

module "Networking" {
  source = "../Networking"

}


resource "aws_lb" "this" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = var.load_balancer_type
  security_groups    = [var.security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = var.enable_deletion_protection #true


}

resource "aws_lb_target_group" "this" {
  name        = "tg-${var.name}"
  port        = var.lb_target_port[0]
  protocol    = var.lb_protocol    #"HTTP"
  target_type = var.lb_target_type #"ip" for ALB/NLB, "instance" for autoscaling group, 
  vpc_id      = var.vpc_id
  depends_on  = [aws_lb.this]
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.lb_listener_port     #"443"
  protocol          = var.lb_listener_protocol #"TLS"


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_lb_target_group_attachment" "nginx_attachment" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = module.EC2.Nginx_instance_id
  port             = var.lb_target_port[0]
}

resource "aws_lb_target_group_attachment" "postgre_attachment" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = module.EC2.Postgre_instance_id
  port             = var.lb_target_port[1]
}

```
EC2
```
module "Networking" {
  source = "../Networking"


}

resource "aws_instance" "Nginx" {
  ami           = "ami-0f844a9675b22ea32"
  instance_type = "t2.micro"
  subnet_id     = can(var.public_subnet_ids) && length(var.public_subnet_ids) > 0 ? element(var.public_subnet_ids, 0) : null
  key_name      = "key_nginx_aws"

  depends_on = [module.Networking]
  tags = {
    Name = "Nginx"
  }

}
resource "aws_instance" "Postgree" {
  ami           = "ami-0f844a9675b22ea32"
  instance_type = "t2.micro"
  subnet_id     = can(var.private_subnet_ids) && length(var.private_subnet_ids) > 0 ? element(var.private_subnet_ids, 0) : null
  key_name      = "key_post_aws"
  depends_on    = [module.Networking]
  tags = {
    Name = "Postgree"
  }

}
resource "local_file" "ansible_inventory" {
  filename = "inventory.ini"
  content  = <<-EOT
    [nginx]
    ${aws_instance.Nginx.public_ip} ansible_ssh_user=ec2-user ansible_ssh_private_key_file=~/.ssh/key_post_aws.pem

    [postgre]
    ${aws_instance.Postgree.private_ip} ansible_ssh_user=ec2-user ansible_ssh_private_key_file=~/.ssh/key_nginx_aws.pem
  EOT
}
resource "aws_key_pair" "Postgree" {
  count = length(data.aws_key_pair.existing_post_key) > 0 ? 0 : 1

  key_name   = "key_post_aws"
  public_key = tls_private_key.rsa.public_key_openssh
}
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "Post-key" {
  content         = tls_private_key.rsa.private_key_pem
  filename        = "~/.ssh/key_post_aws"
  file_permission = "0600"
}
resource "aws_key_pair" "Nginx" {
  count = length(data.aws_key_pair.existing_nginx_key) > 0 ? 0 : 1

  key_name   = "key_nginx_aws"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "local_file" "Nginx-key" {
  content         = tls_private_key.rsa.private_key_pem
  filename        = "~/.ssh/key_nginx_aws"
  file_permission = "0600"
}
data "aws_key_pair" "existing_nginx_key" {
  key_name = "key_nginx_aws"
}
data "aws_key_pair" "existing_post_key" {
  key_name = "key_post_aws"
}

```
outputs Networking
```

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnet[*].id
}

output "default_sg_id" {
  value = aws_security_group.default.id
}

output "security_group_id" {
  value = aws_security_group.default.id
}

output "public_route_table" {
  value = aws_route_table.public.id
}
```
Created instaces with keys
![image](https://github.com/yanchoys/IT-Syndicate/assets/98917290/c714b62f-ef1d-45c6-985c-170c357b8a0b)

ALB and TargetGroup
![image](https://github.com/yanchoys/IT-Syndicate/assets/98917290/01e6d878-67c2-4597-8492-48e319d0ad0c)
![image](https://github.com/yanchoys/IT-Syndicate/assets/98917290/09fe75ef-3fc5-43ab-ae3d-e75ef69925d3)

Example system manager successed ansible playbook
![image](https://github.com/yanchoys/IT-Syndicate/assets/98917290/ca9e3362-5fa4-4498-b3d9-c97ffe55093c)

Ansible
```
- name: Install PostgreSQL
  become: yes
  yum:
    name: postgresql
    state: present

- name: Create PostgreSQL user
  become: yes
  postgresql_user:
    db: your_database
    name: your_user
    password: your_password
    state: present
  tags: db

- name: Create PostgreSQL database
  become: yes
  postgresql_db:
    name: your_database
    owner: your_user
    state: present
  tags: db
```
```
- name: Install required software
  become: yes
  package:
    name: "{{ item }}"
    state: present
  loop:
    - python3
    - python3-pip
    - nginx

- name: Create Nginx configuration
  copy:
    content: |
      server {
          listen 80;
          server_name 3.90.221.11; # Замените на ваш домен или IP-адрес

          location / {
              proxy_pass http://localhost:8000;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
          }

      }
    dest: /etc/nginx/nginx.conf
  notify: Reload Nginx
  tags: nginx

- name: Start and enable Nginx
  become: yes
  systemd:
    name: nginx
    state: started
    enabled: yes
  tags: nginx
```
```
- name: Update code from GitHub
  become: yes
  git:
    repo: https://github.com/yourusername/yourapp.git
    dest: /repos/
    update: yes
  tags: deployment

- name: Perform database migrations
  become: yes
  command: python /repos/manage.py migrate
  environment:
    DJANGO_SETTINGS_MODULE: setting.py  
    DB_HOST: 10.0.10.140  
    DB_PORT: 5432  
    DB_NAME: your_database  
    DB_USER: your_user  
    DB_PASSWORD: your_password  
  tags: migration

```
created ini file
```
[nginx]
3.90.221.11 ansible_ssh_user=ec2-user ansible_ssh_private_key_file=~/.ssh/key_post_aws.pem

[postgre]
10.0.10.140 ansible_ssh_user=ec2-user ansible_ssh_private_key_file=~/.ssh/key_nginx_aws.pem

[deploy]
54.90.162.120 ansible_ssh_user=ec2-user ansible_ssh_private_key_file=~/.ssh/key_nginx_aws.pem
```
