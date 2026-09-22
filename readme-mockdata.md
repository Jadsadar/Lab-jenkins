cd backend
docker compose up -d
Get-Content db\seeds\003_demo_accounts.sql -Raw -Encoding UTF8 | docker exec -i petpaws-postgres psql -U petpaws -d petpaws -v ON_ERROR_STOP=1

cd api
npm install
npm run start:dev
