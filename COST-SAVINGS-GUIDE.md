# 💰 Cost Savings Guide

## Monthly Costs Breakdown

### Most Expensive Resources:
1. **NAT Gateways**: ~$65/month (2x NAT @ $32.40 each + data transfer)
2. **RDS SQL Server**: ~$50-100/month (db.t3.micro)
3. **ALB**: ~$16/month + data transfer
4. **ECS Services**: ~$20-50/month (depending on usage)

**Total monthly cost: ~$150-230/month**

## Cost Savings Options

### Option 1: Scale Services to 0 (Reversible) ✅ Recommended First
**Saves: ~$20-50/month**
- Scales all ECS services to 0 (no running tasks)
- Keeps infrastructure intact
- Easy to restore

```bash
cd konecta_erp/terraform/ERP
terraform apply -var-file=dev.tfvars.cost-savings -var="db_password=KonectaERP2024!DevPass" -auto-approve
```

### Option 2: Destroy NAT Gateways (Biggest Savings)
**Saves: ~$65/month**
- Most expensive resource
- Will break private subnet internet access
- Can recreate later

```bash
cd konecta_erp/terraform/ERP
terraform destroy \
  -target=module.vpc.aws_nat_gateway.main[0] \
  -target=module.vpc.aws_nat_gateway.main[1] \
  -target=module.vpc.aws_eip.nat[0] \
  -target=module.vpc.aws_eip.nat[1] \
  -var-file=dev.tfvars -var="db_password=KonectaERP2024!DevPass" -auto-approve
```

### Option 3: Destroy ALB
**Saves: ~$16/month**
- Removes load balancer
- Services won't be accessible from internet
- Can recreate later

```bash
cd konecta_erp/terraform/ERP
terraform destroy \
  -target=module.ecs.aws_lb.alb \
  -target=module.ecs.aws_lb_target_group.api_gateway \
  -target=module.ecs.aws_lb_listener.api_gateway \
  -var-file=dev.tfvars -var="db_password=KonectaERP2024!DevPass" -auto-approve
```

### Option 4: Stop/Delete RDS
**Saves: ~$50-100/month**
- ⚠️ **WARNING: This will DELETE ALL DATA!**
- Consider taking a snapshot first
- Can recreate later (but data will be lost)

```bash
# Take snapshot first!
aws rds create-db-snapshot \
  --db-instance-identifier konecta-ass1-dev-db \
  --db-snapshot-identifier konecta-ass1-dev-db-snapshot-$(date +%Y%m%d)

# Then destroy
cd konecta_erp/terraform/ERP
terraform destroy \
  -target=module.rds.aws_db_instance.this \
  -var-file=dev.tfvars -var="db_password=KonectaERP2024!DevPass" -auto-approve
```

### Option 5: Full Destruction (Maximum Savings)
**Saves: ~$150-230/month**
- Destroys everything
- Only keeps ECR repositories (free)
- ⚠️ **WARNING: All data will be lost!**

```bash
cd konecta_erp/terraform/ERP
terraform destroy -var-file=dev.tfvars -var="db_password=KonectaERP2024!DevPass"
```

## Recommended Approach

1. **First**: Scale services to 0 (Option 1)
2. **Then**: Destroy NAT Gateways (Option 2) - biggest savings
3. **Then**: Destroy ALB (Option 3)
4. **Last**: Delete RDS only if you don't need data (Option 4)

## Restoring Services

To restore after scaling to 0:
```bash
cd konecta_erp/terraform/ERP
terraform apply -var-file=dev.tfvars -var="db_password=KonectaERP2024!DevPass"
```

## Quick Commands

```bash
# Scale all services to 0
terraform apply -var-file=dev.tfvars.cost-savings -var="db_password=KonectaERP2024!DevPass" -auto-approve

# Destroy NAT Gateways only
terraform destroy -target=module.vpc.aws_nat_gateway.main[0] -target=module.vpc.aws_nat_gateway.main[1] -target=module.vpc.aws_eip.nat[0] -target=module.vpc.aws_eip.nat[1] -var-file=dev.tfvars -var="db_password=KonectaERP2024!DevPass" -auto-approve

# Destroy ALB only
terraform destroy -target=module.ecs.aws_lb.alb -var-file=dev.tfvars -var="db_password=KonectaERP2024!DevPass" -auto-approve

# Destroy RDS (⚠️ deletes data!)
terraform destroy -target=module.rds.aws_db_instance.this -var-file=dev.tfvars -var="db_password=KonectaERP2024!DevPass" -auto-approve
```

