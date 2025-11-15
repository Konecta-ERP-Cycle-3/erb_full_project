# GitHub Actions Troubleshooting Guide

## Common Issues and Solutions

### Issue: GitHub Actions Not Running After Push

#### Problem
When you push code to GitHub, the workflow doesn't trigger or doesn't appear in the Actions tab.

#### Solutions

1. **Check Workflow File Location**
   - ✅ **Correct**: `.github/workflows/ci-cd-pipeline.yml` (at repository root)
   - ❌ **Wrong**: `konecta_erp/.github/workflows/ci-cd-pipeline.yml` (in subdirectory)
   
   GitHub Actions only reads workflows from `.github/workflows/` at the repository root.

2. **Check Branch Name**
   - The workflow triggers on pushes to `main` or `develop` branches
   - If you're pushing to a different branch, it won't trigger
   - Solution: Push to `main` or `develop`, or update the workflow triggers

3. **Check Workflow File Syntax**
   - Ensure the YAML file is valid
   - Check for indentation errors
   - Verify all required fields are present

4. **Check Repository Settings**
   - Go to GitHub repository → Settings → Actions → General
   - Ensure "Allow all actions and reusable workflows" is enabled
   - Check if Actions are enabled for the repository

5. **Check File Permissions**
   - Ensure the workflow file is committed and pushed
   - Check if the file is in `.gitignore` (it shouldn't be)

### Issue: Workflow Runs But Fails

#### Authentication Failures

**Docker Hub Login Fails**
- **Error**: `Error: Cannot perform an interactive login from a non TTY device`
- **Solution**: Verify `DOCKER_USERNAME` and `DOCKER_PASSWORD` secrets are set correctly
- **Check**: Go to Settings → Secrets and variables → Actions

**AWS Authentication Fails**
- **Error**: `The security token included in the request is invalid`
- **Solution**: Verify AWS credentials are correct and not expired
- **Check**: Ensure `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are set

#### Build Failures

**.NET Build Fails**
- **Error**: `error CS0006: Metadata file could not be found`
- **Solution**: Check if all dependencies are restored
- **Fix**: Ensure `dotnet restore` runs before `dotnet build`

**Java Build Fails**
- **Error**: `Could not resolve dependencies`
- **Solution**: Check Maven configuration and network connectivity
- **Fix**: Verify `pom.xml` files are correct

**Docker Build Fails**
- **Error**: `failed to solve: failed to fetch`
- **Solution**: Check Dockerfile paths and context
- **Fix**: Verify Dockerfile exists at the specified path

#### Test Failures

**Tests Fail But Should Pass**
- **Error**: Tests fail with errors
- **Solution**: Check test code and dependencies
- **Note**: Some services might not have tests yet (that's OK, they show warnings)

### Issue: Deployment Fails

#### EC2 Connection Issues

**SSH Connection Fails**
- **Error**: `Permission denied (publickey)`
- **Solution**: 
  - Verify `EC2_SSH_PRIVATE_KEY` secret contains the full key (including BEGIN/END lines)
  - Check `EC2_USER` is correct (ubuntu/ec2-user)
  - Verify `EC2_HOST` is the correct IP/DNS

**EC2 Host Not Found**
- **Error**: `Could not resolve hostname`
- **Solution**: Verify `EC2_HOST` secret is correct
- **Check**: Ensure EC2 instance is running and has a public IP

#### Docker Issues on EC2

**Docker Not Installed**
- **Error**: `docker: command not found`
- **Solution**: Install Docker on EC2 instance
- **Fix**: See deployment guide for Docker installation steps

**Docker Compose Not Found**
- **Error**: `docker-compose: command not found`
- **Solution**: Install Docker Compose on EC2
- **Fix**: See deployment guide for Docker Compose installation

### Issue: Workflow Doesn't Show in Actions Tab

1. **Check if workflow file is committed**
   ```bash
   git status
   git add .github/workflows/ci-cd-pipeline.yml
   git commit -m "Add CI/CD workflow"
   git push
   ```

2. **Check if workflow file is in the correct location**
   - Should be: `.github/workflows/ci-cd-pipeline.yml`
   - Not: `konecta_erp/.github/workflows/ci-cd-pipeline.yml`

3. **Check repository Actions settings**
   - Go to Settings → Actions → General
   - Ensure Actions are enabled

4. **Wait a few seconds**
   - Sometimes there's a delay before workflows appear

### Issue: Workflow Triggers on Wrong Branch

**Problem**: Workflow runs on branches it shouldn't

**Solution**: Check the `on:` section in the workflow:
```yaml
on:
  push:
    branches:
      - main
      - develop
```

To trigger on all branches, use:
```yaml
on:
  push:
    branches:
      - '**'  # All branches
```

### Issue: Secrets Not Available

**Problem**: Secrets are not accessible in workflow

**Solutions**:
1. Verify secrets are set in GitHub repository settings
2. Check secret names match exactly (case-sensitive)
3. Ensure you're not trying to access secrets in a forked repository (secrets don't transfer to forks)

### Issue: Workflow Runs But Jobs Are Skipped

**Problem**: Jobs show as "skipped" instead of running

**Common Causes**:
1. **Conditional logic**: Check `if:` conditions in jobs
   ```yaml
   if: github.event_name != 'pull_request'  # Skips on PRs
   ```

2. **Dependencies**: If a required job fails, dependent jobs are skipped
   - Check previous job status
   - Fix failing jobs first

### Debugging Tips

1. **Enable Debug Logging**
   - Add secret: `ACTIONS_STEP_DEBUG` = `true`
   - Add secret: `ACTIONS_RUNNER_DEBUG` = `true`
   - This provides detailed logs

2. **Check Workflow Logs**
   - Go to Actions tab → Click on workflow run → Click on job → Expand steps
   - Look for error messages in red

3. **Test Locally**
   - Use `act` tool to test workflows locally
   - Install: `brew install act` (macOS) or download from GitHub

4. **Validate YAML**
   - Use online YAML validators
   - Check GitHub Actions syntax

### Quick Checklist

Before pushing, ensure:
- [ ] Workflow file is at `.github/workflows/ci-cd-pipeline.yml` (root)
- [ ] Workflow file is committed and pushed
- [ ] All required secrets are configured
- [ ] Branch name matches workflow triggers (`main` or `develop`)
- [ ] YAML syntax is valid
- [ ] Actions are enabled in repository settings

### Getting Help

If issues persist:
1. Check workflow logs in GitHub Actions tab
2. Review error messages carefully
3. Check this troubleshooting guide
4. Verify all secrets are set correctly
5. Test workflow manually using `workflow_dispatch` trigger

---

**Last Updated**: November 2024

