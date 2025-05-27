# AWS Smart Resource Monitor

This project scans your AWS account daily for:
- Running EC2 Instances
- Available RDS Databases
- Idle EBS Volumes (not attached)
- Unused Security Groups (not attached to ENIs)

## 🧱 Architecture

![image](https://github.com/user-attachments/assets/ba6a7ab1-ebda-471e-991d-e860a65e92cf)



## 🚀 Setup

1. Clone the repo
2. Run `terraform init && terraform apply` in the `terraform/` folder
3. Lambda runs once a day and sends email via SNS

## 📬 Output

You’ll get a daily email like:

```
Idle EBS Volume: vol-0123abcd | 50GB
Unused Security Group: sg-1a2b3c Name: legacy-db
```

## 🔒 Required AWS Permissions
- IAM role creation
- Lambda, SNS, CloudWatch Events, EC2, RDS access

---

🚀 If you liked this guide…  
👉 Follow me for more AWS automation projects  
👉 Check out my portfolio: https://jbrewinthecloud.com  
👉 Let’s connect on LinkedIn! [Jermaine Brewer](https://www.linkedin.com/in/jermainebrewer/)
