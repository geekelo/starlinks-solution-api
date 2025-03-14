# Starlink Installation Solutions API

## Overview
Starlink Installation Solutions API is a Ruby on Rails (RoR) application that provides backend support for managing Starlink installation requests, scheduling, user authentication, and related services.

## Features
- User authentication (JWT-based or Devise-based authentication)
- Installation request management
- Technician scheduling and assignment
- Job tracking and status updates
- Payment processing integration (Stripe, PayPal, etc.)
- Admin dashboard for managing users and installations

## Installation
### Prerequisites
Ensure you have the following installed:
- Ruby (>= 3.0)
- Rails (>= 7.0)
- PostgreSQL
- Redis (for background jobs, if required)
- Bundler

### Setup
1. Clone the repository:
   ```sh
   git clone https://github.com/your-repo/starlink-installation-api.git
   cd starlink-installation-api
   ```
2. Install dependencies:
   ```sh
   bundle install
   ```
3. Configure database:
   ```sh
   rails db:create db:migrate db:seed
   ```
4. Start the server:
   ```sh
   rails server
   ```

## API Endpoints
### Authentication
- `POST /api/v1/signup` - Register a new user
- `POST /api/v1/login` - Authenticate user and return a token
- `POST /api/v1/logout` - Log out the current user

### Installation Requests
- `GET /api/v1/installations` - Fetch all installation requests
- `POST /api/v1/installations` - Create a new installation request
- `PUT /api/v1/installations/:id` - Update an installation request
- `DELETE /api/v1/installations/:id` - Delete an installation request

### Technicians & Scheduling
- `GET /api/v1/technicians` - List all technicians
- `POST /api/v1/schedules` - Schedule an installation
- `PUT /api/v1/schedules/:id` - Update a scheduled job

## Environment Variables
Create a `.env` file and configure the following:
```
DATABASE_URL=postgres://user:password@localhost:5432/starlink_db
SECRET_KEY_BASE=your_secret_key
REDIS_URL=redis://localhost:6379/0
STRIPE_API_KEY=your_stripe_key
```

## Deployment
### Docker
1. Build and run the container:
   ```sh
   docker-compose up --build
   ```

### Heroku
1. Deploy the app:
   ```sh
   git push heroku main
   heroku run rails db:migrate
   ```

## Testing
Run the test suite using:
```sh
rspec
```

## Contributing
1. Fork the repository
2. Create a feature branch (`git checkout -b feature-name`)
3. Commit changes (`git commit -m 'Add new feature'`)
4. Push to the branch (`git push origin feature-name`)
5. Create a Pull Request

## License
This project is licensed under the MIT License.

