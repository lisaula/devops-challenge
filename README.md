
## Overview
This challenge is designed to test and showcase your expertise in DevOps practices, and cloud infrastructure deployment. The project comprises four interrelated packages within a monorepo structure: admin, api, database, and resizePhoto. Each of these components plays a crucial role in the lifecycle of a photo management application. By completing this challenge, you will demonstrate your skills in orchestrating a modern, scalable web application from development to deployment.

**You will have 72 hours to submit the challenge after starting and should not spend more than 8 hours total working on it. It is acceptable to submit something that is incomplete.**

### Project Structure
- [admin](packages/admin/README.md): A React-based user interface for uploading photos.

- [api](packages/api/README.md): An Express REST API for managing photo resources (create, read, single read, delete).

- [database](packages/database/README.md): Utilizing Drizzle ORM to define the database schema and handle migrations, presenting an interface for database operations.

- [resizePhoto](functions/resizePhoto/README.md): An AWS Lambda function that resizes photos upon upload to an S3 bucket, leveraging the Sharp library.

### Tech Stack
- TypeScript/Node.js: Core programming languages
- pnpm: Efficient package management in a monorepo
- React: Front-end library for the admin package
- Express: Web application framework for the api package
- Drizzle ORM: Object-Relational Mapping tool for database management
- Sharp: High-performance Node.js image processing
- Docker Compose: Local development and testing
- Terraform: Infrastructure as Code for AWS deployment
- AWS Lambda & Related Services: Cloud infrastructure

### Objectives
Your main objectives in this coding challenge are:

- Local Development Environment: Create a docker-compose.yml file that facilitates local development, allowing each component of the monorepo to run in a cohesive and isolated manner.
  - resizePhoto function does not need to run locally
  - Both the api and admin need to be served from the same url:port

- Build & Deployment: Utilize GitHub Actions for Continuous Integration and Deployment. Ensure all resources are correctly provisioned and configured for a production-like environment using Terraform.
  - Utilize esbuild to efficiently build each package within the monorepo.

### Requirements
Please ensure your final submission is a working version that includes:

- Docker-compose setup for local development.
- Terraform configuration files for AWS deployment.
- GitHub Actions configuration for the CI/CD pipeline.
- Support for multiple environments.
  - sandbox
  - staging
  - production

### Submission
- Fork this repository.
- Implement the required changes.
- Add `blakez08` as a collaborator on your fork once completed.
- Please remember to commit your changes early and frequently throughout the development process.

### Support
Throughout the challenge, you may encounter errors or have questions. You are encouraged to email bzeiger@sweatworks.net for any assistance, be it clarification on requirements or troubleshooting unexpected issues.
