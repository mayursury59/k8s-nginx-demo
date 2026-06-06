# nginx-demo — Build, Push, and Deploy to AWS EKS

This project demonstrates creating an EKS cluster using AWS CLI, deploying NGINX, and exposing it via LoadBalancer.

---

## Environment

export AWS_REGION=us-east-1

---

## 1. Verify AWS Identity

aws sts get-caller-identity

Output:
{
  "UserId": "AIDASLX4B6ZLQVTTGFCAS",
  "Account": "162663626327",
  "Arn": "arn:aws:iam::162663626327:user/github-actions-deployer"
}

---

## 2. Create EKS Cluster

aws eks create-cluster \
  --name nginx-demo \
  --region us-east-1 \
  --kubernetes-version 1.28 \
  --role-arn arn:aws:iam::162663626327:role/EKSClusterRole \
  --resources-vpc-config subnetIds=subnet-01bb20e36ff4ac64b,subnet-0d728d42d67a72cd5,securityGroupIds=sg-061236de65cd7f891

---

## 3. Create Node Group

aws eks create-nodegroup \
  --cluster-name nginx-demo \
  --nodegroup-name nginx-demo-nodes \
  --region us-east-1 \
  --node-role arn:aws:iam::162663626327:role/EKSNodeRole \
  --subnets subnet-01bb20e36ff4ac64b subnet-0d728d42d67a72cd5 \
  --scaling-config minSize=2,maxSize=4,desiredSize=2 \
  --instance-types t3.medium \
  --ami-type AL2_x86_64

---

## 4. Install kubectl

curl -LO https://dl.k8s.io/release/v1.28.0/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

---

## 5. Configure kubeconfig

aws eks update-kubeconfig \
  --region us-east-1 \
  --name nginx-demo

---

## 6. Verify Nodes

kubectl get node

Output:
ip-172-31-12-166.ec2.internal   Ready
ip-172-31-19-128.ec2.internal   Ready

---

## 7. Deploy NGINX

kubectl create deployment nginx-demo --image=nginx
kubectl get pods

Output:
nginx-demo-6d846b98b9-2wdqr   Running
nginx-demo-6d846b98b9-5b2r4   Running

---

## 8. Expose Service

kubectl expose deployment nginx-demo \
  --type=LoadBalancer \
  --name nginx-demo-service \
  --port 80

---

## 9. Get Service URL

kubectl get svc

Output:
nginx-demo-service   LoadBalancer   ac73646d933a24def8d5d5aca76cbbe6-1773940705.us-east-1.elb.amazonaws.com

---

## 10. Test Application

curl http://ac73646d933a24def8d5d5aca76cbbe6-1773940705.us-east-1.elb.amazonaws.com

Output:
Welcome to nginx

---

## 11. Cleanup

kubectl delete svc nginx-demo-service
kubectl delete deployment nginx-demo

aws eks update-nodegroup-config \
  --cluster-name nginx-demo \
  --nodegroup-name nginx-demo-nodes \
  --scaling-config minSize=0,maxSize=1,desiredSize=0 \
  --region us-east-1

aws eks delete-nodegroup \
  --cluster-name nginx-demo \
  --nodegroup-name nginx-demo-nodes \
  --region us-east-1

aws eks delete-cluster \
  --name nginx-demo \
  --region us-east-1

---

## Final Result

- EKS Cluster created
- Nodegroup with 2 nodes
- NGINX deployed
- Service exposed via LoadBalancer
- Accessible via public URL
