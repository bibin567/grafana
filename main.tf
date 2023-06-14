
resource "aws_instance" "grafana_instance" {
  ami                         = "ami-04a0ae173da5807d3" # Replace with the AMI ID for Amazon Linux in your region
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.example_subnet.id
  vpc_security_group_ids      = [aws_security_group.example_sg.id]
  key_name                    = var.key_pair_name # Replace with your key pair name

  tags = {
    Name = "grafana-instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y https://dl.grafana.com/oss/release/grafana-7.4.3-1.x86_64.rpm
              sudo systemctl enable grafana-server
              sudo systemctl start grafana-server

              # Install Prometheus
              wget https://github.com/prometheus/prometheus/releases/download/v2.30.0/prometheus-2.30.0.linux-amd64.tar.gz
              tar xvfz prometheus-2.30.0.linux-amd64.tar.gz
              cd prometheus-2.30.0.linux-amd64/
              nohup ./prometheus > /dev/null 2>&1 &

              # Install Node Exporter
              sudo useradd --no-create-home --shell /bin/false node_exporter
              wget https://github.com/prometheus/node_exporter/releases/download/v1.2.2/node_exporter-1.2.2.linux-amd64.tar.gz
              tar xvfz node_exporter-1.2.2.linux-amd64.tar.gz
              cd node_exporter-1.2.2.linux-amd64/
              sudo cp node_exporter /usr/local/bin/
              sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

              # Create Node Exporter service file
              sudo tee /etc/systemd/system/node_exporter.service > /dev/null << EOF2
              [Unit]
              Description=Node Exporter
              After=network.target

              [Service]
              User=node_exporter
              ExecStart=/usr/local/bin/node_exporter

              [Install]
              WantedBy=default.target
              EOF2

              sudo systemctl daemon-reload
              sudo systemctl enable node_exporter
              sudo systemctl start node_exporter

              echo "Grafana, Prometheus, and Node Exporter installation finished!"
              EOF
}

# Create a VPC
resource "aws_vpc" "example_vpc" {
  cidr_block = var.vpc_cidr_block
}

# Create a subnet within the VPC
resource "aws_subnet" "example_subnet" {
  vpc_id                  = aws_vpc.example_vpc.id
  cidr_block              = var.subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
}

# Create an internet gateway
resource "aws_internet_gateway" "example_igw" {
  vpc_id = aws_vpc.example_vpc.id
}

# Create a route table
resource "aws_route_table" "example_route_table" {
  vpc_id = aws_vpc.example_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example_igw.id
  }
}

# Associate the route table with the subnet
resource "aws_route_table_association" "example_association" {
  subnet_id      = aws_subnet.example_subnet.id
  route_table_id = aws_route_table.example_route_table.id
}

# Create a security group for the EC2 instances
resource "aws_security_group" "example_sg" {
  name        = var.security_group_name
  description = var.security_group_description
  vpc_id      = aws_vpc.example_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000 # Grafana port
    to_port     = 3000 # Grafana port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090 # Prometheus port
    to_port     = 9090 # Prometheus port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9100 # Node Exporter port
    to_port     = 9100 # Node Exporter port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

