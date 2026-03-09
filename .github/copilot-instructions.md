# AI Coding Guidelines for Voting Application

## Architecture Overview
This is a microservices voting application with two-tier networking:
- **Frontend tier**: Vote (Flask/Python) and Result (Express/Node.js) services
- **Backend tier**: Worker (.NET), Redis, PostgreSQL

Data flow: Vote → Redis queue → Worker → PostgreSQL → Result (WebSocket updates)

## Service Communication Patterns
- Use Docker network names for service discovery: `redis`, `db`
- Votes stored as JSON in Redis list: `{"voter_id": "...", "vote": "..."}`
- Worker processes votes with reconnection logic for both Redis and PostgreSQL
- Result service uses `async.retry()` to wait for database connectivity

## Key Implementation Patterns
- **Vote service**: Cookie-based voter_id generation, Redis rpush for queuing
- **Result service**: Socket.IO for real-time updates, PostgreSQL COUNT queries
- **Worker service**: Thread.Sleep(100) polling, JSON deserialization with anonymous types
- **Health checks**: Custom shell scripts using redis-cli ping and psql SELECT 1

## Development Workflows
- **Testing**: Use phantomjs in `result/tests/tests.sh` for headless browser validation
- **Seeding**: Run `docker compose run --rm seed` to populate test data with Apache Bench
- **Dependencies**: Vote uses gunicorn, Result uses stoppable for graceful shutdown

## Docker Conventions
- Two-tier network architecture with isolated frontend/backend tiers
- Health checks ensure service startup order (Redis/PostgreSQL before dependents)
- Expose vote on 8080, result on 8081

## Code Style Notes
- Python: Flask with global Redis connection via Flask g object
- JavaScript: Express with Socket.IO, async for connection retries
- C#: .NET 7 console app with Npgsql and StackExchange.Redis
- Error handling: Reconnection logic in worker, retry mechanisms in result</content>
<parameter name="filePath">/home/magnus/devper/devops-quest-1/.github/copilot-instructions.md