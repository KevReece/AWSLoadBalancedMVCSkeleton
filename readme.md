AWS - Load Balanced MVC Scaffold
================================

Ready for
---------
- AWS free tier (Not guaranteed)
- Windows 
- MVC/WebAPI .Net
- Load balanced
- Autoscale group 
- CodeDeploy
- CloudFormation
- Code packaging

Setup
-----

1. Create AWS account with VPC and Subnets and EC2 Key Pair
2. Run build\Package.bat and upload generated webPackage.zip to an S3 bucket
3. In CloudFormation, create stack using cloudformation.json (enter all parameters or update defaults in json)

Redeplying
----------

### Redeploying Infrastructure

In CloudFormation, create/update stack from cloudformation.json

### Redeploying Code

Run src\build\package.bat
Upload package to s3
In codedeploy, create new revision for uploaded package
