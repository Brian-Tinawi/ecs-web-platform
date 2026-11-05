from diagrams import Cluster, Diagram, Edge
from diagrams.aws.compute import EC2, Fargate, ECS
from diagrams.aws.network import ALB, InternetGateway, NATGateway
from diagrams.aws.general import Users
from diagrams.aws.management import Cloudwatch
from diagrams.aws.devtools import Codebuild
from diagrams.aws.compute import ECR

out = "docs/architecture/"
attr = {"fontsize": "14"}

with Diagram("Before: one hand-managed IIS server", filename=out + "before", show=False, graph_attr=attr):
    Users("Customers") >> Edge(label="HTTP") >> EC2("1x EC2 / IIS\nhand-patched\nsingle AZ")

with Diagram("After: ECS Fargate across 2 AZs", filename=out + "after", show=False, graph_attr=attr, direction="LR"):
    users = Users("Customers")
    with Cluster("VPC 10.20.0.0/16"):
        igw = InternetGateway("IGW")
        alb = ALB("ALB (public /24 x2)")
        with Cluster("AZ a (private 10.20.10.0/24)"):
            t1 = Fargate("Task")
        with Cluster("AZ b (private 10.20.11.0/24)"):
            t2 = Fargate("Task")
        nat = NATGateway("1 NAT")
    ecr = ECR("ECR (scan on push)")
    cb = Codebuild("CodeBuild")
    cw = Cloudwatch("Alarms: 5xx,\nunhealthy, p95")
    users >> igw >> alb >> [t1, t2]
    [t1, t2] >> nat >> ecr
    cb >> ecr
    alb >> Edge(style="dashed") >> cw
